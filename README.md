# Layoffs Data Cleaning & Exploratory Data Analysis | SQL

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-336791?style=for-the-badge)
![Data Cleaning](https://img.shields.io/badge/Data_Cleaning-A366B0?style=for-the-badge)
![EDA](https://img.shields.io/badge/EDA-E0909A?style=for-the-badge)

A SQL project that cleans a raw, messy layoffs dataset and then explores it. The cleaning turns the raw table into an accurate, consistent dataset that is ready for analysis, and the exploratory analysis (EDA) answers questions about layoffs by company, industry, country, stage and time.

<img width="2175" height="498" alt="Image" src="https://github.com/user-attachments/assets/c26b4f38-e83f-4318-81b8-57c1b3dc34fe" />

---

## Project Overview

Data cleaning is an essential step in any analysis, because wrong, duplicated or inconsistent data leads to wrong conclusions. This project works entirely in SQL (MySQL) and follows a repeatable process:

1. Keep the raw data safe by working on a staging copy
2. Remove duplicate records
3. Standardise text values and fix data types
4. Handle NULL and blank values
5. Remove rows and columns that are not useful
6. Validate the result, then analyse it

---

## Dataset

**Source:** [Layoffs 2022 on Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022)

| Column | Description |
| --- | --- |
| company | Company that announced the layoffs |
| location | City / region of the company |
| industry | Industry the company works in |
| total_laid_off | Number of employees laid off |
| percentage_laid_off | Share of the workforce laid off |
| date | Date of the layoff announcement |
| stage | Funding stage of the company (Seed, Series A, Post-IPO, etc.) |
| country | Country of the company |
| funds_raised_millions | Funding raised by the company, in millions of USD |

The raw CSV is not stored in this repo. See [`data/README.md`](data/README.md) for how to download it.

---

## Features

| Feature | How it is done in this project |
| --- | --- |
| **Data import** | Raw CSV loaded into a MySQL table (`layoffs`) with the Table Data Import Wizard |
| **Duplicate removal** | `ROW_NUMBER()` window function partitioned across every column; rows with a row number above 1 are deleted |
| **Data standardisation** | `TRIM` to remove extra spaces in company names, merging the different spellings of "Crypto" into one value, and removing the trailing period from "United States." |
| **Data type conversion** | The date column is converted from text to a real `DATE` using `STR_TO_DATE` and `ALTER TABLE ... MODIFY COLUMN` |
| **Missing value treatment** | Blank industries are set to NULL, then filled from other rows of the same company using a self-join. Rows where both `total_laid_off` and `percentage_laid_off` are missing are removed because they cannot be used. Other NULLs are kept so calculations stay accurate |
| **Data validation** | Final checks for remaining duplicates, rows with both measures missing, column data type, and raw vs cleaned row counts |

---

## Cleaning Process

The work is done on copies of the raw table, so the original data is never changed.

| Step | What is done | SQL used |
| --- | --- | --- |
| 1. Staging | Copy the raw table to `layoffs_staging` and work on the copy | `CREATE TABLE ... LIKE`, `INSERT ... SELECT` |
| 2. Duplicates | Number each row across all columns, copy into `layoffs_staging2` with a `row_num` column, and delete rows where `row_num > 1` | CTE, `ROW_NUMBER() OVER (PARTITION BY ...)`, `DELETE` |
| 3. Standardise | Trim company names, unify "Crypto" variants, fix "United States." | `TRIM`, `LIKE`, `UPDATE`, `TRIM(TRAILING '.' FROM ...)` |
| 4. Dates | Convert text dates to the `DATE` type | `STR_TO_DATE`, `ALTER TABLE` |
| 5. NULL and blanks | Fill missing industry from the same company, check the rest | `UPDATE` with self `JOIN` |
| 6. Remove unusable data | Delete rows with no layoff numbers, drop the helper `row_num` column | `DELETE`, `ALTER TABLE ... DROP COLUMN` |
| 7. Validate | Confirm the result is clean | Count and check queries |

---

## Exploratory Data Analysis

After cleaning, `02_exploratory_data_analysis.sql` explores the data:

- Period covered, row count, and the largest single layoff
- Companies that laid off 100% of their staff, ordered by funding raised
- Total layoffs by **company, industry, country and funding stage**
- Layoffs by **year** and by **month**, with a **rolling total**
- **Top 5 companies per year** using `DENSE_RANK()`
- Layoffs by industry and year

---

## Repository Structure

```
Layoffs-Data-Cleaning-and-EDA-SQL/
├── README.md
├── data/
│   └── README.md                         how to get the dataset
├── sql/
│   ├── 01_data_cleaning.sql              cleaning steps
│   └── 02_exploratory_data_analysis.sql  EDA queries
└── images/
    └── cleaning-workflow.png
```

---

## How to Run

You need **MySQL 8.0 or later** (the scripts use CTEs and window functions) and MySQL Workbench.

1. Download `layoffs.csv` from the [Kaggle dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022).
2. In MySQL Workbench, create the database:
   ```sql
   CREATE DATABASE world_layoffs;
   ```
3. Import the CSV: right-click **Tables** under `world_layoffs` → **Table Data Import Wizard** → choose the CSV → name the new table `layoffs`. Keep the `date` column as text, because the cleaning script converts it.
4. Run `sql/01_data_cleaning.sql`. It creates `layoffs_staging` and `layoffs_staging2` and cleans the data.
5. Run `sql/02_exploratory_data_analysis.sql` to explore the cleaned table.

---

## Skills Demonstrated

- Data cleaning in SQL: duplicates, standardisation, data types, NULL handling
- Window functions: `ROW_NUMBER`, `DENSE_RANK`, rolling totals
- CTEs, self-joins, subqueries and aggregation
- Working on a staging table to protect raw data
- Exploratory analysis and asking business questions of a dataset

---

## Notes

- `percentage_laid_off` is stored as text in the source data, so the EDA converts it with `CAST` before comparing or taking a maximum.
- Rows with both `total_laid_off` and `percentage_laid_off` missing are deleted, since they contain no usable layoff information.
- Results depend on the version of the dataset you download.

---

## Credits

Dataset: Layoffs 2022 by swaptr on [Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022).

## Author

**Mohammed Tabrez Ali Khan** · Data Analyst
Riyadh, Saudi Arabia · [LinkedIn](https://www.linkedin.com/in/md-tabrez-ali-khan) · mdtabrezalik@gmail.com
