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
    ROW_NUMBER() OVER (ORDER BY TRY_CAST(rider_id AS INT)) AS rider_sk,
    rider_id AS rider_key,
    first AS first,
    last AS last,
    address AS address,
    CONVERT(INT, FORMAT(TRY_CAST(birthday AS DATETIME),'yyyyMMdd')) AS birthday_key,
    CONVERT(INT, FORMAT(TRY_CAST(account_start_date AS DATETIME),'yyyyMMdd')) AS account_start_date_key,
    CONVERT(INT, FORMAT(TRY_CAST(account_end_date AS DATETIME),'yyyyMMdd')) AS account_end_date_key,
    CASE WHEN LOWER(ISNULL(is_member, '0')) IN ('1','true','yes','y') THEN 1 ELSE 0 END AS is_member,
    -- age at account start (years); returns NULL if birthday or account_start_date invalid
    CASE 
    WHEN TRY_CAST(birthday AS DATE) IS NOT NULL AND TRY_CAST(account_start_date AS DATE) IS NOT NULL
    THEN DATEDIFF(year, TRY_CAST(birthday AS DATE), TRY_CAST(account_start_date AS DATE))
        ELSE NULL 
    END AS rider_age_at_account_start
FROM dbo.staging_rider
GO

SELECT TOP 100 * FROM dbo.dim_rider
GO