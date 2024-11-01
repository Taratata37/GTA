INSERT INTO Personne (NomPersonne, PrenomPersonne, SexePersonne,TelephonePersonne, CourrielPersonne, DateinscriptionPersonne, IdSection)
SELECT REPLACE(UPPER(:nom),'6','-'),:prenom,:sexe,:tel,:courriel, date('now'), CAST (:IdSection AS INTEGER)
WHERE :nom IS NOT NULL 
    AND :sexe = 'M'
	AND LENGTH(:nomep) = 0
	AND LENGTH(:nom) > 0
RETURNING 'redirect' AS component, 'detail.sql?id=' || IdPersonne AS link;


INSERT INTO Personne (NomPersonne, PrenomPersonne, SexePersonne,NomJfPersonne,TelephonePersonne, CourrielPersonne, DateinscriptionPersonne, IdSection)
SELECT REPLACE(UPPER(:nomep),'6','-'),:prenom,:sexe,UPPER(:nom),:tel,:courriel, date('now'), CAST (:IdSection AS INTEGER)
WHERE :nom IS NOT NULL 
	AND :sexe = 'F'
	AND LENGTH(:nom) > 0
RETURNING 'redirect' AS component, 'detail.sql?id=' || IdPersonne AS link;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;



SELECT 
'alert' as component,
'Erreur de saisie' as title,
'Données incohérente : Nom d''épouse impossible' as description,
'alert-circle' as icon,
'red' as color
WHERE (LENGTH(:nomep) > 0 AND :sexe ='M') ;

SELECT 
'alert' as component,
'Erreur de saisie' as title,
'Nom obligatoire' as description,
'alert-circle' as icon,
'red' as color
WHERE (LENGTH(:nom) < 1);




select 
    'form'            as component,
	'Ajouter un recommençant' AS title,
    'inscription.sql' as action;
SELECT 'nom' as name,'Nom' as label, :nom as value, FALSE as required;
SELECT 'nomep' as name, 'Nom d''épouse' as label,:nomep as value, FALSE as required;
SELECT 'prenom' as name,'Prénom' as label,:prenom as value, TRUE as required;
select 
    'sexe'  as name,
    'select' as type,
    FALSE     as searchable,
	TRUE as required,
	:sexe as value,
    '[{"label": "Masculin", "value": "M"}, {"label": "Féminin", "value": "F"}]' as options;
SELECT 'courriel' as name,'Courriel' as label,:courriel as value, FALSE as required;
SELECT 'tel' as name,'Téléphone' as label,:tel as value, FALSE as required;
SELECT 'IdSection' as name,
	'Section' as label,
	'select' as type,
    TRUE     as searchable,
	FALSE    as multiple,
	TRUE as required,
    json_group_array(
		json_object(
			'label', sec.NomSection,
			'value', sec.IdSection
		)
	) as options
FROM section sec;
