-- Eden 2026-10-24: is the Disney 15 pattern (payers who end 4+ away fall behind finishers gradually) a Disney release-design effect?
-- Same measure in all three games, latest album: mean unique set stickers per album day, finishers vs payers who end 4+ away
-- (standard-population payers, status on close-1). Album day = date - open + 1; also % of album to compare albums of different length.
-- Dice 63 (2026-07-27..09-07), Domino 20 (2026-08-24..10-12), Disney 15 (2026-08-24..10-05). Results: claude/gap-by-day-3games-2026-10-24.md
-- One section per game; the shared logic: u = per player status and payer flag; d = daily unique stickers; output = mean by day and status.

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
    MAX(a.date_dim) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(a.lr ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(a.uac ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1),
s AS (SELECT user_id, a_start, a_end, IF(uniq_end >= 144, 'finished', 'far_4plus') AS st FROM u WHERE ok AND (uniq_end >= 144 OR uniq_end <= 140))
SELECT DATE_DIFF(d.date_dim, s.a_start, DAY) + 1 AS album_day, ANY_VALUE(DATE_DIFF(s.a_end, s.a_start, DAY)) AS album_len, s.st,
  COUNT(DISTINCT s.user_id) AS players, ROUND(AVG(d.uniq), 1) AS avg_uniq
FROM s JOIN ud d USING (user_id) GROUP BY 1, 3 ORDER BY 1, 3;

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
    MAX(a.date_dim) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(a.lr ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(a.uac ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1),
s AS (SELECT user_id, a_start, a_end, IF(uniq_end >= 144, 'finished', 'far_4plus') AS st FROM u WHERE ok AND (uniq_end >= 144 OR uniq_end <= 140))
SELECT DATE_DIFF(d.date_dim, s.a_start, DAY) + 1 AS album_day, ANY_VALUE(DATE_DIFF(s.a_end, s.a_start, DAY)) AS album_len, s.st,
  COUNT(DISTINCT s.user_id) AS players, ROUND(AVG(d.uniq), 1) AS avg_uniq
FROM s JOIN ud d USING (user_id) GROUP BY 1, 3 ORDER BY 1, 3;

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
    MAX(a.date_dim) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(a.lr ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < 63 AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1),
s AS (SELECT user_id, a_start, a_end, IF(uniq_end >= 144, 'finished', 'far_4plus') AS st FROM u WHERE ok AND (uniq_end >= 144 OR uniq_end <= 140))
SELECT DATE_DIFF(d.date_dim, s.a_start, DAY) + 1 AS album_day, ANY_VALUE(DATE_DIFF(s.a_end, s.a_start, DAY)) AS album_len, s.st,
  COUNT(DISTINCT s.user_id) AS players, ROUND(AVG(d.uniq), 1) AS avg_uniq
FROM s JOIN ud d USING (user_id) GROUP BY 1, 3 ORDER BY 1, 3;
