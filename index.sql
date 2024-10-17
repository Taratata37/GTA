select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;



SELECT 
    'text' as component,
    '
# Accueil - Vue synthétique
Cliquez sur un nom pour accéder à la fiche du recommençant.
	' as contents_md;
	
	
select 
    'chart'   as component,
    'états des inscriptions' as title,
    'pie'     as type,
    TRUE      as labels;
select 
    titre as label,
    count(*)  as value
    FROM Status_Personne
    GROUP BY titre;

    
select 
    'table' as component,
	'Nom' as markdown,
	'Nom de jeune fille' as markdown,
	'Liste des '|| count (*) ||' recommençants' as description,
    TRUE    as sort,
	'état' as icon,
    TRUE    as search from Personne;
select 
    '[' || IiF(length (per.NomPersonne) < 1,"-",per.NomPersonne) ||'](detail.sql?id=' || per.IdPersonne || ')'  as Nom
    ,IiF(length (per.NomPersonne) < 1,'[' || per.NomJfPersonne ||'](detail.sql?id=' || per.IdPersonne || ')', per.NomJfPersonne)  as "Nom de jeune fille"
	,per.PrenomPersonne as Prénom
    --,CourrielPersonne as Courriel
	, /*iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,"alert-triangle", -- Le dossier initial est incomplet
		iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
			iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) = 0 ,"","file-report"),
					"user-search")
	)as "état"*/
	sper.etat as 'état'
FROM Personne per
NATURAL JOIN Status_Personne sper;
