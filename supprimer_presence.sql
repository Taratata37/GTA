DELETE FROM Venir
WHERE IdPersonne = $IdPersonne
AND date  = $date
AND codeType_evenement = $codeevt ;
SELECT 'redirect' AS component, 'detail.sql?id=' || $IdPersonne AS link;