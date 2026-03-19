SELECT 'redirect' AS component, '../login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

-- =============================================
-- TRAITEMENT : Modifier une équipe
-- =============================================
UPDATE Equipe
SET
    LibelleEquipe = :libelle,
    IdDoyenne     = COAlESCE( ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') ), CAST(:IdDoyenne AS INTEGER))
WHERE IdEquipe = CAST($IdEquipe AS INTEGER)
    AND  :libelle is not null
RETURNING 'redirect' AS component, './equipes.sql' AS link;


-- =============================================
-- FORMULAIRE : Modifier une équipe (pré-rempli)
-- =============================================
SELECT 'dynamic' AS component, sqlpage.run_sql('common_header.sql') AS properties;

SELECT
    'text' AS component,
    '# Modifier une équipe' AS contents_md;

SELECT
    'form'                AS component,
    'Modifier une équipe' AS title,
    'f_modif_equipe.sql?IdEquipe=' || $IdEquipe  AS action;


SELECT
    'libelle'          AS name,
    'Nom de l''équipe' AS label,
    equ.LibelleEquipe  AS value,
    TRUE               AS required
FROM Equipe equ
WHERE equ.IdEquipe = CAST($IdEquipe AS INTEGER);

-- Doyenné : select pour l'admin
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
                'label',    doy.NomDoyenne,
                'value',    doy.IdDoyenne,
                'selected', doy.IdDoyenne = equ.IdDoyenne
            )
        ) AS options
    FROM Doyenne doy
    JOIN Equipe equ ON equ.IdEquipe = CAST($IdEquipe AS INTEGER)
) t
WHERE EXISTS (
    SELECT 1 FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
    AND IdDoyenne IS NULL
);

-- Doyenné : champ grisé pour le non-admin
SELECT * FROM (
    SELECT
        'IdDoyenne'    AS name,
        'Doyenné'      AS label,
        TRUE           AS disabled,
        doy.NomDoyenne AS value
    FROM Doyenne doy
    INNER JOIN v_sessions_valides scn ON scn.IdDoyenne = doy.IdDoyenne
    WHERE scn.jeton = sqlpage.cookie('jeton_session')
) t
WHERE EXISTS (
    SELECT 1 FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
    AND IdDoyenne IS NOT NULL
);
