INSERT INTO Venir (idPersonne, date)
SELECT $id, DATE('now')
WHERE $id IS NOT NULL
RETURNING 'redirect' AS component, 'detail.sql?id=' || $id AS link;