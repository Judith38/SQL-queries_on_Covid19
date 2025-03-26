--DATA CLEANING STEPS

--Looking for duplicate value. Where there's no unique key or primary key etc, select multiple column to define uniqueness. 
Select location, population, total_cases, new_cases, total_deaths, new_deaths, count (*) As duplicate_counts
from `Covid19_Project.Covid_Deaths`
group by location, population, total_cases, new_cases, total_deaths, new_deaths
Having count (*)>1

--Updating the table. This helps in upadating a column with NULL values

UPDATE `Covid19_Project.Covid_Deaths`
SET continent = 'Asia'
WHERE continent IS NULL AND location = 'Asia'

UPDATE `Covid19_Project.Covid_Deaths` 
SET continent = 'North America'
WHERE continent IS NULL AND location = 'North America'

UPDATE `Covid19_Project.Covid_Deaths`
SET continent = 'Not Given'
WHERE continent IS NULL

UPDATE `Covid19_Project.Covid_Deaths`
SET population = 0
WHERE population IS NULL

UPDATE `Covid19_Project.Covid_Deaths`
SET reproduction_rate = 0
WHERE reproduction_rate IS NULL

--Update table by trimming it
UPDATE `Covid19_Project.Country_Aggregate`
SET location = TRIM (location)
WHERE location = 'world'


--This helps me check for NULL value in the continent column
SELECT location, continent
FROM `Covid19_Project.Covid_Deaths`
WHERE location = 'Asia' and continent IS NULL

SELECT location, continent
FROM `Covid19_Project.Covid_Deaths`
WHERE continent IS NULL

SELECT reproduction_rate
FROM `Covid19_Project.Covid_Deaths`
WHERE reproduction_rate IS NULL


--Checking for NULL value in other columns
SELECT *
FROM `Covid19_Project.Covid_Deaths`
WHERE population IS NULL

SELECT *
FROM `Covid19_Project.Covid_Deaths`
WHERE iso_code IS NULL

--This helps me to know the distinct value. I wanted to know how many continents are in the data. (they were Asia, Africa, Europe, South America, North America, Oceania and NULL)
SELECT Distinct continent
FROM `Covid19_Project.Covid_Deaths`

SELECT location, continent
FROM `Covid19_Project.Covid_Deaths`
WHERE location = 'Asia, Africa, Europe, South America, North America, Oceania' and continent IS NULL

--Creating new table 
CREATE TABLE Covid19_Project.Africa AS
SELECT *
FROM `Covid19_Project.Covid_Deaths`
WHERE continent= 'Africa'

CREATE TABLE Covid19_Project.Covid_Deaths_2 AS
SELECT iso_code, continent,location,date, population, total_cases, new_cases, new_cases_smoothed, total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million, total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million, reproduction_rate
FROM `Covid19_Project.Covid_Deaths`

--Checking for the number of countries
SELECT DISTINCT (iso_code, location)
FROM `Covid19_Project.Covid_Deaths`

--Checking for the number of continent
SELECT DISTINCT (continent)
FROM `Covid19_Project.Covid_Deaths`


--delete columns from the table

ALTER TABLE `Covid19_Project.Covid_Deaths`
DROP COLUMN icu_patients

--delete rows
DELETE from `Covid19_Project.Country_Aggregate`
WHERE location = 'World'

SELECT *
from `Covid19_Project.Country_Aggregate`
where location= 'World'

DELETE from `Covid19_Project.Country_Aggregate`
WHERE location = 'European Union'

Select *
from `Covid19_Project.Country_Aggregate`
where location= 'European Union'

DELETE from `Covid19_Project.Country_Aggregate`
WHERE location = 'Asia'

Select *
from `Covid19_Project.Country_Aggregate`
where location= 'Asia'

DELETE from `Covid19_Project.Country_Aggregate`
WHERE location = 'Europe'

Select *
from `Covid19_Project.Country_Aggregate`
where location= 'Europe'

DELETE from `Covid19_Project.Country_Aggregate`
WHERE location = 'Africa'

Select *
from `Covid19_Project.Country_Aggregate`
where location= 'Africa'

DELETE from `Covid19_Project.Country_Aggregate`
WHERE location = 'South America'

Select *
from `Covid19_Project.Country_Aggregate`
where location= 'South America'

DELETE from `Covid19_Project.Country_Aggregate`
WHERE location = 'North America'

Select *
from `Covid19_Project.Country_Aggregate`
where location= 'North America'

DELETE from `Covid19_Project.Country_Aggregate`
WHERE location = 'Oceania'

Select *
from `Covid19_Project.Country_Aggregate`
where location= 'Oceania'

--DATA INSIGHTS

--Aggregating the data based on continent
--SUM CONTINENT
SELECT continent, sum(population) AS Total_Population, sum(total_cases) AS Total_Cases, sum(new_cases) AS New_Cases, sum(total_deaths) AS Total_Deaths, sum(new_deaths) AS New_Deaths
FROM `Covid19_Project.Covid_Deaths_2`
GROUP BY continent

--SUM COUNTRY
SELECT location, sum(population) AS Total_Population, sum(total_cases) AS Total_Cases, sum(new_cases) AS New_Cases, sum(total_deaths) AS Total_Deaths, sum(new_deaths) AS New_Deaths
FROM `Covid19_Project.Covid_Deaths_2`
GROUP BY location

--Average 
SELECT continent, Avg(population) AS Avg_Population, Avg(total_cases) AS Avg_Total_Cases, Avg(new_cases) AS Avg_New_Cases, Avg(total_deaths) AS Avg_Total_Deaths, Avg(new_deaths) AS Avg_New_Deaths
FROM `Covid19_Project.Covid_Deaths_2`
GROUP BY continent

--Other calculations

--Percentage of total cases/ population
--Total cases/ population

SELECT 
        continent, 
        location, 
        population,
        date, 
        total_cases, 
        (total_cases/population)*100 AS Total_case_to_population
FROM `Covid19_Project.Covid_Deaths_2`
WHERE population > 0
ORDER BY 1,2

SELECT 
        continent,  
        population,
        date, 
        total_cases, 
        (total_cases/population)*100 AS Total_case_to_population
FROM `Covid19_Project.Covid_Deaths_2`
WHERE population > 0
GROUP BY continent, 
        population,
        date, 
        total_cases
ORDER BY 1,2


--Date filtering

-- Monthly sum
SELECT Continent,Location, format_date('%B',date) As Month, extract(year from date) As Year, sum(total_cases) As Total_cases,sum(new_cases) AS New_Cases, sum(total_deaths) AS Total_Deaths, sum(new_deaths) AS New_Deaths
FROM `Covid19_Project.Covid_Deaths_2`
GROUP BY month, year, continent, location
order by 1,2

--Monthly %rates 
SELECT  Continent,
        Location, 
        format_date('%B',date) As Month,
        extract(year from date) As Year, 
        CASE 
        WHEN sum(total_cases) > 0 then (sum (new_cases)/sum (total_cases))*100 else null end as Rates_Of_NewCases_TotalCase,
        CASE
        WHEN sum(new_deaths) > 0 then (sum(new_cases)/sum(new_deaths))*100 else null end as Rates_Of_NewCases_Newdeaths,
        CASE
        WHEN sum(total_cases) >0 then (sum(total_deaths)/sum(total_cases))*100 else null end as Rates_Of_TotalDeaths_TotalCases,
        CASE
        WHEN sum(total_cases) > 0 then (sum(new_deaths)/sum(total_cases))*100 else null end as Rates_Of_NewDeaths_TotalCase
FROM `Covid19_Project.Covid_Deaths_2`
GROUP BY continent, location, month, year 
order by continent, location,year


--Daily rates

SELECT 
    iso_code,
    Continent,
    Location, 
    date,
    population,
    new_cases, 
    total_cases, 
    new_deaths, 
    total_deaths,
    CASE 
        WHEN total_cases > 0 THEN (new_cases / total_cases) * 100 
        ELSE NULL 
    END AS Rates_Of_NewCases_TotalCase,
    CASE 
        WHEN new_deaths > 0 THEN (new_cases / new_deaths) * 100 
        ELSE NULL 
    END AS Rates_Of_NewCases_NewDeaths,
    CASE 
        WHEN total_cases > 0 THEN (total_deaths / total_cases) * 100 
        ELSE NULL 
    END AS Rates_Of_TotalDeaths_TotalCases,
    CASE 
        WHEN total_cases > 0 THEN (new_deaths / total_cases) * 100 
        ELSE NULL 
    END AS Rates_Of_NewDeaths_TotalCase
FROM 
    `Covid19_Project.Covid_Deaths_2`
GROUP BY 
    iso_code, Continent, Location, date, population, new_cases, total_cases, new_deaths, total_deaths
ORDER BY 
    Continent, Location;


SELECT FORMAT_DATE('%Y_%B',date) AS Year_Month
FROM `Covid19_Project.Covid_Deaths_2`
GROUP BY Year_Month

--MIN & MAX

WITH Min_Cases AS (
    SELECT 
        Location, 
        total_population, 
        total_cases, 
        new_cases, 
        total_deaths, 
        new_deaths
    FROM 
        `Covid19_Project.Country_Aggregate`
    ORDER BY 
        total_cases ASC
    LIMIT 1
),
Max_Cases AS (
    SELECT 
        Location, 
        total_population, 
        total_cases, 
        new_cases, 
        total_deaths, 
        new_deaths
    FROM 
        `Covid19_Project.Country_Aggregate`
    ORDER BY 
        total_cases DESC
    LIMIT 1
)
SELECT * FROM Min_Cases
UNION ALL
SELECT * FROM Max_Cases


--SELECT location, max(total_population) AS Max_Total_Population, max(total_cases) AS Max_Total_Cases, max(new_cases) AS Max_New_Cases, max(total_deaths) AS Max_Total_Deaths, max(new_deaths) AS Max_New_Deaths

--Subquery
SELECT *
FROM `Covid19_Project.Country_Aggregate`
WHERE total_cases > (select min (total_cases)
                      from `Covid19_Project.Continent_Aggregate`
)
