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

IF OBJECT_ID('dbo.dim_time') IS NOT NULL
BEGIN
  DROP EXTERNAL TABLE dbo.dim_time;
END
CREATE EXTERNAL TABLE dbo.dim_time
WITH (
    LOCATION     = 'dim_time',
    DATA_SOURCE = [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)
AS 
SELECT
    DISTINCT(DATEPART(hour, dts) * 60 + DATEPART(minute, dts)) AS time_sk,
    CONVERT(time, DATEADD(second, DATEPART(hour,dts)*3600 + DATEPART(minute,dts)*60, 0)) AS time,
    DATEPART(hour,dts) AS [hour],
    DATEPART(minute,dts) AS [minute],
    CASE 
        WHEN DATEPART(hour,dts) BETWEEN 5 AND 11 THEN 'morning' 
        WHEN DATEPART(hour,dts) BETWEEN 12 AND 16 THEN 'afternoon' 
        WHEN DATEPART(hour,dts) BETWEEN 17 AND 20 THEN 'evening' 
        ELSE 'night'
    END AS time_of_day,
    CASE 
        WHEN DATEPART(hour,dts) IN (7,8,16,17) THEN 1 
        ELSE 0 
    END AS is_rush_hour
FROM (
    SELECT TRY_CAST(start_at AS datetime) AS dts FROM dbo.staging_trip
    UNION ALL
    SELECT TRY_CAST(ended_at AS datetime) FROM dbo.staging_trip
) t
WHERE dts IS NOT NULL
GO

SELECT TOP 100 * FROM dbo.dim_time
GO