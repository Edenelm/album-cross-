-- 2026-10-18 (Eden approved): Dice history vs current spend predictor (same method as Disney D5b / Domino Dom6). Dice 61/63. 15.6 GB. Results: claude/approved-batch-2026-10-18.md
WITH r AS (
  SELECT album_id, user_id, date_dim, DATE_DIFF(date_dim, album_start_date, DAY) AS d, DATE_DIFF(album_end_date, album_start_date, DAY) AS n,
    IFNULL(spent_in_album_today, 0) AS spend, album_login_ratio AS lr, user_past_album_count AS past, is_excluded AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-09-07' AND album_id IN (55, 57, 59, 61, 63) AND date_dim < album_end_date),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, SUM(spend) AS total, MIN(d) AS first_d,
    ARRAY_AGG(STRUCT(lr, past, ex) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l
  FROM r GROUP BY 1, 2),
tgt AS (
  SELECT album_id, user_id, n, total, first_d FROM ua
  WHERE album_id IN (61, 63) AND l.lr >= 0.5 AND IFNULL(l.past, 0) > 0 AND NOT IFNULL(l.ex, FALSE)),
h1 AS (
  SELECT t.album_id, t.user_id, ARRAY_AGG(h.total / h.n ORDER BY h.album_id DESC LIMIT 1)[OFFSET(0)] AS h1d
  FROM tgt t JOIN ua h ON h.user_id = t.user_id AND h.album_id < t.album_id GROUP BY 1, 2),
cps AS (SELECT c.k, c.pct FROM UNNEST([STRUCT(1 AS k, 0.10 AS pct), STRUCT(2, 0.25), STRUCT(3, 0.50), STRUCT(4, 0.75)]) AS c),
sf AS (
  SELECT t.album_id, t.user_id, t.n, t.total, t.first_d, c.k, CAST(CEIL(c.pct * t.n) AS INT64) AS cp,
    SUM(IF(x.d <= CAST(CEIL(c.pct * t.n) AS INT64) - 1, x.spend, 0)) AS so_far
  FROM tgt t CROSS JOIN cps c JOIN r x ON x.album_id = t.album_id AND x.user_id = t.user_id
  GROUP BY 1, 2, 3, 4, 5, 6, 7),
curve AS (SELECT album_id, k, SUM(so_far) / SUM(total) AS s FROM sf WHERE total > 0 GROUP BY 1, 2),
lv AS (
  SELECT sf.album_id, sf.k, sf.total,
    CASE WHEN sf.total / sf.n <= 2 THEN 1 WHEN sf.total / sf.n <= 5 THEN 2 WHEN sf.total / sf.n <= 20 THEN 3 ELSE 4 END AS act,
    CASE WHEN IFNULL(h.h1d, 0) <= 2 THEN 1 WHEN h.h1d <= 5 THEN 2 WHEN h.h1d <= 20 THEN 3 ELSE 4 END AS hist,
    CASE WHEN sf.so_far / c.s / sf.n <= 2 THEN 1 WHEN sf.so_far / c.s / sf.n <= 5 THEN 2 WHEN sf.so_far / c.s / sf.n <= 20 THEN 3 ELSE 4 END AS cur
  FROM sf JOIN curve c ON c.k = sf.k AND c.album_id = IF(sf.album_id = 61, 63, 61)
  LEFT JOIN h1 h ON h.album_id = sf.album_id AND h.user_id = sf.user_id
  WHERE sf.first_d <= sf.cp - 1)
SELECT album_id, k, COUNT(*) AS players, ROUND(SUM(total)) AS rev,
  ROUND(SUM(IF(hist = act, total, 0)) / SUM(total), 3) AS rev_right_hist,
  ROUND(SUM(IF(cur = act, total, 0)) / SUM(total), 3) AS rev_right_cur
FROM lv GROUP BY 1, 2 ORDER BY 1, 2
