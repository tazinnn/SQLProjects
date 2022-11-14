select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Calculating percentage death in the US
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Calculating what percentage of the population was infected
select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulation
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

-- Countries with Highest Infection Rate
select location, population, max(total_cases) as HighestInfection, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count
select location, max(cast(total_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by location 
order by TotalDeath desc 

-- Deaths in each Continent
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Continent

-- Total deaths in each continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global death percentages
select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Sum for the whole world
select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- VACCINATIONS
--select *
--from PortfolioProject..CovidDeaths death
--join PortfolioProject..CovidVaccinations vac
--	on death.location = vac.location
--	and death.date = vac.date

-- Cumulative Sum of Vaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by death.location ORDER BY death.location, death.date)
	as CumulativePeopleVaccinated
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
order by 2,3

-- Using CTE for cumulative vaccinated percentage
With PopVSVac (continent, location, date, population, new_vaccinations, CumulativePeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by death.location ORDER BY death.location, death.date)
	as CumulativePeopleVaccinated
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
)
select *, (CumulativePeopleVaccinated/Population)*100
from PopVSVac

-- Using Temp Table for the same query above

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by death.location ORDER BY death.location, death.date)
	as CumulativePeopleVaccinated
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date

select *, (CumulativePeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- VIEWS
-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as CumulativePeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 

select *
from PercentPopulationVaccinated
