-- Exploratory Data Analysis

/*
1. Retrieve all records where the percentage laid off is 100%, 
and sort them in descending order by funds raised.
*/
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

/*
2. Sum the number of laid-off employees for each company, group the results by company, 
and sort them in descending order by the total number of layoffs.
*/
SELECT company, SUM(total_laid_off) as sum_total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY sum_total_laid_off DESC;

/*
3. Group records by country, calculate the total number of layoffs for each country, 
and sort the results in descending order by the total number of layoffs.
*/
SELECT country, SUM(total_laid_off) as sum_total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY sum_total_laid_off DESC;

/*
4. Group records by year, calculate the total number of layoffs for each year, 
and sort the results in descending order by the year.
*/
SELECT YEAR(`date`), SUM(total_laid_off) as sum_total_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

/*
5. Group records by month, calculate the total number of layoffs for each month, 
and sort the results in ascending order by month.
*/
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

/*
6. Calculate the cumulative total number of layoffs for each month and return the rolling total, 
ordered by month.
*/
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, sum_total_laid_off, SUM(sum_total_laid_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

/*
7. Rank companies by the total number of layoffs for each year, 
and retrieve the top 5 companies with the highest layoffs per year.
*/
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;