SELECT 'redirect' AS component, '../login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;
	
	

select 
    'form'            as component,
	'Afficher les présences' AS title,
	'Afficher' as validate,
    'presence.sql' as action;
SELECT 'jour' as name,
	'jour de présence' as label,
	'select' as type,
    TRUE     as searchable,
	FALSE    as multiple,
	TRUE as required,
    json_group_array(
		json_object(
			'label', 	ven.date,
			'value', 	ven.date,
			'selected', ven.date = :jour
		)
	) as options
	from (
		SELECT DISTINCT ven1.date
		FROM Venir ven1
		INNER JOIN personne
		on  personne.IdPersonne = ven1.IdPersonne
		WHERE cast(Personne.IdSection as text) = sqlpage.cookie('IdSection')
		AND cast(Personne.IdPromotion as text) = sqlpage.cookie('IdPromotion')
	) ven
   ;	

	

select 
    'table' as component,
	'Nom' as markdown,
	'Feuille de présence des ' || count(*) || ' personnes présentes le ' || COALESCE(:jour,date('now')) as description,
    TRUE    as sort,
    TRUE    as search
FROM Personne
NATURAL JOIN Venir
WHERE date = COALESCE(:jour,date('now'))
AND (
    EXISTS ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') and IdDoyenne IS NULL  ) -- admin
    OR ( Personne.IdDoyenne = ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') )) -- responsable local
);

select 
    NomPersonne  as Nom,
    NomJfPersonne as "Nom de jeune fille",
	PrenomPersonne as Prénom,
	(SELECT GROUP_CONCAT(COALESCE(Sacrement.NomSacrement,'-'))FROM Demander NATURAL JOIN Sacrement WHERE Personne.IdPersonne = Demander.IdPersonne) as "Sacrements demandés"
	, COALESCE(t.color,'red') as _sqlpage_color
FROM Personne
LEFT JOIN (
	SELECT IdPersonne as IdPersonne
	, 'green' as color
	FROM Venir 
	WHERE date = COALESCE(:jour,date('now'))
)t ON Personne.IdPersonne = t.IdPersonne
WHERE cast(Personne.IdSection as text) = sqlpage.cookie('IdSection')
AND cast(Personne.IdPromotion as text) = sqlpage.cookie('IdPromotion')
AND (
    EXISTS ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') and IdDoyenne IS NULL  ) -- admin
    OR ( personne.IdDoyenne = ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') )) -- responsable local
)
;

Select 
	'csv' as component,
	'Télécharger la feuille de présence' As title,
	'f_présence_'|| COALESCE(:jour,date('now'))  as filename,
	'file-download' as icon,
	'green' as color,
	';' as separator,
	TRUE as bom;
	
select 
    NomPersonne  as Nom,
    COALESCE(NomJfPersonne,'') as "Nom de jeune fille",
	PrenomPersonne as Prénom,
	CourrielPersonne as courriel,
	STRFTIME('%d/%m/%Y, %H:%M',date) as "présent le",
	(SELECT GROUP_CONCAT(COALESCE(Sacrement.NomSacrement,'-'))FROM Demander NATURAL JOIN Sacrement WHERE Personne.IdPersonne = Demander.IdPersonne) as "Sacrements demandés"
FROM Personne
NATURAL JOIN Venir
WHERE date = COALESCE(:jour,date('now'))
AND (
    EXISTS ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') and IdDoyenne IS NULL  ) -- admin
    OR ( personne.IdDoyenne = ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') )) -- responsable local
)
;
