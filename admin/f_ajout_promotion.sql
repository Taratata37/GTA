-- =============================================
-- FORMULAIRE : Ajouter une promotion
-- =============================================
SELECT
    'form'                   AS component,
    'gestion_promotions.sql' AS action,
    'Créer'                  AS validate;

SELECT
    'hidden' AS type,
    'action' AS name,
    'ajouter' AS value;

SELECT
    'text'               AS type,
    'nom'                AS name,
    'Nom de la promotion' AS label,
    TRUE                 AS required,
    'ex : Promo 2025'    AS placeholder;
