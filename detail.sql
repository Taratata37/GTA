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
SELECT 'Inscrit depuis le' as title,
	STRFTIME('%d/%m/%Y',DateInscriptionPersonne) as description
	FROM Personne
	WHERE IdPersonne = $id;



select 
    'button' as component,
    'center' as justify;
select 
    'noter_presence.sql?id=' || $id       as link,
    'success' as color,
    'Valider la présence ce jour' as title,
	COALESCE(ven.IdPersonne, FALSE )    as disabled
	FROM Personne per LEFT JOIN Venir ven ON (per.IdPersonne=ven.IdPersonne AND ven.date = date('now'))
	WHERE $id IS NOT NULL
	AND per.IdPersonne = $id ;
select 
    'maj_utilisateur.sql?IdPersonne=' || $id  as link,
    'blue' as color,
    'Modifier les infos' as title;

	
	
select 
    'form'            as component,
	'Sacrements demandés' AS title,
	'MAJ sacrements' as validate,
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
LEFT JOIN Remplir ON (Formalite.IdFormalite = Remplir.IdFormalite AND Remplir.IdPersonne = $id );



select 
	'table' as component,
	TRUE    as hover,
	TRUE    as striped_rows,
	'Dates auxquelles la personne était présente' as description,
	'Personne présente à aucune réunion' as empty_description,
	TRUE    as small; 
SELECT STRFTIME('%d/%m/%Y',DATE) as date
FROM Venir
WHERE IdPersonne = $id;



select 
    'foldable' as component;
select 
    'Zone de danger' as title,
    'L''opération suivante est irrémédiable. Aucune confirmation ne sera demandée ! Cliquez [ici](suppr_utilisateur.sql?IdPersonne=' || $id || ') pour retirer définitivement l''utilisateur du système ainsi que toutes ses dépendances.' as description_md,
    FALSE                as expanded;
