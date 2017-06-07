#Revising the Select Query I
SELECT * FROM CITY WHERE Population > 100000 and CountryCode = 'USA'

#Revising the Select Query II
SELECT * FROM CITY WHERE Population > 120000 and CountryCode = 'USA'

#Select All
SELECT * FROM CITY

#Select By ID
SELECT *  FROM CITY WHERE ID = 1661

#Japanese Cities' Attributes
SELECT * FROM CITY WHERE COUNTRYCODE = 'JPN'

#Japanese Cities' Names
SELECT Name FROM CITY WHERE COUNTRYCODE = 'JPN'

#Type of Triangle
SELECT 
CASE
WHEN A+B>C and A+C>B and B+C>A THEN 
    CASE
    WHEN A = B and B = C THEN 'Equilateral'
    WHEN A != B and B != C and A != C THEN 'Scalene'
    ELSE 'Isosceles'
    END
ELSE 'Not A Triangle' 
END 
FROM TRIANGLES

#The PADS
SELECT CONCAT(Name, '(',LEFT(Occupation,1),')') FROM Occupations Order by Name ASC;

SELECT CONCAT('There are total ', COUNT(*),' ' , Lower(Occupation),'s.') 
FROM Occupations GROUP BY Occupation Order by COUNT(*),Occupation ASC;

#Occupations
#sql server
SELECT min(Doctor) as Doctor,
min(Professor) as Professor,
min(Singer) as Singer,
min(Actor) as Actor
from(
select RANK() OVER (PARTITION BY Occupation ORDER BY Name) as Rank,
    case when Occupation='Doctor' then Name else null end as Doctor,
    case when Occupation='Professor' then Name else null end as Professor,
    case when Occupation='Singer' then Name else null end as Singer,
    case when Occupation='Actor' then Name else null end as Actor from Occupations) as T group by Rank
    
#mysql
set @r1=0, @r2=0, @r3=0, @r4=0;
select min(Doctor), min(Professor), min(Singer), min(Actor)
from(
  select case when Occupation='Doctor' then (@r1:=@r1+1)
            when Occupation='Professor' then (@r2:=@r2+1)
            when Occupation='Singer' then (@r3:=@r3+1)
            when Occupation='Actor' then (@r4:=@r4+1) end as RowNumber,
    case when Occupation='Doctor' then Name end as Doctor,
    case when Occupation='Professor' then Name end as Professor,
    case when Occupation='Singer' then Name end as Singer,
    case when Occupation='Actor' then Name end as Actor
  from OCCUPATIONS
  order by Name
) Temp
group by RowNumber
    
#Binary Tree Nodes
SELECT N, 
CASE
WHEN P is NULL THEN 'Root'
WHEN N in (SELECT distinct P FROM BST) THEN 'Inner'
ELSE 'Leaf' END
FROM BST ORDER BY N

#New Companies
SELECT e.company_code,
c.Founder,
count(distinct lead_manager_code),
count(distinct senior_manager_code),
count(distinct manager_code),
count(distinct employee_code) 
FROM Company c,Employee e 
WHERE c.company_code = e.company_code 
group by e.company_code,c.Founder order by company_code

#Projects
SELECT Start_Date, min(End_Date)
FROM 
    (SELECT Start_Date FROM Projects WHERE Start_Date NOT IN (SELECT End_Date FROM Projects)) a,
    (SELECT End_Date FROM Projects WHERE End_Date NOT IN (SELECT Start_Date FROM Projects)) b 
WHERE Start_Date < End_Date
GROUP BY Start_Date 
ORDER BY min(End_Date) - Start_Date, Start_Date

#Placements
#MS SQL Server
WITH CTE AS ( SELECT F.ID , 
            N1.Name as SN, 
            N2.Name as FN, 
            P1.Salary as ISal,
            P2.Salary as FSal, 
            F.Friend_ID 
      FROM FRIENDS F JOIN PACKAGES P1 
            ON P1.ID = F.ID
           Join Packages P2 
           ON P2.ID = F.Friend_ID
      JOIN Students N1
      ON N1.ID = F.ID
           Join Students N2 
           ON N2.ID = F.Friend_ID)
SELECT SN
FROM CTE
WHERE FSal>ISal order by FSal

#MYSQL
SELECT SN
FROM (
SELECT F.ID , 
       N1.Name as SN, 
       P1.Salary as ISal,
       P2.Salary as FSal, 
       F.Friend_ID 
        FROM FRIENDS F JOIN PACKAGES P1 
           ON P1.ID = F.ID
           Join Packages P2 
           ON P2.ID = F.Friend_ID
      JOIN Students N1
      ON N1.ID = F.ID) CTE
WHERE FSal>ISal order by FSal


#Symmetric Pairs
SELECT * FROM
((SELECT X,Y FROM Functions WHERE (X,Y) in (SELECT Y,X FROM Functions ) and X<Y) 
Union 
(SELECT X,Y FROM Functions WHERE X=Y Group by X,Y Having Count(*)>1 )) c
ORDER BY X

#Interviews
#varaition1
SELECT e.contest_id, 
    e.hacker_id, 
    e.name, 
    sum(ts),
    sum(tas),
    sum(tv),
    sum(tuv)
From
    Contests e
    JOIN Colleges a  ON a.contest_id = e.contest_id
    JOIN Challenges b ON a.college_id = b.college_id
    LEFT JOIN (SELECT challenge_id,
                      sum(total_views) as tv,
                      sum(total_unique_views) as tuv 
               FROM View_Stats 
               group by challenge_id) c
    ON b.challenge_id = c.challenge_id
    LEFT JOIN (SELECT challenge_id,
                    sum(total_submissions) as ts, 
                    sum(total_accepted_submissions) as tas
               FROM  Submission_Stats 
               group by challenge_id) d
    ON d.challenge_id = b.challenge_id
GROUP BY e.contest_id, e.hacker_id, e.name
order by contest_id
#varaition2
SELECT a.contest_id, 
    e.hacker_id, 
    e.name,
    sum(ts),
    sum(tas),
    sum(tv),
    sum(tuv)
From
    Colleges a 
    JOIN Challenges b ON a.college_id = b.college_id
    JOIN Contests e ON a.contest_id = e.contest_id
    LEFT JOIN (SELECT challenge_id,
          sum(total_views) as tv,
          sum(total_unique_views) as tuv 
          FROM View_Stats group by challenge_id) c
    ON b.challenge_id = c.challenge_id
    LEFT JOIN (SELECT challenge_id,
          sum(total_submissions) as ts, 
          sum(total_accepted_submissions) as tas
          FROM  Submission_Stats group by challenge_id) d
    ON d.challenge_id = b.challenge_id
GROUP BY a.contest_id, e.hacker_id, e.name
order by contest_id
