DROP VIEW IF EXISTS Status_Personne;
CREATE VIEW Status_Personne AS
WITH base AS (
  SELECT
    p.IdPersonne,
    (SELECT COUNT(*) FROM Demander d WHERE d.IdPersonne = p.IdPersonne) AS nb_sacrements,
    LENGTH(COALESCE(p.CourrielPersonne,'')) + LENGTH(COALESCE(p.TelephonePersonne,'')) AS lg_contact,
    (SELECT COUNT(*) FROM Formalite fo
      LEFT JOIN Remplir rem ON fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = p.IdPersonne
      WHERE rem.IdPersonne IS NULL AND fo.IdSection = p.IdSection) AS nb_formalites_manquantes,
    (SELECT COUNT(*) FROM Venir v WHERE v.IdPersonne = p.IdPersonne) AS nb_venues,
    (SELECT COUNT(*) FROM Remplir r WHERE r.IdPersonne = p.IdPersonne) AS nb_formalites_saisies
  FROM Personne p
),
etat AS (
  SELECT
    IdPersonne,
    CASE
      WHEN nb_sacrements > 0 AND nb_formalites_manquantes = 0        THEN 'complet'
      WHEN nb_sacrements = 0 OR lg_contact < 1                       THEN 'incomplet'
      WHEN nb_venues = 0 AND nb_formalites_saisies = 0               THEN 'absent_rien'
      WHEN nb_venues = 0 AND nb_formalites_saisies > 0               THEN 'absent_wip'
      WHEN nb_venues > 0 AND nb_formalites_saisies = 0               THEN 'venu_rien'
      ELSE                                                                 'venu_wip'
    END AS statut
  FROM base
)
SELECT
  CASE statut
    WHEN 'complet'    THEN ''
    WHEN 'incomplet'  THEN 'alert-triangle'
    WHEN 'absent_rien'THEN 'user-x'
    WHEN 'absent_wip' THEN 'user-search'
    WHEN 'venu_rien'  THEN 'file-alert'
    WHEN 'venu_wip'   THEN 'file-report'
  END AS etat,
  CASE statut
    WHEN 'complet'    THEN ''
    WHEN 'incomplet'  THEN 'Dossier incomplet'
    WHEN 'absent_rien'THEN 'Absent – aucune formalité'
    WHEN 'absent_wip' THEN 'Absent – formalités en cours'
    WHEN 'venu_rien'  THEN 'Venu – aucune formalité'
    WHEN 'venu_wip'   THEN 'Formalités incomplètes'
  END AS titre,
  CASE statut
    WHEN 'complet'    THEN ''
    WHEN 'incomplet'  THEN 'Il manque un moyen de contact ou un sacrement demandé pour compléter le dossier de ce recommençant'
    WHEN 'absent_rien'THEN 'Cette personne n''est jamais venue et aucune formalité n''a été enregistrée'
    WHEN 'absent_wip' THEN 'Cette personne n''est jamais venue mais a déjà au moins une formalité enregistrée'
    WHEN 'venu_rien'  THEN 'Cette personne est venue mais aucune formalité n''a encore été enregistrée'
    WHEN 'venu_wip'   THEN 'Il reste des formalités à remplir par ce recommençant'
  END AS description,
  CASE statut
    WHEN 'complet'    THEN ''
    WHEN 'incomplet'  THEN 'red'
    WHEN 'absent_rien'THEN 'secondary'
    WHEN 'absent_wip' THEN 'purple'
    WHEN 'venu_rien'  THEN 'orange'
    WHEN 'venu_wip'   THEN 'blue'
  END AS couleur,
  etat.IdPersonne
FROM etat;