DELETE FROM Venir
WHERE IdPersonne = $IdPersonne;
DELETE FROM Remplir
WHERE IdPersonne = $IdPersonne ;
DELETE FROM Demander
WHERE IdPersonne = $IdPersonne ;
DELETE FROM Personne 
WHERE IdPersonne = $IdPersonne ;
SELECT 'redirect' AS component, 'index.sql' AS link;
