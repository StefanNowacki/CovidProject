SELECT
    location,
    data,
    total_cases,
    total_deaths,
    ( total_deaths / total_cases ) * 100 AS deathpercentage
FROM
    coviddeaths
WHERE
    location LIKE 'Poland'
ORDER BY
    1,
    2;

--  total cases vs population
--  percentage of population got covid

SELECT
    location,
    data,
    total_cases,
    population,
    total_deaths,
    ( total_cases / population ) * 100 AS populationgotcovid
FROM
    coviddeaths
WHERE
    location LIKE 'Poland'
ORDER BY
    1,
    2;

-- highest infection count by country

SELECT
    location,
    population,
    MAX(total_cases) AS highestinfectioncount,
    MAX((total_cases / population)) * 100 AS percentpopulationinfected
FROM
    coviddeaths
GROUP BY
    location,
    population
ORDER BY
    4 DESC;

-- highest deaths by country

SELECT
    location,
    MAX(total_deaths) AS totaldeathcount
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
    AND total_deaths IS NOT NULL
GROUP BY
    location
ORDER BY
    totaldeathcount DESC;

-- deaths by continent

SELECT
    continent,
    MAX(total_deaths) AS totaldeathcount
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY
    continent
ORDER BY
    totaldeathcount DESC;

-- global numbers

SELECT
    data,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS deathpercentage
FROM
    coviddeaths
--where continent is not null
GROUP BY
    data;
--order by 1,2;

-- creating CTE for further calculation

WITH populationvsvaccination (
    continent,
    location,
    data,
    population,
    new_vaccinations,
    sumofvaccinationbydate
) AS (
-- total population vs vaccinations ( Rolling number of vacinattion by location and date)
    SELECT
        dea.continent,
        dea.location,
        dea.data,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER(
            PARTITION BY dea.location
            ORDER BY
                dea.location, dea.data
        ) AS sumofvaccinationbydate
    FROM
        coviddeaths        dea
        JOIN covidvaccination   vac ON dea.location = vac.location
                                     AND dea.data = vac.data
)

-- My CTE
-- Rolling percentage of number of vaccinations by location and date
SELECT
    continent,
    location,
    data,
    population,
    new_vaccinations,
    sumofvaccinationbydate,
    ( sumofvaccinationbydate / population ) * 100 AS percentageofvaccinationbypopulation
FROM
    populationvsvaccination;
--where location like 'Albania';

-- creating table 

CREATE TABLE percentageofvaccinationbypopulation (
    continent                VARCHAR(255),
    location                 VARCHAR(255),
    data                     DATE,
    population               NUMBER,
    new_vaccinations         NUMBER,
    sumofvaccinationbydate   NUMBER
);

-- insert output of calculaton to new table

INSERT INTO percentageofvaccinationbypopulation
    SELECT
        dea.continent,
        dea.location,
        dea.data,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER(
            PARTITION BY dea.location
            ORDER BY
                dea.location, dea.data
        ) AS sumofvaccinationbydate
    FROM
        coviddeaths        dea
        JOIN covidvaccination   vac ON dea.location = vac.location
                                     AND dea.data = vac.data;

SELECT
    *
FROM
    percentageofvaccinationbypopulation

