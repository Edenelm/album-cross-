-- Tenure population table rerun (Sept 2026) under the install >= 2025-04-01 rule. Run 2026-10-17. Results: tenure-population-rerun-2026-10-17.md

-- Dice (dice-dreams-dbt), 22.5 GB
WITH act AS (
  SELECT user_id, ANY_VALUE(install_date) AS install_date,
    COUNT(*) AS act_days, SUM(IFNULL(revenues_sum, 0)) AS rev,
    COUNTIF(IFNULL(revenues_sum, 0) > 0) AS pay_days
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-09-30'
  GROUP BY 1),
alb AS (
  SELECT user_id, COUNT(DISTINCT album_id) AS n_albums,
    LOGICAL_OR(IFNULL(is_excluded, FALSE)) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-09-30'
    AND user_album_start_date <= DATE '2026-09-30'
  GROUP BY 1)
SELECT CASE
    WHEN a.install_date IS NULL THEN 'unknown_install'
    WHEN a.install_date < DATE '2025-04-01' THEN 'veterans_pre_2025_04'
    WHEN b.n_albums = 1 THEN '1'
    WHEN b.n_albums <= 3 THEN '2-3'
    WHEN b.n_albums <= 6 THEN '4-6'
    ELSE '7+' END AS grp,
  COUNT(*) AS players, COUNTIF(a.rev > 0) AS payers, ROUND(SUM(a.rev)) AS rev,
  SUM(a.act_days) AS act_days, SUM(a.pay_days) AS pay_days
FROM act a JOIN alb b USING (user_id)
WHERE NOT b.excl
GROUP BY 1 ORDER BY 1;

-- Domino (domino-dreams-dbt), 34.3 GB
WITH act AS (
  SELECT user_id, MIN(first_seen_date) AS install_date,
    COUNTIF(sessions_today > 0) AS act_days,
    SUM(IFNULL(user_daily_inapp_purchase_amount, 0) + IFNULL(user_daily_stripe_amount, 0)) AS rev,
    COUNTIF(IFNULL(user_daily_inapp_purchase_amount, 0) + IFNULL(user_daily_stripe_amount, 0) > 0) AS pay_days,
    LOGICAL_OR(IFNULL(special_user_flag, FALSE) OR IFNULL(suspected_cheater_flag, FALSE)) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-09-30'
  GROUP BY 1
  HAVING COUNTIF(sessions_today > 0) > 0),
alb AS (
  SELECT user_id, COUNT(DISTINCT album_id) AS n_albums,
    LOGICAL_OR(IFNULL(special_user_flag, FALSE)) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-09-30'
    AND user_album_start_date <= DATE '2026-09-30'
  GROUP BY 1)
SELECT CASE
    WHEN a.install_date IS NULL THEN 'unknown_install'
    WHEN a.install_date < DATE '2025-04-01' THEN 'veterans_pre_2025_04'
    WHEN b.n_albums = 1 THEN '1'
    WHEN b.n_albums <= 3 THEN '2-3'
    WHEN b.n_albums <= 6 THEN '4-6'
    ELSE '7+' END AS grp,
  COUNT(*) AS players, COUNTIF(a.rev > 0) AS payers, ROUND(SUM(a.rev)) AS rev,
  SUM(a.act_days) AS act_days, SUM(a.pay_days) AS pay_days
FROM act a JOIN alb b USING (user_id)
WHERE NOT a.excl AND NOT b.excl
GROUP BY 1 ORDER BY 1;

