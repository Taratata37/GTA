SELECT 'redirect' AS component, '../login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

SELECT 
    'text' AS component,
    '
# Chargement de fichier 
Attention, le système ne prend qu''une équipe par fichier
La première ligne doit être "nom,nomepouse,sexe,prenom,tel,courriel,rue,cp,ville"
    ' AS contents_md;

SELECT 'form' AS component, 'action_import_csv.sql' AS action;

SELECT 'fichier_csv' AS name, 'file' AS type, 'text/csv' AS accept, 'Fichier CSV' AS label;

SELECT
    'IdSection' AS name,
    'Section'   AS label,
    'select'    AS type,
    TRUE        AS searchable,
    FALSE       AS multiple,
    TRUE        AS required,
    json_group_array(
        json_object(
            'label',    sec.NomSection,
            'value',    sec.IdSection,
            'selected', sec.IdSection = sqlpage.cookie('IdSection')
        )
    ) AS options
FROM section sec;

SELECT
    'IdPromotion' AS name,
    'Promotion'   AS label,
    'select'      AS type,
    TRUE          AS searchable,
    FALSE         AS multiple,
    TRUE          AS required,
    json_group_array(
        json_object(
            'label',    pro.NomPromotion,
            'value',    pro.IdPromotion,
            'selected', pro.IdPromotion = sqlpage.cookie('IdPromotion')
        )
    ) AS options
FROM promotion pro;

-- Champ Équipe : select filtré sur le doyenné de la session si défini, toutes équipes sinon (admin)
SELECT * FROM (
    SELECT
        'IdEquipe'  AS name,
        'Équipe'    AS label,
        'select'    AS type,
        TRUE        AS searchable,
        FALSE       AS multiple,
        TRUE        AS required,
        json_group_array(
            json_object(
                'label', CASE
                    WHEN scn.IdDoyenne IS NULL
                    THEN equ.LibelleEquipe || ' (' || doy.NomDoyenne || ')'
                    ELSE equ.LibelleEquipe
                END,
                'value', equ.IdEquipe
            )
        ) AS options
    FROM Equipe equ
    JOIN Doyenne doy ON doy.IdDoyenne = equ.IdDoyenne
    INNER JOIN v_sessions_valides scn ON (
        scn.IdDoyenne IS NULL
        OR scn.IdDoyenne = equ.IdDoyenne
    )
    WHERE scn.jeton = sqlpage.cookie('jeton_session')
) t;
