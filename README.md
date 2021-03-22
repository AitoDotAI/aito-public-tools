**NOTE: This repository is not actively maintained. These features are covered by the [Aito Python SDK and CLI](https://aito-python-sdk.readthedocs.io/en/stable/cli.html).**

[![CircleCI](https://circleci.com/gh/AitoDotAI/aito-tools.svg?style=svg)](https://circleci.com/gh/AitoDotAI/aito-tools)

# Aito tools

Collection of scripts and tools useful for Aito users.


## [upload-file.sh](./upload-file.sh)

Uploads a single ndjson file to an Aito environment. Executes a [file upload flow](https://aito.ai/docs/api/#post-api-v1-data-table-file).
Requires [jq](https://stedolan.github.io/jq/) command-line tool.

**Example usage:**

In the example we upload products to Aito.

1. [Create a schema](https://aito.ai/docs/api/#put-api-v1-schema) to the Aito database

    ```bash
    curl -H "x-api-key: $API_KEY" -d@schema.json -X POST "https://my-aito-env.api.aito.ai/api/v1/schema"
    ```

    See the example [schema.json](test/upload-file/schema.json) contents.

2. Run upload file script

    ```bash
    ./upload-file.sh products.ndjson https://my-aito-env.api.aito.ai
    ```

    This would upload products.ndjson to a `products` table in https://my-aito-env.api.aito.ai.
    See the example [products.ndjson](test/upload-file/products.ndjson) contents.



## [copy-table.sh](./copy-table.sh)

Outputs all objects from Aito table to stdout as ndjson. Requires [jq](https://stedolan.github.io/jq/) command-line tool.
The table is paginated through with the Search endpoint.

**Example usage:**


```bash
export API_KEY=YOUR_KEY
copy-table.sh your-env-name table > table.ndjson
```
