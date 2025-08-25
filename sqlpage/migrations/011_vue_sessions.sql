CREATE VIEW v_sessions_valides AS
    SELECT jeton, idDoyenne
    FROM session_connexion
    WHERE date_jeton >= datetime('now', '-12 hours')
;
