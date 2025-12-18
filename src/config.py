from pathlib import Path
from typing import Optional

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

    # PostgreSQL settings
    POSTGRES_DB_NAME: str = "postgres"
    POSTGRES_DB_USER: str = "postgres"
    POSTGRES_DB_PASSWORD: str = "postgres"
    POSTGRES_DB_HOST: str = "localhost"
    POSTGRES_DB_PORT: int = 5433

    # Pagila (PostgreSQL sample database) settings
    PAGILA_DB_NAME: str = "postgres"
    PAGILA_DB_USER: str = "postgres"
    PAGILA_DB_PASSWORD: str = "postgres"
    PAGILA_DB_HOST: str = "localhost"
    PAGILA_DB_PORT: int = 5435

    # Pagila (PostgreSQL sample database) settings
    CITUS_DB_NAME: str = "postgres"
    CITUS_DB_USER: str = "postgres"
    CITUS_DB_PASSWORD: str = "postgres"
    CITUS_DB_HOST: str = "localhost"
    CITUS_DB_PORT: int = 5436

    # Azure PostgreSQL settings (SENSITIVE - to be set in .env file)
    AZURE_POSTGRES_DB_NAME: Optional[str] = None
    AZURE_POSTGRES_DB_USER: Optional[str] = None
    AZURE_POSTGRES_DB_PASSWORD: Optional[str] = None
    AZURE_POSTGRES_DB_HOST: Optional[str] = None
    AZURE_POSTGRES_DB_PORT: Optional[int] = None
    AZURE_POSTGRES_SSL_MODE: Optional[str] = None

    # Cassandra settings
    CASSANDRA_DB_HOST: str = "localhost"
    CASSANDRA_DB_PORT: int = 9042
    CASSANDRA_CLUSTER_NAME: str = "Test Cluster"


# Create a single instance to import everywhere
settings = Settings()
