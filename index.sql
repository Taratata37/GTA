SELECT 'redirect' AS component, 'login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);



SELECT 'cookie' as component,
        'IdSection' as name,
        :IdSection as value
WHERE :IdSection IS NOT NULL;
SELECT 'cookie' as component,
        'IdPromotion' as name,
        :IdPromotion as value
WHERE :IdPromotion IS NOT NULL;
SELECT 'redirect' AS component, 'index.sql' AS link
WHERE :IdSection IS NOT NULL OR :IdPromotion IS NOT NULL;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;





select 
    'form'            as component,
	(SELECT 'Sélectionnez la section'WHERE sqlpage.cookie('IdSection') IS  NULL) AS title,
	'Changer la section active' as validate,
    'index.sql' as action;
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
            'selected', sec.IdSection = sqlpage.cookie('IdSection')
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
            'selected', pro.IdPromotion = sqlpage.cookie('IdPromotion')
		)
	) as options
FROM promotion pro;





SELECT 
    'text' as component,
    '
# Accueil - Vue synthétique - '||(SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) 
||' - '||(SELECT pro.NomPromotion FROM Promotion pro WHERE pro.IdPromotion = sqlpage.cookie('IdPromotion')) ||'
Cliquez sur un nom pour accéder à la fiche de la personne.
	' as contents_md
	WHERE sqlpage.cookie('IdSection') IS NOT NULL;;
	
	
SELECT 
    'chart'                  AS component,
    'états des inscriptions' AS title,
    'pie'                    AS type,
    FALSE                    AS labels
WHERE sqlpage.cookie('IdSection') IS NOT NULL;

SELECT 
    COALESCE(NULLIF(titre,''),'Prêt' )   AS label,
    count(*) AS value
FROM Status_Personne
NATURAL JOIN Personne
LEFT JOIN Equipe equ ON equ.IdEquipe = Personne.IdEquipe
WHERE IdSection    = sqlpage.cookie('IdSection')
AND   IdPromotion  = sqlpage.cookie('IdPromotion')
AND (
    equ.IdDoyenne = ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') )
    OR EXISTS ( SELECT 1 FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') AND IdDoyenne IS NULL ) -- admin
)
GROUP BY titre;

    
select 
    'table' as component,
	'Nom' as markdown,
	'Nom de jeune fille' as markdown,
	'Liste des '|| count (*) ||' personnes en section ' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection'))  as description,
    TRUE    as sort,
	'état' as icon,
    TRUE    as search 
    from Personne per
    LEFT JOIN Equipe equ ON equ.IdEquipe = per.IdEquipe
    WHERE cast(per.IdSection as text) = sqlpage.cookie('IdSection')
    AND cast(per.IdPromotion as text) = sqlpage.cookie('IdPromotion')
    AND (
        equ.IdDoyenne = ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') )
        OR EXISTS ( SELECT 1 FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') AND idDoyenne IS NULL ) -- admin
);
select 
    '[' || IiF(NULLIF(per.NomPersonne,'') IS NULL,"-",per.NomPersonne) ||'](detail.sql?id=' || per.IdPersonne || ')'  as Nom
    ,IiF(NULLIF(per.NomPersonne,'')IS NULL,'[' || per.NomJfPersonne ||'](detail.sql?id=' || per.IdPersonne || ')', per.NomJfPersonne)  as "Nom de jeune fille"
	,per.PrenomPersonne as Prénom
    ,doy.NomDoyenne as 'Doyenné'
	,sper.etat as 'état'
    ,NULLIF(sper.couleur, '') AS _sqlpage_color
FROM Personne per
LEFT JOIN Equipe  equ ON equ.IdEquipe  = per.IdEquipe
LEFT JOIN Doyenne doy ON doy.IdDoyenne = equ.IdDoyenne
NATURAL JOIN Status_Personne sper
WHERE CAST(per.IdSection   AS TEXT) = sqlpage.cookie('IdSection')
AND   CAST(per.IdPromotion AS TEXT) = sqlpage.cookie('IdPromotion')
AND (
    EXISTS ( SELECT 1 FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') AND IdDoyenne IS NULL ) -- admin
    OR equ.IdDoyenne = ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') )  -- responsable local
)
;


