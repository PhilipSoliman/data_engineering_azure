IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 STRING_DELIMITER = '"',
			 USE_TYPE_DEFAULT = FALSE
			))
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net]
	WITH (
		LOCATION = 'abfss://udacitydipdecourse@udacitydipdecourse.dfs.core.windows.net'
	)
GO

IF OBJECT_ID('dbo.fact_trip') IS NOT NULL
BEGIN
  DROP EXTERNAL TABLE dbo.fact_trip;
END
CREATE EXTERNAL TABLE dbo.fact_trip
WITH (
    LOCATION     = 'fact_trip',
    DATA_SOURCE = [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)
AS
SELECT
	st.trip_id AS trip_id,
	dd_start_date.date_key AS start_date_key,
	dt_start_time.time_key AS start_time_key,
	dd_end_date.date_key AS end_date_key,
	dt_end_time.time_key AS end_time_key,
	DATEDIFF(minute, TRY_CAST(st.start_at AS datetime), TRY_CAST(st.ended_at AS datetime)) AS trip_duration_minutes,
	ss.station_id AS start_station_id, 
	ss.station_id AS end_station_id, 
	dr.rider_key AS rider_key,
	dr.rider_age_at_account_start,
	DATEDIFF(year,dr.birthday_date,TRY_CAST(st.start_at AS datetime)) AS rider_age_at_trip_start
FROM dbo.staging_trip AS st
LEFT JOIN dbo.dim_date AS dd_start_date
	ON CONVERT(INT, FORMAT(TRY_CAST(st.[start_at] AS DATETIME), 'yyyyMMdd')) = dd_start_date.date_key
LEFT JOIN dbo.dim_time AS dt_start_time
	ON DATEPART(hour, TRY_CAST(st.[start_at] AS DATETIME)) * 60 + DATEPART(minute, TRY_CAST(st.[start_at] AS DATETIME)) = dt_start_time.time_key
LEFT JOIN dbo.dim_date AS dd_end_date
	ON CONVERT(INT, FORMAT(TRY_CAST(st.[ended_at] AS DATETIME), 'yyyyMMdd')) = dd_end_date.date_key
LEFT JOIN dbo.dim_time AS dt_end_time
	ON DATEPART(hour, TRY_CAST(st.[ended_at] AS DATETIME)) * 60 + DATEPART(minute, TRY_CAST(st.[ended_at] AS DATETIME)) = dt_end_time.time_key
LEFT JOIN dbo.dim_rider AS dr
	ON st.rider_id = dr.rider_key
LEFT JOIN dbo.staging_station AS ss
	ON st.start_station_id = ss.station_id
GO

SELECT TOP 100 * FROM dbo.fact_trip
GO