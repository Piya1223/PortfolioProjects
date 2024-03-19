Select* 
from PorfolioProject..CovidVaccinations
order by 3,4

Select*
from PorfolioProject..CovidDeaths


--Select the Data we are going to use 

Select location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject..CovidDeaths order by 1,2

Select location,date,total_cases, new_cases, total_deaths, population
From PorfolioProject..CovidDeaths 
Where location like '%ndia' order by 1,2

---find the total Death Percentage according to Population

Select location,date, (total_deaths/population)*100 as DeathPercentage
From PorfolioProject..CovidDeaths 
--Where location like '%ndia' 
order by 1,2

---Looking at the Total Cases vs Total deaths

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as totalDeathPercentage
From PorfolioProject..CovidDeaths 
--Where location like '%ndia' 
order by 1,2

---loking at the countries with Highest Infection rate Compared to population

Select location,Population, MAX(total_cases) as HighestInfectionRate,
MAX((total_cases/population))*100 as PercentagePopulationInfected
From PorfolioProject..CovidDeaths 
--Where location like '%ndia'
Group by location,population
order by PercentagePopulationInfected desc

---Showing countries with total Death count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths 
--Where location like '%ndia'
Where continent is not null
Group by location
order by TotalDeathCount desc


---Showing continents with the highest death count
 
 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths 
--Where location like '%ndia'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as 
total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths 
--Where location like '%ndia' 
Where continent is not null
group by date
order by 1,2


Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
--,(RollingPopulationVaccinated/population)*100
From PorfolioProject..CovidVaccinations vac
join PorfolioProject..CovidDeaths dea
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

With Popvsvac  (continent, location, date, population, new_vaccinations, RollingPopulationVaccinated)
as
(
Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
--,(RollingPopulationVaccinated/population)*100
From PorfolioProject..CovidVaccinations vac
join PorfolioProject..CovidDeaths dea
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 1,2
)
Select *,(RollingPopulationVaccinated/population)*100
From Popvsvac


--TEMP TABLE

--Select * from #PercentPopulationVaccinated
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPopulationVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
--,(RollingPopulationVaccinated/population)*100
From PorfolioProject..CovidVaccinations vac
join PorfolioProject..CovidDeaths dea
On dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 1,2
Select *,(RollingPopulationVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create view PercentagePopulationvaccinated as
Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
--,(RollingPopulationVaccinated/population)*100
From PorfolioProject..CovidVaccinations vac
join PorfolioProject..CovidDeaths dea
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 1,2

Select* from PercentagePopulationvaccinated