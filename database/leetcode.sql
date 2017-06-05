#######################
#Combine Two Tables
#######################

left join is the fastest compare to the two others.

SELECT A.FirstName, A.LastName, B.City, B.State 
FROM Person A 
LEFT JOIN Address as B 
ON A.PersonId = B.PersonId 
basic left join: 902ms.


SELECT FirstName, LastName, City, State
FROM Person
LEFT JOIN Address
USING(PersonId);
left join + using: 907ms


SELECT FirstName, LastName, City, State
FROM Person
NATURAL LEFT JOIN Address;
natural left join: 940ms


#######################
#Second Highest Salary
#######################

SELECT max(Salary) as SecondHighestSalary
FROM Employee
WHERE Salary < (SELECT max(Salary) FROM Employee)

select (
  select distinct Salary from Employee order by Salary Desc limit 1,1
)as SecondHighestSalary


########################
#Nth Highest Salary
########################

CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
Declare M INT;
Set M=N-1;
  RETURN (
      # Write your MySQL query statement below.
      Select Distinct Salary from Employee order by Salary Desc limit M,1
  );
END


The Reason using M = N-1 because MySQL can only take numeric constants in the LIMIT syntax. 
Directly from MySQL documentation:
The LIMIT clause can be used to constrain the number of rows returned by the SELECT statement. 
LIMIT takes one or two numeric arguments, which must both be nonnegative integer constants (except when using prepared statements).


    CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
    
  RETURN (
      # Write your MySQL query statement below.
      
    
      SELECT e1.Salary
      FROM (SELECT DISTINCT Salary FROM Employee) e1
      WHERE (SELECT COUNT(*) FROM (SELECT DISTINCT Salary FROM Employee) e2 WHERE e2.Salary > e1.Salary) = N - 1      
      
      LIMIT 1    
  );
END


###############
#rank score
###############
These are four different solutions.
With Variables: 841 ms
First one uses two variables, one for the current rank and one for the previous score.

SELECT
  Score,
  @rank := @rank + (@prev <> (@prev := Score)) Rank
FROM
  Scores,
  (SELECT @rank := 0, @prev := -1) init
ORDER BY Score desc




Always Count: 1322 ms
This one counts, for each score, the number of distinct greater or equal scores.

SELECT
  Score,
  (SELECT count(distinct Score) FROM Scores WHERE Score >= s.Score) Rank
FROM Scores s
ORDER BY Score desc



Always Count, Pre-uniqued: 795 ms
Same as the previous one, but faster because I have a subquery that "uniquifies" the scores first. 
Not entirely sure why it's faster, I'm guessing MySQL makes tmp a temporary table and uses it for every outer Score.
SELECT
  Score,
  (SELECT count(*) FROM (SELECT distinct Score s FROM Scores) tmp WHERE s >= Score) Rank
FROM Scores
ORDER BY Score desc


Filter/count Scores^2: 1414 ms
Inspired by the attempt in wangkan2001's answer. Finally Id is good for something :-)
SELECT s.Score, count(distinct t.score) Rank
FROM Scores s JOIN Scores t ON s.Score <= t.score
GROUP BY s.Id
ORDER BY s.Score desc





####################
#Consecutive Numbers
######################

# Write your MySQL query statement below
select distinct l1.Num as ConsecutiveNums
from Logs l1 
    join Logs l2 on l1.id=l2.id-1 
    join Logs l3 on l1.id=l3.id-2
where l1.Num=l2.Num and l2.Num=l3.Num


#################
#Employees Earning More Than Their Managers
#################
SELECT e1.Name as Employee FROM Employee e1, Employee e2 where e1.ManagerId = e2.Id and e1.Salary > e2.Salary

#################
#Duplicate Emails
#################
SELECT Email from Person GROUP BY Email having count(Email)>1

################
#Customers Who Never Order
################
#selec all row with null customerid in joined table
Select  a.Name
FROM Customers a left join Orders b 
on a.Id = b.CustomerId
WHERE b.CustomerId is NULL

#not in the order list
SELECT Name as Customers FROM Customers WHERE Id not in (Select DISTINCT CustomerId  FROM Orders b)  

SELECT A.Name from Customers A
WHERE NOT EXISTS (SELECT 1 FROM Orders B WHERE A.Id = B.CustomerId)

select c.Name from Customers c
where (select count(*) from Orders o where o.customerId=c.id)=0

####################
#Department Highest Salary
####################
SELECT D.Name AS Department ,E.Name AS Employee ,E.Salary 
from 
	Employee E,
	Department D 
WHERE E.DepartmentId = D.id 
  AND (DepartmentId,Salary) in 
  (SELECT DepartmentId,max(Salary) as max FROM Employee GROUP BY DepartmentId)

####################
#Department Top Three Salaries
####################
Select B.Name as Department,A.Name as Employee,Salary
From Employee as A inner join Department as B on A.DepartmentId =B.ID 
where (Select Count(Distinct(Salary)) From Employee as C where C.Salary>A.Salary and A.DepartmentId = C.DepartmentId )<3
order by Department,Employee,Salary


#####################
#Delete Duplicate Emails
#####################
1.simple way
DELETE p from Person p, Person q where p.Id>q.Id AND q.Email=p.Email 
2. Select update 
DELETE FROM Person 
WHERE Id not in 
(SELECT c.Id FROM
(SELECT min(Id) as Id FROM Person GROUP BY Email ) c)
