-- Database schema for the German Cities Data Pipeline
-- Run this once against your MySQL instance before running the notebook.
--
-- Make sure you're using the right schema (replace `gans` with your own schema name if needed)
-- USE gans;

-- Temporarily disable foreign key checks so tables can be created in any order
SET FOREIGN_KEY_CHECKS = 0;

-- 1. Main cities table
-- A UNIQUE constraint on city_name is required for INSERT IGNORE to actually
-- prevent duplicate cities on re-runs (the notebook also filters new cities
-- in Python, so this acts as a safety net at the database level).
CREATE TABLE IF NOT EXISTS cities (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(10) NOT NULL,
    UNIQUE KEY uq_city_name (city_name)
);

-- 2. Geographic data (one row per city)
CREATE TABLE IF NOT EXISTS geo (
    city_id INT,
    latitude DECIMAL(10, 6),
    longitude DECIMAL(10, 6),
    UNIQUE KEY uq_geo_city (city_id),
    FOREIGN KEY (city_id) REFERENCES cities(city_id) ON DELETE CASCADE
);

-- 3. Population data (one row per city per year)
CREATE TABLE IF NOT EXISTS populations (
    population_id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT,
    population INT,
    timestamp_population INT,
    UNIQUE KEY uq_city_year (city_id, timestamp_population),
    FOREIGN KEY (city_id) REFERENCES cities(city_id) ON DELETE CASCADE
);

-- 4. Weather forecasts (one row per city per forecast timestamp)
CREATE TABLE IF NOT EXISTS weathers (
    weather_id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT,
    forecast_time DATETIME,
    outlook VARCHAR(255),
    temperature DECIMAL(5, 2),
    feels_like DECIMAL(5, 2),
    wind_speed DECIMAL(5, 2),
    rain_prob DECIMAL(5, 2),
    UNIQUE KEY uq_city_forecast (city_id, forecast_time),
    FOREIGN KEY (city_id) REFERENCES cities(city_id) ON DELETE CASCADE
);

-- 5. Airports (ICAO code is the primary key)
CREATE TABLE IF NOT EXISTS airports (
    airport_icao VARCHAR(10) PRIMARY KEY,
    airport_name VARCHAR(255)
);

-- 6. Bridge table linking cities to nearby airports
CREATE TABLE IF NOT EXISTS cities_airports (
    city_id INT,
    airport_icao VARCHAR(10),
    PRIMARY KEY (city_id, airport_icao),
    FOREIGN KEY (city_id) REFERENCES cities(city_id) ON DELETE CASCADE,
    FOREIGN KEY (airport_icao) REFERENCES airports(airport_icao) ON DELETE CASCADE
);

-- 7. Flights table
-- A UNIQUE constraint on (flight_num, arrival_time) lets INSERT IGNORE skip
-- a flight that was already fetched on a previous run.
CREATE TABLE IF NOT EXISTS flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_num VARCHAR(50),
    departure_icao VARCHAR(10),
    arrival_icao VARCHAR(10),
    arrival_time DATETIME,
    UNIQUE KEY uq_flight (flight_num, arrival_time)
);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;
