-- 2026-10-28 (Eden): Domino albums 17-20, end-of-album lift vs a normal weekday.
-- Population: standard-population payers (not first album, not special / suspected cheater, lr >= 0.5 on last row before close, row on close-1, paid any album day incl close).
-- Daily ARPDAU = album spend that day / payers active that day (active_flag). Baseline = average ARPDAU of the same weekday on album days up to close-8.
-- Index for d-14..d-1 (close day out) = ARPDAU(day) / baseline(weekday). 1.00 = no lift.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(active_flag, FALSE) AS act,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND album_id IN (17,18,19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)),
day AS (
  SELECT d.album_id, DATE_DIFF(d.date_dim, d.a_end, DAY) AS dd, EXTRACT(DAYOFWEEK FROM d.date_dim) AS wd,
    SUM(d.spend) / COUNTIF(d.act) AS arpdau, COUNTIF(d.act) AS dau
  FROM ud d JOIN pop USING (album_id, user_id) WHERE d.date_dim < d.a_end GROUP BY 1,2,3
),
base AS (SELECT album_id, wd, AVG(arpdau) AS b FROM day WHERE dd <= -8 GROUP BY 1,2)
SELECT album_id, STRING_AGG(FORMAT('%d:%.3f:%d', dd, arpdau / b, dau), ' ' ORDER BY dd) AS series
FROM day JOIN base USING (album_id, wd) WHERE dd BETWEEN -14 AND -1 GROUP BY 1 ORDER BY 1;
