#!/bin/sh

elasticuser="$1"
elasticpass="$2"

echo "=== Updating logstash_system user's password ================"
# We need to setup the logstash_system user's password once the cluster has been created
# For demo purposes, we'll use the same password as the elasticsearch password
curl --user "${elasticuser}:${elasticpass}" -XPUT -H 'Content-Type: application/json' 'localhost:9200/_xpack/security/user/logstash_system/_password' -d\
'{
  "password": "'"${elasticpass}"'"
}'
echo "\n=== Done ====================================================\n"

echo "=== Uncompressing data files ================================"
# Uncompressed the test data files
unzip -o data/accounts.zip -d data
gunzip -f -k data/logs.jsonl.gz
echo "=== Done ====================================================\n"



