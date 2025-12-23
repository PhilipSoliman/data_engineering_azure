FROM python:3.12.9-bullseye AS spark-base

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
      ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## Download spark and hadoop dependencies and install

# Build-time and runtime variables with defaults
ARG SPARK_VERSION=4.0.1
ENV SPARK_VERSION=${SPARK_VERSION}

ARG SPARK_HOME=/opt/spark
ENV SPARK_HOME=${SPARK_HOME}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}

# Ensure Java 17 is used (Spark 3.5+ may require Java 17)
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

ENV SPARK_MASTER_PORT=7077
ENV SPARK_MASTER_HOST=spark-master

ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH
ENV PYSPARK_PYTHON=python3

# Add iceberg spark runtime jar to IJava classpath
ENV IJAVA_CLASSPATH=/opt/spark/jars/*

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

# Download spark
# see resources: https://dlcdn.apache.org/spark/spark-3.5.5/
# filename: spark-3.5.5-bin-hadoop3.tgz 
RUN set -eux; \
    mkdir -p "${SPARK_HOME}"; \
    curl -fSL "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" -o "spark-${SPARK_VERSION}-bin-hadoop3.tgz"; \
    tar -xzf "spark-${SPARK_VERSION}-bin-hadoop3.tgz" -C "${SPARK_HOME}" --strip-components=1; \
    rm -rf "spark-${SPARK_VERSION}-bin-hadoop3.tgz"

# Download Scala 2.12 stdlib and related modules (match Spark's _2.12 artifacts)
RUN set -eux; \
    curl -fSL -o /opt/spark/jars/scala-library-2.12.18.jar https://repo1.maven.org/maven2/org/scala-lang/scala-library/2.12.18/scala-library-2.12.18.jar; \
    curl -fSL -o /opt/spark/jars/scala-compiler-2.12.18.jar https://repo1.maven.org/maven2/org/scala-lang/scala-compiler/2.12.18/scala-compiler-2.12.18.jar; \
    curl -fSL -o /opt/spark/jars/scala-reflect-2.12.18.jar https://repo1.maven.org/maven2/org/scala-lang/scala-reflect/2.12.18/scala-reflect-2.12.18.jar

# Ensure Spark JVM picks up the scala jars
ENV SPARK_DIST_CLASSPATH=/opt/spark/jars/scala-library-2.12.18.jar:/opt/spark/jars/scala-reflect-2.12.18.jar:/opt/spark/jars/scala-compiler-2.12.18.jar

# Add spark binaries to shell and enable execution
RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*
ENV PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"

# Add a spark config for all nodes
COPY conf/spark-defaults.conf "$SPARK_HOME/conf/"


FROM spark-base AS pyspark

# # Install python deps
# COPY requirements.txt .
# RUN pip3 install -r requirements.txt


FROM spark-base AS pyspark-runner

# Download iceberg spark runtime
RUN curl https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.4_2.12/1.4.3/iceberg-spark-runtime-3.4_2.12-1.4.3.jar -Lo /opt/spark/jars/iceberg-spark-runtime-3.4_2.12-1.4.3.jar

# Download delta jars
RUN curl https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.4.0/delta-core_2.12-2.4.0.jar -Lo /opt/spark/jars/delta-core_2.12-2.4.0.jar
RUN curl https://repo1.maven.org/maven2/io/delta/delta-spark_2.12/3.2.0/delta-spark_2.12-3.2.0.jar -Lo /opt/spark/jars/delta-spark_2.12-3.2.0.jar
RUN curl https://repo1.maven.org/maven2/io/delta/delta-storage/3.2.0/delta-storage-3.2.0.jar -Lo /opt/spark/jars/delta-storage-3.2.0.jar

# Download hudi jars
RUN curl https://repo1.maven.org/maven2/org/apache/hudi/hudi-spark3-bundle_2.12/0.15.0/hudi-spark3-bundle_2.12-0.15.0.jar -Lo /opt/spark/jars/hudi-spark3-bundle_2.12-0.15.0.jar

COPY entrypoint.sh .
RUN chmod u+x /opt/spark/entrypoint.sh


# Optionally install Jupyter
# FROM pyspark-runner AS pyspark-jupyter

# RUN pip3 install notebook

# ENV JUPYTER_PORT=8889

# ENV PYSPARK_DRIVER_PYTHON=jupyter
# ENV PYSPARK_DRIVER_PYTHON_OPTS="notebook --no-browser --allow-root --ip=0.0.0.0 --port=${JUPYTER_PORT}"
# # --ip=0.0.0.0 - listen all interfaces
# # --port=${JUPYTER_PORT} - listen ip on port 8889
# # --allow-root - to run Jupyter in this container by root user. It is adviced to change the user to non-root.


ENTRYPOINT ["./entrypoint.sh"]
CMD [ "bash" ]

# Now go to interactive shell mode
# -$ docker exec -it spark-master /bin/bash 
# then execute
# -$ pyspark

# If Jupyter is installed, you will see an URL: `http://127.0.0.1:8889/?token=...`
# This will open Jupyter web UI in your host machine browser.
# Then go to /warehouse/ and test the installation.
