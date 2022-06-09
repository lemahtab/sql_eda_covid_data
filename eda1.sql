Select *
From PortfolioProject..coviddeaths
Where continent is not null
order by 3,4

Select *
From PortfolioProject..covidvaccinations
order by 3,4

-- Looking at Total deaths v total cases
-- Likelihood of dying if you contract covid-19
Select location, date, total_deaths, total_cases, ((total_deaths*100)/total_cases) as DeathPerc
From PortfolioProject..coviddeaths
order by 1,2

--Looking at total cases v population
Select location, date, population, total_cases, (total_cases/population)*100 as CasePerc
From PortfolioProject..coviddeaths
order by 1,2

-- Looking at countries with highest infection rate
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as MaxInfRate
From PortfolioProject..coviddeaths
group by location, population
order by MaxInfRate desc

-- Showing countries with highest death count per population
Select location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population)*100) as MaxDeathRate
From PortfolioProject..coviddeaths
Where continent is not null
group by location, population
order by MaxDeathRate desc

-- Showing continents with highest death count per population
Select continent, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population)*100) as MaxDeathRate
From PortfolioProject..coviddeaths
Where continent is not null
group by continent
order by MaxDeathRate desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as DailyGlobalCases, SUM(new_deaths) as DailyGlobalDeaths, SUM(CAST(new_deaths as decimal))/SUM(CAST(new_cases as decimal))*100 as DeathPerc
From PortfolioProject..coviddeaths
Where new_cases != 0
group by date


Select SUM(CAST(new_cases as bigint)) as DailyGlobalCases, SUM(CAST(new_deaths as bigint)) as DailyGlobalDeaths, SUM(CAST(new_deaths as decimal))/SUM(CAST(new_cases as decimal))*100 as DeathPerc
From PortfolioProject..coviddeaths
Where new_cases != 0


-- Pop vs Vac

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Tot_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Tot_Vaccinated
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (Tot_Vaccinated/Population)*100
From PopvsVac


-- Using temp table to perform calculation on Partition By in previous query

DROP Table if exists #PercPopVaccinated
Create Table #PercPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccinations bigint,
Tot_Vaccinated bigint
)
Insert Into #PercPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Tot_Vaccinated
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (Tot_Vaccinated/Population)*100
From #PercPopVaccinated


-- Creating View to store data for later visualizations

Create View PercPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Tot_Vaccinated
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (Tot_Vaccinated/Population)*100 as PercPopVac
From PercPopVaccinated