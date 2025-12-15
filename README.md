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
docker-compose -f docker-compose-postgres.yml build
```

Then start the PostgreSQL container:
```bash
docker compose -f docker-compose-postgres.yml up -d
```

**Configuration:**
- Container port `5432` is mapped to host port `5433`
- Use this for local development and testing

To stop and remove the PostgreSQL container:
```bash
docker compose -f docker-compose-postgres.yml down
```

### Pagila Sample Database
To set up the Pagila sample database in PostgreSQL, please refer to the [Pagila README](pagila/README.md) for detailed installation instructions.

### Cassandra
> **Note:** Python 3.12 may not be compatible with the Cassandra driver library due to a missing dependency (libdev). Python 3.11 (or earlier) is recommended.

Build a local Cassandra cluster with 2 nodes:
```bash
docker-compose -f docker-compose-cassandra.yml build
```

Then start the Cassandra containers:
```bash
docker compose -f docker-compose-cassandra.yml up -d
```

**Configuration:**
- Container ports `9042`, `9043`, and `9044` are mapped to host port `9043`
- Two-node cluster for development

To stop and remove the Cassandra containers:

```bash
docker compose -f docker-compose-cassandra.yml down
```

**Check cluster status:**

To verify the status of node 2 in the Cassandra cluster:

```bash
docker exec cassandra-2 nodetool status
```