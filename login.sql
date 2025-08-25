-- login.sql
SELECT 'redirect' AS component, 'index' AS link
FROM v_sessions_valides
WHERE jeton = sqlpage.cookie('jeton_session');



select 
    'button' as component;
select 
    '/admin/creer_session_admin.sql' as link,
'dark' as color,
    'Accès diocésain'            as title;


SELECT 
'alert' as component,
'Attention' as title,
$message as description,
'exclamation-circle' as icon,
'red' as color
WHERE $message is not null;


SELECT 'form' AS component,
       'Connexion' AS title,
       'creer_session.sql' AS action;

SELECT 'IdDoyenne' as name,
	'Doyenné' as label,
	'select' as type,
    TRUE     as searchable,
	FALSE    as multiple,
	FALSE as required,
    json_group_array(
		json_object(
			'label', doy.NomDoyenne
			,'value', doy.IdDoyenne
            --,'selected', per.IdDoyenne is not null
		)
	) as options
FROM Doyenne doy; 
SELECT 'mdp_saisi' AS name,
       'Mot de passe' AS label,
       'password' AS type,
       TRUE AS required;
