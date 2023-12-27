-- EXPLORING CovidDeaths

SELECT * FROM CovidProject..CovidDeaths
SELECT * FROM CovidProject..CovidVaccinations

    -- # selecting some importants fields where location is a country
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL -- some fields have location as continent which summarize continent wise data

    -- # where location is a continent or some other region
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent IS NULL

-- * date and location together give an unique record


-- TOTAL CASES VS TOTAL DEATHS
-- calculating death percentage (the percentage of deaths relative to total cases) in India

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT) * 100 AS death_percentage
FROM CovidProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1, 2 


-- POPULATION VS TOTAL CASES
-- calculation population_infected_percentege (the percentage of the population infected with COVID-19) in India

SELECT 
    location, 
    date, 
    population, 
    total_cases, 
    CAST(total_cases AS FLOAT) / CAST(population AS FLOAT) * 100 AS population_infected_percentage
FROM CovidProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1, 2 


-- COUNTRIES WITH HIGHEST INFECTION RATE
-- calculation population_infected_percentage (the maximum total cases divided by population, represented as a percentage)
-- #tableau query 3

SELECT 
    location, 
    population, 
    MAX(total_cases) AS highest_infection_count, 
    MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS population_infected_percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
-- WHERE location LIKE '%India%' -- for India
ORDER BY population_infected_percentage DESC

-- #tableau query 4

SELECT 
    location, 
    population,
    date,
    MAX(total_cases) AS highest_infection_count, 
    MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS population_infected_percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
-- WHERE location LIKE '%India%' -- for India
ORDER BY population_infected_percentage DESC


-- RANKING COUNTRIES WITH THEIR DEATH COUNT

SELECT 
    location, 
    MAX(total_deaths) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
-- AND location LIKE '%India%' -- for India
GROUP BY location
ORDER BY total_death_count DESC


-- RANKING CONTINENTS WITH THEIR DEATH COUNT
-- #tableau query 2

SELECT 
    location, 
    MAX(total_deaths) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
-- AND location LIKE '%India%' -- for India
GROUP BY location
ORDER BY total_death_count DESC


-- GLOBAL NUMBERS
-- #tableau query 1

Select
    SUM(new_cases) as total_cases,
    SUM(new_deaths) as total_deaths,
    CAST(SUM(new_deaths) AS FLOAT) / CAST(SUM(new_cases) AS FLOAT) * 100 AS death_percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- TOTAL POPULATION VS VACCINATIONS

SELECT 
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
    SELECT 
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        v.new_vaccinations,
        SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
    FROM CovidProject..CovidDeaths d
    JOIN CovidProject..CovidVaccinations v
        ON d.location = v.location
        AND d.date = v.date
    WHERE d.continent IS NOT NULL
    --ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated / Population) * 100
FROM PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
    continent varchar(50),
    location varchar(50),
    date DATE,
    population BIGINT,
    new_vaccinations INT,
    rolling_people_vaccinated FLOAT
);
INSERT INTO PercentPopulationVaccinated
SELECT 
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
    ON d.location = v.location
    AND d.date = v.date
--WHERE d.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (rolling_people_vaccinated / Population) * 100
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinatedView AS
SELECT 
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2, 3



SELECT
    CAST(new_deaths AS FLOAT) / CAST(population AS FLOAT) * 1000000 AS new_deaths_per_million,
    CAST(V.new_vaccinations AS FLOAT) / CAST(population AS FLOAT) * 1000 AS new_vaccinations_per_million
FROM
    CovidProject..CovidDeaths D
JOIN
    CovidProject..CovidVaccinations V ON D.location = V.location AND D.date = V.date;

SELECT total_vaccinations, new_vaccinations
FROM CovidProject..CovidVaccinations


-- SELECT total_cases
-- FROM CovidProject..CovidDeaths
-- WHERE date = '2021-07-17'
--     AND location = 'Brazil'
