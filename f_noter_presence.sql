
select 
    'form'            as component,
	'Enregistrer participation à un évènement' AS title,
    'noter_presence.sql?id=' || $id as action;
SELECT 'prenom' as name,'Prénom' as label, FALSE as required,TRUE as disabled,
PrenomPersonne as value
FROM personne
WHERE IdPersonne = $id;
SELECT 'nom' as name,'Nom' as label, FALSE as required,TRUE as disabled,
NomPersonne as value
FROM personne
WHERE IdPersonne = $id;
select 
    'dateevt'    as name,
    'Date'       as label,
    'date'       as type,
    Date('now') as value;
SELECT 'codeevt' as name,
	'évènement' as label,
	'select' as type,
    TRUE     as searchable,
	FALSE    as multiple,
	TRUE as required,
    CASE WHEN $codeevt is not null THEN TRUE ELSE FALSE END as disabled,
    json_group_array(
		json_object(
			'label', tev.Nomtype_evenement,
			'value', tev.Codetype_evenement,
            'selected', t.codeevt is not null
		)
	) as options
FROM type_evenement tev
LEFT JOIN 
(SELECT $codeevt AS codeevt)t ON t.codeevt = tev.Codetype_evenement ;