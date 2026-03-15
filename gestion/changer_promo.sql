SELECT 'redirect' AS component, 'login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

UPDATE Personne
SET IdPromotion = :IdPromotion, DateinscriptionPersonne = date('now')
WHERE $id IS NOT NULL AND $id = IdPersonne
RETURNING 'redirect' AS component, '../detail.sql?id=' || $id AS link;
