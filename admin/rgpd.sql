SELECT 'redirect' AS component, 'login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);

SELECT 'redirect' AS component, '../index.sql' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
    AND IdDoyenne IS NULL
);

-- Purge des justificatifs UNIQUEMENT si confirmé
UPDATE Remplir
SET Justificatif = NULL
WHERE :confirmer IS NOT NULL
  AND IdPersonne IN (
    SELECT IdPersonne FROM Personne
    WHERE DateInscriptionPersonne <= date('now', '-3 years')
);

-- Anonymisation UNIQUEMENT si confirmé
UPDATE Personne
SET
    NomPersonne       = CASE WHEN NULLIF(NomPersonne, '') IS NOT NULL THEN 'ANONYME' ELSE NULL END,
    NomJfPersonne     = CASE WHEN NULLIF(NomJfPersonne, '') IS NOT NULL THEN 'ANONYMEJF' ELSE NULL END,
    TelephonePersonne = NULL,
    CourrielPersonne  = CASE 
                          WHEN CourrielPersonne LIKE '%@%' 
                          THEN 'XXXX' || SUBSTR(CourrielPersonne, INSTR(CourrielPersonne, '@'))
                          ELSE NULL 
                        END,
    RuePersonne       = NULL,
    VillePersonne     = NULL
WHERE :confirmer IS NOT NULL
  AND DateInscriptionPersonne <= date('now', '-3 years')
  AND NomPersonne != 'ANONYME';

SELECT 'redirect' AS component, '../index.sql' AS link
WHERE :confirmer IS NOT NULL;

select 'dynamic' as component, sqlpage.run_sql('common_header.sql') as properties;

-- Aperçu des personnes qui seront affectées
select
    'alert'         as component,
    'Attention'     as title,
    'Cette opération est irrémédiable. Les données personnelles et justificatifs des personnes inscrites avant le '
        || strftime('%d/%m/%Y', date('now', '-3 years'))
        || ' seront définitivement effacés.' as description,
    'alert-triangle' as icon,
    'orange'         as color;

select
    'table'          as component,
    'Personnes concernées (' || (SELECT COUNT(*) FROM Personne WHERE DateInscriptionPersonne <= date('now', '-3 years') AND NomPersonne != 'ANONYME') || ')' as title,
    TRUE             as hover,
    TRUE             as striped_rows,
    TRUE             as small,
    'Aucune personne concernée' as empty_description;

SELECT
    COALESCE(NULLIF(NomPersonne, ''), NULLIF(NomJfPersonne, '')) || ' ' || PrenomPersonne              as 'Nom',
    strftime('%d/%m/%Y', DateInscriptionPersonne)     as 'Inscrit le',
    CAST(ROUND((julianday('now') - julianday(DateInscriptionPersonne)) / 365.25) AS INTEGER) || ' ans' as 'Ancienneté'
FROM Personne
WHERE DateInscriptionPersonne <= date('now', '-3 years')
  AND NomPersonne != 'ANONYME'
ORDER BY DateInscriptionPersonne ASC;

-- Formulaire de confirmation : uniquement si des personnes sont éligibles
select
    'form'           as component,
    'Confirmer la purge RGPD' as title,
    'rgpd.sql'       as action,
    'red'            as validate_color,
    '⚠️ Confirmer la suppression définitive' as validate
WHERE (SELECT COUNT(*) FROM Personne 
       WHERE DateInscriptionPersonne <= date('now', '-3 years') 
       AND NomPersonne != 'ANONYME') > 0;

SELECT
    'confirmer'      as name,
    'hidden'         as type,
    '1'              as value
WHERE (SELECT COUNT(*) FROM Personne 
       WHERE DateInscriptionPersonne <= date('now', '-3 years') 
       AND NomPersonne != 'ANONYME') > 0;

-- Message si rien à purger
SELECT
    'alert'          as component,
    'Aucune purge nécessaire' as title,
    'Aucune personne éligible à la purge RGPD pour le moment.' as description,
    'shield-check'   as icon,
    'green'          as color
WHERE (SELECT COUNT(*) FROM Personne 
       WHERE DateInscriptionPersonne <= date('now', '-3 years') 
       AND NomPersonne != 'ANONYME') = 0;
