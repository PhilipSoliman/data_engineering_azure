import psycopg2 as pg

from src.config import settings

DATA_DIR = settings.PROJECT_DIR / "courses" / "cloud_data_warehouses" / "project" / "data"

dbname = settings.AZURE_POSTGRES_DB_NAME
host = settings.AZURE_POSTGRES_DB_HOST
user = settings.AZURE_POSTGRES_DB_USER
password = settings.AZURE_POSTGRES_DB_PASSWORD
port = settings.AZURE_POSTGRES_DB_PORT
sslmode = settings.AZURE_POSTGRES_SSL_MODE

#######################
# Create new database #
#######################
print("Connecting to the Postgres server...")
conn_string = "host={0} user={1} dbname={2} password={3} sslmode={4}".format(
    host, user, dbname, password, sslmode
)
print(f"Connection params: {conn_string}")
conn = pg.connect(
    dbname=settings.AZURE_POSTGRES_DB_NAME,
    user=settings.AZURE_POSTGRES_DB_USER,
    password=settings.AZURE_POSTGRES_DB_PASSWORD,
    host=settings.AZURE_POSTGRES_DB_HOST,
    port=settings.AZURE_POSTGRES_DB_PORT,
    sslmode=settings.AZURE_POSTGRES_SSL_MODE,
)
print("Connection established")
conn.autocommit = True

# drop and create new database
print("Dropping and creating new database udacityproject...")
cursor = conn.cursor()
cursor.execute("DROP DATABASE IF EXISTS udacityproject")
cursor.execute("CREATE DATABASE udacityproject")
conn.commit()
cursor.close()
conn.close()

# Reconnect to the new DB
dbname = "udacityproject"
conn_string = "host={0} user={1} dbname={2} password={3} sslmode={4}".format(
    host, user, dbname, password, sslmode
)
conn = pg.connect(conn_string)
print("Connection to udacityproject established")
cursor = conn.cursor()


# Helper functions
def drop_recreate(c, tablename, create):
    c.execute("DROP TABLE IF EXISTS {0};".format(tablename))
    c.execute(create)
    print("Finished creating table {0}".format(tablename))


def populate_table(c, filename, tablename):
    f = open(filename, "r")
    try:
        cursor.copy_from(f, tablename, sep=",", null="")
        conn.commit()
    except (Exception, pg.DatabaseError) as error:
        print("Error: %s" % error)
        conn.rollback()
        cursor.close()
    print("Finished populating {0}".format(tablename))


#####################
# Create new tables #
#####################
table = "rider"
filename = DATA_DIR / "riders.csv"
create = "CREATE TABLE rider (rider_id INTEGER PRIMARY KEY, first VARCHAR(50), last VARCHAR(50), address VARCHAR(100), birthday DATE, account_start_date DATE, account_end_date DATE, is_member BOOLEAN);"

drop_recreate(cursor, table, create)
populate_table(cursor, filename, table)

# Create Payment table
table = "payment"
filename = DATA_DIR / "payments.csv"
create = "CREATE TABLE payment (payment_id INTEGER PRIMARY KEY, date DATE, amount MONEY, rider_id INTEGER);"

drop_recreate(cursor, table, create)
populate_table(cursor, filename, table)

# Create Station table
table = "station"
filename = DATA_DIR / "stations.csv"
create = "CREATE TABLE station (station_id VARCHAR(50) PRIMARY KEY, name VARCHAR(75), latitude FLOAT, longitude FLOAT);"

drop_recreate(cursor, table, create)
populate_table(cursor, filename, table)

# Create Trip table
table = "trip"
filename = DATA_DIR / "trips.csv"
create = "CREATE TABLE trip (trip_id VARCHAR(50) PRIMARY KEY, rideable_type VARCHAR(75), start_at TIMESTAMP, ended_at TIMESTAMP, start_station_id VARCHAR(50), end_station_id VARCHAR(50), rider_id INTEGER);"

drop_recreate(cursor, table, create)
populate_table(cursor, filename, table)

# Clean up
conn.commit()
cursor.close()
conn.close()

print("All done!")
