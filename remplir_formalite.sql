SELECT 'redirect' AS component, 'login' AS link
WHERE NOT EXISTS (
    SELECT 1 FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

-- Si confirmation reçue, on supprime
DELETE FROM Remplir 
WHERE IdPersonne = $IdPersonne AND IdFormalite = $IdFormalite
AND :confirmer = 'oui';

SELECT 'redirect' AS component,
    'detail.sql?id=' || $IdPersonne AS link
WHERE $ok > 0 AND :confirmer = 'oui';

-- Si demande de suppression sans confirmation, afficher la page de confirmation
SELECT 'alert' AS component,
    'Confirmation de suppression' AS title,
    'Voulez-vous vraiment supprimer cette formalité ?' AS description,
    'warning' AS color
WHERE $ok > 0 AND :confirmer IS NULL;

SELECT 'form' AS component,
    'Confirmer la suppression' AS title,
    'Supprimer' AS validate,
    'remplir_formalite.sql?IdPersonne=' || $IdPersonne || '&IdFormalite=' || $IdFormalite || '&ok=' || $ok AS action
WHERE $ok > 0 AND :confirmer IS NULL;

SELECT 'confirmer' AS name, 'oui' AS value, 'hidden' AS type
WHERE $ok > 0 AND :confirmer IS NULL;

-- Suite normale : insertion si commentaire fourni
INSERT INTO Remplir (IdFormalite, IdPersonne, CommentaireFormalite, Justificatif)
SELECT $IdFormalite, $IdPersonne, :commentaire, :justificatif_data
WHERE :commentaire IS NOT NULL;

SELECT 'redirect' AS component, 'detail.sql?id=' || $IdPersonne AS link
WHERE :commentaire IS NOT NULL;

-- Formulaire principal
SELECT 
    'form'     AS component,
    'Valider la formalité "' || NomFormalite || '"' AS title,
    'Valider'  AS validate,
    'remplir_formalite.sql?IdPersonne=' || $IdPersonne || '&IdFormalite=' || $IdFormalite AS action
FROM Formalite
WHERE IdFormalite = $IdFormalite
AND $ok < 0;

SELECT 'commentaire'    AS name, 'Commentaire'          AS label, 'textarea' AS type, FALSE AS required WHERE $ok < 0; 
SELECT 'justificatif'   AS name, 'Document justificatif' AS label, 'file'     AS type, FALSE AS required
FROM Formalite
WHERE IdFormalite = $IdFormalite AND Numérisable = 1 AND $ok < 0;

SELECT 'file_compress'  AS component, 'justificatif' AS name, 400 AS max_ko;
