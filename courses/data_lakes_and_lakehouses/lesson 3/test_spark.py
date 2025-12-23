from src.spark_lakehouse import get_spark_session

spark = get_spark_session("test_connection")
print("Spark session created successfully.")
