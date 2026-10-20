-- Dis1 (2026-10-14) Disney: pre-album spend level from history -> decision table for thresholds. Project solitaire-dreams-411507.
-- History = up to 3 most recent albums played among 11..(target-1); daily spend = spend (close day excluded) / (close - open) days. Spend only (Eden).
-- Targets: albums 14, 15. Population: not special, not excluded, user_album_count > 1, login_ratio on last row before close >= 0.5.
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
ua AS (  -- user x album, albums 11-15
  SELECT a.album_id, a.user_id,
    ANY_VALUE(DATE_DIFF(a.album_close_date, a.album_open_date, DAY)) AS n_days,
    SUM(IFNULL(a.album_spent_today, 0)) AS spend,
    ARRAY_AGG(STRUCT(a.login_ratio AS lr, a.user_album_count AS uac, a.album_segment AS seg) ORDER BY a.date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row,
    MAX(a.unique_royal_stickers_tl) AS royals_end, LOGICAL_OR(IFNULL(a.album_finished_flag, FALSE)) AS finished
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-06' AND DATE '2026-10-04' AND a.album_id BETWEEN 11 AND 15
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date
  GROUP BY 1, 2),
tgt AS (
  SELECT album_id, user_id, n_days, spend, spend / n_days AS cur_daily, royals_end, finished, last_row.seg AS seg
  FROM ua WHERE album_id IN (14, 15) AND last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1),
hist AS (  -- up to 3 most recent prior albums played (>= 11)
  SELECT t.album_id, t.user_id,
    SUM(h.spend) / SUM(h.n_days) AS h3_daily,
    ARRAY_AGG(h.spend / h.n_days ORDER BY h.album_id DESC LIMIT 1)[OFFSET(0)] AS h1_daily,
    COUNT(*) AS n_hist
  FROM tgt t JOIN (
    SELECT t2.album_id AS target, h.album_id, h.user_id, h.spend, h.n_days,
      ROW_NUMBER() OVER (PARTITION BY t2.album_id, h.user_id ORDER BY h.album_id DESC) AS rn
    FROM tgt t2 JOIN ua h ON h.user_id = t2.user_id AND h.album_id < t2.album_id) h
    ON h.target = t.album_id AND h.user_id = t.user_id AND h.rn <= 3
  GROUP BY 1, 2),
b AS (
  SELECT t.album_id, t.user_id, t.spend, t.cur_daily, t.royals_end, t.finished, t.seg, h.n_hist,
    CASE WHEN h.h3_daily IS NULL OR h.h3_daily = 0 THEN 0 WHEN h.h3_daily <= 0.25 THEN 1 WHEN h.h3_daily <= 0.5 THEN 2 WHEN h.h3_daily <= 1 THEN 3
         WHEN h.h3_daily <= 2 THEN 4 WHEN h.h3_daily <= 5 THEN 5 WHEN h.h3_daily <= 10 THEN 6 WHEN h.h3_daily <= 20 THEN 7 ELSE 8 END AS bin_h3,
    CASE WHEN h.h1_daily IS NULL OR h.h1_daily = 0 THEN 0 WHEN h.h1_daily <= 0.25 THEN 1 WHEN h.h1_daily <= 0.5 THEN 2 WHEN h.h1_daily <= 1 THEN 3
         WHEN h.h1_daily <= 2 THEN 4 WHEN h.h1_daily <= 5 THEN 5 WHEN h.h1_daily <= 10 THEN 6 WHEN h.h1_daily <= 20 THEN 7 ELSE 8 END AS bin_h1,
    CASE WHEN t.cur_daily = 0 THEN 0 WHEN t.cur_daily <= 0.25 THEN 1 WHEN t.cur_daily <= 0.5 THEN 2 WHEN t.cur_daily <= 1 THEN 3
         WHEN t.cur_daily <= 2 THEN 4 WHEN t.cur_daily <= 5 THEN 5 WHEN t.cur_daily <= 10 THEN 6 WHEN t.cur_daily <= 20 THEN 7 ELSE 8 END AS bin_cur
  FROM tgt t LEFT JOIN hist h USING (album_id, user_id))
SELECT album_id, bin_h3 AS bin,
  COUNT(*) AS players, ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 3) AS share_players,
  COUNTIF(spend > 0) AS payers_in_album,
  ROUND(SUM(spend) / SUM(SUM(spend)) OVER (PARTITION BY album_id), 3) AS share_revenue,
  ROUND(AVG(cur_daily), 2) AS avg_daily_spend_now,
  ROUND(COUNTIF(bin_cur = bin_h3) / COUNT(*), 3) AS same_bin_now,
  ROUND(COUNTIF(ABS(bin_cur - bin_h3) <= 1) / COUNT(*), 3) AS within_1_bin_now,
  ROUND(COUNTIF(bin_cur < bin_h3) / COUNT(*), 3) AS lower_now,
  ROUND(COUNTIF(bin_cur > bin_h3) / COUNT(*), 3) AS higher_now,
  ROUND(COUNTIF(finished) / COUNT(*), 3) AS finish_rate,
  APPROX_QUANTILES(royals_end, 100)[OFFSET(50)] AS p50_royals_end,
  ROUND(AVG(n_hist), 2) AS avg_hist_albums,
  APPROX_TOP_COUNT(seg, 1)[SAFE_OFFSET(0)].value AS top_existing_segment
FROM b GROUP BY 1, 2
UNION ALL  -- bin = -1: overall accuracy. same/within1 = history of up to 3 albums; lower_now/higher_now columns here = same/within1 for LAST album only
SELECT album_id, -1, COUNT(*), NULL, COUNTIF(spend > 0), NULL, NULL,
  ROUND(COUNTIF(bin_cur = bin_h3) / COUNT(*), 3), ROUND(COUNTIF(ABS(bin_cur - bin_h3) <= 1) / COUNT(*), 3),
  ROUND(COUNTIF(bin_cur = bin_h1) / COUNT(*), 3), ROUND(COUNTIF(ABS(bin_cur - bin_h1) <= 1) / COUNT(*), 3),
  NULL, NULL, NULL, NULL
FROM b GROUP BY 1
ORDER BY 1, 2

-- Dis2 (2026-10-14) Disney: reach of "<=3 stickers missing" (of 144) by history spend bin, at close-4 / close-3 / close-1, as revenue share. Project solitaire-dreams-411507.
-- Bins = Dis1 (history = up to 3 most recent albums played among 11..target-1, $/day). Sums are output so any threshold option can be composed.
-- Population = Dis1: not special, not excluded, user_album_count > 1, login_ratio on last row before close >= 0.5; close day excluded.
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS o, a.album_close_date AS c, a.login_ratio, a.user_album_count,
    IFNULL(a.album_spent_today, 0) AS spend, IFNULL(a.active_flag, FALSE) AS act,
    144 - (IFNULL(a.unique_common_stickers_lt, 0) + IFNULL(a.unique_golden_stickers_lt, 0) + IFNULL(a.unique_royal_stickers_tl, 0)) AS miss
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-06' AND DATE '2026-10-04' AND a.album_id BETWEEN 11 AND 15
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(DATE_DIFF(c, o, DAY)) AS n_days, SUM(spend) AS spend,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row
  FROM rows_ GROUP BY 1, 2),
tgt AS (SELECT album_id, user_id FROM ua WHERE album_id IN (14, 15) AND last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1),
hist AS (
  SELECT t.album_id, t.user_id, SUM(h.spend) / SUM(h.n_days) AS h3_daily
  FROM tgt t JOIN (
    SELECT t2.album_id AS target, h.user_id, h.spend, h.n_days,
      ROW_NUMBER() OVER (PARTITION BY t2.album_id, h.user_id ORDER BY h.album_id DESC) AS rn
    FROM tgt t2 JOIN ua h ON h.user_id = t2.user_id AND h.album_id < t2.album_id) h
    ON h.target = t.album_id AND h.user_id = t.user_id AND h.rn <= 3
  GROUP BY 1, 2),
u AS (  -- per player in target album
  SELECT r.album_id, r.user_id,
    SUM(IF(r.date_dim <= DATE_SUB(r.c, INTERVAL 4 DAY), r.spend, 0)) AS rev_c4,
    SUM(IF(r.date_dim <= DATE_SUB(r.c, INTERVAL 3 DAY), r.spend, 0)) AS rev_c3,
    SUM(r.spend) AS rev_c1,
    SUM(IF(r.date_dim > DATE_SUB(r.c, INTERVAL 4 DAY), r.spend, 0)) AS rev_last3,
    COUNTIF(r.date_dim > DATE_SUB(r.c, INTERVAL 4 DAY) AND r.act) AS act_last3,
    MIN(IF(r.date_dim <= DATE_SUB(r.c, INTERVAL 4 DAY), r.miss, NULL)) AS miss_c4,
    MIN(IF(r.date_dim <= DATE_SUB(r.c, INTERVAL 3 DAY), r.miss, NULL)) AS miss_c3,
    MIN(r.miss) AS miss_c1,
    MIN(IF(r.miss <= 3, DATE_DIFF(r.date_dim, r.o, DAY) + 1, NULL)) AS first_day_le3,
    ANY_VALUE(DATE_DIFF(r.c, r.o, DAY)) AS n_days
  FROM rows_ r JOIN tgt t USING (album_id, user_id)
  GROUP BY 1, 2),
b AS (
  SELECT u.album_id, u.rev_c4, u.rev_c3, u.rev_c1, u.rev_last3, u.act_last3, u.miss_c4, u.miss_c3, u.miss_c1, u.first_day_le3, u.n_days,
    CASE WHEN h.h3_daily IS NULL OR h.h3_daily = 0 THEN 0 WHEN h.h3_daily <= 0.25 THEN 1 WHEN h.h3_daily <= 0.5 THEN 2 WHEN h.h3_daily <= 1 THEN 3
         WHEN h.h3_daily <= 2 THEN 4 WHEN h.h3_daily <= 5 THEN 5 WHEN h.h3_daily <= 10 THEN 6 WHEN h.h3_daily <= 20 THEN 7 ELSE 8 END AS bin
  FROM u LEFT JOIN hist h USING (album_id, user_id))
SELECT album_id, bin, COUNT(*) AS players,
  ROUND(SUM(rev_c4), 0) AS rev_c4, ROUND(SUM(IF(miss_c4 <= 3, rev_c4, 0)), 0) AS rev_c4_le3,
  ROUND(SUM(rev_c3), 0) AS rev_c3, ROUND(SUM(IF(miss_c3 <= 3, rev_c3, 0)), 0) AS rev_c3_le3,
  ROUND(SUM(rev_c1), 0) AS rev_c1, ROUND(SUM(IF(miss_c1 <= 3, rev_c1, 0)), 0) AS rev_c1_le3,
  ROUND(SUM(IF(miss_c4 <= 3, rev_c4, 0)) / NULLIF(SUM(rev_c4), 0), 3) AS rs_le3_c4,
  ROUND(SUM(IF(miss_c3 <= 3, rev_c3, 0)) / NULLIF(SUM(rev_c3), 0), 3) AS rs_le3_c3,
  ROUND(SUM(IF(miss_c1 <= 3, rev_c1, 0)) / NULLIF(SUM(rev_c1), 0), 3) AS rs_le3_c1,
  ROUND(COUNTIF(miss_c4 <= 3) / COUNT(*), 3) AS ps_le3_c4,
  ROUND(COUNTIF(miss_c4 = 3) / NULLIF(COUNTIF(miss_c4 BETWEEN 1 AND 3), 0), 3) AS exactly3_of_1to3_c4,
  APPROX_QUANTILES(first_day_le3 / n_days, 100)[OFFSET(50)] AS p50_share_of_album_when_reached_le3,
  -- last 3 full days (close-3..close-1): reachers at close-4 vs far (4+ missing)
  ROUND(COUNTIF(miss_c4 <= 3 AND rev_last3 > 0) / NULLIF(COUNTIF(miss_c4 <= 3), 0), 3) AS paid_last3_le3,
  ROUND(COUNTIF(miss_c4 > 3 AND rev_last3 > 0) / NULLIF(COUNTIF(miss_c4 > 3), 0), 3) AS paid_last3_far,
  ROUND(SUM(IF(miss_c4 <= 3, rev_last3, 0)) / NULLIF(SUM(IF(miss_c4 <= 3, act_last3, 0)), 0), 2) AS arpdau_last3_le3,
  ROUND(SUM(IF(miss_c4 > 3, rev_last3, 0)) / NULLIF(SUM(IF(miss_c4 > 3, act_last3, 0)), 0), 2) AS arpdau_last3_far
FROM b GROUP BY 1, 2 ORDER BY 1, 2
;

-- Dis3 (2026-10-14) Disney: stability of threshold option C (<=2 / 2-5 / 5-20 / >20 $/day). Level from history vs level in the album itself.
-- Two history versions: h3 = up to 3 most recent albums (11..target-1), h1 = last album played. Population = Dis1. Project solitaire-dreams-411507.
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
ua AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(DATE_DIFF(a.album_close_date, a.album_open_date, DAY)) AS n_days,
    SUM(IFNULL(a.album_spent_today, 0)) AS spend,
    ARRAY_AGG(STRUCT(a.login_ratio AS lr, a.user_album_count AS uac) ORDER BY a.date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-06' AND DATE '2026-10-04' AND a.album_id BETWEEN 11 AND 15
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date
  GROUP BY 1, 2),
tgt AS (
  SELECT album_id, user_id, spend, spend / n_days AS cur_daily
  FROM ua WHERE album_id IN (14, 15) AND last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1),
hist AS (
  SELECT t.album_id, t.user_id, SUM(h.spend) / SUM(h.n_days) AS h3_daily,
    ARRAY_AGG(h.spend / h.n_days ORDER BY h.album_id DESC LIMIT 1)[OFFSET(0)] AS h1_daily
  FROM tgt t JOIN (
    SELECT t2.album_id AS target, h.album_id, h.user_id, h.spend, h.n_days,
      ROW_NUMBER() OVER (PARTITION BY t2.album_id, h.user_id ORDER BY h.album_id DESC) AS rn
    FROM tgt t2 JOIN ua h ON h.user_id = t2.user_id AND h.album_id < t2.album_id) h
    ON h.target = t.album_id AND h.user_id = t.user_id AND h.rn <= 3
  GROUP BY 1, 2),
lv AS (
  SELECT t.album_id, t.spend,
    CASE WHEN t.cur_daily <= 2 THEN 1 WHEN t.cur_daily <= 5 THEN 2 WHEN t.cur_daily <= 20 THEN 3 ELSE 4 END AS lv_now,
    CASE WHEN IFNULL(h.h3_daily, 0) <= 2 THEN 1 WHEN h.h3_daily <= 5 THEN 2 WHEN h.h3_daily <= 20 THEN 3 ELSE 4 END AS lv_h3,
    CASE WHEN IFNULL(h.h1_daily, 0) <= 2 THEN 1 WHEN h.h1_daily <= 5 THEN 2 WHEN h.h1_daily <= 20 THEN 3 ELSE 4 END AS lv_h1
  FROM tgt t LEFT JOIN hist h USING (album_id, user_id)),
x AS (
  SELECT album_id, 'h3' AS hist_version, lv_h3 AS level, lv_now, spend FROM lv
  UNION ALL
  SELECT album_id, 'h1', lv_h1, lv_now, spend FROM lv)
SELECT album_id, hist_version, level, COUNT(*) AS players, COUNTIF(spend > 0) AS payers_now,
  ROUND(SUM(spend) / SUM(SUM(spend)) OVER (PARTITION BY album_id, hist_version), 3) AS share_revenue,
  ROUND(COUNTIF(lv_now = level) / COUNT(*), 3) AS same_level_now,
  ROUND(COUNTIF(lv_now < level) / COUNT(*), 3) AS lower_now,
  ROUND(COUNTIF(lv_now > level) / COUNT(*), 3) AS higher_now,
  ROUND(SUM(IF(lv_now = level, spend, 0)) / NULLIF(SUM(spend), 0), 3) AS rev_share_from_same_level
FROM x GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
;

-- Dis4 (2026-10-14) Disney: spend pace curve by option-C level (history = last album played, h1). Payers with album spend > 0. Project solitaire-dreams-411507.
-- Day d = date_dim - album_open_date (0-based); n = close - open = 42 (albums 14, 15); checkpoint p -> cumulative through day CEIL(p*n)-1.
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d,
    DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n, a.login_ratio, a.user_album_count,
    IFNULL(a.album_spent_today, 0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-06' AND DATE '2026-10-04' AND a.album_id BETWEEN 11 AND 15
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, SUM(spend) AS spend,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row
  FROM rows_ GROUP BY 1, 2),
tgt AS (SELECT album_id, user_id, n, spend AS total FROM ua
  WHERE album_id IN (14, 15) AND last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1 AND spend > 0),
h1 AS (
  SELECT t.album_id, t.user_id, ARRAY_AGG(h.spend / h.n ORDER BY h.album_id DESC LIMIT 1)[OFFSET(0)] AS h1_daily
  FROM tgt t JOIN ua h ON h.user_id = t.user_id AND h.album_id < t.album_id GROUP BY 1, 2),
lvl AS (
  SELECT t.album_id, t.user_id, t.n, t.total,
    CASE WHEN IFNULL(h.h1_daily, 0) <= 2 THEN 1 WHEN h.h1_daily <= 5 THEN 2 WHEN h.h1_daily <= 20 THEN 3 ELSE 4 END AS level
  FROM tgt t LEFT JOIN h1 h USING (album_id, user_id)),
cp AS (SELECT p FROM UNNEST([0.10, 0.25, 0.50, 0.60, 0.75, 0.85, 0.90, 0.95]) AS p),
ucp AS (
  SELECT l.album_id, l.user_id, l.level, l.total, c.p,
    SUM(IF(r.d <= CAST(CEIL(c.p * l.n) AS INT64) - 1, r.spend, 0)) AS cum
  FROM lvl l CROSS JOIN cp c JOIN rows_ r ON r.album_id = l.album_id AND r.user_id = l.user_id
  GROUP BY 1, 2, 3, 4, 5),
agg AS (
  SELECT album_id, level, p, COUNT(*) AS payers, SUM(cum) / SUM(total) AS pooled, APPROX_QUANTILES(cum / total, 100)[OFFSET(50)] AS p50
  FROM ucp GROUP BY 1, 2, 3)
SELECT album_id, level, MAX(payers) AS payers,
  ROUND(MAX(IF(p = 0.10, pooled, NULL)), 3) AS s10, ROUND(MAX(IF(p = 0.25, pooled, NULL)), 3) AS s25,
  ROUND(MAX(IF(p = 0.50, pooled, NULL)), 3) AS s50, ROUND(MAX(IF(p = 0.60, pooled, NULL)), 3) AS s60,
  ROUND(MAX(IF(p = 0.75, pooled, NULL)), 3) AS s75, ROUND(MAX(IF(p = 0.85, pooled, NULL)), 3) AS s85,
  ROUND(MAX(IF(p = 0.90, pooled, NULL)), 3) AS s90, ROUND(MAX(IF(p = 0.95, pooled, NULL)), 3) AS s95,
  ROUND(MAX(IF(p = 0.50, p50, NULL)), 3) AS p50_player_50, ROUND(MAX(IF(p = 0.75, p50, NULL)), 3) AS p50_player_75
FROM agg GROUP BY 1, 2 ORDER BY 1, 2
;

