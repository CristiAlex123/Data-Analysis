-- Explorind Data Analysis

select * 
from layoffs_staging2;



select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;


-- What companies with 100% layoffs, sorted by funds raised
select * 
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc
;


select company ,sum(total_laid_off) 
from layoffs_staging2
group by company
order by 2 desc
;


-- Identify the time span of the datase
select min(`date`), max(`date`)
from layoffs_staging2;


-- Total layoffs per industry
select industry ,sum(total_laid_off) 
from layoffs_staging2
group by industry
order by 2 desc
;


-- Total layoffs per country
select country ,sum(total_laid_off) 
from layoffs_staging2
group by country
order by 2 desc
;

-- Total layoffs per year
select year(`date`) ,sum(total_laid_off) 
from layoffs_staging2
group by year(`date`)
order by 1 desc
;

select stage ,sum(total_laid_off) 
from layoffs_staging2
group by stage
order by 1 desc
;


select company ,sum(total_laid_off) 
from layoffs_staging2
group by company
order by 2 desc
;


-- Monthly layoffs analysis
select substring(`date`, 1, 7) as `month`, sum(total_laid_off)
from  layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 desc
;


-- Rolling total of layoffs over time
with Rolling_total as 
(
select substring(`date`, 1, 7) as `month`, sum(total_laid_off) as total_off
from  layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 desc
)
select `month`, total_off,
sum(total_off) over(order by `month`) as rolling_total
from Rolling_total;


select company ,sum(total_laid_off) 
from layoffs_staging2
group by company
order by 2 desc
;


-- Yearly layoffs by company
select company , year(`date`) ,sum(total_laid_off) 
from layoffs_staging2
group by company, year(`date`)
order by 3 desc
;


-- Top 5 companies with most layoffs per year
with Company_Year (company, years, total_laid_off) as 
(
select company , year(`date`) ,sum(total_laid_off) 
from layoffs_staging2
group by company, year(`date`)
),
Company_Year_Rank as 
(
select * ,dense_rank() over( partition by years order by total_laid_off desc) as Ranking
from Company_Year
where years is not null
)
select * from Company_Year_Rank
where Ranking <= 5
;



