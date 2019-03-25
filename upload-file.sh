#!/bin/bash

set -e

# The script assumes:
#  1. You have created a Aito database schema and table called "products"
#  2. You have local products.json containing valid data according to the database schema
#  3. You have cli tool "jq" installed https://stedolan.github.io/jq/.

# Initiate file upload
curl -H "x-api-key: $API_KEY" -X POST "https://your-env-name.api.aito.ai/api/v1/data/products/file" > .file-res.json

# Compress data
gzip -c products.json > .products.json.gz

# Upload data
curl -i -X $(cat .file-res.json | jq -r '.method') -T .products.json.gz "$(cat .file-res.json | jq -r '.url')"

# Trigger file processing
curl -i -H "x-api-key: $API_KEY" -X POST "https://your-env-name.api.aito.ai/api/v1/data/products/file/$(cat .file-res.json | jq -r '.id')"

# Loop for status
while true; do
  curl -H"x-api-key: $API_KEY" "https://your-env-name.api.aito.ai/api/v1/data/products/file/$(cat .file-res.json | jq -r '.id')" > .poll-res.json
  cat .poll-res.json

  if [ "$(cat .poll-res.json | jq -r '.status.finished')" == "true" ]; then
    break;
  fi

  sleep 2
done

rm .file-res.json
rm .poll-res.json
rm .products.json.gz

echo -e "\n\nFile upload done."
