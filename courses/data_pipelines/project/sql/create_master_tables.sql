IF OBJECT_ID('[dbo].[NYC_Payroll_EMP_MD]') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[NYC_Payroll_EMP_MD]
END
CREATE TABLE [dbo].[NYC_Payroll_EMP_MD](
[EmployeeID] [varchar](10) NULL,
[LastName] [varchar](20) NULL,
[FirstName] [varchar](20) NULL
) 
GO

IF OBJECT_ID('[dbo].[NYC_Payroll_TITLE_MD]') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[NYC_Payroll_TITLE_MD]
END
CREATE TABLE [dbo].[NYC_Payroll_TITLE_MD](
[TitleCode] [varchar](10) NULL,
[TitleDescription] [varchar](100) NULL
)
GO


IF OBJECT_ID('[dbo].[NYC_Payroll_AGENCY_MD]') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[NYC_Payroll_AGENCY_MD]
END
CREATE TABLE [dbo].[NYC_Payroll_AGENCY_MD](
    [AgencyID] [varchar](10) NULL,
    [AgencyName] [varchar](50) NULL
) 
GO

IF OBJECT_ID('[dbo].[NYC_Payroll_Data_2020]') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[NYC_Payroll_Data_2020]
END
CREATE TABLE [dbo].[NYC_Payroll_Data_2020](
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
GO

IF OBJECT_ID('[dbo].[NYC_Payroll_Data_2021]') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[NYC_Payroll_Data_2021]
END
CREATE TABLE [dbo].[NYC_Payroll_Data_2021](
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
GO

IF OBJECT_ID('[dbo].[NYC_Payroll_Summary]') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[NYC_Payroll_Summary]
END
CREATE TABLE [dbo].[NYC_Payroll_Summary](
    [FiscalYear] [int] NULL,
    [AgencyName] [varchar](50) NULL,
    [TotalPaid] [float] NULL 
)
GO