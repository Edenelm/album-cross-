-- All Sept-2026 players by number of albums seen, full table history (no "installed before Apr 2025" bucket).
-- Same base as tenure_population_rerun_queries.sql; only change: album window starts at the table's history start, not 2025-04-01.
-- Run 2026-10-21. Results: albums-all-players-2026-10-21.md
-- Dice (dice-dreams-dbt), 55.4 GB
WITH act AS (
  SELECT user_id, ANY_VALUE(install_date) AS install_date,
    COUNT(*) AS act_days, SUM(IFNULL(revenues_sum, 0)) AS rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-09-30'
  GROUP BY 1),
alb AS (
  SELECT user_id, COUNT(DISTINCT album_id) AS n_albums,
    MIN(user_album_start_date) AS first_album_start,
    LOGICAL_OR(IFNULL(is_excluded, FALSE)) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2022-01-01' AND DATE '2026-09-30'
    AND user_album_start_date <= DATE '2026-09-30'
  GROUP BY 1)
SELECT CASE
    WHEN b.n_albums = 1 THEN 'a_1' WHEN b.n_albums <= 3 THEN 'b_2-3'
    WHEN b.n_albums <= 6 THEN 'c_4-6' WHEN b.n_albums <= 12 THEN 'd_7-12'
    WHEN b.n_albums <= 24 THEN 'e_13-24' ELSE 'f_25+' END AS grp,
  a.install_date < DATE '2025-04-01' AS installed_before_2025_04,
  COUNT(*) AS players, COUNTIF(a.rev > 0) AS payers, ROUND(SUM(a.rev)) AS rev,
  SUM(a.act_days) AS act_days, MIN(b.first_album_start) AS earliest_album_start,
  MAX(b.n_albums) AS max_albums
FROM act a JOIN alb b USING (user_id)
WHERE NOT b.excl
GROUP BY 1, 2 ORDER BY 1, 2;

-- Domino (domino-dreams-dbt), 63.8 GB
WITH act AS (
  SELECT user_id, MIN(first_seen_date) AS install_date,
    COUNTIF(sessions_today > 0) AS act_days,
    SUM(IFNULL(user_daily_inapp_purchase_amount, 0) + IFNULL(user_daily_stripe_amount, 0)) AS rev,
    LOGICAL_OR(IFNULL(special_user_flag, FALSE) OR IFNULL(suspected_cheater_flag, FALSE)) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-09-30'
  GROUP BY 1
  HAVING COUNTIF(sessions_today > 0) > 0),
alb AS (
  SELECT user_id, COUNT(DISTINCT album_id) AS n_albums,
    MAX(user_album_count) AS max_counter,
    MIN(user_album_start_date) AS first_album_start,
    LOGICAL_OR(IFNULL(special_user_flag, FALSE)) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2022-01-01' AND DATE '2026-09-30'
    AND user_album_start_date <= DATE '2026-09-30'
  GROUP BY 1)
SELECT CASE
    WHEN b.n_albums = 1 THEN 'a_1' WHEN b.n_albums <= 3 THEN 'b_2-3'
    WHEN b.n_albums <= 6 THEN 'c_4-6' WHEN b.n_albums <= 12 THEN 'd_7-12'
    WHEN b.n_albums <= 24 THEN 'e_13-24' ELSE 'f_25+' END AS grp,
  a.install_date < DATE '2025-04-01' AS installed_before_2025_04,
  COUNT(*) AS players, COUNTIF(a.rev > 0) AS payers, ROUND(SUM(a.rev)) AS rev,
  SUM(a.act_days) AS act_days, MIN(b.first_album_start) AS earliest_album_start,
  MAX(b.n_albums) AS max_albums, COUNTIF(b.max_counter = b.n_albums) AS counter_matches
FROM act a JOIN alb b USING (user_id)
WHERE NOT a.excl AND NOT b.excl
GROUP BY 1, 2 ORDER BY 1, 2;
