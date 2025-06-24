INSERT INTO Venir (idPersonne, date, codeType_evenement)
SELECT $id, DATE('now'), $codeevt
WHERE $id IS NOT NULL AND $codeevt = 'RECOL' AND :dateevt is null
RETURNING 'redirect' AS component, 'detail.sql?id=' || $id AS link;

INSERT INTO Venir (idPersonne, date, codeType_evenement)
SELECT $id, :dateevt, COALESCE(:codeevt,$codeevt)
WHERE $id IS NOT NULL AND COALESCE(:codeevt,$codeevt) IS NOT NULL AND :dateevt IS NOT NULL
RETURNING 'redirect' AS component, 'detail.sql?id=' || $id AS link;

select 
    'form'            as component,
	'Enregistrer participation à un évènement' AS title,
    'noter_presence.sql?id=' || $id || '&codeevt=' || $codeevt as action;
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