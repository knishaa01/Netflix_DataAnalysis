-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*) as CNT
FROM netflix
GROUP BY type
	

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating,
	rating_count
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT 
	title,
	release_year
FROM netflix
WHERE type = 'Movie'
AND release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix

SELECT TOP 5
	country,
	COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
AND TRIM(country)<>''
GROUP BY country
ORDER BY total_content DESC;


-- 5. Identify the longest movie

SELECT TOP 1
	title,
	duration 
FROM netflix
WHERE type = 'Movie'
	AND duration IS NOT NULL
	AND duration LIKE '%min'
ORDER BY CAST(REPLACE(duration,'min','') 
AS INT) DESC


-- 6. Find content added in the last 5 years

SELECT 
	show_id,
	type,
	title,
	date_added,
	release_year
FROM netflix
WHERE TRY_CONVERT(DATE,date_added) >= '2016-09-25'
ORDER BY TRY_CONVERT(DATE,date_added) DESC


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT 
	show_id,
	type,
	title,
	director,
	release_year
FROM netflix
Where director LIKE '%Rajiv Chilaka%'


-- 8. List all TV shows with more than 5 seasons

SELECT title, duration
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND duration LIKE '%Seasons'
	AND duration NOT IN (
	'1 Season',
	'2 Seasons',
	'3 Seasons',
	'4 Seasons',
	'5 Seasons'


-- 9. Count the number of content items in each genre

SELECT
	TRIM(value) AS genre,
	COUNT(*) as total_content
FROM netflix
	CROSS APPLY string_split(
	CAST(listed_in AS NVARCHAR(MAX)),',')
	WHERE
		listed_in IS NOT NULL
	GROUP BY
		TRIM(value)
	ORDER BY 
		total_content DESC


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

WITH yearly_content AS
(
    SELECT
        release_year,
        COUNT(*) AS total_content
    FROM netflix
    WHERE country LIKE '%India%'
    GROUP BY release_year
)

SELECT TOP 5
    release_year,
    total_content,
    ROUND(AVG(total_content) OVER (), 2) AS average_content
FROM yearly_content
ORDER BY total_content DESC


-- 11. List all movies that are documentaries
	
SELECT 
	show_id,
	title,
	release_year,
	duration
FROM netflix
WHERE type = 'Movie'
AND listed_in LIKE '%Documentaries'
ORDER BY release_year


-- 12. Find all content without a director

SELECT 
	show_id,
	title,
	type,
	director
FROM netflix
WHERE director IS NULL
	OR TRIM(director) = ''


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT 
	title,
	COUNT(*) AS Salamn_khan_Movies
FROM netflix
WHERE type = 'Movie'
	AND cast LIKE '%Salman Khan%'
	AND release_year >=
		(SELECT MAX(release_year) - 9 FROM netflix) 
GROUP BY title


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.


SELECT TOP 10 
    TRIM(value) AS actor, 
    COUNT(*) AS movie_count
FROM netflix
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE type = 'Movie' 
  AND country LIKE '%India%'
  AND cast IS NOT NULL
GROUP BY TRIM(value)
ORDER BY movie_count DESC;


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

SELECT 
	category,
	COUNT(*) AS content_count
FROM
(
	SELECT
		CASE
			WHEN description LIKE '%kill%'
			OR description LIKE '%violence%'
			THEN 'Bad'
			ELSE 'Good'
		END AS category
	FROM netflix ) AS k
	GROUP BY category



-- End of reports

