SELECT 'redirect' AS component, '../index.sql' AS link
WHERE sqlpage.cookie('IdSection') IS NULL;
SELECT 'redirect' AS component, '../login.sql' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);


select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;

	
SELECT 
    'text' as component,
    '
# Formalités non accomplies
Les formalités suivantes sont répertoriées comme non accomplies dans la section 
	' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) as contents_md;

SET idsection   = sqlpage.cookie('IdSection');
SET idpromotion = sqlpage.cookie('IdPromotion');
SET jeton       = sqlpage.cookie('jeton_session');

SELECT
    'table' AS component,
    'Nom' AS markdown,
    'Nom de jeune fille' AS markdown,
    TRUE AS sort,
    TRUE AS search,
    'Formalités non accomplies dans la section '
        || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = $idsection) AS description;

SELECT
    '[' || IIF(length(p.NomPersonne) < 1, '-', p.NomPersonne)
        || '](../detail.sql?id=' || p.IdPersonne || ')' AS Nom,
    IIF(length(p.NomPersonne) < 1,
        '[' || p.NomJfPersonne || '](../detail.sql?id=' || p.IdPersonne || ')',
        p.NomJfPersonne) AS "Nom de jeune fille",
    p.PrenomPersonne AS Prénom,
    p.CourrielPersonne AS Courriel,
    (SELECT GROUP_CONCAT(COALESCE(fo.NomFormalite, '-'))
       FROM Formalite fo
      WHERE fo.IdSection = $idsection
        AND NOT EXISTS (SELECT 1 FROM Remplir r
                         WHERE r.IdPersonne = p.IdPersonne
                           AND r.IdFormalite = fo.IdFormalite)
    ) AS "Formalités restantes"
FROM Personne p
LEFT JOIN Equipe equ ON equ.IdEquipe = p.IdEquipe
WHERE p.IdSection = $idsection
  AND p.IdPromotion = $idpromotion
  -- au moins une formalité de la section n'est pas remplie
  AND EXISTS (
        SELECT 1
          FROM Formalite fo
         WHERE fo.IdSection = $idsection
           AND NOT EXISTS (SELECT 1 FROM Remplir r
                            WHERE r.IdPersonne = p.IdPersonne
                              AND r.IdFormalite = fo.IdFormalite)
  )
  AND (
        EXISTS (SELECT 1 FROM v_sessions_valides
                 WHERE jeton = $jeton AND IdDoyenne IS NULL)   -- admin
        OR equ.IdDoyenne = (SELECT IdDoyenne FROM v_sessions_valides
                             WHERE jeton = $jeton)             -- responsable local
  );

Select 
	'csv' as component,
	'Télécharger la liste' As title,
	'f_formalites_'|| COALESCE(:jour,date('now'))  as filename,
	'file-download' as icon,
	'green' as color,
	';' as separator,
	TRUE as bom;
	
select
    Personne.NomPersonne  as Nom,
    COALESCE(Personne.NomJfPersonne,'') as "Nom de jeune fille",
	Personne.PrenomPersonne as Prénom,
	Personne.CourrielPersonne as Courriel,
	(SELECT GROUP_CONCAT(COALESCE(fo.NomFormalite,'-'))FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL AND fo.IdSection = sqlpage.cookie('IdSection')) as "Formalités restantes"
FROM Formalite
CROSS JOIN Personne
LEFT JOIN Equipe equ ON equ.IdEquipe = Personne.IdEquipe
LEFT JOIN Remplir ON Personne.IdPersonne = Remplir.IdPersonne AND Formalite.IdFormalite = Remplir.IdFormalite
WHERE Remplir.IdFormalite IS NULL AND Formalite.IdSection = sqlpage.cookie('IdSection') AND Personne.IdSection = sqlpage.cookie('IdSection') AND Personne.IdPromotion = sqlpage.cookie('IdPromotion')
AND (
    EXISTS ( SELECT 1 FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') AND IdDoyenne IS NULL ) -- admin
    OR equ.IdDoyenne = ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') )  -- responsable local
)
;
