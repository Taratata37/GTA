INSERT INTO Formalite (NomFormalite, IdSection)
SELECT :nom, CAST (:IdSection AS INTEGER)
WHERE :nom IS NOT NULL;


select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;


SELECT 
    'text' as component,
    '
# Liste des formalités existantes
Les recommençant sont appelés à remplir l''ensemble des formalités suivantes  dans la section 
	' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) as contents_md;
select 
    'card'                     as component;
select 
    NomFormalite  as title,
    '#' as link,
    --IdSection as description,
    'green'                    as color
	FROM Formalite
    WHERE Formalite.IdSection = sqlpage.cookie('IdSection');
	
select 
    'form'            as component,
	'Ajouter une formalité dans la section ' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) AS title,
    'formalites.sql' as action;

SELECT 'nom' as name, TRUE as required;
SELECT 'IdSection' as name,
'hidden' as type, 
sqlpage.cookie('IdSection') AS value;
/*SELECT 'IdSection' as name,
	'Section' as label,
	'select' as type,
    TRUE     as searchable,
	FALSE    as multiple,
	TRUE    as required,
    json_group_array(
		json_object(
			'label', sec.NomSection,
			'value', sec.IdSection,
            'selected', sec.IdSection = sqlpage.cookie('IdSection')
		)
	) as options
FROM section sec;*/