Select *
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Mexico'
ORDER BY 3, 4

--Select *
--FROM PortfolioProject..CovidVaccinations
--Order by 3, 4

--Select data that we will be using for project

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying from covid in the US

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths,
	(total_deaths/total_cases)*100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Population
-- Shows what percentage of population contracted covid

SELECT 
	location, 
	date, 
	total_cases, 
	population,
	(total_cases/population)*100 AS casePercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2


--Countries with Highest Infection Rates compared to Population

SELECT 
	location, 
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY
	location,
	population
ORDER BY 4 DESC


--Countries with Highest Death Count per Population

SELECT 
	location, 
	MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY
	location
ORDER BY 2 DESC


--LET'S BREAK THINGS DOWN BY CONTINENT+

SELECT 
	location, 
	MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is NULL AND location NOT LIKE '%income%'
GROUP BY
	location
ORDER BY 2 DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest deathcounts

SELECT 
	continent, 
	MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY
	continent
ORDER BY 2 DESC


--GLOBAL NUMBERS

SELECT 
	--date, 
	SUM(new_cases) AS TotalCases,
	SUM(CAST(new_deaths AS int)) AS TotalDeaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1



--Looking at Total Population vs Vaccinations

Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinated,
--	(RollingTotalVaccinated/population)*100 AS VaccinatedPercentage
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


---USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--	(RollingTotalVaccinated/population)*100 AS VaccinatedPercentage
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
FROM PopvsVac
ORDER BY 2,3


--Create Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
	Select 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null


SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
FROM #PercentPopulationVaccinated
ORDER BY 2,3


--Creating View to store data for visualizations

CREATE VIEW PercentPopulationVaccinated AS
	Select 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated