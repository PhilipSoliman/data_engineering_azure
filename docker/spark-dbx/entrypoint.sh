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
    
    # Check if VERSION table has data (not just if it exists)
    VERSION_COUNT=$(PGPASSWORD=hive psql -h metastore-db -U hive -d hive_metastore -t -c "SELECT COUNT(*) FROM \"VERSION\";" 2>/dev/null | tr -d ' \n')
    
    exec start-thriftserver.sh \
      --master spark://spark-master:${SPARK_MASTER_PORT:-7077} \
      --hiveconf hive.server2.enable.doAs=false \
      --hiveconf hive.metastore.schema.verification=false \
      --hiveconf hive.metastore.uris="" \
      --hiveconf javax.jdo.option.ConnectionURL=jdbc:postgresql://metastore-db:5432/hive_metastore \
      --hiveconf javax.jdo.option.ConnectionDriverName=org.postgresql.Driver \
      --hiveconf javax.jdo.option.ConnectionUserName=hive \
      --hiveconf javax.jdo.option.ConnectionPassword=hive \
      --hiveconf datanucleus.schema.autoCreateAll=true \
      --hiveconf datanucleus.fixedDatastore=false
    ;;
  *)
    exec "$@"
    ;;
esac
