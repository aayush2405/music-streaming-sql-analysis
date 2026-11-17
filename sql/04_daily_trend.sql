USE music_analysis;

WITH daily AS (
  SELECT m.city,
         l.log_date,
         COUNT(DISTINCT l.msno) AS dau
  FROM logs_clean l
  JOIN members m USING (msno) 
  GROUP BY m.city, l.log_date
)
SELECT city,
       log_date,
       dau,
       ROUND(AVG(dau) OVER (PARTITION BY city
                            ORDER BY log_date
                            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 1) AS dau_7d_avg
FROM daily
WHERE city IN (SELECT city FROM (
                 SELECT city FROM members
                 GROUP BY city
                 ORDER BY COUNT(*) DESC
                 LIMIT 3) top3)
ORDER BY city, log_date;
 