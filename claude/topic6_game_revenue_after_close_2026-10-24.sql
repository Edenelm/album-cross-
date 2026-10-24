-- Topic 6 (Eden 2026-10-24): total game revenue after the album closes vs the last month, three games. Is Dice the best after close?
-- Game revenue = deck-wide definition (claude/game_revenue_rebase_queries.sql): all players' purchase revenue from daily metrics, excluded users out
--   (Dice 20_core.dim_excluded_users; Domino special_user_flag / suspected_cheater_flag; Disney exclude_reason).
-- Base = average revenue a day close-30..close-1 (close day left out, half day). Compared: close-7..-1 (last week), close day, days 1-3, days 1-7 after close.
-- Albums: Dice 61/63, Domino 19/20, Disney 14/15. Close date = album table close/end date. Results: claude/topic6-game-revenue-after-close-2026-10-24.md

-- ===== DICE (dice-dreams-dbt) =====
WITH cl AS (
  SELECT album_id, MIN(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61, 63) GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
d AS (
  SELECT date_dim, SUM(IFNULL(revenues_sum,0)) AS rev FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-14' AND user_id NOT IN (SELECT user_id FROM excl) GROUP BY 1),
x AS (SELECT c.album_id, c.a_end, DATE_DIFF(d.date_dim, c.a_end, DAY) AS k, d.rev FROM cl c JOIN d ON DATE_DIFF(d.date_dim, c.a_end, DAY) BETWEEN -30 AND 7)
SELECT album_id, ANY_VALUE(a_end) AS close_date, ROUND(AVG(IF(k BETWEEN -30 AND -1, rev, NULL))) AS base_30d,
  ROUND(AVG(IF(k BETWEEN -7 AND -1, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS last7_vs_base,
  ROUND(AVG(IF(k = 0, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS close_day_vs_base,
  ROUND(AVG(IF(k BETWEEN 1 AND 3, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS d1_3_vs_base,
  ROUND(AVG(IF(k BETWEEN 1 AND 7, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS d1_7_vs_base,
  COUNTIF(k BETWEEN 1 AND 7) AS days_after_in_data
FROM x GROUP BY 1 ORDER BY 1;

-- ===== DOMINO (domino-dreams-dbt) =====
WITH cl AS (
  SELECT album_id, MIN(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (19, 20) GROUP BY 1),
m AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(special_user_flag,FALSE) OR IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-19'),
bad_users AS (SELECT DISTINCT user_id FROM m WHERE bad),
d AS (SELECT date_dim, SUM(rev) AS rev FROM m WHERE user_id NOT IN (SELECT user_id FROM bad_users) GROUP BY 1),
x AS (SELECT c.album_id, c.a_end, DATE_DIFF(d.date_dim, c.a_end, DAY) AS k, d.rev FROM cl c JOIN d ON DATE_DIFF(d.date_dim, c.a_end, DAY) BETWEEN -30 AND 7)
SELECT album_id, ANY_VALUE(a_end) AS close_date, ROUND(AVG(IF(k BETWEEN -30 AND -1, rev, NULL))) AS base_30d,
  ROUND(AVG(IF(k BETWEEN -7 AND -1, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS last7_vs_base,
  ROUND(AVG(IF(k = 0, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS close_day_vs_base,
  ROUND(AVG(IF(k BETWEEN 1 AND 3, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS d1_3_vs_base,
  ROUND(AVG(IF(k BETWEEN 1 AND 7, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS d1_7_vs_base,
  COUNTIF(k BETWEEN 1 AND 7) AS days_after_in_data
FROM x GROUP BY 1 ORDER BY 1;

-- ===== DISNEY (solitaire-dreams-411507) =====
WITH cl AS (
  SELECT album_id, MIN(album_close_date) AS a_end FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-05' AND album_id IN (14, 15) GROUP BY 1),
m AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-10-12'),
bad_users AS (SELECT DISTINCT user_id FROM m WHERE bad),
d AS (SELECT date_dim, SUM(rev) AS rev FROM m WHERE user_id NOT IN (SELECT user_id FROM bad_users) GROUP BY 1),
x AS (SELECT c.album_id, c.a_end, DATE_DIFF(d.date_dim, c.a_end, DAY) AS k, d.rev FROM cl c JOIN d ON DATE_DIFF(d.date_dim, c.a_end, DAY) BETWEEN -30 AND 7)
SELECT album_id, ANY_VALUE(a_end) AS close_date, ROUND(AVG(IF(k BETWEEN -30 AND -1, rev, NULL))) AS base_30d,
  ROUND(AVG(IF(k BETWEEN -7 AND -1, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS last7_vs_base,
  ROUND(AVG(IF(k = 0, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS close_day_vs_base,
  ROUND(AVG(IF(k BETWEEN 1 AND 3, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS d1_3_vs_base,
  ROUND(AVG(IF(k BETWEEN 1 AND 7, rev, NULL)) / AVG(IF(k BETWEEN -30 AND -1, rev, NULL)), 3) AS d1_7_vs_base,
  COUNTIF(k BETWEEN 1 AND 7) AS days_after_in_data
FROM x GROUP BY 1 ORDER BY 1;
