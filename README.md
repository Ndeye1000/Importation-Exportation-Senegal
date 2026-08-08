# Import/Export Sénégal — Base de données commerce extérieur

Base de données SQLite structurée à partir des statistiques du commerce extérieur du Sénégal (importations et exportations), couvrant la période **janvier 2015 à décembre 2025**.

## 📦 Source des données

Les données proviennent de deux fichiers Excel (source : ANSD — Agence Nationale de la Statistique et de la Démographie du Sénégal) :

| Fichier source | Dimension | Unité | Contenu |
|---|---|---|---|
| `Volume.xlsx` | Catégorie de produit | tonnes | Import/export par catégorie de produit (nomenclature douanière), 192 lignes × 132 mois |
| `Valeur.xlsx` | Pays partenaire | millions FCFA | Import/export par pays partenaire commercial, 372 lignes × 132 mois |

Ces deux fichiers étaient au format "large" (un mois par colonne). Les données ont été dépivotées (`melt`) puis normalisées dans un schéma relationnel pour faciliter les requêtes et l'analyse.

## 🗂️ Structure de la base (v2)

```
flux ───────────────┐
                     ├──> mouvement ──> categorie_produit
mois ────────────────┤
annee ───────────────┤
                     └──> mouvement_pays ──> pays
```

- **`flux`** — Référentiel des sens d'échange (`Exportations` / `Importations`)
- **`categorie_produit`** — Référentiel des 96 catégories de produits (nomenclature douanière)
- **`pays`** — Référentiel des 186 pays partenaires commerciaux
- **`mois`** — Référentiel des mois, valeurs uniques (`Jan` à `Dec`, 12 lignes)
- **`annee`** — Référentiel des années (2015 à 2025, 11 lignes)
- **`mouvement`** — Table de faits : volumes en tonnes (`valeur_tonnes`) par flux × catégorie de produit × mois × année (25 344 lignes)
- **`mouvement_pays`** — Table de faits : valeurs en millions FCFA (`valeur_millions_fcfa`) par flux × pays × mois × année (49 104 lignes)

> **v2 vs v1** : `mois` et `annee` sont désormais deux référentiels indépendants (au lieu d'une table `mois` combinant les deux), et l'unité de mesure est portée directement dans le nom de la colonne (`valeur_tonnes` / `valeur_millions_fcfa`) plutôt que stockée en tant que valeur constante répétée sur chaque ligne (colonne `unite` supprimée).

Le schéma complet est disponible dans [`schema.sql`](./schema.sql).

## ✅ Fiabilité des données

Chaque import a été vérifié par comparaison de sommes totales entre le fichier Excel source et la base :

| Table | Lignes | Somme vérifiée |
|---|---|---|
| `mouvement` | 25 344 | 225 917 481,7 tonnes ✅ |
| `mouvement_pays` | 49 104 | 81 155 645,4 millions FCFA ✅ |

Aucune valeur manquante, aucun doublon détecté dans les fichiers sources.

## ⚠️ Limite connue

Il n'existe pas de catégorie "blé" isolée dans la nomenclature. Le blé est agrégé dans la catégorie **`CEREALES`** (avec riz, maïs, sorgho, etc.), utilisée comme proxy dans les analyses. Les produits de minoterie (farine, gluten de froment) apparaissent séparément sous **`PRODUITS DE LA MINOTERIE...`**.

## 🚀 Recréer la base

```bash
sqlite3 import_export_senegal.db < schema.sql
```

Puis importer les données depuis les fichiers CSV ou Excel sources avec le script Python d'import (dépivotage + insertion).

## 🔍 Exemples de requêtes

```sql
-- Évolution annuelle des importations de céréales
SELECT a.annee, SUM(m.valeur_tonnes) AS total_tonnes
FROM mouvement m
JOIN flux f ON f.flux_id = m.flux_id
JOIN categorie_produit cp ON cp.categorie_id = m.categorie_id
JOIN annee a ON a.annee_id = m.annee_id
WHERE cp.nom = 'CEREALES' AND f.nom = 'Importations'
GROUP BY a.annee
ORDER BY a.annee;

-- Nombre de catégories de produits distinctes
SELECT COUNT(*) FROM categorie_produit;

-- Nombre de mois distincts (devrait être 12)
SELECT COUNT(*) FROM mois;

-- Nombre d'années distinctes (devrait être 11 : 2015 à 2025)
SELECT COUNT(*) FROM annee;

-- Vérifier les 2 flux
SELECT * FROM flux;

-- Total exporté par catégorie, tous mois/années confondus (top 10)
SELECT cp.nom, SUM(m.valeur_tonnes) AS total
FROM mouvement m
JOIN flux f ON f.flux_id = m.flux_id
JOIN categorie_produit cp ON cp.categorie_id = m.categorie_id
WHERE f.nom = 'Exportations'
GROUP BY cp.nom
ORDER BY total DESC
LIMIT 10;

-- Évolution mensuelle des exportations totales
SELECT a.annee, mo.nom AS mois, SUM(m.valeur_tonnes) AS total
FROM mouvement m
JOIN flux f ON f.flux_id = m.flux_id
JOIN mois mo ON mo.mois_id = m.mois_id
JOIN annee a ON a.annee_id = m.annee_id
WHERE f.nom = 'Exportations'
GROUP BY a.annee, mo.nom
ORDER BY a.annee,
  CASE mo.nom
    WHEN 'Jan' THEN 1 WHEN 'Feb' THEN 2 WHEN 'Mar' THEN 3
    WHEN 'Apr' THEN 4 WHEN 'May' THEN 5 WHEN 'Jun' THEN 6
    WHEN 'Jul' THEN 7 WHEN 'Aug' THEN 8 WHEN 'Sep' THEN 9
    WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
  END;
```
