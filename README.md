# Data Engineering with Azure
This repository contains my work on the [Udacity course for data engineering with azure](https://www.udacity.com/course/data-engineering-with-microsoft-azure-nanodegree--nd0277). It contains notes, demo's, exercises and projects that I make, encounter and complete during the course.

## Database setup for local development
To set up a local PostgreSQL database for development, you can use Docker Compose file included in this repository. Follow the steps below to get started:
```bash
docker compose -f docker-compose-postgres.yml up -d
```
This provides a Postgres instance for local tests and maps container port 5432 to host 5433.