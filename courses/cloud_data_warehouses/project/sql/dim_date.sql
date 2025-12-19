IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 USE_TYPE_DEFAULT = FALSE
			))
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://udacitydipdecourse@udacitydipdecourse.dfs.core.windows.net' 
	)
GO

IF OBJECT_ID('dbo.dim_date') IS NOT NULL
BEGIN
  DROP EXTERNAL TABLE dbo.dim_date;
END
CREATE EXTERNAL TABLE dbo.dim_date
WITH (
    LOCATION     = 'dim_date',
    DATA_SOURCE = [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)
AS 
SELECT
    DISTINCT(CONVERT(INT, FORMAT(d,'yyyyMMdd'))) AS date_key,
    d AS date_date,
    DATEPART(year, d) AS year,
    DATEPART(quarter, d) AS quarter,
    DATEPART(month, d) AS month,
    DATEPART(week, d) AS week_of_year,
    DATEPART(weekday, d) AS weekday,
    CASE 
        WHEN DATEPART(weekday, d) IN (1,7) 
        THEN 1 
        ELSE 0 
    END AS is_weekend
FROM (
    SELECT TRY_CAST(date AS DATE) AS d FROM dbo.staging_payment
    UNION ALL
    SELECT TRY_CAST(account_start_date AS DATE) FROM dbo.staging_rider
    UNION ALL
    SELECT TRY_CAST(account_end_date AS DATE) FROM dbo.staging_rider
    UNION ALL
    SELECT TRY_CAST(birthday AS DATE) FROM dbo.staging_rider
    UNION ALL
    SELECT TRY_CAST(start_at AS DATE) FROM dbo.staging_trip
    UNION ALL
    SELECT TRY_CAST(ended_at AS DATE) FROM dbo.staging_trip
) t
WHERE d IS NOT NULL
GO

SELECT TOP 100 * FROM dbo.dim_date
GO