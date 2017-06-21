Database is a fodler that contains all SQL codes I practise.



They're used in different places.  group by modifies the entire query, like:

select customerId, count(*) as orderCount
from Orders
group by customerId
But partition by just works on a window function, like row_number:

select row_number() over (partition by customerId order by orderId)
    as OrderNumberForThisCustomer
from Orders
A group by normally reduces the number of rows returned by rolling them up and calculating averages or sums for each row.  partition by does not affect the number of rows returned, but it changes how a window function's result is calculated.



We can take a simple example

we have a table named TableA with the following values .

id | firstname     |              lastname        |            Mark
---|---------------|------------------------------|-----------------
1  | arun          |              prasanth        |            40
2  | ann           |              antony          |            45
3  | sruthy        |              abc             |            41
6  | new           |              abc             |            47
1  | arun          |              prasanth        |            45
1  | arun          |              prasanth        |            49
2  | ann           |              antony          |            49

Group By

The SQL GROUP BY clause can be used in a SELECT statement to collect data across multiple records and group the results by one or more columns.

In more simple words GROUP BY statement is used in conjunction with the aggregate functions to group the result-set by one or more columns.
syntax :

SELECT expression1, expression2, ... expression_n, 
       aggregate_function (aggregate_expression)
FROM tables
WHERE conditions
GROUP BY expression1, expression2, ... expression_n;
We can apply GroupBy in our table

select SUM(Mark)marksum,firstname from TableA
group by id,firstName
Results :

marksum | firstname
--------|--------
94      |ann                      
134     |arun                     
47      |new                      
41      |sruthy 

In our real table we have 7 rows and when we apply group by id, the server group the results based on id

In simple words

here group by normally reduces the number of rows returned by rolling them up and calculating Sum for each row.
partition by

before going to partition by

let us look at OVER clause

As per MSDN definition

OVER clause defines a window or user-specified set of rows within a query result set. A window function then computes a value for each row in the window. You can use the OVER clause with functions to compute aggregated values such as moving averages, cumulative aggregates, running totals, or a top N per group results.
partition by will not reduce the number of rows returned

we can apply partition by in our example table

select SUM(Mark) OVER (PARTITION BY id) AS marksum, firstname from TableA
result :

marksum | firstname 
--------|-----------
134     |arun                     
134     |arun                     
134     |arun                     
94      |ann                      
94      |ann                      
41      |sruthy                   
47      |new  

look at the results it will partition the rows and results all rows not like group by.
