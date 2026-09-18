import pandas as pd
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
SALES = BASE / "sales"
OUT = BASE / "curated" / "sales"

OUT.mkdir(parents=True, exist_ok=True)

files = list(SALES.glob("*.csv"))
print("CSV files found:", len(files))

for i, file in enumerate(files, 1):
    name = file.stem
    parts = name.split("_")
    store = parts[1]
    date = parts[2]

    year = date[:4]
    month = date[4:6]

    if store in ["S06", "S07", "S08", "S09"]:
        df = pd.read_csv(file, sep=";")
        df = df.rename(columns={
            "item_code": "product_code",
            "quantity": "qty",
            "rate": "unit_price",
            "type": "line_type",
            "txn_time": "ts"
        })
    else:
        df = pd.read_csv(file, encoding="utf-8-sig")

        if "txn_time" in df.columns:
            df = df.rename(columns={
                "item_code": "product_code",
                "quantity": "qty",
                "rate": "unit_price",
                "type": "line_type",
                "txn_time": "ts"
            })

    df["ts"] = pd.to_datetime(df["ts"], format="mixed", dayfirst=True)

    output_dir = OUT / f"year={year}" / f"month={month}" / f"store={store}"
    output_dir.mkdir(parents=True, exist_ok=True)

    output_file = output_dir / f"{name}.parquet"
    df.to_parquet(output_file, index=False)

    if i % 250 == 0:
        print(f"Processed {i}/{len(files)}")

print("DONE")
