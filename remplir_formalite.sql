
SELECT 'redirect' AS component, 'login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);


DELETE FROM Remplir 
WHERE IdPersonne = $IdPersonne AND IdFormalite = $IdFormalite ;


SELECT 'redirect' AS component,
 'detail.sql?id='||$IdPersonne AS link
 WHERE $ok > 0;

INSERT INTO Remplir (IdFormalite, IdPersonne, CommentaireFormalite)
SELECT $IdFormalite, $IdPersonne, :commentaire
WHERE :commentaire IS NOT NULL ;


SELECT 'redirect' AS component, 'detail.sql?id='||$IdPersonne AS link
WHERE :commentaire IS NOT NULL;


select 
    'form'            as component,
	'Valider la formalité "' || NomFormalite || '"' AS title,
    'Valider' as validate,
    'remplir_formalite.sql?IdPersonne=' || $Idpersonne || '&IdFormalite=' || $IdFormalite as action
FROM Formalite
WHERE Idformalite = $IdFormalite;
SELECT 'commentaire' as name,'Commentaire' as label, FALSE as required;
