CREATE TABLE Doyenne (
  IdDoyenne     INTEGER,
  Nomdoyenne    VARCHAR(100),
  PRIMARY KEY (IdDoyenne ASC)
);
INSERT INTO Doyenne(Nomdoyenne)VALUES('Amboise');
INSERT INTO Doyenne(Nomdoyenne)VALUES('Chinon');
INSERT INTO Doyenne(Nomdoyenne)VALUES('Loches');
INSERT INTO Doyenne(Nomdoyenne)VALUES('Tours centre');
INSERT INTO Doyenne(Nomdoyenne)VALUES('Tours nord');
INSERT INTO Doyenne(Nomdoyenne)VALUES('Tours sud');

ALTER TABLE PERSONNE ADD IdDoyenne INTEGER REFERENCES Doyenne(IdDoyenne);


CREATE TABLE type_evenement(
  codeType_evenement   VARCHAR(5),
  NomType_evenement    VARCHAR(100),
  PRIMARY KEY (codeType_evenement ASC)
);

INSERT INTO type_evenement(codeType_evenement,NomType_evenement)VALUES('RECOL','Recollection');
INSERT INTO type_evenement(codeType_evenement,NomType_evenement)VALUES('ACCUE','Accueil');
INSERT INTO type_evenement(codeType_evenement,NomType_evenement)VALUES('ENTRE','Entrée en Eglise');
INSERT INTO type_evenement(codeType_evenement,NomType_evenement)VALUES('APDEC','Appel décisif');
INSERT INTO type_evenement(codeType_evenement,NomType_evenement)VALUES('SCRMT','Sacrement');


CREATE TABLE PROMOTION (
  IdPromotion     INTEGER,
  NomPromotion    VARCHAR(100),
  PRIMARY KEY (IdPromotion ASC)
);
INSERT INTO PROMOTION(IdPromotion,NomPromotion)VALUES(1,'2024-2025');

ALTER TABLE PERSONNE ADD IdPromotion INTEGER REFERENCES PROMOTION(IdPromotion);
UPDATE PERSONNE SET IdPromotion = 1;





-- 1. Renommer la table existante
-- ALTER TABLE "Venir" RENAME TO "Venir_old";
DROP VIEW Status_Personne;
-- 2. Créer la nouvelle table avec la clé primaire modifiée
CREATE TABLE "Venir_tmp" (
    "IdPersonne" INTEGER,
    "Date" DATE,
    "codeType_evenement" TEXT,
    FOREIGN KEY("codeType_evenement") REFERENCES "type_evenement"("codeType_evenement"),
    FOREIGN KEY("IdPersonne") REFERENCES "Personne"("IdPersonne"),
    PRIMARY KEY("IdPersonne", "Date", "codeType_evenement")
);

-- 3. Copier les données de l'ancienne table vers la nouvelle
INSERT INTO "Venir_tmp" ("IdPersonne", "Date", "codeType_evenement")
SELECT "IdPersonne", "Date", 'RECOL' FROM "Venir";

-- 4. Supprimer l'ancienne table
DROP TABLE "Venir";
ALTER TABLE "Venir_tmp" RENAME TO "Venir";


CREATE VIEW Status_Personne AS 
  select
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,'alert-triangle', -- Le dossier initial est incomplet
				iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
					iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) = 0 ,'','file-report'),
					'user-search')
		) as etat 
		,
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,'Dossier incomplet', -- Le dossier initial est incomplet
			iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
					iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) = 0 ,'','Formalités incomplètes'),
					'Information')
		) as titre
		,
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,'Il manque un moyen de contact ou un sacrement demandé pour compléter le dossier de ce recommençant', -- Le dossier initial est incomplet
			iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
				iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) = 0 ,'','Il reste des formalités à remplir par ce recommençant'),
					'Cette personne n''est pour l''instant venue à aucune rencontre diocésaine')
		) as description
		,
		iif((SELECT COUNT(*) from Demander WHERE Demander.IdPersonne = Personne.IdPersonne) = 0 OR LENGTH(Personne.CourrielPersonne) + LENGTH(Personne.TelephonePersonne) < 1,'orange', -- Le dossier initial est incomplet
			iif((SELECT COUNT(*) from Venir WHERE Venir.IdPersonne = Personne.IdPersonne) > 0,
				iif( (SELECT COUNT(fo.NomFormalite)FROM Formalite fo LEFT JOIN Remplir rem ON (fo.IdFormalite = rem.IdFormalite AND rem.IdPersonne = Personne.IdPersonne )WHERE rem.IdPersonne IS NULL) = 0 ,'','blue'),
					'dark-grey')
		) as couleur
		,Personne.IdPersonne
		FROM Personne