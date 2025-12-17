from typing import Literal, overload

import cassandra.cluster as cs_cluster
import pandas as pd
import psycopg2
import psycopg2.extensions as pg_ext

from src.config import settings


def get_pg_connection(sample_pagila: bool = False) -> pg_ext.connection:
    conn = None
    try:
        if sample_pagila:
            conn = psycopg2.connect(
                dbname=settings.PAGILA_DB_NAME,
                user=settings.PAGILA_DB_USER,
                password=settings.PAGILA_DB_PASSWORD,
                host=settings.PAGILA_DB_HOST,
                port=settings.PAGILA_DB_PORT,
            )
        else:
            conn = psycopg2.connect(
                dbname=settings.POSTGRES_DB_NAME,
                user=settings.POSTGRES_DB_USER,
                password=settings.POSTGRES_DB_PASSWORD,
                host=settings.POSTGRES_DB_HOST,
                port=settings.POSTGRES_DB_PORT,
            )
    except psycopg2.Error as e:
        print(f"Error connecting to the database: {e}")
        raise
    return conn


def close_pg_connection(conn: pg_ext.connection) -> None:
    try:
        conn.close()
    except psycopg2.Error as e:
        print("Error: Could not close the database connection")
        print(e)


def get_pg_cursor(conn: pg_ext.connection) -> pg_ext.cursor:
    try:
        cur = conn.cursor()
    except psycopg2.Error as e:
        print("Error: Could not get curser to the Database")
        print(e)
    return cur


@overload
def execute_pg_query(
    conn: pg_ext.connection,
    query: str,
    params: tuple | None = None,
    fetch: int = -1,
    return_rows: Literal[False] = False,
) -> pd.DataFrame: ...


@overload
def execute_pg_query(
    conn: pg_ext.connection,
    query: str,
    params: tuple | None = None,
    fetch: int = -1,
    *,
    return_rows: Literal[True],
) -> list[tuple]: ...


def execute_pg_query(
    conn: pg_ext.connection,
    query: str,
    params: tuple | None = None,
    fetch: int = -1,
    return_rows: bool = False,
) -> pd.DataFrame | list[tuple]:
    """Execute a PostgreSQL query and return results as a pandas DataFrame.

    Args:
        conn: PostgreSQL connection object
        query: SQL query string to execute
        params: Optional tuple of parameters for parameterized queries
        fetch: Number of rows to return. Use -1 for all rows (default),
               0 to execute without fetching, or a positive integer for specific count

    Returns:
        pandas DataFrame containing query results. Empty DataFrame if fetch=0 or no results.

    Examples:
        # Fetch all results
        df = execute_pg_query(conn, "SELECT * FROM film;")

        # Fetch first 10 results
        df = execute_pg_query(conn, "SELECT * FROM film;", fetch=10)

        # Fetch one result
        df = execute_pg_query(conn, "SELECT count(*) FROM film;", fetch=1)

        # Execute without fetching (e.g., INSERT/UPDATE/DELETE)
        execute_pg_query(conn, "DELETE FROM temp_table WHERE id = %s;", params=(123,), fetch=0)
    """
    try:
        cur = get_pg_cursor(conn)
        if params:
            cur.execute(query, params)
        else:
            cur.execute(query)

        if fetch == 0:
            # No fetch needed (e.g., for INSERT/UPDATE/DELETE)
            conn.commit()
            results = []
            column_names = []
        elif fetch == -1:
            # Fetch all rows
            results = cur.fetchall()
            column_names = (
                [desc[0] for desc in cur.description] if cur.description else []
            )
        elif fetch == 1:
            # Fetch one row
            result = cur.fetchone()
            results = [result] if result else []
            column_names = (
                [desc[0] for desc in cur.description] if cur.description else []
            )
        else:
            # Fetch specific number of rows
            results = cur.fetchmany(fetch)
            column_names = (
                [desc[0] for desc in cur.description] if cur.description else []
            )

        cur.close()
        if return_rows:
            return results
        else:
            return pd.DataFrame(results, columns=column_names)
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error executing query: {e}")
        raise


def create_pg_table(
    conn: pg_ext.connection, table_name: str, columns: dict[str, str]
) -> None:
    """Create a PostgreSQL table with the given name and column definitions.

    columns: mapping of column name -> PostgreSQL type (e.g., {"id": "SERIAL PRIMARY KEY", "name": "TEXT"}).
    """
    try:
        if not columns:
            raise ValueError("columns cannot be empty")

        cur = get_pg_cursor(conn)
        column_defs = ", ".join(
            f"{col} {col_type}" for col, col_type in columns.items()
        )
        ddl = f"CREATE TABLE IF NOT EXISTS {table_name} ({column_defs});"
        cur.execute(ddl)
        cur.close()
        conn.commit()
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error creating table: {e}")


def drop_pg_table(
    conn: pg_ext.connection, table_name: str, cascade: bool = False
) -> None:
    """Drop a PostgreSQL table if it exists; optionally cascade."""
    suffix = " CASCADE" if cascade else ""
    ddl = f"DROP TABLE IF EXISTS {table_name}{suffix};"
    try:
        cur = get_pg_cursor(conn)
        cur.execute(ddl)
        cur.close()
        conn.commit()
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error dropping table: {e}")


def insert_pg_rows(
    conn: pg_ext.connection,
    table_name: str,
    columns: list[str] | tuple[str, ...],
    rows: list[tuple] | list[list],
) -> None:
    """Insert multiple rows into a PostgreSQL table using a single prepared statement."""
    try:
        if not columns:
            raise ValueError("columns cannot be empty")
        if not rows:
            raise ValueError("rows cannot be empty")

        cur = get_pg_cursor(conn)
        col_list = ", ".join(columns)
        placeholders = ", ".join(["%s"] * len(columns))
        sql = f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})"

        cur.executemany(sql, [tuple(row) for row in rows])
        cur.close()
        conn.commit()
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error inserting rows: {e}")


def get_cs_cluster() -> cs_cluster.Cluster:
    try:
        cluster = cs_cluster.Cluster(
            [settings.CASSANDRA_DB_HOST], port=settings.CASSANDRA_DB_PORT
        )
    except Exception as e:
        print(e)

    return cluster


def get_cs_session(cluster: cs_cluster.Cluster) -> cs_cluster.Session:
    try:
        session = cluster.connect()
    except Exception as e:
        print(e)

    return session


def create_cs_keyspace(
    session: cs_cluster.Session,
    keyspace_name: str,
    class_name: str = "SimpleStrategy",
    replication_factor: int = 1,
) -> None:
    try:
        cql = (
            f"CREATE KEYSPACE IF NOT EXISTS {keyspace_name} "
            f"WITH REPLICATION = {{ 'class' : '{class_name}', 'replication_factor' : {replication_factor} }}"
        )
        session.execute(cql)
    except Exception as e:
        print(e)


def set_cs_keyspace(
    session: cs_cluster.Session,
    keyspace_name: str,
) -> None:
    try:
        session.set_keyspace(keyspace_name)
    except Exception as e:
        print(e)


def drop_cs_keyspace(session: cs_cluster.Session, keyspace_name: str) -> None:
    """Drop a Cassandra keyspace if it exists."""
    try:
        cql = f"DROP KEYSPACE IF EXISTS {keyspace_name}"
        session.execute(cql)
    except Exception as e:
        print(e)


def create_cs_table(
    session: cs_cluster.Session,
    table_name: str,
    columns: dict[str, str],
    primary_keys: str | list[str] | tuple[str, ...],
) -> None:
    """Create a Cassandra table with provided columns and primary key definition."""
    try:
        if not columns:
            raise ValueError("columns cannot be empty")
        if not primary_keys:
            raise ValueError("primary_keys cannot be empty")

        col_defs = ", ".join(f"{col} {col_type}" for col, col_type in columns.items())
        pk = (
            ", ".join(primary_keys)
            if not isinstance(primary_keys, str)
            else primary_keys
        )
        cql = (
            f"CREATE TABLE IF NOT EXISTS {table_name} "
            f"({col_defs}, PRIMARY KEY ({pk}))"
        )
        print(cql)  # to check
        session.execute(cql)
    except Exception as e:
        print(e)


def drop_cs_table(session: cs_cluster.Session, table_name: str) -> None:
    """Drop a Cassandra table if it exists."""
    try:
        cql = f"DROP TABLE IF EXISTS {table_name}"
        session.execute(cql)
    except Exception as e:
        print(e)


def insert_cs_rows(
    session: cs_cluster.Session,
    table_name: str,
    columns: list[str] | tuple[str, ...],
    rows: list[tuple] | list[list],
) -> None:
    """Insert multiple rows into a Cassandra table.

    columns: ordered column names matching each row
    rows: list of tuples/lists with values in the same column order
    """
    try:
        if not columns:
            raise ValueError("columns cannot be empty")
        if not rows:
            raise ValueError("rows cannot be empty")

        col_list = ", ".join(columns)
        placeholders = ", ".join(["%s"] * len(columns))
        cql = f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})"

        for row in rows:
            session.execute(cql, tuple(row))
    except Exception as e:
        print(e)


def close_cs_session(session: cs_cluster.Session) -> None:
    try:
        session.shutdown()
    except Exception as e:
        print("Error: Could not close the Cassandra session")
        print(e)


def shutdown_cs_cluster(cluster: cs_cluster.Cluster) -> None:
    try:
        cluster.shutdown()
    except Exception as e:
        print("Error: Could not close the Cassandra cluster")
        print(e)
