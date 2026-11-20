# UK Regional GVA Data Warehouse & Power BI Analytics

**End-to-End Business Intelligence Portfolio Project | Python | SQL Server | T-SQL | Power BI | DAX**

An end-to-end Business Intelligence solution that transforms Office for National Statistics (ONS) regional Gross Value Added (GVA) data into a structured SQL Server data warehouse and interactive Power BI dashboards.

The project demonstrates practical experience in **ETL development, dimensional modelling, SQL analytics, data validation, DAX calculations and business intelligence reporting**.

**Reporting Period:** 1998–2023  
**Data Source:** Office for National Statistics (ONS)  
**Architecture:** Bronze–Silver–Gold (Medallion Architecture)  
**Analytical Model:** Dimensional Star Schema

---

## 1. Project Overview

This project analyses regional and industry-level economic performance across the United Kingdom using ONS Gross Value Added (GVA) data.

The solution integrates Python-based data preparation, SQL Server data warehousing and Power BI reporting into a structured analytical workflow.

The warehouse follows a **Bronze–Silver–Gold architecture**, with the Gold layer implementing a dimensional star schema consisting of Region, Industry and Date dimensions connected to a central GVA fact table.

The resulting Power BI dashboards support:

- Regional economic performance comparisons.
- Historical GVA trend analysis.
- Year-on-year economic growth calculations.
- SIC07 industry performance analysis.
- COVID-19 economic impact assessment.
- Post-pandemic economic recovery comparisons.

This is an independent technical portfolio project developed to demonstrate real-world business intelligence and data warehousing practices.

---

## 2. Power BI Dashboard Preview

The reporting solution includes three interactive analytical dashboards.

### Dashboard 1 — Regional Economic Overview

![Regional Economic Overview](screenshots/regional_overview.png)

**Purpose:** Analyse regional economic performance and historical growth.

**Key features:**

- Total GVA KPI.
- Previous Year GVA.
- Year-on-Year Growth %.
- Regional GVA comparisons.
- Historical economic trends.
- Interactive region and reporting-year slicers.

### Dashboard 2 — Industry Performance

![Industry Performance](screenshots/industry_performance.png)

**Purpose:** Compare economic contributions across SIC07 industries.

**Key features:**

- Top-performing industry divisions.
- Industry GVA comparisons.
- Industry growth trends.
- Region and industry filtering.
- SIC07 classification-level analysis.

### Dashboard 3 — COVID-19 Impact and Recovery

![COVID-19 Impact and Recovery](screenshots/covid_impact.png)

**Purpose:** Examine regional and industry-level economic changes during and after the initial COVID-19 period.

**Key features:**

- COVID Impact %.
- Recovery vs 2019 %.
- GVA comparisons for 2019–2022.
- Regional and industry performance analysis.
- Interactive reporting filters.

For additional details, see [Power BI Documentation](powerbi/README.md).

---

## 3. Business Problem and Objectives

Regional economic datasets contain multiple geographic classifications, industry hierarchies and reporting periods.

Analysing these datasets directly can create challenges involving data consistency, aggregation accuracy and reporting efficiency.

### Business Challenges

- Comparing economic performance across UK regions.
- Analysing historical growth patterns.
- Identifying leading industry contributors.
- Measuring the economic impact of COVID-19.
- Managing overlapping geographic and industry classifications.
- Preventing double counting in aggregated economic measures.
- Producing consistent analytical metrics.

### Project Objectives

1. Develop a structured SQL Server data warehouse.
2. Prepare and validate source data using Python and Pandas.
3. Implement Bronze, Silver and Gold processing layers.
4. Design a dimensional star schema.
5. Develop reusable SQL views and stored procedures.
6. Implement data quality and reconciliation checks.
7. Create DAX measures for economic performance analysis.
8. Develop interactive Power BI dashboards.
9. Maintain source code and documentation using GitHub.

---

## 4. Technology Stack

| Technology | Application |
|---|---|
| Python | Data preparation and validation |
| Pandas | Data profiling, cleaning and transformation |
| Google Colab | Python-based development |
| SQL Server | Relational data warehouse |
| SSMS | SQL development and database administration |
| T-SQL | ETL, data transformation and analytical queries |
| SQL Window Functions | Growth calculations and industry rankings |
| Power BI Desktop | Interactive reporting and semantic modelling |
| DAX | KPI development and time-based calculations |
| Git | Version control |
| GitHub | Source-code hosting and documentation |

---

## 5. Dataset and Source

**Data Provider:** Office for National Statistics (ONS)

**Dataset:** UK Regional Gross Value Added (GVA)

**Reporting Period:** 1998–2023

### Prepared Dataset Characteristics

| Attribute | Value |
|---|---|
| Total records | 44,928 |
| Geographic entities | 16 |
| SIC07 industry codes | 108 |
| Reporting years | 26 |
| Earliest year | 1998 |
| Latest year | 2023 |
| Economic measure | Gross Value Added |
| Measurement unit | £ million |

These figures describe the prepared analytical dataset used in the project.

### Main Attributes

- `ITLCode` — Geographic identifier.
- `RegionName` — Geographic area name.
- `GeographyLevel` — Geographic hierarchy classification.
- `SIC07Code` — Industry classification code.
- `SIC07Description` — Industry description.
- `IndustryLevel` — Industry hierarchy level.
- `Year` — Reporting year.
- `GVAMillionGBP` — GVA expressed in £ millions.

### Important Aggregation Consideration

The dataset includes overlapping industry classifications such as TOTAL, SECTOR, SECTION, SUBSECTION and DIVISION.

These classifications must be filtered appropriately to prevent double counting.

Similarly, geographic aggregates should not be combined with their constituent regions when calculating overall economic output.

---

## 6. Data Warehouse Architecture

The project follows a **Bronze–Silver–Gold Medallion Architecture**.

### Data Processing Workflow

```text
Office for National Statistics
            |
            v
    Python / Pandas
    Data Preparation
            |
            v
     BRONZE LAYER
    Raw Data Ingestion
            |
            v
     SILVER LAYER
 Cleaning and Validation
            |
            v
      GOLD LAYER
   Dimensional Star Schema
            |
            v
      POWER BI
   Semantic Model + DAX
            |
            v
  Interactive BI Dashboards
```

### Bronze Layer — Data Ingestion

**Table:** `bronze.RegionalGVA_Raw`

The Bronze layer stores prepared source records ingested into SQL Server.

Key responsibilities:

- Preserve the ingested source structure.
- Support source-to-database reconciliation.
- Provide traceability for transformations.
- Enable initial data quality inspection.

### Silver Layer — Data Transformation

**Table:** `silver.RegionalGVA_Clean`

The Silver layer prepares the data for analytical modelling.

Transformations include:

- Whitespace standardisation.
- Data-type validation.
- Reporting-year filtering.
- Missing-value checks.
- Duplicate detection.
- Numeric-value validation.
- Consistent region and industry identifiers.

Batch-based loading was introduced to address SQL Server memory limitations during transformation.

### Gold Layer — Analytical Modelling

The Gold layer contains dimension and fact tables designed for Power BI reporting.

**Dimension Tables:**

- `gold.DimRegion`
- `gold.DimIndustry`
- `gold.DimDate`

**Fact Table:**

- `gold.FactRegionalGVA`

The model separates descriptive attributes from numerical observations to support reusable analytical calculations.

---

## 7. Dimensional Star Schema

The Gold layer uses a star schema with one fact table and three dimensions.

```text
                 DimDate
                    |
                    |
DimRegion ---- FactRegionalGVA ---- DimIndustry
```

### Dimension Tables

| Table | Primary key | Description |
|---|---|---|
| DimRegion | RegionKey | Geographic codes, names and hierarchy |
| DimIndustry | IndustryKey | SIC07 codes, descriptions and hierarchy |
| DimDate | DateKey | Reporting-year information |

### Fact Table

**`gold.FactRegionalGVA`**

| Column | Description |
|---|---|
| GVAKey | Fact-table primary key |
| RegionKey | Foreign key to DimRegion |
| IndustryKey | Foreign key to DimIndustry |
| DateKey | Foreign key to DimDate |
| GVAMillionGBP | GVA value in £ millions |

### Relationships

- DimRegion (1) → (*) FactRegionalGVA
- DimIndustry (1) → (*) FactRegionalGVA
- DimDate (1) → (*) FactRegionalGVA

The fact-table grain represents one geographic code, SIC07 industry code and reporting year.

This structure supports dimensional filtering and analytical reporting in Power BI.

---

## 8. ETL Pipeline Implementation

### Stage 1 — Python Data Preparation

Python and Pandas were used to inspect, validate and prepare the source dataset.

Activities included:

- Dataset profiling.
- Data-type inspection.
- Missing-value analysis.
- Duplicate detection.
- Reporting-year validation.
- Preparing data for SQL Server ingestion.

A pipe-delimited CSV export was introduced to resolve delimiter-related import issues.

### Stage 2 — Bronze Ingestion

The prepared dataset was loaded into SQL Server using T-SQL.

Data ingestion was checked through record counts and schema validation.

### Stage 3 — Silver Transformation

T-SQL transformations were used to standardise records and prepare them for dimensional modelling.

A batch-based processing approach was introduced after a memory-related failure during the initial transformation.

### Stage 4 — Gold Modelling

Distinct region, industry and date attributes were used to populate the dimension tables.

The fact table was populated by mapping source business keys to the corresponding dimensional surrogate keys.

### Stage 5 — SQL Analytics

Reusable SQL views, stored procedures and indexes were developed to support reporting and analysis.

### Stage 6 — Power BI Integration

The Gold tables were imported into Power BI.

Relationships, DAX measures, slicers and interactive visualisations were configured to support regional and industry-level analysis.

---

## 9. SQL Analytics and DAX Measures

### SQL Analytical Objects

| SQL object | Purpose |
|---|---|
| `gold.vw_RegionalPerformance` | Regional and industry GVA analysis |
| `gold.vw_YearOnYearGrowth` | Annual growth calculations using LAG |
| `gold.vw_IndustryPerformance` | Industry rankings using RANK |
| `gold.vw_CovidRecovery` | COVID impact and recovery comparisons |
| `gold.usp_GetRegionalGVA` | Parameterised regional data retrieval |

Indexes were also defined on fact-table dimensional keys to support query access patterns.

### Power BI DAX Measures

| Measure | Purpose |
|---|---|
| Total GVA | Economic output for the selected filter context |
| Previous Year GVA | GVA for the preceding reporting year |
| YoY GVA Change | Absolute annual economic change |
| YoY Growth % | Annual percentage growth |
| Growth Since 1998 % | Growth relative to the 1998 baseline |
| COVID Impact % | Change in GVA between 2019 and 2020 |
| Recovery vs 2019 % | Change in GVA between 2019 and 2022 |

DAX development used functions including `CALCULATE`, `DIVIDE`, `VAR` and `REMOVEFILTERS`.

Measure definitions are documented in [Power BI DAX Measures](powerbi/measures.dax).

---

## 10. Power BI Dashboard Features

### Regional Economic Overview

Provides a high-level analysis of regional economic output and historical performance.

Visualisations include KPI cards, regional comparisons, historical trends and interactive slicers.

### Industry Performance

Supports analysis of SIC07 industry divisions and their contributions to regional economic activity.

Visualisations include industry rankings, comparative bar charts and time-series analysis.

### COVID-19 Impact and Recovery

Examines the economic changes observed between the pre-pandemic baseline and subsequent reporting years.

The dashboard compares GVA in 2019, 2020, 2021 and 2022 to support regional and industry recovery analysis.

### Interactive Analysis

Dashboard users can filter reporting results by:

- Geographic area.
- Reporting year.
- Industry classification.
- SIC07 industry description.

---

## 11. Data Quality and Technical Challenges

Data validation was performed across the warehouse development process.

### Data Quality Checks

- Bronze-to-Silver row-count reconciliation.
- Missing-value detection.
- Duplicate business-key validation.
- Reporting-year verification.
- Numeric-value validation.
- Dimension uniqueness.
- Fact-to-dimension relationship validation.
- Industry and geographic hierarchy checks.

### Technical Challenges

| Challenge | Solution |
|---|---|
| CSV delimiter and conversion errors | Python/Pandas pipe-delimited export |
| SQL Server buffer-pool memory limitations | Batch-based Silver processing |
| Duplicate records during repeated loads | Business-key checks and load validation |
| Inflated totals from overlapping hierarchies | Hierarchy-aware filtering and model review |
| Incorrect percentage display | DAX calculation and formatting review |
| Unexpected slicer behaviour | Relationship and visual interaction checks |

These challenges reinforced the importance of data quality, appropriate aggregation, resource-aware ETL and reporting validation.

For detailed explanations, see [Technical Challenges and Solutions](docs/technical_challenges.md).

---

## 12. Getting Started

### Prerequisites

- Python 3.10 or later.
- Microsoft SQL Server.
- SQL Server Management Studio.
- Power BI Desktop.
- Git.

### Clone the Repository

```bash
git clone https://github.com/sastry-hash/uk-regional-gva-data-warehouse.git

cd uk-regional-gva-data-warehouse
```

### Python Setup

Install Pandas:

```bash
pip install pandas
```

### Data Preparation

The Python script expects a prepared CSV containing the eight analytical fields described in Section 5.

Run the preparation script:

```bash
python python/01_prepare_data.py
```

The script exports a pipe-delimited dataset for SQL Server ingestion.

**Note:** Full reproduction from the original ONS source requires the source-to-prepared-data transformation. The documented Python script assumes the eight-column analytical dataset is already available.

### SQL Server Setup

Execute the SQL scripts in the following order:

1. Database and schema creation.
2. Bronze ingestion.
3. Silver transformations.
4. Gold dimensional model.
5. Analytical SQL views.
6. Stored procedure and indexing.
7. Data validation.

Update local file paths and SQL Server connection settings as required.

### Power BI Setup

1. Open Power BI Desktop.
2. Connect to the SQL Server database.
3. Import the Gold fact and dimension tables.
4. Configure one-to-many relationships.
5. Create the documented DAX measures.
6. Build the three analytical dashboard pages.
7. Validate KPI values and interactive filtering.

---

## 13. Repository Structure

```text
uk-regional-gva-data-warehouse/
│
├── README.md
├── .gitignore
│
├── docs/
│   ├── data_dictionary.md
│   ├── technical_challenges.md
│   └── setup_guide.md
│
├── python/
│   └── 01_prepare_data.py
│
├── sql/
│   ├── 01_database_setup/
│   ├── 02_bronze_load/
│   ├── 03_silver_transform/
│   ├── 04_gold_star_schema/
│   ├── 05_reporting_views/
│   ├── 06_stored_procedure_indexes/
│   └── 07_validation/
│
├── powerbi/
│   ├── README.md
│   └── measures.dax
│
└── screenshots/
    ├── regional_overview.png
    ├── industry_performance.png
    └── covid_impact.png
```

The structure above represents the intended documented project organisation. File availability and exact screenshot names should be verified against the repository before publication.

---

## 14. Key Skills Demonstrated

**Data Engineering:** ETL development, data ingestion, Python data preparation, Medallion Architecture and data quality validation.

**SQL Development:** SQL Server, T-SQL, joins, aggregations, window functions, stored procedures, views and indexing.

**Data Modelling:** Dimensional modelling, star schema, fact and dimension tables, surrogate keys and referential integrity.

**Business Intelligence:** Power BI, DAX, semantic modelling, KPI development, interactive dashboards and analytical reporting.

**Development Practices:** Git, GitHub, technical documentation, version control and reproducible project organisation.

---

## 15. Future Enhancements

Potential improvements include:

- Automated ingestion and scheduled ETL workflows.
- Incremental loading and refresh.
- Automated data-quality testing.
- Cloud-based warehouse deployment.
- Power BI Service publishing.
- Additional economic datasets.
- Expanded regional productivity analysis.
- Improved pipeline monitoring and logging.

---

## 16. Author

**Yanamandra Sri Rama Subrahmanya Sastry**

MSc Data Science & Artificial Intelligence  
University of Liverpool

**Career Interests:** Business Intelligence Developer | Data Analyst | Data Engineering

---

## Data Attribution

**Data Provider:** Office for National Statistics (ONS)

This is an independent technical portfolio project and is not an official ONS reporting product.

The source data and any redistributed extracts remain subject to their applicable licensing and attribution requirements.
