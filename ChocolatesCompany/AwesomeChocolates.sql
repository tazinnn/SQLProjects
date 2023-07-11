-- to see all tables
show tables;

-- table description
desc sales;

select *
from sales;

-- calculation and renaming a column
select SaleDate, Amount, Boxes, Amount / Boxes as 'Amount per Box'
from sales

-- WHERE clause, ORDER BY
select *
from sales
where amount > 10000
order by amount
-- DESC. Default is ASC

select *
from sales
where geoid = 'g1'
order by PID, Amount desc

-- amount > 10000 and date within 2022
select *
from sales
where amount > 10000 AND SaleDate >= '2022-01-01' AND SaleDate <= '2022-12-31'
order by SaleDate desc
-- date format is YY-MM-DD

select *
from sales
where amount > 10000 AND year(SaleDate) = 2022
order by amount desc

-- BETWEEN AND
-- boxes 0 to 50
select *
from sales
where boxes between 0 AND 50
-- where boxes > 0 and boxes <= 50
order by boxes desc
-- BETWEEN is inclusive
