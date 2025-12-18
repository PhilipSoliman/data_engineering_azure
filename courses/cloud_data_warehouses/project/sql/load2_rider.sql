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
-- DROP EXTERNAL TABLE dbo.staging_rider
CREATE EXTERNAL TABLE dbo.staging_rider (
	[rider_id] BIGINT,
	[first] VARCHAR(50),
	[last] VARCHAR(50),
	[address] VARCHAR(100),
	[birthday] DATETIME2,
	[account_start_date] DATETIME2,
	[account_end_date] DATETIME2,
	[is_member] BIT
	)
	WITH (
	LOCATION = 'public.rider.txt',
	DATA_SOURCE = [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.staging_rider
GO