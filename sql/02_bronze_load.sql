
/*
Project: UK Regional GVA Data Warehouse
Layer: Bronze
Purpose: Raw data ingestion from a pipe-delimited CSV

Source: ONS Regional Gross Value Added
Period: 1998–2023
Expected records: 44,928
*/

USE UK_Regional_GVA_DW;
GO

-- 1. Create Bronze table

IF OBJECT_ID('bronze.RegionalGVA_Raw', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.RegionalGVA_Raw
    (
        ITLCode          VARCHAR(30),
        RegionName       NVARCHAR(200),
        GeographyLevel   VARCHAR(50),
        SIC07Code        VARCHAR(30),
        SIC07Description NVARCHAR(500),
        IndustryLevel    VARCHAR(50),
        [Year]           INT,
        GVAMillionGBP    DECIMAL(18,2)
    );
END;
GO

-- 2. Load source data
-- Update the path to your local pipe-delimited file.
-- The file must be accessible to SQL Server.
-- FIRSTROW = 2 assumes the file contains a header.

BULK INSERT bronze.RegionalGVA_Raw
FROM 'C:\GVA_Project\regional_gva_cleaned_pipe.csv'
WITH
(
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- 3. Validate row count

SELECT COUNT(*) AS BronzeRecordCount
FROM bronze.RegionalGVA_Raw;

-- Expected: 44,928 records for the project dataset

-- 4. Validate reporting years

SELECT
    MIN([Year]) AS EarliestYear,
    MAX([Year]) AS LatestYear,
    COUNT(DISTINCT [Year]) AS ReportingYears
FROM bronze.RegionalGVA_Raw;

-- 5. Validate geographic coverage

SELECT
    COUNT(DISTINCT ITLCode) AS GeographicEntities
FROM bronze.RegionalGVA_Raw;

-- 6. Validate industry coverage

SELECT
    COUNT(DISTINCT SIC07Code) AS IndustryCodes
FROM bronze.RegionalGVA_Raw;

-- 7. Check for missing values

SELECT
    SUM(CASE WHEN ITLCode IS NULL THEN 1 ELSE 0 END)
        AS MissingRegionCodes,
    SUM(CASE WHEN SIC07Code IS NULL THEN 1 ELSE 0 END)
        AS MissingIndustryCodes,
    SUM(CASE WHEN [Year] IS NULL THEN 1 ELSE 0 END)
        AS MissingYears,
    SUM(CASE WHEN GVAMillionGBP IS NULL THEN 1 ELSE 0 END)
        AS MissingGVA
FROM bronze.RegionalGVA_Raw;

-- 8. Check for duplicate records

SELECT
    ITLCode,
    SIC07Code,
    [Year],
    COUNT(*) AS DuplicateCount
FROM bronze.RegionalGVA_Raw
GROUP BY
    ITLCode,
    SIC07Code,
    [Year]
HAVING COUNT(*) > 1;

-- 9. Inspect source records

SELECT TOP (20) *
FROM bronze.RegionalGVA_Raw
ORDER BY ITLCode, SIC07Code, [Year];
