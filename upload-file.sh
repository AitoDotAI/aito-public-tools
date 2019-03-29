#!/bin/bash

set -e

# The script assumes:
#  1. You have created an Aito database schema
#  2. Your read-write environment API key is defined as API_KEY environment variable
#  3. "jq" is installed https://stedolan.github.io/jq/.

if [[ -z "$1" ]]; then
  echo "Example usage: ./upload-file.sh products.ndjson https://your-env-name.api.aito.ai" >&2
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

# Parse user input parameteres

# https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
FILENAME=$(basename -- "$1")

EXTENSION="${FILENAME##*.}"
FILENAME="${FILENAME%.*}"

# Remove possible trailing slash from base url
BASE_URL="$2"
BASE_URL_LENGTH=${#BASE_URL}
BASE_URL_LAST_CHAR=${BASE_URL:BASE_URL_LENGTH-1:1}
[[ "$BASE_URL_LAST_CHAR" == "/" ]] && BASE_URL=${BASE_URL:0:BASE_URL_LENGTH-1}; :

AITO_TABLE="$FILENAME"

echo "Uploading file $1 to table \"$AITO_TABLE\" at $BASE_URL .."

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

# Compress data
gzip -c "$1" > .aitotmp/compressed

echo "Initiate file upload .."

curl -sS -H "x-api-key: $API_KEY" -X POST "$BASE_URL/api/v1/data/$AITO_TABLE/file" > .aitotmp/file-res.json

echo "Upload data .."
curl -sS -X $(cat .aitotmp/file-res.json | jq -r '.method') -T .aitotmp/compressed "$(cat .aitotmp/file-res.json | jq -r '.url')" > /dev/null

echo "Trigger file processing .."
curl -sS -H "x-api-key: $API_KEY" -X POST "$BASE_URL/api/v1/data/$AITO_TABLE/file/$(cat .aitotmp/file-res.json | jq -r '.id')" > /dev/null

echo "Loop for status .."
while true; do
  curl -sS -H"x-api-key: $API_KEY" "$BASE_URL/api/v1/data/$AITO_TABLE/file/$(cat .aitotmp/file-res.json | jq -r '.id')" > .aitotmp/poll-res.json
  cat .aitotmp/poll-res.json | jq
  echo ""

  if [ "$(cat .aitotmp/poll-res.json | jq -r '.status.finished')" == "true" ]; then
    break;
  fi

  sleep 2
done

echo -e "\n\nFile upload done."
