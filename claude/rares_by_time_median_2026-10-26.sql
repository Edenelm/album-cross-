-- Median (p50) and average % of the album's rares held, by % of album time (Eden, 2026-10-26). Results: claude/rares-by-time-median-2026-10-26.md
-- Population/rules = claude/rare_timeline_queries.sql (standard population, payer = paid on any album day incl. close day).
-- Albums: Dice 59/61/63, Domino 17/19/20, Disney 12/14/15. X = % of album time; day at X = ROUND(X/100 * n_days), n_days = start..close day inclusive;
-- X=100 = end of the close day (close-day rares included, same as the average version). Y = unique rares held / rares in the album (distinct rare ids collected by the population).
-- 'pooled' = all payers of the 3 albums together.

-- ===== dice-dreams-dbt =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_start, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
pop AS (SELECT album_id, user_id, a_start, a_end, alb_rev FROM pop0 WHERE rev_c > 0),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_date) AS d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-04-01' AND DATE '2026-09-07' AND s.album_id IN (59,61,63)
    AND s.sticker_type = 'super' AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2,3
),
rd AS (SELECT r.album_id, r.user_id, DATE_DIFF(r.d, p.a_start, DAY) + 1 AS day FROM r JOIN pop p USING (album_id, user_id)),
alen AS (SELECT album_id, DATE_DIFF(ANY_VALUE(a_end), ANY_VALUE(a_start), DAY) + 1 AS n_days FROM pop GROUP BY 1),
nr AS (SELECT album_id, COUNT(DISTINCT sticker_id) AS n_rares FROM r GROUP BY 1),
xg AS (SELECT a.album_id, x, CAST(ROUND(x / 100 * a.n_days) AS INT64) AS day FROM alen a, UNNEST(GENERATE_ARRAY(0, 100, 5)) AS x),
held AS (
  SELECT p.album_id, p.user_id, xg.x, 100 * COUNTIF(rd.day <= xg.day) / ANY_VALUE(nr.n_rares) AS pct
  FROM pop p JOIN xg USING (album_id) JOIN nr USING (album_id)
  LEFT JOIN rd ON rd.album_id = p.album_id AND rd.user_id = p.user_id
  GROUP BY 1,2,3
)
SELECT CAST(album_id AS STRING) AS album, x, COUNT(*) AS n, ANY_VALUE(nr.n_rares) AS n_rares,
  APPROX_QUANTILES(pct, 100)[OFFSET(50)] AS p50, ROUND(AVG(pct), 1) AS avg_pct
FROM held JOIN nr USING (album_id) GROUP BY 1,2
UNION ALL
SELECT 'pooled', x, COUNT(*), NULL, APPROX_QUANTILES(pct, 100)[OFFSET(50)], ROUND(AVG(pct), 1)
FROM held GROUP BY 1,2
ORDER BY 1,2
;

-- ===== domino-dreams-dbt =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_start, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND user_id NOT IN (SELECT user_id FROM bad_users)),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
pop AS (SELECT album_id, user_id, a_start, a_end, alb_rev FROM pop0 WHERE rev_c > 0),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_min_date) AS d
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND s.album_id IN (17,19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal' AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
rd AS (SELECT r.album_id, r.user_id, DATE_DIFF(r.d, p.a_start, DAY) + 1 AS day FROM r JOIN pop p USING (album_id, user_id)),
alen AS (SELECT album_id, DATE_DIFF(ANY_VALUE(a_end), ANY_VALUE(a_start), DAY) + 1 AS n_days FROM pop GROUP BY 1),
nr AS (SELECT album_id, COUNT(DISTINCT sticker_id) AS n_rares FROM r GROUP BY 1),
xg AS (SELECT a.album_id, x, CAST(ROUND(x / 100 * a.n_days) AS INT64) AS day FROM alen a, UNNEST(GENERATE_ARRAY(0, 100, 5)) AS x),
held AS (
  SELECT p.album_id, p.user_id, xg.x, 100 * COUNTIF(rd.day <= xg.day) / ANY_VALUE(nr.n_rares) AS pct
  FROM pop p JOIN xg USING (album_id) JOIN nr USING (album_id)
  LEFT JOIN rd ON rd.album_id = p.album_id AND rd.user_id = p.user_id
  GROUP BY 1,2,3
)
SELECT CAST(album_id AS STRING) AS album, x, COUNT(*) AS n, ANY_VALUE(nr.n_rares) AS n_rares,
  APPROX_QUANTILES(pct, 100)[OFFSET(50)] AS p50, ROUND(AVG(pct), 1) AS avg_pct
FROM held JOIN nr USING (album_id) GROUP BY 1,2
UNION ALL
SELECT 'pooled', x, COUNT(*), NULL, APPROX_QUANTILES(pct, 100)[OFFSET(50)], ROUND(AVG(pct), 1)
FROM held GROUP BY 1,2
ORDER BY 1,2
;

-- ===== solitaire-dreams-411507 =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND album_id IN (12,14,15) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_start, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND user_id NOT IN (SELECT user_id FROM bad_users)),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
pop AS (SELECT album_id, user_id, a_start, a_end, alb_rev FROM pop0 WHERE rev_c > 0),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_min_date) AS d
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND s.album_id IN (12,14,15)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal' AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
rd AS (SELECT r.album_id, r.user_id, DATE_DIFF(r.d, p.a_start, DAY) + 1 AS day FROM r JOIN pop p USING (album_id, user_id)),
alen AS (SELECT album_id, DATE_DIFF(ANY_VALUE(a_end), ANY_VALUE(a_start), DAY) + 1 AS n_days FROM pop GROUP BY 1),
nr AS (SELECT album_id, COUNT(DISTINCT sticker_id) AS n_rares FROM r GROUP BY 1),
xg AS (SELECT a.album_id, x, CAST(ROUND(x / 100 * a.n_days) AS INT64) AS day FROM alen a, UNNEST(GENERATE_ARRAY(0, 100, 5)) AS x),
held AS (
  SELECT p.album_id, p.user_id, xg.x, 100 * COUNTIF(rd.day <= xg.day) / ANY_VALUE(nr.n_rares) AS pct
  FROM pop p JOIN xg USING (album_id) JOIN nr USING (album_id)
  LEFT JOIN rd ON rd.album_id = p.album_id AND rd.user_id = p.user_id
  GROUP BY 1,2,3
)
SELECT CAST(album_id AS STRING) AS album, x, COUNT(*) AS n, ANY_VALUE(nr.n_rares) AS n_rares,
  APPROX_QUANTILES(pct, 100)[OFFSET(50)] AS p50, ROUND(AVG(pct), 1) AS avg_pct
FROM held JOIN nr USING (album_id) GROUP BY 1,2
UNION ALL
SELECT 'pooled', x, COUNT(*), NULL, APPROX_QUANTILES(pct, 100)[OFFSET(50)], ROUND(AVG(pct), 1)
FROM held GROUP BY 1,2
ORDER BY 1,2
;
