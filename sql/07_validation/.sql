
/*
====================================================
PROJECT: UK Regional GVA Data Warehouse
FILE: 07_validation.sql

PURPOSE:
Validate data quality across Bronze, Silver
and Gold layers.

CHECKS:
1. Row count reconciliation
2. Missing values
3. Duplicate records
4. Reporting year coverage
5. Geographic and industry coverage
6. Referential integrity
7. Fact-to-Silver reconciliation
8. Hierarchy and aggregation checks

Expected source records: 44,928
Reporting years: 1998–2023
====================================================
*/

USE UK_Regional_GVA_DW;
GO

-- ================================================
-- 1. BRONZE, SILVER AND GOLD ROW COUNTS
-- ================================================

SELECT
    'Bronze' AS DataLayer,
    COUNT(*) AS RecordCount
FROM bronze.RegionalGVA_Raw

UNION ALL

SELECT
    'Silver',
    COUNT(*)
FROM silver.RegionalGVA_Clean

UNION ALL

SELECT
    'Gold Fact',
    COUNT(*)
FROM gold.FactRegionalGVA;
GO

-- Expected: 44,928 records per layer
-- Investigate differences before reporting success.


-- ================================================
-- 2. MISSING VALUES IN SILVER
-- ================================================

SELECT
    SUM(CASE WHEN ITLCode IS NULL
        OR LTRIM(RTRIM(ITLCode)) = ''
        THEN 1 ELSE 0 END) AS MissingRegion,

    SUM(CASE WHEN SIC07Code IS NULL
        OR LTRIM(RTRIM(SIC07Code)) = ''
        THEN 1 ELSE 0 END) AS MissingIndustry,

    SUM(CASE WHEN [Year] IS NULL
        THEN 1 ELSE 0 END) AS MissingYear,

    SUM(CASE WHEN GVAMillionGBP IS NULL
        THEN 1 ELSE 0 END) AS MissingGVA

FROM silver.RegionalGVA_Clean;
GO


-- ================================================
-- 3. DUPLICATE BUSINESS KEYS
-- ================================================

SELECT
    ITLCode,
    SIC07Code,
    [Year],
    COUNT(*) AS DuplicateCount

FROM silver.RegionalGVA_Clean

GROUP BY
    ITLCode,
    SIC07Code,
    [Year]

HAVING COUNT(*) > 1;
GO

-- Expected: Zero duplicate business keys


-- ================================================
-- 4. YEAR COVERAGE
-- ================================================

SELECT
    MIN([Year]) AS EarliestYear,
    MAX([Year]) AS LatestYear,
    COUNT(DISTINCT [Year]) AS DistinctYears

FROM silver.RegionalGVA_Clean;
GO

-- Expected:
-- EarliestYear = 1998
-- LatestYear = 2023
-- DistinctYears = 26


-- ================================================
-- 5. YEAR-BY-YEAR RECORD COUNTS
-- ================================================

SELECT
    [Year],
    COUNT(*) AS RecordCount

FROM silver.RegionalGVA_Clean

GROUP BY [Year]
ORDER BY [Year];
GO


-- ================================================
-- 6. GEOGRAPHIC AND INDUSTRY COVERAGE
-- ================================================

SELECT
    COUNT(DISTINCT ITLCode) AS RegionCount,
    COUNT(DISTINCT SIC07Code) AS IndustryCount

FROM silver.RegionalGVA_Clean;
GO

-- Expected:
-- Regions = 16
-- Industry codes = 108


-- ================================================
-- 7. NEGATIVE GVA VALUES
-- ================================================

SELECT COUNT(*) AS NegativeGVARecords

FROM silver.RegionalGVA_Clean

WHERE GVAMillionGBP < 0;
GO


-- ================================================
-- 8. GOLD DIMENSION COUNTS
-- ================================================

SELECT
    (SELECT COUNT(*)
     FROM gold.DimRegion) AS RegionDimensions,

    (SELECT COUNT(*)
     FROM gold.DimIndustry) AS IndustryDimensions,

    (SELECT COUNT(*)
     FROM gold.DimDate) AS DateDimensions,

    (SELECT COUNT(*)
     FROM gold.FactRegionalGVA) AS FactRecords;
GO


-- ================================================
-- 9. FACT TABLE DUPLICATE CHECK
-- ================================================

SELECT
    RegionKey,
    IndustryKey,
    DateKey,
    COUNT(*) AS DuplicateCount

FROM gold.FactRegionalGVA

GROUP BY
    RegionKey,
    IndustryKey,
    DateKey

HAVING COUNT(*) > 1;
GO


-- ================================================
-- 10. REFERENTIAL INTEGRITY
-- ================================================

SELECT COUNT(*) AS OrphanFactRecords

FROM gold.FactRegionalGVA f

LEFT JOIN gold.DimRegion r
    ON f.RegionKey = r.RegionKey

LEFT JOIN gold.DimIndustry i
    ON f.IndustryKey = i.IndustryKey

LEFT JOIN gold.DimDate d
    ON f.DateKey = d.DateKey

WHERE r.RegionKey IS NULL
   OR i.IndustryKey IS NULL
   OR d.DateKey IS NULL;
GO

-- Expected: 0 orphan records


-- ================================================
-- 11. SILVER-TO-GOLD VALUE RECONCILIATION
-- ================================================

WITH SilverTotals AS
(
    SELECT
        ITLCode,
        SIC07Code,
        [Year],
        SUM(GVAMillionGBP) AS SilverGVA

    FROM silver.RegionalGVA_Clean

    GROUP BY
        ITLCode,
        SIC07Code,
        [Year]
),

GoldTotals AS
(
    SELECT
        r.ITLCode,
        i.SIC07Code,
        d.[Year],
        SUM(f.GVAMillionGBP) AS GoldGVA

    FROM gold.FactRegionalGVA f

    INNER JOIN gold.DimRegion r
        ON f.RegionKey = r.RegionKey

    INNER JOIN gold.DimIndustry i
        ON f.IndustryKey = i.IndustryKey

    INNER JOIN gold.DimDate d
        ON f.DateKey = d.DateKey

    GROUP BY
        r.ITLCode,
        i.SIC07Code,
        d.[Year]
)

SELECT
    COALESCE(s.ITLCode, g.ITLCode) AS ITLCode,
    COALESCE(s.SIC07Code, g.SIC07Code) AS SIC07Code,
    COALESCE(s.[Year], g.[Year]) AS [Year],
    s.SilverGVA,
    g.GoldGVA

FROM SilverTotals s

FULL OUTER JOIN GoldTotals g
    ON s.ITLCode = g.ITLCode
   AND s.SIC07Code = g.SIC07Code
   AND s.[Year] = g.[Year]

WHERE s.ITLCode IS NULL
   OR g.ITLCode IS NULL
   OR s.SilverGVA <> g.GoldGVA;
GO

-- Expected: Zero mismatched records


-- ================================================
-- 12. INSPECT INDUSTRY HIERARCHY
-- ================================================

SELECT
    IndustryLevel,
    COUNT(*) AS IndustryCodes

FROM gold.DimIndustry

GROUP BY IndustryLevel
ORDER BY IndustryLevel;
GO


-- ================================================
-- 13. INSPECT GEOGRAPHIC HIERARCHY
-- ================================================

SELECT
    GeographyLevel,
    COUNT(*) AS GeographicEntities

FROM gold.DimRegion

GROUP BY GeographyLevel
ORDER BY GeographyLevel;
GO


-- ================================================
-- 14. INSPECT TOTAL-LEVEL INDUSTRY CODES
-- ================================================

SELECT
    SIC07Code,
    SIC07Description,
    IndustryLevel

FROM gold.DimIndustry

WHERE IndustryLevel = 'TOTAL'

ORDER BY SIC07Code;
GO

-- Important:
-- Identify the correct overall GVA code.
-- Do not automatically sum every TOTAL-level code.


-- ================================================
-- 15. SAMPLE REGIONAL GVA VALIDATION
-- ================================================

SELECT
    r.RegionName,
    i.SIC07Code,
    i.SIC07Description,
    d.[Year],
    f.GVAMillionGBP

FROM gold.FactRegionalGVA f

INNER JOIN gold.DimRegion r
    ON f.RegionKey = r.RegionKey

INNER JOIN gold.DimIndustry i
    ON f.IndustryKey = i.IndustryKey

INNER JOIN gold.DimDate d
    ON f.DateKey = d.DateKey

WHERE r.RegionName = 'North West'
  AND d.[Year] = 2023
  AND i.IndustryLevel = 'TOTAL'

ORDER BY i.SIC07Code;
GO
