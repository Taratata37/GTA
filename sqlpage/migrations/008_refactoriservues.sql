DROP VIEW IF EXISTS Status_Personne;

CREATE VIEW Status_Personne AS
WITH ref AS(
	SELECT 'DOINC' as code
        , 'alert-triangle' as etat
        , 'orange' AS couleur
        ,'Dossier incomplet' as titre
        , 'Il manque un moyen de contact ou un sacrement demandé pour compléter le dossier de ce recommençant' as description
	UNION ALL
	SELECT 'FORMA' as code
        , 'file-report' as etat
        , 'blue' AS couleur
        , 'Formalités incomplètes' as titre
        , 'Il reste des formalités à remplir par ce recommençant' as description
	UNION ALL
	SELECT 'ABSEN' as code
        , 'user-search' as etat
        , 'dark-grey' AS couleur
        , 'Personne absente' as titre
        , 'Cette personne n''est pour l''instant venue à aucune rencontre diocésaine' as description
)

SELECT
    Personne.IdPersonne,
    ref.etat,
    ref.titre,
    ref.description,
    ref.couleur
FROM
    Personne
LEFT JOIN (
    SELECT IdPersonne, COUNT(*) AS nb_accompagnement
    FROM Demander
    GROUP BY IdPersonne
) AS DemanderInfo ON DemanderInfo.IdPersonne = Personne.IdPersonne
LEFT JOIN (
    SELECT IdPersonne, COUNT(*) AS nb_visites
    FROM Venir
    GROUP BY IdPersonne
) AS VenirInfo ON VenirInfo.IdPersonne = Personne.IdPersonne
LEFT JOIN (
	SELECT
	idPersonne,
	(
		SELECT COUNT(fo.NomFormalite)
		FROM Formalite fo 
		LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )
		WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection
	) NbFormalitesManquantes
	FROM personne
)FormalitiesInfo ON FormalitiesInfo.IdPersonne = Personne.IdPersonne 
LEFT JOIN
    ref ON
    CASE
        WHEN (DemanderInfo.nb_accompagnement = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1) THEN 'DOINC'
        WHEN VenirInfo.nb_visites > 0 THEN
            CASE
                WHEN COALESCE(FormalitiesInfo.NbFormalitesManquantes, 0) = 0 THEN ''
                ELSE 'FORMA'
            END
        ELSE 'ABSEN'
    END = ref.code;





ALTER TABLE PERSONNE ADD pinPersonne TEXT;
UPDATE PERSONNE set pinPersonne = substr(random(),5,6) || substr(random(),5,6);
