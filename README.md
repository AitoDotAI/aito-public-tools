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

