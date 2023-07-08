SELECT *
from Project1..CovidDeaths
where continent is not NULL
order by 3,4

/*SELECT *
from Project1..CovidVaccinations
order by 3,4*/

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Project1..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- Shows liklihod of dying if you contact covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Project1..CovidDeaths
where location like '%india%'
order by 1,2

-- Alter datatype
/*ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases FLOAT;*/

-- looking at total cases vs population
-- Shows what % of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from Project1..CovidDeaths
where location like '%china%'
order by 1,2

-- Looking at countries with hightest infection rate compared to population
select location, population, Max(total_cases) as HightestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
from Project1..CovidDeaths
group by location, population
order by PercentagePopulationInfected desc

-- Showing countries with hightest death count with Population
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from Project1..CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount desc


--Let's break down by continent
-- Showing the Continent’s  with Highest  Deaths count per population
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from Project1..CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount desc

-- Global Numbers
select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as float))as Totaldeaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
from Project1..CovidDeaths
--where location like '%india%'
where continent is not null and new_cases !=0
--group by date
order by 1,2


--looking at total population vs Vaccinations 

select dea.continent, dea.[location],dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
ON dea.[location] = vac.[location]
and dea.[date]=vac.[date]
where dea.continent is not null
order by 2,3


-- use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccination,RollingPeopleVaccinated)
as (
select dea.continent, dea.[location],dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
ON dea.[location] = vac.[location]
and dea.[date]=vac.[date]
where dea.continent is not null
--order by 2,3)
)

SELECT *, (cast(RollingPeopleVaccinated as float)/Population)*100
from PopvsVac


--temp table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    Continent varchar(255),
    location varchar(255),
    Date datetime,
    Population numeric,
    New_Vaccination numeric,
    RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.[location],dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
ON dea.[location] = vac.[location]
and dea.[date]=vac.[date]
where dea.continent is not null
--order by 2,3)


SELECT *, (cast(RollingPeopleVaccinated as float)/Population)*100
from #PercentPopulationVaccinated ;


--creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
select dea.continent, dea.[location],dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
ON dea.[location] = vac.[location]
and dea.[date]=vac.[date]
where dea.continent is not null
--order by 2,3)

select * from PercentPopulationVaccinated





