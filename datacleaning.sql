--Data cleaning with sql
--1.removing duplicates
--2.standardization 
--3.handling null values
--4.removing unwanted column 
							  
							  					  
							  --Removing duplicates--

with cte as 
(select *, row_number() over ( partition by company, location, industry, total_laid_off,percentage,date_of_layoff, stage, country,
funds_raised_millions) as rn 
from layoff_staging)

select * from cte 
where rn >1;
--we cant update through cte so we have to create a new table with rownumber columnn and data from existing table.

CREATE TABLE layoff_staging02 (
    company varchar(50),
    location varchar(50),
    industry varchar(50),
    total_laid_off INTEGER,
    percentage NUMERIC(5,2),
    date_of_layoff varchar(50),
    stage varchar(50),
    country varchar(50),
    funds_raised_millions NUMERIC(10,2),
	rn int
);
--after creating table i add the rows of existing table with rownumber column.
insert into layoff_staging02
select *, row_number() over ( partition by company, location, industry, total_laid_off,percentage,date_of_layoff, stage, country,
funds_raised_millions) as rn 
from layoff_staging;

delete from layoff_staging02 
where rn >1;

                        --Standardization of data--

--a.Removing space before the rows of company column.
update layoff_staging02
set company = trim(company);

--b.Standardising Industry column.
select distinct(industry) from layoff_staging02
order by 1;

select distinct(industry) from layoff_staging02
where industry like 'Crypto%';

update layoff_staging02
set industry = 'Crypto'
where industry like 'Crypto%';

--c.Standardizing country column
update layoff_staging02
set country = trim(trailing '.' from country ) 
where country like 'United States.';

--d.Changing date format as per sql and converting date column to date datatype.

update layoff_staging02
set date_of_layoff = to_date(date_of_layoff,'yyyy-mm-dd');

alter table layoff_staging02
alter column date_of_layoff type date using date_of_layoff::date;

                               --   .Handling null values

select *   from layoff_staging02 as x
 join layoff_staging02 as y
 on x.company=y.company
 where x.industry is null and
 y.industry is not null;
 

update layoff_staging02
set industry ='Travel'
where company = 'Airbnb'
and
industry is null;

update layoff_staging02
set industry ='Transportation'
where company = 'Carvana'
and
industry is null;

update layoff_staging02
set industry ='Consumer'
where company = 'Jull'
and
industry is null;

delete from layoff_staging02
where total_laid_off is null
and 
percentage is null;

select * from layoff_staging02 
where total_laid_off is null
and 
percentage is null;
                                   --Removing unwanted columns

								   
     
--Deleting the row number column which we created earlier to remove duplicates.

alter table layoff_staging02
drop column rn;









