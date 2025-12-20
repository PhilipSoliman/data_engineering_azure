IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 FIRST_ROW = 2,
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
-- DROP EXTERNAL TABLE dbo.staging_station
CREATE EXTERNAL TABLE dbo.staging_station (
	[station_key] VARCHAR(50),
	[name] VARCHAR(75),
	[latitude] FLOAT,
	[longitude] FLOAT
	)
	WITH (
	LOCATION = 'public.station.txt',
	DATA_SOURCE = [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.staging_station
GO