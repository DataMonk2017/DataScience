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
