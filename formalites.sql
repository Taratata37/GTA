INSERT INTO Formalite (NomFormalite)
SELECT :nom
WHERE :nom IS NOT NULL
RETURNING 'redirect' AS component, 'formalites.sql' AS link;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;


SELECT 
    'text' as component,
    '
# Liste des formalités existantes
Les recommençant sont appelés à remplir l''ensemble des formalités suivantes.
	' as contents_md;
select 
    'card'                     as component;
select 
    NomFormalite  as title,
    '#' as link,
    --'Using the CSV component, you can download your data as a spreadsheet.' as description,
    'green'                    as color
	FROM Formalite;
	
	select 
    'form'            as component,
	'Ajouter une formalité' AS title,
    'formalites.sql' as action;
SELECT 'nom' as name, TRUE as required;