import cassandra.cluster as cs_cluster
import psycopg2
import psycopg2.extensions as pg_ext

from src.config import settings


def get_pg_connection() -> pg_ext.connection:
    try:
        conn = psycopg2.connect(
            dbname=settings.POSTGRES_DB_NAME,
            user=settings.POSTGRES_DB_USER,
            password=settings.POSTGRES_DB_PASSWORD,
            host=settings.POSTGRES_DB_HOST,
            port=settings.POSTGRES_DB_PORT,
        )
    except psycopg2.Error as e:
        print(f"Error connecting to the database: {e}")
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
        print(cql) # to check
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
