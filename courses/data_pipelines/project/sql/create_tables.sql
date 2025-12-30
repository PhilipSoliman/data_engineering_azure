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
        LOCATION = 'https://udacitydipstore.dfs.core.windows.net/adlsnycpayroll-philip-s/dirstaging'
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
    CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
    WITH ( FORMAT_TYPE = DELIMITEDTEXT,
           FORMAT_OPTIONS (
             FIELD_TERMINATOR = ',',
             USE_TYPE_DEFAULT = FALSE
            ))
GO

IF OBJECT_ID('[dbo].[NYC_Payroll_Summary]') IS NOT NULL
BEGIN
  DROP EXTERNAL TABLE [dbo].[NYC_Payroll_Summary];
END
GO

CREATE EXTERNAL TABLE [dbo].[NYC_Payroll_TITLE_MD](
[TitleCode] [varchar](10) NULL,
[TitleDescription] [varchar](100) NULL
)
WITH (
    LOCATION = '/',
    DATA_SOURCE = [udacitydip_nycpayroll_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)
GO

CREATE EXTERNAL TABLE [dbo].[NYC_Payroll_AGENCY_MD](
    [AgencyID] [varchar](10) NULL,
    [AgencyName] [varchar](50) NULL
) 
WITH (
    LOCATION = '/',
    DATA_SOURCE = [udacitydip_nycpayroll_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)

CREATE EXTERNAL TABLE [dbo].[NYC_Payroll_Data_2020](
    [FiscalYear] [int] NULL,
    [PayrollNumber] [int] NULL,
    [AgencyID] [varchar](10) NULL,
    [AgencyName] [varchar](50) NULL,
    [EmployeeID] [varchar](10) NULL,
    [LastName] [varchar](20) NULL,
    [FirstName] [varchar](20) NULL,
    [AgencyStartDate] [date] NULL,
    [WorkLocationBorough] [varchar](50) NULL,
    [TitleCode] [varchar](10) NULL,
    [TitleDescription] [varchar](100) NULL,
    [LeaveStatusasofJune30] [varchar](50) NULL,
    [BaseSalary] [float] NULL,
    [PayBasis] [varchar](50) NULL,
    [RegularHours] [float] NULL,
    [RegularGrossPaid] [float] NULL,
    [OTHours] [float] NULL,
    [TotalOTPaid] [float] NULL,
    [TotalOtherPay] [float] NULL
) 
WITH (
    LOCATION = '/',
    DATA_SOURCE = [udacitydip_nycpayroll_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)
GO

CREATE EXTERNAL TABLE [dbo].[NYC_Payroll_Data_2021](
    [FiscalYear] [int] NULL,
    [PayrollNumber] [int] NULL,
    [AgencyCode] [varchar](10) NULL,
    [AgencyName] [varchar](50) NULL,
    [EmployeeID] [varchar](10) NULL,
    [LastName] [varchar](20) NULL,
    [FirstName] [varchar](20) NULL,
    [AgencyStartDate] [date] NULL,
    [WorkLocationBorough] [varchar](50) NULL,
    [TitleCode] [varchar](10) NULL,
    [TitleDescription] [varchar](100) NULL,
    [LeaveStatusasofJune30] [varchar](50) NULL,
    [BaseSalary] [float] NULL,
    [PayBasis] [varchar](50) NULL,
    [RegularHours] [float] NULL,
    [RegularGrossPaid] [float] NULL,
    [OTHours] [float] NULL,
    [TotalOTPaid] [float] NULL,
    [TotalOtherPay] [float] NULL
)
WITH (
    LOCATION = '/',
    DATA_SOURCE = [udacitydip_nycpayroll_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)
GO

CREATE EXTERNAL TABLE [dbo].[NYC_Payroll_Summary](
    [FiscalYear] [int] NULL,
    [AgencyName] [varchar](50) NULL,
    [TotalPaid] [float] NULL
)
WITH (
    LOCATION = '/',
    DATA_SOURCE = [udacitydip_nycpayroll_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)
GO

SELECT TOP 10 * FROM [dbo].[NYC_Payroll_Summary]