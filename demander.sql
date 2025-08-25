SELECT 'redirect' AS component, 'login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

DELETE FROM Demander WHERE IdPersonne = $id;


INSERT INTO Demander (IdSacrement, IdPersonne)

select CAST(value AS integer) as id_s, $id -- all values are transmitted by the browser as strings
from json_each(:nom_s); -- json_each returns a table with a "value" column for each element in the JSON array
SELECT 'redirect' AS component, 'detail.sql?id='||$id || '&majok=La modification des sacrements a été prise en compte.' AS link;