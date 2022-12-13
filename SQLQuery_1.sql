

SELECT *
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, [date]

--Select *
--From Portfolio.dbo.CovidVaccinations
--Where continent is not null 
--order by location, [date]

--Select Data that we are going to be using

SELECT location, date, total_cases, total_tests, new_cases, total_deaths, new_deaths, population
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, [date]

--Looking at Total Cases vs Total Deaths and calculating the percentages of deaths
--Shows rough estimates of likelihood of dying if you contract the COVID virus at your country.
SELECT location, date, total_cases, total_deaths, ((total_deaths * 1.0)/ (total_cases * 1.0))* 100 AS DeathPercentage
FROM Portfolio.dbo.CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, [date]

--Total Cases vs Population
--Shows what percentage of population had Covid.
SELECT location, date, total_cases, population, ((total_cases * 1.0)/ (population * 1.0))* 100 AS casesperpopulation
FROM Portfolio.dbo.CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, [date]

--Looking at Countries with Highest infection rate comparing to population.

SELECT location, MAX(total_cases) AS highest_infectionCount, population, ((MAX(total_cases * 1.0))/ (population * 1.0))* 100 AS InfectionRatePerPopulation
FROM Portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRatePerPopulation DESC

--Showing Countries with Highest Death Count per population.
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM Portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--By Continent

--Looking at Total Cases vs Total Deaths and calculating the percentages of deaths per continent.
--Shows rough estimates of likelihood of dying if you contract the COVID virus at your continent.
SELECT  SUM(new_cases) AS totalcases, SUM(new_deaths) AS totaldeaths, (SUM(new_deaths * 1.0)/SUM(new_cases * 1.0)) * 100 AS DeathPercentage --total_deaths, ((total_deaths * 1.0)/ (total_cases * 1.0))* 100 AS DeathPercentage
FROM Portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%' AND 
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY [date]


SELECT date, SUM(new_cases) AS totalcases, SUM(new_deaths) AS totaldeaths, (SUM(new_deaths * 1.0)/SUM(new_cases * 1.0)) * 100 AS DeathPercentage --total_deaths, ((total_deaths * 1.0)/ (total_cases * 1.0))* 100 AS DeathPercentage
FROM Portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%' AND 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY [date]


--Total Cases vs Population by continent
--Shows what percentage of population had Covid.
SELECT continent, date, total_cases, population, ((total_cases * 1.0)/ (population * 1.0))* 100 AS casesperpopulation
FROM Portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
ORDER BY continent, [date]


--Showing Continents with highest death counts.
SELECT [continent], MAX(total_deaths) AS TotalDeathCount
FROM Portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY [continent]
ORDER BY TotalDeathCount DESC 

--Looking at Continents with Highest infection rate comparing to population.

SELECT continent, MAX(total_cases) AS highest_infectionCount, population, ((MAX(total_cases * 1.0))/ (population * 1.0))* 100 AS InfectionRatePerPopulation
FROM Portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY InfectionRatePerPopulation DESC

--Total population vs vaccinations
SELECT de.continent, de.[location], de.date, de.population, va.new_vaccinations,
SUM(va.new_vaccinations) OVER (Partition by de.location ORDER BY de.location, de.date) AS RollingpeopleVaccinated --partition by location because everytime the query gets to the new location, the count starts over.

FROM Portfolio.dbo.CovidDeaths as de 
Join Portfolio.dbo.CovidVaccinations as va 
ON de.location = va.location AND
de.date = va. date
WHERE de.continent is NOT NULL
ORDER BY 2,3

--Using CTE to create rollingvaccinatedpeople column.

WITH popvsVac (continent, Location, Date, Population, new_vaccinations, RollingpeopleVaccinated) --This will create a common table expression for population vs vaccinated so that we can pull Rollingpeople Vaccinated as a column
AS
(
SELECT de.continent, de.[location], de.date, de.population, va.new_vaccinations,
SUM(va.new_vaccinations) OVER (Partition by de.location ORDER BY de.location, de.date) AS RollingpeopleVaccinated --partition by location because everytime the query gets to the new location, the count starts over.
FROM Portfolio.dbo.CovidDeaths as de 
Join Portfolio.dbo.CovidVaccinations as va 
ON de.location = va.location AND
de.date = va. date
WHERE de.continent is NOT NULL
--ORDER BY 2,3
)

SELECT *, ((RollingpeopleVaccinated*1.0)/Population)*100
FROM popvsVac
WHERE location = 'Albania'

--Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

Insert INTO #PercentPopulationVaccinated
SELECT de.continent, de.[location], de.date, de.population, va.new_vaccinations,
SUM(va.new_vaccinations) OVER (Partition by de.location ORDER BY de.location, de.date) AS RollingpeopleVaccinated --partition by location because everytime the query gets to the new location, the count starts over.

FROM Portfolio.dbo.CovidDeaths as de 
Join Portfolio.dbo.CovidVaccinations as va 
ON de.location = va.location AND
de.date = va. date
WHERE de.continent is NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATE A VIEW to store data later for Tableau analysis.
--Ex.

CREATE VIEW PercentPopulationVaccinated AS
SELECT de.continent, de.[location], de.date, de.population, va.new_vaccinations,
SUM(va.new_vaccinations) OVER (Partition by de.location ORDER BY de.location, de.date) AS RollingpeopleVaccinated --partition by location because everytime the query gets to the new location, the count starts over.
FROM Portfolio.dbo.CovidDeaths as de 
Join Portfolio.dbo.CovidVaccinations as va 
ON de.location = va.location AND
de.date = va. date
WHERE de.continent is NOT NULL
--ORDER BY 2,3
