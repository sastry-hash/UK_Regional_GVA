uk-regional-gva-data-warehouse/
│
├── README.md
├── .gitignore
│
├── docs/
│   ├── data_dictionary.md
│   ├── technical_challenges.md
│   └── setup_guide.md
│
├── python/
│   └── 01_prepare_data.py
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_bronze_load.sql
│   ├── 03_silver_transform.sql
│   ├── 04_gold_star_schema.sql
│   ├── 05_reporting_views.sql
│   ├── 06_stored_procedure_indexes.sql
│   └── 07_validation.sql
│
├── power_bi/
│   ├── README.md
│   └── measures.dax
│
└── screenshots/
    ├── regional_overview.png
    ├── industry_performance.png
    └── covid_impact.png
