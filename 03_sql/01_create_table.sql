-- ============================================
-- SPOTIFY A/B TESTING PROJECT
-- STEP 1: CREATE DATABASE TABLES
-- ============================================

-- Daily listening activity table
CREATE TABLE IF NOT EXISTS listening_activity (
    date DATE,
    user_id VARCHAR(50),
    podcast_minutes_listened NUMERIC,
    music_minutes_listened NUMERIC,
    discovery_feed_clicks INTEGER,
    app_crashes INTEGER,
    missing_reasons VARCHAR(20)
);

-- User experiment assignment table
CREATE TABLE IF NOT EXISTS users (
    user_id VARCHAR(50) PRIMARY KEY,
    variant VARCHAR(20),
    region VARCHAR(50),
    premium_status VARCHAR(20),
    account_age_days NUMERIC
);

-- Import listening activity
COPY listening_activity 
FROM 'C:/Spotify_A-B_Test_project/01_Data/02_processed_data/cleaned_activity.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ','
);

-- Import users
COPY users 
FROM 'C:/Spotify_A-B_Test_project/01_Data/02_processed_data/cleaned_users.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ','
);

-- Analyzing the tables
SELECT 'users' AS table_name, COUNT(*) AS total_rows
FROM users

UNION ALL

SELECT 'listening_activity' AS table_name, COUNT(*) AS total_rows
FROM listening_activity;

SELECT *
FROM users
LIMIT 5;

SELECT *
FROM listening_activity
LIMIT 5;