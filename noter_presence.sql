SELECT 'redirect' AS component, 'login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);


INSERT INTO Venir (idPersonne, date, codeType_evenement)
SELECT $id, DATE('now'), $codeevt
WHERE $id IS NOT NULL AND $codeevt = 'RECOL' AND :dateevt is null
RETURNING 'redirect' AS component, 'detail.sql?id=' || $id AS link;

INSERT INTO Venir (idPersonne, date, codeType_evenement)
SELECT $id, :dateevt, COALESCE(:codeevt,$codeevt)
WHERE $id IS NOT NULL AND COALESCE(:codeevt,$codeevt) IS NOT NULL AND :dateevt IS NOT NULL
RETURNING 'redirect' AS component, 'detail.sql?id=' || $id AS link;