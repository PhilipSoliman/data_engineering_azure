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

-- Uncomment to recreate table
-- DROP EXTERNAL TABLE dbo.staging_trip
CREATE EXTERNAL TABLE dbo.staging_trip (
	trip_id VARCHAR(50), 
	rideable_type VARCHAR(75), 
	start_at DATETIME2, 
	ended_at DATETIME2, 
	start_station_id VARCHAR(50), 
	end_station_id VARCHAR(50), 
	rider_id INTEGER
	)
	WITH (
	LOCATION = 'public.trip.txt',
	DATA_SOURCE = [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.staging_trip
GO