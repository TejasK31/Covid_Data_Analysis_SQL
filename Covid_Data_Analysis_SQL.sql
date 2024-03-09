Select * 
From PortfolioProject_CovidAnalysis..CovidDeaths
Where continent is NOT NULL
order by 3,4 ---Ordering by location and dates

--Select * 
--From PortfolioProject_CovidAnalysis..CovidVaccinations
--order by 3,4 ---Ordering by location and dates

--Selecting the data that we are going to use. 

Select location, date, total_cases, new_cases,total_deaths,population
From PortfolioProject_CovidAnalysis..CovidDeaths
order by 1,2


-- we are going to be looking at total cases vs total deaths


-- Altering total_cases column to be of type INT
ALTER TABLE PortfolioProject_CovidAnalysis..CovidDeaths
ALTER COLUMN total_cases INT;

-- Altering total_deaths column to be of type INT
ALTER TABLE PortfolioProject_CovidAnalysis..CovidDeaths
ALTER COLUMN total_deaths INT;

Select location, date, total_cases,total_deaths, (total_deaths/total_cases) as Mortality_rate
From PortfolioProject_CovidAnalysis..CovidDeaths
order by 1,2	

--Calcuating death percentage
SELECT
  location,
  date,
  total_cases,
  total_deaths,
  population,
  CASE
    WHEN total_cases > 0 THEN (total_deaths * 100.0 / total_cases)
    ELSE NULL -- or another appropriate value when total_cases is zero
  END AS Death_percentage
FROM
  PortfolioProject_CovidAnalysis..CovidDeaths
  Where location  like'India'
ORDER BY
  location,
  date;

--Looking at total deaths vs population i.e mortality rate
SELECT
  location,
  date,
  total_deaths,
  population,
  CASE
    WHEN population > 0 THEN (total_deaths * 100.0 / population)
    ELSE NULL -- or another appropriate value when total_cases is zero
  END AS Mortality_Rate
FROM
  PortfolioProject_CovidAnalysis..CovidDeaths
  Where location  like'India'
ORDER BY
  location,
  date;



 -- COuntry with highest infection rate compared to populations
SELECT
  location,
  population,
  MAX(total_cases) as HighestInfectionCount,
  MAX(
    CASE
      WHEN population > 0 THEN (total_cases * 100.0 / population)
      ELSE NULL
    END
  ) AS Mortality_Rate
FROM
  PortfolioProject_CovidAnalysis..CovidDeaths
WHERE
  location LIKE 'India'
GROUP BY
  location, population
ORDER BY
  location,
  MAX(date);  -- Assuming you want to get the highest infection count's date

  ----
  --Looking at countries with highest infection rate compared to population 
  Select location,population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 as PercentPopulationInfected	 
From PortfolioProject_CovidAnalysis..CovidDeaths
group by location, population
order by PercentPopulationInfected DESC

--Showing the countries with highest death count per population 

  Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount	 
From PortfolioProject_CovidAnalysis..CovidDeaths
Where continent is NOT NULL
group by location
order by TotalDeathCount desc

---Analysis by continent

 SELECT
    location,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM
    PortfolioProject_CovidAnalysis..CovidDeaths
WHERE
    continent IS NULL
    AND location NOT IN ('High income', 'Upper middle income','Lower middle income','European Union','Low income')
GROUP BY
    location
ORDER BY
    TotalDeathCount DESC;
--------------


	 SELECT
    continent,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM
    PortfolioProject_CovidAnalysis..CovidDeaths
WHERE
    continent IS not  NULL
   -- AND location NOT IN ('High income', 'Upper middle income','Lower middle income','European Union','Low income')
GROUP BY
    continent
ORDER BY
    TotalDeathCount DESC;

	-----Global Analysis

		Select  date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
	From PortfolioProject_CovidAnalysis..CovidDeaths
	Where continent is NOT NULL
	group by date
	order by 1,2 

	---Aggregate functions

SELECT
    date,
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths,
    SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM
    PortfolioProject_CovidAnalysis..CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    date, TotalNewCases ASC;


----Looking at total population vs Vaccination
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations AS NewVaccination,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM
    PortfolioProject_CovidAnalysis..CovidDeaths dea
JOIN
    PortfolioProject_CovidAnalysis..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    dea.continent, dea.location, dea.date;

	-------------------

----USE CTE

with PopvsVAC(continent, Location, Date, Population,NewVaccination,RollingPeopleVaccinated	)
as
(
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations AS NewVaccination,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM
    PortfolioProject_CovidAnalysis..CovidDeaths dea
JOIN
    PortfolioProject_CovidAnalysis..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
--ORDER BY
   -- dea.continent, dea.location, dea.date
)
Select *, ( RollingPeopleVaccinated/Population)*100 as Percent_of_Population_Vaccinated
from PopvsVAC



---Using Temp Table
drop table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations AS NewVaccination,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM
    PortfolioProject_CovidAnalysis..CovidDeaths dea
JOIN
    PortfolioProject_CovidAnalysis..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    dea.continent, dea.location, dea.date

	Select *, ( RollingPeopleVaccinated/Population)*100 as Percent_of_Population_Vaccinated
from #PercentPopulationVaccinated


--creating view to store data for later data viz

create view PercentPopulationVaccinated as
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations AS NewVaccination,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM
    PortfolioProject_CovidAnalysis..CovidDeaths dea
JOIN
    PortfolioProject_CovidAnalysis..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
--ORDER BY
  --  dea.continent, dea.location, dea.date	
  

  -----
    Select * 
  from PercentPopulationVaccinated
