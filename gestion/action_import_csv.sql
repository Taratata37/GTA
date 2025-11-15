SELECT 'redirect' AS component, '../login' AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM v_sessions_valides
    WHERE jeton = sqlpage.cookie('jeton_session')
);


-- create a temporary table to preprocess the data
create temporary table if not exists csv_import(nom text, nomepouse text, sexe text, prenom text, tel text, courriel text, rue text, cp text, ville text);
delete from csv_import; -- empty the table
-- If you don't have any preprocessing to do, you can skip the temporary table and use the target table directly

copy csv_import(nom, nomepouse, sexe, prenom, tel, courriel, rue, cp, ville) from 'fichier_csv'
with (header true, delimiter ',', quote '"', null ''); -- all the options are optional
-- since header is true, the first line of the file will be used to find the "name" and "age" columns
-- if you don't have a header line, the first column in the CSV will be interpreted as the first column of the table, etc

-- run any preprocessing you want on the data here

-- insert the data into the users table
INSERT INTO Personne (
    NomPersonne, 
    PrenomPersonne, 
    SexePersonne, 
    NomJfPersonne,
    TelephonePersonne, 
    CourrielPersonne, 
    DateinscriptionPersonne, 
    IdSection, 
    IdPromotion, 
    RuePersonne, 
    CpPersonne, 
    VillePersonne, 
    IdDoyenne,
    pinPersonne
)
SELECT 
    CASE 
        WHEN sexe = 'M' THEN REPLACE(UPPER(nom), '6', '-')
        ELSE REPLACE(UPPER(COALESCE(nomepouse,'')), '6', '-')
    END,
    prenom,
    sexe,
    CASE 
        WHEN sexe = 'F' THEN REPLACE(UPPER(nom), '6', '-')
        ELSE NULL
    END,
    tel,
    courriel,
    date('now'),
    CAST(:IdSection AS INTEGER),
    CAST(:IdPromotion AS INTEGER),
    rue,
    cp,
    ville,
    COAlESCE( ( SELECT IdDoyenne FROM v_sessions_valides WHERE jeton = sqlpage.cookie('jeton_session') ), CAST(:IdDoyenne AS INTEGER)),
    substr(random(),5,6) || substr(random(),5,6)
from csv_import
WHERE nom IS NOT NULL
    AND sexe IN ('M', 'F')
    AND LENGTH(COALESCE(nom,'')) > 0
    AND (sexe = 'F' OR LENGTH(COALESCE(nomepouse, '')) = 0 ) ;
