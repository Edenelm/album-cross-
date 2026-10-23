-- Topic 5 sensitivity (2026-10-24): is "<=3 missing at close-4" the best cut? Same payer population as topic5_end_lift_2026-10-24.sql.
-- Grid: measure day d = close-2 .. close-7 x threshold k = 0,1,2,3,5,8 missing (status = last row on or before close-d).
-- Per cell: players and revenue share (up to close-d) of the <=k group; end window = close-d .. close-1 (d days, close day out);
--   end lift of the <=k group and of the rest = window ARPDAU / whole-album ARPDAU - 1 (active days); <=k group's share of window revenue.
-- Separation = lift(<=k) - lift(rest). Context (Eden): games lock the last 3 stickers until about 4 days before close.

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
    COUNTIF(a.act AND a.date_dim < a.a_end) AS act_days, SUM(IF(a.act AND a.date_dim < a.a_end, a.spend, 0)) AS act_rev,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
ud_d AS (
  SELECT album_id, user_id, d,
    144 - IFNULL(ARRAY_AGG(IF(date_dim <= DATE_SUB(a_end, INTERVAL d DAY), uniq, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL d DAY), spend, 0)) AS rev_c,
    COUNTIF(act AND date_dim < a_end AND date_dim >= DATE_SUB(a_end, INTERVAL d DAY)) AS wdays,
    SUM(IF(act AND date_dim < a_end AND date_dim >= DATE_SUB(a_end, INTERVAL d DAY), spend, 0)) AS wrev
  FROM ud, UNNEST([2, 3, 4, 5, 6, 7]) AS d GROUP BY 1, 2, 3),
g AS (
  SELECT x.album_id, x.d, k, x.miss <= k AS close, COUNT(*) AS players, SUM(x.rev_c) AS rev_c, SUM(u.act_days) AS act_days,
    SUM(u.act_rev) AS act_rev, SUM(x.wdays) AS wdays, SUM(x.wrev) AS wrev
  FROM ud_d x JOIN u USING (album_id, user_id), UNNEST([0, 1, 2, 3, 5, 8]) AS k WHERE u.ok GROUP BY 1, 2, 3, 4)
SELECT album_id, d, k,
  ROUND(SUM(IF(close, players, 0)) / SUM(players), 3) AS close_players, ROUND(SUM(IF(close, rev_c, 0)) / SUM(rev_c), 3) AS close_rev,
  ROUND(SUM(IF(close, wrev, 0)) / SUM(wrev), 3) AS close_share_end,
  ROUND(SAFE_DIVIDE(SUM(IF(close, wrev, 0)), SUM(IF(close, wdays, 0))) / SAFE_DIVIDE(SUM(IF(close, act_rev, 0)), SUM(IF(close, act_days, 0))) - 1, 3) AS lift_close,
  ROUND(SAFE_DIVIDE(SUM(IF(close, 0, wrev)), SUM(IF(close, 0, wdays))) / SAFE_DIVIDE(SUM(IF(close, 0, act_rev)), SUM(IF(close, 0, act_days))) - 1, 3) AS lift_rest,
  ROUND(SUM(wrev) / SUM(wdays) / (SUM(act_rev) / SUM(act_days)) - 1, 3) AS lift_all
FROM g GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;

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
    COUNTIF(a.act AND a.date_dim < a.a_end) AS act_days, SUM(IF(a.act AND a.date_dim < a.a_end, a.spend, 0)) AS act_rev,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
ud_d AS (
  SELECT album_id, user_id, d,
    144 - IFNULL(ARRAY_AGG(IF(date_dim <= DATE_SUB(a_end, INTERVAL d DAY), uniq, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL d DAY), spend, 0)) AS rev_c,
    COUNTIF(act AND date_dim < a_end AND date_dim >= DATE_SUB(a_end, INTERVAL d DAY)) AS wdays,
    SUM(IF(act AND date_dim < a_end AND date_dim >= DATE_SUB(a_end, INTERVAL d DAY), spend, 0)) AS wrev
  FROM ud, UNNEST([2, 3, 4, 5, 6, 7]) AS d GROUP BY 1, 2, 3),
g AS (
  SELECT x.album_id, x.d, k, x.miss <= k AS close, COUNT(*) AS players, SUM(x.rev_c) AS rev_c, SUM(u.act_days) AS act_days,
    SUM(u.act_rev) AS act_rev, SUM(x.wdays) AS wdays, SUM(x.wrev) AS wrev
  FROM ud_d x JOIN u USING (album_id, user_id), UNNEST([0, 1, 2, 3, 5, 8]) AS k WHERE u.ok GROUP BY 1, 2, 3, 4)
SELECT album_id, d, k,
  ROUND(SUM(IF(close, players, 0)) / SUM(players), 3) AS close_players, ROUND(SUM(IF(close, rev_c, 0)) / SUM(rev_c), 3) AS close_rev,
  ROUND(SUM(IF(close, wrev, 0)) / SUM(wrev), 3) AS close_share_end,
  ROUND(SAFE_DIVIDE(SUM(IF(close, wrev, 0)), SUM(IF(close, wdays, 0))) / SAFE_DIVIDE(SUM(IF(close, act_rev, 0)), SUM(IF(close, act_days, 0))) - 1, 3) AS lift_close,
  ROUND(SAFE_DIVIDE(SUM(IF(close, 0, wrev)), SUM(IF(close, 0, wdays))) / SAFE_DIVIDE(SUM(IF(close, 0, act_rev)), SUM(IF(close, 0, act_days))) - 1, 3) AS lift_rest,
  ROUND(SUM(wrev) / SUM(wdays) / (SUM(act_rev) / SUM(act_days)) - 1, 3) AS lift_all
FROM g GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;

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
    COUNTIF(a.act AND a.date_dim < a.a_end) AS act_days, SUM(IF(a.act AND a.date_dim < a.a_end, a.spend, 0)) AS act_rev,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
ud_d AS (
  SELECT album_id, user_id, d,
    144 - IFNULL(ARRAY_AGG(IF(date_dim <= DATE_SUB(a_end, INTERVAL d DAY), uniq, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL d DAY), spend, 0)) AS rev_c,
    COUNTIF(act AND date_dim < a_end AND date_dim >= DATE_SUB(a_end, INTERVAL d DAY)) AS wdays,
    SUM(IF(act AND date_dim < a_end AND date_dim >= DATE_SUB(a_end, INTERVAL d DAY), spend, 0)) AS wrev
  FROM ud, UNNEST([2, 3, 4, 5, 6, 7]) AS d GROUP BY 1, 2, 3),
g AS (
  SELECT x.album_id, x.d, k, x.miss <= k AS close, COUNT(*) AS players, SUM(x.rev_c) AS rev_c, SUM(u.act_days) AS act_days,
    SUM(u.act_rev) AS act_rev, SUM(x.wdays) AS wdays, SUM(x.wrev) AS wrev
  FROM ud_d x JOIN u USING (album_id, user_id), UNNEST([0, 1, 2, 3, 5, 8]) AS k WHERE u.ok GROUP BY 1, 2, 3, 4)
SELECT album_id, d, k,
  ROUND(SUM(IF(close, players, 0)) / SUM(players), 3) AS close_players, ROUND(SUM(IF(close, rev_c, 0)) / SUM(rev_c), 3) AS close_rev,
  ROUND(SUM(IF(close, wrev, 0)) / SUM(wrev), 3) AS close_share_end,
  ROUND(SAFE_DIVIDE(SUM(IF(close, wrev, 0)), SUM(IF(close, wdays, 0))) / SAFE_DIVIDE(SUM(IF(close, act_rev, 0)), SUM(IF(close, act_days, 0))) - 1, 3) AS lift_close,
  ROUND(SAFE_DIVIDE(SUM(IF(close, 0, wrev)), SUM(IF(close, 0, wdays))) / SAFE_DIVIDE(SUM(IF(close, 0, act_rev)), SUM(IF(close, 0, act_days))) - 1, 3) AS lift_rest,
  ROUND(SUM(wrev) / SUM(wdays) / (SUM(act_rev) / SUM(act_days)) - 1, 3) AS lift_all
FROM g GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;
