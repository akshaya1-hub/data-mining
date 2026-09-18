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
ATTACH 'dbname=shopsphere user=shopsphere password=shopsphere host=localhost port=5432'
AS pg (TYPE POSTGRES, READ_ONLY)
""")

con.execute("""
CREATE OR REPLACE VIEW dim_store AS
SELECT * FROM pg.stores
""")

con.execute("""
CREATE OR REPLACE VIEW dim_product AS
SELECT * FROM pg.products
""")

con.execute("""
CREATE OR REPLACE VIEW dim_category AS
SELECT * FROM pg.product_categories
""")

con.execute("""
CREATE OR REPLACE VIEW fact_sales AS
SELECT
    s.bill_no,
    s.line_no,
    s.product_code,
    s.qty,
    s.unit_price,
    s.line_type,
    s.ts,
    s.year,
    s.month,
    s.store
FROM read_parquet(
    's3://shopsphere/curated/sales/**/*.parquet',
    hive_partitioning=true
) s
""")

print("Star-schema views created")
print("Stores:", con.execute("SELECT COUNT(*) FROM dim_store").fetchone()[0])
print("Products:", con.execute("SELECT COUNT(*) FROM dim_product").fetchone()[0])
print("Categories:", con.execute("SELECT COUNT(*) FROM dim_category").fetchone()[0])

con.close()
