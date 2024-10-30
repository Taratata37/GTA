SELECT 'cookie' as component,
        'IdSection' as name,
        :IdSection as value
WHERE :IdSection IS NOT NULL;
SELECT 'redirect' AS component, 'index.sql' AS link
WHERE :IdSection IS NOT NULL;;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;





select 
    'form'            as component,
	(SELECT 'Sélectionnez la section'WHERE sqlpage.cookie('IdSection') IS  NULL) AS title,
	'Changer la section active' as validate,
    'index.sql' as action;
SELECT 'IdSection' as name,
	'Section' as label,
	'select' as type,
    TRUE     as searchable,
	FALSE    as multiple,
	TRUE as required,
    json_group_array(
		json_object(
			'label', sec.NomSection,
			'value', sec.IdSection,
            'selected', sec.IdSection = sqlpage.cookie('IdSection')
		)
	) as options
FROM section sec;





SELECT 
    'text' as component,
    '
# Accueil - Vue synthétique - '||(SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) ||'
Cliquez sur un nom pour accéder à la fiche du recommençant.
	' as contents_md
	WHERE sqlpage.cookie('IdSection') IS NOT NULL;;
	
	
select 
    'chart'   as component,
    'états des inscriptions' as title,
    'pie'     as type,
    FALSE      as labels
    WHERE sqlpage.cookie('IdSection') IS NOT NULL;
select 
    REPLACE(titre,'Information','Personne absente') as label,
    count(*)  as value
    FROM Status_Personne
    NATURAL JOIN PERSONNE
    WHERE IdSection = sqlpage.cookie('IdSection')
    GROUP BY titre;

    
select 
    'table' as component,
	'Nom' as markdown,
	'Nom de jeune fille' as markdown,
	'Liste des '|| count (*) ||' recommençants en section ' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection'))  as description,
    TRUE    as sort,
	'état' as icon,
    TRUE    as search 
    from Personne per
    WHERE cast(per.IdSection as text) = sqlpage.cookie('IdSection');
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
NATURAL JOIN Status_Personne sper
WHERE cast(per.IdSection as text) = sqlpage.cookie('IdSection');
