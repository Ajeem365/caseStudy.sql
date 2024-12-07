use case1;
select * from weekly_sales limit 10;

## Data Cleansing

/*
A. Data Cleansing Steps
In a single query, perform the following operations and generate a new table in
the data_mart schema named clean_weekly_sales:
1. Add a week_number as the second column for each week_date value, for
example any value from the 1st of January to 7th of January will be 1, 8th to
14th will be 2, etc.
2. Add a month_number with the calendar month for each week_date value as
the 3rd column
3. Add a calendar_year column as the 4th column containing either 2018, 2019
or 2020 values
4. Add a new column called age_band after the original segment column using
the following mapping on the number inside the segment value
segment age_band

1 Young Adults

2 Middle Aged

3 or 4 Retirees

5. Add a new demographic column using the following mapping for the first
letter in the segment values:
segment | demographic |
C | Couples |
F | Families |

6. Ensure all null string values with an &quot;unknown&quot; string value in the
original segment column as well as the
new age_band and demographic columns
7. Generate a new avg_transaction column as the sales value divided
by transactions rounded to 2 decimal places for
*/
create  table clean_weekly_sales as select week_date,
week(week_date) as week_number,
month(week_date) as month_number,
year(week_date) as year_number,region
platform,
case
when segment='null' then 'unknown'
else segment
end as segment,
case
when right(segment,1)='1' then 'Young Adults'
when right(segment,1)='2' then 'Middle aged'
when right(segment,1) in ('3','4') then 'Retirees'
else 'unknown'
end  as age_band,
case 
when left(segment,1)='C' then 'couples'
when left(segment,1)='F' then 'families'
else 'unknown'
end  as demographic,
customer_type,transactions,sales,
round(sales/(transactions),2) as avg_transactions from weekly_sales;
 select * from clean_weekly_sales limit 20;
 
 ## DATA EXPLORATION
 /*
 1. Which week numbers are missing from the dataset?
 */
 
create table seq100
(x int not null auto_increment primary key);
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 select x + 50 from seq100;
select * from seq100;
create table seq52 as (select x from seq100 limit 52);
select distinct x as week_day from seq52 where x not in(select distinct week_number from clean_weekly_sales); 

select distinct week_number from clean_weekly_sales;
/*
2. How many total transactions were there for each year in the dataset?
*/
select year_number, sum(transactions) as total_transaction from clean_weekly_sales 
group by year_number;


/*
3. What are the total sales for each region for each month?
*/
select month_number, region,sum(sales) as total_sales from clean_weekly_sales
group by region,month_number order by region ,month_number;

/*
4. What is the total count of transactions for each platform
*/

select platform ,sum(transactions) from clean_weekly_sales
group by platform;

/*
## 5.What is the percentage of sales for Retail vs Shopify for each month?
*/


WITH cte_monthly_platform_sales AS (
  SELECT
    month_number,year_number,
    platform,
    SUM(sales) AS monthly_sales
  FROM clean_weekly_sales
  GROUP BY month_number,year_number, platform
)
SELECT
  month_number,year_number,
  ROUND(
    100 * MAX(CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) /
      SUM(monthly_sales),
    2
  ) AS retail_percentage,
  ROUND(
    100 * MAX(CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) /
      SUM(monthly_sales),
    2
  ) AS shopify_percentage
FROM cte_monthly_platform_sales
GROUP BY month_number,year_number
ORDER BY month_number,year_number;


/*
6 Which age_band and demographic values contribute the most to Retail
sales?
*/
SELECT age_band ,demographic, SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC;


