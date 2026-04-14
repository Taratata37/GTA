ALTER TABLE "Equipe" ADD COLUMN "IdSection" INTEGER
    REFERENCES "SECTION"("IdSection");

UPDATE "Equipe" SET "IdSection" = 1;