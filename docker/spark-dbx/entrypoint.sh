#!/bin/bash
set -euo pipefail

SPARK_WORKLOAD=${1:-master}
INIT_DIR=${INIT_DIR:-/databricks/init}

# Run cluster init scripts (Databricks-style hook)
if [ -d "$INIT_DIR" ]; then
  for script in "$INIT_DIR"/*.sh; do
    if [ -f "$script" ]; then
      echo "Running init script: $script"
      bash "$script"
    fi
  done
fi

# Ensure DBFS-like dirs exist (host bind mounts may shadow image defaults)
mkdir -p /dbfs/spark-events /dbfs/warehouse /dbfs/tmp /dbfs/Workspace/Users /dbfs/mnt

echo "SPARK_WORKLOAD: $SPARK_WORKLOAD"

case "$SPARK_WORKLOAD" in
  master)
    exec start-master.sh -p ${SPARK_MASTER_PORT:-7077}
    ;;
  worker*)
    exec start-worker.sh spark://spark-master:${SPARK_MASTER_PORT:-7077}
    ;;
  connect|connect-server)
    # Start Spark Connect server (Spark 4 ships sbin/start-connect-server.sh)
    exec sbin/start-connect-server.sh || exec /opt/spark/sbin/start-connect-server.sh
    ;;
  history)
    exec start-history-server.sh
    ;;
  thrift|thriftserver)
    # Wait for metastore DB to be ready
    echo "Waiting for metastore-db to be ready..."
    until PGPASSWORD=hive psql -h metastore-db -U hive -d hive_metastore -c '\q' 2>/dev/null; do
      echo "Postgres is unavailable - sleeping"
      sleep 2
    done
    echo "Postgres is up - checking schema"
    
    # Check if VERSION table exists; if not, initialize schema
    PGPASSWORD=hive psql -h metastore-db -U hive -d hive_metastore -c "SELECT * FROM \"VERSION\" LIMIT 1;" 2>/dev/null || {
      echo "VERSION table not found - initializing Hive metastore schema..."
      schematool -dbType postgres -initSchema -userName hive -passWord hive \
        -url jdbc:postgresql://metastore-db:5432/hive_metastore || echo "schematool failed (continuing anyway)"
    }
    
    exec start-thriftserver.sh --master spark://spark-master:${SPARK_MASTER_PORT:-7077} --hiveconf hive.server2.enable.doAs=false
    ;;
  *)
    exec "$@"
    ;;
esac
