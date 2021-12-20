select *
from covid_world..coviddeaths$
order by 3,4

select *
from covid_world..covidvacc$
order by 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
from covid_world..coviddeaths$
order by 1,2

-- Looking at Total Cases Vs Total Deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from covid_world..coviddeaths$
order by 1,2
---------------------------------------------------------------------------------------------------

-- Total cases Vs Deaths in India
-- Shows liklihood of dying if a person is infected with Covid.

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from covid_world..coviddeaths$
where location like '%India%'
order by 1,2
-----------------------------------------------------------------------------------------------
-- Looking at Total cases Vs Population(Percentage of population infected with Covid)
SELECT location,date,total_cases,population,(total_cases/population)*100 as DeathPercentage
from covid_world..coviddeaths$
where location like '%India%'
order by 1,2
--------------------------------------------------------------------------------------------
-- Looking at countries with highest Infection rate compared to population.
SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from covid_world..coviddeaths$
--where location like '%India%'
group by location, population
order by PercentPopulationInfected desc
--------------------------------------------------------------------------------------------
--Showing the countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid_world..coviddeaths$
--where location like '%India%'
where continent is not null
group by location
order by TotalDeathCount desc

-----------------------------------------------------------------------------------------
-- On the basis of continents
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid_world..coviddeaths$
--where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid_world..coviddeaths$
--where location like '%India%'
where continent is not null
group by location
order by TotalDeathCount desc
----------------------------------------------------------------------------------
-- Global Numbers
SELECT date,SUM(new_cases)as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from covid_world..coviddeaths$
--where location like '%India%'
where continent is not null
group by date
order by 1,2

-- Overall Death Percentage
SELECT SUM(new_cases)as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from covid_world..coviddeaths$
--where location like '%India%'
where continent is not null
--group by date
order by 1,2

select *
from covid_world..coviddeaths$ dea
join covid_world..covidvacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
-----------------------------------------------------------------------------------------------
-- Looking at Total Population Vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from covid_world..coviddeaths$ dea
join covid_world..covidvacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
---------------------------------------------------------------------------------
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from covid_world..coviddeaths$ dea
join covid_world..covidvacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-------------------------------------------------------------------------------
-- USE CTE
with PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location,dea.date) as RollingPeopleVaccinated
from covid_world..coviddeaths$ dea
join covid_world..covidvacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from PopVsVac
------------------------------------------------------------------------------------------
--Temp Tables
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location,dea.date) as RollingPeopleVaccinated
from covid_world..coviddeaths$ dea
join covid_world..covidvacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location,dea.date) as RollingPeopleVaccinated
from covid_world..coviddeaths$ dea
join covid_world..covidvacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated