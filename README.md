# Elasticsearch Demo

Run the following
- `git clone https://github.com/deviantony/docker-elk.git`
- `cd docker-elk && docker-compose up -d && cd ..`
- Wait for Kibana to be up and running at `localhost:5601`
- `git clone git@github.com:cocotton/elasticsearch-demo.git && cd elasticsearch-demo && ./setup.sh`
- In Kibana: Management -> Saved Objects -> Import -> Choose the export.json file from the elasticsearch-demo repository
