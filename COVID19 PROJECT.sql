-- FIRSTLY, LET ME CHECK TO SEE IF THE DATA WAS IMPORTED PROPERLY BY LOOKING AT SPECIFIC COLUMNS 

SELECT *
FROM PortfolioProject1..CovidVaccinations
ORDER BY 3,4

SELECT *
FROM PortfolioProject1..CovidDeaths
ORDER BY 3,4

-- NOW LET ME SELECT THE DATA THAT I'LL BE USING 

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject1..CovidDeaths
order by 1,2

--I want to compare the total_cases nto the total_deaths. Let me take a percentage of people who actually get infected and die 
-- I'm using the CAST statement to convert the datatypes of total_deaths and total_cases from nvarchar to float

SELECT Location, date, total_cases, total_deaths,
       ((CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100) AS PercentageofDeaths
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

--Let's check out what's going on in Nigeria 
-- The query below shows the likelihood of dying if you contract the Disease in your country (i.e Nigeria)

SELECT Location, date, total_cases, total_deaths,
       ((CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100) AS PercentageofDeaths
FROM PortfolioProject1..CovidDeaths
WHERE Location = 'Nigeria'
ORDER BY 1,2 

-- NOW, I want to compare the total cases to the population. Let me take a percentage of the population that caught the disease in Nigeria

SELECT Location, date, population, total_cases, 
      ((CAST(total_cases AS float) / CAST(population AS float)) * 100) AS PercentageofCases
FROM PortfolioProject1..CovidDeaths
WHERE Location = 'Nigeria'
ORDER BY 1,2 


-- I'm curious as to what countries have the highest infection rates. Let's check it out 
-- I'll discover what countries have the highest infection rates in comparison to Population 
-- This long query is in use because I want to want to find the maximum total_cases for each Location and calculate he percentage
-- of population infected. To achieve this, I used a subquery to find the maximum total_cases per Location, then join it back with 
-- the main table to calculate the percentage of population infected.


SELECT cd.Location, cd.population, cd.total_cases, 
       max_cases.HighestInfectionCount,
       ((CAST(cd.total_cases AS float) / CAST(cd.population AS float)) * 100) AS PercentofPopulationInfected
FROM PortfolioProject1..CovidDeaths cd
INNER JOIN (
  SELECT Location, MAX(total_cases) AS HighestInfectionCount
  FROM PortfolioProject1..CovidDeaths
  GROUP BY Location
) max_cases ON cd.Location = max_cases.Location
ORDER BY PercentofPopulationInfected DESC

-- The query above returns a country multiple times. I want each country to have it's total presented once. 
-- Below is the appropriate query to determine the percent of the population with the highest infections

SELECT subquery.Location, subquery.TotalPopulation, subquery.total_cases, 
       subquery.HighestInfectionCount,
       ((CAST(subquery.HighestInfectionCount AS float) / subquery.TotalPopulation) * 100) AS PercentofPopulationInfected
FROM (
  SELECT cd.Location, SUM(cd.population) AS TotalPopulation, cd.total_cases, 
         MAX(cd.total_cases) AS HighestInfectionCount
  FROM PortfolioProject1..CovidDeaths cd
  GROUP BY cd.Location, cd.total_cases
) subquery
ORDER BY PercentofPopulationInfected DESC

-- Now, I want to look at how many people, actually dies from COVID. Let me show the countries with te highest death count per population

SELECT Location, MAX(total_deaths) AS TotalDeathCount 
  FROM PortfolioProject1..CovidDeaths 
  group by Location 
  Order By TotalDeathCount DESC

-- The result of this query is incorrect because total_deaths is in nvarchar datatype and I need to cast(convert) it to 
-- an int datatype

SELECT
  Location,
  CAST(MAX(total_deaths) AS int) AS TotalDeathCount
FROM
  PortfolioProject1..CovidDeaths
GROUP BY
  Location
ORDER BY
  TotalDeathCount DESC

-- Now another issue I have here is that our data has continents in it, instead of just countries. Entire continents 
-- are being grouped. Let's RUN a query to return just countries

SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

-- THIS QUERY HAS RETURNED ONLY COUNTRIES, BECAUSE IT'S ONLY COUNTRIES IN THIS TABLE THAT HAVE THEIR CONTINENT COLUMN
-- AS NOT NULL. SO LET'S INTEGRATE INTO OUR PREVIOUS QUERY

SELECT
  Location,
  CAST(MAX(total_deaths) AS int) AS TotalDeathCount
FROM
  PortfolioProject1..CovidDeaths
  WHERE continent IS NOT NULL
GROUP BY
  Location
ORDER BY
  TotalDeathCount DESC

-- NOW LET'S CLASSIFY BY CONTINENT 

SELECT continent,
  CAST(MAX(total_deaths) AS int) AS TotalDeathCount
FROM
  PortfolioProject1..CovidDeaths
  WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- BUT THIS VALUES LOOK INCORRECT. SO TO GET OUR DEMOGRAPHICS BASED OFF CONTINENT WE USE ANOTHER APPROACH, TAKING INTO 
-- CONSIDERATION THE NULL VALUES WE HAVE FROM OUR LOCATION TABLE INSTEAD OF CONTINENT TABLE. 

SELECT
  Location,
  CAST(MAX(total_deaths) AS int) AS TotalDeathCount
FROM
  PortfolioProject1..CovidDeaths
  WHERE continent IS NULL
GROUP BY
  Location
ORDER BY
  TotalDeathCount DESC

-- This data still has some discrepancies in the sense that our Location contains some wrong entries 
-- Now, I want to show the continents with the highest death count per population. 

SELECT
  Location,
  CAST(MAX(total_deaths) AS int) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- A drill-down breaks down a large set into smaller sets. In this case, a drill-down would indicate the countries in 
-- each continent and then the states in each country. 
-- Recall taht we have to account for the data in nvarchar and those in float.
--  Now Let's look at Global numbers:


SELECT date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths,
       SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) * 100 AS GlobalDeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, SUM(new_cases) 

-- This gives us the total death percentage all over the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--- NOW LET'S LOOK AT COVID VACCINATIONS 

SELECT *
FROM PortfolioProject1..CovidVaccinations

-- NOW LET'S JOIN COVIDDeaths and COVIDVaccinations together 

SELECT *
FROM PortfolioProject1..CovidVaccinations deat
JOIN PortfolioProject1..CovidVaccinations vacc
ON deat.location = vacc.location
AND deat.date = vacc.date 

-- Looking at Total Population VS Vaccinations 

SELECT deat.continent, deat.location, deat.date, deat.population_density, vacc.new_vaccinations
FROM PortfolioProject1..CovidVaccinations deat
JOIN PortfolioProject1..CovidVaccinations vacc
ON deat.location = vacc.location
AND deat.date = vacc.date 
where deat.continent is NOT NULL
ORDER BY 1,2,3


-- FROM THE QUERY ABOVE, I can't seem to use Population, so I'm using Population_desnity instead
-- ALSO, FROM thsi query we can tell that Vaccination started in Africa on January 30th in Algeria (392nd row)
-- NOW, We want to use the total_vacciantions but Instead of using that column, we'd perform a rolling count on the 
-- new_vaccinations so they add up until they give the total vaccinatiions, COOL RIGHT !!


SELECT deat.continent, deat.location, deat.date, deat.population_density, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS float)) OVER (PARTITION BY deat.location) 
FROM PortfolioProject1..CovidVaccinations deat
JOIN PortfolioProject1..CovidVaccinations vacc
ON deat.location = vacc.location
AND deat.date = vacc.date 
where deat.continent is NOT NULL
ORDER BY 1,2,3
 
-- INSTEAD OF THE CAST STATEMENT WE COULD ALTERNATIVELY USE THE CONVERT STATEMENT AS THUS:

SELECT deat.continent, deat.location, deat.date, deat.population_density, vacc.new_vaccinations,
SUM(CONVERT(float,vacc.new_vaccinations)) OVER (PARTITION BY deat.location) 
FROM PortfolioProject1..CovidVaccinations deat
JOIN PortfolioProject1..CovidVaccinations vacc
ON deat.location = vacc.location
AND deat.date = vacc.date 
where deat.continent is NOT NULL
ORDER BY 1,2,3

-- NOW, WE NEED TO SEPARATE SOME DATA USING THE CODE BELOW:

SELECT deat.continent, deat.location, deat.date, deat.population_density, vacc.new_vaccinations,
SUM(CONVERT(float,vacc.new_vaccinations)) 
OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidVaccinations deat
JOIN PortfolioProject1..CovidVaccinations vacc
ON deat.location = vacc.location	
AND deat.date = vacc.date 
where deat.continent is NOT NULL
ORDER BY 1,2,3


-- I keep getting an error saying that 
Msg 8729, Level 16, State 1, Line 226
ORDER BY list of RANGE window frame has total size of 1020 bytes. Largest size supported is 900 bytes

-- To fix it, I used this code:

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- Let's Use a CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
    FROM PortfolioProject1..CovidDeaths dea
    JOIN PortfolioProject1..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    -- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac

-- I use the bignit datatype instead of float because the float cannot the handle the volume of data 

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


--When trying to look at the "PercentPopulationVaccinated" View as a TABLE, I GET THE ERROR 

--Msg 8729, Level 16, State 1, Line 1
--ORDER BY list of RANGE window frame has total size of 1020 bytes. Largest size supported is 900 bytes.

--TO FIX THIS I USED THIS QUERY, I made the following changes 
--the ORDER BY clause within the OVER clause only includes the dea.Date column. The dea.location column has been removed 
--from the ORDER BY clause since it was not explicitly necessary for sorting within the window frame.
--Please note that this modification assumes that sorting by dea.location within the window frame is not required for 
--your analysis. If dea.location is indeed necessary for the sorting logic, you may need to consider other alternatives,
--such as reducing the length of the dea.location column or changing the data representation as mentioned earlier.

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
FROM
    PortfolioProject1..CovidDeaths dea
JOIN
    PortfolioProject1..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated 