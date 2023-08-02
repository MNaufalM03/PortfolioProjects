Select *
From PortfolioProject..CovidDeaths
Where Continent is not null

--Select data that we are going to be using
Select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
From PortfolioProject..CovidDeaths
Where Continent is not null
Order By 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location = 'Indonesia' and Continent is not null
Order By 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location = 'Indonesia' and Continent is not null
Order By 1,2

--Looking at countries with highest infection rate compared to population
Select Location, Population, Max(Total_Cases) as HighestInfectedCount, Max((Total_Cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Continent is not null
Group By Location, Population
Order By PercentPopulationInfected Desc

--Showing countries with highest death count per population
Select Location, Max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group By Location
Order By TotalDeathCount Desc

--Showing continents with the highest death count per population
Select Continent, Max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group By Continent
Order By TotalDeathCount Desc

--Global numbers
Select Sum(New_Cases), Sum(Cast(New_Deaths as int)), Sum(Cast(New_Deaths as int))/Sum(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null

Select *
From PortfolioProject..CovidVaccinations

--Looking at total population vs vaccinations
--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, Sum(Cast(vac.New_Vaccinations as int)) Over (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.Date = vac.Date
Where dea.Continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVactinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, Sum(Cast(vac.New_Vaccinations as int)) Over (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.Date = vac.Date
Where dea.Continent is not null

--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, Sum(Cast(vac.New_Vaccinations as int)) Over (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.Date = vac.Date
Where dea.Continent is not null