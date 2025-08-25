SELECT 'redirect' AS component, 'login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);


UPDATE Personne 
set NomPersonne = REPLACE(UPPER(:nom),'6','-'),
PrenomPersonne = :prenom,
TelephonePersonne = :telephone,
CourrielPersonne = :courriel,
NomJfPersonne = UPPER(:nomjf)
,RuePersonne = :rue
,CpPersonne = :cp
,VillePersonne = :ville
,IdDoyenne = :IdDoyenne
WHERE IdPersonne = $IdPersonne 
AND :nom IS NOT NULL
AND (LENGTH(:nomjf) > 0 OR Personne.SexePersonne = 'M') 
AND (:nomjf IS NULL OR Personne.SexePersonne = 'F')
AND (LENGTH(:nom) > 0 OR Personne.SexePersonne = 'F') 
RETURNING 'redirect' AS component, 'detail.sql?id=' || $IdPersonne AS link;

SELECT 
'alert' as component,
'Erreur de saisie' as title,
'Données incohérente : Nom de jeune fille impossible' as description,
'alert-circle' as icon,
'red' as color
FROM Personne
WHERE (LENGTH(:nomjf) > 0 AND Personne.SexePersonne ='M')
AND Personne.IdPersonne = $IdPersonne ;

SELECT 
'alert' as component,
'Erreur de saisie' as title,
'Données incohérente : Nom de jeune fille obligatoire' as description,
'alert-circle' as icon,
'red' as color
FROM Personne
WHERE (LENGTH(:nomjf) < 1 AND Personne.SexePersonne ='F')
AND Personne.IdPersonne = $IdPersonne ;

SELECT 
'alert' as component,
'Erreur de saisie' as title,
'Nom obligatoire' as description,
'alert-circle' as icon,
'red' as color
FROM Personne
WHERE (LENGTH(:nom) < 1 AND Personne.SexePersonne ='M')
AND Personne.IdPersonne = $IdPersonne ;


select 
    'form'            as component,
	'Mettre à jour un utilisateur' AS title,
    'maj_utilisateur.sql?IdPersonne=' || $IdPersonne  as action;
SELECT 'nom' as name, Personne.NomPersonne as value, FALSE as required FROM Personne WHERE IdPersonne = $IdPersonne;
SELECT 'nomjf' as name, 'Nom de jeune fille' as label,Personne.NomJfPersonne as value, FALSE as required FROM Personne WHERE IdPersonne = $IdPersonne AND Personne.SexePersonne = 'F';
SELECT 'prenom' as name,'Prénom' as label,Personne.PrenomPersonne as value, TRUE as required FROM Personne WHERE IdPersonne = $IdPersonne;
SELECT 'courriel' as name,'Courriel' as label,Personne.CourrielPersonne as value, FALSE as required FROM Personne WHERE IdPersonne = $IdPersonne;
SELECT 'telephone' as name,'Téléphone' as label,Personne.TelephonePersonne as value, FALSE as required FROM Personne WHERE IdPersonne = $IdPersonne;
SELECT 'rue' as name,'Rue' as label,Personne.RuePersonne as value, FALSE as required FROM Personne WHERE IdPersonne = $IdPersonne;
SELECT 'cp' as name,'Code postal' as label,Personne.CpPersonne as value, FALSE as required FROM Personne WHERE IdPersonne = $IdPersonne;
SELECT 'ville' as name,'Ville' as label,Personne.VillePersonne as value, FALSE as required FROM Personne WHERE IdPersonne = $IdPersonne;
SELECT 'IdDoyenne' as name,
	'Doyenne' as label,
	'select' as type,
    TRUE     as searchable,
	FALSE    as multiple,
	FALSE as required,
    json_group_array(
		json_object(
			'label', doy.NomDoyenne,
			'value', doy.IdDoyenne,
            'selected', per.IdDoyenne is not null
		)
	) as options
FROM Doyenne doy
LEFT JOIN personne per ON per.IdDoyenne = doy.idDoyenne
WHERE per.IdPersonne = $IdPersonne OR per.idPersonne is null ;

