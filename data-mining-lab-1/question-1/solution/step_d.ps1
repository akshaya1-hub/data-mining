Write-Host "=== SUBQUESTION (d) - CROSS-SYSTEM ANALYTICAL QUERY ==="

duckdb -c @"
INSTALL httpfs;
LOAD httpfs;

CREATE OR REPLACE SECRET minio (
    TYPE S3,
    KEY_ID 'admin',
    SECRET 'minioadmin',
    REGION 'us-east-1',
    ENDPOINT 'localhost:9000',
    URL_STYLE 'path',
    USE_SSL false
);

SELECT
    store,
    COUNT(*) AS rows
FROM read_parquet(
    's3://shopsphere/curated/sales/**/*.parquet',
    hive_partitioning=true
)
GROUP BY store
ORDER BY store;
"@