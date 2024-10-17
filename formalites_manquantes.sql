select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;

	
SELECT 
    'text' as component,
    '
# Formalités non accomplies
Les formalités suivantes sont répertoriées comme non accomplies.
	' as contents_md;
	
select 
    'table' as component,
	'Nom' as markdown,
	'Nom de jeune fille' as markdown,
    TRUE    as sort,
	'Formalités non accomplies' as description,
    TRUE    as search;
select DISTINCT
    '[' || IiF(length (Personne.NomPersonne) < 1,"-",Personne.NomPersonne) ||'](detail.sql?id=' || Personne.IdPersonne || ')'  as Nom,
    IiF(length (Personne.NomPersonne) < 1,'[' || Personne.NomJfPersonne ||'](detail.sql?id=' || Personne.IdPersonne || ')', Personne.NomJfPersonne)  as "Nom de jeune fille",
	Personne.PrenomPersonne as Prénom,
	Personne.CourrielPersonne as Courriel,
	(SELECT GROUP_CONCAT(COALESCE(fo.NomFormalite,'-'))FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) as "Formalités restantes"
FROM Formalite
CROSS JOIN Personne
LEFT JOIN Remplir ON Personne.IdPersonne = Remplir.IdPersonne AND Formalite.IdFormalite = Remplir.IdFormalite
WHERE Remplir.IdFormalite IS NULL
;

Select 
	'csv' as component,
	'Télécharger la liste' As title,
	'f_formalites_'|| COALESCE(:jour,date('now'))  as filename,
	'file-download' as icon,
	'green' as color,
	';' as separator,
	TRUE as bom;
	
select DISTINCT
    Personne.NomPersonne  as Nom,
    COALESCE(Personne.NomJfPersonne,'') as "Nom de jeune fille",
	Personne.PrenomPersonne as Prénom,
	Personne.CourrielPersonne as Courriel,
	(SELECT GROUP_CONCAT(COALESCE(fo.NomFormalite,'-'))FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) as "Formalités restantes"
FROM Formalite
CROSS JOIN Personne
LEFT JOIN Remplir ON Personne.IdPersonne = Remplir.IdPersonne AND Formalite.IdFormalite = Remplir.IdFormalite
WHERE Remplir.IdFormalite IS NULL
;