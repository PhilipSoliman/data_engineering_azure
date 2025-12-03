import psycopg2
from src.config import settings
import psycopg2.extensions as ext

def get_connection() -> ext.connection:
    try:
        conn = psycopg2.connect(
            dbname=settings.DB_NAME,
            user=settings.DB_USER,
            password=settings.DB_PASSWORD,
            host=settings.DB_HOST,
            port=settings.DB_PORT
        )
    except psycopg2.Error as e:
        print(f"Error connecting to the database: {e}")
    return conn

def close_connection(conn: ext.connection) -> None:
    try:
        conn.close()
    except psycopg2.Error as e:
        print("Error: Could not close the database connection")
        print(e)

def get_cursor(conn: ext.connection) -> ext.cursor:
    try: 
        cur = conn.cursor()
    except psycopg2.Error as e: 
        print("Error: Could not get curser to the Database")
        print(e)
    return cur
