/* Earthquake Analysis
1. create the necessary extension and table, read in the data into table */

Create extension postgis;
create extension hstore;

CREATE TABLE earthquake1 (time TIMESTAMP,latitude DOUBLE PRECISION,longitude DOUBLE PRECISION,
						 depth DOUBLE PRECISION, mag DOUBLE PRECISION,magType VARCHAR(10),
						 nst INTEGER,gap DOUBLE PRECISION,dmin DOUBLE PRECISION,rms DOUBLE PRECISION,
						 net Varchar(10),id VARCHAR(255) PRIMARY KEY,updated TIMESTAMP,place VARCHAR(255),
						 type VARCHAR(50),horizontal DOUBLE PRECISION,depthError DOUBLE PRECISION,
						 magError DOUBLE PRECISION,magNst INTEGER,status varchar(50),
						 locationSource VARCHAR(50),magSource VARCHAR(50));

-- used the select statement to view table

select * from earthquake1

-- get count of total rows in table

SELECT COUNT(*) AS total_rows
FROM earthquake1;

-- get count of total columns in table

SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'earthquake1';

SELECT COUNT(mag) AS non_null_magnitudes
FROM earthquake1;

-- Top Region using Groupby and orderby showing limit 10

SELECT place, COUNT(id) AS earthquake_count
FROM earthquake1
GROUP BY place
ORDER BY earthquake_count DESC
LIMIT 10;

--Analyzing Earthquake Magnitude Distribution

--Determine the distribution of earthquake magnitudes to understand the frequency of different magnitudes.

SELECT mag, COUNT(id) AS frequency
FROM earthquake1
GROUP BY mag
ORDER BY mag
LIMIT 15;

--Finding Average Depth of Earthquakes by Region

--Calculate the average depth of earthquakes for each region to understand the typical depth at which earthquakes occur.

SELECT place, AVG(depth) AS average_depth
FROM earthquake1
GROUP BY place
ORDER BY average_depth DESC;

--Correlation between Magnitude and Depth:

--Analyze the correlation between the magnitude of earthquakes and their depth.

SELECT mag, depth
FROM earthquake1
WHERE mag IS NOT NULL AND depth IS NOT NULL;


--Monthly Earthquake Trend

--Examine the trend of earthquakes over time on a monthly basis to identify any patterns or seasonal trends.

SELECT DATE_TRUNC('month', time) AS month, 
COUNT(id) AS earthquake_count
FROM earthquake1
GROUP BY month
ORDER BY month;


--Magnitude vs. Geographical Distribution

--Analyze the distribution of earthquake magnitudes across different latitude and longitude ranges.

SELECT latitude, longitude, mag
FROM earthquake1
WHERE mag IS NOT NULL
limit 15;

--Determining High-Risk Earthquake Types

--Identify the types of earthquakes that occur most frequently and their average magnitude.

SELECT type, COUNT(id) AS frequency, AVG(mag) AS average_magnitude
FROM earthquake1
GROUP BY type
ORDER BY frequency DESC;

--Classifying Earthquake Magnitudes:

--Classify earthquakes into categories such as minor, light, moderate, strong, major, and great, and count the number of earthquakes in each category.

SELECT 
    CASE 
        WHEN mag < 3 THEN 'Minor'
        WHEN mag >= 3 AND mag < 4 THEN 'Light'
        WHEN mag >= 4 AND mag < 5 THEN 'Moderate'
        WHEN mag >= 5 AND mag < 6 THEN 'Strong'
        WHEN mag >= 6 AND mag < 7 THEN 'Major'
        ELSE 'Great'
    END AS magnitude_category,
    COUNT(id) AS earthquake_count
FROM earthquake1
GROUP BY magnitude_category
ORDER BY earthquake_count DESC;

--Average Magnitude and Depth by Earthquake Type:

--calculate the average magnitude and average depth for each type of earthquake.

SELECT 
    type,
    AVG(mag) AS average_magnitude,
    AVG(depth) AS average_depth
FROM earthquake1
GROUP BY type
ORDER BY average_magnitude DESC;


--Frequency of Earthquakes by Year:

--Determine the number of earthquakes that occurred each year.


SELECT 
    EXTRACT(YEAR FROM time) AS year,
    COUNT(id) AS earthquake_count
FROM earthquake1
GROUP BY year
ORDER BY year;

--High-Risk Areas Based on Magnitude Thresholds:

--Identify regions that frequently experience earthquakes with a magnitude greater than 5.0

SELECT 
    place,
    COUNT(id) AS earthquake_count
FROM earthquake1
WHERE mag > 5.0
GROUP BY place
HAVING COUNT(id) > 10
ORDER BY earthquake_count DESC;

--Monthly Earthquake Count with Magnitude Classification:

--Count the number of earthquakes each month, classified by magnitude categories.

SELECT 
    DATE_TRUNC('month', time) AS month,
    COUNT(CASE WHEN mag < 3 THEN 1 END) AS minor_earthquakes,
    COUNT(CASE WHEN mag >= 3 AND mag < 4 THEN 1 END) AS light_earthquakes,
    COUNT(CASE WHEN mag >= 4 AND mag < 5 THEN 1 END) AS moderate_earthquakes,
    COUNT(CASE WHEN mag >= 5 AND mag < 6 THEN 1 END) AS strong_earthquakes,
    COUNT(CASE WHEN mag >= 6 AND mag < 7 THEN 1 END) AS major_earthquakes,
    COUNT(CASE WHEN mag >= 7 THEN 1 END) AS great_earthquakes
FROM earthquake1
GROUP BY month
ORDER BY month;


--Comparison of Earthquake Characteristics Between Different Regions:

--Compare the average magnitude, average depth, and total number of earthquakes for different regions.


SELECT 
    place,
    AVG(mag) AS average_magnitude,
    AVG(depth) AS average_depth,
    COUNT(id) AS total_earthquakes
FROM earthquake1
GROUP BY place
HAVING COUNT(id) > 50  
ORDER BY total_earthquakes DESC;


--Severity of Earthquakes Over Time

--Analyze how the severity (measured by magnitude) of earthquakes has changed over the years.

SELECT 
    EXTRACT(YEAR FROM time) AS year,
    AVG(mag) AS average_magnitude,
    MAX(mag) AS max_magnitude,
    MIN(mag) AS min_magnitude
FROM earthquake1
GROUP BY year
ORDER BY year;


SELECT COUNT(*) AS total_rows
FROM earthquake1;


SELECT COUNT(mag) AS non_null_magnitudes
FROM earthquake1;

SELECT place, COUNT(*) AS earthquake_count
FROM earthquake1
GROUP BY place
ORDER BY earthquake_count DESC;


--Regions Most Affected by Earthquakes

--The top regions affected by earthquakes were identified by counting the number of occurrences in each place

SELECT place, COUNT(id) AS earthquake_count
FROM earthquake1
GROUP BY place
ORDER BY earthquake_count DESC
LIMIT 10;


--Query to Rank Earthquakes by Magnitude, Depth, and Gap



SELECT 
    id,
    place,
    mag,
    depth,
    gap,
    RANK() OVER (ORDER BY mag DESC) AS rank_by_mag,
    RANK() OVER (ORDER BY depth DESC) AS rank_by_depth,
    RANK() OVER (ORDER BY gap DESC) AS rank_by_gap
FROM 
    earthquake1;


SELECT id,place, mag,depth,gap,
    RANK() OVER (ORDER BY mag DESC) AS rank_by_mag,
    RANK() OVER (ORDER BY depth DESC) AS rank_by_depth,
    RANK() OVER (ORDER BY gap DESC) AS rank_by_gap
FROM earthquake1;


-- rank earthquakes by magnitude, depth, and gap within each place (geographical region)

SELECT 
    id,
    place,
    mag,
    depth,
    gap,
    RANK() OVER (PARTITION BY place ORDER BY mag DESC) AS rank_by_mag_within_place,
    RANK() OVER (PARTITION BY place ORDER BY depth DESC) AS rank_by_depth_within_place,
    RANK() OVER (PARTITION BY place ORDER BY gap DESC) AS rank_by_gap_within_place
FROM 
    earthquake1;

--Create View for Most Impacted Areas

CREATE VIEW most_impacted_areas AS
SELECT 
    place,
    COUNT(id) AS earthquake_count,
    AVG(mag) AS average_magnitude,
    AVG(depth) AS average_depth,
    AVG(gap) AS average_gap,
    MAX(mag) AS max_magnitude,
    MAX(depth) AS max_depth,
    MAX(gap) AS max_gap
FROM 
    earthquake1
GROUP BY 
    place
ORDER BY 
    earthquake_count DESC;
SELECT * FROM most_impacted_areas;
