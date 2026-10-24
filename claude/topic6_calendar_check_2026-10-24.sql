-- Topic 6 (Eden 2026-10-24): Domino 19 and Disney 14 look like Dice 63 on tg1 — same case? Calendar check.
-- Same measure as tg1 (total game revenue, days 1-7 after a date / average day of the 30 days before), but at EVERY game's close dates
-- (2026-07-27 Dice 61, 08-24 Domino 19 + Disney 14, 09-07 Dice 63, 10-05 Disney 15, 10-12 Domino 20), in all three games.
-- If a game dips after a date when it had NO album close, the dip is the calendar, not the album end.
-- Results: claude/topic6-game-revenue-after-close-2026-10-24.md (calendar section)

-- ===== DICE (dice-dreams-dbt) =====
WITH a AS (SELECT dt FROM UNNEST([DATE '2026-07-27', DATE '2026-08-24', DATE '2026-09-07', DATE '2026-10-05', DATE '2026-10-12']) dt),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
d AS (SELECT date_dim, SUM(IFNULL(revenues_sum,0)) AS rev FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-27' AND DATE '2026-10-19' AND user_id NOT IN (SELECT user_id FROM excl) GROUP BY 1)
SELECT a.dt, ROUND(AVG(IF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN -30 AND -1, d.rev, NULL))) AS base_30d,
  ROUND(AVG(IF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN 1 AND 7, d.rev, NULL)) / AVG(IF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN -30 AND -1, d.rev, NULL)), 3) AS d1_7_vs_base,
  COUNTIF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN 1 AND 7) AS days_after
FROM a JOIN d ON DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN -30 AND 7 GROUP BY 1 ORDER BY 1;

-- ===== DOMINO (domino-dreams-dbt) =====
WITH a AS (SELECT dt FROM UNNEST([DATE '2026-07-27', DATE '2026-08-24', DATE '2026-09-07', DATE '2026-10-05', DATE '2026-10-12']) dt),
m AS (SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(special_user_flag,FALSE) OR IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-06-27' AND DATE '2026-10-19'),
bad_users AS (SELECT DISTINCT user_id FROM m WHERE bad),
d AS (SELECT date_dim, SUM(rev) AS rev FROM m WHERE user_id NOT IN (SELECT user_id FROM bad_users) GROUP BY 1)
SELECT a.dt, ROUND(AVG(IF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN -30 AND -1, d.rev, NULL))) AS base_30d,
  ROUND(AVG(IF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN 1 AND 7, d.rev, NULL)) / AVG(IF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN -30 AND -1, d.rev, NULL)), 3) AS d1_7_vs_base,
  COUNTIF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN 1 AND 7) AS days_after
FROM a JOIN d ON DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN -30 AND 7 GROUP BY 1 ORDER BY 1;

-- ===== DISNEY (solitaire-dreams-411507) =====
WITH a AS (SELECT dt FROM UNNEST([DATE '2026-07-27', DATE '2026-08-24', DATE '2026-09-07', DATE '2026-10-05', DATE '2026-10-12']) dt),
m AS (SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-06-27' AND DATE '2026-10-19'),
bad_users AS (SELECT DISTINCT user_id FROM m WHERE bad),
d AS (SELECT date_dim, SUM(rev) AS rev FROM m WHERE user_id NOT IN (SELECT user_id FROM bad_users) GROUP BY 1)
SELECT a.dt, ROUND(AVG(IF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN -30 AND -1, d.rev, NULL))) AS base_30d,
  ROUND(AVG(IF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN 1 AND 7, d.rev, NULL)) / AVG(IF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN -30 AND -1, d.rev, NULL)), 3) AS d1_7_vs_base,
  COUNTIF(DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN 1 AND 7) AS days_after
FROM a JOIN d ON DATE_DIFF(d.date_dim, a.dt, DAY) BETWEEN -30 AND 7 GROUP BY 1 ORDER BY 1;
