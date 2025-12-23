import os
import re
import shutil
import subprocess
from pathlib import Path
from typing import Optional

from pydantic import ConfigDict, field_validator
from pydantic_settings import BaseSettings

JAVA_MAJOR_VERSION = 17  # should match the version of the spark JVM

class Settings(BaseSettings):
    # Directories
    PROJECT_DIR: Path = Path(__file__).resolve().parent.parent
    APP_DIR: Path = PROJECT_DIR / "src"

    # Load values from .env file or defaults
    model_config = ConfigDict(  # type: ignore
        env_file=APP_DIR / ".env", env_file_encoding="utf-8", extra="ignore"
    )

    # Java installation path (for PySpark)
    JAVA_MAJOR_VERSION: int = JAVA_MAJOR_VERSION # should match the version of the spark JVM
    JAVA_HOME: str = ""

    @field_validator("JAVA_HOME", mode="after")
    @classmethod
    def _validate_java_home(cls, v: str) -> str:
        f"""Validate that Java is installed and is major version {JAVA_MAJOR_VERSION}.

        - If `JAVA_HOME` is provided, check for a `java` executable under its `bin` dir.
        - If empty, try to find `java` on PATH.
        - Run `java -version` and parse the major version; require {JAVA_MAJOR_VERSION}.
        - If `JAVA_HOME` was empty and a suitable `java` is found, infer and return the JAVA_HOME.
        Raises `ValueError` when Java {JAVA_MAJOR_VERSION} cannot be found or the version is incorrect.
        """
        # Try to locate java executable from provided JAVA_HOME
        java_exe = None
        if v:
            candidates = [
                Path(v) / "bin" / "java",
                Path(v) / "bin" / "java.exe",
                Path(v) / "java",
                Path(v) / "java.exe",
            ]
            for p in candidates:
                if p.exists():
                    java_exe = str(p)
                    break
        else:
            java_in_path = shutil.which("java")
            if java_in_path:
                java_exe = java_in_path

        if not java_exe:
            raise ValueError(
                f"Java not found. Set JAVA_HOME to a Java {JAVA_MAJOR_VERSION} installation or install Java {JAVA_MAJOR_VERSION}."
            )

        try:
            proc = subprocess.run(
                [java_exe, "-version"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=5,
            )
            output = (proc.stderr or "") + "\n" + (proc.stdout or "")
        except Exception as exc:
            raise ValueError(f"Failed to run java executable: {exc}")

        m = re.search(r"version \"?(\d+)", output)
        if not m:
            raise ValueError(
                "Unable to parse Java version from `java -version` output."
            )

        major = int(m.group(1))
        if major != JAVA_MAJOR_VERSION:
            raise ValueError(f"Java major version {major} found; Java {JAVA_MAJOR_VERSION} is required.")

        # If JAVA_HOME wasn't provided, infer it from the java executable path
        if not v:
            v = str(Path(java_exe).resolve().parent.parent)

        # Normalize: if JAVA_HOME points at a `bin` directory, use its parent as the JDK root
        try:
            p = Path(v)
            if p.name.lower() == "bin":
                p = p.parent
            v = str(p)
        except Exception:
            pass

        # set JAVA_HOME environment variable to the JDK root and ensure PATH contains its bin
        os.environ["JAVA_HOME"] = v
        bin_path = str(Path(v) / "bin")
        cur_path = os.environ.get("PATH", "")
        if bin_path not in cur_path:
            os.environ["PATH"] = bin_path + os.pathsep + cur_path

        return v

    # Spark settings
    SPARK_CLUSTER_DATA_DIR: str = "file:///opt/spark/data/"

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
