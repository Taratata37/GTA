INSERT INTO Sacrement (NomSacrement)
SELECT :nom
WHERE :nom IS NOT NULL
RETURNING 'redirect' AS component, 'sacrements.sql' AS link;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;


SELECT 
    'text' as component,
    '
# Liste des services
Les recommençant pourront bénéficier d''un ou plusieurs des éléments suivants.
	' as contents_md;
select 
    'card'                     as component;
select 
    NomSacrement  as title,
    '#' as link,
    --'Using the CSV component, you can download your data as a spreadsheet.' as description,
    'green'                    as color
	FROM Sacrement;
	
select 
    'form'            as component,
	'Ajouter un sacrement (ou autre)' AS title,
    'sacrements.sql' as action;
SELECT 'nom' as name, TRUE as required;