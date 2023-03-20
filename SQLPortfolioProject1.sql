select *
from [dbo].[CovidDeaths]
order by 3,4

select *
from [dbo].[CovidVaccinations]
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths]
order by 1,2

-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [dbo].[CovidDeaths]
where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from [dbo].[CovidDeaths]
where total_cases is not null and population is not null
group by location, population
order by PercentPopulationInfected desc

--Looking at Countries with Highest Death Count per Population

select location, max(total_deaths) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
group by location
order by TotalDeathCount desc

--Looking at Continents with Highest Death Count per Population

select continent, max(total_deaths) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers

select date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
where location = 'world'
group by date, location, total_cases, total_deaths

--Looking at Vaccinations vs Population Globally

select dea.location, max(vac.people_fully_vaccinated) as TotalPeopleVaccinated, max(dea.population) as TotalPopulation, (max(vac.people_fully_vaccinated)/max(dea.population))*100 as VaccinatedPercentage
from [dbo].[CovidVaccinations] vac
join [dbo].[CovidDeaths] dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.location = 'world'
group by dea.location

--Looking at Vaccinations vs Population by Country 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[CovidVaccinations] vac
join [dbo].[CovidDeaths] dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

--Looking at Vaccinations vs Population by Country (using CTE)

with VacvsPop (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[CovidVaccinations] vac
join [dbo].[CovidDeaths] dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not NULL
)
select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinatedPercentage
from VacvsPop

--Looking at Vaccinations vs Population by Country (using Temp Table)

drop table if exists #VacvsPop
create table #VacvsPop (
Continent varchar(255),
Location varchar (255),
Date date,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #VacvsPop
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[CovidVaccinations] vac
join [dbo].[CovidDeaths] dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not NULL

select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinatedPercentage
from #VacvsPop
order by 2,3

--Creating View to store data for later visualizations

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[CovidVaccinations] vac
join [dbo].[CovidDeaths] dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not NULL