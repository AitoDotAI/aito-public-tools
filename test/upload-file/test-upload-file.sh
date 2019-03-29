#!/bin/bash

set -e

echo -e "Resetting aito database .."

# Delete contents
curl -sS -H "x-api-key: $API_KEY" -X DELETE "https://aito-tools.api.aito.ai/api/v1/schema" > /dev/null

# Create schema
curl -sS -H "x-api-key: $API_KEY" -H "content-type: application/json" -d@test/upload-file/schema.json -X PUT "https://aito-tools.api.aito.ai/api/v1/schema" > /dev/null

echo -e "Done.\n"

# Here we also test that the script is able to remove trailing slash from base url
./upload-file.sh test/upload-file/products.ndjson https://aito-tools.api.aito.ai/

# Verify that correct data has been uploaded
curl -sS -X POST \
  -H "x-api-key: $API_KEY" \
  -H "content-type: application/json" \
  "https://aito-tools.api.aito.ai/api/v1/_search" \
  -d '{"from": "products"}' > .products-res.json

if [[ $(diff <(jq -S . .products-res.json) <(jq -S . test/upload-file/expected-response.json)) ]]; then
    echo -e "\n\nAssertion error: unexpected response:\n"
    diff <(jq -S . .products-res.json) <(jq -S . test/upload-file/expected-response.json)
    exit 2
fi

rm .products-res.json

echo "Test passed."
