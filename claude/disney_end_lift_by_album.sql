-- 2026-10-21 (Eden): Disney only, every album since April 2025: ARPDAU of the last 4 full days (close-4..close-1, close day excluded)
-- vs ARPDAU of the whole album, by album id. Eden saw a downlift in album 14. Results: claude/disney-end-lift-by-album-2026-10-21.md
-- Same definitions as album_length_end_arpdau_queries.sql (2026-10-18): all players who received the album (rows from the player's
-- album start date), active days only (active_flag), close day excluded, special users and exclude_reason users out.
-- ARPDAU = sum of album_spent_today / active player-days. Project solitaire-dreams-411507. 76.7 GB.

-- ===== 1. Lift per album =====
WITH alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end,
         COUNT(DISTINCT album_open_date) AS n_open, COUNT(DISTINCT album_close_date) AS n_close
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-03-01' AND DATE '2026-10-21'
  GROUP BY 1
  HAVING MIN(album_open_date) >= DATE '2025-04-01' AND MAX(album_close_date) <= DATE '2026-10-21'
),
excl AS (SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
         WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-21' AND exclude_reason IS NOT NULL),
d AS (
  SELECT x.album_id, x.user_id, x.date_dim, a.a_end, IFNULL(x.album_spent_today, 0) AS rev
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x
  JOIN alb a ON a.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-21'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.active_flag AND NOT IFNULL(x.special_user_flag, FALSE)
    AND x.user_id NOT IN (SELECT user_id FROM excl)
)
SELECT a.album_id, a.a_start, a.a_end, DATE_DIFF(a.a_end, a.a_start, DAY) AS span_days,
  FORMAT_DATE('%a', a.a_end) AS close_weekday, a.n_open, a.n_close,
  COUNT(DISTINCT d.user_id) AS players, COUNT(*) AS act_days, ROUND(SUM(d.rev)) AS rev,
  ROUND(SUM(d.rev) / COUNT(*), 3) AS arpdau_album,
  COUNTIF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY)) AS end_days,
  ROUND(SUM(IF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY), d.rev, 0))) AS end_rev,
  ROUND(SAFE_DIVIDE(SUM(IF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY), d.rev, 0)),
                    COUNTIF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY))), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY), d.rev, 0)),
                    COUNTIF(d.date_dim >= DATE_SUB(a.a_end, INTERVAL 4 DAY))), SUM(d.rev) / COUNT(*)), 3) AS ratio_last4
FROM alb a JOIN d ON d.album_id = a.album_id
GROUP BY 1, 2, 3, 4, 5, 6, 7
ORDER BY a.a_start;

-- ===== 2. Day by day, albums 14 and 15 (15.3 GB) =====
WITH alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-06' AND album_id IN (14, 15)
  GROUP BY 1
),
excl AS (SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
         WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-21' AND exclude_reason IS NOT NULL),
d AS (
  SELECT x.album_id, x.user_id, x.date_dim, a.a_start, a.a_end, IFNULL(x.album_spent_today, 0) AS rev
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x
  JOIN alb a ON a.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-06'
    AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.active_flag AND NOT IFNULL(x.special_user_flag, FALSE)
    AND x.user_id NOT IN (SELECT user_id FROM excl)
)
SELECT album_id, date_dim, DATE_DIFF(date_dim, a_start, DAY) AS day_in_album, DATE_DIFF(a_end, date_dim, DAY) AS days_before_close,
  FORMAT_DATE('%a', date_dim) AS weekday, COUNT(*) AS dau, ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / COUNT(*), 3) AS arpdau,
  COUNTIF(rev > 0) AS payers
FROM d
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2;
