-- Dis5 (2026-10-15) Disney: daily tier inside each option-C level at the last-quarter start. Project solitaire-dreams-411507. 45.6 GB.
-- Level = h1 (last album played) <=2/2-5/5-20/>20 $/day. Checkpoint cp = CEIL(0.75*n); spend so far through day cp-1.
-- Projected $/day = so_far / curve / n, curve from the OTHER album (out-of-sample). Reach = rev share at <=3 missing at close-4 / close-3.
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d,
    DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend,
    144 - (IFNULL(a.unique_common_stickers_lt, 0) + IFNULL(a.unique_golden_stickers_lt, 0) + IFNULL(a.unique_royal_stickers_tl, 0)) AS miss
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-06' AND DATE '2026-10-04' AND a.album_id BETWEEN 11 AND 15
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, SUM(spend) AS spend, MIN(d) AS first_d,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row
  FROM rows_ GROUP BY 1, 2),
tgt AS (
  SELECT album_id, user_id, n, spend AS total, CAST(CEIL(0.75 * n) AS INT64) AS cp
  FROM ua WHERE album_id IN (14, 15) AND last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1
    AND first_d <= CAST(CEIL(0.75 * n) AS INT64)),
h1 AS (
  SELECT t.album_id, t.user_id, ARRAY_AGG(h.spend / h.n ORDER BY h.album_id DESC LIMIT 1)[OFFSET(0)] AS h1_daily
  FROM tgt t JOIN ua h ON h.user_id = t.user_id AND h.album_id < t.album_id GROUP BY 1, 2),
lvl AS (
  SELECT t.album_id, t.user_id, t.n, t.total, t.cp,
    CASE WHEN IFNULL(h.h1_daily, 0) <= 2 THEN 1 WHEN h.h1_daily <= 5 THEN 2 WHEN h.h1_daily <= 20 THEN 3 ELSE 4 END AS level
  FROM tgt t LEFT JOIN h1 h USING (album_id, user_id)),
u AS (
  SELECT l.album_id, l.user_id, l.n, l.total, l.level,
    SUM(IF(r.d <= l.cp - 1, r.spend, 0)) AS so_far,
    SUM(IF(r.date_dim <= DATE_SUB(r.c, INTERVAL 4 DAY), r.spend, 0)) AS rev_c4,
    SUM(IF(r.date_dim <= DATE_SUB(r.c, INTERVAL 3 DAY), r.spend, 0)) AS rev_c3,
    MIN(IF(r.date_dim <= DATE_SUB(r.c, INTERVAL 4 DAY), r.miss, NULL)) AS miss_c4,
    MIN(IF(r.date_dim <= DATE_SUB(r.c, INTERVAL 3 DAY), r.miss, NULL)) AS miss_c3
  FROM lvl l JOIN rows_ r ON r.album_id = l.album_id AND r.user_id = l.user_id
  GROUP BY 1, 2, 3, 4, 5),
curve AS (
  SELECT album_id, level, SUM(so_far) / SUM(total) AS s75 FROM u WHERE total > 0 GROUP BY 1, 2),
p AS (
  SELECT u.album_id, u.level, u.n, u.total, u.so_far, u.rev_c4, u.rev_c3, u.miss_c4, u.miss_c3,
    c.s75 AS curve_used, u.so_far / c.s75 / u.n AS proj_daily
  FROM u JOIN curve c ON c.level = u.level AND c.album_id = IF(u.album_id = 14, 15, 14)),
b AS (
  SELECT album_id, level, n, total, so_far, rev_c4, rev_c3, miss_c4, miss_c3, curve_used, proj_daily,
    CASE WHEN proj_daily = 0 THEN 0 WHEN proj_daily <= 0.25 THEN 1 WHEN proj_daily <= 0.5 THEN 2 WHEN proj_daily <= 1 THEN 3
         WHEN proj_daily <= 2 THEN 4 WHEN proj_daily <= 5 THEN 5 WHEN proj_daily <= 10 THEN 6 WHEN proj_daily <= 20 THEN 7
         WHEN proj_daily <= 50 THEN 8 ELSE 9 END AS pbin
  FROM p)
SELECT album_id, level, pbin, COUNT(*) AS players, COUNTIF(so_far > 0) AS payers_so_far,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, level), 3) AS share_players_in_level,
  ROUND(SUM(total) / SUM(SUM(total)) OVER (PARTITION BY album_id, level), 3) AS share_album_rev_in_level,
  ROUND(SUM(rev_c4), 0) AS rev_c4, ROUND(SUM(IF(miss_c4 <= 3, rev_c4, 0)), 0) AS rev_c4_le3,
  ROUND(SUM(rev_c3), 0) AS rev_c3, ROUND(SUM(IF(miss_c3 <= 3, rev_c3, 0)), 0) AS rev_c3_le3,
  ROUND(SAFE_DIVIDE(SUM(IF(miss_c4 <= 3, rev_c4, 0)), SUM(rev_c4)), 3) AS rs_le3_c4,
  ROUND(SAFE_DIVIDE(SUM(IF(miss_c3 <= 3, rev_c3, 0)), SUM(rev_c3)), 3) AS rs_le3_c3,
  ROUND(COUNTIF(miss_c4 <= 3) / COUNT(*), 3) AS ps_le3_c4,
  ROUND(SAFE_DIVIDE(SUM(total), SUM(so_far / curve_used)), 3) AS actual_vs_projected,
  ROUND(AVG(total / n), 2) AS avg_actual_daily,
  ROUND(ANY_VALUE(curve_used), 3) AS curve_used
FROM b GROUP BY 1, 2, 3 ORDER BY 1, 2, 3

