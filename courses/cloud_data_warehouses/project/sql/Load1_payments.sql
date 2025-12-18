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
-- DROP EXTERNAL TABLE dbo.staging_payment
CREATE EXTERNAL TABLE dbo.staging_payment (
	[payment_id] BIGINT,
	[date] DATETIME2,
	[amount] FLOAT,
	[account_number] BIGINT
	)
	WITH (
	LOCATION = 'public.payment.txt',
	DATA_SOURCE = [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.staging_payment
GO