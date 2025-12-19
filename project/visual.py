import pandas as pd
import matplotlib
matplotlib.use('Qt5Agg')
import matplotlib.pyplot as plt
import seaborn as sns

DATA_FILE = 'netflix_titles.csv'

sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (12, 8)
plt.rcParams['font.size'] = 12


df = pd.read_csv(DATA_FILE)

### Data Cleaning

df['date_added'] = df['date_added'].str.strip()
df['date_added_dt'] = pd.to_datetime(df['date_added'], format='mixed', errors='coerce')
df['year_added'] = df['date_added_dt'].dt.year
df['month_added'] = df['date_added_dt'].dt.month_name()

df_genres = df.assign(genre=df['listed_in'].str.split(', ')).explode('genre')

df_countries = df.assign(country=df['country'].str.split(', ')).explode('country')

df_directors = df.assign(director=df['director'].str.split(', ')).explode('director')



### Plotting

# --- Movies vs TV Shows ---
plt.figure()
type_counts = df['type'].value_counts()
plt.pie(type_counts, labels=type_counts.index, autopct='%1.1f%%', startangle=140, colors=['#e50914', '#221f1f'])
plt.title('Distribution of Content Types')
plt.show()

# --- Top 10 Genres ---
plt.figure()
genre_counts = df_genres['genre'].value_counts().head(10)
sns.barplot(x=genre_counts.values, y=genre_counts.index, palette='Reds_r')
plt.title('Top 10 Most Common Genres')
plt.xlabel('Number of Titles')
plt.show()

# --- Movie Duration Distribution ---
plt.figure()
movies = df[df['type'] == 'Movie'].copy()
movies['duration_min'] = movies['duration'].str.replace(' min', '', regex=False).astype(float)
sns.histplot(movies['duration_min'], bins=30, kde=True, color='dimgray')
plt.title('Movie Duration Distribution')
plt.xlabel('Duration (Minutes)')
plt.show()

# --- TV Show Season Count ---
plt.figure()
tv_shows = df[df['type'] == 'TV Show'].copy()
tv_shows['seasons_count'] = tv_shows['duration'].apply(lambda x: int(x.split(' ')[0]))
season_counts = tv_shows['seasons_count'].value_counts().sort_index()
sns.barplot(x=season_counts.index, y=season_counts.values, color='#e50914')
plt.title('Distribution of TV Show Seasons')
plt.xlim(-0.5, 10.5)
plt.show()

# --- Content Added Over Time ---
plt.figure()
year_counts = df['year_added'].value_counts().sort_index()
year_counts = year_counts[year_counts.index >= 2008]
sns.lineplot(x=year_counts.index, y=year_counts.values, marker='o', color='#e50914')
plt.title('Content Added to Netflix Over Time')
plt.xlabel('Year Added')
plt.grid(True)
plt.show()

# --- Top 10 Producing Countries ---
plt.figure()
country_counts = df_countries['country'].value_counts().head(10)
sns.barplot(x=country_counts.values, y=country_counts.index, palette='gray')
plt.title('Top 10 Producing Countries')
plt.show()

# --- Seasonality ---
plt.figure()
month_order = ['January', 'February', 'March', 'April', 'May', 'June', 
               'July', 'August', 'September', 'October', 'November', 'December']
sns.countplot(data=df, x='month_added', order=month_order, palette='Reds')
plt.title('Content Added by Month (Seasonality)')
plt.xticks(rotation=45)
plt.show()

# --- Freshness ---
plt.figure()
df_lag = df.dropna(subset=['year_added', 'release_year']).copy()
df_lag['lag'] = df_lag['year_added'] - df_lag['release_year']
avg_lag = df_lag.groupby('year_added')['lag'].mean()
avg_lag = avg_lag[avg_lag.index >= 2010]
sns.lineplot(x=avg_lag.index, y=avg_lag.values, marker='o', color='black')
plt.title('Average Lag Time (Years from Cinema to Netflix)')
plt.grid(True)
plt.show()

# --- Target Audience ---
plt.figure()
rating_order = df['rating'].value_counts().index
sns.countplot(data=df, x='rating', order=rating_order, palette='Reds')
plt.title('Distribution of Maturity Ratings')
plt.show()

# --- Top 10 Directors ---
plt.figure()
director_counts = df_directors['director'].dropna().value_counts().head(10)
sns.barplot(x=director_counts.values, y=director_counts.index, palette='rocket')
plt.title('Top 10 Directors on Netflix')
plt.show()
