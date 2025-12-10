# Data Engineering with Azure
This repository contains my work on the [Udacity course for data engineering with azure](https://www.udacity.com/course/data-engineering-with-microsoft-azure-nanodegree--nd0277). It contains notes, demo's, exercises and projects that I make, encounter and complete during the course.

## Postgres Database setup
To set up a local PostgreSQL database for development, you can use Docker Compose file included in this repository. Follow the steps below to get started:
```bash
docker compose -f docker-compose-postgres.yml up -d
```
This provides a Postgres instance for local tests and maps container port 5432 to host 5433.


## Cassandra Database setup
Similarly use
```bash
docker compose -f docker-compose-cassandra.yml up -d
```
to set up a local Cassandra database consisting of 2 nodes for development. This maps container ports 9042,9043 and 9044 to host 9043.

To check the status of a node 2 in the Cassandra cluster, you can use the following command:
```bash
docker exec cassandra-2 nodetool status
```