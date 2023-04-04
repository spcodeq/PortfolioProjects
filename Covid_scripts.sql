--SET ARITHABORT OFF
--SET ANSI_WARNINGS OFF
--SET ARITHIGNORE OFF

--Update PortfolioProject..CovidDeaths
--Set new_cases = NullIf(new_cases, 0)

--Update PortfolioProject..CovidVaccinations
--Set new_vaccinations_smoothed_per_million = NullIf(new_vaccinations_smoothed_per_million, 0)

Select location, continent, total_deaths, (SUM(total_deaths) / 365) AS 'Deaths_Per_Day'
From PortfolioProject..CovidDeaths
Group By location, continent, total_deaths


Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercent
From PortfolioProject..CovidDeaths
Order By 1, 2

-- Looking at Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercent
From PortfolioProject..CovidDeaths
Where location like '%states'
Order By 1, 2 desc

-- Looking at Total Cases vs Population
-- Show what percentage of population with covid
Select location, date, population,total_cases, (Convert(float, total_cases) / Convert(float, population)) * 100 AS 'PerPopWithVid'
From PortfolioProject..CovidDeaths
--Where location like '%states'
Order By 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/cast(population as float))) * 100 AS 'InfectedPopulation'
From PortfolioProject..CovidDeaths
--Where location like '%states'
Group By location, population
Order By InfectedPopulation desc


-- Show Countries with Highest Death Total Per Population
Select continent, MAX(total_deaths) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Group By continent
Order By TotalDeathCount desc


-- Global numbers
Select SUM(cast(new_cases as float)) total_cases, SUM(cast(new_deaths as float)) total_deaths, (SUM(cast(new_deaths as float)) / SUM(cast(new_cases as float))) * 100 as DeathPER
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
--Group by date
Order By 1, 2


-- Total population vs Vaccinations
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinated.new_vaccinations, 
Sum(Convert(int, vaccinated.new_vaccinations)) Over(Partition By deaths.location Order by deaths.location, deaths.date) as RollingPplVaccinated
--, (RollingPplVaccinated/population)*100
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vaccinated
	On deaths.location = vaccinated.location
	And deaths.date = vaccinated.date
Where deaths.continent Is Not Null And vaccinated.new_vaccinations Is Not Null
Order By 2, 3


--Use CTE
With PopVsVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingPplVaccinated) As
( 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinated.new_vaccinations, 
Sum(Convert(int, vaccinated.new_vaccinations)) Over(Partition By deaths.location Order by deaths.location, deaths.date) as RollingPplVaccinated
--, (RollingPplVaccinated/population)*100
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vaccinated
	On deaths.location = vaccinated.location
	And deaths.date = vaccinated.date
Where deaths.continent Is Not Null And vaccinated.new_vaccinations Is Not Null
--Order By 2, 3 
) Select *, Convert(float, RollingPplVaccinated) / Convert(float, Population) * 100 As TotalVaccinated
From PopVsVaccinated


-- Temp Table
Drop Table if Exists #PercPopVacc
Create Table #PercPopVacc
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPplVaccinated numeric
)

Insert into #PercPopVacc
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinated.new_vaccinations, 
Sum(Convert(int, vaccinated.new_vaccinations)) Over(Partition By deaths.location Order by deaths.location, deaths.date) as RollingPplVaccinated
--, (RollingPplVaccinated/population)*100
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vaccinated
	On deaths.location = vaccinated.location
	And deaths.date = vaccinated.date
Where deaths.continent Is Not Null And vaccinated.new_vaccinations Is Not Null
--Order By 2, 3 

Select *, Convert(float, RollingPplVaccinated) / Convert(float, Population) * 100 As TotalVaccinated
From #PercPopVacc


-- Creating View for Visualization 
--Create View DeathsPerDay As
--Select location, continent, total_deaths, (SUM(total_deaths) / 365) AS 'Deaths_Per_Day'
--From PortfolioProject..CovidDeaths
--Group By location, continent, total_deaths
