-- Delete table
DROP TABLE WorldPopulation;

-- Create new table for World Population
CREATE TABLE WorldPopulation
(
  [populationRank] int NOT NULL PRIMARY KEY,
  [country] nvarchar(50) NOT NULL FOREIGN KEY REFERENCES GDP ([country]),
  [region] nvarchar(500),
  [populationNr] float NOT NULL,
  [percentageWorldPopulation] float CHECK ([percentageWorldPopulation]>=1),
  [date] nvarchar(50)
);

-- Delete table
DROP TABLE PopulationData;

-- Create new table for Health index
CREATE TABLE PopulationData
(
  [country] nvarchar(50) NOT NULL PRIMARY KEY,
  [alcoholConsumption] float,
  [incomePerPerson] float,
  [suicidePer100th] float,
  [employrate] float,
  [urbanRate] float
);

-- Delete table
DROP TABLE GDP;

-- New table for World Happiness Report
CREATE TABLE GDP
(
  [gdpRank] int NOT NULL PRIMARY KEY,
  [country] nvarchar(50) NOT NULL,
  [happinessScore] float NOT NULL,
  [gdpPerCapita] float NOT NULL,
  [socialSupport] float NOT NULL,
  [lifeExpectancy] float,
  [freedom] float,
  [generosity] float,
  [corruption] float
);

-- Insert data from World Population into WorldPopulation
BULK INSERT WorldPopulation
FROM 'C:\Users\joele\source\repos\WorldPopulation\WorldPopulation\World Population.csv'
WITH
(
  CODEPAGE = '65001',
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  TABLOCK
);

-- Insert data from Health index into PopulationData table
BULK INSERT PopulationData
FROM 'C:\Users\joele\source\repos\WorldPopulation\WorldPopulation\data.csv'
WITH
(
  CODEPAGE = '65001',
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  TABLOCK
);

-- Insert data from World Happiness Report into GDP table
BULK INSERT GDP
FROM 'C:\Users\joele\source\repos\WorldPopulation\WorldPopulation\2019.csv'
WITH
(
  CODEPAGE = '65001',
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  TABLOCK
);

-- Does have money a correlation with happiness?
-- Average income per person (devided by 1000 to show a in thousands)and average GDP score of all continents 
SELECT region, AVG(PopulationData.incomePerPerson) / 1000 AS avgIncomePerPersonInTh, AVG(GDP.happinessScore)
AS avgHappinessScore
FROM WorldPopulation
INNER JOIN PopulationData ON PopulationData.country=WorldPopulation.country
INNER JOIN GDP ON GDP.country=PopulationData.country
GROUP BY region
ORDER BY AVG(GDP.happinessScore) DESC;

-- Do the counties with the highest suicide rating in Americas have a GDP below 1?
-- Suicide rate compared to happieness score and the percentage of total world population ordered by population amount
SELECT GDP.country, PopulationData.suicidePer100th / 10 AS suicidePer10th, GDP.gdpPerCapita, WorldPopulation.percentageWorldPopulation 
FROM GDP
INNER JOIN PopulationData ON PopulationData.country=GDP.country
INNER JOIN WorldPopulation ON WorldPopulation.country=PopulationData.country
WHERE region IN ('Americas')
ORDER BY PopulationData.suicidePer100th DESC

-- What country in Asia have the worst social support and what is that countries employrate?
-- Social support compared to employrate (divided by 10 to show from a scale from 1 to 10) ordered by social support 
SELECT WorldPopulation.country, GDP.socialSupport, PopulationData.employrate / 100 AS employrate1to10
FROM WorldPopulation
INNER JOIN GDP ON GDP.country=WorldPopulation.country
INNER JOIN PopulationData ON PopulationData.country=GDP.country
WHERE region IN ('Asia')
ORDER BY GDP.socialSupport;