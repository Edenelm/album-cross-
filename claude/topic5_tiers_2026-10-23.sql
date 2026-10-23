-- Topic 5 split (Eden 2026-10-23: split by the 5 tiers, goal = revenue share at <=3 missing at close-4).
-- Population: standard-population payers (as topic5_left_behind). Albums Dice 61/63, Domino 19/20, Disney 14/15.
-- Tier = album spend per day so far at the start of the last quarter (days 0 .. ceil(0.75 n)-1), cuts 0 / <=2 / 2-5 / 5-20 / >20 $ a day
--   (my proxy for the projected tier: spend pace is near-linear). Reach = <=3 missing at close-4 (last row on or before close-4).
-- Revenue: album revenue before close (share of all payers'), and revenue up to close-4 (goal metric basis).
-- End status on close-1: finished / 1-3 missing / 4+ missing.

-- ===== DISNEY 14/15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    SUM(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.spend, 0)) AS rev_c4,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c4,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
t AS (
  SELECT album_id, user_id, alb_rev, rev_c4, miss_c4, uniq_end,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier
  FROM u WHERE ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1)
SELECT t.album_id, tier, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev)) AS album_rev, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(AVG(IF(miss_c4 <= 3, 1, 0)), 3) AS reach_players, ROUND(SAFE_DIVIDE(SUM(IF(miss_c4 <= 3, rev_c4, 0)), SUM(rev_c4)), 3) AS reach_rev_share,
  ROUND(AVG(IF(uniq_end >= 144, 1, 0)), 3) AS finished, ROUND(AVG(IF(uniq_end BETWEEN 141 AND 143, 1, 0)), 3) AS near_1_3,
  ROUND(AVG(IF(uniq_end <= 140, 1, 0)), 3) AS far_4plus,
  COUNTIF(uniq_end <= 140) AS far_players, ROUND(SUM(IF(uniq_end <= 140, alb_rev, 0))) AS far_rev,
  ROUND(SUM(IF(uniq_end <= 140, alb_rev, 0)) / ANY_VALUE(rev_all), 4) AS far_share_rev
FROM t JOIN tot USING (album_id) GROUP BY 1,2 ORDER BY 1,2;

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
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    SUM(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.spend, 0)) AS rev_c4,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c4,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
t AS (
  SELECT album_id, user_id, alb_rev, rev_c4, miss_c4, uniq_end,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier
  FROM u WHERE ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1)
SELECT t.album_id, tier, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev)) AS album_rev, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(AVG(IF(miss_c4 <= 3, 1, 0)), 3) AS reach_players, ROUND(SAFE_DIVIDE(SUM(IF(miss_c4 <= 3, rev_c4, 0)), SUM(rev_c4)), 3) AS reach_rev_share,
  ROUND(AVG(IF(uniq_end >= 144, 1, 0)), 3) AS finished, ROUND(AVG(IF(uniq_end BETWEEN 141 AND 143, 1, 0)), 3) AS near_1_3,
  ROUND(AVG(IF(uniq_end <= 140, 1, 0)), 3) AS far_4plus,
  COUNTIF(uniq_end <= 140) AS far_players, ROUND(SUM(IF(uniq_end <= 140, alb_rev, 0))) AS far_rev,
  ROUND(SUM(IF(uniq_end <= 140, alb_rev, 0)) / ANY_VALUE(rev_all), 4) AS far_share_rev
FROM t JOIN tot USING (album_id) GROUP BY 1,2 ORDER BY 1,2;

-- ===== DICE 61/63 (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    SUM(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.spend, 0)) AS rev_c4,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c4,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
t AS (
  SELECT album_id, user_id, alb_rev, rev_c4, miss_c4, uniq_end,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier
  FROM u WHERE ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1)
SELECT t.album_id, tier, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev)) AS album_rev, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(AVG(IF(miss_c4 <= 3, 1, 0)), 3) AS reach_players, ROUND(SAFE_DIVIDE(SUM(IF(miss_c4 <= 3, rev_c4, 0)), SUM(rev_c4)), 3) AS reach_rev_share,
  ROUND(AVG(IF(uniq_end >= 144, 1, 0)), 3) AS finished, ROUND(AVG(IF(uniq_end BETWEEN 141 AND 143, 1, 0)), 3) AS near_1_3,
  ROUND(AVG(IF(uniq_end <= 140, 1, 0)), 3) AS far_4plus,
  COUNTIF(uniq_end <= 140) AS far_players, ROUND(SUM(IF(uniq_end <= 140, alb_rev, 0))) AS far_rev,
  ROUND(SUM(IF(uniq_end <= 140, alb_rev, 0)) / ANY_VALUE(rev_all), 4) AS far_share_rev
FROM t JOIN tot USING (album_id) GROUP BY 1,2 ORDER BY 1,2;
