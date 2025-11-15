SELECT 'redirect' AS component, '../login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);
SELECT 
    'text' as component,
    '
# Chargement de fichier 
Attention, le système ne prend qu''un doyenné par fichier
	' as contents_md;



select 'form' as component,'action_import_csv.sql' as action;
select 'fichier_csv' as name, 'file' as type,  'text/csv' as accept;
SELECT 'IdSection' as name,
	'Section' as label,
	'select' as type,
    TRUE     as searchable,
	FALSE    as multiple,
	TRUE as required,
    json_group_array(
		json_object(
			'label', sec.NomSection,
			'value', sec.IdSection,
            'selected',sec.IdSection =sqlpage.cookie('IdSection')
		)
	) as options
FROM section sec;
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
select * FROM(
    SELECT 'IdDoyenne' as name,
	    'Doyenné' as label,
	    'select' as type,
        TRUE     as searchable,
	    FALSE    as multiple,
	    FALSE as required,
        json_group_array(
		    json_object(
			    'label', doy.NomDoyenne,
			    'value', doy.IdDoyenne
		    )
	    ) as options
    FROM Doyenne doy
) t
WHERE EXISTS ( SELECT '1' FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session')  and IdDoyenne IS NULL );
select 
    'nom_doyenne' as name,
    'Doyenné' as label,
    TRUE        as disabled,
    doy.nomdoyenne as value
FROM Doyenne doy
INNER JOIN v_sessions_valides scn ON scn.idDoyenne = doy.IdDoyenne
WHERE scn.jeton = sqlpage.cookie('jeton_session') 