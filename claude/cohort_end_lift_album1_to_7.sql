-- Same players from their 1st to their 7th album: end lift and ARPDAU (Eden 2026-10-22, option B). Results: claude/cohort-end-lift-2026-10-22.md
-- Cohort = players whose first album with rows in user_daily_album is album A (history: Dice from 2023-11-07, Domino from 2024-06-10, Disney launch).
-- Panel = cohort players who have rows in all 7 albums from A on (Dice A, A+2 ... A+12; Domino / Disney A ... A+6) = the same players in every point.
-- k = album number since joining (1 = first album). Per k: ARPDAU whole album, ARPDAU last 4 days (close-4..close-1), lift = ratio - 1.
-- Rows: active days, from user_album_start_date, close day excluded, game exclusions. Two cohorts per game, averaged on the slide.
-- Cohorts: Dice 49 / 51 (7th album = 61 / 63), Domino 13 / 14 (19 / 20), Disney 8 / 9 (14 / 15).

-- STATUS 2026-10-22: RAN (after a BIFROST outage). Results: claude/cohort-end-lift-2026-10-22.md

-- ===== DICE (step 2), 81 GB =====
WITH ua AS (
  SELECT user_id, album_id, MAX(IFNULL(is_excluded, FALSE)) AS excl FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' AND album_id <= 63 GROUP BY 1, 2
),
f AS (SELECT user_id, MIN(album_id) AS first_alb, LOGICAL_OR(excl) AS excl FROM ua GROUP BY 1),
pan AS (
  SELECT f.user_id, f.first_alb FROM f JOIN ua USING (user_id)
  WHERE f.first_alb IN (49, 51) AND NOT f.excl AND ua.album_id BETWEEN f.first_alb AND f.first_alb + 12
  GROUP BY 1, 2 HAVING COUNT(DISTINCT ua.album_id) = 7
),
alb AS (
  SELECT album_id, MAX(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-07-01' AND DATE '2026-09-07' AND album_id BETWEEN 49 AND 63 GROUP BY 1
),
d AS (
  SELECT p.first_alb, CAST((x.album_id - p.first_alb) / 2 + 1 AS INT64) AS k, IFNULL(x.spent_in_album_today, 0) AS rev,
    x.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY) AS last4
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x
  JOIN pan p ON p.user_id = x.user_id JOIN alb a ON a.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2025-07-01' AND DATE '2026-09-07' AND x.album_id BETWEEN p.first_alb AND p.first_alb + 12
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date AND x.is_active
)
SELECT first_alb, k, COUNT(*) AS act_days, ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / COUNT(*), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), SUM(rev) / COUNT(*)) - 1, 3) AS lift
FROM d GROUP BY 1, 2
UNION ALL
SELECT first_alb, 0 AS k, COUNT(*) AS act_days, NULL, NULL, NULL, NULL FROM pan GROUP BY 1   -- k = 0 row: panel size in act_days
ORDER BY 1, 2
;

-- ===== DOMINO (step 1), 84 GB =====
WITH cheat AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2025-06-01' AND DATE '2026-10-12' GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))
),
ua AS (
  SELECT user_id, album_id, LOGICAL_OR(IFNULL(special_user_flag, FALSE)) AS excl FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2024-06-01' AND DATE '2026-10-12' AND album_id <= 20 GROUP BY 1, 2
),
f AS (SELECT user_id, MIN(album_id) AS first_alb, LOGICAL_OR(excl) AS excl FROM ua GROUP BY 1),
pan AS (
  SELECT f.user_id, f.first_alb FROM f JOIN ua USING (user_id)
  WHERE f.first_alb IN (13, 14) AND NOT f.excl AND ua.album_id BETWEEN f.first_alb AND f.first_alb + 6
    AND f.user_id NOT IN (SELECT user_id FROM cheat)
  GROUP BY 1, 2 HAVING COUNT(DISTINCT ua.album_id) = 7
),
alb AS (
  SELECT album_id, MAX(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-06-01' AND DATE '2026-10-12' AND album_id BETWEEN 13 AND 20 GROUP BY 1
),
d AS (
  SELECT p.first_alb, x.album_id - p.first_alb + 1 AS k, IFNULL(x.album_spent_today, 0) AS rev,
    x.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY) AS last4
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x
  JOIN pan p ON p.user_id = x.user_id JOIN alb a ON a.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2025-06-01' AND DATE '2026-10-12' AND x.album_id BETWEEN p.first_alb AND p.first_alb + 6
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date AND x.active_flag
)
SELECT first_alb, k, COUNT(*) AS act_days, ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / COUNT(*), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), SUM(rev) / COUNT(*)) - 1, 3) AS lift
FROM d GROUP BY 1, 2
UNION ALL
SELECT first_alb, 0 AS k, COUNT(*) AS act_days, NULL, NULL, NULL, NULL FROM pan GROUP BY 1
ORDER BY 1, 2
;

-- ===== DISNEY (step 1), 67 GB =====
WITH excl AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL
),
ua AS (
  SELECT user_id, album_id, LOGICAL_OR(IFNULL(special_user_flag, FALSE)) AS sp FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2024-01-01' AND DATE '2026-10-05' AND album_id <= 15 GROUP BY 1, 2
),
f AS (SELECT user_id, MIN(album_id) AS first_alb, LOGICAL_OR(sp) AS sp FROM ua GROUP BY 1),
pan AS (
  SELECT f.user_id, f.first_alb FROM f JOIN ua USING (user_id)
  WHERE f.first_alb IN (8, 9) AND NOT f.sp AND ua.album_id BETWEEN f.first_alb AND f.first_alb + 6
    AND f.user_id NOT IN (SELECT user_id FROM excl)
  GROUP BY 1, 2 HAVING COUNT(DISTINCT ua.album_id) = 7
),
alb AS (
  SELECT album_id, MAX(album_close_date) AS a_end FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-10-01' AND DATE '2026-10-05' AND album_id BETWEEN 8 AND 15 GROUP BY 1
),
d AS (
  SELECT p.first_alb, x.album_id - p.first_alb + 1 AS k, IFNULL(x.album_spent_today, 0) AS rev,
    x.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY) AS last4
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x
  JOIN pan p ON p.user_id = x.user_id JOIN alb a ON a.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2025-10-01' AND DATE '2026-10-05' AND x.album_id BETWEEN p.first_alb AND p.first_alb + 6
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date AND x.active_flag
)
SELECT first_alb, k, COUNT(*) AS act_days, ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / COUNT(*), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), SUM(rev) / COUNT(*)) - 1, 3) AS lift
FROM d GROUP BY 1, 2
UNION ALL
SELECT first_alb, 0 AS k, COUNT(*) AS act_days, NULL, NULL, NULL, NULL FROM pan GROUP BY 1
ORDER BY 1, 2
;

-- ===== CHECK (Eden 2026-10-22): Dice cohort 49/51 by install age, album-1 ARPDAU, panel vs everyone (96 GB) =====
-- Same ua / f / pan CTEs as the Dice query above; coh = everyone whose first album is 49/51 (in_panel flag);
-- inst = MIN(install_date) from 50_reporting.user_daily_metrics_agg (date_dim 2025-09-01..2026-01-31);
-- d1 = album-1 spend and active days (rows from user_album_start_date, close day excluded, is_active).
-- Buckets: installed 0-60 / 61-365 / >365 days before the first album's start. Full text: session run 2026-10-22 (see results doc).
