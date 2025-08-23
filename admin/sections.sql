INSERT INTO Section (NomSection)
SELECT :nom
WHERE :nom IS NOT NULL;
--RETURNING 'redirect' AS component, 'formalites.sql' AS link;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;


SELECT 
    'text' as component,
    '
# Liste des sections existantes
Les recommençant font partie d''une des sections suivantes.
	' as contents_md;
select 
    'card'                     as component;
select 
    NomSection  as title,
    '#' as link,
    --'Using the CSV component, you can download your data as a spreadsheet.' as description,
    'green'                    as color
	FROM Section;
	
	select 
    'form'            as component,
	'Ajouter une section' AS title,
    'sections.sql' as action;
SELECT 'nom' as name, TRUE as required;