-- 2026-10-28 (Eden): size of 'Steady Royal Source' test audience = standard payers, P50-95 of spend up to 75% of the album, 4+ of 144 stickers missing at end of close-14. Domino 20 and Disney 15.
-- ===== DOMINO 20 =====
WITH ud AS (
  SELECT user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(login_ratio,-1) AS lr,
    IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
pay AS (
  SELECT user_id, SUM(IF(date_dim < a_end, spend, 0)) AS rev,
    SUM(IF(DATE_DIFF(date_dim, a_start, DAY) < CAST(CEIL(0.75 * (DATE_DIFF(a_end, a_start, DAY) + 1)) AS INT64), spend, 0)) AS rev75,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 14 DAY), uniq, NULL)) AS u14
  FROM ud GROUP BY user_id, a_end
  HAVING MAX(IF(date_dim < a_end, date_dim, NULL)) = DATE_SUB(a_end, INTERVAL 1 DAY)
    AND ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND ARRAY_AGG(IF(date_dim < a_end, uac, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
    AND NOT LOGICAL_OR(excl) AND SUM(spend) > 0),
p AS (SELECT * FROM pay WHERE user_id NOT IN (SELECT user_id FROM bad)),
q AS (SELECT APPROX_QUANTILES(rev75, 100)[OFFSET(50)] AS q50, APPROX_QUANTILES(rev75, 100)[OFFSET(95)] AS q95 FROM p),
t AS (SELECT p.rev, p.rev75 >= q.q50 AND p.rev75 < q.q95 AND 144 - IFNULL(p.u14, 0) >= 4 AS aud FROM p CROSS JOIN q)
SELECT COUNT(*) AS payers, COUNTIF(aud) AS aud_payers, ROUND(100*COUNTIF(aud)/COUNT(*),1) AS pct_payers,
  ROUND(SUM(IF(aud, rev, 0))) AS aud_rev, ROUND(100*SUM(IF(aud, rev, 0))/SUM(rev),1) AS pct_rev FROM t;
-- ===== DISNEY 15 =====
WITH ud AS (
  SELECT user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(login_ratio,-1) AS lr,
    IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-06' AND album_id = 15 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-06' AND exclude_reason IS NOT NULL),
pay AS (
  SELECT user_id, SUM(IF(date_dim < a_end, spend, 0)) AS rev,
    SUM(IF(DATE_DIFF(date_dim, a_start, DAY) < CAST(CEIL(0.75 * (DATE_DIFF(a_end, a_start, DAY) + 1)) AS INT64), spend, 0)) AS rev75,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 14 DAY), uniq, NULL)) AS u14
  FROM ud GROUP BY user_id, a_end
  HAVING MAX(IF(date_dim < a_end, date_dim, NULL)) = DATE_SUB(a_end, INTERVAL 1 DAY)
    AND ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND ARRAY_AGG(IF(date_dim < a_end, uac, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
    AND NOT LOGICAL_OR(excl) AND SUM(spend) > 0),
p AS (SELECT * FROM pay WHERE user_id NOT IN (SELECT user_id FROM bad)),
q AS (SELECT APPROX_QUANTILES(rev75, 100)[OFFSET(50)] AS q50, APPROX_QUANTILES(rev75, 100)[OFFSET(95)] AS q95 FROM p),
t AS (SELECT p.rev, p.rev75 >= q.q50 AND p.rev75 < q.q95 AND 144 - IFNULL(p.u14, 0) >= 4 AS aud FROM p CROSS JOIN q)
SELECT COUNT(*) AS payers, COUNTIF(aud) AS aud_payers, ROUND(100*COUNTIF(aud)/COUNT(*),1) AS pct_payers,
  ROUND(SUM(IF(aud, rev, 0))) AS aud_rev, ROUND(100*SUM(IF(aud, rev, 0))/SUM(rev),1) AS pct_rev FROM t;
-- RESULTS 2026-10-28. Wide rule: Domino 20 48,038 (45% payers, 50% rev); Disney 15 146,589 (45%, 50%).
-- OPTION C (Eden): + no new Royal between close-19 and close-14 (unique_royal_stickers_tl at d-14 <= at d-19):
-- Domino 20: 19,723 (18.5% of payers, 19.7% of album rev, $2,524,384). Disney 15: 62,701 (19.2%, 25.3%, $9,230,312).
