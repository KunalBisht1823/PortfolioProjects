select *
from portfolioproject.dbo.CovidVaccinations$
order by 3,4

select *
from CovidDeaths$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

-- Shows likelihood of dying if you contact covid in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
from CovidDeaths$
--where location like '%India%'
order by 1,2

-- show what percentage of population got covid 

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected  
from CovidDeaths$
where location like 'India'
order by 1,2

--Looking at countries with highest Infectin Rate compared to populatio 
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected  
from CovidDeaths$
--where location like 'India'
group by location, population
order by HighestInfectionCount desc

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected  
from CovidDeaths$
--where location like 'India'
group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population 
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like 'India'
where continent is not null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100  AS DeathPercentage 
from CovidDeaths$
--where location like '%India%'
where continent is not null 
--group by date 
order by 1,2


--looking at the total population vs vaccination 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccinations$ vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (Continent, location, date, New_Vaccinations, population, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccinations$ vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (Rollingpeoplevaccinated/population)*100
from PopvsVac

-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccinations$ vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*, (Rollingpeoplevaccinated/ Population)*100
from #PercentPopulationVaccinated

-- creating view to store data for later visualizations 
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccinations$ vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
