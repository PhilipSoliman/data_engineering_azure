#!/bin/bash
set -e

echo "[init] downloading sample CSVs to /tmp..."
wget -q -O /tmp/customer_reviews_1998.csv.gz http://examples.citusdata.com/customer_reviews_1998.csv.gz || true
wget -q -O /tmp/customer_reviews_1999.csv.gz http://examples.citusdata.com/customer_reviews_1999.csv.gz || true

echo "[init] handling decompression..."
for f in /tmp/customer_reviews_1998.csv.gz /tmp/customer_reviews_1999.csv.gz; do
  if [ -f "$f" ]; then
    gunzip -c "$f"; 
  fi
done

echo "[init] download complete. files available in /tmp"
