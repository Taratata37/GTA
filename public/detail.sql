SELECT
    'redirect' AS component,
    'login.sql' AS link
WHERE NOT EXISTS  (SELECT 1 FROM personne WHERE idPersonne = $id AND pinPersonne = $pin AND DateInscriptionPersonne  > date('now', '-18 months'));

/*
select 
    'shell'                     as component,
    'GTA - Gestion des Tracasseries Administratives' as title,
    'database'                  as icon,
    'boxed'                     as layout,
    '#'                         as link,
    'fr-FR'                     as language;

*/
SELECT 
'alert' as component,
etatresume.titre as title,
etatresume.description as description,
etatresume.couleur as color,
etatresume.etat as icon
FROM Status_Personne etatresume
WHERE length(etatresume.etat) > 1 and etatresume.IdPersonne = $id;



SELECT 
'alert' as component,
'Pris en compte' as title,
$majok as description,
'check' as icon,
'green' as color
WHERE $majok is not null;


Select 
'text' as component,
'# Récaputilatif personnel - diocèse de Tours
Bienvenue sur la page récapitulant l''état actuel de votre dossier.
La visibilité sur certaines données personnelle est réduite pour des questions de sécurité.

Conformément à la législation en vigueur, vous disposez d'' un droit d''accès et de rectification de vos données. 
Veuillez contacter votre responsable de doyenné si vous constatez une erreur dans votre dossier.

Vos données personnelles ne seront plus accessible sur cette page à partir de 18 mois d''ancienneté, et seront supprimées rapidement après.
' as contents_md;

select 
    'steps' as component,
	TRUE as counter 
	WHERE EXISTS (
    SELECT 1 
    FROM demander dem
    INNER JOIN Sacrement sac ON dem.IdSacrement = sac.IdSacrement
    WHERE dem.IdPersonne = $id AND sac.NomSacrement = 'Baptême'
) ;
SELECT title, active FROM (
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
     SUBSTR(TelephonePersonne, 1, LENGTH(TelephonePersonne) - 2) || 'XX'  as description
	FROM Personne
	WHERE IdPersonne = $id;
SELECT
    'Ancienneté en mois' AS title,
    CAST((STRFTIME('%m', 'now') - STRFTIME('%m', DateInscriptionPersonne) +
          (STRFTIME('%Y', 'now') - STRFTIME('%Y', DateInscriptionPersonne)) * 12) AS INTEGER) AS description
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
    'XXXXX, ' || per.CpPersonne ||  ' '  || per.VillePersonne  as description
	FROM Personne per
	WHERE per.IdPersonne = $id;
	
select 
    'form'            as component,
	'Accompagnement demandé' AS title,
	'Enregistrer' as validate,
    '#'  as action;
SELECT 'nom_s[]' as name,
	'' as label,
	'select' as type,
    TRUE     as searchable,
     TRUE     as disabled,
	TRUE     as multiple,
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
    Remplir.CommentaireFormalite as description,
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
	'Dates auxquelles la personne était présente' as description,
	'Personne présente à aucune réunion' as empty_description,
	TRUE    as small; 
SELECT STRFTIME('%d/%m/%Y',DATE) as date,NomType_evenement as 'Evènement'
FROM Venir
LEFT JOIN type_evenement ON type_evenement.codeType_evenement = venir.codeType_evenement
WHERE IdPersonne = $id;
