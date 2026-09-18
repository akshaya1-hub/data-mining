import duckdb

con = duckdb.connect("shopsphere.duckdb")
con.execute("LOAD httpfs")
con.execute("LOAD postgres")

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
ATTACH 'host=localhost port=5432 dbname=shopsphere user=shopsphere password=shopsphere'
AS pg (TYPE POSTGRES, READ_ONLY)
""")

rows = con.execute("""
SELECT
    pc.category_name,
    SUM(s.qty * s.unit_price) AS net_revenue
FROM read_parquet(
    's3://shopsphere/curated/sales/**/*.parquet',
    hive_partitioning=true
) s
JOIN pg.products p
    ON s.product_code = p.product_code
JOIN pg.product_categories pc
    ON p.category_sk = pc.category_sk
WHERE s.line_type NOT IN ('TAX', 'TENDER')
GROUP BY pc.category_name
ORDER BY net_revenue DESC
""").fetchall()

for row in rows:
    print(row)

con.close()
