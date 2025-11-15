SELECT 'redirect' AS component, '../login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

INSERT INTO Personne (
    NomPersonne, 
    PrenomPersonne, 
    SexePersonne, 
    NomJfPersonne,
    TelephonePersonne, 
    CourrielPersonne, 
    DateinscriptionPersonne, 
    IdSection, 
    IdPromotion, 
    RuePersonne, 
    CpPersonne, 
    VillePersonne, 
    IdDoyenne,
    pinPersonne
)
SELECT 
    CASE 
        WHEN :sexe = 'M' THEN REPLACE(UPPER(:nom), '6', '-')
        ELSE REPLACE(UPPER(:nomep), '6', '-')
    END,
    :prenom,
    :sexe,
    CASE 
        WHEN :sexe = 'F' THEN REPLACE(UPPER(:nom), '6', '-')
        ELSE NULL
    END,
    :tel,
    :courriel,
    date('now'),
    CAST(:IdSection AS INTEGER),
    CAST(:IdPromotion AS INTEGER),
    :rue,
    :cp,
    :ville,
    COAlESCE( ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') ), CAST(:IdDoyenne AS INTEGER)),
    substr(random(),5,6) || substr(random(),5,6)
WHERE :nom IS NOT NULL
    AND :sexe IN ('M', 'F')
    AND LENGTH(:nom) > 0
    AND (:sexe = 'F' OR LENGTH(:nomep) = 0 )
RETURNING 'redirect' AS component, '../detail.sql?id=' || IdPersonne AS link;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;



SELECT 
'alert' as component,
'Erreur de saisie' as title,
'Données incohérente : Nom d''épouse impossible' as description,
'alert-circle' as icon,
'red' as color
WHERE (LENGTH(:nomep) > 0 AND :sexe ='M') ;

SELECT 
'alert' as component,
'Erreur de saisie' as title,
'Nom obligatoire' as description,
'alert-circle' as icon,
'red' as color
WHERE (LENGTH(:nom) < 1);




select 
    'form'            as component,
	'Ajouter un participant' AS title,
    'inscription.sql' as action;
SELECT 'nom' as name,'Nom' as label, :nom as value, FALSE as required;
SELECT 'nomep' as name, 'Nom d''épouse' as label,:nomep as value, FALSE as required;
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
SELECT 'rue' as name,'Rue' as label,:rue as value, FALSE as required;
SELECT 'cp' as name,'Code postal' as label,:cp as value, FALSE as required;
SELECT 'ville' as name,'Ville' as label,:ville as value, FALSE as required;
select * FROM(
    SELECT 'IdDoyenne' as name,
	    'Doyenne' as label,
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
;


SELECT 'text' as component, 'Pour un import en masse, l''utilisateur averti peut utiliser le chargement de fichier [CSV](./charger_fichier.sql)' as contents_md;