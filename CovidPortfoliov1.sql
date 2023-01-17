SELECT *
FROM PortfolioProject..CovidDeaths$
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2


--Looking at Total cases vs Population
--Shows the percentage of the population with covid
SELECT Location, date, total_cases, population,  (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2


--Looking at countries with Highest Infection Rate compared to Population

SELECT Location, population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Coutries with the Highest Death Count per Population

SELECT Location, Max(cast (Total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Let's Break Things Down by Continent

--showing contintents with the highest death count per population

SELECT continent, Max(cast (Total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
WHERE continent is not null
--GROUP BY date
Order BY 1,2

--Looking at Total Population vs Vaccinations

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated, --(RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated