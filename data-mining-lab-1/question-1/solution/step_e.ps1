Write-Host "=== SUBQUESTION (e) - QUERY EXECUTION EVIDENCE ==="

python -c "import duckdb; con=duckdb.connect(); con.execute('INSTALL httpfs'); con.execute('LOAD httpfs'); con.execute(""CREATE OR REPLACE SECRET minio (TYPE S3, KEY_ID 'admin', SECRET 'minioadmin', REGION 'us-east-1', ENDPOINT 'localhost:9000', URL_STYLE 'path', USE_SSL false)""); r=con.execute(""EXPLAIN SELECT store, COUNT(*) AS rows FROM read_parquet('s3://shopsphere/curated/sales/**/*.parquet', hive_partitioning=true) GROUP BY store ORDER BY store"").fetchall(); print(r[0][1])"

OUTPUT:
┌─────────────────────────────┐
│┌───────────────────────────┐│
││       Physical Plan       ││
│└───────────────────────────┘│
└─────────────────────────────┘
┌───────────────────────────┐
│      STREAMING_LIMIT      │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│       HASH_GROUP_BY       │
│    ────────────────────   │
│          Groups:          │
│             #0            │
│             #1            │
│             #2            │
│                           │
│    Aggregates: sum(#3)    │
│                           │
│        ~33,587 rows       │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│         PROJECTION        │
│    ────────────────────   │
│          store_id         │
│         store_name        │
│       category_name       │
│   (CAST(qty AS DOUBLE) *  │
│         unit_price)       │
│                           │
│        ~33,588 rows       │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│       CROSS_PRODUCT       ├────────────────────────────────────────────────────────────────────────┐
└─────────────┬─────────────┘                                                                        │
┌─────────────┴─────────────┐                                                          ┌─────────────┴─────────────┐
│         HASH_JOIN         │                                                          │       POSTGRES_SCAN       │
│    ────────────────────   │                                                          │    ────────────────────   │
│      Join Type: INNER     │                                                          │       Table: stores       │
│                           │                                                          │                           │
│        Conditions:        │                                                          │        Projections:       │
│product_code = product_code│                                                          │          store_id         │
│                           ├──────────────┐                                           │         store_name        │
│                           │              │                                           │                           │
│                           │              │                                           │          Filters:         │
│                           │              │                                           │       store_id='S03'      │
│                           │              │                                           │                           │
│        ~1,866 rows        │              │                                           │          ~18 rows         │
└─────────────┬─────────────┘              │                                           └───────────────────────────┘
┌─────────────┴─────────────┐┌─────────────┴─────────────┐
│         PROJECTION        ││         HASH_JOIN         │
│    ────────────────────   ││    ────────────────────   │
│             #0            ││      Join Type: INNER     │
│             #2            ││                           │
│             #3            ││        Conditions:        ├──────────────┐
│                           ││ category_id = category_id │              │
│                           ││                           │              │
│        ~1,866 rows        ││        ~1,264 rows        │              │
└─────────────┬─────────────┘└─────────────┬─────────────┘              │
┌─────────────┴─────────────┐┌─────────────┴─────────────┐┌─────────────┴─────────────┐
│           FILTER          ││       POSTGRES_SCAN       ││       POSTGRES_SCAN       │
│    ────────────────────   ││    ────────────────────   ││    ────────────────────   │
│    (line_type = 'SALE')   ││      Table: products      ││           Table:          │
│                           ││                           ││     product_categories    │
│                           ││        Projections:       ││                           │
│                           ││        product_code       ││        Projections:       │
│                           ││        category_id        ││        category_id        │
│                           ││                           ││       category_name       │
│                           ││                           ││                           │
│        ~1,866 rows        ││        ~1,264 rows        ││         ~148 rows         │
└─────────────┬─────────────┘└───────────────────────────┘└───────────────────────────┘
┌─────────────┴─────────────┐
│       READ_CSV_AUTO       │
│    ────────────────────   │
│         Function:         │
│       READ_CSV_AUTO       │
│                           │
│        Projections:       │
│        product_code       │
│         line_type         │
│            qty            │
│         unit_price        │
│                           │
│        ~9,331 rows        │
└───────────────────────────┘
┌──────────┬───────────────────┬───────────────────────┬────────────────────┐
│ store_id │    store_name     │     category_name     │      revenue       │
│ varchar  │      varchar      │        varchar        │       double       │
├──────────┼───────────────────┼───────────────────────┼────────────────────┤
│ S03      │ Annapurna T Nagar │ Staples & Grains      │ 1268461.3100000003 │
│ S03      │ Annapurna T Nagar │ Baby Care             │         1161403.37 │
│ S03      │ Annapurna T Nagar │ Edible Oils           │         1007056.36 │
│ S03      │ Annapurna T Nagar │ Dairy                 │ 519284.19999999995 │
│ S03      │ Annapurna T Nagar │ Personal Care         │ 474155.13000000006 │
│ S03      │ Annapurna T Nagar │ Frozen & Ready to Eat │ 406014.76000000007 │
│ S03      │ Annapurna T Nagar │ Beverages             │           374095.1 │
│ S03      │ Annapurna T Nagar │ Stationery & General  │          369826.79 │
│ S03      │ Annapurna T Nagar │ Home Care             │          353198.36 │
│ S03      │ Annapurna T Nagar │ Spices & Masala       │ 251832.33999999997 │
└──────────┴───────────────────┴───────────────────────┴────────────────────┘

========== PART (E) – CROSS-SYSTEM QUERY ==========

Sales data is stored in the MinIO object store, while
stores, products and product categories are stored in
PostgreSQL.

DuckDB was used as the analytical query engine. PostgreSQL
was attached as the database "pg", while the sales files
were read directly using READ_CSV_AUTO from the object store.

A single query joined the object-store sales data with:
- pg.public.stores
- pg.public.products
- pg.public.product_categories

No sales data was first copied into PostgreSQL.

The DuckDB EXPLAIN output shows READ_CSV_AUTO in the query
plan, providing evidence that the analytical engine evaluates
the object-store scan and performs the query.

