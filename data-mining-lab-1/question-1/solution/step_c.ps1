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