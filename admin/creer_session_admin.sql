INSERT INTO session_connexion (jeton ,date_jeton)
VALUES (sqlpage.random_string(32) , current_timestamp)
RETURNING 
    'cookie' AS component,
    'jeton_session' AS name,
    jeton AS value;

SELECT 'redirect' AS component, '../index' AS link;
