select * from walmart;

--drop table walmart;

select count(*) from walmart;

select distinct payment_method from walmart;

select payment_method, count(*)
from walmart
group by payment_method;

select count(distinct Branch)
from walmart;

select max(quantity) from walmart;


--Business Problems:

--1. Find diffrent payment methods and number of transactions, number of wty sold.
select payment_method, count(*) as no_of_transactions, sum(quantity) as no_qty_sold
from walmart
group by payment_method;


--2. Identify the highest rated category in each branch, displaying the branch, category, avg rating.
select * 
from
(
select branch, category, avg(rating) as avg_rating, rank() over( partition by branch order by avg(rating) desc ) as rank
from walmart
group by 1, 2
)
where rank = 1;


--3. Identify the busiest day for each branch based on the number of teansactions.
select branch, day_name, no_transactions
from
(
select branch, to_char(to_date(date, 'DD/MM/YY'), 'Day') as day_name, count(*) as no_transactions,
rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1, 2
)
where rank = 1;


--4. Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
select payment_method, sum(quantity) as no_qty_sold
from walmart
group by payment_method;


--5. Determine the average, minimum and maximum rating of category for each city. 
--List the city, average_rating, min_rating and max_rating.
select city, category, avg(rating) as avg_rating, min(rating) as min_rating, max(rating) as max_rating
from walmart
group by 1, 2;


--6. Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
--List category and total_profit, ordered from higest to lowest.
select category, sum(total) as total_revenue, sum(total * profit_margin) as profit
from walmart
group by 1
order by 3 desc;


--7. Determine the most common payment method for each branch.
-- Display Branch and preferred_payment_method.
with cte as 
(
select branch, payment_method, count(*) as total_trans,
rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1, 2
) 
select branch, payment_method, total_trans
from cte
where rank = 1


--8. Categorize sales into 3 groups Morning, Afternoon, evening. 
-- Find out each of the shift and no. of unvoices.
select  branch,
case when extract(hour from(time::time)) < 12 then 'Morning'
when extract(hour from(time::time)) between 12 and 17 then 'Afternoon'
else 'Evening'
end shift,
count(*)
from walmart
group by 1, 2
order by 1, 3 desc


--9. Identify 5 branchbwith highest decrease ratio in revenue compared to the last year.
--(current year 2023 and last year 2022)
select *, extract(year from to_date(date, 'DD/MM/YY')) as formated_date
from walmart	

--2022 sales
with revenue_2022
as (
select branch, sum(total) as revenue
from walmart
where extract(year from to_date(date, 'DD/MM/YY')) = 2022
group by 1
),
--2023 sales
 revenue_2023 as
(
select branch, sum(total) as revenue
from walmart
where extract(year from to_date(date, 'DD/MM/YY')) = 2023
group by 1
)

select ls.branch, ls.revenue as last_year_revenue, cs.revenue as current_year_revenue,
round(((ls.revenue - cs.revenue)::numeric / ls.revenue::numeric ) * 100, 2) as revenue_dec_ratio
from revenue_2022 as ls
join revenue_2023 as cs on ls.branch = cs.branch
where ls.revenue > cs.revenue
order by 4 desc 
limit 5;
