INSERT INTO Personne (NomPersonne, PrenomPersonne, SexePersonne,NomJfPersonne,TelephonePersonne, CourrielPersonne, DateinscriptionPersonne)
SELECT REPLACE(UPPER(:nom),'6','-'),:prenom,:sexe,UPPER(:nomjf),:tel,:courriel, date('now')
WHERE :nom IS NOT NULL 
	AND (LENGTH(:nomjf) > 0 OR :sexe = 'M') 
	AND (LENGTH(:nomjf) = 0 OR :sexe = 'F')
	AND (LENGTH(:nom) > 0 OR :sexe = 'F') 
RETURNING 'redirect' AS component, 'index.sql' AS link;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;



SELECT 
'alert' as component,
'Erreur de saisie' as title,
'Données incohérente : Nom de jeune fille impossible' as description,
'alert-circle' as icon,
'red' as color
WHERE (LENGTH(:nomjf) > 0 AND :sexe ='M') ;

SELECT 
'alert' as component,
'Erreur de saisie' as title,
'Données incohérente : Nom de jeune fille obligatoire' as description,
'alert-circle' as icon,
'red' as color
WHERE (LENGTH(:nomjf) < 1 AND :sexe = 'F');

SELECT 
'alert' as component,
'Erreur de saisie' as title,
'Nom obligatoire' as description,
'alert-circle' as icon,
'red' as color
WHERE (LENGTH(:nom) < 1 AND :sexe = 'M');




select 
    'form'            as component,
	'Ajouter un recommençant' AS title,
    'inscription.sql' as action;
SELECT 'nom' as name,'Nom' as label, :nom as value, FALSE as required;
SELECT 'nomjf' as name, 'Nom de jeune fille' as label,:nomjf as value, FALSE as required;
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
