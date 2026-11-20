
/*
=====================================================
PROJECT: UK Regional GVA Data Warehouse
LAYER: SILVER
PURPOSE: Data cleaning, validation and transformation
SOURCE: bronze.RegionalGVA_Raw
TARGET: silver.RegionalGVA_Clean

Technical challenge:
Initial bulk transformation encountered SQL Server
buffer-pool memory limitations.

Solution:
Process records in batches of 5,000 and validate
the final dataset.

Expected records: 44,928
Reporting years: 1998–2023
=====================================================
*/

USE UK_Regional_GVA_DW;
GO

-- STEP 1: Create Silver table

IF OBJECT_ID('silver.RegionalGVA_Clean', 'U') IS NULL
BEGIN
    CREATE TABLE silver.RegionalGVA_Clean
    (
        ITLCode          VARCHAR(30) NOT NULL,
        RegionName       NVARCHAR(200) NOT NULL,
        GeographyLevel   VARCHAR(50) NOT NULL,
        SIC07Code        VARCHAR(30) NOT NULL,
        SIC07Description NVARCHAR(500) NOT NULL,
        IndustryLevel    VARCHAR(50) NOT NULL,
        [Year]           INT NOT NULL,
        GVAMillionGBP    DECIMAL(18,2) NOT NULL
    );
END;
GO

-- STEP 2: Validate source before transformation

SELECT
    COUNT(*) AS BronzeRows,
    MIN([Year]) AS FirstYear,
    MAX([Year]) AS LastYear
FROM bronze.RegionalGVA_Raw;
GO

-- STEP 3: Stage and clean source records

DROP TABLE IF EXISTS #SilverStage;

SELECT
    ROW_NUMBER() OVER (
        ORDER BY ITLCode, SIC07Code, [Year]
    ) AS RowNum,

    LTRIM(RTRIM(ITLCode)) AS ITLCode,
    LTRIM(RTRIM(RegionName)) AS RegionName,
    LTRIM(RTRIM(GeographyLevel)) AS GeographyLevel,
    LTRIM(RTRIM(SIC07Code)) AS SIC07Code,
    LTRIM(RTRIM(SIC07Description)) AS SIC07Description,
    LTRIM(RTRIM(IndustryLevel)) AS IndustryLevel,
    [Year],
    GVAMillionGBP

INTO #SilverStage

FROM
(
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ITLCode, SIC07Code, [Year]
            ORDER BY ITLCode
        ) AS DuplicateRow
    FROM bronze.RegionalGVA_Raw
    WHERE [Year] BETWEEN 1998 AND 2023
      AND GVAMillionGBP IS NOT NULL
      AND GVAMillionGBP >= 0
      AND NULLIF(LTRIM(RTRIM(ITLCode)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(SIC07Code)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(RegionName)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(GeographyLevel)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(SIC07Description)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(IndustryLevel)), '') IS NOT NULL
) AS SourceData

WHERE DuplicateRow = 1;

-- STEP 4: Clear previous Silver data
-- Only run this for a complete reload.

TRUNCATE TABLE silver.RegionalGVA_Clean;

-- STEP 5: Insert records in batches

DECLARE @BatchSize INT = 5000;
DECLARE @StartRow BIGINT = 1;
DECLARE @MaxRow BIGINT;

SELECT @MaxRow = MAX(RowNum)
FROM #SilverStage;

WHILE @StartRow <= ISNULL(@MaxRow, 0)
BEGIN

    INSERT INTO silver.RegionalGVA_Clean
    (
        ITLCode,
        RegionName,
        GeographyLevel,
        SIC07Code,
        SIC07Description,
        IndustryLevel,
        [Year],
        GVAMillionGBP
    )

    SELECT
        ITLCode,
        RegionName,
        GeographyLevel,
        SIC07Code,
        SIC07Description,
        IndustryLevel,
        [Year],
        GVAMillionGBP

    FROM #SilverStage
    WHERE RowNum BETWEEN
        @StartRow AND (@StartRow + @BatchSize - 1);

    SET @StartRow = @StartRow + @BatchSize;

END;

-- STEP 6: Validate final row count

SELECT
    COUNT(*) AS SilverRecordCount
FROM silver.RegionalGVA_Clean;

-- Expected: 44,928 for the validated dataset

-- STEP 7: Check for duplicate records

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

-- Expected: No duplicate rows

-- STEP 8: Check missing values

SELECT
    SUM(CASE WHEN ITLCode IS NULL THEN 1 ELSE 0 END)
        AS MissingRegionCodes,
    SUM(CASE WHEN SIC07Code IS NULL THEN 1 ELSE 0 END)
        AS MissingIndustryCodes,
    SUM(CASE WHEN [Year] IS NULL THEN 1 ELSE 0 END)
        AS MissingYears,
    SUM(CASE WHEN GVAMillionGBP IS NULL THEN 1 ELSE 0 END)
        AS MissingGVA
FROM silver.RegionalGVA_Clean;

-- STEP 9: Check reporting period

SELECT
    MIN([Year]) AS EarliestYear,
    MAX([Year]) AS LatestYear,
    COUNT(DISTINCT [Year]) AS ReportingYears
FROM silver.RegionalGVA_Clean;

-- STEP 10: Check geographic and industry coverage

SELECT
    COUNT(DISTINCT ITLCode) AS GeographicEntities,
    COUNT(DISTINCT SIC07Code) AS IndustryCodes
FROM silver.RegionalGVA_Clean;

-- STEP 11: Check negative GVA values

SELECT COUNT(*) AS NegativeGVARecords
FROM silver.RegionalGVA_Clean
WHERE GVAMillionGBP < 0;

-- STEP 12: Compare Bronze and Silver counts

SELECT
    (SELECT COUNT(*)
     FROM bronze.RegionalGVA_Raw) AS BronzeRows,

    (SELECT COUNT(*)
     FROM silver.RegionalGVA_Clean) AS SilverRows;
GO
