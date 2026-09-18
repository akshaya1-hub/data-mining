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

con.execute("""
CREATE OR REPLACE VIEW fact_sales AS
SELECT
    bill_no,
    line_no,
    product_code,
    qty,
    unit_price,
    line_type,
    ts,
    year,
    month,
    store
FROM read_parquet(
    's3://shopsphere/curated/sales/**/*.parquet',
    hive_partitioning=true
)
""")

print("fact_sales view created")
print("Rows:", con.execute("SELECT COUNT(*) FROM fact_sales").fetchone()[0])

con.close()
