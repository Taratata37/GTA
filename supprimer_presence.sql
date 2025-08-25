SELECT 'redirect' AS component, 'login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);


DELETE FROM Venir
WHERE IdPersonne = $IdPersonne
AND date  = $date
AND codeType_evenement = $codeevt ;
SELECT 'redirect' AS component, 'detail.sql?id=' || $IdPersonne AS link;