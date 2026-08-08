-- Schéma de la base import_export_senegal.db (v2 - normalisé)
-- Données douanières du Sénégal : importations/exportations par catégorie de produit et par pays
-- Source : ANSD (Volume.xlsx en tonnes, Valeur.xlsx en millions FCFA) - 2015 à 2025

-- Table des flux commerciaux (Importations / Exportations)
CREATE TABLE flux (
    flux_id INTEGER PRIMARY KEY,
    nom TEXT NOT NULL UNIQUE          -- 'Exportations' / 'Importations'
);

-- Table des catégories de produits (nomenclature douanière)
CREATE TABLE categorie_produit (
    categorie_id INTEGER PRIMARY KEY,
    nom TEXT NOT NULL UNIQUE          -- 'ANIMAUX VIVANTS', 'CEREALES', etc.
);

-- Table des pays partenaires commerciaux
CREATE TABLE pays (
    pays_id INTEGER PRIMARY KEY,
    nom TEXT NOT NULL UNIQUE
);

-- Table des mois (référentiel, valeurs uniques : 12 lignes)
CREATE TABLE mois (
    mois_id INTEGER PRIMARY KEY,
    nom TEXT NOT NULL UNIQUE          -- 'Jan', 'Feb', ..., 'Dec'
);

-- Table des années (référentiel, 2015 à 2025 : 11 lignes)
CREATE TABLE annee (
    annee_id INTEGER PRIMARY KEY,
    annee INTEGER NOT NULL UNIQUE     -- 2015, 2016, ..., 2025
);

-- Table de faits : mouvements par catégorie de produit
-- Source : Volume.xlsx — unité fixe : tonnes (portée dans le nom de la colonne)
CREATE TABLE mouvement (
    mouvement_id INTEGER PRIMARY KEY,
    flux_id INTEGER NOT NULL REFERENCES flux(flux_id),
    categorie_id INTEGER NOT NULL REFERENCES categorie_produit(categorie_id),
    mois_id INTEGER NOT NULL REFERENCES mois(mois_id),
    annee_id INTEGER NOT NULL REFERENCES annee(annee_id),
    valeur_tonnes REAL
);

-- Table de faits : mouvements par pays partenaire
-- Source : Valeur.xlsx — unité fixe : millions FCFA (portée dans le nom de la colonne)
CREATE TABLE mouvement_pays (
    mouvement_pays_id INTEGER PRIMARY KEY,
    flux_id INTEGER NOT NULL REFERENCES flux(flux_id),
    pays_id INTEGER NOT NULL REFERENCES pays(pays_id),
    mois_id INTEGER NOT NULL REFERENCES mois(mois_id),
    annee_id INTEGER NOT NULL REFERENCES annee(annee_id),
    valeur_millions_fcfa REAL
);

-- Index utiles pour accélérer les requêtes d'analyse
CREATE INDEX idx_mouvement_flux ON mouvement(flux_id);
CREATE INDEX idx_mouvement_categorie ON mouvement(categorie_id);
CREATE INDEX idx_mouvement_mois ON mouvement(mois_id);
CREATE INDEX idx_mouvement_annee ON mouvement(annee_id);

CREATE INDEX idx_mouvement_pays_flux ON mouvement_pays(flux_id);
CREATE INDEX idx_mouvement_pays_pays ON mouvement_pays(pays_id);
CREATE INDEX idx_mouvement_pays_mois ON mouvement_pays(mois_id);
CREATE INDEX idx_mouvement_pays_annee ON mouvement_pays(annee_id);
