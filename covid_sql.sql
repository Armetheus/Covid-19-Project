SELECT *
FROM portfolioproject..covid_deaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM portfolioproject..covid_vaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject..covid_deaths
ORDER BY 1,2

--Looking at total_cases vs total_deaths
--Shows the likelihood of dying if you contract covid in the united kingdom

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM portfolioproject..covid_deaths
WHERE location like '%kingdom%'
ORDER BY 1,2

--Looking at total_cases vs population
--Shows what percentage of the population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as percent_population_infected
FROM portfolioproject..covid_deaths
WHERE location like '%kingdom%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM portfolioproject..covid_deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY percent_population_infected desc


--Showing the countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as bigint)) as total_deaths_count
FROM portfolioproject..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY total_deaths_count desc

--Showing the continents with the highest death count

SELECT continent, MAX(cast(total_deaths as bigint)) as total_deaths_count
FROM portfolioproject..covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_deaths_count desc

--Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as death_percentage
FROM portfolioproject..covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--SUM of global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as death_percentage
FROM portfolioproject..covid_deaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--To Join the two tables, death and vaccination by location and date
SELECT *
FROM portfolioproject..covid_deaths dea
JOIN portfolioproject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea. date = vac.date

--Looking at total population vs vaccinations
 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS rolling_people_vaccinated
-- , (rolling_people_vaccinated/population)*100
FROM portfolioproject..covid_deaths dea
JOIN portfolioproject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea. date = vac.date
	WHERE dea.continent is not null
ORDER BY 2,3

--Use cte

WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS rolling_people_vaccinated
-- , (rolling_people_vaccinated/population)*100
FROM portfolioproject..covid_deaths dea
JOIN portfolioproject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea. date = vac.date
	WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM popvsvac

--Temp table

Drop table if exists #percent_population_vaccinated
Create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS rolling_people_vaccinated
-- , (rolling_people_vaccinated/population)*100
FROM portfolioproject..covid_deaths dea
JOIN portfolioproject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea. date = vac.date
	--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #percent_population_vaccinated

--Creatng view to store data for late visualizations




Create view percentage_population_vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
DROP VIEW if exists #percentage_population_vaccinated
FROM portfolioproject..covid_deaths dea
JOIN portfolioproject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



SELECT table_name 
FROM INFORMATION_SCHEMA.views