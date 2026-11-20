
/*
====================================================
PROJECT: UK Regional GVA Data Warehouse
LAYER: GOLD
PURPOSE: Dimensional Star Schema

SOURCE:
    silver.RegionalGVA_Clean

DIMENSIONS:
    gold.DimRegion
    gold.DimIndustry
    gold.DimDate

FACT:
    gold.FactRegionalGVA

GRAIN:
    One record per ITLCode, SIC07Code and Year

IMPORTANT:
    The source contains overlapping geographic
    and industry hierarchy levels.
    Filter the relevant hierarchy before
    aggregating GVA values.
====================================================
*/

USE UK_Regional_GVA_DW;
GO

-- ================================================
-- STEP 1: CREATE REGION DIMENSION
-- ================================================

IF OBJECT_ID('gold.DimRegion', 'U') IS NULL
BEGIN
    CREATE TABLE gold.DimRegion
    (
        RegionKey INT IDENTITY(1,1) PRIMARY KEY,
        ITLCode VARCHAR(30) NOT NULL UNIQUE,
        RegionName NVARCHAR(200) NOT NULL,
        GeographyLevel VARCHAR(50) NOT NULL
    );
END;
GO

-- ================================================
-- STEP 2: CREATE INDUSTRY DIMENSION
-- ================================================

IF OBJECT_ID('gold.DimIndustry', 'U') IS NULL
BEGIN
    CREATE TABLE gold.DimIndustry
    (
        IndustryKey INT IDENTITY(1,1) PRIMARY KEY,
        SIC07Code VARCHAR(30) NOT NULL UNIQUE,
        SIC07Description NVARCHAR(500) NOT NULL,
        IndustryLevel VARCHAR(50) NOT NULL
    );
END;
GO

-- ================================================
-- STEP 3: CREATE DATE DIMENSION
-- ================================================

IF OBJECT_ID('gold.DimDate', 'U') IS NULL
BEGIN
    CREATE TABLE gold.DimDate
    (
        DateKey INT IDENTITY(1,1) PRIMARY KEY,
        [Year] INT NOT NULL UNIQUE
    );
END;
GO

-- ================================================
-- STEP 4: CREATE FACT TABLE
-- ================================================

IF OBJECT_ID('gold.FactRegionalGVA', 'U') IS NULL
BEGIN
    CREATE TABLE gold.FactRegionalGVA
    (
        GVAKey BIGINT IDENTITY(1,1) PRIMARY KEY,

        RegionKey INT NOT NULL,
        IndustryKey INT NOT NULL,
        DateKey INT NOT NULL,

        GVAMillionGBP DECIMAL(18,2) NOT NULL,

        CONSTRAINT FK_GVA_Region
            FOREIGN KEY (RegionKey)
            REFERENCES gold.DimRegion(RegionKey),

        CONSTRAINT FK_GVA_Industry
            FOREIGN KEY (IndustryKey)
            REFERENCES gold.DimIndustry(IndustryKey),

        CONSTRAINT FK_GVA_Date
            FOREIGN KEY (DateKey)
            REFERENCES gold.DimDate(DateKey),

        CONSTRAINT UQ_GVA_Grain
            UNIQUE (RegionKey, IndustryKey, DateKey)
    );
END;
GO

-- ================================================
-- STEP 5: LOAD REGION DIMENSION
-- ================================================

INSERT INTO gold.DimRegion
(
    ITLCode,
    RegionName,
    GeographyLevel
)
SELECT DISTINCT
    s.ITLCode,
    s.RegionName,
    s.GeographyLevel
FROM silver.RegionalGVA_Clean s
WHERE NOT EXISTS
(
    SELECT 1
    FROM gold.DimRegion r
    WHERE r.ITLCode = s.ITLCode
);
GO

-- ================================================
-- STEP 6: LOAD INDUSTRY DIMENSION
-- ================================================

INSERT INTO gold.DimIndustry
(
    SIC07Code,
    SIC07Description,
    IndustryLevel
)
SELECT DISTINCT
    s.SIC07Code,
    s.SIC07Description,
    s.IndustryLevel
FROM silver.RegionalGVA_Clean s
WHERE NOT EXISTS
(
    SELECT 1
    FROM gold.DimIndustry i
    WHERE i.SIC07Code = s.SIC07Code
);
GO

-- ================================================
-- STEP 7: LOAD DATE DIMENSION
-- ================================================

INSERT INTO gold.DimDate ([Year])
SELECT DISTINCT s.[Year]
FROM silver.RegionalGVA_Clean s
WHERE NOT EXISTS
(
    SELECT 1
    FROM gold.DimDate d
    WHERE d.[Year] = s.[Year]
);
GO

-- ================================================
-- STEP 8: LOAD FACT TABLE
-- ================================================

INSERT INTO gold.FactRegionalGVA
(
    RegionKey,
    IndustryKey,
    DateKey,
    GVAMillionGBP
)
SELECT
    r.RegionKey,
    i.IndustryKey,
    d.DateKey,
    s.GVAMillionGBP
FROM silver.RegionalGVA_Clean s

INNER JOIN gold.DimRegion r
    ON s.ITLCode = r.ITLCode

INNER JOIN gold.DimIndustry i
    ON s.SIC07Code = i.SIC07Code

INNER JOIN gold.DimDate d
    ON s.[Year] = d.[Year]

WHERE NOT EXISTS
(
    SELECT 1
    FROM gold.FactRegionalGVA f
    WHERE f.RegionKey = r.RegionKey
      AND f.IndustryKey = i.IndustryKey
      AND f.DateKey = d.DateKey
);
GO

-- ================================================
-- STEP 9: VALIDATE DIMENSION COUNTS
-- ================================================

SELECT
    (SELECT COUNT(*)
     FROM gold.DimRegion) AS RegionCount,

    (SELECT COUNT(*)
     FROM gold.DimIndustry) AS IndustryCount,

    (SELECT COUNT(*)
     FROM gold.DimDate) AS YearCount,

    (SELECT COUNT(*)
     FROM gold.FactRegionalGVA) AS FactCount;
GO

-- Expected for the prepared dataset:
-- Regions: 16
-- Industries: 108
-- Years: 26
-- Fact records: 44,928

-- ================================================
-- STEP 10: CHECK FOR DUPLICATE FACT RECORDS
-- ================================================

SELECT
    RegionKey,
    IndustryKey,
    DateKey,
    COUNT(*) AS RecordCount
FROM gold.FactRegionalGVA
GROUP BY
    RegionKey,
    IndustryKey,
    DateKey
HAVING COUNT(*) > 1;
GO

-- Expected: Zero rows

-- ================================================
-- STEP 11: CHECK FACT-DIMENSION RELATIONSHIPS
-- ================================================

SELECT COUNT(*) AS MissingDimensionReferences
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

-- Expected: 0

-- ================================================
-- STEP 12: SAMPLE ANALYTICAL QUERY
-- ================================================

SELECT TOP (20)
    r.RegionName,
    r.GeographyLevel,
    i.SIC07Description,
    i.IndustryLevel,
    d.[Year],
    f.GVAMillionGBP
FROM gold.FactRegionalGVA f

INNER JOIN gold.DimRegion r
    ON f.RegionKey = r.RegionKey

INNER JOIN gold.DimIndustry i
    ON f.IndustryKey = i.IndustryKey

INNER JOIN gold.DimDate d
    ON f.DateKey = d.DateKey

ORDER BY
    d.[Year] DESC,
    r.RegionName,
    i.SIC07Description;
GO
