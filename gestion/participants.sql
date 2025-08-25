SELECT 'redirect' AS component, '../index.sql' AS link
WHERE sqlpage.cookie('IdSection') IS NULL;

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
    Personne.NomPersonne as Nom
    ,Personne.NomJfPersonne  as "Nom de jeune fille"
	,Personne.PrenomPersonne as Prénom
	,Personne.CourrielPersonne as Courriel
	,Remplir.CommentaireFormalite as parrain
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
WHERE Personne.IdSection = sqlpage.cookie('IdSection')
AND cast(Personne.IdPromotion as text) = sqlpage.cookie('IdPromotion')
AND (
    EXISTS ( SELECT IdDoyenne FROM session_connexion WHERE jeton = sqlpage.cookie('jeton_session') and IdDoyenne IS NULL  ) -- admin
    OR ( Personne.IdDoyenne = ( SELECT IdDoyenne FROM session_connexion WHERE jeton = sqlpage.cookie('jeton_session') )) -- responsable local
);



select 
    'table' as component,
	'Nom' as markdown,
	'Nom de jeune fille' as markdown,
    TRUE    as sort,
	'Liste des participants dans la section ' || (SELECT sec.NomSection FROM Section sec WHERE sec.IdSection = sqlpage.cookie('IdSection')) as description,
    TRUE    as search;
select DISTINCT
    '[' || IiF(length (Personne.NomPersonne) < 1,"-",Personne.NomPersonne) ||'](detail.sql?id=' || Personne.IdPersonne || ')'  as Nom
    ,IiF(length (Personne.NomPersonne) < 1,'[' || Personne.NomJfPersonne ||'](detail.sql?id=' || Personne.IdPersonne || ')', Personne.NomJfPersonne)  as "Nom de jeune fille"
	,Personne.PrenomPersonne as Prénom
	,Personne.CourrielPersonne as Courriel
	,Remplir.CommentaireFormalite as parrain
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
WHERE Personne.IdSection = sqlpage.cookie('IdSection')
AND cast(Personne.IdPromotion as text) = sqlpage.cookie('IdPromotion')
AND (
    EXISTS ( SELECT IdDoyenne FROM session_connexion WHERE jeton = sqlpage.cookie('jeton_session') and IdDoyenne IS NULL  ) -- admin
    OR ( Personne.IdDoyenne = ( SELECT IdDoyenne FROM session_connexion WHERE jeton = sqlpage.cookie('jeton_session') )) -- responsable local
);
--AND forma2.IdSection = sqlpage.cookie('IdSection')
;
