-- Revenue share by number of albums seen, October 2026 (Oct 1-24 = last full day of data on 2026-10-25).
-- Same base as albums-all-players-2026-10-21.sql (Sept slide 11), only the month changes.
-- Population: active >= 1 day in the window, >= 1 album started by the window end, excluded users removed.
-- Revenue = all in-game purchases in the window. Run 2026-10-25. Results: albums-seen-october-2026-10-25.md

-- Dice (dice-dreams-dbt), 56 GB. Data ends 2026-10-24.
WITH act AS (
  SELECT user_id, COUNT(*) AS act_days, SUM(IFNULL(revenues_sum, 0)) AS rev, MAX(date_dim) AS last_day
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-10-01' AND DATE '2026-10-31'
  GROUP BY 1),
alb AS (
  SELECT user_id, COUNT(DISTINCT album_id) AS n_albums,
    LOGICAL_OR(IFNULL(is_excluded, FALSE)) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2022-01-01' AND DATE '2026-10-31'
    AND user_album_start_date <= DATE '2026-10-31'
  GROUP BY 1)
SELECT CASE
    WHEN b.n_albums = 1 THEN 'a_1' WHEN b.n_albums <= 3 THEN 'b_2-3'
    WHEN b.n_albums <= 6 THEN 'c_4-6' WHEN b.n_albums <= 12 THEN 'd_7-12'
    ELSE 'e_13+' END AS grp,
  COUNT(*) AS players, COUNTIF(a.rev > 0) AS payers, ROUND(SUM(a.rev)) AS rev,
  MAX(a.last_day) AS last_day, MAX(b.n_albums) AS max_albums
FROM act a JOIN alb b USING (user_id)
WHERE NOT b.excl
GROUP BY 1 ORDER BY 1;

-- Domino (domino-dreams-dbt), 57 GB. Cut at 2026-10-24 (table already had part of 10-25).
WITH act AS (
  SELECT user_id,
    SUM(IFNULL(user_daily_inapp_purchase_amount, 0) + IFNULL(user_daily_stripe_amount, 0)) AS rev,
    MAX(date_dim) AS last_day,
    LOGICAL_OR(IFNULL(special_user_flag, FALSE) OR IFNULL(suspected_cheater_flag, FALSE)) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-10-01' AND DATE '2026-10-24'
  GROUP BY 1
  HAVING COUNTIF(sessions_today > 0) > 0),
alb AS (
  SELECT user_id, COUNT(DISTINCT album_id) AS n_albums,
    LOGICAL_OR(IFNULL(special_user_flag, FALSE)) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2022-01-01' AND DATE '2026-10-24'
    AND user_album_start_date <= DATE '2026-10-24'
  GROUP BY 1)
SELECT CASE
    WHEN b.n_albums = 1 THEN 'a_1' WHEN b.n_albums <= 3 THEN 'b_2-3'
    WHEN b.n_albums <= 6 THEN 'c_4-6' WHEN b.n_albums <= 12 THEN 'd_7-12'
    ELSE 'e_13+' END AS grp,
  COUNT(*) AS players, COUNTIF(a.rev > 0) AS payers, ROUND(SUM(a.rev)) AS rev,
  MAX(a.last_day) AS last_day, MAX(b.n_albums) AS max_albums
FROM act a JOIN alb b USING (user_id)
WHERE NOT a.excl AND NOT b.excl
GROUP BY 1 ORDER BY 1;

-- Disney (solitaire-dreams-411507), 54 GB. Data ends 2026-10-24. Albums = lifetime counter user_album_count (as Sept).
WITH act AS (
  SELECT user_id, SUM(IFNULL(gross_revenues, 0)) AS rev, MAX(date_dim) AS last_day,
    LOGICAL_OR(exclude_reason IS NOT NULL) AS excl
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-10-01' AND DATE '2026-10-31'
  GROUP BY 1),
alb AS (
  SELECT user_id, MAX(user_album_count) AS n_albums,
    LOGICAL_OR(IFNULL(special_user_flag, FALSE)) AS excl
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-01-01' AND DATE '2026-10-31'
    AND user_album_start_date <= DATE '2026-10-31'
  GROUP BY 1)
SELECT CASE
    WHEN b.n_albums = 1 THEN 'a_1' WHEN b.n_albums <= 3 THEN 'b_2-3'
    WHEN b.n_albums <= 6 THEN 'c_4-6' WHEN b.n_albums <= 12 THEN 'd_7-12'
    ELSE 'e_13+' END AS grp,
  COUNT(*) AS players, COUNTIF(a.rev > 0) AS payers, ROUND(SUM(a.rev)) AS rev,
  MAX(a.last_day) AS last_day, MAX(b.n_albums) AS max_albums
FROM act a JOIN alb b USING (user_id)
WHERE NOT a.excl AND NOT b.excl AND b.n_albums >= 1
GROUP BY 1 ORDER BY 1;
