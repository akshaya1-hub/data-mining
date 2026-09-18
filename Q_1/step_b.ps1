Write-Host "=== SUBQUESTION (b): IDEMPOTENT LOADING ==="

Write-Host "`n--- RUN 1 ---"
python .\scripts\normalize_sales.py

Write-Host "`nCalculating Run 1 statistics..."
python .\scripts\idempotency_check.py

Write-Host "`n--- RUN 2 ---"
python .\scripts\normalize_sales.py

Write-Host "`nCalculating Run 2 statistics..."
python .\scripts\idempotency_check.py

Write-Host "`n--- RUN 3 ---"
python .\scripts\normalize_sales.py

Write-Host "`nCalculating Run 3 statistics..."
python .\scripts\idempotency_check.py

Write-Host "`n=== END OF IDEMPOTENCY TEST ==="

OUTPUT:
=== SUBQUESTION (b) - IDEMPOTENT LOADER ===

Loader: scripts/normalize_sales.py

Three consecutive runs produced identical results.

Run 1:
Curated Parquet files : 4457
Total rows            : 1137585
SHA-256 checksum      : a825afdffddd483c8d3ea1f78c76c58e27d860550b4fcc507a4d4c5db4a66e13

Run 2:
Curated Parquet files : 4457
Total rows            : 1137585
SHA-256 checksum      : a825afdffddd483c8d3ea1f78c76c58e27d860550b4fcc507a4d4c5db4a66e13

Run 3:
Curated Parquet files : 4457
Total rows            : 1137585
SHA-256 checksum      : a825afdffddd483c8d3ea1f78c76c58e27d860550b4fcc507a4d4c5db4a66e13

Result:
All three runs produced the same file count, row count and checksum.
Therefore, the loader is idempotent and safe to re-run.