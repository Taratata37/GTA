INSERT INTO Formalite (NomFormalite, IdSection, Numérisable)
SELECT :nom, CAST(:IdSection AS INTEGER), CASE WHEN :numerisable IS NOT NULL THEN 1 ELSE 0 END
WHERE :nom IS NOT NULL;

SELECT 'redirect' AS component, '../index.sql' AS link
WHERE sqlpage.cookie('IdSection') IS NULL;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;
SELECT 
    'text' as component,
    '
# Liste des formalités existantes
Les recommençants sont appelés à remplir l''ensemble des formalités suivantes dans la section 
    ' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) as contents_md;

select 
    'card' as component;
select 
    NomFormalite as title,
    '#' as link,
    CASE WHEN Numérisable = 1 THEN 'Numérisable' ELSE NULL END as description,
    'green' as color,
    CASE WHEN Numérisable = 1 THEN 'scan' ELSE NULL END as icon
FROM Formalite
WHERE Formalite.IdSection = sqlpage.cookie('IdSection');

select 
    'form'           as component,
    'Ajouter une formalité dans la section ' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) AS title,
    'formalites.sql' as action;
SELECT 'nom'         as name, TRUE as required;
SELECT 'numerisable' as name, 
       'Numérisable (justificatif image accepté)' as label, 
       'switch' as type, 
 TRUE                       as checked,
       FALSE as required;
SELECT 'IdSection'   as name, 'hidden' as type, sqlpage.cookie('IdSection') AS value;
