# Netflix Content Strategy & Market Analysis

## Overview
This project involves a comprehensive analysis of Netflix's content catalog, comprmising over 8,800 titles added between 2008 and 2021. Using PostgreSQL for data extraction and Pyhton for visualization, we investigate how Netflix has evolved from US centric DVD rental service into a global streaming powerhouse. The analysis uncovers trends in content production, internal expansion and genre diversification, offering data driven insights into the company's strategic pivot towards 'Originals' and international markets.

Looking for SQL queries? Look Here: [project folder](project)

## The Questions I Wanted to answer thrugh my SQL Queries Were:
1. Is Netflix focusing more on Movies or TV Shows in recent years?
2. Which countries are the biggest producers of content outside the US?
3. What are the most dominant genres in the Netflix Library?
4. How "fresh" is the content (the lag time between release and upload)?
5. Does Netflix target adults or families with it's rating strategy?
6. Is there a specific seasonal trend (like Q4) for content releases?
7. Who are the top directors driving the platform's content?
8. What is the standart duration for movies and TV Shows?
9. How has the volume of content added changed historically?
10. What is the exact distribution of content types?


# Tools I Used
- **PostgreSQL:** The core analysis engine. I chose SQL for this project to demonstrate database management skills, specifically handling array data types and complex aggregations.
- **Python (Pandas & Seaborn):** Used to visualize the SQL results, transforming numbers into 10 actionable dashboards.
- **Seaborn & Matplotlib:** Essential for version control and sharing my findings.
- **Visual Studio Code:** The IDE used for writing SQL queries and managing the Python enviroment.

# The Analysis
Each query in this project was aimed at a specific business metric. By cleaning the data and running aggregate functions, I was able to build a timeline of Netflix's strategy.

### 1. Content Type Distribution
I wanted to see if Netflix is shifting it's focus on movies or series. Despite the cultural buzz around popular series like Stranger Things, Netflix is primarly a film archive. However, this split serves two purposes: Movies attract new users , while TV Shows retain them. The strategy is a balanced ecosystem of acquisition (Movies) vs retention(TV).

```sql
SELECT 
    type, 
    COUNT(*) as total_count,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles)), 2) as percentage
FROM netflix_titles
GROUP BY type
ORDER BY total_count DESC;
```

![Type Distrubition](assets/1.png)
*For this analysis i used a pie chart. Since I was comparing two distinct categories, a pie chart was the most effective way to instantly visualize the dominance without a need for reading the exact numbers.*

### 2. Global Expansion
To understand Netflix's globalization strategy, I analyzed the primary country of production. India is the second largest content producer after the US, significantly outpacing the UK. This highlights Netflix's "Next Billions Users" strategy, heavily investing in the Asian market where mobile streaming is dominant

```sql
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as country_name, 
    COUNT(*) as content_count
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY country_name
ORDER BY content_count DESC
LIMIT 10;
```

![Global Expansion](assets/6.png)
*I used a bar chart to rank the countries. This allows for an easy comparison between the dominant producer (USA) and emerging markets like India, highlighting the scale of difference.*

### 3. Content Freshness
I calculated the "The Lag Time"(Years between Release and Netflix Add) to see if the library is getting newer. The Lag Time has dropped from ~4 years in 2010 to near zero today. This confirms Netflix's pivot from a renting old movies to a releasing Originals day and date.

```sql
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year_added,
    ROUND(AVG(EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) - release_year), 1) as avg_delay_years
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY year_added
HAVING EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) >= 2010
ORDER BY year_added DESC;
```


![Content Freshness](assets/8.png)
*I used a line chart to visualize the trend over time. This effectively demonstrates the downward slope, proving the strategic shift toward newer content.*

### 4. Maturity Ratings
I analyzed the ratings to determine if Netflix is positioning itself for producing contents for kids or adults. TV-MA is the dominant rating. Despite having a Kids profile, Netflix's core brand identity is built on edgy, adult oriented dramas distinguishing it from other streaming platforms.

```sql
SELECT 
    rating, 
    COUNT(*) as count
FROM netflix_titles
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY count DESC;
```

![Maturity Ratings](assets/9.png)
*I used a bar chart sorted by volume. This makes it instantly clear which demographic is the primary target for the platform*