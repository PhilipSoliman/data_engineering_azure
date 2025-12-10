import re
from pathlib import Path
from urllib.parse import quote

from pydantic import ConfigDict
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Directories
    PROJECT_DIR: Path = Path(__file__).resolve().parent.parent
    APP_DIR: Path = PROJECT_DIR / "src"

    # Load values from .env file
    model_config = ConfigDict(env_file=APP_DIR / ".env")
    POSTGRES_DB_NAME: str
    POSTGRES_DB_USER: str
    POSTGRES_DB_PASSWORD: str
    POSTGRES_DB_HOST: str
    POSTGRES_DB_PORT: int
    CASSANDRA_DB_HOST: str
    CASSANDRA_DB_PORT: int
    CASSANDRA_CLUSTER_NAME: str


# Create a single instance to import everywhere
settings = Settings()
