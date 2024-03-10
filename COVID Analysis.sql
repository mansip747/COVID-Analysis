
--select data to be used
select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project ]..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows liklihood of dying if you contract COVID 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project ]..CovidDeaths
where location like '%India%'
order by 1,2

--total cases vs population and percentage of population got COVID
select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project ]..CovidDeaths
where location like '%India%'
order by 1,2

--countries with high infection rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project ]..CovidDeaths
Group By location, population 
order by PercentPopulationInfected desc;

--countries with high death rate per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project ]..CovidDeaths
where continent is not null
Group By location 
order by TotalDeathCount desc;

--breaking it down continent wise 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project ]..CovidDeaths
where continent is null
Group By location
order by TotalDeathCount desc;

--continents with highest death count per population
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from [Portfolio Project ]..CovidDeaths
where continent is not null
order by 1,2

--total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Portfolio Project ]..CovidDeaths dea
join [Portfolio Project ]..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using cte

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project ]..CovidDeaths dea
join [Portfolio Project ]..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac



--temp table

drop 
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project ]..CovidDeaths dea
join [Portfolio Project ]..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for visualization later 

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project ]..CovidDeaths dea
join [Portfolio Project ]..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null

