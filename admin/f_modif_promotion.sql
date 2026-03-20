-- =============================================
-- FORMULAIRE : Modifier une promotion
-- Appelé avec ?IdPromotion=X en paramètre GET
-- =============================================

-- Champ caché : IdPromotion transmis via GET ou via le formulaire
SELECT
    'form'                   AS component,
    'gestion_promotions.sql' AS action,
    'Enregistrer'            AS validate;

SELECT
    'hidden'      AS type,
    'action'      AS name,
    'modifier'    AS value;

SELECT
    'hidden'      AS type,
    'IdPromotion' AS name,
    CAST($IdPromotion AS TEXT) AS value;

SELECT
    'text'                AS type,
    'nom'                 AS name,
    'Nom de la promotion' AS label,
    TRUE                  AS required,
    NomPromotion          AS value
FROM PROMOTION
WHERE IdPromotion = CAST($IdPromotion AS INTEGER);

-- =============================================
-- SÉPARATEUR + INFO personnes rattachées
-- =============================================
SELECT
    'text' AS component,
    '---' || CHAR(10) ||
    '⚠️ **Suppression** : cette action supprimera également toutes les personnes rattachées à cette promotion (**'
    || COUNT(per.IdPersonne)
    || ' personne(s)**).'
    AS contents_md
FROM PROMOTION pro
LEFT JOIN PERSONNE per ON per.IdPromotion = pro.IdPromotion
WHERE pro.IdPromotion = CAST($IdPromotion AS INTEGER)
GROUP BY pro.IdPromotion;

-- =============================================
-- BOUTON : Supprimer la promotion
-- =============================================
SELECT 'form' AS component, 'gestion_promotions.sql' AS action, '🗑️ Supprimer cette promotion' AS validate, 'red' AS validate_color;

SELECT 'hidden' AS type, 'action'      AS name, 'supprimer'                AS value;
SELECT 'hidden' AS type, 'IdPromotion' AS name, CAST($IdPromotion AS TEXT) AS value;
