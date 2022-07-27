
-- DATA CLEANING, continent and location with same entries not required (can be added to query if needed)
SELECT *
  FROM [Portfolio_Project].[dbo].[CovidDeaths$]
  WHERE continent is not null
  --ORDER BY location
 

-- DATA CLEANING, checking for any false entries
SELECT DISTINCT location 
  FROM [Portfolio_Project].[dbo].[CovidDeaths$]

 
--Comparing Total deaths Vs Total cases
--Likelihood of you dying if COVID positive in current Location
SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as death_percentage
  FROM [Portfolio_Project].[dbo].[CovidDeaths$]
  WHERE location LIKE '%CANADA%'
  order by 1,2


--Comparing Total deaths Vs Total cases
--Likelihood of you dying if COVID positive, around the world 
SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as death_percentage
  FROM [Portfolio_Project].[dbo].[CovidDeaths$]
  order by 1,2

--Comparing Total Cases Vs Total Population
--Shows percentage of population that got covid in Canada
SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 as pop_percentage_infected
  FROM [Portfolio_Project].[dbo].[CovidDeaths$]
  WHERE location LIKE '%CANADA%'
  order by 1,2

--Comparing country with highest infections and % of pop infected
SELECT location, population, MAX(total_cases) as Highest_inf_count, MAX((total_cases/population))*100 as pop_percentage_infected
  FROM [Portfolio_Project].[dbo].[CovidDeaths$]
  GROUP BY location, population
  order by 4 desc


--Showing countries with highest death per population
--NVARCHAR data type leading to error, hence converting to int
SELECT location, population, MAX(CAST (total_deaths AS int)) as total_death_count --MAX(total_deaths/population) as death
  FROM [Portfolio_Project].[dbo].[CovidDeaths$]
  WHERE continent IS NOT NULL
  GROUP BY location, population
  order by 3 desc

--Total deaths by continent
  SELECT continent, MAX(CAST (total_deaths AS int)) as total_death_count --MAX(total_deaths/population) as death
  FROM [Portfolio_Project].[dbo].[CovidDeaths$]
  WHERE continent IS NOT NULL
  GROUP BY continent
  ORDER BY total_death_count DESC
  --order by 2 desc

--Day by day increase in global cases and deaths
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
  FROM [Portfolio_Project].[dbo].[CovidDeaths$]
  WHERE continent IS NOT NULL
  GROUP BY date
  ORDER BY 1

  --Total deaths and cases worldwide
  SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
  FROM [Portfolio_Project].[dbo].[CovidDeaths$]
  WHERE continent IS NOT NULL
  

  --Comparing new daily vaccinations
  SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
  SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_vacc
  FROM Portfolio_Project.dbo.CovidDeaths$ death
  JOIN Portfolio_Project.dbo.CovidVaccinations$ vacc
  ON death.location = vacc.location
  AND death.date = vacc.date
  WHERE death.continent is not null
  ORDER by 2,3

  --Using WITH clause

  WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVacc)
  AS
  (
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
  SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_vacc
  FROM Portfolio_Project.dbo.CovidDeaths$ death
  JOIN Portfolio_Project.dbo.CovidVaccinations$ vacc
  ON death.location = vacc.location
  AND death.date = vacc.date
  WHERE death.continent is not null
  --ORDER by 2,3
  )
  SELECT *, (RollingPeopleVacc/Population)*100
  FROM PopVsVac

