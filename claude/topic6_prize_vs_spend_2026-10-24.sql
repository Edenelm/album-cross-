-- Topic 6 / prize (Eden 2026-10-24): "strong players spend a lot relative to what the prize gives them" - is it also true in Domino and Disney?
-- Same population and prize measure as claude/topic6_finisher_prize_2026-10-24.sql (paying finishers, prize in days of the player's own play =
-- album prize / own play per day over the album; Dice rolls, Domino / Disney coins in allowance units). Output: per album x spend level
-- (album $ a day before the last quarter): median $ a day, prize in days (p25 / median / p75), % with prize < 1 day and < 2 days, week after.
-- Albums: Dice 61/63, Domino 19/20, Disney 15 (Disney 14 = 490 GB for both, not run). Results: claude/topic6-prize-vs-spend-2026-10-24.md

-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-05' AND album_id IN (19, 20) GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.album_spent_today,0)) AS rev7, COUNTIF(IFNULL(n.album_spent_today,0) > 0) AS pay_days7
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 1
  WHERE n.date_dim BETWEEN DATE '2026-08-25' AND DATE '2026-10-19' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    u.uniq_end >= 144 AS fin
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
f AS (SELECT * FROM t WHERE fin),
ev AS (
  SELECT user_id, pdate AS d, IFNULL(source,'') AS source, 'in' AS dir, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)) AS units, mp_country_code
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw` WHERE pdate BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND source = 'album completed'
  UNION ALL
  SELECT user_id, pdate, IFNULL(source,''), 'out', SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)), mp_country_code
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw` WHERE pdate BETWEEN DATE '2026-07-06' AND DATE '2026-10-12'),
play AS (
  SELECT f.album_id, f.user_id, SUM(IF(e.dir = 'in', e.units, 0)) AS prize,
    SUM(IF(e.dir = 'out', e.units, 0)) / ANY_VALUE(DATE_DIFF(f.a_end, f.a_start, DAY)) AS out_pd
  FROM f JOIN ev e ON e.user_id = f.user_id AND e.d >= f.a_start AND e.d < f.a_end
  WHERE e.units BETWEEN 0 AND 1000 AND IFNULL(e.mp_country_code,'') NOT IN ('IL','RO')
  GROUP BY 1, 2),
g AS (
  SELECT f.*, p.prize, SAFE_DIVIDE(NULLIF(p.prize, 0), p.out_pd) AS pdays,
    CASE WHEN IFNULL(p.prize, 0) <= 0 OR SAFE_DIVIDE(p.prize, p.out_pd) IS NULL THEN 'z_na' WHEN p.prize / p.out_pd < 2 THEN 'p1_lt2'
         WHEN p.prize / p.out_pd < 4 THEN 'p2_2_4' ELSE 'p3_4plus' END AS pbucket
  FROM f LEFT JOIN play p USING (album_id, user_id)),
agg AS (
  SELECT album_id, tier, alb_rev, pace, pdays, prize, rev7, pay_days7 FROM g WHERE tier != 't0_0'
  UNION ALL SELECT album_id, 'all', alb_rev, pace, pdays, prize, rev7, pay_days7 FROM g WHERE tier != 't0_0')
SELECT a.album_id, tier, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, ROUND(APPROX_QUANTILES(pace, 2)[OFFSET(1)], 1) AS med_usd_day,
  COUNTIF(pdays IS NOT NULL) AS with_prize, ROUND(APPROX_QUANTILES(prize, 2)[OFFSET(1)]) AS med_prize_units,
  ROUND(APPROX_QUANTILES(pdays, 4)[OFFSET(1)], 2) AS p25_days, ROUND(APPROX_QUANTILES(pdays, 4)[OFFSET(2)], 2) AS med_days,
  ROUND(APPROX_QUANTILES(pdays, 4)[OFFSET(3)], 2) AS p75_days,
  ROUND(SAFE_DIVIDE(COUNTIF(pdays < 1), COUNTIF(pdays IS NOT NULL)), 3) AS pct_lt1, ROUND(SAFE_DIVIDE(COUNTIF(pdays < 2), COUNTIF(pdays IS NOT NULL)), 3) AS pct_lt2,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d
FROM agg a JOIN tot USING (album_id) GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DISNEY 15 (solitaire-dreams-411507). Album 15: 08-24..10-05; next 16. Album 14 not run (both albums = 490 GB; 15 only ~250 GB). =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-05' AND album_id = 15 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_close_date) AS a_end FROM `solitaire-dreams-411507.bi_prod.user_daily_album` WHERE date_dim BETWEEN DATE '2026-09-20' AND DATE '2026-10-05' AND album_id = 15 GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.album_spent_today,0)) AS rev7, COUNTIF(IFNULL(n.album_spent_today,0) > 0) AS pay_days7
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 1
  WHERE n.date_dim BETWEEN DATE '2026-10-06' AND DATE '2026-10-12' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    u.uniq_end >= 144 AS fin
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
f AS (SELECT album_id, user_id, a_start, a_end, alb_rev, last7, pace, rev7, pay_days7, tier FROM t WHERE fin),
ev AS (
  SELECT user_id, pdate AS d, 'in' AS dir, SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) AS units, coins_balance_in_allowance AS bal
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_in_vw` WHERE pdate BETWEEN DATE '2026-08-24' AND DATE '2026-10-05' AND source = 'album completed'
  UNION ALL
  SELECT user_id, pdate, 'out', SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)), coins_balance_in_allowance
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_out_vw` WHERE pdate BETWEEN DATE '2026-08-24' AND DATE '2026-10-05'),
play AS (
  SELECT f.album_id, f.user_id, SUM(IF(e.dir = 'in', e.units, 0)) AS prize,
    SUM(IF(e.dir = 'out', e.units, 0)) / ANY_VALUE(DATE_DIFF(f.a_end, f.a_start, DAY)) AS out_pd
  FROM f JOIN ev e ON e.user_id = f.user_id AND e.d >= f.a_start AND e.d < f.a_end
  WHERE e.units BETWEEN 0 AND 1000 AND e.bal BETWEEN 0 AND 5000
  GROUP BY 1, 2),
g AS (
  SELECT f.album_id, f.tier, f.alb_rev, f.last7, f.pace, f.rev7, f.pay_days7, p.prize, SAFE_DIVIDE(NULLIF(p.prize, 0), p.out_pd) AS pdays,
    CASE WHEN IFNULL(p.prize, 0) <= 0 OR SAFE_DIVIDE(p.prize, p.out_pd) IS NULL THEN 'z_na' WHEN p.prize / p.out_pd < 2 THEN 'p1_lt2'
         WHEN p.prize / p.out_pd < 4 THEN 'p2_2_4' ELSE 'p3_4plus' END AS pbucket
  FROM f LEFT JOIN play p USING (album_id, user_id)),
agg AS (
  SELECT album_id, tier, alb_rev, pace, pdays, prize, rev7, pay_days7 FROM g WHERE tier != 't0_0'
  UNION ALL SELECT album_id, 'all', alb_rev, pace, pdays, prize, rev7, pay_days7 FROM g WHERE tier != 't0_0')
SELECT a.album_id, tier, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, ROUND(APPROX_QUANTILES(pace, 2)[OFFSET(1)], 1) AS med_usd_day,
  COUNTIF(pdays IS NOT NULL) AS with_prize, ROUND(APPROX_QUANTILES(prize, 2)[OFFSET(1)]) AS med_prize_units,
  ROUND(APPROX_QUANTILES(pdays, 4)[OFFSET(1)], 2) AS p25_days, ROUND(APPROX_QUANTILES(pdays, 4)[OFFSET(2)], 2) AS med_days,
  ROUND(APPROX_QUANTILES(pdays, 4)[OFFSET(3)], 2) AS p75_days,
  ROUND(SAFE_DIVIDE(COUNTIF(pdays < 1), COUNTIF(pdays IS NOT NULL)), 3) AS pct_lt1, ROUND(SAFE_DIVIDE(COUNTIF(pdays < 2), COUNTIF(pdays IS NOT NULL)), 3) AS pct_lt2,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d
FROM agg a JOIN tot USING (album_id) GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DICE 61/63 (dice-dreams-dbt), next 63/65. Prize = album_reward_value (rolls); play = rolls out (30_intermediate.user_daily_rolls_in_out). =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend, album_reward_value AS r_val
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.r_val, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS r_val,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-09-05' AND album_id IN (61, 63) GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.spent_in_album_today,0)) AS rev7, COUNTIF(IFNULL(n.spent_in_album_today,0) > 0) AS pay_days7
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 2
  WHERE n.date_dim BETWEEN DATE '2026-07-28' AND DATE '2026-09-14' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7, u.r_val,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    u.uniq_end >= 144 AS fin
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
f AS (SELECT album_id, user_id, a_start, a_end, alb_rev, last7, pace, rev7, pay_days7, r_val, tier FROM t WHERE fin),
play AS (
  SELECT f.album_id, f.user_id, SUM(IFNULL(r.rolls_out_sum,0)) / ANY_VALUE(DATE_DIFF(f.a_end, f.a_start, DAY)) AS out_pd
  FROM f JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out` r
    ON r.user_id = f.user_id AND r.date_dim >= f.a_start AND r.date_dim < f.a_end
  WHERE r.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07'
  GROUP BY 1, 2),
g AS (
  SELECT f.album_id, f.tier, f.alb_rev, f.last7, f.pace, f.rev7, f.pay_days7, f.r_val AS prize, SAFE_DIVIDE(NULLIF(f.r_val, 0), p.out_pd) AS pdays,
    CASE WHEN IFNULL(f.r_val, 0) <= 0 OR SAFE_DIVIDE(f.r_val, p.out_pd) IS NULL THEN 'z_na' WHEN f.r_val / p.out_pd < 2 THEN 'p1_lt2'
         WHEN f.r_val / p.out_pd < 4 THEN 'p2_2_4' ELSE 'p3_4plus' END AS pbucket
  FROM f LEFT JOIN play p USING (album_id, user_id)),
agg AS (
  SELECT album_id, tier, alb_rev, pace, pdays, prize, rev7, pay_days7 FROM g WHERE tier != 't0_0'
  UNION ALL SELECT album_id, 'all', alb_rev, pace, pdays, prize, rev7, pay_days7 FROM g WHERE tier != 't0_0')
SELECT a.album_id, tier, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, ROUND(APPROX_QUANTILES(pace, 2)[OFFSET(1)], 1) AS med_usd_day,
  COUNTIF(pdays IS NOT NULL) AS with_prize, ROUND(APPROX_QUANTILES(prize, 2)[OFFSET(1)]) AS med_prize_units,
  ROUND(APPROX_QUANTILES(pdays, 4)[OFFSET(1)], 2) AS p25_days, ROUND(APPROX_QUANTILES(pdays, 4)[OFFSET(2)], 2) AS med_days,
  ROUND(APPROX_QUANTILES(pdays, 4)[OFFSET(3)], 2) AS p75_days,
  ROUND(SAFE_DIVIDE(COUNTIF(pdays < 1), COUNTIF(pdays IS NOT NULL)), 3) AS pct_lt1, ROUND(SAFE_DIVIDE(COUNTIF(pdays < 2), COUNTIF(pdays IS NOT NULL)), 3) AS pct_lt2,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d
FROM agg a JOIN tot USING (album_id) GROUP BY 1, 2 ORDER BY 1, 2;
