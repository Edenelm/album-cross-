-- 2026-10-19: album timeline (ARPDAU by 10% of album time) + last 4 days vs rest, all players and 7+. Ran after Eden's approval.
-- Results: claude/album-timeline-7plus-end-2026-10-19.md

-- Dice (dice-dreams-dbt), 16.6 GB
WITH alb AS (SELECT album_id, MIN(album_start_date) AS a_start, MAX(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album` WHERE date_dim BETWEEN DATE '2025-12-01' AND DATE '2026-10-18' AND album_id IN (53,55,57,59,61,63) GROUP BY 1),
d AS (SELECT x.album_id, a.a_start, a.a_end, x.date_dim,
    IFNULL(x.user_past_album_count,0) >= 6 AS is7, IFNULL(x.spent_in_album_today,0) AS rev,
    LEAST(9, CAST(FLOOR(DATE_DIFF(x.date_dim,a.a_start,DAY)/DATE_DIFF(a.a_end,a.a_start,DAY)*10) AS INT64)) AS sl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x JOIN alb a USING (album_id)
  WHERE x.date_dim BETWEEN DATE '2025-12-01' AND DATE '2026-10-18'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.is_active AND NOT IFNULL(x.is_excluded, FALSE))
SELECT album_id, ANY_VALUE(DATE_DIFF(a_end,a_start,DAY)) AS span,
  ROUND(SUM(rev)/COUNT(*),3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=0,rev,0)),COUNTIF(sl=0)),3) AS s0,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=1,rev,0)),COUNTIF(sl=1)),3) AS s1,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=2,rev,0)),COUNTIF(sl=2)),3) AS s2,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=3,rev,0)),COUNTIF(sl=3)),3) AS s3,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=4,rev,0)),COUNTIF(sl=4)),3) AS s4,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=5,rev,0)),COUNTIF(sl=5)),3) AS s5,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=6,rev,0)),COUNTIF(sl=6)),3) AS s6,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=7,rev,0)),COUNTIF(sl=7)),3) AS s7,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=8,rev,0)),COUNTIF(sl=8)),3) AS s8,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=9,rev,0)),COUNTIF(sl=9)),3) AS s9,
  ROUND(SAFE_DIVIDE(SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY),rev,0)),COUNTIF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY))),3) AS last4_all,
  ROUND(SAFE_DIVIDE(SUM(IF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY),rev,0)),COUNTIF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY))),3) AS rest_all,
  ROUND(SAFE_DIVIDE(SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7,rev,0)),COUNTIF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7)),3) AS last4_7p,
  ROUND(SAFE_DIVIDE(SUM(IF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7,rev,0)),COUNTIF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7)),3) AS rest_7p,
  ROUND(COUNTIF(is7)/COUNT(*),3) AS share_days_7p,
  ROUND(SAFE_DIVIDE(SUM(IF(is7,rev,0)),SUM(rev)),3) AS share_rev_7p
FROM d GROUP BY album_id ORDER BY album_id;

-- Domino (domino-dreams-dbt), 31.6 GB
WITH cheat AS (SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-01-01' AND DATE '2026-10-18'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
alb AS (SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` WHERE date_dim BETWEEN DATE '2026-01-01' AND DATE '2026-10-18' AND album_id IN (15,16,17,18,19,20) GROUP BY 1),
d AS (SELECT x.album_id, a.a_start, a.a_end, x.date_dim,
    IFNULL(x.user_album_count,0) >= 7 AS is7, IFNULL(x.album_spent_today,0) AS rev,
    LEAST(9, CAST(FLOOR(DATE_DIFF(x.date_dim,a.a_start,DAY)/DATE_DIFF(a.a_end,a.a_start,DAY)*10) AS INT64)) AS sl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x JOIN alb a USING (album_id) LEFT JOIN cheat e ON e.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-01-01' AND DATE '2026-10-18'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.active_flag AND x.special_user_flag = FALSE AND e.user_id IS NULL)
SELECT album_id, ANY_VALUE(DATE_DIFF(a_end,a_start,DAY)) AS span,
  ROUND(SUM(rev)/COUNT(*),3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=0,rev,0)),COUNTIF(sl=0)),3) AS s0,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=1,rev,0)),COUNTIF(sl=1)),3) AS s1,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=2,rev,0)),COUNTIF(sl=2)),3) AS s2,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=3,rev,0)),COUNTIF(sl=3)),3) AS s3,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=4,rev,0)),COUNTIF(sl=4)),3) AS s4,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=5,rev,0)),COUNTIF(sl=5)),3) AS s5,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=6,rev,0)),COUNTIF(sl=6)),3) AS s6,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=7,rev,0)),COUNTIF(sl=7)),3) AS s7,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=8,rev,0)),COUNTIF(sl=8)),3) AS s8,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=9,rev,0)),COUNTIF(sl=9)),3) AS s9,
  ROUND(SAFE_DIVIDE(SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY),rev,0)),COUNTIF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY))),3) AS last4_all,
  ROUND(SAFE_DIVIDE(SUM(IF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY),rev,0)),COUNTIF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY))),3) AS rest_all,
  ROUND(SAFE_DIVIDE(SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7,rev,0)),COUNTIF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7)),3) AS last4_7p,
  ROUND(SAFE_DIVIDE(SUM(IF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7,rev,0)),COUNTIF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7)),3) AS rest_7p,
  ROUND(COUNTIF(is7)/COUNT(*),3) AS share_days_7p,
  ROUND(SAFE_DIVIDE(SUM(IF(is7,rev,0)),SUM(rev)),3) AS share_rev_7p
FROM d GROUP BY album_id ORDER BY album_id;

-- Disney (solitaire-dreams-411507), 47.5 GB
WITH cheat AS (SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-18' AND exclude_reason IS NOT NULL),
alb AS (SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end FROM `solitaire-dreams-411507.bi_prod.user_daily_album` WHERE date_dim BETWEEN DATE '2026-01-01' AND DATE '2026-10-18' AND album_id IN (10,11,12,13,14,15) GROUP BY 1),
d AS (SELECT x.album_id, a.a_start, a.a_end, x.date_dim,
    IFNULL(x.user_album_count,0) >= 7 AS is7, IFNULL(x.album_spent_today,0) AS rev,
    LEAST(9, CAST(FLOOR(DATE_DIFF(x.date_dim,a.a_start,DAY)/DATE_DIFF(a.a_end,a.a_start,DAY)*10) AS INT64)) AS sl
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x JOIN alb a USING (album_id) LEFT JOIN cheat e ON e.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-01-01' AND DATE '2026-10-18'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.active_flag AND x.special_user_flag = FALSE AND e.user_id IS NULL)
SELECT album_id, ANY_VALUE(DATE_DIFF(a_end,a_start,DAY)) AS span,
  ROUND(SUM(rev)/COUNT(*),3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=0,rev,0)),COUNTIF(sl=0)),3) AS s0,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=1,rev,0)),COUNTIF(sl=1)),3) AS s1,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=2,rev,0)),COUNTIF(sl=2)),3) AS s2,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=3,rev,0)),COUNTIF(sl=3)),3) AS s3,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=4,rev,0)),COUNTIF(sl=4)),3) AS s4,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=5,rev,0)),COUNTIF(sl=5)),3) AS s5,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=6,rev,0)),COUNTIF(sl=6)),3) AS s6,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=7,rev,0)),COUNTIF(sl=7)),3) AS s7,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=8,rev,0)),COUNTIF(sl=8)),3) AS s8,
  ROUND(SAFE_DIVIDE(SUM(IF(sl=9,rev,0)),COUNTIF(sl=9)),3) AS s9,
  ROUND(SAFE_DIVIDE(SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY),rev,0)),COUNTIF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY))),3) AS last4_all,
  ROUND(SAFE_DIVIDE(SUM(IF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY),rev,0)),COUNTIF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY))),3) AS rest_all,
  ROUND(SAFE_DIVIDE(SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7,rev,0)),COUNTIF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7)),3) AS last4_7p,
  ROUND(SAFE_DIVIDE(SUM(IF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7,rev,0)),COUNTIF(NOT date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND is7)),3) AS rest_7p,
  ROUND(COUNTIF(is7)/COUNT(*),3) AS share_days_7p,
  ROUND(SAFE_DIVIDE(SUM(IF(is7,rev,0)),SUM(rev)),3) AS share_rev_7p
FROM d GROUP BY album_id ORDER BY album_id;
