import hashlib
from pathlib import Path
import pandas as pd

BASE = Path(__file__).resolve().parent.parent
CURATED = BASE / "curated" / "sales"

total_rows = 0
sha = hashlib.sha256()

files = sorted(CURATED.rglob("*.parquet"))

for file in files:
    df = pd.read_parquet(file)

    total_rows += len(df)

    # Deterministic checksum
    data = df.to_csv(index=False).encode("utf-8")
    sha.update(data)

print("Curated Parquet files :", len(files))
print("Total rows            :", total_rows)
print("SHA-256 checksum      :", sha.hexdigest())