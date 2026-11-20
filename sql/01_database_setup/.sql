
-- UK Regional GVA Data Warehouse
-- Database and Schema Setup

IF DB_ID('UK_Regional_GVA_DW') IS NULL
BEGIN
    CREATE DATABASE UK_Regional_GVA_DW;
END;
GO

USE UK_Regional_GVA_DW;
GO

IF SCHEMA_ID('bronze') IS NULL
    EXEC('CREATE SCHEMA bronze');
GO

IF SCHEMA_ID('silver') IS NULL
    EXEC('CREATE SCHEMA silver');
GO

IF SCHEMA_ID('gold') IS NULL
    EXEC('CREATE SCHEMA gold');
GO

-- Verify schemas
SELECT
    name AS SchemaName
FROM sys.schemas
WHERE name IN ('bronze', 'silver', 'gold')
ORDER BY name;
  
