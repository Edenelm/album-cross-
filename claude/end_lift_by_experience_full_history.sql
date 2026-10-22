-- End lift by number of albums experienced, same groups as Eden's revenue slide (1 / 2-3 / 4-6 / 7-12 / 13+), 2026-10-22.
-- Results: claude/end-lift-by-experience-2026-10-22.md
-- Population (as end-growth / album_length_end_arpdau_queries.sql): all players who received the album, rows from user_album_start_date,
--   active days, close day excluded, game exclusions. Revenue = album-table spend column.
-- Albums seen = number of distinct albums the player has rows for in user_daily_album up to and including this album (full table history:
--   Dice from 2023-11-07, Domino from 2024-06-10, Disney from launch). Lift = last-4-days ARPDAU / whole-album ARPDAU - 1, per album.

-- ===== DICE 61/63 =====
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND album_id IN (61,63) GROUP BY 1
),
ua AS (
  SELECT user_id, album_id FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' AND album_id <= 63 GROUP BY 1, 2
),
nseen AS (SELECT user_id, album_id, COUNT(*) OVER (PARTITION BY user_id ORDER BY album_id) AS n FROM ua),
d AS (
  SELECT x.album_id, IFNULL(x.spent_in_album_today, 0) AS rev, x.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY) AS last4,
    CASE WHEN p.n = 1 THEN 'a_1' WHEN p.n <= 3 THEN 'b_2-3' WHEN p.n <= 6 THEN 'c_4-6' WHEN p.n <= 12 THEN 'd_7-12' ELSE 'e_13+' END AS grp
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x
  JOIN alb a USING (album_id)
  JOIN nseen p ON p.user_id = x.user_id AND p.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-07'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.is_active AND NOT IFNULL(x.is_excluded, FALSE)
)
SELECT album_id, grp, COUNT(*) AS act_days, ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / COUNT(*), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), SUM(rev) / COUNT(*)) - 1, 3) AS lift
FROM d GROUP BY 1, 2 ORDER BY 1, 2
;

-- ===== DOMINO 19/20 =====
WITH cheat AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))
),
alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (19,20) GROUP BY 1
),
ua AS (
  SELECT user_id, album_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2024-06-01' AND DATE '2026-10-12' AND album_id <= 20 GROUP BY 1, 2
),
nseen AS (SELECT user_id, album_id, COUNT(*) OVER (PARTITION BY user_id ORDER BY album_id) AS n FROM ua),
d AS (
  SELECT x.album_id, IFNULL(x.album_spent_today, 0) AS rev, x.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY) AS last4,
    CASE WHEN p.n = 1 THEN 'a_1' WHEN p.n <= 3 THEN 'b_2-3' WHEN p.n <= 6 THEN 'c_4-6' WHEN p.n <= 12 THEN 'd_7-12' ELSE 'e_13+' END AS grp
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x
  JOIN alb a USING (album_id)
  JOIN nseen p ON p.user_id = x.user_id AND p.album_id = x.album_id
  LEFT JOIN cheat c ON c.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.active_flag AND x.special_user_flag = FALSE AND c.user_id IS NULL
)
SELECT album_id, grp, COUNT(*) AS act_days, ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / COUNT(*), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), SUM(rev) / COUNT(*)) - 1, 3) AS lift
FROM d GROUP BY 1, 2 ORDER BY 1, 2
;

-- ===== DISNEY 14/15 =====
WITH excl AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL
),
alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-05' AND album_id IN (14,15) GROUP BY 1
),
ua AS (
  SELECT user_id, album_id FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2024-01-01' AND DATE '2026-10-05' AND album_id <= 15 GROUP BY 1, 2
),
nseen AS (SELECT user_id, album_id, COUNT(*) OVER (PARTITION BY user_id ORDER BY album_id) AS n FROM ua),
d AS (
  SELECT x.album_id, IFNULL(x.album_spent_today, 0) AS rev, x.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY) AS last4,
    CASE WHEN p.n = 1 THEN 'a_1' WHEN p.n <= 3 THEN 'b_2-3' WHEN p.n <= 6 THEN 'c_4-6' WHEN p.n <= 12 THEN 'd_7-12' ELSE 'e_13+' END AS grp
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x
  JOIN alb a USING (album_id)
  JOIN nseen p ON p.user_id = x.user_id AND p.album_id = x.album_id
  LEFT JOIN excl e ON e.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-05'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.active_flag AND x.special_user_flag = FALSE AND e.user_id IS NULL
)
SELECT album_id, grp, COUNT(*) AS act_days, ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / COUNT(*), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), SUM(rev) / COUNT(*)) - 1, 3) AS lift
FROM d GROUP BY 1, 2 ORDER BY 1, 2
;
