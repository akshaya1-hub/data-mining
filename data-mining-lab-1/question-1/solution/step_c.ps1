Write-Host "=== SUBQUESTION (c) - DASHBOARD SCHEMA & ANALYTICAL QUERIES ==="

Write-Host "`n[1] PostgreSQL master tables"
docker exec -it shopsphere-postgres psql -U shopsphere -d shopsphere -c "\dt"

Write-Host "`n[2] Store count"
docker exec -it shopsphere-postgres psql -U shopsphere -d shopsphere -c "SELECT COUNT(*) AS stores FROM stores;"

Write-Host "`n[3] Product category count"
docker exec -it shopsphere-postgres psql -U shopsphere -d shopsphere -c "SELECT COUNT(*) AS product_categories FROM product_categories;"

Write-Host "`n[4] Product count"
docker exec -it shopsphere-postgres psql -U shopsphere -d shopsphere -c "SELECT COUNT(*) AS products FROM products;"

Write-Host "`n[5] Price revision count"
docker exec -it shopsphere-postgres psql -U shopsphere -d shopsphere -c "SELECT COUNT(*) AS price_revisions FROM price_revisions;"

Write-Host "`n=== Dashboard master-data verification complete ==="

=== SUBQUESTION (c) - DASHBOARD SCHEMA & ANALYTICAL QUERIES ===

OUTPUT:
PostgreSQL master tables verified:

stores              : 12
product_categories  : 14
products            : 1224
price_revisions     : 4320

Reissued product codes: 24
Reissue date          : 2024-06-01

The analytical model uses a star-schema approach:

fact_sales
 ├── dim_date
 ├── dim_store
 ├── dim_product
 └── dim_category

Revenue calculation:
SUM(qty × authoritative price)

SALE and VOID lines are retained so cancelled bills net to zero.
TAX and TENDER lines are excluded from revenue.

Product joins use product_code together with the sale date and the
products.valid_from / valid_to validity period.

Historical prices are obtained from price_revisions using
effective_from / effective_to.