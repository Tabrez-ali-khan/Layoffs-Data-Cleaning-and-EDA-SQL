-- =====================================================================
-- Project : Layoffs Data Cleaning and Exploratory Data Analysis (EDA)
-- Author  : Mohammed Tabrez Ali Khan
-- Dialect : MySQL 8.0+
-- Dataset : Layoffs 2022 (Kaggle) https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- File 01 : Data cleaning. Run this first, then 02_exploratory_data_analysis.sql
-- Before  : create the database world_layoffs and import layoffs.csv into a
--           table called layoffs (see the README for the steps).
-- =====================================================================

-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

show databases;

use world_layoffs;

SELECT *
FROM layoffs;

-- 1. REMOVE DUPLICATE
-- 2. STANDARDIZE THE DATA
-- 3. NULL VALUE AND BLANK VALUE.
-- 4. REMOVE ANY COLUMNS/ROWS

-- first thing we want to do is create a staging table. 
-- This is the one we will work in and clean the data. 
-- We want a table with the raw data in case something happens

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

SELECT *
FROM layoffs_staging;

-- 1. Remove Duplicates

# First let's check for duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,industry,total_laid_off,percentage_laid_off,`DATE`) AS row_num
FROM layoffs_staging;

-- it looks like these are all legitimate entries and shouldn't be deleted. 
-- We need to really look at every single row to be accurate

-- these are our real duplicates

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Oda';

-- one solution, which I think is a good one. Is to create a new column and add those row numbers in.
-- Then delete where row numbers are over 2, then delete that column
-- so let's do it!!

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing the data

SELECT company,TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);
-- I also noticed the Crypto has multiple different variations. We need to standardize that 
-- let's say all to Crypto

SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT(industry)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2;

SELECT DISTINCT(location)
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2;

-- everything looks good except apparently we have some "United States" and some "United States." 
-- with a period at the end. Let's standardize this.
SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'united states%';
	
SELECT DISTINCT(country),TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.'  FROM country)
WHERE country LIKE 'United States%';

-- now if we run this again it is fixed
SELECT DISTINCT(country)
FROM layoffs_staging2
WHERE country LIKE  'united states%';

SELECT *
FROM layoffs_staging2;

-- Let's also fix the date columns:
SELECT `date`
FROM layoffs_staging2;

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

-- we can use str to date to update this field
UPDATE layoffs_staging2 
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

-- now we can convert the data type properly
ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE; 

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND
percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR 
industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry ='';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON
t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND 
t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging2;

-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. 
-- I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase
-- so there isn't anything I want to change with the null values

-- 4. remove any columns and rows we need to

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND
percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND 
percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND
percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2; 

-- NOW WE DON'T NEED ROW NUM COLUMN AS WE HAVE REMOVED DUPLICATES FROM DATA.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;

-- NOW THE DATA IS CLEANED. --

-- =====================================================================
-- FINAL VALIDATION CHECKS (added after cleaning)
-- =====================================================================

-- Row counts: raw table vs cleaned table
SELECT (SELECT COUNT(*) FROM layoffs)          AS raw_rows,
       (SELECT COUNT(*) FROM layoffs_staging2) AS cleaned_rows;

-- No duplicates should remain (expected: 0 rows)
SELECT company, location, `date`, stage, country, total_laid_off, percentage_laid_off, funds_raised_millions,
       COUNT(*) AS copies
FROM layoffs_staging2
GROUP BY company, location, `date`, stage, country, total_laid_off, percentage_laid_off, funds_raised_millions
HAVING COUNT(*) > 1;

-- No rows should have both layoff measures missing (expected: 0 rows)
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Date column should now be a DATE type (expected: data_type = date)
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'layoffs_staging2' AND COLUMN_NAME = 'date';

-- Remaining blank or missing industries (a few are expected where a company has only one row)
SELECT COUNT(*) AS industry_still_missing
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';
