# UK_Regional_GVA
# UK Regional GVA Data Warehouse & Power BI Analytics

**End-to-End Business Intelligence Project | Python | SQL Server | T-SQL | Power BI | DAX**

## 1. Project Overview

This project develops an end-to-end Business Intelligence (BI) solution to analyse regional economic performance across the United Kingdom using Gross Value Added (GVA) data from the Office for National Statistics (ONS).

The solution processes annual regional and industry-level economic data covering **1998–2023**, transforms it into a structured SQL Server data warehouse, and provides interactive Power BI dashboards for economic performance analysis.

A **Bronze–Silver–Gold (Medallion) Architecture** was implemented to manage raw ingestion, data cleaning, validation and analytical modelling.

The Gold layer follows a **dimensional star schema**, with a central fact table connected to Region, Industry and Date dimensions.

The project demonstrates practical skills in data engineering, SQL development, ETL processing, dimensional modelling, data quality, analytical reporting and business intelligence.

---

## 2. Business Problem

Regional economic data is often distributed across large datasets containing multiple geographic classifications, industry hierarchies and reporting periods.

Without a structured analytical model, comparing economic performance across regions and industries can be difficult.

The main challenges include:

- Managing multiple geographic and industry classifications.
- Identifying differences in regional economic performance.
- Analysing long-term economic growth.
- Comparing industry contributions across regions.
- Investigating the economic impact of COVID-19.
- Avoiding double counting across overlapping aggregation levels.
- Providing consistent and reusable analytical metrics.

### Project Objectives

The solution was designed to:

1. Build a structured SQL Server data warehouse for regional GVA analysis.
2. Develop an ETL pipeline using Python and T-SQL.
3. Implement a Bronze–Silver–Gold data architecture.
4. Design a dimensional star schema for analytical reporting.
5. Develop reusable SQL views and stored procedures.
6. Create DAX measures for economic performance analysis.
7. Build interactive Power BI dashboards.
8. Apply data-quality checks throughout the pipeline.
9. Maintain project code and documentation using Git and GitHub.

---

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Python | Source-data preparation and transformation |
| Pandas | Data profiling, cleaning and validation |
| Google Colab | Python-based data preparation |
| Microsoft SQL Server | Relational data warehouse |
| SQL Server Management Studio | SQL development and database management |
| T-SQL | ETL, transformations and analytical queries |
| SQL Window Functions | Growth comparisons and industry rankings |
| Power BI Desktop | Interactive dashboards and semantic modelling |
| DAX | KPI and business measure development |
| Git | Source-code version control |
| GitHub | Repository hosting and technical documentation |

---

## 4. Data Source

**Source:** Office for National Statistics (ONS)

**Dataset:** UK Regional Gross Value Added (GVA)

**Reporting period:** 1998–2023

### Dataset Characteristics

| Attribute | Value |
|---|---|
| Records | 44,928 |
| Geographic entities | 16 |
| SIC07 codes | 108 |
| Reporting years | 26 |
| Earliest year | 1998 |
| Latest year | 2023 |
| GVA unit | £ million |

The dataset contains economic output values classified by geographic area, industry and year.

### Main Attributes

- ITL geographic code
- Region name
- Geographic classification
- SIC07 industry code
- Industry description
- Industry classification level
- Reporting year
- GVA value in £ million

### Data Modelling Considerations

The dataset contains overlapping industry hierarchy levels, including TOTAL, SECTOR, SECTION, SUBSECTION and DIVISION.

These classifications must be filtered appropriately during analysis because summing across multiple hierarchy levels can result in double counting.

Similarly, geographic totals must be separated from regional observations when calculating regional comparisons.

---

## 5. Data Warehouse Architecture

The project implements a Medallion Architecture consisting of three data-processing layers.

**Data Flow:**

ONS Source Data → Python/Pandas → Bronze → Silver → Gold → Power BI

### Bronze Layer — Raw Ingestion

**Table:** `bronze.RegionalGVA_Raw`

The Bronze layer stores source records after ingestion into SQL Server.

Responsibilities:

- Preserve the source data.
- Support source-to-database reconciliation.
- Provide traceability for downstream transformations.
- Enable inspection of raw data quality.

The Bronze dataset contains 44,928 records.

### Silver Layer — Data Cleaning and Validation

**Table:** `silver.RegionalGVA_Clean`

The Silver layer standardises the data and prepares it for dimensional modelling.

Transformations and checks include:

- Whitespace removal.
- Data-type standardisation.
- Year-range validation.
- Numeric-value validation.
- Duplicate detection.
- Missing-value inspection.
- Preparation of consistent region and industry identifiers.

### Gold Layer — Analytical Data Model

The Gold layer contains analytics-ready dimensional tables.

**Dimension Tables:**

- `gold.DimRegion`
- `gold.DimIndustry`
- `gold.DimDate`

**Fact Table:**

- `gold.FactRegionalGVA`

This model provides the foundation for SQL analytics and Power BI reporting.

---

## 6. Dimensional Data Modelling

A star schema was designed to separate numerical GVA observations from descriptive dimensions.

### DimRegion

Stores geographic information.

| Column | Description |
|---|---|
| RegionKey | Surrogate primary key |
| ITLCode | Geographic identifier |
| RegionName | Geographic area |
| GeographyLevel | Geographic classification |

### DimIndustry

Stores industry information.

| Column | Description |
|---|---|
| IndustryKey | Surrogate primary key |
| SIC07Code | Industry classification code |
| SIC07Description | Industry description |
| IndustryLevel | Industry hierarchy level |

### DimDate

Stores the reporting year.

| Column | Description |
|---|---|
| DateKey | Surrogate primary key |
| Year | Reporting year |

### FactRegionalGVA

Stores numerical GVA observations.

| Column | Description |
|---|---|
| GVAKey | Fact primary key |
| RegionKey | Foreign key to DimRegion |
| IndustryKey | Foreign key to DimIndustry |
| DateKey | Foreign key to DimDate |
| GVAMillionGBP | GVA value in £ million |

### Relationships

- DimRegion (1) → (*) FactRegionalGVA
- DimIndustry (1) → (*) FactRegionalGVA
- DimDate (1) → (*) FactRegionalGVA

The model supports consistent filtering, aggregation and reuse of analytical measures.

---

## 7. ETL Pipeline Implementation

### Stage 1 — Data Preparation

Python and Pandas were used to inspect and prepare the source data.

Activities included:

- Reviewing data structure and column types.
- Inspecting geographic and industry classifications.
- Validating reporting years.
- Checking missing and duplicate records.
- Preparing the dataset for SQL Server ingestion.

### Stage 2 — Bronze Ingestion

The prepared dataset was loaded into the SQL Server Bronze schema.

The ingestion process was validated through row-count and data-type checks.

### Stage 3 — Silver Transformation

T-SQL transformations were applied to clean and standardise the Bronze data.

The Silver load was implemented using smaller processing batches after an initial memory-related error.

### Stage 4 — Gold Dimensional Modelling

Distinct geographic, industry and date attributes were used to populate the dimension tables.

The central fact table was populated using the corresponding dimension keys.

### Stage 5 — Analytical SQL Development

Reusable views, stored procedures and indexes were developed to support economic analysis and reporting.

### Stage 6 — Power BI Integration

The Gold dimensional tables were imported into Power BI.

Relationships, DAX measures, slicers and interactive visuals were developed to support regional and industry-level economic analysis.

---

## 8. SQL Analytical Objects

The Gold layer includes reusable analytical views.

### Regional Performance

`gold.vw_RegionalPerformance`

Supports regional economic comparisons and aggregation.

### Year-on-Year Growth

`gold.vw_YearOnYearGrowth`

Uses SQL window functions to compare GVA between consecutive reporting years.

### Industry Performance

`gold.vw_IndustryPerformance`

Uses ranking logic to compare industry performance.

### COVID Recovery

`gold.vw_CovidRecovery`

Supports analysis of GVA changes between 2019, 2020, 2021 and 2022.

### Stored Procedure

`gold.usp_GetRegionalGVA`

Provides parameterised retrieval of regional GVA data.

### Database Indexing

Indexes were created on fact-table dimensional keys to support analytical queries.

---

## 9. Power BI Dashboard

The reporting solution contains three analytical pages.

### Dashboard 1 — Regional Economic Overview

**Purpose:** Analyse regional economic performance and long-term growth.

Features:

- Total GVA KPI.
- Previous Year GVA.
- Year-on-Year Growth %.
- Regional GVA comparison.
- Historical economic trends.
- Interactive region and year filters.

The dashboard supports comparison of English regions while keeping geographic aggregation levels separate.

### Dashboard 2 — Industry Performance

**Purpose:** Analyse the contribution and performance of SIC07 industries.

Features:

- Top 10 industries by GVA.
- Industry-level GVA trends.
- Selected-industry Total GVA.
- Industry Year-on-Year Growth %.
- Regional filtering.
- SIC07 Division-level analysis.

### Dashboard 3 — COVID Impact and Recovery

**Purpose:** Examine economic changes during and after the initial COVID-19 period.

Features:

- 2019–2022 GVA trend analysis.
- COVID Impact %.
- Recovery vs 2019 %.
- Industry and regional slicers.
- Comparison of pre-COVID and recovery-period performance.

---

## 10. DAX Measures

The Power BI semantic model includes the following analytical measures:

| Measure | Purpose |
|---|---|
| Total GVA | Calculates total GVA for the selected context |
| Previous Year GVA | Calculates GVA for the preceding year |
| YoY Change | Calculates absolute annual change |
| YoY Growth % | Calculates annual percentage growth |
| GVA Growth Since 1998 % | Measures growth relative to the 1998 baseline |
| COVID Impact % | Measures GVA change from 2019 to 2020 |
| Recovery vs 2019 % | Measures 2022 GVA relative to 2019 |

The calculations use DAX functions including CALCULATE, FILTER, ALL, REMOVEFILTERS, VAR and DIVIDE.

---

## 11. Technical Challenges and Solutions

### Challenge 1 — CSV Delimiter and Data Conversion Errors

**Problem:**

During the initial SQL Server bulk ingestion, the source dataset contained commas within industry descriptions.

Using a basic comma field delimiter caused incorrect column separation and data-conversion errors.

**Solution:**

Python and Pandas were used to prepare a pipe-delimited export.

The SQL Server bulk-loading configuration was updated to use the corresponding delimiter.

**Outcome:**

The source data was successfully ingested into the Bronze layer.

**Technical learning:**

Source-file structure and delimiter handling must be validated before ingestion.

### Challenge 2 — SQL Server Buffer Pool Memory

**Problem:**

An initial attempt to transform and insert the complete Bronze dataset into the Silver layer resulted in an insufficient buffer-pool-memory error.

**Solution:**

The ETL approach was modified to process records in smaller batches.

Row counts and duplicate checks were used to validate the transformation.

**Outcome:**

The Silver dataset was successfully populated.

**Technical learning:**

ETL processes should account for database resource constraints and support reliable validation.

### Challenge 3 — Duplicate Records During ETL

**Problem:**

Repeated loading attempts introduced duplicate records during development.

**Solution:**

The transformation and loading process was reviewed, and row-count and duplicate-validation queries were applied before proceeding to the Gold layer.

**Outcome:**

The warehouse was reconciled against the expected source records.

**Technical learning:**

ETL pipelines require repeatable loading strategies and data-quality controls.

### Challenge 4 — Industry Hierarchy Double Counting

**Problem:**

The dataset contained multiple overlapping SIC07 aggregation levels.

Combining these levels could produce misleading GVA totals.

**Solution:**

Industry hierarchy attributes were retained in DimIndustry, allowing Power BI visuals to filter the appropriate level.

**Technical learning:**

Understanding source-data granularity is essential for accurate BI reporting.

### Challenge 5 — Power BI Measure Formatting

**Problem:**

Percentage measures initially displayed as decimal values or were rounded incorrectly in Power BI cards.

**Solution:**

DAX measures were reviewed and formatted as percentages with appropriate decimal precision.

**Technical learning:**

Analytical correctness includes both calculation logic and accurate presentation.

---

## 12. Data Quality and Validation

Validation was performed across the warehouse development process.

Key checks included:

- Bronze and Silver row-count reconciliation.
- Duplicate detection.
- Missing-value validation.
- Year-range validation.
- GVA numeric-value checks.
- Dimension uniqueness.
- Fact-to-dimension key matching.
- Geographic hierarchy filtering.
- Industry hierarchy filtering.

These checks help ensure the analytical model remains consistent with the prepared source data.

---

## 13. Git and Version Control

Git and GitHub are used to organise and maintain the project's source code and documentation.

The repository separates Python scripts, SQL transformations, analytical queries, Power BI assets and supporting documentation.

### Version Control Approach

- Maintain the stable project on the `main` branch.
- Use descriptive commit messages.
- Track changes to Python, SQL and DAX code.
- Document technical changes and improvements.
- Use feature branches for future development.
- Tag validated project releases.

### Example Commit Messages

- `docs: add project overview and architecture`
- `feat: add bronze ingestion scripts`
- `feat: implement silver data transformations`
- `feat: create gold star schema`
- `feat: add analytical SQL views`
- `feat: add Power BI DAX measures`
- `docs: document ETL technical challenges`

Version control provides a traceable development history for future improvements.

---

## 14. Repository Structure

```text
uk-regional-gva-data-warehouse/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── data/
│   └── README.md
│
├── python/
│   └── 01_prepare_data.py
│
├── sql/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   └── validation/
│
├── powerbi/
│   ├── measures.dax
│   └── README.md
│
├── docs/
│   └── technical_challenges.md
│
└── images/
    ├── architecture.png
    ├── star_schema.png
    ├── regional_overview.png
    ├── industry_performance.png
    └── covid_recovery.png
```

---

## 15. Key Skills Demonstrated

**Data Engineering:** ETL, data ingestion, data preparation, Bronze–Silver–Gold architecture, data quality.

**SQL Development:** T-SQL, SQL Server, joins, window functions, stored procedures, views and indexing.

**Data Modelling:** Star schema, dimensional modelling, fact and dimension tables, primary and foreign keys.

**Business Intelligence:** Power BI, DAX, KPI development, interactive reporting and analytical modelling.

**Development Practices:** Git, GitHub, technical documentation and reproducible project organisation.

---

## 16. Future Enhancements

Potential improvements include:

- Automated ingestion and scheduled ETL execution.
- Incremental loading.
- Automated data-quality tests.
- Cloud-based data warehouse deployment.
- Power BI Service publishing.
- Additional UK economic datasets.
- Expanded regional productivity and industry analysis.

---

## 17. Author

**Yanamandra Sri Rama Subrahmanya Sastry**

MSc Data Science & Artificial Intelligence  
University of Liverpool

**Career Interests:** Business Intelligence Developer | Data Analyst | Data Engineering

---

## Data Attribution

Data source: Office for National Statistics (ONS).

The source dataset and any redistributed extracts remain subject to their applicable licensing and attribution requirements.
