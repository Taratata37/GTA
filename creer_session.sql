SELECT 'authentication' AS component,
    'login.sql?message=identifiants invalides' AS link,
    (SELECT mot_de_passe FROM doyenne WHERE IdDoyenne = :IdDoyenne) AS password_hash,
    :mdp_saisi AS password;

-- The code after this point is only executed if the user has sent the correct password

-- Generate a random session token
INSERT INTO session_connexion (jeton, idDoyenne,date_jeton)
VALUES (sqlpage.random_string(32), :IdDoyenne, current_timestamp)
RETURNING 
    'cookie' AS component,
    'jeton_session' AS name,
    jeton AS value;

SELECT 'redirect' AS component, 'index' AS link;
