
DROP VIEW Status_Personne;
CREATE VIEW Status_Personne AS 
  select
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,'alert-triangle', -- Le dossier initial est incomplet
				iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
					iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0 ,'','file-report'),
					'user-search')
		) as etat 
		,
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,'Dossier incomplet', -- Le dossier initial est incomplet
			iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
					iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0 ,'','Formalités incomplètes'),
					'Personne absente')
		) as titre
		,
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,'Il manque un moyen de contact ou un sacrement demandé pour compléter le dossier de ce recommençant', -- Le dossier initial est incomplet
			iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
				iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0 ,'','Il reste des formalités à remplir par ce recommençant'),
					'Cette personne n''est pour l''instant venue à aucune rencontre diocésaine')
		) as description
		,
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,'orange', -- Le dossier initial est incomplet
			iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
				iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0 ,'','blue'),
					'dark-grey')
		) as couleur
		,Personne.IdPersonne
		FROM Personne