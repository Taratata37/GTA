SELECT 'redirect' AS component, 'login' AS link
WHERE NOT EXISTS (
    SELECT 1 FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

DELETE FROM Remplir 
WHERE IdPersonne = $IdPersonne AND IdFormalite = $IdFormalite;

SELECT 'redirect' AS component,
    'detail.sql?id=' || $IdPersonne AS link
WHERE $ok > 0;

INSERT INTO Remplir (IdFormalite, IdPersonne, CommentaireFormalite, Justificatif)
SELECT $IdFormalite, $IdPersonne, :commentaire, :justificatif_data
WHERE :commentaire IS NOT NULL;

SELECT 'redirect' AS component, 'detail.sql?id=' || $IdPersonne AS link
WHERE :commentaire IS NOT NULL;

SELECT 
    'form'     AS component,
    'Valider la formalité "' || NomFormalite || '"' AS title,
    'Valider'  AS validate,
    'remplir_formalite.sql?IdPersonne=' || $IdPersonne || '&IdFormalite=' || $IdFormalite AS action
FROM Formalite
WHERE IdFormalite = $IdFormalite;

SELECT 'commentaire'    AS name, 'Commentaire'          AS label, 'textarea' AS type, FALSE AS required;
SELECT 'justificatif'   AS name, 'Document justificatif' AS label, 'file'     AS type, FALSE AS required
FROM Formalite
WHERE IdFormalite = $IdFormalite AND Numérisable = 1;;

-- Le template injecte uniquement le JS d'interception, après la fermeture du form
SELECT 'file_compress'  AS component, 'justificatif' AS name, 400 AS max_ko;
