FROM postgres:15

RUN apt-get update -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y wget gzip \
  && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/*.sh
