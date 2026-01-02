FROM --platform=linux/amd64 python:3.11.14-slim-bookworm AS spark-base

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo \
      curl \
      vim \
      unzip \
      rsync \
      openjdk-17-jdk \
      build-essential \
      software-properties-common \
      ssh \
      ca-certificates \
      postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG SPARK_VERSION=4.0.1
ENV SPARK_VERSION=${SPARK_VERSION}

ARG SPARK_HOME=/opt/spark
ENV SPARK_HOME=${SPARK_HOME}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV SPARK_MASTER_PORT=7077
ENV SPARK_MASTER_HOST=spark-master
ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH
ENV PYSPARK_PYTHON=python3.11
ENV IJAVA_CLASSPATH=/opt/spark/jars/*

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

# Download spark
RUN set -eux; \
    curl -fSL "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" -o "spark-${SPARK_VERSION}-bin-hadoop3.tgz"; \
    tar -xzf "spark-${SPARK_VERSION}-bin-hadoop3.tgz" -C "${SPARK_HOME}" --strip-components=1; \
    rm -rf "spark-${SPARK_VERSION}-bin-hadoop3.tgz"

# Spark 4 uses Scala 2.13; add core Scala libs for tooling parity
RUN set -eux; \
    curl -fSL -o /opt/spark/jars/scala-library-2.13.12.jar https://repo1.maven.org/maven2/org/scala-lang/scala-library/2.13.12/scala-library-2.13.12.jar; \
    curl -fSL -o /opt/spark/jars/scala-compiler-2.13.12.jar https://repo1.maven.org/maven2/org/scala-lang/scala-compiler/2.13.12/scala-compiler-2.13.12.jar; \
    curl -fSL -o /opt/spark/jars/scala-reflect-2.13.12.jar https://repo1.maven.org/maven2/org/scala-lang/scala-reflect/2.13.12/scala-reflect-2.13.12.jar

# Make Spark scripts executable and add to PATH
RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*
ENV PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"

# Cloud storage connectors + metastore driver (align with Hadoop 3.x bundled in Spark 4.0)
RUN set -eux; \
    curl -fSL -o /opt/spark/jars/hadoop-aws-3.3.4.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar; \
    curl -fSL -o /opt/spark/jars/aws-java-sdk-bundle-1.12.767.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.767/aws-java-sdk-bundle-1.12.767.jar; \
    curl -fSL -o /opt/spark/jars/hadoop-azure-3.3.4.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-azure/3.3.4/hadoop-azure-3.3.4.jar; \
    curl -fSL -o /opt/spark/jars/azure-identity-1.11.4.jar https://repo1.maven.org/maven2/com/azure/azure-identity/1.11.4/azure-identity-1.11.4.jar; \
    curl -fSL -o /opt/spark/jars/azure-core-1.54.0.jar https://repo1.maven.org/maven2/com/azure/azure-core/1.54.0/azure-core-1.54.0.jar; \
    curl -fSL -o /opt/spark/jars/azure-storage-blob-12.25.1.jar https://repo1.maven.org/maven2/com/azure/azure-storage-blob/12.25.1/azure-storage-blob-12.25.1.jar; \
    curl -fSL -o /opt/spark/jars/gcs-connector-hadoop3-2.2.19-shaded.jar https://repo1.maven.org/maven2/com/google/cloud/bigdataoss/gcs-connector/hadoop3-2.2.19/gcs-connector-hadoop3-2.2.19-shaded.jar; \
    curl -fSL -o /opt/spark/jars/postgresql-42.7.3.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.3/postgresql-42.7.3.jar

# Lakehouse engines (Iceberg 2.13, Delta 2.13, Hudi Spark 4 bundle)
RUN set -eux; \
    curl -fSL -o /opt/spark/jars/iceberg-spark-runtime-3.5_2.13-1.6.1.jar https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.13/1.6.1/iceberg-spark-runtime-3.5_2.13-1.6.1.jar; \
    curl -fSL -o /opt/spark/jars/delta-core_2.13-2.4.0.jar https://repo1.maven.org/maven2/io/delta/delta-core_2.13/2.4.0/delta-core_2.13-2.4.0.jar; \
    curl -fSL -o /opt/spark/jars/delta-spark_2.13-4.0.0.jar https://repo1.maven.org/maven2/io/delta/delta-spark_2.13/4.0.0/delta-spark_2.13-4.0.0.jar; \
    curl -fSL -o /opt/spark/jars/delta-storage-4.0.0.jar https://repo1.maven.org/maven2/io/delta/delta-storage/4.0.0/delta-storage-4.0.0.jar; \
    curl -fSL -o /opt/spark/jars/hudi-spark4.0-bundle_2.13-1.1.1.jar https://repo1.maven.org/maven2/org/apache/hudi/hudi-spark4.0-bundle_2.13/1.1.1/hudi-spark4.0-bundle_2.13-1.1.1.jar

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY conf/spark-defaults.conf "$SPARK_HOME/conf/"
COPY entrypoint.sh /opt/spark/entrypoint.sh
RUN chmod u+x /opt/spark/entrypoint.sh

# Create DBFS-like directory structure
RUN mkdir -p /dbfs/Workspace/Users \
             /dbfs/mnt \
             /dbfs/tmp \
             /dbfs/spark-events \
             /dbfs/warehouse \
             /databricks/init

ENTRYPOINT ["/opt/spark/entrypoint.sh"]
CMD ["bash"]
