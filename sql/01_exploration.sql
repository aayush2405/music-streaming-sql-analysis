
-- Row Count 
SELECT COUNT(*) AS members_rows   FROM members;         #88726 member_rows
SELECT COUNT(*) AS train_rows     FROM train;           #100000 train_rows
SELECT COUNT(*) AS user_logs_rows FROM user_logs;       #1393933 user_logs_rows



-- Users in train with no member record (no city). 
-- Found: 11,274 train_users_without_member
SELECT COUNT(*) AS train_users_without_member
FROM train t LEFT JOIN members m USING (msno)
WHERE m.msno IS NULL;           



-- Users who actually appear in the logs. 
-- Found: 77762
SELECT COUNT(DISTINCT msno) AS users_with_logs 
FROM user_logs;



-- Date range of the logs (stored as YYYYMMDD). 
-- Found: 20170301 to 20170331
SELECT MIN(log_date) AS first_day, MAX(log_date) AS last_day 
FROM user_logs;



-- Churn balance. 
-- Found: 9.0% churned (8,993 of 100,000)
SELECT is_churn, COUNT(*) AS n,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM train GROUP BY is_churn;



-- Users who have BOTH a city and listening logs (the real analysis base)
-- Found : 77761
SELECT COUNT(DISTINCT m.msno) AS users_with_city_and_logs
FROM members m 
JOIN user_logs l USING (msno);



-- Users per city code
SELECT city, COUNT(*) AS users
FROM members 
GROUP BY city 
ORDER BY users DESC;



-- Age quality (bd usually has zeros and impossible values)
SELECT bd, COUNT(*) AS n
FROM members 
GROUP BY bd 
ORDER BY n DESC LIMIT 10;



-- Impossible values in logs (over 24h in a day, or negative)
-- Found : 326
SELECT COUNT(*) AS bad_rows
FROM user_logs
WHERE total_secs > 86400 OR total_secs < 0;



-- Duplicate user-day rows
SELECT COUNT(*) AS duplicate_user_days FROM (
  SELECT msno, log_date
  FROM user_logs
  GROUP BY msno, lo_date
  HAVING COUNT(*) > 1
) d;



-- Gender completeness
SELECT COALESCE(NULLIF(gender, ''), 'unknown') AS gender, COUNT(*) AS n
FROM members GROUP BY 1;
 