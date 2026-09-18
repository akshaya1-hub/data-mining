Write-Host "=== ShopSphere - Subquestion (a) ==="

Write-Host "`nDocker containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host "`nRaw CSV file count:"
docker exec shopsphere-minio mc find local/shopsphere/raw --name "*.csv" | Measure-Object

Write-Host "`nCurated Parquet file count:"
docker exec shopsphere-minio mc find local/shopsphere/curated/sales --name "*.parquet" | Measure-Object

OUTPUT:
=== SUBQUESTION (a) - INFRASTRUCTURE & OBJECT STORE ===

PostgreSQL container : shopsphere-postgres
MinIO container      : shopsphere-minio

Raw CSV files         : 4457
Curated Parquet files : 4457

Object store bucket:
shopsphere

Raw path:
shopsphere/raw

Curated path:
shopsphere/curated/sales

Curated partitioning:
year=YYYY/month=MM/store=SXX

Example:
shopsphere/curated/sales/year=2024/month=01/store=S01/

The curated data is partitioned by year, month and store, allowing
queries for one store and month to avoid scanning unrelated partitions.