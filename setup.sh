#!/bin/sh

elasticuser="$1"
elasticpass="$2"

# We need to setup the logstash_system user password once the cluster has been created
# For demo purposes, we'll use the same password as the elasticsearch password
curl --user "${elasticuser}:${elasticpass}" -XPUT -H 'Content-Type: application/json' 'localhost:9200/_xpack/security/user/logstash_system/_password' -d\
'{
  "password": "'"${elasticpass}"'"
}'

# Uncompressed the test data files
unzip data/accounts.zip -d data
gunzip data/logs.jsonl.gz
