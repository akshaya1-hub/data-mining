import duckdb

con = duckdb.connect("shopsphere.duckdb")
con.execute("LOAD httpfs")

con.execute("""
CREATE OR REPLACE SECRET minio (
    TYPE S3,
    KEY_ID 'admin',
    SECRET 'minioadmin',
    REGION 'us-east-1',
    ENDPOINT 'localhost:9000',
    URL_STYLE 'path',
    USE_SSL false
)
""")

result = con.execute("""
SELECT
    store,
    SUM(qty * unit_price) AS net_revenue
FROM read_parquet(
    's3://shopsphere/curated/sales/**/*.parquet',
    hive_partitioning=true
)
WHERE line_type NOT IN ('TAX', 'TENDER')
GROUP BY store
ORDER BY store
""").fetchall()

for row in result:
    print(row)

con.close()
