Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

 -- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

 -- Looking at Total Cases vs Total Deaths
 -- Shows likelihood of dying from covid

Select Location, date, total_cases, total_deaths, (Convert(float,total_deaths)/
Nullif(Convert(float, total_cases), 0))*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like '%canada%'
Where continent is not null
order by 1,2

 -- Looking at Total Cases vs Population
 -- Shows percentage of infection rate

Select Location, date, population, total_cases, (Convert(float,total_cases)/
Nullif(Convert(float, population), 0))*100 as infection_rate 
From PortfolioProject..CovidDeaths
Where location like '%canada%'
Where continent is not null
order by 1,2

 -- Looking at Countries with higest infection rate Vs. population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((Convert(float,total_cases)/
Nullif(Convert(float, population), 0)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

 -- Showing Countries with highest death count per Population 

Select Location, Max(Convert(float, total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

 -- Break things down by continent (correct numbers)

Select location, Max(Convert(float, total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null AND location Not LIKE '%income%'
Group by location
order by TotalDeathCount desc

 -- Showing Continents with highest death count per Population 

Select continent, Max(Convert(float, total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null AND location Not LIKE '%income%'
Group by continent
order by TotalDeathCount desc

 -- Global Numbers 

Select date, Sum(new_cases) as total_cases, Sum(Convert(float,new_deaths)) as total_deaths, Sum(Convert(float,new_deaths))/nullif(Sum(new_cases),0) as 
	DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent is not null
Group by date
order by 1,2

 -- Looking at Total Population Vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(float,new_vaccinations)) OVER(Partition By dea.location Order by dea.location, dea.date)
  as RunningVaccinationCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

 --USE CTE

With PopVsVac (Continent, Location, Date, Population,new_vaccinations, RunningVaccinationCount)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(float,new_vaccinations)) OVER(Partition By dea.location Order by dea.location, dea.date, dea.continent)
  as RunningVaccinationCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RunningVaccinationCount/Population)*100 as RunningVaccinationPercentage
From PopVsVac

 -- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RunningVaccinationCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(float,new_vaccinations)) OVER(Partition By dea.location Order by dea.location, dea.date, dea.continent)
  as RunningVaccinationCount
From PortfolioProject..CovidDeaths dea
--Where dea.continent is not null
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--order by 2,3

Select *, (RunningVaccinationCount/Population)*100 as RunningVaccinationPercentage
From #PercentPopulationVaccinated


 -- Creating View to store data for later visulizations(tableau)

Create View PercentPopulationVacinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(float,new_vaccinations)) OVER(Partition By dea.location Order by dea.location, dea.date, dea.continent)
  as RunningVaccinationCount
From PortfolioProject..CovidDeaths dea
--Where dea.continent is not null
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVacinated