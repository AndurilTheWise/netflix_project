/* =========================================================
 Netflix Content Strategy Analysis - SQL Queries
 Description: This script answers 10 key business questions 
 regarding Netflix's content distribution, growth, and 
 global expansion strategy.
 =========================================================
 */
--
-- Q: Movies vs. TV Shows Distrubution
-- Goal: Determine if Netflix is primarily a movie or TV show plotform.
SELECT type,
    COUNT(*) as total_count,
    ROUND(
        (
            COUNT(*) * 100.0 / (
                SELECT COUNT(*)
                FROM netflix_titles
            )
        ),
        2
    ) as percentage
FROM netflix_titles
GROUP BY type
ORDER BY total_count DESC;
-- Q: Top 10 Most Common Genres
-- Goal: Identify the dominant content categories.
-- Technique: 'listed_in' contains comma seperated values 
-- I am going to use UNNEST(STRING_TO_ARRAY(...)) to split them into individual rows for counting.
SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre,
    COUNT(*) as title_count
FROM netflix_titles
GROUP BY genre
ORDER BY title_count DESC
LIMIT 10;
-- Q: Movie Duration Analysis
-- Goal: Find the most common movie lengths
-- Technique: Filter for 'Movie' type and remove the 'min' string to cast as integer.
SELECT CAST(REPLACE(duration, ' min', '') AS INTEGER) as duration_minutes,
    COUNT(*) as count
FROM netflix_titles
WHERE type = 'Movie'
    AND duration LIKE '% min'
GROUP BY duration_minutes
ORDER BY count DESC
LIMIT 10;
-- Q: TV Show Longevity (Season Count)
-- Goal: Analyze how many seasons TV Shows typically last?
-- Technique: Extract the number from strings like '1 Season', '2 Seasons'.
SELECT SPLIT_PART(duration, ' ', 1) as seasons,
    COUNT(*) as title_count
FROM netflix_titles
WHERE type = 'TV Show'
GROUP BY seasons
ORDER BY title_count DESC;
-- Q: Content Added Over Time (Yearly Growth)
-- Goal: Visualize the volume of content added per year.
-- Technique: Parse the 'data_added' string into a data object.
SELECT EXTRACT(
        YEAR
        FROM TO_DATE(date_added, 'Month DD, YYYY')
    ) as year_added,
    COUNT(*) as total_added
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY year_added
ORDER BY year_added DESC -- Q: Top 10 Content Producing Countries
    -- Goal: Identify key international markets.    
    -- Technique: One title can have multiple countries, we split and count.
SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as country_name,
    COUNT(*) as content_count
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY country_name
ORDER BY content_count DESC
LIMIT 10;
-- Q: Seasonality Analysis (Best month to Release)
-- Goal: Checking if there is a specific month with higher upload volumes.
SELECT EXTRACT(
        MONTH
        FROM TO_DATE(date_added, 'Month DD, YYYY')
    ) as month_added,
    TO_CHAR(TO_DATE(date_added, 'Month DD, YYYY'), 'Month') as month_name,
    COUNT(*) as total_added
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY month_added,
    month_name
ORDER BY month_added -- Q: Freshness Analyis (Release Year vs Added Year)
    -- Goal: Calculating the average delay between theatrical release and Netflix launch
SELECT EXTRACT(
        YEAR
        FROM TO_DATE(date_added, 'Month DD, YYYY')
    ) as year_added,
    ROUND(
        AVG(
            EXTRACT(
                YEAR
                FROM TO_DATE(date_added, 'Month DD, YYYY')
            ) - release_year
        ),
        1
    ) as avg_delay_years
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY year_added
HAVING(
        EXTRACT(
            YEAR
            FROM TO_DATE(date_added, 'Month DD, YYYY')
        ) >= 2010
    )
ORDER BY year_added DESC --
    -- Q: Target Audience (Maturity Ratings)
    -- Goals: Understanding the demographic focus.
SELECT rating,
    COUNT(*) as count
FROM netflix_titles
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY count DESC;
-- Q: Top 10 Directors
-- Goal: Identify the most frequent directors on the platform.
SELECT TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) as director_name,
    COUNT(*) as title_count
FROM netflix_titles
WHERE director IS NOT NULL
GROUP BY director_name
ORDER BY title_count DESC
LIMIT 10;