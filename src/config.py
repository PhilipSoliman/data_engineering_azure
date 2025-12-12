from pathlib import Path

from pydantic import ConfigDict
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Directories
    PROJECT_DIR: Path = Path(__file__).resolve().parent.parent
    APP_DIR: Path = PROJECT_DIR / "src"

    # Load values from .env file or defaults
    model_config = ConfigDict(  # type: ignore
        env_file=APP_DIR / ".env", env_file_encoding="utf-8", extra="ignore"
    )
    POSTGRES_DB_NAME: str = "postgres"
    POSTGRES_DB_USER: str = "postgres"
    POSTGRES_DB_PASSWORD: str = "postgres"
    POSTGRES_DB_HOST: str = "localhost"
    POSTGRES_DB_PORT: int = 5433
    CASSANDRA_DB_HOST: str = "localhost"
    CASSANDRA_DB_PORT: int = 9042
    CASSANDRA_CLUSTER_NAME: str = "Test Cluster"


# Create a single instance to import everywhere
settings = Settings()
