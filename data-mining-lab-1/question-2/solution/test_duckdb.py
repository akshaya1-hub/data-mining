import duckdb

con = duckdb.connect("shopsphere.duckdb")
con.execute("INSTALL httpfs")
con.execute("LOAD httpfs")

print("DuckDB + httpfs OK")

con.close()
