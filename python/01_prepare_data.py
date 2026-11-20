
"""
Project: UK Regional GVA Data Warehouse
File: 01_prepare_data.py

Purpose:
- Profile and validate prepared ONS GVA data
- Standardise data types and text fields
- Check duplicate records and missing values
- Export pipe-delimited data for SQL Server

Period: 1998–2023

Dependencies:
    pip install pandas
"""

from pathlib import Path
import pandas as pd


# ==========================================
# 1. FILE CONFIGURATION
# ==========================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_FILE = BASE_DIR / "data" / "regional_gva_cleaned.csv"

OUTPUT_DIR = BASE_DIR / "data" / "processed"

OUTPUT_FILE = (
    OUTPUT_DIR / "regional_gva_cleaned_pipe.csv"
)

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


# ==========================================
# 2. LOAD DATASET
# ==========================================

print("Loading UK Regional GVA dataset...")

df = pd.read_csv(
    INPUT_FILE,
    dtype={
        "ITLCode": "string",
        "RegionName": "string",
        "GeographyLevel": "string",
        "SIC07Code": "string",
        "SIC07Description": "string",
        "IndustryLevel": "string"
    },
    encoding="utf-8-sig"
)

print("Initial shape:", df.shape)


# ==========================================
# 3. STANDARDISE COLUMN NAMES
# ==========================================

column_mapping = {
    "itl_code": "ITLCode",
    "region_name": "RegionName",
    "geography_level": "GeographyLevel",
    "sic07_code": "SIC07Code",
    "sic07_description": "SIC07Description",
    "industry_level": "IndustryLevel",
    "year": "Year",
    "gva_million_gbp": "GVAMillionGBP"
}

df = df.rename(columns=column_mapping)

required_columns = [
    "ITLCode",
    "RegionName",
    "GeographyLevel",
    "SIC07Code",
    "SIC07Description",
    "IndustryLevel",
    "Year",
    "GVAMillionGBP"
]

missing_columns = [
    col for col in required_columns
    if col not in df.columns
]

if missing_columns:
    raise ValueError(
        f"Missing required columns: {missing_columns}"
    )

df = df[required_columns].copy()


# ==========================================
# 4. CLEAN TEXT COLUMNS
# ==========================================

text_columns = [
    "ITLCode",
    "RegionName",
    "GeographyLevel",
    "SIC07Code",
    "SIC07Description",
    "IndustryLevel"
]

for col in text_columns:
    df[col] = (
        df[col]
        .astype("string")
        .str.strip()
    )

    df[col] = df[col].replace("", pd.NA)


# ==========================================
# 5. CONVERT NUMERIC COLUMNS
# ==========================================

df["Year"] = pd.to_numeric(
    df["Year"],
    errors="coerce"
)

df["GVAMillionGBP"] = pd.to_numeric(
    df["GVAMillionGBP"],
    errors="coerce"
)


# ==========================================
# 6. DATA QUALITY VALIDATION
# ==========================================

print("\nDATA QUALITY REPORT")
print("-" * 40)

print("Missing values:")
print(df.isna().sum())

print("\nDuplicate business keys:")

business_keys = [
    "ITLCode",
    "SIC07Code",
    "Year"
]

duplicate_count = df.duplicated(
    subset=business_keys
).sum()

print(duplicate_count)

print("\nYear range:")
print(df["Year"].min(), "-", df["Year"].max())

print("\nGeographic entities:")
print(df["ITLCode"].nunique())

print("\nSIC07 codes:")
print(df["SIC07Code"].nunique())


# ==========================================
# 7. VALIDATE REQUIRED VALUES
# ==========================================

if df[required_columns].isna().any().any():
    raise ValueError(
        "Missing or invalid required values detected."
    )

if duplicate_count > 0:
    raise ValueError(
        "Duplicate region-industry-year keys detected."
    )

if not df["Year"].between(1998, 2023).all():
    raise ValueError(
        "Records outside 1998–2023 detected."
    )

if not (df["Year"] % 1 == 0).all():
    raise ValueError(
        "Non-integer reporting years detected."
    )

if (df["GVAMillionGBP"] < 0).any():
    raise ValueError(
        "Negative GVA values detected."
    )


# ==========================================
# 8. CONVERT YEAR TO INTEGER
# ==========================================

df["Year"] = df["Year"].astype(int)


# ==========================================
# 9. SORT DATA
# ==========================================

df = df.sort_values(
    by=["ITLCode", "SIC07Code", "Year"]
).reset_index(drop=True)


# ==========================================
# 10. DATASET SUMMARY
# ==========================================

print("\nFINAL DATASET SUMMARY")
print("-" * 40)

print("Total records:", len(df))
print("Reporting years:", df["Year"].nunique())
print("Geographic entities:", df["ITLCode"].nunique())
print("Industry codes:", df["SIC07Code"].nunique())


# ==========================================
# 11. EXPORT FOR SQL SERVER
# ==========================================

df.to_csv(
    OUTPUT_FILE,
    sep="|",
    index=False,
    encoding="utf-8",
    lineterminator="\n",
    float_format="%.2f"
)

print("\nExport successful!")
print("Output:", OUTPUT_FILE)

print("\nReady for SQL Server Bronze ingestion.")
