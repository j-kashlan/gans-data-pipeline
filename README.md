# German Cities Data Pipeline

A small ETL project built in Jupyter that pulls demographic, geographic, weather, airport, and
flight data for a set of German cities and loads everything into a MySQL database.

## What it does

1. **Wikipedia scraping** — gets population and coordinates for each target city.
2. **Weather** — pulls a forecast for each city from the OpenWeatherMap API.
3. **Airports** — finds nearby airports for each city via the AeroDataBox API (RapidAPI).
4. **Flights** — fetches upcoming arrivals for each of those airports.

The default target cities are Munich, Stuttgart, and Düsseldorf (see `target_cities` in the
notebook — add more cities there any time).

## Project structure

```
.
├── api_project.ipynb   # Main notebook — run top to bottom
├── schema.sql           # MySQL table definitions — run this first
├── requirements.txt      # Python dependencies
├── .env.example          # Template for your local .env file
└── .gitignore
```

## Setup

1. **Create the database schema**

   Run `schema.sql` against your MySQL instance (adjust the schema name at the top if needed):

   ```bash
   mysql -u root -p < schema.sql
   ```

2. **Install dependencies**

   ```bash
   pip install -r requirements.txt
   ```

3. **Configure environment variables**

   Copy `.env.example` to `.env` and fill in your own values:

   ```bash
   cp .env.example .env
   ```

   You'll need:
   - MySQL connection details (`DB_HOST`, `DB_PORT`, `DB_SCHEMA`, `DB_USER`, `DB_PASSWORD`)
   - An [OpenWeatherMap](https://openweathermap.org/api) API key
   - A [RapidAPI](https://rapidapi.com/aedbx-aedbx/api/aerodatabox) key for AeroDataBox

   `.env` is already listed in `.gitignore` — never commit it.

4. **Run the notebook**

   Open `api_project.ipynb` and run the cells in order, top to bottom. Each step depends on
   data written to the database by the step before it.

## Notes

- The notebook is safe to re-run: it filters out cities that already exist before scraping, and
  uses `INSERT IGNORE` (via a small SQLAlchemy helper) so re-running it won't create duplicate
  rows, as long as `schema.sql` has been applied (it adds the unique constraints this relies on).
- Weather and flight data are naturally time-series — re-running the notebook later will fetch a
  fresh forecast/schedule rather than "duplicate" the old one.
