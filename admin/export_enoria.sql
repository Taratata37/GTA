SELECT 'csv' AS component,
       'export_enoria.csv' AS filename;

SELECT
    -- Champs obligatoires reconstruits
    'A'                                         AS adulteProfilAffichage,
    CASE
        WHEN p.SexePersonne = 'F'
         AND (p.NomPersonne IS NULL OR TRIM(p.NomPersonne) = '')
         AND (p.NomJfPersonne IS NOT NULL AND TRIM(p.NomJfPersonne) != '')
        THEN 'Mademoiselle'
        WHEN p.SexePersonne = 'F' THEN 'Madame'
        ELSE 'Monsieur'
    END                                                             AS adulteTitre,
    p.SexePersonne                              AS adulteSexe,

    -- Identité
    UPPER(p.NomPersonne)                        AS adulteNom,
    p.NomJfPersonne                             AS adulteNomJeuneFille,
    p.PrenomPersonne                            AS adultePrenom,

    -- Contact
    p.CourrielPersonne                          AS adulteMailPerso,
    p.TelephonePersonne                         AS adulteTelMobilePerso,

    -- Adresse postale (champ unique RuePersonne → PostaleRue)
    p.RuePersonne                               AS PostaleRue,
    p.CpPersonne                                AS PostaleCP,
    p.VillePersonne                             AS PostaleVille,

    -- Sacrements (présence)
    CASE WHEN EXISTS (
        SELECT 1 FROM Demander d
        INNER JOIN Sacrement s ON d.IdSacrement = s.IdSacrement
        WHERE d.IdPersonne = p.IdPersonne
          AND LOWER(s.NomSacrement) LIKE '%baptême%'
    ) AND EXISTS (
        SELECT 1 FROM Venir v
        WHERE v.IdPersonne = p.IdPersonne
          AND v.codeType_evenement = 'SCRMT'
    )THEN 'T' ELSE 'I' END                     AS adulteIsBapteme,

    CASE WHEN EXISTS (
        SELECT 1 FROM Demander d
        INNER JOIN Sacrement s ON d.IdSacrement = s.IdSacrement
        WHERE d.IdPersonne = p.IdPersonne
          AND LOWER(s.NomSacrement) LIKE '%communion%'
    ) AND EXISTS (
        SELECT 1 FROM Venir v
        WHERE v.IdPersonne = p.IdPersonne
          AND v.codeType_evenement = 'SCRMT'
    )THEN 'T' ELSE 'I' END                     AS adulteIs1ereCommunion,

    CASE WHEN EXISTS (
        SELECT 1 FROM Demander d
        INNER JOIN Sacrement s ON d.IdSacrement = s.IdSacrement
        WHERE d.IdPersonne = p.IdPersonne
          AND LOWER(s.NomSacrement) LIKE '%confirmation%'
    ) AND EXISTS (
        SELECT 1 FROM Venir v
        WHERE v.IdPersonne = p.IdPersonne
          AND v.codeType_evenement = 'SCRMT'
    ) THEN 'T' ELSE 'I' END                     AS adulteIsConfirmation,

    -- Date de confirmation : date de la rencontre 'SCRMT' si la personne
    -- a demandé le sacrement de confirmation
    CASE WHEN EXISTS (
        SELECT 1 FROM Demander d
        INNER JOIN Sacrement s ON d.IdSacrement = s.IdSacrement
        WHERE d.IdPersonne = p.IdPersonne
          AND LOWER(s.NomSacrement) LIKE '%confirmation%'
    ) THEN (
        SELECT strftime('%d/%m/%Y', v.Date)
        FROM Venir v
        WHERE v.IdPersonne = p.IdPersonne
          AND v.codeType_evenement = 'SCRMT'
        ORDER BY v.Date DESC
        LIMIT 1
    ) ELSE NULL END                             AS adulteDateConfirmation

FROM Personne p
WHERE p.IdSection   = sqlpage.cookie('IdSection')
  AND p.IdPromotion = sqlpage.cookie('IdPromotion');
