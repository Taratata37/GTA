SELECT 'redirect' AS component, '../index.sql' AS link
WHERE sqlpage.cookie('IdSection') IS NULL;

SELECT 'redirect' AS component, '../login.sql' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;

	
SELECT 
    'text' as component,
    '
# Vue synthétique des participants
Téléchargez la liste des participants dans la section 
	' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) as contents_md;
	

	
Select 
	'csv' as component,
	'Télécharger la liste' As title,
	'f_formalites_'|| COALESCE(:jour,date('now'))  as filename,
	'file-download' as icon,
	'green' as color,
	';' as separator,
	TRUE as bom;
	
select DISTINCT
	Personne.IdPersonne
	,doy.NomDoyenne
	,equ.libelleEquipe
    ,COALESCE(NULLIF(Personne.NomJfPersonne,''),Personne.NomPersonne) as Nom
	,Personne.PrenomPersonne as Prénom
	,COALESCE(NULLIF(Personne.NomPersonne,''),Personne.NomJfPersonne)  as "Nom d'usage"
	,Personne.CourrielPersonne as Courriel
	,Personne.TelephonePersonne as téléphone
	 -- Ajout des colonnes pour chaque sacrement
    ,EXISTS(SELECT 1 FROM Demander d WHERE d.IdPersonne = Personne.IdPersonne AND d.IdSacrement = (SELECT idSacrement FROM Sacrement WHERE NomSacrement = 'baptême')) AS demande_le_baptême
    ,EXISTS(SELECT 1 FROM Demander d WHERE d.IdPersonne = Personne.IdPersonne AND d.IdSacrement = (SELECT idSacrement FROM Sacrement WHERE NomSacrement = 'confirmation')) AS demande_la_confirmation
    ,EXISTS(SELECT 1 FROM Demander d WHERE d.IdPersonne = Personne.IdPersonne AND d.IdSacrement = (SELECT idSacrement FROM Sacrement WHERE NomSacrement = 'eucharistie')) AS demande_l_eucharistie
    ,EXISTS(SELECT 1 FROM Demander d WHERE d.IdPersonne = Personne.IdPersonne AND d.IdSacrement = (SELECT idSacrement FROM Sacrement WHERE NomSacrement LIKE 'Reprise%')) AS demande_reprise_vie
    ,EXISTS(SELECT 1 FROM Demander d WHERE d.IdPersonne = Personne.IdPersonne AND d.IdSacrement = (SELECT idSacrement FROM Sacrement WHERE NomSacrement LIKE 'Réintroduction%')) AS demande_geste_évêque

	,COALESCE(NULLIF(Remplir.CommentaireFormalite,''),remplir.Idformalite > 0,0) as parrain
    ,COALESCE(NULLIF(Remplir2.CommentaireFormalite,''),remplir2.Idformalite > 0,0) as "certificat de baptême"
	,COALESCE(NULLIF(Remplir3.CommentaireFormalite,''),remplir3.Idformalite > 0,0) as "acte de naissance"
	,COALESCE(NULLIF(Remplir4.CommentaireFormalite,''),remplir4.Idformalite > 0,0) as "lettre à l'évêque"
    ,sper.titre as 'état'    
    
FROM Personne Personne
NATURAL JOIN Status_Personne sper
LEFT JOIN Formalite ON Formalite.IdSection = sqlpage.cookie('IdSection') AND Formalite.NomFormalite LIKE '%parrain%'
LEFT JOIN Formalite forma2 ON forma2.IdSection = sqlpage.cookie('IdSection') AND  forma2.NomFormalite LIKE '%baptême%'
LEFT JOIN Remplir ON Personne.IdPersonne = Remplir.IdPersonne AND Remplir.IdFormalite = Formalite.IdFormalite
LEFT JOIN Remplir remplir2 ON Personne.IdPersonne = remplir2.IdPersonne AND remplir2.IdFormalite = forma2.IdFormalite 
LEFT JOIN Equipe equ ON equ.IdEquipe = Personne.IdEquipe

LEFT JOIN Doyenne doy ON doy.IdDoyenne = equ.IdDoyenne
LEFT JOIN Formalite forma3 ON forma3.IdSection = 1 AND  forma3.NomFormalite LIKE '%naissance%'
LEFT JOIN Remplir remplir3 ON Personne.IdPersonne = remplir3.IdPersonne AND remplir3.IdFormalite = forma3.IdFormalite 
LEFT JOIN Formalite forma4 ON forma4.IdSection = 1 AND  forma4.NomFormalite LIKE '%évêque%'
LEFT JOIN Remplir remplir4 ON Personne.IdPersonne = remplir4.IdPersonne AND remplir4.IdFormalite = forma4.IdFormalite 

WHERE Personne.IdSection = sqlpage.cookie('IdSection')
AND cast(Personne.IdPromotion as text) = sqlpage.cookie('IdPromotion')
AND (
    EXISTS ( SELECT 1 FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') AND IdDoyenne IS NULL ) -- admin
    OR equ.IdDoyenne = ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') )  -- responsable local
);


select 
    'table' as component,
	'Nom' as markdown,
    TRUE    as sort,
	'Liste des participants dans la section ' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) as description,
    TRUE    as search;
select DISTINCT
    '[' || IiF(length (Personne.NomPersonne) < 1,Personne.NomJfPersonne,Personne.NomPersonne) ||'](../detail.sql?id=' || Personne.IdPersonne || ')'  as Nom
	,Personne.PrenomPersonne as Prénom
	,Personne.CourrielPersonne as Courriel
	,Remplir.CommentaireFormalite as parrain
    ,equ.LibelleEquipe as équipe
	,remplir2.CommentaireFormalite as "certificat de baptème"
	 , (
        SELECT libelle
        FROM (
            SELECT ven.codeType_evenement
            ,CASE ven.codeType_evenement
                    WHEN 'ACCUE' THEN 'Accueilli'
                    WHEN 'ENTRE' THEN 'Catéchumène'
                    WHEN 'APDEC' THEN 'Catéchumène'
                    WHEN 'SCRMT' THEN 'Néophyte'
                    ELSE ''
            END libelle 
            ,CASE ven.codeType_evenement
                    WHEN 'ACCUE' THEN 1
                    WHEN 'ENTRE' THEN 2
                    WHEN 'APDEC' THEN 3
                    WHEN 'SCRMT' THEN 4
                    ELSE 0
            END ordre 
            FROM Venir ven
            WHERE ven.IdPersonne = Personne.IdPersonne
           ORDER BY ordre desc
        )
        LIMIT 1
    ) AS 'Étape de cheminement'
FROM Personne Personne
LEFT JOIN Formalite ON Formalite.IdSection = sqlpage.cookie('IdSection') AND Formalite.NomFormalite LIKE '%parrain%'
LEFT JOIN Formalite forma2 ON forma2.IdSection = sqlpage.cookie('IdSection') AND  forma2.NomFormalite LIKE '%baptême%'
LEFT JOIN Remplir ON Personne.IdPersonne = Remplir.IdPersonne AND Remplir.IdFormalite = Formalite.IdFormalite
LEFT JOIN Remplir remplir2 ON Personne.IdPersonne = remplir2.IdPersonne AND remplir2.IdFormalite = forma2.IdFormalite 
LEFT JOIN Equipe equ ON equ.IdEquipe = Personne.IdEquipe
WHERE Personne.IdSection = sqlpage.cookie('IdSection')
AND cast(Personne.IdPromotion as text) = sqlpage.cookie('IdPromotion')
AND (
    EXISTS ( SELECT 1 FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') AND IdDoyenne IS NULL ) -- admin
    OR equ.IdDoyenne = ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') )  -- responsable local
);

--AND forma2.IdSection = sqlpage.cookie('IdSection')
;
