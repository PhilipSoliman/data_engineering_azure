USE master;
GO

IF DB_ID('udacity') IS NOT NULL
BEGIN
    DROP DATABASE udacity
END
GO

CREATE DATABASE udacity;
GO

USE udacity;
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'udacitydip_nycpayroll_dfs_core_windows_net')
BEGIN
    CREATE EXTERNAL DATA SOURCE [udacitydip_nycpayroll_dfs_core_windows_net] WITH (
        LOCATION = 'https://udacitydipstorage.dfs.core.windows.net/adlsnycpayroll-philip-s/dirstaging'
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
    CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
    WITH ( FORMAT_TYPE = DELIMITEDTEXT,
           FORMAT_OPTIONS (
            FIELD_TERMINATOR = ',',
            FIRST_ROW = 1,
            USE_TYPE_DEFAULT = FALSE
            ))
GO

IF OBJECT_ID('[dbo].[NYC_Payroll_Summary]') IS NOT NULL
BEGIN
  DROP EXTERNAL TABLE [dbo].[NYC_Payroll_Summary];
END
GO
CREATE EXTERNAL TABLE [dbo].[NYC_Payroll_Summary](
    [FiscalYear] [varchar](10) NULL,
    [AgencyName] [varchar](50) NULL,
    [TotalPaid] [varchar](10) NULL
)
WITH (
    LOCATION = '/',
    DATA_SOURCE = [udacitydip_nycpayroll_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)
GO

SELECT TOP 10 * FROM [dbo].[NYC_Payroll_Summary]