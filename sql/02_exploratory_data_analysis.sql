-- =====================================================================
-- Project : Layoffs Data Cleaning and Exploratory Data Analysis (EDA)
-- Author  : Mohammed Tabrez Ali Khan
-- Dialect : MySQL 8.0+ (uses CTEs and window functions)
-- Dataset : Layoffs 2022 (Kaggle) - cleaned table layoffs_staging2
-- Run     : after 01_data_cleaning.sql
-- =====================================================================

USE world_layoffs;

-- ---------------------------------------------------------------------
-- 1. Overview of the cleaned data
-- ---------------------------------------------------------------------

SELECT * FROM layoffs_staging2;

-- Number of rows and the period covered
SELECT COUNT(*)    AS total_rows,
       MIN(`date`) AS first_date,
       MAX(`date`) AS last_date
FROM layoffs_staging2;

-- Biggest single layoff and highest percentage laid off
-- (percentage_laid_off is stored as text, so it is converted before MAX)
SELECT MAX(total_laid_off)                            AS max_laid_off,
       MAX(CAST(percentage_laid_off AS DECIMAL(5,2))) AS max_percentage
FROM layoffs_staging2;

-- ---------------------------------------------------------------------
-- 2. Companies that laid off 100% of their staff (they went out of business)
--    Ordered by how much funding they had raised
-- ---------------------------------------------------------------------
SELECT *
FROM layoffs_staging2
WHERE CAST(percentage_laid_off AS DECIMAL(5,2)) = 1
ORDER BY funds_raised_millions DESC;

-- ---------------------------------------------------------------------
-- 3. Total layoffs by company, industry, country and stage
-- ---------------------------------------------------------------------

-- Top 10 companies
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- Layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Layoffs by country
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- Layoffs by company stage (Seed, Series A, Post-IPO, etc.)
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- ---------------------------------------------------------------------
-- 4. Layoffs over time
-- ---------------------------------------------------------------------

-- By year
SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY year;

-- By month, with a rolling (running) total
WITH monthly AS (
    SELECT SUBSTRING(`date`, 1, 7) AS month,
           SUM(total_laid_off)     AS total_laid_off
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY SUBSTRING(`date`, 1, 7)
)
SELECT month,
       total_laid_off,
       SUM(total_laid_off) OVER (ORDER BY month) AS rolling_total
FROM monthly
ORDER BY month;

-- ---------------------------------------------------------------------
-- 5. Top 5 companies by layoffs in each year (ranking with window functions)
-- ---------------------------------------------------------------------
WITH company_year AS (
    SELECT company,
           YEAR(`date`)        AS year,
           SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL AND total_laid_off IS NOT NULL
    GROUP BY company, YEAR(`date`)
),
company_year_rank AS (
    SELECT company, year, total_laid_off,
           DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5
ORDER BY year, ranking;

-- ---------------------------------------------------------------------
-- 6. Industry layoffs by year (which sectors were hit hardest, and when)
-- ---------------------------------------------------------------------
SELECT industry,
       YEAR(`date`)        AS year,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL AND industry IS NOT NULL
GROUP BY industry, YEAR(`date`)
ORDER BY industry, year;
