select 'form' as component, 'Définir mot de passe' as validate;
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
select 'password' as type, 'password' as name, 'Mot de passe' as label;

select 'text' as component, '

### Opération réussie

La valeur hashée suivante a été enregistrée pour le doyenné correspondant:

```
' || sqlpage.hash_password(:password) || '
```
' as contents_md
where :password is not null;


UPDATE doyenne set mot_de_passe = sqlpage.hash_password(:password)
WHERE :password is not null AND idDoyenne = :IdDoyenne;
