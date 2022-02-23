
Select *
From PortfolioProject..covid_deaths
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..covid_vaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_deaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying of you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
Where location like '%states%'
Order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date,population, total_cases, (total_cases/population)*100 as ContactedCovidPercentage
From PortfolioProject..covid_deaths
Where location like 'cyprus'
Order by 1,2


-- Looking at countries with countries with Highest Infection Rate compared to Population

Select location, population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
--Where location like 'cyprus'
Group by location, population
Order by PercentPopulationInfected desc

-- Showing the Countries with the Highest Death Count per population

Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
--, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
--Where location like 'cyprus'
Where continent is not null
Group by location
Order by TotalDeathCount desc



-- Showing continents with the highest continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
Where continent is not null
Group by date
Order by 1,2


-- Total cases and deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
Where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





--TEMP TABLE

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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3