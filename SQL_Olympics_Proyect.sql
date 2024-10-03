-- Description

-- The Olympic Games database contains detailed information about sports, athletes (including data such as gender, age, height, and weight), and participating countries.
-- It also includes records of host cities, medals won (gold, silver, bronze), other awards, and the history of the Olympic events.
-- This structure allows for comprehensive analysis of athletic performance, the evolution of the games, and trends over the various Olympic editions.


-- Objectives of the proyect 

-- Analyze Athletic Performance: Evaluate athletes' performance trends based on age, gender, height, and weight across different sports.

-- Medal Distribution Insights: Assess the distribution of medals among countries and sports to identify patterns and competitiveness.

-- Historical Trends: Examine the evolution of the Olympic Games through historical data on sports and medal achievements4

-- Country Participation Analysis: Analyze participation rates of countries in the Olympics to understand global involvement in sports over time.


-- Cleaning Data 

-- ALTER TABLE olympics_history
-- ALTER COLUMN age TYPE numeric USING NULLIF(age, 'NA')::numeric;

-- Which is the Average age by sport?
  
  SELECT sport, ROUND(AVG(age), 0) AS avg_age_by_sport
FROM olympics_history
GROUP BY sport;
  
-- This shows that the average age per sport is between 20 and 30 years old 

-- Who are the TOP 5 Rank athletes that won golden medals?

WITH rnk_athletes_1 AS(
 SELECT DISTINCT(name) as athletes, sport, COUNT(*) as total_medals 
 FROM olympics_history
 WHERE medal = 'Gold'
 GROUP BY athletes , sport
 ORDER BY total_medals DESC
),
 rnk_athletes_2 AS (
 SELECT *, DENSE_RANK() OVER(ORDER BY total_medals DESC) as rnk
 FROM rnk_athletes_1
 )
  SELECT *
  FROM rnk_athletes_2
  WHERE rnk <= 5;
 
-- This analysis highlights that Michael Fred Phelps II stands out as the most accomplished athlete of those years
-- Achieving an extraordinary number of gold medals in swimming."
 
 
 -- Show the Total of countries that participate in each olympics game
 
  WITH all_countries AS(
 SELECT games, ohr.region
 FROM olympics_history oh
 JOIN olympics_history_noc_regions ohr
 ON oh.noc = ohr.noc
 GROUP BY games, ohr.region
	 )
	 SELECT games, COUNT(*) as total_countries
	 FROM all_countries
	 GROUP BY games 
	 ORDER BY games, total_countries DESC;

-- We conclude that the best year among the 1990s for the olympics was in 1992 , during the summer season in which about 167 countries played



-- Show all the countries that played in each olympic games	

WITH tot_games AS(
  SELECT COUNT(DISTINCT(games)) as total_olympics_games 
  FROM olympics_history
	  ),
	  countries AS
  (SELECT oh.games, ohr.region as country 
  FROM olympics_history oh
  JOIN olympics_history_noc_regions ohr
  ON oh.noc = ohr.noc
  GROUP BY oh.games, ohr.region),
  
  countries_participate AS
  (SELECT country, COUNT(1) as total_participate_games
  FROM countries
  GROUP BY country)
  SELECT cp.*
  FROM countries_participate cp
  JOIN tot_games tg 
  ON cp.total_participate_games = tg.total_olympics_games
  ORDER BY 1;
	
-- This analysis reveals that France, Italy, Switzerland, and the UK have consistently participated in every Olympic Games.
-- Showcasing their longstanding commitment to the event."
  

 -- Category athletes by its weight - Filter the top 10 most heavy athletes

   SELECT DISTINCT(name) as athlete, weight,
   CASE WHEN weight < 65 THEN 'very light'
        WHEN weight BETWEEN 70 AND 79 THEN 'Medium weight'
        WHEN weight BETWEEN 80 AND 89 THEN 'Big weight'
        WHEN weight >= 90 THEN 'Tremedus weight' ELSE 
        'light weight' END AS weight_category, sport
        FROM olympics_history
        WHERE weight IS NOT NULL
	   ORDER BY weight DESC
       LIMIT(10);

-- Ricardo Blas, Jr. is recognized as one of the heaviest athletes in Olympic history within the judo discipline.

-- The data indicates that sports such as judo, wrestling, and weightlifting tend to feature the heaviest competitors.
 
  
-- CREATE EXTENSION tablefunc;
-- List down total gold, silver and bronze medals won by each country 
   
 SELECT country,
 COALESCE(Gold, 0) as Gold,
 COALESCE(Bronze, 0) as Bronze,
 COALESCE(Silver, 0) as Silver
 FROM crosstab('SELECT ohr.region, oh.medal , COUNT(1) total_medals
  FROM olympics_history oh
  JOIN olympics_history_noc_regions ohr
  ON oh.noc = ohr.noc 
  WHERE medal <> ''NA''
  GROUP BY ohr.region, oh.medal
  ORDER BY ohr.region, oh.medal',
  'Values (''Bronze''), (''Gold''), (''Silver'')')
  as result(country varchar, Bronze bigint, Gold bigint, Silver bigint)
  ORDER BY gold DESC, Bronze DESC, Silver DESC;
  
 -- IMPORTANT INSIGHTS 
 -- The data indicates that USA is one of the countries with the most awards in both gold, bronze and silver medals.
 -- In addition we can also see that the country with the fewest medals in each category is Montenegro. 
