SELECT 'redirect' AS component, 'index' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides scn
    INNER JOIN personne per ON per.idDoyenne = scn.IdDoyenne OR per.idDoyenne IS NULL
    WHERE (
        EXISTS ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') and IdDoyenne IS NULL  ) -- admin
        OR ( per.IdDoyenne = ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') )) -- responsable local
    )
    AND per.idPersonne = $id
);


select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;


SELECT 
'alert' as component,
etatresume.titre as title,
etatresume.description as description,
etatresume.couleur as color,
etatresume.etat as icon
FROM Status_Personne etatresume
/*
FROM(  
		select
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,"alert-triangle", -- Le dossier initial est incomplet
				iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
					iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) = 0 ,"","file-report"),
					"user-search")
		) as etat 
		,
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,"Dossier incomplet", -- Le dossier initial est incomplet
			iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
					iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) = 0 ,"","Formalités incomplètes"),
					"Information")
		) as titre
		,
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,"Il manque un moyen de contact ou un sacrement demandé pour compléter le dossier de ce recommençant", -- Le dossier initial est incomplet
			iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
				iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) = 0 ,"","Il reste des formalités à remplir par ce recommençant"),
					"Cette personne n'est pour l'instant venue à aucune rencontre diocésaine")
		) as description
		,
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,"orange", -- Le dossier initial est incomplet
			iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
				iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) = 0 ,"","blue"),
					"dark-grey")
		) as couleur
		FROM Personne Where Personne.IdPersonne = $id

) etatresume*/
WHERE length(etatresume.etat) > 1 and etatresume.IdPersonne = $id;



SELECT 
'alert' as component,
'Pris en compte' as title,
$majok as description,
'check' as icon,
'green' as color
WHERE $majok is not null;




select 
    'steps' as component,
	TRUE as counter 
	WHERE EXISTS (
    SELECT 1 
    FROM demander dem
    INNER JOIN Sacrement sac ON dem.IdSacrement = sac.IdSacrement
    WHERE dem.IdPersonne = $id AND sac.NomSacrement = 'Baptême'
) ;
SELECT title, active, link FROM (
	SELECT * FROM(
    SELECT 'Accueil' as title,
           CASE WHEN accueil.IdPersonne IS NULL THEN TRUE ELSE FALSE END as active,
           CASE WHEN accueil.IdPersonne IS NULL THEN '/noter_presence.sql?id=' || $id || '&codeevt=ACCUE' ELSE NULL END as link,
           1 as ordre
    FROM Personne per
    LEFT JOIN Venir accueil ON (per.IdPersonne = accueil.IdPersonne AND accueil.codeType_evenement = 'ACCUE')
    WHERE per.IdPersonne = $id
    
    UNION ALL
    
    SELECT 'Entrée en Eglise' as title,
           CASE WHEN accueil.IdPersonne IS NOT NULL AND entree.IdPersonne IS NULL THEN TRUE ELSE FALSE END as active,
           CASE WHEN accueil.IdPersonne IS NOT NULL AND entree.IdPersonne IS NULL THEN '/noter_presence.sql?id=' || $id || '&codeevt=ENTRE' ELSE NULL END as link,
           2 as ordre
    FROM Personne per
    LEFT JOIN Venir accueil ON (per.IdPersonne = accueil.IdPersonne AND accueil.codeType_evenement = 'ACCUE')
    LEFT JOIN Venir entree ON (per.IdPersonne = entree.IdPersonne AND entree.codeType_evenement = 'ENTRE')
    WHERE per.IdPersonne = $id
    
    UNION ALL
    
    SELECT 'Appel décisif' as title,
           CASE WHEN entree.IdPersonne IS NOT NULL AND appel.IdPersonne IS NULL THEN TRUE ELSE FALSE END as active,
           CASE WHEN entree.IdPersonne IS NOT NULL AND appel.IdPersonne IS NULL THEN '/noter_presence.sql?id=' || $id || '&codeevt=APDEC' ELSE NULL END as link,
           3 as ordre
    FROM Personne per
    LEFT JOIN Venir entree ON (per.IdPersonne = entree.IdPersonne AND entree.codeType_evenement = 'ENTRE')
    LEFT JOIN Venir appel ON (per.IdPersonne = appel.IdPersonne AND appel.codeType_evenement = 'APDEC')
    WHERE per.IdPersonne = $id
    
    UNION ALL
    
    SELECT 'Réception des sacrements' as title,
           CASE WHEN appel.IdPersonne IS NOT NULL AND sacrement.IdPersonne IS NULL THEN TRUE ELSE FALSE END as active,
           CASE WHEN appel.IdPersonne IS NOT NULL AND sacrement.IdPersonne IS NULL THEN '/noter_presence.sql?id=' || $id || '&codeevt=SCRMT' ELSE NULL END as link,
           4 as ordre
    FROM Personne per
    LEFT JOIN Venir appel ON (per.IdPersonne = appel.IdPersonne AND appel.codeType_evenement = 'APDEC')
    LEFT JOIN Venir sacrement ON (per.IdPersonne = sacrement.IdPersonne AND sacrement.codeType_evenement = 'SCRMT')
    WHERE per.IdPersonne = $id
)ORDER BY ordre
) AS etapes

WHERE EXISTS (
    SELECT 1 
    FROM demander dem
    INNER JOIN Sacrement sac ON dem.IdSacrement = sac.IdSacrement
    WHERE dem.IdPersonne = $id AND sac.NomSacrement = 'Baptême'
) ;



select 
    'datagrid' as component;
select 
    'Nom' as title,
    NomPersonne      as description
	FROM Personne
WHERE IdPersonne = $id;
select 
    'Nom de jeune fille' as title,
    NomJfPersonne  as description
	FROM Personne
	WHERE SexePersonne = "F" ANd IdPersonne = $id;
select 
	'Prénom' as title,
	PrenomPersonne  as description
	FROM Personne WHERE IdPersonne = $id;
select 
	'Courriel' as title,
	CourrielPersonne  as description
	FROM Personne WHERE IdPersonne = $id;
select 
    'Téléphone' as title,
    TelephonePersonne  as description
	FROM Personne
	WHERE IdPersonne = $id;
SELECT 'Date d''inscription' as title,
	STRFTIME('%d/%m/%Y',DateInscriptionPersonne) as description
	FROM Personne
	WHERE IdPersonne = $id;
select 
    'Section' as title,
    sec.NomSection  as description
	FROM Personne per
	INNER JOIN Section sec ON sec.IdSection = per.IdSection
	WHERE per.IdPersonne = $id;
select 
    'Promotion' as title,
    pro.NomPromotion  as description
	FROM Personne per
	INNER JOIN promotion pro ON pro.IdPromotion = per.IdPromotion
	WHERE per.IdPersonne = $id;
select 
    'Doyenné' as title,
    doy.NomDoyenne  as description
	FROM Personne per
	LEFT JOIN doyenne doy ON doy.IdDoyenne = per.IdDoyenne
	WHERE per.IdPersonne = $id;
select 
    'Adresse' as title,
    per.RuePersonne ||  ' - '  || per.CpPersonne ||  ' '  || per.VillePersonne  as description
	FROM Personne per
	WHERE per.IdPersonne = $id;
select 
	'Accès espace en ligne' as title,
	pinPersonne  as description
    ,'/public/detail.sql?id=' || IdPersonne || '&pin='|| pinPersonne as link
	FROM Personne WHERE IdPersonne = $id;


select 
    'button' as component,
    'center' as justify;
SELECT
    'noter_presence.sql?id=' || $id || '&codeevt=RECOL' as link,
    'success' as color,
    'Valider la présence ce jour' as title,
    COALESCE((SELECT 1 FROM Venir ven WHERE ven.IdPersonne = per.IdPersonne AND ven.date = date('now') LIMIT 1), FALSE) as disabled
FROM
    Personne per
WHERE
    $id IS NOT NULL
    AND per.IdPersonne = $id;
SELECT
    'noter_presence.sql?id=' || $id as link,
    'white' as color,
    'Valider la présence ...' as title;
select 
    'maj_utilisateur.sql?IdPersonne=' || $id  as link,
    'blue' as color,
    'Modifier les coordonnées' as title;

	
	
select 
    'form'            as component,
	'Accompagnement demandé' AS title,
	'Enregistrer' as validate,
    'demander.sql?id=' || $id as action;
SELECT 'nom_s[]' as name,
	'' as label,
	'select' as type,
    TRUE     as searchable,
	TRUE             as multiple,
	'press ctrl to select multiple values' as description,
	TRUE as required,
    json_group_array(
		json_object(
			'label', Sacrement.NomSacrement,
			'value', Sacrement.IdSacrement,
			'selected', Demander.IdSacrement is not null
		)
	) as options
	from Sacrement
	left join Demander
    on  Sacrement.IdSacrement = Demander.IdSacrement
    and Demander.idPersonne = $id;
	


select 
    'list'             as component,
    'Formalités' as title;
select 
    Formalite.NomFormalite             as title,
    'remplir_formalite.sql?IdPersonne='|| $id || '&IdFormalite=' || Formalite.IdFormalite || '&ok=' || COALESCE (Remplir.IdPersonne,'-1') as link,
    Remplir.CommentaireFormalite ||' - Cliquez pour changer l''état'    as description,
    iif(Remplir.IdPersonne IS NULL, 'red','green')                 as color,
    iif(Remplir.IdPersonne IS NULL, 'arrow-big-right','check')       as icon
FROM Formalite
INNER JOIN Personne ON (Personne.IdSection = Formalite.IdSection AND Personne.IdPersonne = $id )
LEFT JOIN Remplir ON (Formalite.IdFormalite = Remplir.IdFormalite AND Remplir.IdPersonne = $id )
--WHERE Formalite.IdSection = 2

;


select 
	'table' as component,
	TRUE    as hover,
	TRUE    as striped_rows,
    'supprimer' as markdown,
	'Dates auxquelles la personne était présente' as description,
	'Personne présente à aucune réunion' as empty_description,
	TRUE    as small; 
SELECT STRFTIME('%d/%m/%Y',DATE) as date
, NomType_evenement as 'Evènement'
,'[supprimer](supprimer_presence.sql?IdPersonne=' || $id || '&date=' || date || '&codeevt=' || Venir.codeType_evenement || ')' as supprimer
FROM Venir
LEFT JOIN type_evenement ON type_evenement.codeType_evenement = venir.codeType_evenement
WHERE IdPersonne = $id;



select 
    'foldable' as component;
select 
    'Zone de danger' as title,
    'L''opération suivante est irrémédiable. Aucune confirmation ne sera demandée ! Cliquez [ici](/admin/suppr_utilisateur.sql?IdPersonne=' || $id || ') pour retirer définitivement l''utilisateur du système ainsi que toutes ses dépendances.' as description_md,
    FALSE                as expanded;
