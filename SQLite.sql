CREATE TABLE applestore_description_combined AS

SELECT * FROM appleStore_description1

UNIOn ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL 

SELECT * FROM appleStore_description4

**EXPLORATORY DATA ANALYSIS**

-- check the number of unique apps in both tables

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM applestore_description_combined

-- check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERe track_name IS null OR user_rating IS null OR prime_genre IS null

SELECT COUNT(*) AS MissingValues
FROM applestore_description_combined
WHERe app_desc IS null

-- find out the number of apps per genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

-- get an overview of the app's ratings

SELECT MIN(user_rating) AS MinRating
       MAX(user_rating) AS MaxRating
       AVG(user_rating) AS AvgRating
FROM AppleStore

**DATA ANALYSIS**

-- determine whether paid appls have higher ratings than free apps

SELECT CASE
	   		WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
        END AS App_Type,
        avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- check if apps with more supported languages have higher ratings

SELECT CASE
			WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-20 languages'
            ELSE '>30 languages'
       END AS language_bucket,
       avg(user_rating) AS Avg_Rating
From AppleStore
GROUP By language_bucket
ORDER BY Avg_Rating DESC

-- check genres with low ratings

SELECT prime_genre,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER by Avg_Rating ASC
LIMIT 10

-- check if there is correlation between the length of the app description and the user rating

SELECT CASE
            When length(b.app_desc) <500 then 'Short'
            When length(b.app_desc) BETWEEN 500 and 1000 then 'Medium'
            Else 'Long'
        End as description_length_bucket,
        avg(a.user_rating) AS average_rating
        
from AppleStore AS A
JOIN applestore_description_combined AS B
ON A.id = B.id

Group by description_length_bucket
order by average_rating DESC

-- check the top-rated apps for each genre

SELECT 
   prime_genre,
   track_name,
   user_rating
From (
      SELect 
      prime_genre,
      track_name,
      user_rating,
      RANK() OVER(PARTITION by prime_genre order by user_rating DESC, rating_count_tot DESC) AS rank
      FROM 
      AppleStore
     ) AS A 
WHERE
A.rank = 1