-- ==========================================
-- SPOTIFY A/B TEST
-- 1. EXPERIMENT GROUP DISTRIBUTION
-- ==========================================

SELECT
    variant,
    COUNT(*) AS total_users,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM users
GROUP BY variant
ORDER BY variant;

-- ==========================================
-- 2. SAMPLE RATIO MISMATCH (SRM) CHECK
-- ==========================================

WITH group_counts AS (
    SELECT
        variant,
        COUNT(*) AS observed_count
    FROM users
    GROUP BY variant
),
totals AS (
    SELECT SUM(observed_count) AS total_users
    FROM group_counts
),
expected AS (
    SELECT total_users / 2.0 AS expected_count
    FROM totals
)
SELECT
    g.variant,
    g.observed_count,
    ROUND(e.expected_count, 2) AS expected_count,
    ROUND(
        POWER(g.observed_count - e.expected_count, 2)
        / e.expected_count, 4
    ) AS chi_square_component
FROM group_counts g
CROSS JOIN expected e;

-- Overall SRM chi-square statistic

WITH group_counts AS (
    SELECT
        variant,
        COUNT(*) AS observed_count
    FROM users
    GROUP BY variant
),
totals AS (
    SELECT SUM(observed_count) AS total_users
    FROM group_counts
)
SELECT
    SUM(
        POWER(g.observed_count - t.total_users / 2.0, 2)
        / (t.total_users / 2.0)
    ) AS chi_square_statistic
FROM group_counts g
CROSS JOIN totals t;


-- SRM chi-square p-value (1 degree of freedom)

SELECT
    1 - SQRT(
        2.0 / PI()
    ) * (
        SELECT
            0.0
    ) AS placeholder;

SELECT
    1 - ERF(SQRT(0.45 / 2.0)) AS srm_p_value;


-- ==========================================
-- 3. PREMIUM STATUS BALANCE CHECK
-- ==========================================

SELECT
    variant,
    premium_status,
    COUNT(*) AS total_users,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY variant),
        2
    ) AS percentage
FROM users
GROUP BY variant, premium_status
ORDER BY variant, premium_status;


-- ==========================================
-- 4. REGION BALANCE CHECK
-- ==========================================

SELECT
    variant,
    region,
    COUNT(*) AS total_users,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY variant),
        2
    ) AS percentage
FROM users
GROUP BY variant, region
ORDER BY variant, region;


-- ==========================================
-- 5. PRIMARY METRIC
-- Average daily podcast listening per user
-- ==========================================

WITH user_podcast AS (
    SELECT
        u.user_id,
        u.variant,
        COALESCE(SUM(a.podcast_minutes_listened), 0) AS total_podcast_minutes
    FROM users u
    LEFT JOIN listening_activity a
        ON u.user_id = a.user_id
    GROUP BY u.user_id, u.variant
)
SELECT
    variant,
    COUNT(*) AS total_users,
    ROUND(AVG(total_podcast_minutes / 14.0), 4)
        AS avg_daily_podcast_minutes
FROM user_podcast
GROUP BY variant
ORDER BY variant;


-- ==========================================
-- 6. PRIMARY METRIC TREATMENT EFFECT
-- ==========================================

WITH user_podcast AS (
    SELECT
        u.user_id,
        u.variant,
        COALESCE(SUM(a.podcast_minutes_listened), 0) / 14.0
            AS avg_daily_minutes
    FROM users u
    LEFT JOIN listening_activity a
        ON u.user_id = a.user_id
    GROUP BY u.user_id, u.variant
),
group_averages AS (
    SELECT
        variant,
        AVG(avg_daily_minutes) AS avg_minutes
    FROM user_podcast
    GROUP BY variant
)
SELECT
    MAX(CASE WHEN variant = 'Treatment'
        THEN avg_minutes END)
    -
    MAX(CASE WHEN variant = 'Control'
        THEN avg_minutes END)
    AS treatment_effect
FROM group_averages;

-- ==========================================
-- 7. SECONDARY METRIC: DISCOVERY FEED CLICKS
-- ==========================================

WITH user_clicks AS (
    SELECT
        u.user_id,
        u.variant,
        COALESCE(SUM(a.discovery_feed_clicks), 0) AS total_clicks,
        COUNT(DISTINCT a.date) AS recorded_days
    FROM users u
    LEFT JOIN listening_activity a
        ON u.user_id = a.user_id
    GROUP BY u.user_id, u.variant
)
SELECT
    variant,
    COUNT(*) AS total_users,
    ROUND(AVG(total_clicks / NULLIF(recorded_days, 0)), 4)
        AS avg_daily_clicks
FROM user_clicks
GROUP BY variant
ORDER BY variant;

SELECT
    u.variant,
    COUNT(DISTINCT u.user_id) AS total_users,
    SUM(a.discovery_feed_clicks) AS total_clicks,
    COUNT(DISTINCT a.date) AS distinct_activity_dates
FROM users u
LEFT JOIN listening_activity a
    ON u.user_id = a.user_id
GROUP BY u.variant;


SELECT
    variant,
    COUNT(*) AS user_count,
    ROUND(AVG(total_music), 4) AS average_music_minutes
FROM (
    SELECT
        u.user_id,
        u.variant,
        COALESCE(SUM(a.music_minutes_listened), 0) AS total_music
    FROM users u
    LEFT JOIN listening_activity a
        ON u.user_id = a.user_id
    GROUP BY u.user_id, u.variant
) AS user_totals
GROUP BY variant
ORDER BY variant;

-- ==========================================
-- 7. SECONDARY METRIC: DAILY DISCOVERY CLICKS
-- ==========================================

WITH user_clicks AS (
    SELECT
        u.user_id,
        u.variant,
        COALESCE(SUM(a.discovery_feed_clicks), 0) AS total_clicks,
        COUNT(DISTINCT a.date) AS recorded_days
    FROM users u
    LEFT JOIN listening_activity a
        ON u.user_id = a.user_id
    GROUP BY u.user_id, u.variant
)
SELECT
    variant,
    ROUND(
        AVG(total_clicks / NULLIF(recorded_days, 0)),
        4
    ) AS avg_daily_clicks
FROM user_clicks
GROUP BY variant
ORDER BY variant;

-- ==========================================
-- 9. AVERAGE DAILY MUSIC LISTENING
-- ==========================================

WITH user_music AS (
    SELECT
        u.user_id,
        u.variant,
        COALESCE(SUM(a.music_minutes_listened), 0) AS total_music,
        COUNT(DISTINCT a.date) AS recorded_days
    FROM users u
    LEFT JOIN listening_activity a
        ON u.user_id = a.user_id
    GROUP BY u.user_id, u.variant
)
SELECT
    variant,
    ROUND(
        AVG(total_music / NULLIF(recorded_days, 0)),
        4
    ) AS avg_music_per_recorded_day
FROM user_music
GROUP BY variant
ORDER BY variant;

-- ==========================================
-- 10. APP CRASHES: GUARDRAIL METRIC
-- ==========================================

WITH user_crashes AS (
    SELECT
        u.user_id,
        u.variant,
        COALESCE(SUM(a.app_crashes), 0) AS total_crashes
    FROM users u
    LEFT JOIN listening_activity a
        ON u.user_id = a.user_id
    GROUP BY u.user_id, u.variant
)
SELECT
    variant,
    COUNT(*) AS total_users,
    SUM(total_crashes) AS total_crashes,
    ROUND(AVG(total_crashes), 4) AS avg_crashes_per_user,
    SUM(CASE WHEN total_crashes > 0 THEN 1 ELSE 0 END)
        AS users_with_crashes,
    ROUND(
        100.0 * SUM(CASE WHEN total_crashes > 0 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS crash_incidence_percentage
FROM user_crashes
GROUP BY variant
ORDER BY variant;

-- ==========================================
-- 11. DATA QUALITY CHECKS
-- ==========================================

-- Check total users and unique users
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT user_id) AS unique_users
FROM users;

-- Check duplicate user-date records
SELECT
    COUNT(*) AS duplicate_user_date_records
FROM (
    SELECT
        user_id,
        date
    FROM listening_activity
    GROUP BY user_id, date
    HAVING COUNT(*) > 1
) AS duplicates;

-- Check missing podcast measurements
SELECT
    COUNT(*) AS missing_podcast_records
FROM listening_activity
WHERE podcast_minutes_listened IS NULL;

-- Check activity records without a matching user
SELECT
    COUNT(*) AS unmatched_activity_records
FROM listening_activity a
LEFT JOIN users u
    ON a.user_id = u.user_id
WHERE u.user_id IS NULL;

-- Check impossible podcast listening values
SELECT
    COUNT(*) AS values_above_480
FROM listening_activity
WHERE podcast_minutes_listened > 480;