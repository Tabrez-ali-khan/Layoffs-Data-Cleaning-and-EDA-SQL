# Data

This project uses the **Layoffs 2022** dataset from Kaggle:
https://www.kaggle.com/datasets/swaptr/layoffs-2022

The raw CSV is not included in this repository because it belongs to its original publisher. To reproduce the project:

1. Download `layoffs.csv` from the Kaggle link above.
2. Import it into MySQL as a table called `layoffs` in a database called `world_layoffs`.
3. Run the scripts in the `sql/` folder in order.

**Columns:** company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
