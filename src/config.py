import re
from pathlib import Path
from urllib.parse import quote

from pydantic_settings import BaseSettings
from pydantic import ConfigDict

class Settings(BaseSettings):
    # Directories
    PROJECT_DIR: Path = Path(__file__).resolve().parent.parent
    APP_DIR: Path = PROJECT_DIR / "src"

    # Load values from .env file
    model_config = ConfigDict(env_file=APP_DIR / ".env")
    DB_NAME: str
    DB_USER: str
    DB_PASSWORD: str
    DB_HOST: str
    DB_PORT: int


# Create a single instance to import everywhere
settings = Settings()