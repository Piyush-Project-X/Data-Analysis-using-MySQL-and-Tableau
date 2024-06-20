-- This SQL script is structured to create a database, explore datasets, 
-- perform various calculations, create a common table expression (CTE), 
-- and create a view for later visualization. 

-- Create a new database named `portfolio_project`
CREATE DATABASE `portfolio_project`;

-- Select the `portfolio_project` database for use
USE `portfolio_project`;

-- Exploring the coviddeaths dataset by selecting all columns and ordering by the 3rd and 5th columns
SELECT * FROM portfolio_project.coviddeaths
ORDER BY 3, 5;

-- Exploring the covidvaccination dataset by selecting all columns and ordering by the 3rd and 5th columns
SELECT * FROM portfolio_project.covidvaccination
ORDER BY 3, 5;

-- Counting the number of records in the coviddeaths table
SELECT COUNT(*) FROM portfolio_project.coviddeaths;

-- Counting the number of records in the covidvaccination table
SELECT COUNT(*) FROM portfolio_project.covidvaccination;

-- Calculating death percentage for Afghanistan and filtering out null percentages
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolio_project.coviddeaths
WHERE location LIKE '%afgha%' AND (total_deaths/total_cases)*100 IS NOT NULL 
ORDER BY 1, 2;

-- Calculating infection rate as a percentage of the population for Afghanistan and filtering out null percentages
SELECT location, date, total_cases, total_deaths, (total_cases/population)*100 AS InfectionPercentage
FROM portfolio_project.coviddeaths
WHERE location LIKE '%afgha%' AND (total_cases/population)*100 IS NOT NULL 
ORDER BY 1, 2;

-- Identifying countries with the highest infection rate compared to population
SELECT location, date, MAX(total_cases), total_deaths, MAX(total_cases/population)*100 AS InfectionPercentage
FROM portfolio_project.coviddeaths
GROUP BY location, date, total_deaths;

-- Total death count per continent, ordered by the highest death count
SELECT continent, MAX(total_deaths) AS Total_Deaths
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Deaths DESC;

-- Total death count per location, ordered by the highest death count
SELECT location, MAX(total_deaths) AS Total_Deaths
FROM portfolio_project.coviddeaths
WHERE location IS NOT NULL
GROUP BY location
ORDER BY Total_Deaths DESC;

-- Global numbers for new cases and new deaths, grouped by location and date
SELECT location, date, SUM(new_cases), SUM(new_deaths)
FROM portfolio_project.coviddeaths
WHERE location IS NOT NULL
GROUP BY location, date
ORDER BY 1, 2;

-- Joining coviddeaths and covidvaccination tables on location and date to combine relevant data
SELECT * 
FROM portfolio_project.coviddeaths cd
JOIN portfolio_project.covidvaccination cv
    ON cd.location = cv.location
    AND cd.date = cv.date;

-- Calculating the percentage of population that has received at least one COVID vaccine
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPercentage
FROM portfolio_project.coviddeaths cd
JOIN portfolio_project.covidvaccination cv
    ON cd.location = cv.location
    AND cd.date = cv.date;

-- Using a Common Table Expression (CTE) to encapsulate the rolling percentage calculation for easier reuse
WITH popvsvac AS (
    SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPercentage
    FROM portfolio_project.coviddeaths cd
    JOIN portfolio_project.covidvaccination cv
        ON cd.location = cv.location
        AND cd.date = cv.date
)
-- Selecting all columns from the CTE
SELECT * 
FROM popvsvac;

-- Creating a view for later visualizations to show the highest infection rate compared to population
CREATE VIEW coviddata AS
SELECT location, date, MAX(total_cases), total_deaths, MAX(total_cases/population)*100 AS InfectionPercentage
FROM portfolio_project.coviddeaths
GROUP BY location, date, total_deaths;

-- Querying the view to verify its creation and content
SELECT * FROM coviddata;
