#!/bin/sh

elasticuser="$1"
elasticpass="$2"

echo "=== Updating logstash_system user's password"
# We need to setup the logstash_system user's password once the cluster has been created
# For demo purposes, we'll use the same password as the elasticsearch password
curl --user "${elasticuser}:${elasticpass}" -XPUT -H 'Content-Type: application/json' 'localhost:9200/_xpack/security/user/logstash_system/_password' -d\
'{
  "password": "'"${elasticpass}"'"
}'
echo "\n=== Done\n"

echo "=== Uncompressing data files"
# Uncompressed the test data files
unzip -o data/accounts.zip -d data
gunzip -f -k data/logs.jsonl.gz
echo "=== Done\n"


echo "=== Creating mappings"
curl --user "${elasticuser}:${elasticpass}" -XPUT -H 'Content-Type: application/json' 'localhost:9200/shakespeare' -d\
'{
  "mappings": {
  "doc": {
   "properties": {
    "speaker": {"type": "keyword"},
    "play_name": {"type": "keyword"},
    "line_id": {"type": "integer"},
    "speech_number": {"type": "integer"}
   }
  }
 }
}' && echo ""

for i in 18 19 20
do
curl --user "${elasticuser}:${elasticpass}" -XPUT -H 'Content-Type: application/json' "localhost:9200/logstash-2015.05.$i" -d\
'{
  "mappings": {
    "log": {
      "properties": {
        "geo": {
          "properties": {
            "coordinates": {
              "type": "geo_point"
            }
          }
        }
      }
    }
  }
}' && echo ""
done
echo "=== Done\n"

echo "=== Upload test data"
curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/x-ndjson' 'localhost:9200/bank/account/_bulk?pretty' --data-binary @data/accounts.json
curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/x-ndjson' 'localhost:9200/shakespeare/doc/_bulk?pretty' --data-binary @data/shakespeare_6.0.json
curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/x-ndjson' 'localhost:9200/_bulk?pretty' --data-binary @data/logs.jsonl
echo "=== Done\n"
