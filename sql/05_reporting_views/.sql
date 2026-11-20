
/*
====================================================
PROJECT: UK Regional GVA Data Warehouse
FILE: 05_reporting_views.sql
LAYER: GOLD

PURPOSE:
Reusable analytical SQL views for regional
economic performance, year-on-year growth,
industry rankings and COVID-19 recovery.

SOURCE:
gold.FactRegionalGVA
gold.DimRegion
gold.DimIndustry
gold.DimDate

GVA UNIT: GBP millions
====================================================
*/

USE UK_Regional_GVA_DW;
GO

-- ================================================
-- VIEW 1: REGIONAL PERFORMANCE
-- ================================================

CREATE OR ALTER VIEW gold.vw_RegionalPerformance
AS

SELECT
    r.ITLCode,
    r.RegionName,
    r.GeographyLevel,

    i.SIC07Code,
    i.SIC07Description,
    i.IndustryLevel,

    d.[Year],

    SUM(f.GVAMillionGBP) AS TotalGVAMillionGBP

FROM gold.FactRegionalGVA f

INNER JOIN gold.DimRegion r
    ON f.RegionKey = r.RegionKey

INNER JOIN gold.DimIndustry i
    ON f.IndustryKey = i.IndustryKey

INNER JOIN gold.DimDate d
    ON f.DateKey = d.DateKey

GROUP BY
    r.ITLCode,
    r.RegionName,
    r.GeographyLevel,
    i.SIC07Code,
    i.SIC07Description,
    i.IndustryLevel,
    d.[Year];
GO


-- ================================================
-- VIEW 2: YEAR-ON-YEAR GROWTH
-- ================================================

CREATE OR ALTER VIEW gold.vw_YearOnYearGrowth
AS

WITH AnnualGVA AS
(
    SELECT
        ITLCode,
        RegionName,
        GeographyLevel,
        SIC07Code,
        SIC07Description,
        IndustryLevel,
        [Year],
        TotalGVAMillionGBP,

        LAG(TotalGVAMillionGBP)
        OVER
        (
            PARTITION BY ITLCode, SIC07Code
            ORDER BY [Year]
        ) AS PreviousYearGVA

    FROM gold.vw_RegionalPerformance
)

SELECT
    ITLCode,
    RegionName,
    GeographyLevel,
    SIC07Code,
    SIC07Description,
    IndustryLevel,
    [Year],

    TotalGVAMillionGBP,
    PreviousYearGVA,

    TotalGVAMillionGBP - PreviousYearGVA
        AS YoYChangeMillionGBP,

    CAST
    (
        100.0 *
        (TotalGVAMillionGBP - PreviousYearGVA)
        / NULLIF(PreviousYearGVA, 0)

        AS DECIMAL(18,2)
    ) AS YoYGrowthPercent

FROM AnnualGVA;
GO


-- ================================================
-- VIEW 3: INDUSTRY PERFORMANCE
-- ================================================

CREATE OR ALTER VIEW gold.vw_IndustryPerformance
AS

SELECT
    ITLCode,
    RegionName,
    GeographyLevel,

    SIC07Code,
    SIC07Description,
    IndustryLevel,

    [Year],
    TotalGVAMillionGBP,

    RANK() OVER
    (
        PARTITION BY ITLCode, [Year], IndustryLevel
        ORDER BY TotalGVAMillionGBP DESC
    ) AS IndustryRank

FROM gold.vw_RegionalPerformance;
GO


-- ================================================
-- VIEW 4: COVID IMPACT AND RECOVERY
-- ================================================

CREATE OR ALTER VIEW gold.vw_CovidRecovery
AS

WITH CovidGVA AS
(
    SELECT
        ITLCode,
        RegionName,
        GeographyLevel,
        SIC07Code,
        SIC07Description,
        IndustryLevel,

        MAX(CASE
            WHEN [Year] = 2019
            THEN TotalGVAMillionGBP
        END) AS GVA_2019,

        MAX(CASE
            WHEN [Year] = 2020
            THEN TotalGVAMillionGBP
        END) AS GVA_2020,

        MAX(CASE
            WHEN [Year] = 2021
            THEN TotalGVAMillionGBP
        END) AS GVA_2021,

        MAX(CASE
            WHEN [Year] = 2022
            THEN TotalGVAMillionGBP
        END) AS GVA_2022

    FROM gold.vw_RegionalPerformance

    WHERE [Year] BETWEEN 2019 AND 2022

    GROUP BY
        ITLCode,
        RegionName,
        GeographyLevel,
        SIC07Code,
        SIC07Description,
        IndustryLevel
)

SELECT
    ITLCode,
    RegionName,
    GeographyLevel,

    SIC07Code,
    SIC07Description,
    IndustryLevel,

    GVA_2019,
    GVA_2020,
    GVA_2021,
    GVA_2022,

    CAST
    (
        100.0 * (GVA_2020 - GVA_2019)
        / NULLIF(GVA_2019, 0)

        AS DECIMAL(18,2)
    ) AS CovidImpactPercent,

    CAST
    (
        100.0 * (GVA_2022 - GVA_2019)
        / NULLIF(GVA_2019, 0)

        AS DECIMAL(18,2)
    ) AS RecoveryVs2019Percent

FROM CovidGVA;
GO


-- ================================================
-- VALIDATION QUERIES
-- ================================================

-- 1. Regional performance sample

SELECT TOP (20) *
FROM gold.vw_RegionalPerformance
ORDER BY [Year] DESC, RegionName;


-- 2. Year-on-year growth sample

SELECT TOP (20) *
FROM gold.vw_YearOnYearGrowth
WHERE PreviousYearGVA IS NOT NULL
ORDER BY [Year] DESC, RegionName;


-- 3. Top 10 divisions in North West, 2023

SELECT TOP (10)
    RegionName,
    SIC07Description,
    TotalGVAMillionGBP,
    IndustryRank

FROM gold.vw_IndustryPerformance

WHERE RegionName = 'North West'
  AND [Year] = 2023
  AND IndustryLevel = 'DIVISION'

ORDER BY IndustryRank, SIC07Code;


-- 4. COVID impact for North West industries

SELECT TOP (20)
    RegionName,
    SIC07Description,
    GVA_2019,
    GVA_2020,
    GVA_2022,
    CovidImpactPercent,
    RecoveryVs2019Percent

FROM gold.vw_CovidRecovery

WHERE RegionName = 'North West'
  AND IndustryLevel = 'DIVISION'

ORDER BY CovidImpactPercent ASC;


-- 5. Check view record counts

SELECT
    (SELECT COUNT(*)
     FROM gold.vw_RegionalPerformance)
        AS RegionalPerformanceRows,

    (SELECT COUNT(*)
     FROM gold.vw_YearOnYearGrowth)
        AS YearOnYearRows,

    (SELECT COUNT(*)
     FROM gold.vw_IndustryPerformance)
        AS IndustryPerformanceRows,

    (SELECT COUNT(*)
     FROM gold.vw_CovidRecovery)
        AS CovidRecoveryRows;
GO
