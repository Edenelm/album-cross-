-- Dice end lift: add album 65 (closed 2026-10-19) + 7+ group with the fixed album count (Eden approved 2026-10-22).
-- Results: claude/dice-end-lift-65-7plus-2026-10-22.md
-- Population (as album_length_end_arpdau_queries.sql): all players who received the album, rows from user_album_start_date,
--   active days, close day excluded, is_excluded removed. Revenue = spent_in_album_today.
-- lift_all = last-4-days ARPDAU / whole-album ARPDAU (end-growth slide). last4 vs rest = album-timeline-7plus rule.
-- 7+ new = at least 6 earlier albums with a row in user_daily_album (history from 2023-11-07); 7+ old = user_past_album_count >= 6.
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-01-01' AND DATE '2026-10-19' AND album_id IN (53,55,57,59,61,63,65)
  GROUP BY 1
),
ua AS (
  SELECT user_id, album_id FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-10-19' AND album_id <= 65
  GROUP BY 1, 2
),
nprev AS (SELECT user_id, album_id, COUNT(*) OVER (PARTITION BY user_id ORDER BY album_id) - 1 AS n_prev FROM ua),
d AS (
  SELECT x.album_id, a.a_end, x.date_dim, IFNULL(x.spent_in_album_today, 0) AS rev,
    IFNULL(x.user_past_album_count, 0) >= 6 AS is7_old, IFNULL(p.n_prev, 0) >= 6 AS is7_new,
    x.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY) AS last4
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x
  JOIN alb a USING (album_id)
  LEFT JOIN nprev p ON p.user_id = x.user_id AND p.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2026-01-01' AND DATE '2026-10-19'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.is_active AND NOT IFNULL(x.is_excluded, FALSE)
)
SELECT album_id,
  COUNT(*) AS act_days, ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / COUNT(*), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), SUM(rev) / COUNT(*)) - 1, 3) AS lift_all,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(last4, rev, 0)), COUNTIF(last4)), SAFE_DIVIDE(SUM(IF(NOT last4, rev, 0)), COUNTIF(NOT last4))) - 1, 3) AS last4_vs_rest_all,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(last4 AND is7_old, rev, 0)), COUNTIF(last4 AND is7_old)), SAFE_DIVIDE(SUM(IF(NOT last4 AND is7_old, rev, 0)), COUNTIF(NOT last4 AND is7_old))) - 1, 3) AS last4_vs_rest_7p_old,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(last4 AND is7_new, rev, 0)), COUNTIF(last4 AND is7_new)), SAFE_DIVIDE(SUM(IF(NOT last4 AND is7_new, rev, 0)), COUNTIF(NOT last4 AND is7_new))) - 1, 3) AS last4_vs_rest_7p_new,
  ROUND(COUNTIF(is7_old) / COUNT(*), 3) AS share_days_7p_old, ROUND(COUNTIF(is7_new) / COUNT(*), 3) AS share_days_7p_new,
  ROUND(SAFE_DIVIDE(SUM(IF(is7_old, rev, 0)), SUM(rev)), 3) AS share_rev_7p_old, ROUND(SAFE_DIVIDE(SUM(IF(is7_new, rev, 0)), SUM(rev)), 3) AS share_rev_7p_new
FROM d GROUP BY album_id ORDER BY album_id
