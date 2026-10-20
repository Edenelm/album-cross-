-- 2026-10-18: where players stand 3 days before close (Eden asked: same as close-4, at 3 days). Results: claude/stand-close4-2026-10-18.md (close-3 section)
-- Revenue (album start -> close-3, spend column of the album table) held by players 3 or fewer short vs 4+ short at close-3, by spend group.
-- Population = standard: not first album, login ratio 0.5+ on the last row before close, exclusions, close day excluded.
-- Stickers at close-3 = max unique stickers on rows up to close-3 (cumulative column). Group = spend so far / days so far at close-3.

-- ===== Dice (dice-dreams-dbt), albums 61, 63 =====
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-08' AND album_id IN (61, 63) GROUP BY 1),
u AS (
  SELECT x.album_id, x.user_id,
    SUM(IF(x.date_dim <= DATE_SUB(a.a_end, INTERVAL 3 DAY), IFNULL(x.spent_in_album_today, 0), 0)) AS rev_c4,
    MAX(IF(x.date_dim <= DATE_SUB(a.a_end, INTERVAL 3 DAY), x.unique_stickers_lt, NULL)) AS stk_c4,
    ANY_VALUE(DATE_DIFF(DATE_SUB(a.a_end, INTERVAL 3 DAY), a.a_start, DAY) + 1) AS days_c4,
    ARRAY_AGG(STRUCT(x.album_login_ratio AS lr, x.user_past_album_count AS past, x.is_excluded AS ex) ORDER BY x.date_dim DESC LIMIT 1)[OFFSET(0)] AS l
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x JOIN alb a USING (album_id)
  WHERE x.date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-08' AND x.date_dim < a.a_end
  GROUP BY 1, 2)
SELECT album_id,
  CASE WHEN rev_c4 = 0 THEN '0' WHEN rev_c4 / days_c4 <= 2 THEN '<=2' WHEN rev_c4 / days_c4 <= 5 THEN '2-5'
       WHEN rev_c4 / days_c4 <= 20 THEN '5-20' ELSE '>20' END AS grp,
  COUNT(*) AS players, ROUND(SUM(rev_c4)) AS rev,
  COUNTIF(144 - stk_c4 <= 3) AS players_near, ROUND(SUM(IF(144 - stk_c4 <= 3, rev_c4, 0))) AS rev_near
FROM u
WHERE l.lr >= 0.5 AND IFNULL(l.past, 0) > 0 AND NOT IFNULL(l.ex, FALSE) AND stk_c4 IS NOT NULL
GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== Domino (domino-dreams-dbt), albums 19, 20 =====
WITH bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag, FALSE)),
u AS (
  SELECT x.album_id, x.user_id,
    SUM(IF(x.date_dim <= DATE_SUB(x.album_close_date, INTERVAL 3 DAY), IFNULL(x.album_spent_today, 0), 0)) AS rev_c4,
    MAX(IF(x.date_dim <= DATE_SUB(x.album_close_date, INTERVAL 3 DAY),
      IFNULL(x.unique_common_stickers_lt,0) + IFNULL(x.unique_golden_stickers_lt,0) + IFNULL(x.unique_royal_stickers_tl,0), NULL)) AS stk_c4,
    ANY_VALUE(DATE_DIFF(DATE_SUB(x.album_close_date, INTERVAL 3 DAY), x.album_open_date, DAY) + 1) AS days_c4,
    ARRAY_AGG(STRUCT(x.login_ratio AS lr, x.user_album_count AS past, x.special_user_flag AS ex) ORDER BY x.date_dim DESC LIMIT 1)[OFFSET(0)] AS l
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x
  WHERE x.date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND x.album_id IN (19, 20) AND x.date_dim < x.album_close_date
  GROUP BY 1, 2)
SELECT album_id,
  CASE WHEN rev_c4 = 0 THEN '0' WHEN rev_c4 / days_c4 <= 2 THEN '<=2' WHEN rev_c4 / days_c4 <= 5 THEN '2-5'
       WHEN rev_c4 / days_c4 <= 20 THEN '5-20' ELSE '>20' END AS grp,
  COUNT(*) AS players, ROUND(SUM(rev_c4)) AS rev,
  COUNTIF(144 - stk_c4 <= 3) AS players_near, ROUND(SUM(IF(144 - stk_c4 <= 3, rev_c4, 0))) AS rev_near
FROM u
WHERE l.lr >= 0.5 AND IFNULL(l.past, 1) > 1 AND NOT IFNULL(l.ex, FALSE) AND stk_c4 IS NOT NULL
  AND user_id NOT IN (SELECT user_id FROM bad)
GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== Disney (solitaire-dreams-411507), albums 14, 15 =====
WITH ex AS (SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-06' AND exclude_reason IS NOT NULL),
u AS (
  SELECT x.album_id, x.user_id,
    SUM(IF(x.date_dim <= DATE_SUB(x.album_close_date, INTERVAL 3 DAY), IFNULL(x.album_spent_today, 0), 0)) AS rev_c4,
    MAX(IF(x.date_dim <= DATE_SUB(x.album_close_date, INTERVAL 3 DAY),
      IFNULL(x.unique_common_stickers_lt,0) + IFNULL(x.unique_golden_stickers_lt,0) + IFNULL(x.unique_royal_stickers_tl,0), NULL)) AS stk_c4,
    ANY_VALUE(DATE_DIFF(DATE_SUB(x.album_close_date, INTERVAL 3 DAY), x.album_open_date, DAY) + 1) AS days_c4,
    ARRAY_AGG(STRUCT(x.login_ratio AS lr, x.user_album_count AS past, x.special_user_flag AS sp) ORDER BY x.date_dim DESC LIMIT 1)[OFFSET(0)] AS l
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x
  WHERE x.date_dim BETWEEN DATE '2026-07-10' AND DATE '2026-10-06' AND x.album_id IN (14, 15) AND x.date_dim < x.album_close_date
  GROUP BY 1, 2)
SELECT album_id,
  CASE WHEN rev_c4 = 0 THEN '0' WHEN rev_c4 / days_c4 <= 2 THEN '<=2' WHEN rev_c4 / days_c4 <= 5 THEN '2-5'
       WHEN rev_c4 / days_c4 <= 20 THEN '5-20' ELSE '>20' END AS grp,
  COUNT(*) AS players, ROUND(SUM(rev_c4)) AS rev,
  COUNTIF(144 - stk_c4 <= 3) AS players_near, ROUND(SUM(IF(144 - stk_c4 <= 3, rev_c4, 0))) AS rev_near
FROM u
WHERE l.lr >= 0.5 AND IFNULL(l.past, 1) > 1 AND NOT IFNULL(l.sp, FALSE) AND stk_c4 IS NOT NULL
  AND user_id NOT IN (SELECT user_id FROM ex)
GROUP BY 1, 2 ORDER BY 1, 2;
