DROP VIEW IF EXISTS Status_Personne;
CREATE VIEW Status_Personne AS
  SELECT
    iif(
      -- Toutes les formalités accomplies ET au moins un sacrement → complet, quoi qu'il arrive
      (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) > 0
      AND
      (SELECT COUNT(*) FROM Formalite fo
        LEFT JOIN Remplir rem ON fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne
        WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0,
      '', -- Dossier complet

      iif(
        (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0
          OR LENGTH(COALESCE(Personne.CourrielPersonne,'')) + LENGTH(COALESCE(Personne.TelephonePersonne,'')) < 1,
        'alert-triangle', -- Dossier incomplet (pas de contact ou pas de sacrement)

        iif(
          (SELECT COUNT(*) FROM Venir WHERE Venir.IdPersonne = Personne.IdPersonne) = 0,
          iif(
            (SELECT COUNT(*) FROM Remplir WHERE Remplir.IdPersonne = Personne.IdPersonne) = 0,
            'user-x',       -- Jamais venu + aucune formalité
            'user-search'   -- Jamais venu + au moins une formalité
          ),
          iif(
            (SELECT COUNT(*) FROM Remplir WHERE Remplir.IdPersonne = Personne.IdPersonne) = 0,
            'file-alert',   -- Venu + aucune formalité
            'file-report'   -- Venu + formalités incomplètes
          )
        )
      )
    ) AS etat,

    iif(
      (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) > 0
      AND
      (SELECT COUNT(*) FROM Formalite fo
        LEFT JOIN Remplir rem ON fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne
        WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0,
      '',

      iif(
        (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0
          OR LENGTH(COALESCE(Personne.CourrielPersonne,'')) + LENGTH(COALESCE(Personne.TelephonePersonne,'')) < 1,
        'Dossier incomplet',

        iif(
          (SELECT COUNT(*) FROM Venir WHERE Venir.IdPersonne = Personne.IdPersonne) = 0,
          iif(
            (SELECT COUNT(*) FROM Remplir WHERE Remplir.IdPersonne = Personne.IdPersonne) = 0,
            'Absent – aucune formalité',
            'Absent – formalités en cours'
          ),
          iif(
            (SELECT COUNT(*) FROM Remplir WHERE Remplir.IdPersonne = Personne.IdPersonne) = 0,
            'Venu – aucune formalité',
            'Formalités incomplètes'
          )
        )
      )
    ) AS titre,

    iif(
      (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) > 0
      AND
      (SELECT COUNT(*) FROM Formalite fo
        LEFT JOIN Remplir rem ON fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne
        WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0,
      '',

      iif(
        (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0
          OR LENGTH(COALESCE(Personne.CourrielPersonne,'')) + LENGTH(COALESCE(Personne.TelephonePersonne,'')) < 1,
        'Il manque un moyen de contact ou un sacrement demandé pour compléter le dossier de ce recommençant',

        iif(
          (SELECT COUNT(*) FROM Venir WHERE Venir.IdPersonne = Personne.IdPersonne) = 0,
          iif(
            (SELECT COUNT(*) FROM Remplir WHERE Remplir.IdPersonne = Personne.IdPersonne) = 0,
            'Cette personne n''est jamais venue et aucune formalité n''a été enregistrée',
            'Cette personne n''est jamais venue mais a déjà au moins une formalité enregistrée'
          ),
          iif(
            (SELECT COUNT(*) FROM Remplir WHERE Remplir.IdPersonne = Personne.IdPersonne) = 0,
            'Cette personne est venue mais aucune formalité n''a encore été enregistrée',
            'Il reste des formalités à remplir par ce recommençant'
          )
        )
      )
    ) AS description,

    iif(
      (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) > 0
      AND
      (SELECT COUNT(*) FROM Formalite fo
        LEFT JOIN Remplir rem ON fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne
        WHERE rem.IdPersonne IS NULL AND fo.IdSection = Personne.IdSection) = 0,
      '',

      iif(
        (SELECT COUNT(*) FROM Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0
          OR LENGTH(COALESCE(Personne.CourrielPersonne,'')) + LENGTH(COALESCE(Personne.TelephonePersonne,'')) < 1,
        'red',

        iif(
          (SELECT COUNT(*) FROM Venir WHERE Venir.IdPersonne = Personne.IdPersonne) = 0,
          iif(
            (SELECT COUNT(*) FROM Remplir WHERE Remplir.IdPersonne = Personne.IdPersonne) = 0,
            'secondary',
            'purple'
          ),
          iif(
            (SELECT COUNT(*) FROM Remplir WHERE Remplir.IdPersonne = Personne.IdPersonne) = 0,
            'orange',
            'blue'
          )
        )
      )
    ) AS couleur,

    Personne.IdPersonne
  FROM Personne;