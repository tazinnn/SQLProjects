-- to see all tables
show tables;

-- table description
desc sales;

SELECT 
    *
FROM
    sales;

-- calculation and renaming a column
select SaleDate, Amount, Boxes, Amount / Boxes as 'Amount per Box'
from sales;

-- WHERE clause, ORDER BY
select *
from sales
where amount > 10000
order by amount;
-- DESC. Default is ASC

select *
from sales
where geoid = 'g1'
order by PID, Amount desc;

-- amount > 10000 and date within 2022
select *
from sales
where amount > 10000 AND SaleDate >= '2022-01-01' AND SaleDate <= '2022-12-31'
order by SaleDate desc;
-- date format is YY-MM-DD

select *
from sales
where amount > 10000 AND year(SaleDate) = 2022
order by amount desc;

-- BETWEEN AND
-- boxes 0 to 50
select *
from sales
where boxes between 0 AND 50
-- where boxes > 0 and boxes <= 50
order by boxes desc;
-- BETWEEN is inclusive

-- shipment on FRIDAY
select *, weekday(saledate) as 'Day of the week'
from sales
where weekday(saledate) = 4;
-- weekday: 0 = Monday
-- alias cannot be used in WHERE. Alternative: CTE

-- using MULTIPLE TABLES
select *
from people;

-- team Delish or Jucies
select *
from people
where team = 'Delish' OR team = 'Jucies';

-- IN Clause
SELECT *
FROM people
WHERE team IN('Delish', 'Jucies');

-- PATTERN MATCHING using LIKE
SELECT *
FROM people
WHERE Salesperson LIKE 'B%';
-- '%B%', 'B*',

-- CASE operator
SELECT 
    SaleDate,
    Amount,
    CASE
        WHEN amount < 1000 THEN 'Under 1k'
        WHEN amount < 5000 THEN 'Under 5k'
        WHEN amount < 10000 THEN 'Under 10k'
        ELSE '10k or more'
    END AS 'Amount Category'
FROM
    sales;

-- ********** JOIN ********** --
SELECT *
FROM sales;
-- SPID, GeoID, PID, SaleDate, Amount, Customers, Boxes

SELECT *
FROM people;
-- Salesperson, SPID, Team, Location

SELECT s.SaleDate, s.Amount, p.Salesperson
FROM sales s
JOIN people p ON p.SPID = s.SPID;

SELECT s.saledate, s.amount, s.pid, pr.product
FROM sales s
LEFT JOIN products pr ON pr.pid = s.pid;

SELECT s.SaleDate, s.Amount, p.Salesperson, pr.Product, p.Team
FROM sales s
JOIN people p ON p.SPID = s.SPID
JOIN products pr ON pr.pid = s.pid;

SELECT s.SaleDate, s.Amount, p.Salesperson, pr.Product, p.Team
FROM sales s
JOIN people p ON p.SPID = s.SPID
JOIN products pr ON pr.pid = s.pid
WHERE s.amount < 500 AND p.team = '';

SELECT s.SaleDate, s.Amount, p.Salesperson, pr.Product, p.Team
FROM sales s
JOIN people p ON p.SPID = s.SPID
JOIN products pr ON pr.pid = s.pid
JOIN geo g ON g.GeoID = s.GeoID
WHERE s.amount < 500 
AND p.team = ''
AND g.geo IN ('New Zealand', 'India');

-- *** GROUP BY *** --
SELECT GeoID, SUM(Amount), AVG(Amount), SUM(Boxes)
FROM sales
GROUP BY GeoID;

SELECT g.Geo, SUM(Amount), AVG(Amount), SUM(Boxes)
FROM sales s
JOIN geo g ON s.GeoID = g.GeoID
GROUP BY g.Geo;

SELECT pr.Category, p.Team, SUM(Boxes), SUM(Amount)
FROM sales s
JOIN people p ON p.SPID = s.SPID
JOIN products pr ON pr.PID = s.PID
WHERE p.Team <> ''
GROUP BY pr.Category, p.Team
ORDER BY pr.Category, p.Team;

-- show top 10 products by Amount
SELECT pr.Product, SUM(s.Amount) AS 'Total Amount'
FROM sales s
JOIN products pr ON pr.PID = s.PID
GROUP BY pr.Product
ORDER BY `Total Amount` DESC
LIMIT 10;
