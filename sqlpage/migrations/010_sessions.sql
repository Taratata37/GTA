CREATE TABLE session_connexion (
    jeton VARCHAR(80),
    idDoyenne INTEGER,
    date_jeton DATETIME,
    FOREIGN KEY (idDoyenne) REFERENCES Doyenne(IdDoyenne)
);
