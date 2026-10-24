-- Topic 6 stock check (Eden approved 2026-10-24): balance at the end of the close day in days of the player's own play.
-- Days of stock = balance at the end of the close day / own play per day close-18..-5 (14 calendar days, as point 1 used calendar days).
-- Also: / own play per day the player played in close-18..-5 (active-day reading), shown next to it.
-- Population, status (on close-1: a_finished / b_1_2 / c_3 / d_4plus) and levels (all paying, $2-20 a day) exactly as claude/topic6_payout_by_status_2026-10-24.sql.
-- Latest album: Dice 63 (close 2026-09-07), Domino 20 (close 2026-10-12), Disney 15 (close 2026-10-05).
-- Sources (Eden 2026-10-24):
--   Dice   play = 30_intermediate.user_daily_rolls_in_out.rolls_out_sum. Balance: that table has no end-of-day balance (only max/min),
--          so the end balance = rolls_balance of the player's last event (in or out) on the close day, 20_core.rolls_in_out_vw (its source layer).
--          The 1.2M-balance cohort (rolls_max > 1.2M) is left out, as in the payout check; counted separately.
--   Domino balance = prod_30_intermediate.int_rv_user_daily_coins_balance.coins_balance_in_allowance_end_day; play = int_rv_user_daily_coins_spent.spent_in_allowance (all coins out).
--   Disney balance = bi_prod.solitaire_user_daily_metrics_agg_df.coins_allowance_enday, which is already the balance in allowance units
--          (checked 2026-10-05: its median 3.4 = Mixpanel coins_balance_in_allowance 3.6; enday_coins_balance / it = raw allowance, not the balance. First run divided them -> 178 days, wrong);
--          play = mp_raw_prod_vw.mp_coins_out_vw level start + extra tiles / undo / wild / trade, allowance units (filters units 0..1000, balance 0..5000, as the payout check).
-- Balance = last value on or before the close day (close-3 .. close) for players with no event on the close day.
-- Results: claude/topic6-stock-by-status-2026-10-24.md

-- ===== DICE 63 (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date),
u AS (
  SELECT a.user_id, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < 63 AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1),
t AS (
  SELECT user_id, a_end, alb_rev,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 142 THEN 'b_1_2' WHEN uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status
  FROM u WHERE ok),
tot AS (SELECT COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t),
ro AS (
  SELECT user_id, date_dim AS d, IFNULL(rolls_out_sum,0) AS play, IFNULL(rolls_max,0) AS bal_max
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
  WHERE date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-09-10'),
bigbal AS (SELECT DISTINCT user_id FROM ro WHERE bal_max > 1200000),
pl AS (
  SELECT t.user_id, SUM(r.play) / 14 AS play_pd, SAFE_DIVIDE(SUM(r.play), COUNTIF(r.play > 0)) AS play_pad
  FROM t JOIN ro r ON r.user_id = t.user_id AND r.d BETWEEN DATE_SUB(t.a_end, INTERVAL 18 DAY) AND DATE_SUB(t.a_end, INTERVAL 5 DAY)
  GROUP BY 1),
bl AS (
  SELECT user_id, ARRAY_AGG(rolls_balance IGNORE NULLS ORDER BY timestamp DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal
  FROM `dice-dreams-dbt.20_core.rolls_in_out_vw`
  WHERE pdate BETWEEN DATE '2026-09-03' AND DATE '2026-09-08' AND date_dim BETWEEN DATE '2026-09-04' AND DATE '2026-09-07'
  GROUP BY 1),
g AS (
  SELECT t.status, t.tier, t.alb_rev, b.bal, SAFE_DIVIDE(b.bal, p.play_pd) AS dys, SAFE_DIVIDE(b.bal, p.play_pad) AS dys_act, x.user_id IS NOT NULL AS big
  FROM t LEFT JOIN pl p USING (user_id) LEFT JOIN bl b USING (user_id) LEFT JOIN bigbal x USING (user_id)),
agg AS (
  SELECT status, 'all' AS lvl, alb_rev, bal, dys, dys_act, big FROM g WHERE tier != 't0_0'
  UNION ALL SELECT status, 'l2_20', alb_rev, bal, dys, dys_act, big FROM g WHERE tier IN ('t2_2_5','t3_5_20'))
SELECT status, lvl, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  COUNTIF(big) AS big_bal_left_out, COUNTIF(NOT big AND dys IS NOT NULL) AS players_measured,
  ROUND(APPROX_QUANTILES(IF(NOT big, bal, NULL), 2)[OFFSET(1)]) AS med_bal_units,
  ROUND(APPROX_QUANTILES(IF(NOT big, dys, NULL), 4)[OFFSET(1)], 2) AS p25_days,
  ROUND(APPROX_QUANTILES(IF(NOT big, dys, NULL), 4)[OFFSET(2)], 2) AS med_days,
  ROUND(APPROX_QUANTILES(IF(NOT big, dys, NULL), 4)[OFFSET(3)], 2) AS p75_days,
  ROUND(APPROX_QUANTILES(IF(NOT big, dys_act, NULL), 4)[OFFSET(2)], 2) AS med_days_active,
  ROUND(SAFE_DIVIDE(COUNTIF(NOT big AND dys >= 2), COUNTIF(NOT big AND dys IS NOT NULL)), 3) AS pct_2plus,
  ROUND(SAFE_DIVIDE(COUNTIF(NOT big AND dys >= 4), COUNTIF(NOT big AND dys IS NOT NULL)), 3) AS pct_4plus
FROM agg CROSS JOIN tot GROUP BY 1, 2 ORDER BY 2, 1;

-- ===== DOMINO 20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.user_id, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1),
t AS (
  SELECT user_id, a_end, alb_rev,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 142 THEN 'b_1_2' WHEN uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status
  FROM u WHERE ok),
tot AS (SELECT COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t),
pl AS (
  SELECT t.user_id, SUM(IFNULL(s.spent_in_allowance,0)) / 14 AS play_pd,
    SAFE_DIVIDE(SUM(IFNULL(s.spent_in_allowance,0)), COUNTIF(s.spent_in_allowance > 0)) AS play_pad
  FROM t JOIN `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_spent` s
    ON s.user_id = t.user_id AND s.date_dim BETWEEN DATE_SUB(t.a_end, INTERVAL 18 DAY) AND DATE_SUB(t.a_end, INTERVAL 5 DAY)
  WHERE s.date_dim BETWEEN DATE '2026-09-24' AND DATE '2026-10-07'
  GROUP BY 1),
bl AS (
  SELECT user_id, ARRAY_AGG(coins_balance_in_allowance_end_day IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal
  FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_balance`
  WHERE date_dim BETWEEN DATE '2026-10-09' AND DATE '2026-10-12'
  GROUP BY 1),
g AS (
  SELECT t.status, t.tier, t.alb_rev, b.bal, SAFE_DIVIDE(b.bal, p.play_pd) AS dys, SAFE_DIVIDE(b.bal, p.play_pad) AS dys_act
  FROM t LEFT JOIN pl p USING (user_id) LEFT JOIN bl b USING (user_id)),
agg AS (
  SELECT status, 'all' AS lvl, alb_rev, bal, dys, dys_act FROM g WHERE tier != 't0_0'
  UNION ALL SELECT status, 'l2_20', alb_rev, bal, dys, dys_act FROM g WHERE tier IN ('t2_2_5','t3_5_20'))
SELECT status, lvl, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  COUNTIF(dys IS NOT NULL) AS players_measured,
  ROUND(APPROX_QUANTILES(bal, 2)[OFFSET(1)], 1) AS med_bal_units,
  ROUND(APPROX_QUANTILES(dys, 4)[OFFSET(1)], 2) AS p25_days,
  ROUND(APPROX_QUANTILES(dys, 4)[OFFSET(2)], 2) AS med_days,
  ROUND(APPROX_QUANTILES(dys, 4)[OFFSET(3)], 2) AS p75_days,
  ROUND(APPROX_QUANTILES(dys_act, 4)[OFFSET(2)], 2) AS med_days_active,
  ROUND(SAFE_DIVIDE(COUNTIF(dys >= 2), COUNTIF(dys IS NOT NULL)), 3) AS pct_2plus,
  ROUND(SAFE_DIVIDE(COUNTIF(dys >= 4), COUNTIF(dys IS NOT NULL)), 3) AS pct_4plus
FROM agg CROSS JOIN tot GROUP BY 1, 2 ORDER BY 2, 1;

-- ===== DISNEY 15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id = 15 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT a.user_id, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1),
t AS (
  SELECT user_id, a_end, alb_rev,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 142 THEN 'b_1_2' WHEN uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status
  FROM u WHERE ok),
tot AS (SELECT COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t),
co AS (
  SELECT user_id, pdate AS d, SUM(SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64))) AS play
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-09-17' AND DATE '2026-09-30'
    AND source IN ('level start','extra tiles','undo','wild','trade')
    AND SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) BETWEEN 0 AND 1000 AND coins_balance_in_allowance BETWEEN 0 AND 5000
  GROUP BY 1, 2),
pl AS (
  SELECT t.user_id, SUM(c.play) / 14 AS play_pd, SAFE_DIVIDE(SUM(c.play), COUNTIF(c.play > 0)) AS play_pad
  FROM t JOIN co c ON c.user_id = t.user_id AND c.d BETWEEN DATE_SUB(t.a_end, INTERVAL 18 DAY) AND DATE_SUB(t.a_end, INTERVAL 5 DAY)
  GROUP BY 1),
bl AS (
  SELECT user_id, ARRAY_AGG(coins_allowance_enday IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-10-02' AND DATE '2026-10-05'
  GROUP BY 1),
g AS (
  SELECT t.status, t.tier, t.alb_rev, b.bal, SAFE_DIVIDE(b.bal, p.play_pd) AS dys, SAFE_DIVIDE(b.bal, p.play_pad) AS dys_act
  FROM t LEFT JOIN pl p USING (user_id) LEFT JOIN bl b USING (user_id)),
agg AS (
  SELECT status, 'all' AS lvl, alb_rev, bal, dys, dys_act FROM g WHERE tier != 't0_0'
  UNION ALL SELECT status, 'l2_20', alb_rev, bal, dys, dys_act FROM g WHERE tier IN ('t2_2_5','t3_5_20'))
SELECT status, lvl, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  COUNTIF(dys IS NOT NULL) AS players_measured,
  ROUND(APPROX_QUANTILES(bal, 2)[OFFSET(1)], 1) AS med_bal_units,
  ROUND(APPROX_QUANTILES(dys, 4)[OFFSET(1)], 2) AS p25_days,
  ROUND(APPROX_QUANTILES(dys, 4)[OFFSET(2)], 2) AS med_days,
  ROUND(APPROX_QUANTILES(dys, 4)[OFFSET(3)], 2) AS p75_days,
  ROUND(APPROX_QUANTILES(dys_act, 4)[OFFSET(2)], 2) AS med_days_active,
  ROUND(SAFE_DIVIDE(COUNTIF(dys >= 2), COUNTIF(dys IS NOT NULL)), 3) AS pct_2plus,
  ROUND(SAFE_DIVIDE(COUNTIF(dys >= 4), COUNTIF(dys IS NOT NULL)), 3) AS pct_4plus
FROM agg CROSS JOIN tot GROUP BY 1, 2 ORDER BY 2, 1;
