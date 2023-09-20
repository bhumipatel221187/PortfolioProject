select *
From PortfolioProject.dbo.CovidDeath
where continent is not null
order by 3,4

select *
From PortfolioProject.dbo.CovidVaccination
order by 3,4

--Select Data that we are going to be using
select location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeath
order by 1,2

-- Looking at Total Cases Vs Total Dealths
--Shows likelihood of dying if contract covid in your country
select location, date, total_cases, total_deaths,
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0)) * 100 AS Deathpercentage
From PortfolioProject.dbo.CovidDeath
where Location like '%states%'
order by 1,2

-- Looking at Total Cases VS Population
--Shows what percentage of pololation got Covid
select location, date, population, total_cases,
(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)) * 100 AS Deathpercentage
From PortfolioProject.dbo.CovidDeath
--where Location like '%India%'
order by 1,2

--Looking at countries with highest infection rate VS Population
select location, population, MAX(total_cases) AS HighestInfectioncount,
Max((CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))) * 100 AS PercentPopulationInfect
From PortfolioProject.dbo.CovidDeath
--where Location like '%India%'
Group by location, population
order by PercentPopulationInfect desc

--Showing Countries with highest Death count per percentage
Select location, MAX(convert(int,total_deaths)) AS TotalDeathCount
From PortfolioProject.dbo.CovidDeath
--where Location like '%India%'
where continent is not null
Group by location
order by TotalDeathCount desc

--Let's Break things down by continent

--Showing continent with the highest death count

Select continent, MAX(convert(int,total_deaths)) AS TotalDeathCount
From PortfolioProject.dbo.CovidDeath
--where Location like '%India%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers
select sum(new_cases) as total_cases, sum(convert(int, new_deaths)) as total_deaths, sum(convert(int,new_deaths))/NULLIF(sum(new_cases),0)*100 as DeathPercentage
--(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0)) * 100 AS Deathpercentage
From PortfolioProject.dbo.CovidDeath
--where Location like '%states%'
where continent is not null
--group by date
order by 1,2


--Looking at total populaton VS Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(CONVERT(float, vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeath dea
Join PortfolioProject.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeath dea
Join PortfolioProject.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeath dea
Join PortfolioProject.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeath dea
Join PortfolioProject.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


