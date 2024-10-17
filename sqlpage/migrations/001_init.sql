CREATE TABLE Personne (
  IdPersonne     INTEGER,
  NomPersonne    VARCHAR(100),
  PrenomPersonne VARCHAR(80),
  SexePersonne   VARCHAR(1),
  NomJfPersonne  VARCHAR(100),
  CourrielPersonne VARCHAR(100),
  TelephonePersonne VARCHAR(20), 
  DateinscriptionPersonne DATE,
  PRIMARY KEY (IdPersonne ASC)
);

CREATE TABLE Sacrement (
  IdSacrement  INTEGER,
  NomSacrement VARCHAR(42),
  PRIMARY KEY (IdSacrement ASC)
);

CREATE TABLE Formalite (
  IdFormalite  INTEGER,
  NomFormalite VARCHAR(42),
  PRIMARY KEY (IdFormalite ASC)
);

CREATE TABLE Venir (
  IdPersonne INTEGER,
  Date       DATE,
  PRIMARY KEY (IdPersonne, Date),
  FOREIGN KEY (IdPersonne) REFERENCES Personne (IdPersonne)
);

CREATE TABLE Demander (
  IdPersonne  INTEGER,
  IdSacrement INTEGER,
  PRIMARY KEY (IdPersonne, IdSacrement),
  FOREIGN KEY (IdPersonne) REFERENCES Personne (IdPersonne),
  FOREIGN KEY (IdSacrement) REFERENCES Sacrement (IdSacrement)
);

CREATE TABLE Remplir (
  IdPersonne  INTEGER,
  IdFormalite INTEGER,
  CommentaireFormalite VARCHAR(100),
  PRIMARY KEY (IdPersonne, IdFormalite),
  FOREIGN KEY (IdPersonne) REFERENCES Personne (IdPersonne),
  FOREIGN KEY (IdFormalite) REFERENCES Formalite (IdFormalite)
);
