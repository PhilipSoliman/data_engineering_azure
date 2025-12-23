# import SparkSession
from pyspark.sql import SparkSession


# Connect to the Dockerized Spark standalone master (port 7077 per docker-compose)
def get_spark_session(app_name: str) -> SparkSession:
    spark = (
        SparkSession.builder.remote("sc://localhost:15002").appName(  # type: ignore
            app_name
        )
        # # When running the Python driver on Windows and Spark workers in Docker,
        # # advertise the host machine so executors can connect back to the driver.
        # # Docker Desktop exposes the host as `host.docker.internal` on Linux containers.
        # .config("spark.driver.host", "host.docker.internal")
        # # Bind address for the driver (allow container connections)
        # .config("spark.driver.bindAddress", "0.0.0.0")
        # # Fix the driver port so containers know which port to connect to
        # .config("spark.driver.port", "49992")
        .getOrCreate()
    )
    print(
        f"Connected to Spark app {spark.conf.get('spark.app.name')} (v. {spark.version})"
    )
    return spark
