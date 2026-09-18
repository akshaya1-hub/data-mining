import duckdb

con = duckdb.connect("shopsphere.duckdb")

con.execute("INSTALL postgres")
con.execute("LOAD postgres")

con.execute("""
ATTACH 'dbname=shopsphere user=shopsphere password=shopsphere host=localhost port=5432'
AS pg (TYPE POSTGRES, READ_ONLY)
""")

print("Stores:", con.execute("SELECT COUNT(*) FROM pg.stores").fetchone()[0])
print("Products:", con.execute("SELECT COUNT(*) FROM pg.products").fetchone()[0])
print("Categories:", con.execute("SELECT COUNT(*) FROM pg.product_categories").fetchone()[0])
print("Price revisions:", con.execute("SELECT COUNT(*) FROM pg.price_revisions").fetchone()[0])

con.close()
