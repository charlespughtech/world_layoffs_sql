-- Exploratory Data Analysis Project - MySQL
-- world_layoffs
-- Charles Pugh - 2025-05-05




/*
Here, I will explore the data and find trends, patterns or anything interesting like outliers.

I will not be following as structured of a plan as during cleaning, and so will outline my process via comments, as I explore the cleaned data.

Raw dataset used: https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv
Cleaned table: world_layoffs.layoffs_staging_2

Due to the data having an emphasis on layoffs, two columns of interest will definitely be total_laid_off and percentage_laid_off.
The columns called company, industry and date will also likely be an integral part of the analysis but I will keep an open mind and see what insights the data reveals.

Due to the density of the commenting and large number of total queries, I have used 4 lines between each query to enhance readability, this should make the logic significantly easier to follow.
It may increase the memory-usage slightly but will valstly enhance readability and thus understanding, repeatability and any necessary debugging.
*/




-- I will start by viewing the whole, cleaned world_layoffs.layoffs_staging_2 table.
SELECT *
FROM world_layoffs.layoffs_staging_2;




-- I will now check the max value for the total laid off column.
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs.layoffs_staging_2;
-- The max value for total laid off was 12000, the maximum percentage laid off was 100% (0 = 0%, 0.5 = 50%, 1 = 100%).




-- I will now check which companies laid off 100% of their staff.
-- I will do this by selecting all of the columns, filtering by companies where their value for the percentage_laid_off column is 1 and order the results by the total_lad_off column in descending order.
-- This will show me companies who laid off 100% of their staff (likely went under) and will order them by the largest number of total staff laid off.
SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;




-- I will now run the same query but change the order by clause to order it by the funds_raised_millions column (to see which companeis who fired 100% of their staff raised the most money).
-- This will show me the size of some of the companies who went under.
-- Britishvolt went under after raising 2.5bn, this was the largest amount of funds raised before going under.
SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;




-- I will now look at the company and for each companuy will look at the sum of their total laid off values.
-- I will group the data by company and will order it in descending order of the sum(total_laid_off) column in order to see which company laid off the most staff.  
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;
-- Amazon laid off the most staff in total (18150).
-- As expected, the largest companies laid off the most staff (tech giants like Amazon, Google Meta etc.).




-- I will now check the min and max values for the date column (backticks are used, as date is a keyword).
-- This will give me the date range of the dataset.
SELECT MIN(`date`), MAX(`date`)
FROM world_layoffs.layoffs_staging_2;
-- The date range of the dataset is between March 2020 and March 2023, so 3 years.
-- The data started around the pandemic time, this may have impacted the comapanies, as many companies collapsed during the pandemic and many staff were let go.




-- I will check the agggregates for the columns by checking the column (grouped) vs the sum of the total laid off.
-- I had removed or populated all possible null (also converted blanks to null) values during cleaning, but any left over may still slightly impact the data. 




-- I will now check which industries laid off the most staff.
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC;
-- Industrries who laid the most staff were Consumer and Retail.
-- This does make some sense, as people couldn't use shops as easily during covid.



-- I will now take another look at the whole table again, to see what data points we have to see if there is anything else that I could look into.
SELECT *
FROM world_layoffs.layoffs_staging_2;




-- I might check the layoffs by country next.
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;
-- United States had considerably more layoffs than the other countries.




-- One thing that I might check later is how many layoffs per month, per year etc.
-- I will first check layoffs by year by selecting the date column and by ordering by the sum of the total_laid_off data grouped bycountry.
SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
-- 2022 was the worst full-year for layoffs, 2023 only had 3 months of data but had nearly as many layffs as 2022, so if the trened continued for 2023, it would be the year with the most layoffs.




-- I will now check layoffs with respect to the stage column. This column shows the stage of the company. 
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
GROUP BY stage 
ORDER BY 2 DESC;
-- Comapnies in the Post-IPO (post-initial public offering a.k.a going public on the stock market) stage hads the largest number of total layoffs by quite some margin.
-- This potentially suggests a couple of things:
-- 	- These companies are generally larger and thus could lay off more staff and yet the percentage_laid_off column's data may be less of an outlier compared to other stages.
-- 	- These companies could have had their profitability negatively affected by the influence of members of the public trading their stock.




-- I will re-run the above query, but this time will include the percentage_laid_off column to check if the first of the two aforementioned possibilities could align with the data given the introduction of the percentage_laid_off data.
SELECT stage, SUM(total_laid_off), AVG(percentage_laid_off)
FROM world_layoffs.layoffs_staging_2
GROUP BY stage
ORDER BY 3 DESC;
-- This confirmed my hypothesis, I checked the average of the percentage_laid_off for each stage ,grouped by stage and ordered by the averages for each stage's percentage_laid_off column values.
-- This showed that actually the companies post-ipo had a below-average percentage of their total staff laid off.
-- Re-affirming my hypothesis that despite a larger number of ayoffs within that stage as a total, the actual percentage of their staff laid off was relatively small.
-- This would indicate larger staff numbers and thus would indicate the total_laid_off data was higher for them, not because they were laying more off as a percentage of their staff but simply due ot the scale.




-- I will now check the sum of the total_laid_off values grouped by month to see which months had the highest total number of staff laid off..
-- I will use a substring function to extract the month from the date - the date format is yyyy-mm-dd, therefore, the data we want is in the 6th position within the `date` column and we are taking two characters: y(1)y(2)y(3)y(4)-(5)-m(6)m(7)-(8)d(9)d(10).
SELECT SUBSTRING(`date`, 6, 2) AS `month`, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
GROUP BY `month`
ORDER BY 2 DESC;
-- This shows that January had the most layoffs, by far, followed by November and February. This suggests that the Christmas period may have had an impact on these numbers, or it could be either the impact of a new calander year or also the impact of tax years.




-- I will now check the rolling total for layoffs with respect to the year and month.
SELECT SUBSTRING(`date`, 1, 7) AS `year_month`, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `year_month`
ORDER BY 2 DESC;
-- I can see that the most layoffs were in the 3 months were durinng the start of 2023/end of 2022. January of 2023 had by far the highest.




-- I will now order it in chronological order.
SELECT SUBSTRING(`date`, 1, 7) AS `year_month`, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `year_month`
ORDER BY 1;




-- I will now do a rolling sum of the year_month and sum(total_laid_off) data.
-- I will use a CTE.
-- I will use the previous query, which gave me hte sum for each year_month.
-- I will order it by year_motnh and will 
-- Define a Common Table Expression (CTE) named 'Rolling_Total'
WITH Rolling_Total AS
(
	-- Extract the year and month (YYYY-MM) from the `date` column and alias it as 'year_month'
    -- Sum the 'total_laid_off' column to get the total layoffs per year-month
    SELECT SUBSTRING(`date`, 1, 7) AS `year_month`, SUM(total_laid_off) AS total_off
    -- From the 'layoffs_staging_2' table in the 'world_layoffs' database
    FROM world_layoffs.layoffs_staging_2
    -- Filter out rows where the 'year_month' extraction is NULL
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    -- Group the results by 'year_month' to aggregate layoffs per year-month
    GROUP BY `year_month`
    -- Sort the results by 'year_month' in ascending order
    ORDER BY 1
)
-- Select the 'year_month' from the CTE
-- Calculate a rolling sum of 'total_off' ordered by 'year_month', aliasing it as 'rolling_total'
SELECT `year_month`, SUM(total_off) OVER(ORDER BY `year_month`) AS rolling_total
-- From the 'Rolling_Total' CTE
FROM Rolling_Total;




-- Below I will repeat the cte without the comments in-case it helps with readabiltiy:
WITH Rolling_Total AS
(
	SELECT SUBSTRING(`date`, 1, 7) AS `year_month`, SUM(total_laid_off) AS total_off
	FROM world_layoffs.layoffs_staging_2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `year_month`
	ORDER BY 1
)
SELECT `year_month`, SUM(total_off) OVER(ORDER BY `year_month`) AS rolling_total
FROM Rolling_Total;




-- I want to visually improve the output of this CTE so that the total_off column (SUM(toal_laid_off)) shows next to the rolling_total column.
-- This will help me see the how the sum of the total layoffs (total_off) for each month impact the rolling_total and thus will enable me to see each increment more clearly.
WITH Rolling_Total AS
(
	SELECT SUBSTRING(`date`, 1, 7) AS `year_month`, SUM(total_laid_off) AS total_off
	FROM world_layoffs.layoffs_staging_2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `year_month`
	ORDER BY 1
)
SELECT `year_month`, total_off, SUM(total_off) OVER(ORDER BY `year_month`) AS rolling_total
FROM Rolling_Total;
-- The above simply shows a month-by-motnh progression of layoffs.
-- I can see that there were much fewer laid off in 2021 comaratively.
-- I can also see that the total number of layoffs for 2022 and the start of 2023 particularly were much greater.




-- I now want to look into the data with more of an emphasis on companies to find any company-specific patterns.
-- First, I will quickly check a prior query that focused on more company-specific data, it showed which companies laid off the most staff using an aggregate/sum function for ther grouped company data.
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;




-- I want to now include the `date` data, as the prior query showed no dat for `date`. I cannot see how companies laid off staff over tiem witout this data.
-- I will add it in by extracting the year from the dates and using that as a column.
-- I will group by the company and year to keep that data together.
-- I will order by company to ensure that the companies are in alphabetical order.
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
GROUP BY company, YEAR(`date`)
ORDER BY 1;




-- I will now order the same query by the sum(total_laid_off) column in descending order to see which company laid off the most staff in a year.
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;




-- I will now rank the highest year based off the number of people laid off per company.
-- I will start by putting the previous query into a CTE and will change the column names for readability.
-- I will partitition the data by `year` so that all of the 2021 layoffs will be in one partition, all of 2022 will be in another etc.
-- Then rank it based off how many the company laid of in that year using dense_rank.
-- This will rank the layoffs per company in descending order for each year.
WITH Company_Year (company, `year`, total_laid_off) AS
(
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM world_layoffs.layoffs_staging_2
	GROUP BY company, YEAR(`date`)
	ORDER BY 3 DESC
)
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC)
FROM Company_Year;




-- There was one null value within the year column, so I will repeat but this time omit the null.
-- I will also order the results by ranking so that each of the number 1 ranks (for each year - 2020, 2021, 2022 and 2023 (they are paritioned by `year`)) show first - ascending order .
-- CTE to aggregate layoffs by company and year, excluding NULL years
WITH Company_Year (company, `year`, total_laid_off) AS
(
    -- Select company, year (from `date`), and sum of total_laid_off
    SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM world_layoffs.layoffs_staging_2
    -- Group by company and year to sum layoffs for each company-year pair
    GROUP BY company, YEAR(`date`)
    -- Order by total_laid_off descending for reference
    ORDER BY 3 DESC
)
-- Select all CTE columns and calculate a dense rank for each company within its year
SELECT 
    *, 
    -- Rank companies within each year by total_laid_off (highest gets rank 1)
    DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
-- Exclude rows where year is NULL
WHERE `year` IS NOT NULL
-- Order by ranking to show rank 1 for each year first, then rank 2, etc.
ORDER BY ranking;




-- I will re-write the ranked CTE below without comments for readability.
WITH Company_Year (company, `year`, total_laid_off) AS
(
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM world_layoffs.layoffs_staging_2
	GROUP BY company, YEAR(`date`)
	ORDER BY 3 DESC
)
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE `year` IS NOT NULL
ORDER BY ranking;


-- From the ranked cte, I can see that the following companies ranked number 1 for most total layoffs per year: 
-- 	- 2020: Uber (7525 laid off)
--  - 2021: Bytedance (3600 laid off)
-- 	- 2022: Meta (11000 laid off)
-- 	- 2023: Google (12000 laid off) 
-- Overall, Google's was the largest total layoffs for a single year with 12000, closeley followed by Meta with 11000.




-- I will now filter the top 5 highest layoffs per company per year.
-- I will add this as another cte to the original cte and query off that.
WITH Company_Year (company, `year`, total_laid_off) AS
(
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM world_layoffs.layoffs_staging_2
	GROUP BY company, YEAR(`date`)
	ORDER BY 3 DESC
),
Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE `year` IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


-- From the ranked CTE, here are the rankings by company for each year (with layoffs):
-- 2020
-- 1: Uber (7,525 laid off)
-- 2: Booking.com (4,375 laid off)
-- 3: Groupon (2,800 laid off)
-- 4: Swiggy (2,250 laid off)
-- 5: Airbnb (1,900 laid off)

-- 2021
-- 1: Bytedance (3,600 laid off)
-- 2: Katerra (2,434 laid off)
-- 3: Zillow (2,000 laid off)
-- 4: Instacart (1,877 laid off)
-- 5: WhiteHat Jr (1,800 laid off)

-- 2022
-- 1: Meta (11,000 laid off)
-- 2: Amazon (10,150 laid off)
-- 3: Cisco (4,100 laid off)
-- 4: Peloton (4,084 laid off)
-- 5: Carvana (4,000 laid off), Philips (4,000 laid off)

-- 2023
-- 1: Google (12,000 laid off)
-- 2: Microsoft (10,000 laid off)
-- 3: Ericsson (8,500 laid off)
-- 4: Amazon (8,000 laid off), Salesforce (8,000 laid off)
-- 5: Dell (6,650 laid off)




-- I will now repeat the cte but will replace company with industry to see how industries faired regarding layoffs per year.
WITH Industry_Year (industry, `year`, total_laid_off) AS
(
	SELECT industry, YEAR(`date`), SUM(total_laid_off)
	FROM world_layoffs.layoffs_staging_2
	GROUP BY industry, YEAR(`date`)
	ORDER BY 3 DESC
),
Industry_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
FROM Industry_Year
WHERE `year` IS NOT NULL
)
SELECT *
FROM Industry_Year_Rank
WHERE Ranking <= 5;


-- From the new ranked CTE, here are the rankings by industry for each year (with layoffs):
-- 2020
-- 1: Transportation (14,656 laid off)
-- 2: Travel (13,983 laid off)
-- 3: Finance (8,624 laid off)
-- 4: Retail (8,002 laid off)
-- 5: Food (6,218 laid off)

-- 2021
-- 1: Consumer (3,600 laid off)
-- 2: Real Estate (2,900 laid off)
-- 3: Food (2,644 laid off)
-- 4: Construction (2,434 laid off)
-- 5: Education (1,943 laid off)

-- 2022
-- 1: Retail (20,914 laid off)
-- 2: Consumer (19,856 laid off)
-- 3: Transportation (15,227 laid off)
-- 4: Healthcare (15,058 laid off)
-- 5: Finance (12,684 laid off)

-- 2023
-- 1: Other (28,512 laid off)
-- 2: Consumer (15,663 laid off)
-- 3: Retail (13,609 laid off)
-- 4: Hardware (13,223 laid off)
-- 5: Healthcare (9,770 laid off)

-- 2020: This data is likely impacted heavily by the pandemic, which decimated travel, hospitality, and in-person retail.
-- 2021: The lower numbers laid off for 2021 stands out amongst the rest. This could be due to either government stimulus or an attempted recovery after the initial impact of the pandemic.
-- 2022: Retail/consumer closures, finance and inflationary pressures due to the pandemic and the Russia-Ukraine war’s impact on energy and transport cost, thus impacting supply-chains. A large heathcare layoff could be due to temporary staff recruited for the pandemcic.
-- 2023: The dominant “Other” bucket signals either a broader correction or that a large volume of the 2023 data fell into the other column. In 2023, many firms refocused on efficiency and profitability after still suffering from the impact of the pandemic.
-- Together, these patterns map neatly onto: the pandemic’s onset -> uneven reopening -> inflationary/geopolitical headwinds -> recalibration.




-- I will now repeat the cte but will replace the industry with the country to see how countries faired regarding layoffs per year.
WITH Country_Year (country, `year`, total_laid_off) AS
(
	SELECT country, YEAR(`date`), SUM(total_laid_off)
	FROM world_layoffs.layoffs_staging_2
	GROUP BY country, YEAR(`date`)
	ORDER BY 3 DESC
),
Country_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
FROM Country_Year
WHERE `year` IS NOT NULL
)
SELECT *
FROM Country_Year_Rank
WHERE Ranking <= 5;


-- From the ranked CTE, here are the rankings by country for each year (ranked by total layoffs):
--  2020
--  1: United States (50 385 laid off)
--  2: India (12 932 laid off)
--  3: Netherlands (4 600 laid off)
--  4: Brazil (3 341 laid off)
--  5: Singapore (2 361 laid off)

--  2021
--  1: United States (9 470 laid off)
--  2: India (4 080 laid off)
--  3: China (1 800 laid off)
--  4: Germany (387 laid off)
--  5: Canada (45 laid off)

--  2022
--  1: United States (106 520 laid off)
--  2: India (14 224 laid off)
--  3: Netherlands (5 120 laid off)
--  4: Brazil (4 889 laid off)
--  5: Canada (3 936 laid off)

--  2023
--  1: United States (89 684 laid off)
--  2: Sweden (9 100 laid off)
--  3: Netherlands (7 500 laid off)
--  4: India (4 757 laid off)
--  5: Germany (4 176 laid off)


-- Analysing the country rankings for consistencies:
-- 1: The United States ranked number 1, every year.
--    — Large economy hit by economic shifts, automation, and post-COVID adjustments.
-- 2: India ranked number 2, 3 out of the 4 years.
--    — Vast workforce affected by global slowdowns and supply chain changes.
-- 3: The Netherlands ranked number 3, 3 out of the 4 years.
--    — Trade and logistics hub impacted by supply chain disruptions and economic adjustments.
-- 4: Brazil ranked number 4, 2 out of the 4 years.
--    — Economy shaken by global demand drops and political instability.
-- 5: Canada ranked number 5, 2 out of the 4 years.
--    — Resource-dependent economy hit by commodity price swings and diversification efforts.
--  Other notable rankings:
--   – China reached third once (2021)
--   	— Trade tensions and regulatory changes triggered layoffs.
--   – Sweden achieved second once (2023)
--    	— Supply chain issues and industrial shifts caused spikes in layoffs.
--   – Germany recorded fourth once (2021) and fifth once (2023)
--   	— Economic restructuring and supply chain challenges led to layoffs.




-- I will now repeat the cte but will replace the country column with the stage to see how the different company stages faired regarding layoffs per year.
WITH Stage_Year (stage, `year`, total_laid_off) AS
(
	SELECT stage, YEAR(`date`), SUM(total_laid_off)
	FROM world_layoffs.layoffs_staging_2
	GROUP BY stage, YEAR(`date`)
	ORDER BY 3 DESC
),
Stage_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
FROM Stage_Year
WHERE `year` IS NOT NULL
)
SELECT *
FROM Stage_Year_Rank
WHERE Ranking <= 5;


-- From the ranked CTE, here are the rankings by stage for each year (ranked by total layoffs):
-- 2020
-- 1: Post-IPO (22,672 laid off)
-- 2: Acquired (12,169 laid off)
-- 3: Series D (8,837 laid off)
-- 4: Unknown (7,632 laid off)
-- 5: Series B (5,609 laid off)
-- 2021
-- 1: Unknown (9,097 laid off)
-- 2: Acquired (2,984 laid off)
-- 3: Post-IPO (2,895 laid off)
-- 4: Series F (323 laid off)
-- 5: Series D (236 laid off)
-- 2022
-- 1: Post-IPO (79,373 laid off)
-- 2: Unknown (19,127 laid off)
-- 3: Series C (13,072 laid off)
-- 4: Series D (8,351 laid off)
-- 5: Series B (7,514 laid off)
-- 2023
-- 1: Post-IPO (98,692 laid off)
-- 2: Acquired (6,966 laid off)
-- 3: Unknown (4,860 laid off)
-- 4: Series C (2,711 laid off)
-- 5: Series E (2,421 laid off)

-- Analysing the stage rankings for consistencies:
-- 1: Post-IPO ranked number 1 in 3 out of 4 years (2020, 2022, 2023).
--    — Large public companies, with bigger workforces, faced 2020’s pandemic disruptions, 2022’s inflation and rate hikes, and 2023’s cost-cutting pressures, leading to high layoffs due to their scale and market exposure.
-- 2: Unknown appeared in the top 5 every year, ranking 1st in 2021.
--    — Likely a mix of smaller or unspecified firms, sensitive to 2021’s uneven recovery, with varied sizes making them vulnerable to sector-specific or funding issues.
-- 3: Acquired ranked 2nd in 3 out of 4 years (2020, 2021, 2023).
--    — Acquired firms, often large, saw layoffs from 2020’s uncertainty, 2021’s M&A rebound, and 2023’s efficiency drives, as restructuring eliminates redundant roles.
-- 4: Series D appeared in the top 5 in 3 out of 4 years (2020, 2021, 2022).
--    — Mid-to-late-stage startups, with significant staff but reliant on funding, were hit by 2020’s economic shock, 2021’s funding scrutiny, and 2022’s VC slowdown, prompting layoffs to conserve cash.
-- 5: Series C appeared in the top 5 in 2 out of 4 years (2022, 2023).
--    — Growth-stage startups, scaling operations, faced 2022’s funding crunch and 2023’s market pressures, leading to layoffs due to high burn rates and investor demands.

-- Other notable rankings:
--   – Series B appeared in 2020 and 2022.
--     — Early-stage firms, with smaller teams but high funding dependency, were hit by 2020’s market freeze and 2022’s tightened funding, leading to layoffs to extend runway.
--   – Series E appeared in 2023.
--     — Later-stage startups, with larger teams and high valuations, faced 2023’s high interest rates and profitability pressures, triggering layoffs to align with investor expectations.
--   – Series F appeared in 2021.
--     — Advanced-stage firms, often overextended, faced 2021’s sector-specific corrections during recovery, leading to targeted layoffs.




-- I want to repeat som of the above analysis, using the CTE's above but instead will replace sum(total_laid_off) with avg(percetage_laid_off).
-- This will give me a clearer insight into the data without the bias of scale (larger companies have more stff than smaller ones and thus lay off more per percentage jump).
-- I will first look at the data as a whole and will look for columns to analyse.
SELECT *
FROM world_layoffs.layoffs_staging_2;




-- I will edit the prior CTE but replace sum(total_laid_off) with avg(percentage_laid_off) to remove the bias of scale .
-- I will repeat that process twice: once for countries, once for industries.
-- First CTE: countries, ranked by avg(percentage_laid_off), patritioned by year and in descending order of avg(percentage_laid_off): 
WITH Country_Year (country, `year`, avg_percentage_laid_off) AS
(
    SELECT country, YEAR(`date`), AVG(percentage_laid_off) AS avg_percentage_laid_off
    FROM world_layoffs.layoffs_staging_2
    WHERE percentage_laid_off IS NOT NULL AND `date` IS NOT NULL
    GROUP BY country, YEAR(`date`)
),
Country_Year_Rank AS
(
    SELECT country, `year`, avg_percentage_laid_off, 
           DENSE_RANK() OVER(PARTITION BY `year` ORDER BY avg_percentage_laid_off DESC) AS ranking
    FROM Country_Year
    WHERE avg_percentage_laid_off IS NOT NULL
)
SELECT country, `year`, avg_percentage_laid_off, ranking
FROM Country_Year_Rank
WHERE ranking <= 5
ORDER BY `year`, ranking;


-- From the ranked CTE, here are the rankings by country for each year (ranked by average percentage of layoffs):
-- 2020
-- 1: Vietnam (100% laid off)
-- 2: United Arab Emirates (77% laid off)
-- 3: Nigeria (60% laid off)
-- 4: Indonesia (59.86% laid off)
-- 5: Switzerland (50% laid off)
-- 2021
-- 1: Singapore (100% laid off, tied)
-- 1: Canada (100% laid off, tied)
-- 2: United States (59.86% laid off)
-- 3: India (40% laid off)
-- 4: Germany (20% laid off)
-- 2022
-- 1: Vietnam (75% laid off)
-- 2: Denmark (67.5% laid off)
-- 3: Pakistan (53.67% laid off)
-- 4: Egypt (50% laid off)
-- 5: Australia (46.29% laid off)
-- 2023
-- 1: United Kingdom (33.45% laid off)
-- 2: India (31.71% laid off)
-- 3: Italy (30% laid off, tied)
-- 3: Chile (30% laid off, tied)
-- 4: Australia (27.64% laid off)
-- 5: South Korea (20% laid off, tied)
-- 5: France (20% laid off, tied)

-- Analysing the country rankings for consistencies:
-- Note: Percentages above 50% (0.5) are likely inflated due to limited data points for a country in a given year (e.g., Canada’s 100% in 2021 from one row).
-- 1: Vietnam ranked number 1 in 2 out of 4 years (2020, 2022).
--    -- Small, export-driven firms in manufacturing/tech, hit by 2020’s supply chain disruptions and 2022’s demand slowdown, saw high percentage layoffs; 100% and 75% likely due to few data points.
-- 2: India appeared in the top 5 in 2 out of 4 years (2021, 2023).
--    -- Large startup and service sectors, with small firms, faced 2021’s recovery challenges and 2023’s funding crunch, driving high percentage layoffs due to funding dependency.
-- 3: Australia appeared in the top 5 in 2 out of 4 years (2022, 2023).
--    -- Smaller tech/service firms in a resource-heavy economy were hit by 2022’s rate hikes and 2023’s market pressures, leading to high percentage layoffs due to economic sensitivity.
-- 4: United Kingdom appeared in the top 5 in 1 out of 4 years (2023).
--    -- Tech/finance sectors, with small firms, faced 2023’s post-Brexit and inflation pressures, resulting in high percentage layoffs due to economic and regulatory challenges.
-- 5: Canada appeared in the top 5 in 1 out of 4 years (2021, tied for 1st).
--    -- Small tech startups, over-hired during the pandemic, faced 2021’s post-COVID corrections; 100% likely from one data point, inflating the percentage.

-- Other notable rankings:
--   -- United Arab Emirates ranked 2nd in 2020.
--      -- Small tourism/oil firms, hit by 2020’s travel bans and oil price crashes, saw 77% layoffs, likely inflated by limited data points.
--   -- Nigeria ranked 3rd in 2020.
--      -- Emerging tech/oil firms faced 2020’s economic freeze; 60% likely due to few data points for small firms.
--   -- Switzerland ranked 5th in 2020.
--      -- Niche tech/finance firms faced 2020’s disruptions; 50% reflects small firms’ sensitivity, possibly with limited data.
--   -- Singapore ranked 1st in 2021 (tied).
--      -- Small tech/finance hubs faced 2021’s recovery challenges; 100% likely from one data point, inflating the percentage.
--   -- United States ranked 2nd in 2021.
--      -- Diverse economy with tech startups saw 2021’s recovery issues; 59.86% likely from limited high-percentage layoffs in small firms.
--   -- Denmark ranked 2nd in 2022.
--      -- Small tech/renewable firms faced 2022’s economic tightening; 67.5% likely inflated by few data points.
--   -- Pakistan ranked 3rd in 2022.
--      -- Emerging startup sector faced 2022’s funding crunch; 53.67% possibly due to limited data for small firms.
--   -- Egypt ranked 4th in 2022.
--      -- Small tech/service firms faced 2022’s global pressures; 50% reflects economic instability, possibly with few data points.
--   -- Italy ranked 3rd in 2023 (tied).
--      -- Small manufacturing/tech firms faced 2023’s inflation, driving 30% layoffs due to cost-cutting needs.
--   -- Chile ranked 3rd in 2023 (tied).
--      -- Small mining/tech firms faced 2023’s commodity/funding challenges, leading to 30% layoffs due to economic volatility.
--   -- South Korea ranked 5th in 2023 (tied).
--      -- Small tech/manufacturing firms faced 2023’s demand slowdowns, causing 20% layoffs due to global market shifts.
--   -- France ranked 5th in 2023 (tied).
--      -- Small tech/service firms faced 2023’s economic pressures, leading to 20% layoffs due to labor market adjustments.




-- Final CTE: Industries, ranked by avg(percentage_laid_off), patritioned by year and in descending order of avg(percentage_laid_off): 
WITH Industry_Year (industry, `year`, avg_percentage_laid_off) AS
(
    SELECT industry, YEAR(`date`), AVG(percentage_laid_off) AS avg_percentage_laid_off
    FROM world_layoffs.layoffs_staging_2
    WHERE percentage_laid_off IS NOT NULL AND `date` IS NOT NULL
    GROUP BY industry, YEAR(`date`)
),
Industry_Year_Rank AS
(
    SELECT industry, `year`, avg_percentage_laid_off, 
           DENSE_RANK() OVER(PARTITION BY `year` ORDER BY avg_percentage_laid_off DESC) AS ranking
    FROM Industry_Year
    WHERE avg_percentage_laid_off IS NOT NULL
)
SELECT industry, `year`, avg_percentage_laid_off, ranking
FROM Industry_Year_Rank
WHERE ranking <= 5
ORDER BY `year`, ranking;


-- From the ranked CTE, here are the rankings by industry for each year (ranked by average percentage of layoffs):
-- 2020
-- 1: Aerospace (55% laid off)
-- 2: Fitness (48.11% laid off)
-- 3: Education (42.38% laid off)
-- 4: Food (42.16% laid off)
-- 5: Retail (41.68% laid off)
-- 2021
-- 1: Media (100% laid off, tied)
-- 1: Recruiting (100% laid off, tied)
-- 1: Construction (100% laid off, tied)
-- 1: Retail (100% laid off, tied)
-- 1: Finance (100% laid off, tied)
-- 1: Marketing (100% laid off, tied)
-- 2: Education (70% laid off)
-- 3: Transportation (40% laid off)
-- 4: Data (27% laid off)
-- 5: Food (17.5% laid off)
-- 2022
-- 1: Aerospace (58% laid off)
-- 2: Travel (42.2% laid off)
-- 3: Legal (42% laid off)
-- 4: Food (32.85% laid off)
-- 5: Recruiting (32% laid off)
-- 2023
-- 1: Transportation (42.87% laid off)
-- 2: Education (39.67% laid off)
-- 3: Real Estate (35% laid off)
-- 4: Healthcare (31.47% laid off)
-- 5: Crypto (28.09% laid off)

-- Analysing the industry rankings for consistencies:
-- Note: Percentages above 50% (0.5) are likely inflated due to limited data points for an industry in a given year (e.g., Media’s 100% in 2021 likely from few rows).
-- 1: Education appeared in the top 5 in 3 out of 4 years (2020, 2021, 2023).
--    -- Edtech and traditional education firms, often small, faced 2020’s school closures, 2021’s uneven recovery, and 2023’s funding crunch, leading to high percentage layoffs due to market and funding volatility.
-- 2: Food appeared in the top 5 in 3 out of 4 years (2020, 2021, 2022).
--    -- Food service/delivery firms, typically lean, were hit by 2020’s lockdowns, 2021’s recovery shifts, and 2022’s inflation, driving high percentage layoffs due to demand and cost fluctuations.
-- 3: Aerospace ranked number 1 in 2 out of 4 years (2020, 2022).
--    -- Small aerospace firms faced 2020’s travel bans and 2022’s supply chain issues; high percentages (55%, 58%) likely due to limited data points and sector-specific disruptions.
-- 4: Retail appeared in the top 5 in 2 out of 4 years (2020, 2021).
--    -- Small retail firms faced 2020’s store closures and 2021’s recovery challenges; 100% in 2021 likely from few data points, reflecting high layoffs in struggling stores.
-- 5: Transportation appeared in the top 5 in 2 out of 4 years (2021, 2023).
--    -- Transport/logistics firms, with variable workforce sizes, were hit by 2021’s supply chain recovery issues and 2023’s economic slowdown, leading to high percentage layoffs due to demand shifts.

-- Other notable rankings:
--   -- Fitness ranked 2nd in 2020.
--      -- Small gym/fitness firms faced 2020’s lockdowns, causing 48.11% layoffs due to widespread closures.
--   -- Media ranked 1st in 2021 (tied).
--      -- Small media firms faced 2021’s ad revenue drops; 100% likely from few data points, inflating the percentage.
--   -- Recruiting ranked 1st in 2021 (tied) and 5th in 2022.
--      -- Small recruiting firms faced 2021’s hiring volatility and 2022’s funding crunch; 100% in 2021 likely due to limited data.
--   -- Construction ranked 1st in 2021 (tied).
--      -- Small construction firms faced 2021’s supply chain issues; 100% likely from few data points.
--   -- Finance ranked 1st in 2021 (tied).
--      -- Small fintech firms faced 2021’s recovery corrections; 100% likely from limited data points.
--   -- Marketing ranked 1st in 2021 (tied).
--      -- Small marketing firms faced 2021’s budget cuts; 100% likely due to few data points.
--   -- Data ranked 4th in 2021.
--      -- Small data firms faced 2021’s recovery challenges, leading to 27% layoffs due to project slowdowns.
--   -- Travel ranked 2nd in 2022.
--      -- Small travel firms faced 2022’s uneven post-COVID recovery, causing 42.2% layoffs due to demand fluctuations.
--   -- Legal ranked 3rd in 2022.
--      -- Small legal firms faced 2022’s reduced demand, leading to 42% layoffs due to economic tightening.
--   -- Real Estate ranked 3rd in 2023.
--      -- Small real estate firms faced 2023’s housing market slowdown, causing 35% layoffs due to high interest rates.
--   -- Healthcare ranked 4th in 2023.
--      -- Small healthcare firms faced 2023’s cost pressures, leading to 31.47% layoffs due to budget constraints.
--   -- Crypto ranked 5th in 2023.
--      -- Small crypto firms faced 2023’s market volatility, causing 28.09% layoffs due to investor pullbacks.




-- I feel like I have now extensively traversed the data and analysed it from multiple angles.
-- I ensured to maintain clarity of reading through consistent commenting and hope that it helped with readability.
-- I have used CTEs, CTEs with mutliple query definitions, aggregate functions, dense_rank, order by, group by and partition by to enahance the clarity of the outputs. 
-- Below, to summarise, I will provide my key takeaways having thoroughly analysed the world_layoffs dataset.

-- Key takeaways:
-- 1: Two global events shaped layoffs: the COVID-19 pandemic (2020–2021) and the Russia-Ukraine war (2022–2023), disrupting supply chains, enforcing lockdowns, and impacting businesses across sectors.
-- 2: Mega-cap tech firms (e.g., Google, Meta) led total layoffs due to large workforces, but non-tech sectors (e.g., Transport, Retail) faced higher proportional impacts from pandemic and war-related disruptions.
-- 3: Post-IPO firms, exposed to stock market turmoil, dominated layoffs in 2020, 2022, and 2023, driven by pandemic shocks, inflation, and efficiency drives, reflecting their scale and market sensitivity.
-- 4: The United States and India consistently ranked high in total layoffs due to their large economies and workforce sizes, while smaller countries (e.g., Vietnam) showed high percentage layoffs, often inflated by limited data.
-- 5: Industries like Education and Food faced persistent high percentage layoffs, hit by 2020’s closures, 2021’s recovery challenges, and 2022–2023’s economic pressures, reflecting sector-specific vulnerabilities.
-- 6: Chronological trends show a cycle: pandemic shock (2020) -> uneven recovery with stimulus (2021) -> inflationary and geopolitical pressures (2022) -> profitability-focused recalibration (2023).


-- Room for improvement:
-- 1. Expanding the data's date-range would give a much more in-depth understanding of how it fits in with other historical patterns and would expose the impact of both the pandemic and the Russia-Ukraine war more distinctly. 
-- - To truly see the impact of the pandemic, I would prefer to have had some pre-2020 data to truly compare the layoff data from before and after the covid pandemic and lockdowns.
-- - That would give me a more nuanced perspective as to how the covid period sits amongst data from other periods.
-- - Improvcing the data range could maybe shed some light as to whether these layoff trends were solely due to covid or if they were part of a larger pattern that began before the pandemic.
-- 2. Less blank and null-values, along with swapping the "Other" and "Unknown" values for more specific data in the raw data would help imporve raw data quality.
-- - I worked around these as best as I could by populating data after cross-referencing and using self-joins and swapping null values for non-null values wehere they were from the same company and an industry value was left blank or null.
-- 3. Single or limited data-points per country, industyr or company skewed some of the averages.
-- - Providing more raw data for each of these could help to further improve the accuracy of averages and any analysis of them.