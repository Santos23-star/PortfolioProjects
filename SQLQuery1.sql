SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data that we're going to be using

Select Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract Covid in the U.S
Select Location,date,total_cases,total_deaths,(Total_deaths/Total_cases)* 100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states'
AND continent is not null
ORDER BY 1,2

-- Looking at Total Cases Vs Population
-- Shows the percentage of population  got Covid
Select Location,date,population,total_cases,(Total_cases/population)* 100 As PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states'
ORDER BY 1,2

-- Looking at countries with the Highest Infection Rate compared to population

Select Location,population,MAX(total_cases) AS HighestInfectionCount, MAX((Total_cases/population))* 100 As PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states'
GROUP BY location,population
ORDER BY PercentPopulationInfected Desc

-- Showing Countries with the Highest Death Count per population
Select Location,population,MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states'
WHERE continent is null
GROUP BY location, population
ORDER BY TotalDeathCount Desc


-- Breaking things down by Continent


-- Showing Continents with the Highest Death Count per population
Select location,MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states'
WHERE continent is null
Group by location
ORDER BY TotalDeathCount Desc

-- GLOBAL NUMBERS 
Select SUM(new_cases) As Total_Cases, SUM(Cast(new_deaths as INT)) As Total_deaths, SUM(cast(New_deaths as INT))/ SUM(New_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states'
WHERE continent is not null
--GROUP by Date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations 

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER By dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent,Location,Date,population, New_vaccionations ,RollingPeopleVaccinated)
AS
( 
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER By dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac



-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(Partition by dea.location ORDER By dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(Partition by dea.location ORDER By dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3