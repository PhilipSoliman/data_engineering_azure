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

IF OBJECT_ID('dbo.fact_payment') IS NOT NULL
BEGIN
  DROP EXTERNAL TABLE dbo.fact_payment;
END
CREATE EXTERNAL TABLE dbo.fact_payment
WITH (
    LOCATION     = 'fact_payment',
    DATA_SOURCE = [udacitydipdecourse_udacitydipdecourse_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)
AS
SELECT
    sp.payment_id AS payment_id,
    dd.date_sk AS date_key,
    sp.amount AS amount,
    dr.rider_sk AS rider_sk
FROM dbo.staging_payment AS sp
LEFT JOIN dbo.dim_date AS dd
    ON CONVERT(INT, FORMAT(TRY_CAST(sp.[date] AS DATETIME), 'yyyyMMdd')) = dd.date_sk
LEFT JOIN dbo.dim_rider AS dr
	ON sp.account_number = dr.rider_id;
GO

SELECT TOP 100 * FROM dbo.fact_payment
GO