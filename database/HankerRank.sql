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
