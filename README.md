# taxacheck
A Shiny web app for taxonomy name checking and validation.
#  TaxaCheck — Taxonomy Checker Tool

**Author:** Mahallelah Shauer  
**License:** GPL-3  
**Live App:** [https://shauer.shinyapps.io/taxacheck](https://shauer.shinyapps.io/taxacheck)


---

##  Overview

**TaxaCheck** is an open-source Shiny web application designed for **biologists, ecologists, and data curators** to validate and standardize scientific names across major taxonomic databases — without requiring any programming experience.

Users can upload a CSV file of species names, select one or more **kingdoms** (e.g., Animalia, Plantae, Fungi), and choose a **taxonomic database** such as GBIF, ITIS, Catalogue of Life, NCBI, or WFO.  
The app automatically cleans and standardizes names, identifies synonyms, and outputs a downloadable, traceable results file.

---

##  Key Features

-  **Multi-Kingdom Selection** – Choose one or more kingdoms (e.g., Animalia + Plantae).  
-  **Database Choice** – Query GBIF, ITIS, Catalogue of Life, NCBI, or WFO.  
-  **Automatic Cleaning** – Uses the `bdc` and `rgnparser` packages to standardize name formatting.  
-  **Synonym Replacement & Suggestions** – Finds accepted names and suggests close matches for misspellings.  
-  **Progress Tracking** – Real-time feedback via a Shiny progress bar.  
-  **Traceability** – Outputs include database and kingdom metadata for reproducibility.  
-  **No Coding Required** – User-friendly web interface for research teams.

---

## Live App

🔗 **[Launch TaxaCheck on shinyapps.io](https://shauer.shinyapps.io/taxacheck/)**

- Upload a CSV file containing at least one column named `scientificName`.
- Select your preferred taxonomic database.
- Select one or more kingdoms.
- Click **“Run Taxonomy Check.”**
- Download your cleaned and validated results file.

---

## Input File Format

Your input file must contain:
- A column named **`scientificName`**  
- (Optional) Additional metadata columns (e.g., `locality`, `collectionDate`, etc.)  
- (Optional) A column named **`kingdom`** (used for traceability)

**Example:**

| scientificName        | kingdom   | locality    |
|------------------------|-----------|--------------|
| Panthera leo           | Animalia  | Serengeti    |
| Quercus robur          | Plantae   | London       |
| Amanita muscaria       | Fungi     | Helsinki     |

---

## Output

The app produces a cleaned CSV file including:
- `names_clean` — standardized scientific names  
- `.uncer_terms` — uncertainty flags  
- `queried_kingdom` — kingdom(s) queried  
- Database and kingdom metadata  

---

## TaxaCheck is powered by:
- [`bdc`](https://cran.r-project.org/package=bdc)
- [`taxadb`](https://cran.r-project.org/package=taxadb)
- [`rgnparser`](https://cran.r-project.org/package=rgnparser)
- [`shiny`](https://shiny.posit.co/)
- [`dplyr`](https://cran.r-project.org/package=dplyr)
- [`readr`](https://cran.r-project.org/package=readr)
- [`here`](https://cran.r-project.org/package=here)

All taxonomic data are retrieved directly from the selected database (GBIF, ITIS, COL, NCBI, or WFO) via these R packages.

---
Shauer, M. (2025). *TaxaCheck: A Shiny app for taxonomy validation*.  
Version 1.0. Available at https://shauer.shinyapps.io/taxacheck

##  Local Installation (Optional)

If you prefer to run TaxaCheck locally in RStudio:

```r
# Install required packages
install.packages(c("shiny", "dplyr", "readr", "bdc", "taxadb", "rgnparser", "here"))

# Run the app locally
shiny::runApp("app.R")
