-- Eden 2026-10-24: slide proposing a post-album event test for Dice. Who could such an event reach?
-- Payers who finish 2+ days before close (finish date <= close-2) vs the day before close vs not finished, latest album.
-- Population: standard-population payers (same CTEs as claude/gap_by_day_3games_2026-10-24.sql; payer = album spend > 0 up to close-1).
-- Finish date = first day with 144 unique set stickers in the daily album table (close day not in the table window; close-day finishers sit in 'not finished' here).
-- Revenue = album-table spend from album start to close-1. Results: claude/early-finishers-event-2026-10-24.md

-- ===== DISNEY 15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-05' AND album_id = 15 AND date_dim < album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
u AS (
  SELECT a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    ARRAY_AGG(a.uniq ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MIN(IF(a.uniq >= 144, a.date_dim, NULL)) AS fin_date, SUM(a.spend) AS rev,
    MAX(a.date_dim) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(a.lr ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(a.uac ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1),
s AS (SELECT user_id, rev, CASE WHEN uniq_end < 144 THEN 'not finished'
    WHEN fin_date <= DATE_SUB(a_end, INTERVAL 2 DAY) THEN 'finished 2+ days before close'
    ELSE 'finished the day before close' END AS grp FROM u WHERE ok)
SELECT grp, COUNT(1) AS payers, ROUND(100 * COUNT(1) / SUM(COUNT(1)) OVER (), 1) AS pct_payers,
  ROUND(SUM(rev)) AS album_rev, ROUND(100 * SUM(rev) / SUM(SUM(rev)) OVER (), 1) AS pct_album_rev
FROM s GROUP BY 1 ORDER BY 1;

-- ===== DOMINO 20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim < album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    ARRAY_AGG(a.uniq ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MIN(IF(a.uniq >= 144, a.date_dim, NULL)) AS fin_date, SUM(a.spend) AS rev,
    MAX(a.date_dim) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(a.lr ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(a.uac ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1),
s AS (SELECT user_id, rev, CASE WHEN uniq_end < 144 THEN 'not finished'
    WHEN fin_date <= DATE_SUB(a_end, INTERVAL 2 DAY) THEN 'finished 2+ days before close'
    ELSE 'finished the day before close' END AS grp FROM u WHERE ok)
SELECT grp, COUNT(1) AS payers, ROUND(100 * COUNT(1) / SUM(COUNT(1)) OVER (), 1) AS pct_payers,
  ROUND(SUM(rev)) AS album_rev, ROUND(100 * SUM(rev) / SUM(SUM(rev)) OVER (), 1) AS pct_album_rev
FROM s GROUP BY 1 ORDER BY 1;

-- ===== DICE 63 (dice-dreams-dbt) =====
WITH hist AS (SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND album_id = 63 AND date_dim < album_end_date),
u AS (
  SELECT a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    ARRAY_AGG(a.uniq ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MIN(IF(a.uniq >= 144, a.date_dim, NULL)) AS fin_date, SUM(a.spend) AS rev,
    MAX(a.date_dim) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(a.lr ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < 63 AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1),
s AS (SELECT user_id, rev, CASE WHEN uniq_end < 144 THEN 'not finished'
    WHEN fin_date <= DATE_SUB(a_end, INTERVAL 2 DAY) THEN 'finished 2+ days before close'
    ELSE 'finished the day before close' END AS grp FROM u WHERE ok)
SELECT grp, COUNT(1) AS payers, ROUND(100 * COUNT(1) / SUM(COUNT(1)) OVER (), 1) AS pct_payers,
  ROUND(SUM(rev)) AS album_rev, ROUND(100 * SUM(rev) / SUM(SUM(rev)) OVER (), 1) AS pct_album_rev
FROM s GROUP BY 1 ORDER BY 1;
