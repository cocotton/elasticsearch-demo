#!/bin/sh

elasticuser="$1"
elasticpass="$2"

echo "=== Updating logstash_system user's password"
curl --user "${elasticuser}:${elasticpass}" -XPUT -H 'Content-Type: application/json' 'localhost:9200/_xpack/security/user/logstash_system/_password' -d\
'{
  "password": "'"${elasticpass}"'"
}'
echo "\n=== Done\n"

echo "=== Uncompressing data files"
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

echo "=== Uploading test data"
curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/x-ndjson' 'localhost:9200/bank/account/_bulk?pretty' --data-binary @data/accounts.json
curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/x-ndjson' 'localhost:9200/shakespeare/doc/_bulk?pretty' --data-binary @data/shakespeare_6.0.json
curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/x-ndjson' 'localhost:9200/_bulk?pretty' --data-binary @data/logs.jsonl
echo "=== Done\n"

echo "=== Creating test roles"
curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/json' 'localhost:9200/_xpack/security/role/bank_ro' -d\
'{
  "indices": [
    {
      "names": [ "bank*" ],
      "privileges": [ "read" ]
    }
  ]
}' && echo ""

curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/json' 'localhost:9200/_xpack/security/role/bank_ro_no-balance' -d\
'{
  "indices": [
    {
      "names": [ "bank*" ],
      "privileges": [ "read" ],
      "field_security": {
        "grant": [ "*" ],
        "except": [ "balance" ]
      }
    }
  ]
}' && echo ""

curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/json' 'localhost:9200/_xpack/security/role/bank_ro_me-state' -d\
'{
  "indices": [
    {
      "names": [ "bank*" ],
      "privileges": [ "read" ],
      "query": "{\"match\": {\"state\": \"ME\"}}"
    }
  ]
}' && echo ""
echo "=== Done\n"

echo "=== Creating test users"
curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/json' 'localhost:9200/_xpack/security/user/bank_ro' -d\
'{
  "username": "bank_ro",
  "password": "bank_ro",
  "roles": [
    "kibana_user",
    "bank_ro"
  ],
  "full_name": "Bank RO",
  "email": "test@test.test"
}' && echo ""

curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/json' 'localhost:9200/_xpack/security/user/bank_ro_no-balance' -d\
'{
  "username": "bank_ro_no-balance",
  "password": "bank_ro_no-balance",
  "roles": [
    "kibana_user",
    "bank_ro_no-balance"
  ],
  "full_name": "Bank RO No Balance",
  "email": "test@test.test"
}' && echo ""

curl --user "${elasticuser}:${elasticpass}" -XPOST -H 'Content-Type: application/json' 'localhost:9200/_xpack/security/user/bank_ro_me-state' -d\
'{
  "username": "bank_ro_me-state",
  "password": "bank_ro_me-state",
  "roles": [
    "kibana_user",
    "bank_ro_me-state"
  ],
  "full_name": "Bank RO ME State",
  "email": "test@test.test"
}' && echo ""
echo "=== Done\n"
