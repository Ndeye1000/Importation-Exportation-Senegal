CREATE TABLE flux (
    flux_id INTEGER PRIMARY KEY,
    nom TEXT NOT NULL UNIQUE          -- 'Exportations' / 'Importations'
);
CREATE TABLE categorie_produit (
    categorie_id INTEGER PRIMARY KEY,
    nom TEXT NOT NULL UNIQUE          -- 'ANIMAUX VIVANTS', 'VIANDES ET ABATS...', etc.
);
CREATE TABLE mois (
    mois_id INTEGER PRIMARY KEY,
    mois TEXT NOT NULL,               -- 'Jan', 'Feb', ...
    annee INTEGER NOT NULL,           -- 2015
    UNIQUE(mois, annee)
);
CREATE TABLE mouvement (
    mouvement_id INTEGER PRIMARY KEY,
    flux_id INTEGER NOT NULL REFERENCES flux(flux_id),
    categorie_id INTEGER NOT NULL REFERENCES categorie_produit(categorie_id),
    mois_id INTEGER NOT NULL REFERENCES mois(mois_id),
    unite TEXT NOT NULL DEFAULT 'tonnes',
    valeur REAL          -- plus de NOT NULL, pour garder les données manquantes
);
CREATE TABLE pays (
    pays_id INTEGER PRIMARY KEY,
    nom TEXT NOT NULL UNIQUE
);
CREATE TABLE mouvement_pays (
    mouvement_pays_id INTEGER PRIMARY KEY,
    flux_id INTEGER NOT NULL REFERENCES flux(flux_id),
    pays_id INTEGER NOT NULL REFERENCES pays(pays_id),
    mois_id INTEGER NOT NULL REFERENCES mois(mois_id),
    unite TEXT NOT NULL DEFAULT 'millions FCFA',
    valeur REAL
);
