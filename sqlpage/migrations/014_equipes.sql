
-- ============================================================
-- MIGRATION : Création table Equipe + rattachement à Personne
-- Une équipe fictive est créée par doyenné
-- La colonne IdDoyenne de Personne est conservée
-- ============================================================
 
-- 1. Création de la table Equipe
CREATE TABLE IF NOT EXISTS Equipe (
  IdEquipe      INTEGER,
  LibelleEquipe VARCHAR(150) NOT NULL,
  IdDoyenne     INTEGER NOT NULL REFERENCES Doyenne(IdDoyenne),
  PRIMARY KEY (IdEquipe ASC)
);
 
-- 2. Insertion d'une équipe fictive par doyenné
INSERT INTO Equipe(LibelleEquipe, IdDoyenne)
  SELECT 'Équipe ' || Nomdoyenne, IdDoyenne FROM Doyenne;
 
-- Résultat attendu :
--   IdEquipe | LibelleEquipe          | IdDoyenne
--   ---------+------------------------+----------
--   1        | Équipe Amboise         | 1
--   2        | Équipe Chinon          | 2
--   3        | Équipe Loches          | 3
--   4        | Équipe Tours centre    | 4
--   5        | Équipe Tours nord      | 5
--   6        | Équipe Tours sud       | 6
 
-- 3. Ajout de la colonne IdEquipe dans Personne
ALTER TABLE Personne ADD COLUMN IdEquipe INTEGER REFERENCES Equipe(IdEquipe);
 
-- 4. Mise à jour : chaque personne reçoit l'équipe correspondant à son doyenné
UPDATE Personne
SET IdEquipe = (
  SELECT IdEquipe
  FROM Equipe
  WHERE Equipe.IdDoyenne = Personne.IdDoyenne
);
