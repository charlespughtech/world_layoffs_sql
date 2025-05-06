-- Data Cleaning Project - MySQL
-- world_layoffs
-- Charles Pugh - 2025-05-04

/*
I will:
	- Download a dataset.
 	- Create a database.
 	- Import the dataset.
    - Create a staging table to protect the integrity of the raw data.
	- Clean the data.

I will make sure to comment my steps to allow ease of readability.

Dataset used:
	- https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv
*/



-- Step 1: Download the dataset



-- Step 2: Create a new schema called world_layoffs:
-- 	- Click: 'Create a new schema...' > rename it to: world_layoffs > click: 'Apply' > click: 'Apply' > click: 'Finish'.



-- Step 3: Create a table within the schema:
-- 	- Expand the dropdown for the schema called world_layoffs > right-click on: 'Tables' > click: 'Table Data Import Wizard' > browse and select the layoffs.csv dataset. > click: 'Next' >
-- 	- Select: 'Create new table:' and 'Drop table if exists' > select: world_layoffs in the schema dropdown > use layoffs for the name of the Table > Click: 'Next' >
-- 	- Don't change data types for columns and leave 'Encoding' as 'utf-8' - I want the data to be imported in raw form and to not use the Wizard to change datatypes for me. Click: 'Next' >
-- 	- Click: 'Next' and wait for the data to import. > Click: 'Next' once the dataset has been imported > Click: 'Finish'.

-- Inspect the data by SELECTing all of the columns from the world_layoffs.layoffs table:
SELECT *
FROM world_layoffs.layoffs;



-- Step 4: Create a staging table called layoffs_staging to protect the integrity of the raw dataset. Copy data from the raw world_layoffs.layoffs table into the world_layoffs.layoffs_staging table:
CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;

-- That created a table with the same column headers as the raw layoffs table.
-- Select all columns from the world_layoffs.layoffs_staging table to check that the columns headers were copied correctly:
SELECT *
FROM world_layoffs.layoffs_staging;

-- Insert the all of the data from the raw world_layoffs.layoffs table into the world_layoffs.layoffs_staging table:
INSERT world_layoffs.layoffs_staging
SELECT *
FROM world_layoffs.layoffs;

-- Run the following again to check that inserted the data correctly:
SELECT *
FROM world_layoffs.layoffs_staging;



-- Step 5: Clean the data:
-- i) Remove duplicates.
-- ii) Standardise the data.
-- iii) Null or blank values.
-- iv) Remove any columns that aren't necessary.


-- i) Remove duplicates
-- Check for row numbers:
SELECT *
FROM world_layoffs.layoffs_staging;

-- Row numbers don't exist, so will add a row numbers column - partitioned by all of the columns - called row_num.
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM world_layoffs.layoffs_staging;

-- Create a CTE called duplicate_cte and filter to find row number values greater than 1 to find dupicates.
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- 5 rows show numbers greater than 1 and there are therefore 5 duplicate rows

-- Checking one of the duplicates by filtering by the company name:
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Casper';

-- Delete duplicate rows - rows where row_num > 1.
-- You can't use a DELETE/UPDATE statement on a CTE.
-- Therefore take the query definition/subquery and put it into world_layoffs.layoffs_staging_2 table.
-- Then I can use a DELETE statement to delete rows where row_num > 1 from the newly-created world_layoffs.layoffs_staging_2 table, as it is not a CTE.
-- I have written the query definition/subquery below from within the CTE that will be used to create a new table called world_layoffs.layoffs_staging_2:
/*
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging
*/

-- Creating the world_layoffs.layoffs_staging_2 table:
-- Right-click: world_layoffs.layoffs_staging > Click: 'Copy to Clipboard' > Click: 'Create Statement' > Paste/ctrl+v.
-- Change the name of the table to layoffs_staging_2.
-- Add a column called: `row_num` with an int data type - note: use backticks for the column name.
-- Run it.
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Select all columns from world_layoffs.layoffs_staging_2 to ensure that it worked.
SELECT *
FROM world_layoffs.layoffs_staging_2;

-- The column names are all correct.
-- Now to insert the data into world_layoffs.layoffs_staging_2 from the cte query definition/subquery:
/*
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging
*/

INSERT INTO world_layoffs.layoffs_staging_2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging;

-- Now select all columns from the newly created world_layoffs.layoffs_staging_2 table to check that it worked:
SELECT *
FROM world_layoffs.layoffs_staging_2;

-- Now use a SELECT statement before using a DELETE statement so that we can filter the world_layoffs.layoffs_staging_2 table to show only rows where row_num > 1.
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE row_num > 1;

-- Delete the duplicate rows (where row_num > 1) from the table using a DELETE statement, as it is no longer a CTE.
DELETE
FROM world_layoffs.layoffs_staging_2
WHERE row_num > 1;

-- Select all columns from the newly created world_layoffs.layoffs_staging_2 table, where row_num > 1, to confirm that the duplicates have been deleted:
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE row_num > 1;

-- View the full table to check for what needs to be standardised:
SELECT *
FROM world_layoffs.layoffs_staging_2;

-- Now that duplicates have been removed, the row_num column is no-longer needed and will be removed later.


-- ii) Standardising data

-- There where whitespaces in some of the company names within the company column, so I trimmed the values within the company column in order to remove the whitespaces..
-- I selected both the original and trimmed data for the company column to compare the two.
SELECT company, TRIM(company)
FROM world_layoffs.layoffs_staging_2;

-- The trimmed version definitely looks better
-- I'll now update the world_layoffs.layoffs_staging_2 table to set the company values to the trimmed values.
UPDATE world_layoffs.layoffs_staging_2
SET company = TRIM(company);

-- To ensure that the trim worked, I'll now select the company column and the trimmed company column from the updated world_layoffs.layoffs_staging_2 table to check that they are now identical.
SELECT company, TRIM(company)
FROM world_layoffs.layoffs_staging_2;

-- I'll now check the industry column within the world_layoffs.layoffs_staging_2 column by selecting distinct values within the industry column and will order it by industry - using industry or could use 1 (column number).
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging_2
ORDER BY industry;

-- There is 1 blank and 1 null value, which I will come back to.

-- The industry values 'Crypto', 'Crypto Currency' and 'CryptoCurrency' are not standardised.
-- I will select all columns from the `world_layoffs.layoffs_staging_2` table.
-- I will run a like operator after filtering by the industry column and a % sign after Crypto e.g. 'Cryto%' to ensure that I show all values that start with the word 'Crypto' and and end with characters after 'Crypto'.
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE industry LIKE 'Crypto%';

-- Running that query showed that the majority of values were 'Crypto', so I will use a trim function to standardise the others to 'Crytpo'. Note: No spelling errors found for the word Crypto either.
UPDATE world_layoffs.layoffs_staging_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- I will now re-run the following to double-check that it worked:
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging_2
ORDER BY industry;

-- That successfully updated the 3 rows to now contain the value 'Crypto' within the indistry column.

-- I will now check for distinct values within the location column of the world_layoffs.layoffs_staging_2 table and order the results by location (or 1, as I am looking at 1 column).
SELECT DISTINCT location
FROM world_layoffs.layoffs_staging_2
ORDER BY 1;

-- I will now select all distinct values within the country column and order the results by country.
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging_2
ORDER BY 1;

-- There is one error within the country column, having seen the distinct vlaues - 'United States.' needs to be standardised/updated to 'United States'. No other country vlaues have a full_stop at the end.
UPDATE world_layoffs.layoffs_staging_2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Alternate queries that could be used to remove the trailing full-stop in a more verbose manner, not my first choice solution:
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM world_layoffs.layoffs_staging_2
ORDER BY 1;

UPDATE world_layoffs.layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- I will now re-run the following query to ensure that the change worked:
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging_2
ORDER BY 1;

-- I will now view the entire table to find anything else that will need to be standardised.
SELECT *
FROM world_layoffs.layoffs_staging_2;

-- Looking back earlier on, the date column was in text format, not as a date/datetime. This is the query from earlier on in the project, when creating the table that shows this:
/*
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
*/ 
-- Note: I could have also checked this by clicking the dropdown arrow next to the schema name (world_layoffs), then the table name (world_layoffs.layoffs_staging_2), then Column and then clicking on the column called date - within the schemas panel.

-- I will now select the date column from the world_layoffs.layoffs_staging_2 table and will use backticks around the word `date`, as it is a keyword.
-- I will reformat it the correct format first, using STR_TO-DATE().
-- Syntax: STR_TO_DATE(`column name`, date format) what I need: STR_TO_DATE(`date`, '%m/%d/%Y') - see this link for more: https://www.w3schools.com/sql/func_mysql_str_to_date.asp
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM world_layoffs.layoffs_staging_2;

-- That works, so I will update the column to contain the correct date format ('%m/%d/%Y', which is yyyy-mm-dd).
UPDATE world_layoffs.layoffs_staging_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- I will now confirm that the update worked by selecting the date column from the world_layoffs.layoffs_staging_2 table.
SELECT `date`
FROM world_layoffs.layoffs_staging_2;

-- That worked and there was also a null value, which I will come back to, when I correct all null values together later.

-- Now, having changed the values within the date column of the world_layoffs.layoffs_staging_2 table to the correct format, I can change the data type from text to date.
-- Note: I needed to format them first, before I could change the data type.
-- I will use the alter table statement on the world_layoffs.layoffs_staging_2 table and then will use the modify clause to modify the data type for the date column from string/text to date and do this by listing the date data type after the column name.
-- See for more on the alter table statement: https://www.w3schools.com/mysql/mysql_alter.asp
-- IMPORTANT: do not use on raw data - use only on staging tables!!!
ALTER TABLE world_layoffs.layoffs_staging_2
MODIFY COLUMN `date` DATE;

-- Re-check by clicking the dropdown arrow next to the schema name (world_layoffs), then the table name (world_layoffs.layoffs_staging_2), then Column and then clicking on the column called date - within the schemas panel.
-- The data type for `date` now shows as date instead of text - it worked!


-- I will now check the world_layoffs.layoffs_staging_2 table where there are null values within the total_laid_off column - it needs to be is null, not = null.
SELECT *
from world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NULL;

-- I can see several rows where both the total_laid_off column and percentage_laid_off column values are null. I will now check those specifically.
SELECT *
from world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- There is a lot of null values within these two columns and may come back to them later regarding potentially removing the columns.

-- I will now check for blanks and null values within the industry column.
SELECT industry
from world_layoffs.layoffs_staging_2
ORDER BY 1;
-- This revealed that there is one row with a null value and 3 rows wqith blank values.

-- I will now re-cehck the rest of the data from the world_layoffs.layoffs_staging_2 table where the values within the industry column are blank or null and will order by industry to see what could be missing.
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- I can now try to see if any of these rows with blank columns have values from other rows containing  the same data to cross-reference and then use that to populate any blank or null values.
-- The first blank value is for a row that contains the 'Airbnb' value for company. I will check if this can be usful for replacing the blank value. 
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE company LIKE 'Airbnb%';

-- I will set the blank values within the industry column to nulls, as these are typically easier to work with.
UPDATE world_layoffs.layoffs_staging_2
SET industry = NULL
WHERE industry = '';
-- 3 changed, it likely worked. I will now check.

-- I will now check the indsutry column and order the results by indsutrry (asc) to ensure that all blanks are now nulls.
SELECT industry
from world_layoffs.layoffs_staging_2
ORDER BY 1;

-- That worked!
-- I will now update the industry column in world_layoffs.layoffs_staging_2 for rows where the industry value is null.
-- I will do this by self-joining the table, creating two aliases - t1 and t2.
-- The condition for the join is t1.company = t2.company, meaning it matches rows with the same company name.
-- I will set the industry value in t1 where the value is null to the non-null industry values from t2.
-- I have ensured that I restricted the update to only show rows where t1.industry is null and t2.industry is not null.
-- This will populate the null industry values with the non-null industry values from companies with the same name.
-- Reference for MySQL self-join UPDATE syntax and use cases: https://www.mysqltutorial.org/mysql-update-join/
UPDATE world_layoffs.layoffs_staging_2 t1
JOIN world_layoffs.layoffs_staging_2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- I will double-check to see if this worked by checking for rows that contain null values within the industry column
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE industry IS NULL
ORDER BY industry;
-- 'Bally''s Ineractive' contains a null (double ' because of the ' mid-string)

-- I will now check for that company name to see if there are multiple rows containing a company value like 'Bally%' to see if ther is potential to update the missing industry value or not.
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE company LIKE 'Bally%';

-- There is only 1 row and thus I will not be able to update it based off of other rows containing an industry value.

SELECT *
FROM world_layoffs.layoffs_staging_2;

-- Checking the world_layoffs.layoffs_staging_2 table...
-- ...The other blank values are within the total_laid_off, percentage_laid_off and the funds_raised_millions columns.
-- Due to not having the total number of staff for each company or any data about how many funds were rt, i won't be able to calculate any of these to fill in the nulls.
-- The funds_raised_millions column data looks like it could be date-specific and so I might not be able to populate any of that null data either (web-scraping would be a more advanced solution but I cannot do that yet).

-- Data cleaning for the null and blankvalues is now done!

-- I will now remove columns and rows that I need to remove before analysis.

-- As I will be analysing layoffs, I will first remove rows where the total_laid_off and percentage_laid_off values are both null.
-- I will now check for rows where both the total_laid_off percentage_laid_off values are null.
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- I will now delete rows from the staging table where both the total_laid_off percentage_laid_off values are null.
DELETE
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- I will run this query again to ensure that they are gone:
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- That worked.

-- We no longer need the row_num column and so can delete it.
-- To delete a column, use the alter table statement and then the drop column clause, naming both the table and column respectively.
-- IMPORTANT: Only do this on the staging table to keep the raw data intact!!!
ALTER TABLE world_layoffs.layoffs_staging_2
DROP COLUMN row_num;

-- I will now check that this worked by viewing the world_layoffs.layoffs_staging_2 table.
SELECT *
FROM world_layoffs.layoffs_staging_2;

-- It worked, the rows is gone and the data is now fully cleaned!

/*
I have:
	- Downloaded the dataset.
 	- Created the database.
 	- Imported the dataset.
    - Created a staging table to protect the integrity of the raw data.
	- Cleaned the data by:
		i) Removing duplicates.
		ii) Standardising the data.
		iii) Populating null or blank values.
		iv) Removing any rows and columns that aren't necessary.

Next, I will perform exploratory analysis on the cleaned data.
*/

-- End of data cleaning project!