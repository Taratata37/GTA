DROP VIEW Status_Personne;
CREATE VIEW Status_Personne AS 
  SELECT
    iif(
      (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 
        OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,
      'alert-triangle', -- Dossier incomplet
      iif(
        (SELECT COUNT(fo.NomFormalite)
          FROM Formalite fo 
          LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne)
          WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0,
        '', -- Toutes les formalités sont accomplies → dossier complet
        iif(
          (SELECT COUNT(*) FROM Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
          'file-report', -- Venu mais formalités incomplètes
          'user-search'  -- Jamais venu et formalités incomplètes
        )
      )
    ) AS etat,

    iif(
      (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 
        OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,
      'Dossier incomplet',
      iif(
        (SELECT COUNT(fo.NomFormalite)
          FROM Formalite fo 
          LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne)
          WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0,
        '', -- Complet
        iif(
          (SELECT COUNT(*) FROM Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
          'Formalités incomplètes',
          'Personne absente'
        )
      )
    ) AS titre,

    iif(
      (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 
        OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,
      'Il manque un moyen de contact ou un sacrement demandé pour compléter le dossier de ce recommençant',
      iif(
        (SELECT COUNT(fo.NomFormalite)
          FROM Formalite fo 
          LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne)
          WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0,
        '', -- Complet
        iif(
          (SELECT COUNT(*) FROM Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
          'Il reste des formalités à remplir par ce recommençant',
          'Cette personne n''est pour l''instant venue à aucune rencontre diocésaine'
        )
      )
    ) AS description,

    iif(
      (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 
        OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,
      'orange',
      iif(
        (SELECT COUNT(fo.NomFormalite)
          FROM Formalite fo 
          LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne)
          WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0,
        '', -- Complet (couleur vide = vert par défaut ?)
        iif(
          (SELECT COUNT(*) FROM Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
          'blue',
          'dark-grey'
        )
      )
    ) AS couleur,

    Personne.IdPersonne
  FROM Personne;
