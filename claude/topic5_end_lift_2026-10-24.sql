-- Topic 5 end lift on the topic-5 payer population (2026-10-24). Albums Dice 61/63, Domino 19/20, Disney 14/15.
-- Eden: show the change 61->63 / 19->20 / 14->15: the end was stronger in revenue, and more payers close at close-4 goes with a stronger end.
-- Population: standard-population payers, exactly as claude/topic5_tiers_2026-10-23.sql.
-- Reach = <=3 missing at close-4 (last row on or before close-4); rev_c4 = revenue up to close-4 (reach share = reach rev_c4 / all rev_c4).
-- End lift = last-4-days ARPDAU (close-4 .. close-1) / whole-album ARPDAU - 1; active days only (game active flag, from
--   user_album_start_date), close day excluded (as end_lift_by_experience_full_history.sql). Rows: all / reach / far.

-- ===== DISNEY 14/15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    IFNULL(active_flag,FALSE) AND date_dim >= user_album_start_date AS act
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.spend, 0)) AS rev_c4,
    COUNTIF(a.act AND a.date_dim < a.a_end) AS act_days, SUM(IF(a.act AND a.date_dim < a.a_end, a.spend, 0)) AS act_rev,
    COUNTIF(a.act AND a.date_dim < a.a_end AND a.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY)) AS act_days_l4,
    SUM(IF(a.act AND a.date_dim < a.a_end AND a.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.spend, 0)) AS act_rev_l4,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c4,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
t AS (SELECT album_id, user_id, alb_rev, rev_c4, act_days, act_rev, act_days_l4, act_rev_l4,
    IF(miss_c4 <= 3, 'reach', 'far') AS grp FROM u WHERE ok)
SELECT album_id, IFNULL(grp, 'all') AS grp, COUNT(*) AS players, ROUND(SUM(alb_rev)) AS album_rev, ROUND(SUM(rev_c4)) AS rev_c4,
  SUM(act_days) AS act_days, ROUND(SUM(act_rev) / SUM(act_days), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(act_rev_l4), SUM(act_days_l4)), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(act_rev_l4), SUM(act_days_l4)), SUM(act_rev) / SUM(act_days)) - 1, 3) AS end_lift,
  ROUND(SUM(act_rev_l4)) AS rev_last4
FROM t GROUP BY ROLLUP (album_id, grp) HAVING album_id IS NOT NULL ORDER BY 1, 2;

-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    IFNULL(active_flag,FALSE) AND date_dim >= user_album_start_date AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.spend, 0)) AS rev_c4,
    COUNTIF(a.act AND a.date_dim < a.a_end) AS act_days, SUM(IF(a.act AND a.date_dim < a.a_end, a.spend, 0)) AS act_rev,
    COUNTIF(a.act AND a.date_dim < a.a_end AND a.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY)) AS act_days_l4,
    SUM(IF(a.act AND a.date_dim < a.a_end AND a.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.spend, 0)) AS act_rev_l4,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c4,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
t AS (SELECT album_id, user_id, alb_rev, rev_c4, act_days, act_rev, act_days_l4, act_rev_l4,
    IF(miss_c4 <= 3, 'reach', 'far') AS grp FROM u WHERE ok)
SELECT album_id, IFNULL(grp, 'all') AS grp, COUNT(*) AS players, ROUND(SUM(alb_rev)) AS album_rev, ROUND(SUM(rev_c4)) AS rev_c4,
  SUM(act_days) AS act_days, ROUND(SUM(act_rev) / SUM(act_days), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(act_rev_l4), SUM(act_days_l4)), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(act_rev_l4), SUM(act_days_l4)), SUM(act_rev) / SUM(act_days)) - 1, 3) AS end_lift,
  ROUND(SUM(act_rev_l4)) AS rev_last4
FROM t GROUP BY ROLLUP (album_id, grp) HAVING album_id IS NOT NULL ORDER BY 1, 2;

-- ===== DICE 61/63 (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend,
    IFNULL(is_active,FALSE) AND date_dim >= user_album_start_date AS act
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.spend, 0)) AS rev_c4,
    COUNTIF(a.act AND a.date_dim < a.a_end) AS act_days, SUM(IF(a.act AND a.date_dim < a.a_end, a.spend, 0)) AS act_rev,
    COUNTIF(a.act AND a.date_dim < a.a_end AND a.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY)) AS act_days_l4,
    SUM(IF(a.act AND a.date_dim < a.a_end AND a.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.spend, 0)) AS act_rev_l4,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c4,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
t AS (SELECT album_id, user_id, alb_rev, rev_c4, act_days, act_rev, act_days_l4, act_rev_l4,
    IF(miss_c4 <= 3, 'reach', 'far') AS grp FROM u WHERE ok)
SELECT album_id, IFNULL(grp, 'all') AS grp, COUNT(*) AS players, ROUND(SUM(alb_rev)) AS album_rev, ROUND(SUM(rev_c4)) AS rev_c4,
  SUM(act_days) AS act_days, ROUND(SUM(act_rev) / SUM(act_days), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(act_rev_l4), SUM(act_days_l4)), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(act_rev_l4), SUM(act_days_l4)), SUM(act_rev) / SUM(act_days)) - 1, 3) AS end_lift,
  ROUND(SUM(act_rev_l4)) AS rev_last4
FROM t GROUP BY ROLLUP (album_id, grp) HAVING album_id IS NOT NULL ORDER BY 1, 2;
