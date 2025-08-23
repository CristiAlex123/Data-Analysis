-- Data Cleaning Project

select * 
from world_layoffs.layoffs_staging; -- Created a copy of the original database


with duplicate_cte as -- Numbered each row with row_number() to create a pseudo ID
(
select * ,
row_number() over(
partition by company, location , industry, total_laid_off, percentage_laid_off, `date`,stage, country,funds_raised_millions) as row_num
from world_layoffs.layoffs_staging
)
select * -- Rows with row_num > 1 are duplicates and should be removed, considering all columns
from duplicate_cte
where row_num > 1 
;


CREATE TABLE `world_world_layoffs.layoffs.world_layoffs.layoffs_staging2` ( -- Added a new column to store the pseudo ID in a new table
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

select * 
from world_layoffs.layoffs_staging2 
where row_num > 1;

insert into world_layoffs.layoffs_staging2 -- Inserted data into the new table including the row_num column
select * ,
row_number() over(
partition by company, location , industry, total_laid_off, percentage_laid_off, `date`,stage, country,funds_raised_millions) as row_num
from world_layoffs.layoffs_staging
;

delete -- Removed all duplicate rows
from world_layoffs.layoffs_staging2
where row_num > 1;

select * -- Double-check if everything looks good
from world_layoffs.layoffs_staging2;



-- Standardizing data

select company, trim(company) -- Removed leading/trailing spaces from company names
from world_layoffs.layoffs_staging2;

update world_layoffs.layoffs_staging2 -- Updated the table with trimmed company names
set company = trim(company)
;

select * -- Additional checks for inconsistencies
from world_layoffs.layoffs_staging2
;

update world_layoffs.layoffs_staging2 -- Standardized industry values: "Crypto currency" to "Crypto"
set industry='Crypto'
where industry like 'Crypto%'
;


select * -- Spelling inconsistency for "United States"
from world_layoffs.layoffs_staging2
where country like 'United States%'
;

select distinct country, trim(trailing '.' from country)  -- Removed trailing '.' from country names like "United States."
from world_layoffs.layoffs_staging2
order by 1
;

update world_layoffs.layoffs_staging2 -- Applied update to fix the issue
set country = trim(trailing '.' from country)
where country like 'United States%';


select `date`, -- Converted date strings to DATE format (e.g. '2023-01-27')
STR_TO_DATE(`date`, '%m/%d/%Y')
from world_layoffs.layoffs_staging2
;

update world_layoffs.layoffs_staging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

alter table world_layoffs.layoffs_staging2 -- Changed column type from TEXT to DATE
modify column `date` DATE;


-- Handling null values

select * -- Checked for rows where both total_laid_off and percentage_laid_off are null
from world_layoffs.layoffs_staging2
where total_laid_off is null AND percentage_laid_off is null
;

update world_layoffs.layoffs_staging2 -- Replaced empty strings with null in industry column
set industry = null
where industry = ''
;

select * -- Checked for blank or null values in industry
from world_layoffs.layoffs_staging2
where industry = '' or industry is null
;

select * 
from world_layoffs.layoffs_staging2
where company = 'Airbnb'
;

select t1.industry, t2.industry -- Joined table with itself to compare null vs non-null industry values for the same company
from world_layoffs.layoffs_staging2 t1
join world_layoffs.layoffs_staging2 t2
	on t1.company = t2.company
where t1.industry is null 
and t2.industry is not null;

update world_layoffs.layoffs_staging2 t1 -- Updated null industry values with the correct industry from matching company
join world_layoffs.layoffs_staging2 t2
	on t1.company = t2.company
set t1.company = t2.company
where t1.industry is null
and t2.industry is not null
;


select * 
from world_layoffs.layoffs_staging2
;


-- Deleting unnecessary rows

select * 
from world_layoffs.layoffs_staging2
where total_laid_off is null AND percentage_laid_off is null
;

delete -- Removed rows with no useful information
from world_layoffs.layoffs_staging2
where total_laid_off is null AND percentage_laid_off is null
;

alter table world_layoffs.layoffs_staging2 -- Dropped row_num column since it’s no longer needed
drop column row_num;
