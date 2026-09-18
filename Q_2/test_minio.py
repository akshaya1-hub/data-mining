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

print("MinIO connection configured")
con.close()
