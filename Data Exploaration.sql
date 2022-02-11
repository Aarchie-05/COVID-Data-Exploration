SELECT *
FROM CovidDeaths
ORDER BY 3,4

-- SELECT *
-- FROM CovidVaccinations
-- ORDER BY 3,4

-- Select data we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Your country

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS REAL) / total_cases)*100 AS PercentagPopulationInfected
FROM CovidDeaths
WHERE location LIKE '%india%' 
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Case vs Population 
-- Shows what percentage of Population got covid 

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS REAL) / population))*100 AS PercentagPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagPopulationInfected DESC

-- Showing countries with Highest Death count per Population 

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC 

-- LET'S BREAK THINGS DOWN BY CONTINENT 
-- Showing continents with highest death count per population 

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, CAST(SUM(CAST(new_deaths AS INT)) AS REAL)/SUM(new_cases)*100 AS DeathPercentage 
FROM CovidDeaths
WHERE continent IS NOT NULL

-- Looking at Total Population vs Vaccinations 

SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , 
SUM(CAST(new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- USE CTC

WITH PopvsVac (continent , location , date , population , new_vaccinations , RollingPeopleVaccinated)
AS
(
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , 
SUM(CAST(new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)
SELECT * , ((CAST(RollingPeopleVaccinated AS REAL))/population)*100
FROM PopvsVac

-- TEMP TABLE 

DROP TABLE IF EXISTS PercentagePopulationVaccinated
CREATE TABLE PercentagePopulationVaccinated
(
continent TEXT,
location TEXT,
date datetime,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated numeric 
)
INSERT INTO PercentagePopulationVaccinated
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , 
SUM(CAST(new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

SELECT * , ((CAST(RollingPeopleVaccinated AS REAL))/population)*100
FROM PercentagePopulationVaccinated

-- CREATING VIEW
CREATE VIEW PercentagePopulationVaccinatedView AS
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , 
SUM(CAST(new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

SELECT * 
FROM PercentagePopulationVaccinatedView


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((CAST(total_cases AS REAL)/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc