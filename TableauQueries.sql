-- TABLEAU QUERY 1
-- Global COVID-19 Overview

SELECT
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    CAST(SUM(new_deaths) AS FLOAT) / NULLIF(CAST(SUM(new_cases) AS FLOAT), 0) * 100 AS death_percentage
FROM
    CovidProject..CovidDeaths
WHERE
    continent IS NOT NULL;

-- TABLEAU QUERY 2
-- Top 5 Continents by Total Death Count

SELECT TOP 5
    location, 
    MAX(total_deaths) AS max_total_death_count 
FROM 
    CovidProject..CovidDeaths
WHERE 
    continent IS NULL
    AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Low income') 
    -- AND location LIKE '%India%' -- for India
GROUP BY 
    location
ORDER BY 
    max_total_death_count DESC

-- TABLEAU QUERY 3
-- Top 5 Countries by Total Death Count

SELECT TOP 5
    location,
    MAX(total_deaths) AS total_death_count
FROM
    CovidProject..CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY
    location
ORDER BY
    total_death_count DESC

-- TABLEAU QUERY 4
-- Infection Rate Over Time

SELECT 
    location, 
    population,
    date,
    MAX(total_cases) AS highest_infection_count, 
    MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS infected_population_percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
-- WHERE location LIKE '%India%' -- for India
ORDER BY infected_population_percentage DESC

-- TABLEAU QUERY 5
-- Vaccination Rate Over Time

SELECT
    D.location,
    D.date,
    D.population,
    MAX(V.total_vaccinations) AS highest_vaccination_count,
    MAX(CAST(V.total_vaccinations AS FLOAT) / CAST(D.population AS FLOAT)) * 100 AS vacinated_population_percentage
FROM
    CovidProject..CovidDeaths D
JOIN
    CovidProject..CovidVaccinations V ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL
GROUP BY D.location, D.population, D.date
-- WHERE location LIKE '%India%' -- for India
ORDER BY vacinated_population_percentage DESC


-- TABLEAU QUERY 6
-- New Cases Over Time

SELECT location, date, population, new_cases
from CovidProject..CovidDeaths
