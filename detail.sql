SELECT 'redirect' AS component, 'index' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides scn
    LEFT JOIN Personne per ON per.IdPersonne = $id
    LEFT JOIN Equipe equ ON equ.IdEquipe = per.IdEquipe
    WHERE jeton = sqlpage.cookie('jeton_session')
    AND (
        scn.IdDoyenne IS NULL                        -- admin : accès à tout
        OR equ.IdDoyenne = scn.IdDoyenne             -- responsable local : même doyenné
    )
);


select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;


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
    'modal'                as component,
    'form_modal_details'   as id,
    'Modification de la personne' as title,
    TRUE                   as large,
    'maj_utilisateur.sql?IdPersonne=' || $id as embed;

select 
    'modal'                as component,
    'form_modal_validerpresence'   as id,
    'Pointer la venue de la personne' as title,
    TRUE                   as large,
    'f_noter_presence.sql?id=' || $id as embed;


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
SELECT
    'Doyenné' AS title,
    doy.NomDoyenne AS description
FROM Personne per
LEFT JOIN Equipe  equ ON equ.IdEquipe  = per.IdEquipe
LEFT JOIN Doyenne doy ON doy.IdDoyenne = equ.IdDoyenne
WHERE per.IdPersonne = $id;
SELECT
    'equipe' AS title,
    equ.LibelleEquipe AS description
FROM Personne per
LEFT JOIN Equipe  equ ON equ.IdEquipe  = per.IdEquipe
WHERE per.IdPersonne = $id;
select 
    'Adresse' as title,
    per.RuePersonne ||  ' - '  || per.CpPersonne ||  ' '  || per.VillePersonne  as description
	FROM Personne per
	WHERE per.IdPersonne = $id;
select 
	'Accès personnel en ligne' as title,
	pinPersonne  as description
    ,'/public/detail.sql?id=' || IdPersonne || '&pin='|| pinPersonne as link
	FROM Personne WHERE IdPersonne = $id;


select 
    'button' as component,
    'center' as justify;
SELECT
    'noter_presence.sql?id=' || $id || '&codeevt=RECOL' as link,
    'success' as color,
    'check' as icon,
    'Valider la présence ce jour' as title,
    COALESCE((SELECT 1 FROM Venir ven WHERE ven.IdPersonne = per.IdPersonne AND ven.date = date('now') LIMIT 1), FALSE) as disabled
FROM
    Personne per
WHERE
    $id IS NOT NULL
    AND per.IdPersonne = $id;



SELECT
    '#form_modal_validerpresence' as link,
    'lime' as color,

    'Valider la présence ...' as title;
select 
    '#form_modal_details'     as link,
    'blue' as color,
    'Modifier les coordonnées'           as tooltip,
    'edit' as icon
    --,'Modifier les coordonnées' as title
;

select 
    '/detail_print.sql?id=' || $id                 as link,
    TRUE                as narrow,
    'printer' as icon,
    'dark'           as color,
    'Imprimer'           as tooltip;	
	
SELECT 'datagrid' AS component, 'Accompagnement' AS title;

-- Cas : au moins un sacrement demandé
SELECT 
    'Demande enregistrée' AS title,
    sac.NomSacrement AS description,
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
select 
    'modal'                as component,
    'my_embed_form_modal'  as id,
    'Modification des sacrements demandés' as title,
    TRUE                   as large,
    '/f_accompagnement.sql?id=' || $id as embed;
select 
    'button' as component;
select 
    'Modfier l''accompagnement demandé' as title,
    'blue' as color,
    'edit' as icon,
    '#my_embed_form_modal'     as link;


select 
    'list'             as component,
    'Formalités' as title;
select 
    Formalite.NomFormalite             as title,
    'remplir_formalite.sql?IdPersonne='|| $id || '&IdFormalite=' || Formalite.IdFormalite || '&ok=' || COALESCE(Remplir.IdPersonne,'-1') as link,
    Remplir.CommentaireFormalite || ' - Cliquez pour changer l''état' as description,
    iif(Remplir.IdPersonne IS NULL, 'red','green')          as color,
    iif(Remplir.IdPersonne IS NULL, 'arrow-big-right','check') as icon
FROM Formalite
INNER JOIN Personne ON (Personne.IdSection = Formalite.IdSection AND Personne.IdPersonne = $id)
LEFT JOIN Remplir ON (Formalite.IdFormalite = Remplir.IdFormalite AND Remplir.IdPersonne = $id);

-- Justificatifs : une carte par formalité qui en possède un
select 'card' as component, 'Justificatifs déposés' as title, 3 as columns
WHERE EXISTS (
    SELECT 1 FROM Remplir
    INNER JOIN Formalite ON Formalite.IdFormalite = Remplir.IdFormalite
    INNER JOIN Personne  ON Personne.IdSection = Formalite.IdSection AND Personne.IdPersonne = $id
    WHERE Remplir.IdPersonne = $id AND Remplir.Justificatif IS NOT NULL
);

SELECT
    Formalite.NomFormalite            as title,
    Remplir.CommentaireFormalite      as description,
    -- Si c'est une image (data URL image/*) on l'affiche directement
    CASE WHEN Remplir.Justificatif LIKE 'data:image/%'
         THEN Remplir.Justificatif
         ELSE NULL
    END                               as top_image
FROM Remplir
INNER JOIN Formalite ON Formalite.IdFormalite = Remplir.IdFormalite
INNER JOIN Personne  ON Personne.IdSection = Formalite.IdSection AND Personne.IdPersonne = $id
WHERE Remplir.IdPersonne = $id AND NULLIF(Remplir.Justificatif,'') IS NOT NULL;


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
,'[🗑️ supprimer](supprimer_presence.sql?IdPersonne=' || $id || '&date=' || date || '&codeevt=' || Venir.codeType_evenement || ')' as supprimer
FROM Venir
LEFT JOIN type_evenement ON type_evenement.codeType_evenement = venir.codeType_evenement
WHERE IdPersonne = $id;

select 
    'modal'                as component,
    'modal_changer_promo'  as id,
    'Modification de la promo' as title,
    TRUE                   as large,
    '/gestion/f_changer_promo.sql?id=' || $id as embed;


select 'foldable' as component;

select
    'Zone de danger' as title,
    'Cliquez [🧭là](#modal_changer_promo) pour changer la personne de promotion. '
    || 'Cela ré-initialisera sa date d''inscription.'
    || CASE
        WHEN EXISTS (
            SELECT 1 FROM v_sessions_valides
            WHERE jeton = sqlpage.cookie('jeton_session')
              AND IdDoyenne IS NULL
        )
        THEN char(10) || char(10)
        || 'L''opération suivante est irrémédiable. Aucune confirmation ne sera demandée ! '
        || 'Cliquez [🗑️ici](/admin/suppr_utilisateur.sql?IdPersonne=' || $id || ') '
        || 'pour retirer définitivement l''utilisateur du système ainsi que toutes ses dépendances.'
        ELSE ''
       END                  as description_md,
    FALSE                   as expanded
;