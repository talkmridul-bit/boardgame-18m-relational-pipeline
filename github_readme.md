# Boardgame 18M+ Rating Data Relational Inner Join Pipeline

## Overview
A high-throughput, low-resource relational data engineering pipeline built using **R (Tidyverse & readr)**. This project demonstrates **$0.00 Cloud OPEX** on-premise ETL processing, execution under severe hardware memory limits, deduplication, schema validation, relational joining, and disk persistence over **18,000,000+** records.

---

## Machine Specifications & Hardware Constraints
* **Host CPU:** Intel Core i3 @ 1.20 GHz (Dual-Core)
* **Physical RAM:** 4.00 GB DDR4 Ceiling
* **OS Footprint:** Windows 10 Base Overhead (~2.0 GB RAM usage)
* **Net Executable Memory:** ~2.0 GB Net Heap space available for processing
* **Cloud Infrastructure:** None ($0.00 Cloud OPEX / Air-Gapped Local Environment)

---

## Data Pipeline Flow
The data flows through four memory-optimized stages to prevent RAM swapping and buffer overflows:

```
+--------------------+      +--------------------+      +--------------------------+      +-----------------------+
|  1. Data Ingestion | ---> | 2. Data Cleaning   | ---> | 3. Relational Inner Join | ---> | 4. Disk Persistence   |
|  (C++ readr Stream)|      | (Filter & Typecast)|      | (Index Match via BGGId)  |      | (Compressed CSV Export)|
+--------------------+      +--------------------+      +--------------------------+      +-----------------------+
```

---

## Pipeline Implementation Details

### Stage 1: Fast Data Ingestion
Utilizes multi-threaded C++ backends (`readr::read_csv`) for fast disk-to-memory streaming without triggering buffer copies.

```R
library(tidyverse)
library(readr)

# Ingest 18M+ Ratings raw dataset
data_rating <- read_csv("Boardgame_18M_ratings.csv")
glimpse(data_rating)

# Ingest Boardgame Subcategory relational mapping table
data_subcategory <- read_csv("Boardgame_subcategories.csv")
glimpse(data_subcategory)
```

### Stage 2: Data Cleaning & Sanitization
Strips duplicate submission records to enforce primary key integrity (`BGGId`) and purges corrupted/zero-value entries upfront.

```R
# Sanitize Ratings: Deduplication, Type Coercion & Non-Zero Filtering
cleaned_data_rating <- data_rating %>%
  distinct() %>%
  mutate(
    BGGId = as.integer(BGGId),
    Rating = as.numeric(Rating)
  ) %>%
  filter(BGGId > 0 & Rating > 0)

# Sanitize Subcategory Lookup Table
cleaned_data_subcategory <- data_subcategory %>%
  distinct() %>%
  mutate(BGGId = as.integer(BGGId)) %>%
  filter(BGGId > 0)
```

### Stage 3: Relational Inner Join
Merges the 18M+ clean ratings table with subcategories indexed strictly on `BGGId`.

```R
# Execute memory-optimized relational Inner Join
join_report <- cleaned_data_rating %>%
  inner_join(cleaned_data_subcategory, by = "BGGId")
```

### Stage 4: Feature Selection & Persistence
Projects essential analytical columns to prune unnecessary attributes before exporting to disk.

```R
# Project target subcategories & export sanitized dataset to CSV
final_report <- join_report %>%
  select(BGGId, Rating, Username, Puzzle, Exploration, Electronic)

write.csv(final_report, "Boardgame_18M_rating_join_data.csv", row.names = FALSE)
```

---

## Project Structure
```text
├── scripts/
│   ├── 01_ingestion.R
│   ├── 02_cleaning.R
│   └── 03_join_and_persist.R
├── README.md
└── .gitignore
```

---

## Author & Connect
* **GitHub:** [talkmridul-bit](https://github.com/talkmridul-bit)
* **LinkedIn:** [Niaz Shoyab](https://www.linkedin.com/in/niaz-shoyab-495061b8)