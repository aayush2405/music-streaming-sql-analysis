-- CLEAN VIEW
-- Removes impossible values, merges duplicate user-days, converts the date.
-- The raw table user_logs is left untouched.

USE music_analysis;

CREATE OR REPLACE VIEW logs_clean AS
SELECT msno,
       STR_TO_DATE(log_date, '%Y%m%d') AS log_date,
       SUM(num_25)     AS num_25,
       SUM(num_50)     AS num_50,
       SUM(num_75)     AS num_75,
       SUM(num_985)    AS num_985,
       SUM(num_100)    AS num_100,
       SUM(num_unq)    AS num_unq,
       SUM(total_secs) AS total_secs
FROM user_logs
WHERE total_secs BETWEEN 0 AND 86400
GROUP BY msno, log_date;
