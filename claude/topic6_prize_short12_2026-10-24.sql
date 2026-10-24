-- Topic 6 / prize (Eden 2026-10-24): show the prize in days of own play for players 1-2 stickers short, as for finishers (a6s3).
-- Players 1-2 short did not get the album prize, so this is the prize they MISSED:
--   Dice: album_reward_value (the player's own final-prize value, also set for non-finishers).
--   Domino / Disney: no per-player prize column, so the median 'album completed' prize of FINISHERS in the same album_segment (my choice, flagged).
-- Days of own play = prize / own play per day over the album (Dice rolls bet, Domino / Disney coins spent, allowance units). Paying players, status on close-1.
-- Latest album only (Dice 63, Domino 20, Disney 15), as a6s3. Base: claude/topic6_prize_vs_spend_2026-10-24.sql. Results: claude/topic6-prize-vs-spend-2026-10-24.md

-- ===== DOMINO 20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(album_segment,'') AS seg,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.seg, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS seg,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
t AS (
  SELECT album_id, user_id, a_start, a_end, alb_rev, seg,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 142 THEN 'b_1_2' ELSE 'x' END AS status
  FROM u WHERE ok),
tot AS (SELECT COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t),
f AS (SELECT * FROM t WHERE status != 'x' AND tier != 't0_0'),
ev AS (
  SELECT user_id, pdate AS d, 'in' AS dir, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)) AS units, mp_country_code
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw` WHERE pdate BETWEEN DATE '2026-08-20' AND DATE '2026-10-12' AND source = 'album completed'
  UNION ALL
  SELECT user_id, pdate, 'out', SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)), mp_country_code
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw` WHERE pdate BETWEEN DATE '2026-08-20' AND DATE '2026-10-12'),
play AS (
  SELECT f.user_id, SUM(IF(e.dir = 'in', e.units, 0)) AS prize, SUM(IF(e.dir = 'out', e.units, 0)) / ANY_VALUE(DATE_DIFF(f.a_end, f.a_start, DAY)) AS out_pd
  FROM f JOIN ev e ON e.user_id = f.user_id AND e.d >= f.a_start AND e.d < f.a_end
  WHERE e.units BETWEEN 0 AND 1000 AND IFNULL(e.mp_country_code,'') NOT IN ('IL','RO')
  GROUP BY 1),
segp AS (
  SELECT f.seg, APPROX_QUANTILES(p.prize, 2)[OFFSET(1)] AS seg_prize, COUNT(*) AS seg_n
  FROM f JOIN play p USING (user_id) WHERE f.status = 'a_finished' AND p.prize > 0 GROUP BY 1),
g AS (
  SELECT f.status, f.tier, f.alb_rev, IF(f.status = 'a_finished', NULLIF(p.prize, 0), s.seg_prize) AS prize, p.out_pd
  FROM f LEFT JOIN play p USING (user_id) LEFT JOIN segp s USING (seg)),
agg AS (
  SELECT status, tier, alb_rev, prize, SAFE_DIVIDE(prize, out_pd) AS pdays FROM g
  UNION ALL SELECT status, 'all', alb_rev, prize, SAFE_DIVIDE(prize, out_pd) FROM g)
SELECT status, tier, COUNT(*) AS players, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, COUNTIF(pdays IS NOT NULL) AS with_prize,
  ROUND(APPROX_QUANTILES(prize, 2)[OFFSET(1)]) AS med_prize_units, ROUND(APPROX_QUANTILES(pdays, 2)[OFFSET(1)], 2) AS med_days,
  ROUND(SAFE_DIVIDE(COUNTIF(pdays < 1), COUNTIF(pdays IS NOT NULL)), 3) AS pct_lt1
FROM agg CROSS JOIN tot GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DISNEY 15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(album_segment,'') AS seg,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-05' AND album_id = 15 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.seg, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS seg,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
t AS (
  SELECT album_id, user_id, a_start, a_end, alb_rev, seg,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 142 THEN 'b_1_2' ELSE 'x' END AS status
  FROM u WHERE ok),
tot AS (SELECT COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t),
f AS (SELECT * FROM t WHERE status != 'x' AND tier != 't0_0'),
ev AS (
  SELECT user_id, pdate AS d, 'in' AS dir, SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) AS units, coins_balance_in_allowance AS bal
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_in_vw` WHERE pdate BETWEEN DATE '2026-08-24' AND DATE '2026-10-05' AND source = 'album completed'
  UNION ALL
  SELECT user_id, pdate, 'out', SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)), coins_balance_in_allowance
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_out_vw` WHERE pdate BETWEEN DATE '2026-08-24' AND DATE '2026-10-05'),
play AS (
  SELECT f.user_id, SUM(IF(e.dir = 'in', e.units, 0)) AS prize, SUM(IF(e.dir = 'out', e.units, 0)) / ANY_VALUE(DATE_DIFF(f.a_end, f.a_start, DAY)) AS out_pd
  FROM f JOIN ev e ON e.user_id = f.user_id AND e.d >= f.a_start AND e.d < f.a_end
  WHERE e.units BETWEEN 0 AND 1000 AND e.bal BETWEEN 0 AND 5000
  GROUP BY 1),
segp AS (
  SELECT f.seg, APPROX_QUANTILES(p.prize, 2)[OFFSET(1)] AS seg_prize, COUNT(*) AS seg_n
  FROM f JOIN play p USING (user_id) WHERE f.status = 'a_finished' AND p.prize > 0 GROUP BY 1),
g AS (
  SELECT f.status, f.tier, f.alb_rev, IF(f.status = 'a_finished', NULLIF(p.prize, 0), s.seg_prize) AS prize, p.out_pd
  FROM f LEFT JOIN play p USING (user_id) LEFT JOIN segp s USING (seg)),
agg AS (
  SELECT status, tier, alb_rev, prize, SAFE_DIVIDE(prize, out_pd) AS pdays FROM g
  UNION ALL SELECT status, 'all', alb_rev, prize, SAFE_DIVIDE(prize, out_pd) FROM g)
SELECT status, tier, COUNT(*) AS players, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, COUNTIF(pdays IS NOT NULL) AS with_prize,
  ROUND(APPROX_QUANTILES(prize, 2)[OFFSET(1)]) AS med_prize_units, ROUND(APPROX_QUANTILES(pdays, 2)[OFFSET(1)], 2) AS med_days,
  ROUND(SAFE_DIVIDE(COUNTIF(pdays < 1), COUNTIF(pdays IS NOT NULL)), 3) AS pct_lt1
FROM agg CROSS JOIN tot GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DICE 63 (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend, album_reward_value AS r_val
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.r_val, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS r_val,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < 63 AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
t AS (
  SELECT album_id, user_id, a_start, a_end, alb_rev, r_val,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 142 THEN 'b_1_2' ELSE 'x' END AS status
  FROM u WHERE ok),
tot AS (SELECT COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t),
f AS (SELECT * FROM t WHERE status != 'x' AND tier != 't0_0'),
play AS (
  SELECT f.user_id, SUM(IFNULL(r.rolls_out_sum,0)) / ANY_VALUE(DATE_DIFF(f.a_end, f.a_start, DAY)) AS out_pd
  FROM f JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out` r ON r.user_id = f.user_id AND r.date_dim >= f.a_start AND r.date_dim < f.a_end
  WHERE r.date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-07'
  GROUP BY 1),
g AS (SELECT f.status, f.tier, f.alb_rev, NULLIF(f.r_val, 0) AS prize, p.out_pd FROM f LEFT JOIN play p USING (user_id)),
agg AS (
  SELECT status, tier, alb_rev, prize, SAFE_DIVIDE(prize, out_pd) AS pdays FROM g
  UNION ALL SELECT status, 'all', alb_rev, prize, SAFE_DIVIDE(prize, out_pd) FROM g)
SELECT status, tier, COUNT(*) AS players, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, COUNTIF(pdays IS NOT NULL) AS with_prize,
  ROUND(APPROX_QUANTILES(prize, 2)[OFFSET(1)]) AS med_prize_units, ROUND(APPROX_QUANTILES(pdays, 2)[OFFSET(1)], 2) AS med_days,
  ROUND(SAFE_DIVIDE(COUNTIF(pdays < 1), COUNTIF(pdays IS NOT NULL)), 3) AS pct_lt1
FROM agg CROSS JOIN tot GROUP BY 1, 2 ORDER BY 1, 2;
