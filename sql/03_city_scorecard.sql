-- CITY SCORECARD (core analysis)
-- Combines users, hours listened, song completion and churn per city
-- code into one 0-100 market score.

USE music_analysis;

WITH user_stats AS (
  SELECT msno,
         COUNT(DISTINCT log_date) AS active_days,
         SUM(total_secs) / 3600   AS hours,
         SUM(num_100) / NULLIF(SUM(num_25 + num_50 + num_75 + num_985 + num_100), 0) AS completion
  FROM logs_clean
  GROUP BY msno
),
city_stats AS (
  SELECT m.city,
         COUNT(*)          AS users,
         AVG(t.is_churn)   AS churn_rate,
         AVG(u.hours)      AS avg_hours,
         AVG(u.active_days) AS avg_active_days,
         AVG(u.completion) AS completion
  FROM members m
  JOIN train t USING (msno)
  LEFT JOIN user_stats u USING (msno)
  GROUP BY m.city
  HAVING COUNT(*) >= 300          -- ignore very small city codes
)
SELECT city,
       users,
       ROUND(100 * churn_rate, 1)    AS churn_pct,
       ROUND(avg_hours, 1)           AS avg_hours,
       ROUND(avg_active_days, 1)     AS avg_active_days,
       ROUND(completion, 3)          AS completion,
       ROUND(100 * ( PERCENT_RANK() OVER (ORDER BY users)
                   + PERCENT_RANK() OVER (ORDER BY avg_hours)
                   + PERCENT_RANK() OVER (ORDER BY completion)
                   + (1 - PERCENT_RANK() OVER (ORDER BY churn_rate)) ) / 4, 1) AS market_score
FROM city_stats
ORDER BY market_score DESC;
