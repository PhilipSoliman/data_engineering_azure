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

IF OBJECT_ID('dbo.dim_rider') IS NOT NULL
BEGIN
  DROP EXTERNAL TABLE dbo.dim_rider;
END
CREATE EXTERNAL TABLE dbo.dim_rider
WITH (
    LOCATION     = 'dim_rider',
    DATA_SOURCE = [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)
AS 
SELECT
    rider_id AS rider_key,
    first AS first,
    last AS last,
    address AS address,
    CONVERT(INT, FORMAT(birthday,'yyyyMMdd')) AS birthday,
    CONVERT(INT, FORMAT(account_start_date,'yyyyMMdd')) AS account_start_date,
    CONVERT(INT, FORMAT(account_end_date,'yyyyMMdd')) AS account_end_date,
    is_member AS is_member
FROM dbo.staging_rider
GO

SELECT TOP 100 * FROM dbo.dim_rider
GO