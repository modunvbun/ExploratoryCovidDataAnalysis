--partial data cleaning- where continent is null, the location is stored as continent which makes the population-location data inaccurate
select * 
from portfolioproject..covid_deaths$
Where continent is not null
order by 3,4

--selecting data to be used

select Location, date, total_cases, new_cases, total_deaths, population 
from portfolioproject..covid_deaths$
Where continent is not null
order by 1,2

--looking at Total cases vs total_death

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as percentagedeaths, population 
from portfolioproject..covid_deaths$
Where continent is not null
order by 1,2

--likelihood of getting covid in Canada

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as percentagedeaths, population 
from portfolioproject..covid_deaths$
Where location like '%canada%' 
order by 1,2

--total cases vs population

select Location, date, population, total_cases, (total_cases/population) * 100 as percentagepopulationinfected
from portfolioproject..covid_deaths$
Where location like '%canada%' 
order by 1,2


--countries with highest infection rate
select Location, population, max(total_cases) as HighestesInfectionCount, max(total_cases/population) * 100 as percentagepopulationinfected
from portfolioproject..covid_deaths$
Where continent is not null
group by location, population
order by percentagepopulationinfected desc

--countries with highest death count per population
--also casting the total deatth to integer cause now it is a string
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..covid_deaths$
Where continent is not null
group by location

--continents with highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..covid_deaths$
Where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers


select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from portfolioproject..covid_deaths$
where continent is not null
Group by date
order by 1,2

--total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..covid_deaths$ dea
join portfolioproject..covid_vaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

With PopvsVac ( Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..covid_deaths$ dea
join portfolioproject..covid_vaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp table
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..covid_deaths$ dea
join portfolioproject..covid_vaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..covid_deaths$ dea
join portfolioproject..covid_vaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3