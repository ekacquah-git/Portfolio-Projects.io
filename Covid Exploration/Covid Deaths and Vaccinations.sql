--Selecting Data we are working with

SELECT * FROM coviddeaths;

SELECT country, date, total_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2;

-- Comparing total cases to total deaths to show likeliness of death by day.
SELECT 
country, 
date, 
total_cases, 
total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM coviddeaths
WHERE country LIKE '%States%'
ORDER BY 1,2;

--Comparing total cases to population to show likeliness of getting covid in US by day
SELECT 
country, 
date, 
total_cases, 
population, (total_cases/population)*100 AS infectionrate
FROM coviddeaths
WHERE country LIKE '%States%'
ORDER BY 1,2;

--Countries with the highest infection rate
SELECT
country AS location,
population, 
MAX(total_cases) AS highest_infection_count,
MAX(total_cases/population)*100 AS infection_rate
FROM coviddeaths
WHERE population IS NOT NULL
GROUP BY country, population
ORDER BY infection_rate DESC;

SELECT
country,
population,
date,
MAX(total_cases) AS highest_infection_count,
MAX(total_cases/population)*100 AS infection_rate
FROM coviddeaths
WHERE population IS NOT NULL AND country NOT LIKE '%countries%'
GROUP BY country, population, date
ORDER BY infection_rate DESC;
--Countries with the highest death count per population
--Continent with the highest death count per population

SELECT
country, 
MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE population IS NOT NULL AND continent IS NOT NULL
GROUP BY country
ORDER BY total_death_count DESC;

-- by continent
SELECT
continent AS location, 
MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE population IS NOT NULL AND continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

--Total deaths per cases
SELECT
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 AS total_deathpercentage
FROM coviddeaths;

--Joining the covidvaccinations to the coviddeaths to make a new table
-- Viewing new vaccinations by day for each continent and coountry with a running total
SELECT cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cv.country ORDER BY cv.country,cd.date) AS new_vac_runningtotal
FROM coviddeaths cd
LEFT JOIN covidvaccinations cv
ON cd.country = cv.country
AND	cd.date = cv.date
WHERE cv.continent IS NOT NULL;

--Checking the percent vaccinated by day.
WITH rollingtotal_cte
AS(
SELECT cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cv.country ORDER BY cv.country,cd.date) AS new_vac_runningtotal
FROM coviddeaths cd
LEFT JOIN covidvaccinations cv
ON cd.country = cv.country
AND	cd.date = cv.date
WHERE cv.continent IS NOT NULL)
SELECT *, (new_vac_runningtotal/population)*100 AS percent_vaccinated
FROM rollingtotal_cte;

--Transferring into queries into a View to work with
CREATE VIEW runningvaccinations_view
AS(WITH rollingtotal_cte
AS(
SELECT cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cv.country ORDER BY cv.country,cd.date) AS new_vac_runningtotal
FROM coviddeaths cd
LEFT JOIN covidvaccinations cv
ON cd.country = cv.country
AND	cd.date = cv.date
WHERE cv.continent IS NOT NULL)
SELECT *, (new_vac_runningtotal/population)*100 AS percent_vaccinated
FROM rollingtotal_cte);

-- Query View to check
SELECT * FROM runningvaccinations_view
WHERE new_vaccinations IS NOT NULL;

--Create as view to export to Tableau Public
CREATE VIEW coviddeathscases_view
AS(SELECT
country,
population,
date,
MAX(total_cases) AS highest_infection_count,
MAX(total_cases/population)*100 AS infection_rate
FROM coviddeaths
WHERE population IS NOT NULL AND country NOT LIKE '%countries%'
GROUP BY country, population, date
ORDER BY infection_rate DESC);