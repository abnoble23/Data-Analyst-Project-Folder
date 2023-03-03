--CREATE TABLE EmployeeDemographics
(EmployeeID int,
FirstName varchar(50),
LastName varchar(50),
Age int,
Gender varchar(50)
)

--CREATE TABLE EmployeeSalary
--(EmployeeID int,
--JobTitle varchar(50),
--Salary int
--)

Select *
From PortfolioProject..CovidDeaths$
where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject..covidvacinnationsTBL
--Order by 3, 4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeathsTBL
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying from Covid in your conuntry

Select Location, date,  total_deaths,total_cases,(total_deaths/total_cases)*100 as DeathPercentage --total_deaths(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Toral Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, total_cases, population,(total_cases/population)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population

Select Location,  population, MAX(total_cases) as HigestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing the Countries with the highest Death count per pop.

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by location 
order by TotalDeathCount desc

-- Let's Break Things down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- showing the continents with the highest deathcount per pop

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global #s

Select  date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1, 2


Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
, 
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location	= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location	= vac.location
	and dea.date = vac.date
where dea.continent is not null
/*order by 2,3*/
 )
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac


 -- Temp Table

--DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location	= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

 Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated


 -- Creating View to store data for later Visuals
 Use PortfolioProject
 GO
 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location	= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
From dbo.PercentPopulationVaccinated