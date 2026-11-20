# Power BI — UK Regional GVA Analytics Dashboard

## 1. Overview

This Power BI reporting solution forms the analytical and visualisation layer of the **UK Regional Gross Value Added (GVA) Data Warehouse** project.

The dashboard analyses regional economic performance across the United Kingdom using Office for National Statistics (ONS) GVA data covering **1998–2023**.

The reporting solution enables users to:

- Explore economic output across regions and industries.
- Analyse historical GVA trends and year-on-year growth.
- Compare the economic performance of different regions.
- Identify high-performing industry divisions.
- Examine the economic impact of COVID-19.
- Evaluate post-pandemic economic recovery.

The dashboard is supported by a SQL Server data warehouse following a Bronze–Silver–Gold architecture.

---

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| Microsoft Power BI Desktop | Dashboard development and visualisation |
| SQL Server | Data storage and analytical processing |
| Power Query | Data import and preparation |
| DAX | KPI calculations and time-based analysis |
| SQL | Data modelling, transformations and analytical views |
| GitHub | Source control and project documentation |

---

## 3. Data Architecture

The Power BI dashboard consumes analytics-ready data from the Gold layer of the SQL Server data warehouse.

**Data flow:**

ONS GVA Source Data → Python Preparation → SQL Server Bronze → Silver → Gold → Power BI

### Gold Layer Tables

The semantic model is designed around four tables.

**Fact Table**

`gold_FactRegionalGVA`

Contains GVA observations and foreign keys connecting each record to its region, industry and reporting year.

Key columns:

- GVAKey
- RegionKey
- IndustryKey
- DateKey
- GVAMillionGBP

**Dimension Tables**

`gold_DimRegion`

Contains geographic information, including region codes, region names and geographic hierarchy levels.

`gold_DimIndustry`

Contains SIC07 industry classifications, descriptions and industry hierarchy levels.

`gold_DimDate`

Contains reporting-year information for historical analysis.

---

## 4. Star Schema and Relationships

The Power BI semantic model follows a dimensional star schema.

| Dimension | Fact relationship | Cardinality |
|---|---|---|
| DimRegion | RegionKey | One-to-many |
| DimIndustry | IndustryKey | One-to-many |
| DimDate | DateKey | One-to-many |

The relationships use single-direction filtering from dimension tables to the fact table.

This design supports consistent filtering, reusable calculations and analytical reporting across regions, industries and years.

---

## 5. DAX Measures

The dashboard uses DAX measures to calculate economic performance indicators.

### Core Measures

- Total GVA (£m)
- Total GVA (£bn)
- Previous Year GVA
- YoY GVA Change
- YoY Growth %
- Growth Since 1998 %

### COVID-19 Analysis

- COVID Impact %
- Recovery vs 2019 %

The measure definitions are documented in [`measures.dax`](measures.dax).

Percentage measures are formatted as percentages, while GVA values are presented in millions or billions of pounds.

---

## 6. Dashboard Pages

### Page 1 — Regional Overview

**Purpose:** Provide a high-level overview of regional economic performance.

Key components:

- Total GVA KPI cards.
- Year-on-year growth indicators.
- Historical GVA trend line chart.
- Regional GVA comparisons.
- Region and reporting-year slicers.

This page supports comparisons of regional economic output and historical growth.

### Page 2 — Industry Performance

**Purpose:** Analyse economic contributions from different industries.

Key components:

- Industry-level GVA comparisons.
- Top-performing SIC07 industry divisions.
- Industry GVA trend charts.
- Region and industry slicers.
- Reporting-year filtering.

This page helps identify major industry contributors and compare economic activity across sectors.

Industry comparisons should use consistent SIC07 classification levels to avoid double counting.

### Page 3 — COVID-19 Impact and Recovery

**Purpose:** Examine changes in economic output during and after the COVID-19 pandemic.

Key components:

- COVID Impact % KPI.
- Recovery vs 2019 % KPI.
- Regional comparisons of economic decline.
- Industry-level recovery analysis.
- Historical GVA comparisons for 2019–2022.

The dashboard uses 2019 as the pre-pandemic baseline.

COVID Impact % compares 2020 with 2019, while Recovery vs 2019 % compares 2022 with 2019.

---

## 7. Interactive Filtering

The dashboard supports interactive analysis using Power BI slicers and visual interactions.

Filters include:

- Region
- Reporting year
- Industry classification
- SIC07 industry descriptions

These controls allow users to explore economic performance at different levels of detail.

---

## 8. Data Quality and Validation

Data validation was performed during SQL Server processing and Power BI model development.

Validation activities include:

- Checking row counts across warehouse layers.
- Identifying missing values and duplicate records.
- Verifying reporting-year coverage.
- Validating fact-to-dimension relationships.
- Reviewing GVA calculations and unit conversions.
- Checking the effect of geographic and industry hierarchies on totals.
- Verifying percentage formatting and slicer interactions.

The underlying SQL validation queries are documented in [`../sql/07_validation.sql`](../sql/07_validation.sql).

---

## 9. Technical Challenges

### CSV Import and Delimiter Issues

The source data contained industry descriptions with embedded commas, which created problems during SQL Server bulk ingestion.

**Approach:** Python and Pandas were used to prepare a pipe-delimited dataset for more reliable loading.

### SQL Server Memory Limitations

Large Silver-layer insert operations encountered SQL Server memory limitations.

**Approach:** Batch-based processing was introduced to reduce the amount of data processed in a single operation.

### Incorrect Aggregation Across Hierarchies

The GVA dataset includes multiple industry and geographic aggregation levels.

Summing overlapping hierarchy levels can inflate reported economic output.

**Approach:** Industry and geographic classifications were retained in dimension tables to support appropriate filtering and validation.

### Power BI Measure Formatting

Percentage measures initially required correction to display their values accurately.

**Approach:** DAX calculations and Power BI measure formatting were reviewed to distinguish decimal ratios from displayed percentages.

---

## 10. Dashboard Screenshots

Dashboard screenshots will be stored in the `screenshots/` directory.

Planned files:

- `regional_overview.png`
- `industry_performance.png`
- `covid_impact.png`
- `star_schema.png`

These images will provide a visual overview of the dashboard and its underlying data model.

---

## 11. Business Value

This project demonstrates how publicly available economic data can be transformed into a structured analytical solution.

The reporting solution supports:

- Regional economic comparisons.
- Historical trend analysis.
- Industry performance monitoring.
- COVID-19 impact assessment.
- Data-driven reporting and exploration.

The project also demonstrates practical skills in SQL Server, dimensional modelling, ETL, Power BI, DAX, data validation and technical documentation.

---

## 12. Project Scope

This is an independent technical portfolio project developed for practical learning and demonstration of business intelligence and data warehousing skills.

It is not an official ONS reporting product.

**Data source:** Office for National Statistics (ONS), UK Regional Gross Value Added datasets.
