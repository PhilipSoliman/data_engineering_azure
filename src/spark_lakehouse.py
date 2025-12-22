# import SparkSession
from pyspark.sql import SparkSession

# Connect to the Dockerized Spark standalone master (port 7077 per docker-compose)
def get_spark_session(app_name: str) -> SparkSession:
    spark = (
        SparkSession.builder
        .master("spark://localhost:7077") # type: ignore
        .appName(app_name)
        .config("spark.driver.host", "localhost")
        .getOrCreate()
    )
    print("Connected to Spark master:", spark.sparkContext.master)
    print("Spark version:", spark.version)
    return spark