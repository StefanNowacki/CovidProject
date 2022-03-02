select location, data, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
from coviddeaths
where location like 'Poland'
order by 1,2;


-- looking at total cases vs population
-- shows percentage of population got covid
select location, data, total_cases,population , total_deaths, (total_cases/population)*100 as PopulationGotCovid
from coviddeaths
where location like 'Poland'
order by 1,2;


-- highest infection count by country
select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/ population))* 100 as PercentPopulationInfected
from coviddeaths
group by location, population
order by 4 desc;


-- highest deaths by country
select location, max(total_deaths)as TotalDeathCount
from coviddeaths
where continent is not null and total_deaths is not null
group by location
order by TotalDeathCount desc;


-- deaths by continent
select continent, max(total_deaths)as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- global numbers
select data, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(new_deaths)/ sum(new_cases) * 100 as DeathPercentage
from coviddeaths
--where continent is not null
group by data;
--order by 1,2;

-- creating CTE for further calculation
with PopulationVsVaccination (Continent, Location, Data, population, new_vaccinations, 
SumOfVaccinationByDate)
as
(
-- total population vs vaccinations ( Rolling number of vacinattion by location and date)
select dea.continent, dea.location, dea.data, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.data)
as SumOfVaccinationByDate
from covidDeaths dea
join covidvaccination vac
    on dea.location = vac.location
    and dea.data = vac.data
)


-- My CTE
-- Rolling percentage of number of vaccinations by location and date
select Continent, Location, Data, Population, New_vaccinations, SumOfVaccinationByDate,
(SumOfVaccinationByDate/population)*100 as PercentageOfVaccinationByPopulation
from PopulationVsVaccination;
--where location like 'Albania';


-- creating table 
create table PercentageOfVaccinationByPopulation
(
Continent varchar(255),
Location varchar(255),
Data date,
population number,
new_vaccinations number,
SumOfVaccinationByDate number
);


-- insert output of calculaton to new table
insert INTO PercentageOfVaccinationByPopulation
select dea.continent, dea.location, dea.data, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.data)
as SumOfVaccinationByDate
from covidDeaths dea
join covidvaccination vac
    on dea.location = vac.location
    and dea.data = vac.data;


select * from PercentageOfVaccinationByPopulation
