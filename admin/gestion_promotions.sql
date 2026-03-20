-- =============================================
-- SÉCURITÉ : Réservé aux admins (IdDoyenne IS NULL)
-- =============================================
SELECT 'redirect' AS component, '../index' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
      AND IdDoyenne IS NULL
);
 
SELECT 'dynamic' AS component, sqlpage.run_sql('common_header.sql') AS properties;
 
-- =============================================
-- TRAITEMENT : Ajout d'une promotion
-- =============================================
INSERT INTO PROMOTION (NomPromotion)
SELECT :nom
WHERE NULLIF(:nom, '') IS NOT NULL
  AND :action = 'ajouter';
 
-- =============================================
-- TRAITEMENT : Modification d'une promotion
-- =============================================
UPDATE PROMOTION
SET NomPromotion = :nom
WHERE IdPromotion = CAST(:IdPromotion AS INTEGER)
  AND NULLIF(:nom, '') IS NOT NULL
  AND :action = 'modifier';
 
-- =============================================
-- TRAITEMENT : Suppression d'une promotion
-- (supprime d'abord les personnes rattachées)
-- =============================================
DELETE FROM Remplir
WHERE IdPersonne IN (
    SELECT IdPersonne FROM PERSONNE
    WHERE IdPromotion = CAST(:IdPromotion AS INTEGER)
)
  AND :action = 'supprimer';

DELETE FROM PERSONNE
WHERE IdPromotion = CAST(:IdPromotion AS INTEGER)
  AND :action = 'supprimer';
 
DELETE FROM PROMOTION
WHERE IdPromotion = CAST(:IdPromotion AS INTEGER)
  AND :action = 'supprimer';
 
-- =============================================
-- MODALE : Modifier une promotion
-- =============================================
SELECT
    'modal'                  AS component,
    'form_modal_modifier'    AS id,
    'Modifier une promotion' AS title,
    TRUE                     AS large,
    'f_modif_promotion.sql'  AS embed;
 
-- =============================================
-- TITRE
-- =============================================
SELECT
    'text'                        AS component,
    '# Gestion des promotions'    AS contents_md;
 
-- =============================================
-- TABLEAU des promotions
-- =============================================
SELECT
    'table'    AS component,
    TRUE       AS sort,
    TRUE       AS search,
    'Modifier' AS markdown;
 
SELECT
    pro.NomPromotion                                                          AS Promotion,
    COUNT(per.IdPersonne)                                                     AS "Nb personnes",
    '[✏️ Modifier](f_modif_promotion.sql?IdPromotion='
        || pro.IdPromotion || ')' AS Modifier
FROM PROMOTION pro
LEFT JOIN PERSONNE per ON per.IdPromotion = pro.IdPromotion
GROUP BY pro.IdPromotion, pro.NomPromotion
ORDER BY pro.NomPromotion;
 
-- =============================================
-- BOUTON : Ajouter une promotion
-- =============================================
SELECT 'button' AS component;
SELECT
    'Ajouter une promotion' AS title,
    '#form_modal_ajouter'   AS link,
    'plus'                  AS icon;
 
-- =============================================
-- MODALE : Ajouter une promotion
-- =============================================
SELECT
    'modal'                  AS component,
    'form_modal_ajouter'     AS id,
    'Ajouter une promotion'  AS title,
    TRUE                     AS large,
    'f_ajout_promotion.sql'  AS embed;
 
