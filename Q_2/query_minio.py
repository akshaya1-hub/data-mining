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
SELECT COUNT(*)
FROM read_parquet(
    's3://shopsphere/curated/sales/**/*.parquet',
    hive_partitioning=true
)
""").fetchone()

print("Total curated rows:", result[0])

con.close()
