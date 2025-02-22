SELECT 'redirect' AS component, 'index.sql' AS link
WHERE sqlpage.cookie('IdSection') IS NULL;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;

	
SELECT 
    'text' as component,
    '
# Vue synthétique des participants
Téléchargez la liste des participants dans la section 
	' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) as contents_md;
	

	
Select 
	'csv' as component,
	'Télécharger la liste' As title,
	'f_formalites_'|| COALESCE(:jour,date('now'))  as filename,
	'file-download' as icon,
	'green' as color,
	';' as separator,
	TRUE as bom;
	
select DISTINCT
    Personne.NomPersonne as Nom
    ,Personne.NomJfPersonne  as "Nom de jeune fille"
	,Personne.PrenomPersonne as Prénom
	,Personne.CourrielPersonne as Courriel
	,Remplir.CommentaireFormalite as parrain
	,remplir2.CommentaireFormalite as "certificat de baptème"
FROM Personne Personne
CROSS JOIN Formalite 
CROSS JOIN Formalite forma2
LEFT JOIN Remplir ON Personne.IdPersonne = Remplir.IdPersonne AND Remplir.IdFormalite = Formalite.IdFormalite
LEFT JOIN Remplir remplir2 ON Personne.IdPersonne = remplir2.IdPersonne AND remplir2.IdFormalite = forma2.IdFormalite
WHERE Personne.IdSection = sqlpage.cookie('IdSection')
AND Formalite.IdSection = sqlpage.cookie('IdSection')
AND Formalite.NomFormalite LIKE '%parrain%'
AND forma2.IdSection = sqlpage.cookie('IdSection')
AND forma2.NomFormalite LIKE '%baptême%'
--AND forma2.IdSection = sqlpage.cookie('IdSection')
;




select 
    'table' as component,
	'Nom' as markdown,
	'Nom de jeune fille' as markdown,
    TRUE    as sort,
	'Liste des participants dans la section ' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) as description,
    TRUE    as search;
select DISTINCT
    '[' || IiF(length (Personne.NomPersonne) < 1,"-",Personne.NomPersonne) ||'](detail.sql?id=' || Personne.IdPersonne || ')'  as Nom
    ,IiF(length (Personne.NomPersonne) < 1,'[' || Personne.NomJfPersonne ||'](detail.sql?id=' || Personne.IdPersonne || ')', Personne.NomJfPersonne)  as "Nom de jeune fille"
	,Personne.PrenomPersonne as Prénom
	,Personne.CourrielPersonne as Courriel
	,Remplir.CommentaireFormalite as parrain
	,remplir2.CommentaireFormalite as "certificat de baptème"
FROM Personne Personne
CROSS JOIN Formalite 
CROSS JOIN Formalite forma2
LEFT JOIN Remplir ON Personne.IdPersonne = Remplir.IdPersonne AND Remplir.IdFormalite = Formalite.IdFormalite
LEFT JOIN Remplir remplir2 ON Personne.IdPersonne = remplir2.IdPersonne AND remplir2.IdFormalite = forma2.IdFormalite
WHERE Personne.IdSection = sqlpage.cookie('IdSection')
AND Formalite.IdSection = sqlpage.cookie('IdSection')
AND Formalite.NomFormalite LIKE '%parrain%'
AND forma2.IdSection = sqlpage.cookie('IdSection')
AND forma2.NomFormalite LIKE '%baptême%'
--AND forma2.IdSection = sqlpage.cookie('IdSection')
;
