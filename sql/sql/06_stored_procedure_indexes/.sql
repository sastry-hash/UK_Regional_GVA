
/*
====================================================
PROJECT: UK Regional GVA Data Warehouse
FILE: 06_stored_procedure_indexes.sql
LAYER: GOLD

PURPOSE:
1. Create a reusable stored procedure
2. Implement fact-table indexes
3. Support analytical query performance

DATABASE: UK_Regional_GVA_DW
====================================================
*/

USE UK_Regional_GVA_DW;
GO

-- ================================================
-- STEP 1: CREATE STORED PROCEDURE
-- ================================================

CREATE OR ALTER PROCEDURE gold.usp_GetRegionalGVA
    @RegionName NVARCHAR(200),
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.RegionName,
        r.GeographyLevel,
        i.SIC07Code,
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

    WHERE r.RegionName = @RegionName
      AND d.[Year] = @Year

    ORDER BY
        i.IndustryLevel,
        i.SIC07Code;
END;
GO


-- ================================================
-- STEP 2: EXECUTE STORED PROCEDURE
-- ================================================

EXEC gold.usp_GetRegionalGVA
    @RegionName = 'North West',
    @Year = 2023;
GO


-- ================================================
-- STEP 3: INDEX ON REGION KEY
-- ================================================

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_FactRegionalGVA_RegionKey'
      AND object_id =
          OBJECT_ID('gold.FactRegionalGVA')
)
BEGIN
    CREATE NONCLUSTERED INDEX
        IX_FactRegionalGVA_RegionKey

    ON gold.FactRegionalGVA (RegionKey);
END;
GO


-- ================================================
-- STEP 4: INDEX ON INDUSTRY KEY
-- ================================================

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_FactRegionalGVA_IndustryKey'
      AND object_id =
          OBJECT_ID('gold.FactRegionalGVA')
)
BEGIN
    CREATE NONCLUSTERED INDEX
        IX_FactRegionalGVA_IndustryKey

    ON gold.FactRegionalGVA (IndustryKey);
END;
GO


-- ================================================
-- STEP 5: INDEX ON DATE KEY
-- ================================================

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_FactRegionalGVA_DateKey'
      AND object_id =
          OBJECT_ID('gold.FactRegionalGVA')
)
BEGIN
    CREATE NONCLUSTERED INDEX
        IX_FactRegionalGVA_DateKey

    ON gold.FactRegionalGVA (DateKey);
END;
GO


-- ================================================
-- STEP 6: COMPOSITE INDEX
-- ================================================

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_FactRegionalGVA_RegionDateIndustry'
      AND object_id =
          OBJECT_ID('gold.FactRegionalGVA')
)
BEGIN
    CREATE NONCLUSTERED INDEX
        IX_FactRegionalGVA_RegionDateIndustry

    ON gold.FactRegionalGVA
    (
        RegionKey,
        DateKey,
        IndustryKey
    )

    INCLUDE (GVAMillionGBP);
END;
GO


-- ================================================
-- STEP 7: VERIFY CREATED INDEXES
-- ================================================

SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique

FROM sys.indexes i

WHERE i.object_id =
    OBJECT_ID('gold.FactRegionalGVA')

ORDER BY i.name;
GO


-- ================================================
-- STEP 8: INSPECT QUERY EXECUTION
-- ================================================

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

EXEC gold.usp_GetRegionalGVA
    @RegionName = 'North West',
    @Year = 2023;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
