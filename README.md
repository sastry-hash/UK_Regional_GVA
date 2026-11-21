UK Regional GVA Data Warehouse & Power BI Analytics
End-to-End Business Intelligence Portfolio Project | Python · Pandas · SQL Server · T-SQL · Power BI · DAX

An end-to-end business intelligence project that prepares Office for National Statistics (ONS) regional Gross Value Added (GVA) data, models it in a SQL Server data warehouse, and presents regional and industry-level economic insights through interactive Power BI reports.

Reporting period: 1998–2023
Source: Office for National Statistics (ONS)
Architecture: Bronze–Silver–Gold (Medallion)
Analytical model: Dimensional star schema
Measure: Gross Value Added (£ million)
Project scope: An independent technical portfolio project, not an official ONS reporting product. The documentation describes the project's implemented workflow and intended reporting structure. Reproduction from the original ONS files requires an additional source-to-prepared-data transformation step.

Contents
1. Project overview
2. Power BI dashboards
3. Business problem and objectives
4. Technology stack
5. Data source and structure
6. Data warehouse architecture
7. Dimensional star schema
8. ETL implementation
9. SQL analytics and DAX
10. Data quality and technical challenges
11. Getting started
12. Repository structure
13. Skills demonstrated
14. Future enhancements
15. Author and attribution
1. Project overview
This project analyses economic performance across UK geographic areas and SIC07 industries using ONS GVA data for 1998–2023. It combines Python-based preparation, SQL Server warehousing, dimensional modelling, and Power BI reporting in a layered analytical workflow.

The Gold layer contains a central GVA fact table connected to Region, Industry, and Date dimensions. The reporting layer supports:
- Comparisons of regional economic output.
- Historical GVA trends and year-on-year growth.
- SIC07 industry-level analysis.
- Assessment of the initial COVID-19 impact and subsequent recovery.
- Interactive exploration by reporting year, geographic area, and industry.
A key modelling consideration is avoiding double counting: both the geographic and industry classifications include hierarchical aggregates that must not be summed alongside their constituent records.
2. Power BI dashboards
The reporting solution is documented as three analytical report pages. Add the screenshots from the repository to the image references below once their exact filenames are confirmed.
Dashboard 1 — Regional Economic Overview
Purpose: Understand economic output and growth across geographic areas.
- Total GVA and previous-year GVA KPIs.
- Year-on-year growth percentage.
- Regional comparisons and historical trends.
- Interactive year and region slicers.
<!-- Uncomment and update the path after confirming the screenshot filename. -->
<!-- ![Regional Economic Overview](screenshots/regional_overview.png) -->Dashboard 2 — Industry Performance
Purpose: Explore the contribution and growth of SIC07 industries.
- Top-performing industry divisions.
- Industry GVA comparisons and time-series analysis.
- Region and industry filters.
- SIC07 classification-level exploration.
<!-- ![Industry Performance](screenshots/industry_performance.png) -->Dashboard 3 — COVID-19 Impact and Recovery
Purpose: Compare pre-pandemic economic output with the initial shock and recovery period.
- COVID impact percentage (2019 to 2020).
- Recovery relative to 2019.
- Comparisons covering 2019–2022.
- Geographic and industry-level filtering.
<!-- ![COVID-19 Impact and Recovery](screenshots/covid_impact.png) -->See the [Power BI folder](power_bi/) for reporting documentation and DAX assets.
3. Business problem and objectives
ONS regional GVA data spans multiple years, geographic hierarchies, and industry classifications. Direct aggregation without a consistent analytical model can lead to duplicated totals, inconsistent growth metrics, and difficult-to-maintain reporting.

Objectives
1. Prepare and profile the analytical dataset with Python and Pandas.
2. Ingest and transform records in SQL Server using Bronze, Silver, and Gold layers.
3. Validate record counts, business keys, data types, and year ranges.
4. Design a reusable dimensional star schema.
5. Develop SQL views, stored procedures, and analytical calculations.
6. Define DAX measures for GVA and growth analysis.
7. Present findings in interactive Power BI reports.
8. Document technical decisions, issues, and reproducibility steps in GitHub.
4. Technology stack
Technology	Application
Python, Pandas	Data profiling, preparation, validation, and export
Google Colab	Python development environment
Microsoft SQL Server	Relational data warehouse
SQL Server Management Studio (SSMS)	SQL development and administration
T-SQL	Ingestion, transformation, validation, and analytics
SQL window functions	Growth calculations and rankings
Power BI Desktop	Semantic model and interactive reports
DAX	KPIs, growth rates, and period comparisons
Git and GitHub	Version control and technical documentation


5. Data source and structure
Provider: Office for National Statistics (ONS)
Dataset: UK Regional Gross Value Added (GVA)
Years: 1998–2023 (26 reporting years)
Unit: £ million

The project's documentation records the following characteristics for a prepared analytical extract:
Attribute	Documented value
Prepared records	44,928
Geographic entities	16
SIC07 industry codes	108
Reporting years	26
First / last year	1998 / 2023


Validation note: These figures describe a documented prepared extract, not necessarily the final Silver or Gold row counts. Confirm the final counts against the current SQL tables before publishing them as final warehouse statistics.

Analytical fields
Field	Meaning
ITLCode	Geographic identifier
RegionName	Geographic area name
GeographyLevel	Geographic hierarchy classification
SIC07Code	Industry classification identifier
SIC07Description	Industry description
IndustryLevel	Industry hierarchy level
Year	Reporting year
GVAMillionGBP	Gross Value Added in £ million


Aggregation safeguards
Industry records can include TOTAL, SECTOR, SECTION, SUBSECTION, and DIVISION levels. Summing across these levels would count the same underlying economic activity multiple times. Geographic aggregates must likewise be separated from their constituent areas.

Reporting rule: Select a consistent, non-overlapping geographic level and industry level for each aggregation. Validate headline totals against the corresponding source aggregates before interpreting the results.
6. Data warehouse architecture
The pipeline follows a Bronze–Silver–Gold approach:
ONS Regional GVA source
          |
          v
   Python / Pandas
   Prepare and profile
          |
          v
   BRONZE: Raw ingestion
          |
          v
   SILVER: Clean and validate
          |
          v
   GOLD: Star schema
          |
          v
   Power BI semantic model
          |
          v
   Interactive dashboards
Bronze — ingestion
Documented table: bronze.RegionalGVA_Raw
- Loads the prepared source extract into SQL Server.
- Preserves ingested records for traceability.
- Supports source-to-database row-count reconciliation.
- Provides a baseline for downstream validation.
Silver — transformation
Documented table: silver.RegionalGVA_Clean
- Standardises whitespace and identifiers.
- Validates numeric values and data types.
- Checks missing values and duplicate business keys.
- Restricts reporting years to the intended range.
- Prepares consistent records for dimensional loading.
Batch-based processing was introduced after SQL Server memory limitations affected an earlier transformation attempt.
Gold — analytical model
Documented tables:
- gold.DimRegion
- gold.DimIndustry
- gold.DimDate
- gold.FactRegionalGVA
The Gold layer separates descriptive dimensions from numeric GVA observations, enabling consistent joins and reusable reporting logic.
7. Dimensional star schema
                   gold.DimDate
                        |
                        | 1-to-many
                        v
 gold.DimRegion --> gold.FactRegionalGVA <-- gold.DimIndustry
       1-to-many                         1-to-many
Table	Key	Purpose
gold.DimRegion	RegionKey	Geographic identifiers, names, and hierarchy
gold.DimIndustry	IndustryKey	SIC07 codes, descriptions, and hierarchy
gold.DimDate	DateKey	Reporting year attributes
gold.FactRegionalGVA	GVAKey	GVA observations and dimensional foreign keys


Fact table fields: GVAKey, RegionKey, IndustryKey, DateKey, GVAMillionGBP.

Fact grain: One geographic code × one SIC07 industry code × one reporting year, subject to the uniqueness of the loaded business keys.

Each dimension has a one-to-many relationship with the fact table. In Power BI, these relationships enable dimension-driven filtering and consistent measures.
Model integrity: Confirm unique dimension keys, valid foreign keys, and the absence of unintended duplicate fact-grain combinations. Because hierarchical totals are present, a technically valid star schema alone does not prevent double counting; measures and filters must respect the classification levels.

8. ETL implementation
Stage 1 — Python preparation
Python and Pandas support dataset profiling, data-type inspection, missing-value checks, duplicate detection, year validation, and preparation for database ingestion.

A pipe-delimited export was adopted to address CSV delimiter and import issues encountered during development.
Stage 2 — Bronze ingestion
The prepared extract is loaded into SQL Server with T-SQL. Record counts and expected columns are checked after ingestion.
Stage 3 — Silver transformation
T-SQL standardises and validates records for downstream modelling. The transformation was adapted to use batches after an initial memory-related failure.
Stage 4 — Gold loading
Distinct region, industry, and reporting-year attributes populate dimension tables. The fact load maps source business identifiers to dimensional surrogate keys.
Stage 5 — SQL reporting objects
Analytical views, a parameterised stored procedure, and indexes support querying and reporting.
Stage 6 — Power BI integration
Power BI imports the Gold model and applies relationships, DAX measures, slicers, and interactive visualisations.
9. SQL analytics and DAX
SQL analytical objects
The project documentation describes these objects; confirm their definitions and names against the SQL scripts in the repository.
Object	Purpose
gold.vw_RegionalPerformance	Regional and industry GVA reporting
gold.vw_YearOnYearGrowth	Annual growth using LAG
gold.vw_IndustryPerformance	Industry rankings using RANK
gold.vw_CovidRecovery	COVID impact and recovery comparisons
gold.usp_GetRegionalGVA	Parameterised regional retrieval


Indexes on fact-table dimension keys are intended to support common query patterns.
DAX measures
Measure	Business meaning
Total GVA	GVA for the selected filter context
Previous Year GVA	GVA for the preceding year
YoY GVA Change	Absolute annual change
YoY Growth %	Annual percentage change
Growth Since 1998 %	Growth relative to the 1998 baseline
COVID Impact %	Change from 2019 to 2020
Recovery vs 2019 %	Change relative to 2019, evaluated for 2022


The documented DAX implementation uses functions such as CALCULATE, DIVIDE, VAR, and REMOVEFILTERS. Refer to the DAX file in the repository for the actual definitions.
Measure interpretation: The totals and percentages are meaningful only when the selected geographic and industry levels are non-overlapping. Percentage measures should also be checked for zero or missing baseline values.

10. Data quality and technical challenges
Validation approach
- Reconcile row counts between ingestion and transformation stages.
- Check missing and invalid values.
- Identify duplicate business keys.
- Verify the 1998–2023 reporting range.
- Validate dimension key uniqueness and fact-to-dimension mappings.
- Review geographic and industry hierarchy selections.
- Reconcile selected Power BI KPI values against SQL and source figures.
Problems encountered and resolutions
Challenge	Approach
CSV delimiter and conversion errors	Prepared a pipe-delimited export using Python/Pandas
SQL Server memory limitations	Introduced batch-based Silver processing
Duplicate records after repeated loads	Added business-key and load validation checks
Inflated economic totals	Reviewed hierarchy-aware filtering and aggregation
Incorrect percentage display	Reviewed DAX calculations and formatting
Unexpected slicer results	Checked relationships and visual interactions


These issues illustrate why data quality, hierarchy-aware aggregation, resource-aware ETL, and end-to-end reporting validation matter in BI development.

For more context, see the [documentation folder](docs/).
11. Getting started
Prerequisites
- Python 3.10 or later and Pandas.
- Microsoft SQL Server.
- SQL Server Management Studio (SSMS).
- Power BI Desktop.
- Git.
Clone the repository
git clone https://github.com/sastry-hash/uk-regional-gva-data-warehouse.git
cd uk-regional-gva-data-warehouse
Prepare the data
Install Pandas:
pip install pandas
The documented preparation script expects a dataset containing the eight analytical fields listed in Section 5. Run:
python python/01_prepare_data.py
The script is documented as producing a pipe-delimited export for SQL Server ingestion. Review its configured input and output paths before execution. The original ONS-to-eight-column preparation step is not included in this reproduction path.
Set up SQL Server
Run the scripts in logical pipeline order:
1. Database and schema setup.
2. Bronze ingestion.
3. Silver transformation.
4. Gold star-schema creation and loading.
5. Reporting views.
6. Stored procedure and indexes.
7. Validation checks.
Update SQL Server database names, local data paths, and any environment-specific settings before running the scripts. Consult the actual filenames in [`sql/`](sql/) rather than assuming a particular directory layout.
Configure Power BI
1. Open Power BI Desktop and connect to SQL Server.
2. Import the Gold fact and dimension tables.
3. Check one-to-many relationships and filter direction.
4. Add the documented DAX measures.
5. Configure the three report pages and their slicers.
6. Verify headline totals, growth measures, and hierarchy filters against SQL results.
Reproducibility limitation: The repository's documented workflow starts from an already prepared analytical extract. Full reconstruction from raw ONS releases requires the upstream preparation logic and source files or download instructions.
12. Repository structure
The structure below is a recommended organisation aligned with the updated top-level folders. Verify exact filenames and paths against the live repository.
uk-regional-gva-data-warehouse/
|
|-- README.md
|-- .gitignore
|-- docs/
|   |-- data_dictionary.md
|   |-- technical_challenges.md
|   `-- setup_guide.md
|-- python/
|   `-- 01_prepare_data.py
|-- sql/
|   |-- 01_database_setup.sql
|   |-- 02_bronze_load.sql
|   |-- 03_silver_transform.sql
|   |-- 04_gold_star_schema.sql
|   |-- 05_reporting_views.sql
|   |-- 06_stored_procedure_indexes.sql
|   `-- 07_validation.sql
|-- power_bi/
|   |-- Power_bi_README.md
|   `-- measures.dax
`-- screenshots/
    |-- regional_overview.png
    |-- industry_performance.png
    `-- covid_impact.png
The top-level docs/, power_bi/, python/, screenshots/, and sql/ folders are visible in the latest repository screenshot. Some nested filenames shown above are illustrative or documented rather than independently verified. In particular, measures.dax was still visible at the repository root in that screenshot; moving it into power_bi/ is a recommended cleanup.
13. Skills demonstrated
Data engineering: ETL, Python preparation, layered warehouse architecture, data profiling, and validation.

SQL development: SQL Server, T-SQL, joins, transformations, aggregations, window functions, views, stored procedures, and indexing.

Data modelling: Star schemas, fact and dimension tables, surrogate keys, relationship integrity, and hierarchy-aware reporting.

Business intelligence: Power BI, DAX, semantic modelling, KPI definitions, historical comparisons, and interactive dashboards.

Engineering practice: Git, GitHub, technical documentation, troubleshooting, and reproducibility considerations.
14. Future enhancements
- Automate ingestion and scheduled ETL runs.
- Introduce incremental loading and refresh.
- Add automated data-quality tests and pipeline logging.
- Package the complete raw-source preparation process for reproducibility.
- Deploy the warehouse to a cloud environment.
- Publish and maintain reports in Power BI Service.
- Extend the analysis with productivity and additional economic indicators.
15. Author and attribution
Yanamandra Sri Rama Subrahmanya Sastry
MSc Data Science & Artificial Intelligence — University of Liverpool
Career interests: Business Intelligence Developer · Data Analyst · Data Engineering

Data attribution: Office for National Statistics (ONS). This is an independent portfolio project and is not an official ONS reporting product. Source data and any redistributed extracts remain subject to the applicable ONS licensing and attribution requirements.
