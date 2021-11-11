SELECT *
FROM PortfolioProject_Covid19..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4

--SELECT *
--FROM PortfolioProject_Covid19..CovidVaccinations
--order by 3,4

--Select Data we are going to use
SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_Covid19..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2

--Looking at Total Cases vs Total Deaths
--Likelihood to death if you're infected of covid in Spain
SELECT Location, Date, total_cases, total_deaths, CAST((total_deaths/total_cases)*100 as decimal(10,2)) AS 'Death%'
FROM PortfolioProject_Covid19..CovidDeaths
WHERE Location = 'Spain' AND continent IS NOT NULL
order by 1,2


--Looking at Total Cases vs Population
--Shows percentage of Spain's population that got covid
SELECT Location, Date, population, total_cases, CAST((total_cases/population)*100 as decimal(10,2)) AS 'Infection%'
FROM PortfolioProject_Covid19..CovidDeaths
WHERE Location = 'Spain' AND continent IS NOT NULL
order by 1,2


--Looking at countries with higher infection ratescompared to Population
SELECT Location, population, MAX(total_cases) AS Highest_Infection, MAX(CAST((total_cases/population)*100 as decimal(10,2))) AS 'Infection%'
FROM PortfolioProject_Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
order by 'Infection%' desc


--Looking countries with Highest Death Count over Population
SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeaths
FROM PortfolioProject_Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
order by TotalDeaths desc


--Looking continents with Highest Death Count over Population
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeaths
FROM PortfolioProject_Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
order by TotalDeaths desc


--Global Data
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 AS 'Death%'
FROM PortfolioProject_Covid19..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY Date
order by 1,2


--Looking Total Population vs Vaccinations
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CAST(b.new_vaccinations as bigint)) OVER (Partition by a.location ORDER BY a.location, a.date) AS Rolling_PeopleVaccinated
FROM PortfolioProject_Covid19..CovidDeaths a 
JOIN PortfolioProject_Covid19..CovidVaccinations b
	ON a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL
order by 2,3


--USE CTE
With PopulationvsVaccination(Continent, Location, Date, Population, New_Vaccinations, Rolling_PeopleVaccinated)
AS
(
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CAST(b.new_vaccinations as bigint)) OVER (Partition by a.location ORDER BY a.location, a.date) AS Rolling_PeopleVaccinated
FROM PortfolioProject_Covid19..CovidDeaths a 
JOIN PortfolioProject_Covid19..CovidVaccinations b
	ON a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL)
SELECT *, (Rolling_PeopleVaccinated/Population)*100
FROM PopulationvsVaccination



--TEMPORARY TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vacc numeric,
Rolling_PeopleVaccinated numeric)


INSERT INTO #PercentPopulationVaccinated
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CAST(b.new_vaccinations as bigint)) OVER (Partition by a.location ORDER BY a.location, a.date) AS Rolling_PeopleVaccinated
FROM PortfolioProject_Covid19..CovidDeaths a 
JOIN PortfolioProject_Covid19..CovidVaccinations b
	ON a.location = b.location
	AND a.date = b.date

SELECT *, (Rolling_PeopleVaccinated/Population)*100 AS '%Rolling_PeopleVaccinated'
FROM #PercentPopulationVaccinated


--View for Tableau/Power BI visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CAST(b.new_vaccinations as bigint)) OVER (Partition by a.location ORDER BY a.location, a.date) AS Rolling_PeopleVaccinated
FROM PortfolioProject_Covid19..CovidDeaths a 
JOIN PortfolioProject_Covid19..CovidVaccinations b
	ON a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated