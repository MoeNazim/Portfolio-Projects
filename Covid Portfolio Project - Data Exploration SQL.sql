
/*

Covid 19 Data Exploration:


Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
from PortfolioProject2022..CovidDeaths
Order by 3,4

Select *
from PortfolioProject2022..CovidVaccinations
Order by 3,4


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject2022..CovidDeaths
Order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject2022..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject2022..CovidDeaths
--Where location like '%states%'
Order by 1,2




-- Countries with Highest Infection Rate compared to Population


Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject2022..CovidDeaths
group by location, population
order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population


Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject2022..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject2022..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject2022..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject2022..CovidDeaths Dea
Join PortfolioProject2022..CovidVaccinations Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date
Where Dea.continent is not null
Order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.Location Order by Dea.location, Dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject2022..CovidDeaths dea
Join PortfolioProject2022..CovidVaccinations vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
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
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject2022..CovidDeaths Dea
Join PortfolioProject2022..CovidVaccinations Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date
--Where Dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations



Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject2022..CovidDeaths dea
Join PortfolioProject2022..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 