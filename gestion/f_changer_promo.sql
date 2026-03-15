select 
    'form'            as component,
	'Changer la promotion' AS title,
    '/gestion/changer_promo.sql?id=' || $id as action;
SELECT 'IdPromotion' as name,
	'Promotion' as label,
	'select' as type,
    TRUE     as searchable,
	FALSE    as multiple,
	TRUE as required,
    json_group_array(
		json_object(
			'label', pro.NomPromotion,
			'value', pro.IdPromotion,
            'selected',pro.IdPromotion =sqlpage.cookie('IdPromotion')
		)
	) as options
FROM promotion pro;
