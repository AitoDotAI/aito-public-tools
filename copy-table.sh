#!/bin/bash

set -e

# The script assumes:
#  1. You have created an Aito database schema
#  2. Your read-write environment API key is defined as API_KEY environment variable
#  3. "jq" is installed https://stedolan.github.io/jq/.

if [[ -z "$1" ]]; then
  echo "Example usage: ./copy-table.sh your-env-name products" >&2
  exit 1
fi

if [[ -z "$API_KEY" ]]; then
  echo "API_KEY environment variable is not defined. Exiting .." >&2
  exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  echo "Error: jq is not installed." >&2
  exit 1
fi

AITO_ENV="$1"
AITO_TABLE="$2"


if [ -d ".aitotmp" ]; then
  echo ".aitotmp directory already exists, refusing to run."
  echo "You can manually delete the directory and try running again."
  echo "Exiting .."
  exit 1
fi

echo "Creating .aitotmp working directory .."
mkdir .aitotmp

function cleanup {
  echo "Removing .aitotmp working directory .."
  rm -r .aitotmp
  exit 0
}
trap cleanup EXIT


curl -X POST \
  https://$AITO_ENV.api.aito.ai/api/v1/_search \
  -H 'content-type: application/json' \
  -H "x-api-key: $API_KEY" \
  -d "
  {
    \"from\": \"$AITO_TABLE\",
    \"limit\": 1
  }" | jq -r '.total' > .aitotmp/totalrows

TOTAL_ROWS=$(cat .aitotmp/totalrows)

BATCH_SIZE=500
COUNTER=0
while [  $COUNTER -lt $(($TOTAL_ROWS)) ]; do
  curl -X POST \
    https://$AITO_ENV.api.aito.ai/api/v1/_search \
    -H 'content-type: application/json' \
    -H "x-api-key: $API_KEY" \
    -d "
    {
      \"from\": \"$AITO_TABLE\",
      \"limit\": $BATCH_SIZE,
      \"offset\": $COUNTER
    }" | jq -c '.hits[]'

  let COUNTER=COUNTER+BATCH_SIZE
done
