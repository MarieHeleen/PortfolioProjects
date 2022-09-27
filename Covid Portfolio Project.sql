SELECT *
FROM dbo.CovidDeaths

SELECT *
FROM dbo.CovidVaccinations

-- Selecting data we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dyinf if you contract covid in US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
Where location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
Where location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with the highest Death Count per Population
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVAccinated
--, (RollingPeopleVAccinated/population)*100
FROM dbo.CovidDeaths AS dea
JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

WITH PopvsVac (continent, location, date, population, PeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, TRY_CAST(people_vaccinated as int) AS PeopleVaccinated
FROM dbo.CovidDeaths AS dea
JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (PeopleVaccinated/population)*100 AS PercentagePeopleVaccinated
FROM PopvsVAC


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, TRY_CAST(people_vaccinated as int) AS PeopleVaccinated
FROM dbo.CovidDeaths AS dea
JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (PeopleVaccinated/population)*100 AS PercentagePeopleVaccinated
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizatsions

Create view PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, TRY_CAST(people_vaccinated as int) AS PeopleVaccinated
FROM dbo.CovidDeaths AS dea
JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated