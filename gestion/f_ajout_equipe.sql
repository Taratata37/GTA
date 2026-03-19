-- =============================================
-- FORMULAIRE : Ajouter une équipe
-- =============================================
SELECT
    'form'               AS component,
    'Ajouter une équipe' AS title,
    'equipes.sql'        AS action;

SELECT
    'action' AS name,
    'hidden' AS type,
    'ajouter' AS value;

SELECT
    'libelle'          AS name,
    'Nom de l''équipe' AS label,
    TRUE               AS required;

-- Admin : select interactif avec tous les doyennés
SELECT * FROM (
    SELECT
        'IdDoyenne' AS name,
        'Doyenné'   AS label,
        'select'    AS type,
        TRUE        AS searchable,
        FALSE       AS multiple,
        TRUE        AS required,
        json_group_array(
            json_object(
                'label', doy.NomDoyenne,
                'value', doy.IdDoyenne
            )
        ) AS options
    FROM Doyenne doy
) t
WHERE EXISTS (
    SELECT 1 FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
    AND IdDoyenne IS NULL
);

-- Non-admin : champ grisé affichant son doyenné
SELECT
    'IdDoyenne'    AS name,
    'Doyenné'      AS label,
    TRUE           AS disabled,
    doy.NomDoyenne AS value
FROM Doyenne doy
INNER JOIN v_sessions_valides scn ON scn.IdDoyenne = doy.IdDoyenne
WHERE scn.jeton = sqlpage.cookie('jeton_session')
AND scn.IdDoyenne IS NOT NULL;  -- exclut l'admin

-- Champ caché pour soumettre la valeur malgré le disabled
SELECT
    'IdDoyenne_hidden' AS name,
    'hidden'           AS type,
    scn.IdDoyenne      AS value
FROM v_sessions_valides scn
WHERE scn.jeton = sqlpage.cookie('jeton_session')
AND scn.IdDoyenne IS NOT NULL;
