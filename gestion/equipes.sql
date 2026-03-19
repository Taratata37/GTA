SELECT 'redirect' AS component, '../login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

SELECT 'dynamic' AS component, sqlpage.run_sql('common_header.sql') AS properties;

-- =============================================
-- TRAITEMENT : Ajout d'une équipe
-- =============================================
INSERT INTO Equipe (LibelleEquipe, IdDoyenne)
SELECT
    :libelle,
    COALESCE(
        ( SELECT IdDoyenne FROM v_sessions_valides
          WHERE jeton = sqlpage.cookie('jeton_session')
          AND IdDoyenne IS NOT NULL ),
        CAST(:IdDoyenne AS INTEGER)
    )
WHERE NULLIF(:libelle, '') IS NOT NULL
    AND (
        NULLIF(:IdDoyenne, '') IS NOT NULL
        OR EXISTS (
            SELECT 1 FROM v_sessions_valides
            WHERE jeton = sqlpage.cookie('jeton_session')
            AND IdDoyenne IS NOT NULL
        )
    );



-- =============================================
-- MODALE : Modifier une équipe
-- =============================================
SELECT
    'modal'               AS component,
    'form_modal_modifier' AS id,
    'Modifier une équipe' AS title,
    TRUE                  AS large,
    'f_modif_equipe.sql'  AS embed;

-- =============================================
-- TITRE
-- =============================================
SELECT
    'text' AS component,
    '# Gestion des équipes' AS contents_md;

-- =============================================
-- TABLEAU des équipes
-- =============================================
SELECT
    'table'    AS component,
    TRUE       AS sort,
    TRUE       AS search,
    'Modifier' AS markdown;

SELECT
    doy.NomDoyenne    AS Doyenné,
    equ.LibelleEquipe AS Équipe,
    '[✏️ Modifier](f_modif_equipe.sql?IdEquipe=' || equ.IdEquipe || ')' AS Modifier
FROM Equipe equ
JOIN Doyenne doy ON doy.IdDoyenne = equ.IdDoyenne
JOIN v_sessions_valides scn ON (
    scn.IdDoyenne IS NULL
    OR scn.IdDoyenne = equ.IdDoyenne
)
WHERE scn.jeton = sqlpage.cookie('jeton_session')
ORDER BY doy.NomDoyenne, equ.LibelleEquipe;

-- =============================================
-- BOUTON : Ajouter une équipe
-- =============================================
SELECT 'button' AS component;
SELECT
    'Ajouter une équipe'  AS title,
    '#form_modal_ajouter' AS link,
    'plus'                AS icon;



-- =============================================
-- MODALE : Ajouter une équipe
-- =============================================
SELECT
    'modal'               AS component,
    'form_modal_ajouter'  AS id,
    'Ajouter une équipe'  AS title,
    TRUE                  AS large,
    'f_ajout_equipe.sql'  AS embed;
