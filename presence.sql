select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;
	
select 
    'form'            as component,
    'Afficher les présences' as validate,
	'presence.sql' as action;
	
select 
    'jour de présence' as label,
	'jour' as name,
    'date'       as type,
    '2020-01-01' as min,
	date('now') as max,
    COALESCE(:jour, date('now')) as value,
	TRUE       as required;
	
	
	
select 
    'table' as component,
	'Nom' as markdown,
	'Feuille de présence des ' || count(*) || ' personnes présentes le ' || COALESCE(:jour,date('now')) as description,
    TRUE    as sort,
    TRUE    as search
FROM Personne
NATURAL JOIN Venir
WHERE date = COALESCE(:jour,date('now'));

select 
    NomPersonne  as Nom,
    NomJfPersonne as "Nom de jeune fille",
	PrenomPersonne as Prénom,
	(SELECT GROUP_CONCAT(COALESCE(Sacrement.NomSacrement,'-'))FROM Demander NATURAL JOIN Sacrement WHERE Personne.IdPersonne = Demander.IdPersonne) as "Sacrements demandés"
FROM Personne
NATURAL JOIN Venir
WHERE date = COALESCE(:jour,date('now'))
;

Select 
	'csv' as component,
	'Télécharger la feuille de présence' As title,
	'f_présence_'|| COALESCE(:jour,date('now'))  as filename,
	'file-download' as icon,
	'green' as color,
	';' as separator,
	TRUE as bom;
	
select 
    NomPersonne  as Nom,
    COALESCE(NomJfPersonne,'') as "Nom de jeune fille",
	PrenomPersonne as Prénom,
	STRFTIME('%d/%m/%Y, %H:%M',date) as "présent le",
	(SELECT GROUP_CONCAT(COALESCE(Sacrement.NomSacrement,'-'))FROM Demander NATURAL JOIN Sacrement WHERE Personne.IdPersonne = Demander.IdPersonne) as "Sacrements demandés"
FROM Personne
NATURAL JOIN Venir
WHERE date = COALESCE(:jour,date('now'))
;
