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

OUTPUT:
┌─────────┬────────────┬─────────────┬──────────────────────────────────┐
│  month  │ closed_on  │ revenue_inr │          signed_off_by           │
│ varchar │    date    │   double    │             varchar              │
├─────────┼────────────┼─────────────┼──────────────────────────────────┤
│ 2024-01 │ 2024-02-09 │ 38446071.33 │ A. Krishnan (Finance Controller) │
│ 2024-02 │ 2024-03-11 │ 34887085.55 │ A. Krishnan (Finance Controller) │
│ 2024-03 │ 2024-04-09 │ 42457899.09 │ A. Krishnan (Finance Controller) │
│ 2024-04 │ 2024-05-10 │ 37958457.37 │ A. Krishnan (Finance Controller) │
│ 2024-05 │ 2024-06-09 │  41764716.4 │ A. Krishnan (Finance Controller) │
└─────────┴────────────┴─────────────┴──────────────────────────────────┘

┌─────────┬─────────────────┬────────────────┬────────────┐
│  month  │ finance_revenue │ folder_revenue │ difference │
│ varchar │     double      │ decimal(12,2)  │   double   │
├─────────┼─────────────────┼────────────────┼────────────┤
│ 2024-01 │     38446071.33 │    38446071.33 │        0.0 │
│ 2024-02 │     34887085.55 │    34887085.55 │        0.0 │
│ 2024-03 │     42457899.09 │    41971649.09 │   486250.0 │
│ 2024-04 │     37958457.37 │    37958457.37 │        0.0 │
│ 2024-05 │      41764716.4 │    41764716.40 │        0.0 │
│ 2024-06 │     38987082.82 │    38987082.82 │        0.0 │
│ 2024-07 │     40527291.81 │    40295160.11 │   232131.7 │
│ 2024-08 │     45252181.75 │    45252181.75 │        0.0 │
│ 2024-09 │     44615037.46 │    44615037.46 │        0.0 │
│ 2024-10 │     56359195.92 │    56359195.92 │        0.0 │
│ 2024-11 │     51583838.47 │    51583838.47 │        0.0 │
│ 2024-12 │      50745209.0 │    50745259.48 │     -50.48 │
└─────────┴─────────────────┴────────────────┴────────────┘

========== PART (D) – MONTHLY RECONCILIATION ==========

The monthly revenue calculated from the sales folder was
compared with the signed-off finance_monthly.csv values.

January, February, April, May, June, August, September,
October and November match exactly.

March:
Finance revenue is higher by ₹486,250.00.
This is explained by the institutional bulk invoice of
₹486,250 that was invoiced outside the till data.
This is a scope difference rather than a sales-file error.

July:
Finance revenue is higher by ₹232,131.70.
The sales folder is missing S07 exports for:
2024-07-09
2024-07-10
2024-07-11
This is a source-data completeness issue.

December:
The folder revenue is higher by ₹50.48.
Finance rounds each bill to the nearest rupee, while the
folder calculation retains the more precise values.
This is a revenue-definition/rounding difference.

The differences should therefore be taken back to Finance as:
1. March – scope difference due to institutional billing.
2. July – missing S07 source files.
3. December – bill-level rounding difference.

