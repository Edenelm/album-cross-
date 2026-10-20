-- Sticker progression, median paying player (2026-10-18). Cumulative unique set stickers (of 144) at the end of each 10% of album time.
-- Population: paid in album days before close; login ratio >= 0.5 on last row before close; not first album; standard exclusions.
-- Domino (17/19/20, 2026-03-30..2026-10-12) and Disney (12/14/15, 2026-05-11..2026-10-05): same logic with
--   st = unique_common_stickers_lt + unique_golden_stickers_lt + unique_royal_stickers_tl, sp = album_spent_today, lr = login_ratio,
--   not first album = MAX(user_album_count) > 1, album_open_date / album_close_date;
--   exclusions Domino: special_user_flag = FALSE + suspected_cheater_flag (prod_40_mart.user_daily_metrics);
--   Disney: special_user_flag = FALSE + bi_prod.user_profile.exclude_reason IS NULL.

-- Dice (dice-dreams-dbt) 59/61/63
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (59, 61, 63)
  GROUP BY 1
),
r AS (
  SELECT x.album_id, x.user_id, x.date_dim, DATE_DIFF(a.a_end, a.a_start, DAY) AS n,
    DATE_DIFF(x.date_dim, a.a_start, DAY) AS d, IFNULL(x.unique_stickers_lt, 0) AS st,
    IFNULL(x.spent_in_album_today, 0) AS sp, x.album_login_ratio AS lr, x.user_past_album_count AS past
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x
  JOIN alb a ON a.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-07'
    AND x.date_dim < a.a_end AND NOT IFNULL(x.is_excluded, FALSE)
),
u AS (
  SELECT album_id, user_id FROM r GROUP BY 1, 2
  HAVING SUM(sp) > 0 AND MIN(IFNULL(past, 0)) > 0 AND ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5
),
g AS (
  SELECT r.album_id, r.user_id, p, MAX(r.st) AS st_p
  FROM r JOIN u USING (album_id, user_id)
  CROSS JOIN UNNEST(GENERATE_ARRAY(1, 10)) AS p
  WHERE r.d <= CAST(CEIL(r.n * p / 10) AS INT64) - 1
  GROUP BY 1, 2, 3
)
SELECT album_id, p * 10 AS pct_time, COUNT(*) AS players,
  APPROX_QUANTILES(st_p, 100)[OFFSET(25)] AS p25, APPROX_QUANTILES(st_p, 100)[OFFSET(50)] AS p50,
  APPROX_QUANTILES(st_p, 100)[OFFSET(75)] AS p75, ROUND(AVG(st_p), 1) AS mean_st
FROM g GROUP BY 1, 2 ORDER BY 1, 2;
