-- Album length vs last-4-days ARPDAU (2026-10-18). Albums opened >= 2025-04-01, closed <= 2026-10-18.
-- Population: all players who received the album (rows from user_album_start_date), active days, close day excluded.
-- Domino and Disney versions are identical except: table/columns (album_open_date, album_close_date, album_spent_today, active_flag),
-- exclusions (Domino: special_user_flag = FALSE + suspected_cheater_flag from prod_40_mart.user_daily_metrics;
-- Disney: special_user_flag = FALSE + bi_prod.user_profile.exclude_reason IS NULL).

-- Dice (dice-dreams-dbt)
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MAX(album_end_date) AS a_end,
         COUNT(DISTINCT album_start_date) AS n_open, COUNT(DISTINCT album_end_date) AS n_close
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-03-01' AND DATE '2026-10-18'
  GROUP BY 1
  HAVING MIN(album_start_date) >= DATE '2025-04-01' AND MAX(album_end_date) <= DATE '2026-10-18'
),
d AS (
  SELECT x.album_id, x.user_id, x.date_dim, a.a_end, IFNULL(x.spent_in_album_today, 0) AS rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x
  JOIN alb a ON a.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-18'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.is_active AND NOT IFNULL(x.is_excluded, FALSE)
)
SELECT a.album_id, a.a_start, a.a_end, DATE_DIFF(a.a_end, a.a_start, DAY) AS span_days,
  FORMAT_DATE('%a', a.a_end) AS close_weekday, a.n_open, a.n_close,
  COUNT(DISTINCT d.user_id) AS players, COUNT(*) AS act_days, ROUND(SUM(d.rev)) AS rev,
  ROUND(SUM(d.rev) / COUNT(*), 3) AS arpdau_album,
  COUNTIF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY)) AS end_days,
  ROUND(SUM(IF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY), d.rev, 0))) AS end_rev,
  ROUND(SAFE_DIVIDE(SUM(IF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY), d.rev, 0)),
                    COUNTIF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY))), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY), d.rev, 0)),
                    COUNTIF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY))), SUM(d.rev) / COUNT(*)), 3) AS ratio_last4
FROM alb a JOIN d ON d.album_id = a.album_id
GROUP BY 1, 2, 3, 4, 5, 6, 7
ORDER BY a.a_start;

-- Domino (domino-dreams-dbt): exclusion CTE
-- cheat AS (SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
--           WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-18'
--           GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE)))
-- Disney (solitaire-dreams-411507): exclusion CTE
-- excl AS (SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
--          WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-18' AND exclude_reason IS NOT NULL)
