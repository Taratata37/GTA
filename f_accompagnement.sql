select 
    'form'            as component,
	'Accompagnement demandé' AS title,
    FALSE as auto_submit,
	'Enregistrer' as validate,
    'demander.sql?id=' || $id as action;
SELECT 'nom_s[]' as name,
	'' as label,
	'select' as type,
    FALSE     as disabled,
    TRUE     as searchable,
	TRUE             as multiple,
	'press ctrl to select multiple values' as description,
	FALSE as required,
    json_group_array(
		json_object(
			'label', Sacrement.NomSacrement,
			'value', Sacrement.IdSacrement,
			'selected', Demander.IdSacrement is not null
		)
	) as options
	from Sacrement
	left join Demander
    on  Sacrement.IdSacrement = Demander.IdSacrement
    and Demander.idPersonne = $id;