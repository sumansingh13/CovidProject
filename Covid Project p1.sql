select *
from PortfolioProject..['covid deaths$']
where continent is not null
order by 3,4

--select *
--from PortfolioProject..['covid vaccatination$']
--order by 3,4


--select Data that we are going to be using


select location, date, total_cases, new_cases,total_deaths,population
from PortfolioProject..['covid deaths$']
order by 1,2


--Looking at total cases vs total deaths
--Shows likelihood fo dying if you contract covid in your country
select location, date, total_cases, total_deaths,
case 
when total_cases = 0 Then NULL
Else (CAST(total_deaths AS float) / total_cases) * 100
END AS DeathPercentage
from PortfolioProject..['covid deaths$']
where location like '%india%'
order by 1,2


--Looking at total cases vs population
--shows what percentage of population got covid

select location, date, total_cases, population,
case 
when total_cases = 0 Then NULL
Else (CAST(total_cases AS float) / population) * 100
END AS InfectedpopulationPercentage
from PortfolioProject..['covid deaths$']
where location like '%india%'
order by 1,2


--Looking at countries with highest infection rate compared to population
SELECT
  location,
  MAX(total_cases) as Highest_infectioncount,
  population,
  CASE 
    WHEN MAX(total_cases) = 0 THEN NULL
    ELSE (CAST(MAX(total_cases) AS float) / population) * 100
  END AS InfectedpopulationPercentage
FROM PortfolioProject..['covid deaths$']
GROUP BY location, population
ORDER BY InfectedpopulationPercentage desc


--Showing countries with highest deathcount per population
select location, sum(new_deaths) as TotalDeathCount
from PortfolioProject..['covid deaths$']
where continent!=''--(!='')means not null--
group by location
order by TotalDeathCount desc

--Showing Total deathcount per population of continents--
select continent, sum(new_deaths) as TotalDeathCount
from PortfolioProject..['covid deaths$']
where continent is not null
group by continent
order by TotalDeathCount desc



--Global Numbers by date--

SELECT date,
       SUM(new_cases) AS total_cases,
       SUM(CAST(new_deaths AS INT)) AS total_deaths,
       (SUM(CAST(new_deaths AS INT)) * 100.0) / NULLIF(SUM(new_cases), 0) AS DeathPercentage
FROM PortfolioProject..['covid deaths$']
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total Global Numbers--
SELECT
       SUM(new_cases) AS total_cases,
       SUM(CAST(new_deaths AS INT)) AS total_deaths,
       (SUM(CAST(new_deaths AS INT)) * 100.0) / NULLIF(SUM(new_cases), 0) AS DeathPercentage
FROM PortfolioProject..['covid deaths$']
WHERE continent IS NOT NULL
ORDER BY 1,2



--Joining two tables and looking at total population vs total vaccination--
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM PortfolioProject..['covid deaths$'] dea
JOIN PortfolioProject..['covid vaccatination$'] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


--using TEMP TABLE adding total_vaccinations_percentage--
drop table if exists #vaccination_Percentage
Create table #vaccination_Percentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_vaccination numeric
)

insert into #vaccination_Percentage
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_vaccination
FROM PortfolioProject..['covid deaths$'] dea
JOIN PortfolioProject..['covid vaccatination$'] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

select*, (Total_vaccination/population)*100 as VaccinationPercentage
from #vaccination_Percentage




---Creating view to store data for later visualization---

create view vaccination_Percentage as
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_vaccination
FROM PortfolioProject..['covid deaths$'] dea
JOIN PortfolioProject..['covid vaccatination$'] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


select*
from vaccination_Percentage