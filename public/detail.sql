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



SELECT 'modal' AS component, 'modal_rgpd' AS id, 'Politique de confidentialité' AS title,'rgpd.sql'as embed;




Select 
'text' as component,
'# Récaputilatif personnel - diocèse de Tours
Bienvenue sur la page récapitulant l''état actuel de votre dossier. 

Vous pouvez également consulter les [Infos RGPD](#modal_rgpd)

'  as contents_md;


SELECT 'card' AS component, 2 AS columns;
-- Carte identité
SELECT 
    per.PrenomPersonne || ' ' || COALESCE(nullif(per.NomPersonne,''),per.NomJfPersonne) AS title,
    sec.NomSection || ' — ' || per.VillePersonne AS description,
    'user' AS icon,
    'blue' AS color
FROM Personne per
LEFT JOIN Section sec ON sec.IdSection = per.IdSection
WHERE per.IdPersonne = $id;
select 
	'Courriel' as title,
    'mail' AS icon,
	CourrielPersonne  as description
	FROM Personne WHERE IdPersonne = $id;


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







-- AVANT : form avec select disabled
-- APRÈS : datagrid clair
SELECT 'datagrid' AS component, 'Accompagnement' AS title;

-- Cas : au moins un sacrement demandé
SELECT 
    sac.NomSacrement AS title,
    'Demandé'        AS description,
    'arrow-big-right'          AS icon,
    'blue'          AS color
FROM Sacrement sac
INNER JOIN Demander dem ON sac.IdSacrement = dem.IdSacrement AND dem.idPersonne = $id


UNION ALL

-- Cas : aucun sacrement demandé
SELECT
    '' AS title,
    'A remplir'                             AS description,
    'alert-triangle'                            AS icon,
    'red'                          AS color
WHERE NOT EXISTS (
    SELECT 1 FROM Demander WHERE idPersonne = $id
);


SELECT 
    'qrcode'                    AS component,
    'QR Code d''accès rapide'  AS title,
    $id                         AS id,
    '/detail.sql?id=' || $id    AS url;


select 
    'datagrid' as component;
select 
    'Nom de jeune fille' as title,
    NomJfPersonne  as description
	FROM Personne
	WHERE SexePersonne = "F" ANd IdPersonne = $id;
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
	


-- Onglets de navigation
SELECT 'tab' AS component;
SELECT 'Formalités' AS title, 'clipboard-list' AS icon, ($tab IS NULL OR $tab = 'Formalités')  AS active ,'?tab=Formalités&id=' || $id || '&pin=' || $pin || '#tabs' as link;
SELECT 'Présences' AS title, 'calendar-check' AS icon,($tab = 'Présences') as active, '?tab=Présences&id=' || $id || '&pin=' || $pin || '#tabs' as link;


select 
    'list'             as component,
    'Formalités' as title
WHERE $tab IS NULL OR $tab = 'Formalités';
select 
    Formalite.NomFormalite             as title,
    Remplir.CommentaireFormalite as description,
    iif(Remplir.IdPersonne IS NULL, 'red','green')                 as color,
    iif(Remplir.IdPersonne IS NULL, 'arrow-big-right','check')       as icon
FROM Formalite
INNER JOIN Personne ON (Personne.IdSection = Formalite.IdSection AND Personne.IdPersonne = $id )
LEFT JOIN Remplir ON (Formalite.IdFormalite = Remplir.IdFormalite AND Remplir.IdPersonne = $id )
WHERE $tab IS NULL OR $tab = 'Formalités' AND EXISTS (
    SELECT 1 FROM Demander WHERE idPersonne = $id
);

;


select 
	'table' as component,
	TRUE    as hover,
	TRUE    as striped_rows,
	'Dates auxquelles la personne était présente' as description,
	'Personne présente à aucune réunion' as empty_description,
	TRUE    as small
WHERE $tab = 'Présences'; 
SELECT STRFTIME('%d/%m/%Y',DATE) as date,NomType_evenement as 'Evènement'
FROM Venir
LEFT JOIN type_evenement ON type_evenement.codeType_evenement = venir.codeType_evenement
WHERE IdPersonne = $id AND ($tab = 'Présences');
SELECT 'html' AS component;
SELECT '<a name="tabs"></a>' AS html;
