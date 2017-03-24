-- Show time needed to execute each command 
\timing on 

-- Make the output of relations look slightly nicer 
\pset border 2 

-- Echo all input taken from a script file 
-- using the \i command or the --file=... command line option 
\set ECHO all

--Task A:
--Query 1  the query shows gross_sales is not always equal to net_sales+manuf_coupon
SELECT Count(*) FROM postrans WHERE gross_sales<>net_sales+manuf_coupon;
--Query 2 this query used to check whether there exist exceptional situation: 0 units sell, but the sales is not 0.
SELECT Count(*) FROM postrans WHERE unit_count = 0 AND gross_sales <> 0;
--Query 3 this query to check whether the unit price of each good with different transanction number is same
--in other words, this query is made to make sure whether different transanction number sell the same good with same unit price or not. 
SELECT DISTINCT(P.item_number),COUNT(DISTINCT(P.store_num)) AS num_of_store, COUNT(DISTINCT(P.gross_sales/P.unit_count)) AS number_of_different_price FROM postrans P 
WHERE unit_count>0 GROUP BY P.item_number HAVING COUNT(DISTINCT(P.gross_sales/P.unit_count))>1 ORDER BY number_of_different_price DESC LIMIT 10;
-- the answer is no. This query above list the good has the 10 highest number of different unit price with different transanction number.
--Also, this query implies the unit price for some item changes over time in same store since the num_of_store is not equal to number_of_different_price

--This query below count how many items have different unit price with different transanction number.
SELECT COUNT(DISTINCT(P.item_number)) AS number_of_item_which_has_different_price FROM postrans P WHERE P.item_number IN 
(SELECT DISTINCT(D.item_number) FROM postrans D
WHERE D.unit_count>0 GROUP BY D.item_number HAVING COUNT(DISTINCT(D.gross_sales/D.unit_count))>1 );

--Query 4 check whether some non-key attributes in postrans are null
SELECT Count(*) FROM postrans WHERE hshld_acct is NULL; 
SELECT Count(*) FROM postrans WHERE unit_count is NULL;
SELECT Count(*) FROM postrans WHERE net_sales is NULL;
SELECT Count(*) FROM postrans WHERE gross_sales is NULL;

--Query 5 wine_email_sent should be bigger than wine_email_open
SELECT COUNT(*) 
FROM customer 
WHERE wine_email_sent<wine_email_open;
--there are 117 tuples where wine_email_sent<wine_email_open

--Query 6 check whether the household size be equal to the number of adults plus the number of children. 
SELECT COUNT(*) 
FROM customer 
WHERE hh_size <> adult_count + child_count;

--QUERY 7 these 3 quries below is used to figure out that the birth year of oldest child and the birth year of youngest child 
--are both equal to 0 when the households don't raise a child
SELECT COUNT(*) FROM customer WHERE customer.birth_yr_oldest=0;
SELECT COUNT(*) FROM customer WHERE customer.birth_yr_youngest=0;
SELECT COUNT(*) FROM customer WHERE customer.birth_yr_oldest=0 AND customer.birth_yr_youngest=0;
--this query below is to see how the database record the birth_year of child when the household only has 1 child. 
--In other word, when the household only has 1 child, the datanase puts the age of child into birth_yr_youngest or birth_yr_oldest.
SELECT COUNT(*) FROM customer WHERE child_count=1 AND customer.birth_yr_oldest>0 AND customer.birth_yr_youngest>0;
SELECT COUNT(*) FROM customer WHERE child_count=1 AND customer.birth_yr_oldest=0 AND customer.birth_yr_youngest=0;
--the output shows the dataset record some data tuple with the child_count, but birth_yr_youngest and birth_yr_oldest of the data tuple
--bot show 0. In my opinion, 0 means null or data missing.
--the query below is to show how many tuples there are that child_count is not 0 but birth_yr_oldest=0 or  birth_yr_youngest=0
SELECT COUNT(*) FROM customer WHERE child_count>0 AND customer.birth_yr_oldest=0 AND customer.birth_yr_youngest=0;
--these tuples are missing data, so we cannot use these tuples to calculate the answer in Q14
SELECT COUNT(*) FROM customer WHERE child_count=0 AND customer.birth_yr_oldest>0 OR customer.birth_yr_youngest>0;
--the query below is to show that the child,who is already 22, is still a child
SELECT COUNT(*) FROM customer WHERE 2014- customer.birth_yr_oldest=22 AND child_count>0;
--the query below is to show that in some tuples, the child,who is already 22, is not a child now
SELECT COUNT(*) FROM customer WHERE 2014- customer.birth_yr_oldest=22 AND child_count=0;
--Conclusion: we need to get the rid of all tuples which birth_yr_oldest=0 and birth_yr_oldest=0.
--the database is really dirty.

--Task B:
--11. What is the minimum, maximum and average net total spend per household?
SELECT hshld_acct,MIN(net_sales),MAX(net_sales),AVG(net_sales) FROM postrans GROUP BY hshld_acct;

--12.How many households are there, and what is their average total spend, by the number of children in the household?
SELECT COUNT(DISTINCT(Z.hshld_acct)) AS num_of_hshld,AVG(Z.net_sales) AS avg_spend,child_count AS num_of_child
FROM (SELECT Y.hshld_acct,Y.net_sales,C.child_count FROM postrans AS Y 
INNER JOIN (SELECT customer.hshld_acct,customer.child_count FROM customer )AS C 
ON Y.hshld_acct=C.hshld_acct ) AS Z 
GROUP by child_count;

--13.What is the average total spend per household with children, by age of the oldest child, sorted by age?
--SELECT DISTINCT(birth_yr_oldest) FROM customer WHERE birth_yr_oldest>0;
--there exits some housholds which don't raise a child. 
SELECT (2014-Z.birth_yr_oldest) AS age_of_oldest_child, AVG(Z.net_sales) 
FROM (SELECT Y.trans_date,Y.hshld_acct,Y.net_sales,C.birth_yr_oldest FROM postrans AS Y 
	INNER JOIN 
	(SELECT customer.hshld_acct,customer.birth_yr_oldest FROM customer WHERE customer.child_count>0 and customer.birth_yr_oldest>0)AS C 
	on Y.hshld_acct=C.hshld_acct ) AS Z 
GROUP BY age_of_oldest_child ORDER BY age_of_oldest_child;


--14.What was the average age of all the children, by the end of the year of the most recent transaction in the sample? 
--(Assumption: in households with more than two children the ages are evenly distributed between youngest and oldest.)
WITH E AS(
SELECT hshld_acct,MAX(date_part('YEAR', Y.trans_date)) as end_yr_of_most_recent_transaction
 FROM postrans AS Y 
 GROUP BY hshld_acct
),F AS(
SELECT C.hshld_acct,E.end_yr_of_most_recent_transaction,
(C.child_count/2*(E.end_yr_of_most_recent_transaction-C.birth_yr_oldest)+C.child_count/2*(E.end_yr_of_most_recent_transaction-C.birth_yr_youngest))/C.child_count AS avg_age_of_child_per_hshold
FROM customer AS C, E
 WHERE C.hshld_acct in (SELECT hshld_acct FROM E) AND C.child_count>0 AND C.birth_yr_oldest>0 AND C.birth_yr_youngest>0
)
SELECT F.end_yr_of_most_recent_transaction,AVG(F.avg_age_of_child_per_hshold) FROM F GROUP BY F.end_yr_of_most_recent_transaction;


--15.What is the total sales (gross and net) over the sample period, by weekday? 
---The day of the week (0 - 6; Sunday is 0) 
--SELECT EXTRACT(DOW FROM P.trans_date::DATE) as weekday,SUM(P.gross_sales) AS total_gross_sales,SUM(P.net_sales) AS total_net_sales
--FROM postrans P GROUP BY weekday;
--this query shows the text of day of week, like friday wed satuerday sunday etc.
SELECT to_char(P.trans_date,'day') as weekday,SUM(P.gross_sales) AS total_gross_sales,SUM(P.net_sales) AS total_net_sales
FROM postrans P GROUP BY weekday;

--16.What is the total sales (gross and net) over the sample period, by weekday? 
--List the results in order of weekday, Monday first, Sunday last.

--The day of the week (0 - 6; Sunday is 0) 
--SELECT EXTRACT(DOW FROM P.trans_date::DATE) as weekday,SUM(P.gross_sales) AS total_gross_sales,SUM(P.net_sales) AS total_net_sales
--FROM postrans P GROUP BY weekday ORDER BY weekday;
--this query shows the text of day of week, like fri wed sat tue sun etc.
WITH A AS (SELECT EXTRACT(DOW FROM P.trans_date::DATE) as weekday,SUM(P.gross_sales) AS total_gross_sales,SUM(P.net_sales) AS total_net_sales
FROM postrans P GROUP BY weekday)
,B as (SELECT 
	CASE weekday
               WHEN 0 THEN 6
               WHEN 1 THEN 0
               WHEN 2 THEN 1
               WHEN 3 THEN 2
               WHEN 4 THEN 3
               WHEN 5 THEN 4
               WHEN 6 THEN 5
	END AS weekday,total_gross_sales,total_net_sales
FROM A ORDER BY weekday)
SELECT 
	CASE weekday
               WHEN 6 THEN 'Sunday'
               WHEN 0 THEN 'Monday'
               WHEN 1 THEN 'Tuesday'
               WHEN 2 THEN 'Wednesday'
               WHEN 3 THEN 'Thursday'
               WHEN 4 THEN 'Friday'
               WHEN 5 THEN 'Saturday'
	END AS weekday,total_gross_sales,total_net_sales
FROM B;

--17.Which items in the CRAFT BEER category had a lowest net unit price that was less than the highest net unit price? 
--For each of these items include in your results
--1.the item number,
--2.the item description,
--3.the highest net unit price paid,
--4.the lowest net unit price paid,
--5.the discount percentage (how many percent was the lowest price less than the highest price), and
--6.the number of transactions that sold that item for the lowest price.


--18.How many households are there with a 3-year old as the youngest child, and how many of those buy diapers?
--19.How many POS transactions are there in the sample, how many included beer, how many included diapers, and how many included both? 

