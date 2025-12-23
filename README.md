# Data Engineering with Azure

This repository contains my work on the [Udacity Data Engineering with Microsoft Azure Nanodegree](https://www.udacity.com/course/data-engineering-with-microsoft-azure-nanodegree--nd0277). It includes notes, demos, exercises, and projects completed throughout the course.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Database Setup](#database-setup)
    - [PostgreSQL](#postgresql)
    - [Cassandra](#cassandra)

## Prerequisites

Before getting started, ensure you have the following installed:

- **Python**: Version 3.11 (other versions may work, but 3.11 is recommended)
- **uv**: Python package installer ([installation guide](https://github.com/astral-sh/uv))
- **Docker Desktop**: For running local databases ([download here](https://www.docker.com/products/docker-desktop/))

## Installation

To set up the development environment in editable mode:

```bash
uv pip install -e .
```

## Java (host) setup

The Spark Docker images and the project's Dockerfiles use Java 11. If you plan
to run PySpark locally (outside Docker), install a matching JDK on your host.

Windows (recommended: Temurin / Adoptium OpenJDK 11):

```powershell
# Install via winget (Admin PowerShell)
winget install --id EclipseAdoptium.Temurin.11.JDK -e

# Or via Chocolatey (Admin PowerShell)
choco install temurin17 -y

# Set JAVA_HOME (replace with your actual install path) and add to PATH
setx -m JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-17.0.x"
setx -m PATH "%PATH%;%JAVA_HOME%\bin"

# Restart terminal/IDE, then verify
java -version
powershell -Command "echo $Env:JAVA_HOME"
```

Linux (Debian/Ubuntu example):

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk
java -version
```

macOS (Homebrew):

```bash
brew install temurin17
java -version
```

Notes:

- If you only run Spark inside Docker containers, you don't need to install Java on the host — the container images include the JDK.
- If you prefer configuring `JAVA_HOME` per-project, add `JAVA_HOME` to `src/.env` and the repository's `src/config.py` can read and set it for Python processes.

## Database Setup
The application uses environment variables for database connections with defaults that match the provided Docker Compose configurations. 

**You only need to customize environment variables if you plan to use your own PostgreSQL or Cassandra servers.** The Docker Compose files are already configured to work with the default values in `src/config.py`.

To customize for external databases:

1. Copy the example environment file:
   ```bash
   cp src/.env.example src/.env
   ```

2. Edit `src/.env` with your custom database connection details.


### PostgreSQL

Build a local PostgreSQL database using Docker Compose:
```bash
docker compose -f docker/docker-compose-postgres.yml up -d
```

**Configuration:**
- Container port `5432` is mapped to host port `5433`
- Use this for local development and testing

To stop and remove the PostgreSQL container:
```bash
docker compose -f docker/docker-compose-postgres.yml down
```

### Pagila Sample Database
To set up the Pagila sample database in PostgreSQL, please refer to the [Pagila README](pagila/README.md) for detailed installation instructions. TLDR; run 
```bash
docker-compose -f docker/docker-compose-pagila.yml up -d
```
to start the Pagila database container. Now, load the schema:
```bash
cat pagila/pagila-schema.sql | docker exec -i pagila psql -U postgres -d postgres
```
Load the data:
```bash
cat pagila/pagila-data.sql | docker exec -i pagila psql -U postgres -d postgres
```

### Citus Sample Database 
> **Note:** NOT WORKING YET: the download of sample citus data is outdated; simply returns a download page html.

Run the following commands to set up the `customer_reviews` sample database in PostgreSQL:
```bash
docker compose -f docker/docker-compose-citus.yml up -d
```
The citus_loader container will automatically download sample data. Loading the sample data into the PostgreSQl database is done in Lesson 2: [E3 - Columnar Vs Row Storage](courses/cloud_data_warehouses/lesson%202/E3%20-%20Columnar%20Vs%20Row%20Storage.ipynb).

### Cassandra
> **Note:** Python 3.12 may not be compatible with the Cassandra driver library due to a missing dependency (libdev). Python 3.11 (or earlier) is recommended.

Build a local Cassandra cluster with 2 nodes:
```bash
docker compose -f docker/docker-compose-cassandra.yml up -d
```

**Configuration:**
- Container ports `9042`, `9043`, and `9044` are mapped to host port `9043`
- Two-node cluster for development

To stop and remove the Cassandra containers:

```bash
docker compose -f docker/docker-compose-cassandra.yml down
```

**Check cluster status:**

To verify the status of node 2 in the Cassandra cluster:

```bash
docker exec cassandra-2 nodetool status
```