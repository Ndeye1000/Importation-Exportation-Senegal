# Import/Export Sénégal — Base de données commerce extérieur

Base de données SQLite structurée à partir des statistiques du commerce extérieur du Sénégal (importations et exportations), couvrant la période **janvier 2015 à décembre 2025**.

## 📦 Source des données

Les données proviennent de deux fichiers Excel (source : ANSD — Agence Nationale de la Statistique et de la Démographie du Sénégal) :

| Fichier source | Dimension | Unité | Contenu |
|---|---|---|---|
| `Volume.xlsx` | Catégorie de produit | tonnes | Import/export par catégorie de produit (nomenclature douanière), 192 lignes × 132 mois |
| `Valeur.xlsx` | Pays partenaire | millions FCFA | Import/export par pays partenaire commercial, 372 lignes × 132 mois |

Ces deux fichiers étaient au format "large" (un mois par colonne). Les données ont été dépivotées (`melt`) puis normalisées dans un schéma relationnel pour faciliter les requêtes et l'analyse.

## 🗂️ Structure de la base

```
flux ──────────────┐
                    ├──> mouvement ──> categorie_produit
mois ───────────────┤
                    └──> mouvement_pays ──> pays
```

- **`flux`** — Référentiel des sens d'échange (`Exportations` / `Importations`)
- **`categorie_produit`** — Référentiel des 96 catégories de produits (nomenclature douanière)
- **`pays`** — Référentiel des 186 pays partenaires commerciaux
- **`mois`** — Référentiel temporel (mois + année, 132 entrées : 2015-2025)
- **`mouvement`** — Table de faits : volumes en tonnes par flux × catégorie de produit × mois (25 344 lignes)
- **`mouvement_pays`** — Table de faits : valeurs en millions FCFA par flux × pays × mois (49 104 lignes)

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

## 🔍 Exemple de requête

```sql
-- Évolution annuelle des importations de céréales
SELECT mo.annee, SUM(m.valeur) AS total_tonnes
FROM mouvement m
JOIN flux f ON f.flux_id = m.flux_id
JOIN categorie_produit cp ON cp.categorie_id = m.categorie_id
JOIN mois mo ON mo.mois_id = m.mois_id
WHERE cp.nom = 'CEREALES' AND f.nom = 'Importations'
GROUP BY mo.annee
ORDER BY mo.annee;
```
