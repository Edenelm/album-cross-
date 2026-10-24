-- 2026-10-21 (Eden): same check as gate_distance_finish_queries.sql, with Eden's definition of "easy":
--   easy = paid below the previous album's p50 and did not finish it, or new (no row in the previous album).
--   Classes: easy_paid (0 < previous-album spend < p50, not finished), easy_zero (spend 0 in the previous album, not finished),
--   new (no previous-album row), not_easy (finished the previous album or spend >= p50); easy_all = the three easy classes together.
--   p50 = median album spend (album table, start..close-1) among players with spend > 0 in the previous album, all players: my choice.
-- Previous albums: Domino 18/19, Dice 59/61, Disney 13/14. Everything else as in gate_distance_finish_queries.sql.
-- Results: claude/gate-distance-finish-2026-10-21.md (section 5)

-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12' AND album_id IN (18,19,20) AND date_dim <= album_close_date
),
alb AS (SELECT album_id, MIN(a_start) AS a_start, MIN(a_end) AS a_end FROM ud WHERE album_id IN (19,20) GROUP BY 1),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(special_user_flag,FALSE) OR IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
tot AS (
  SELECT a.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN alb a ON m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1
),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_close,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), spend, 0)) AS rev_c4,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), spend, 0)) AS rev_c3,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS uniq_c4,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), uniq, NULL)) AS uniq_c3,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
prev AS (SELECT album_id + 1 AS album_id, user_id, alb_rev AS prev_rev, uniq_close >= 144 AS prev_fin FROM ua WHERE album_id IN (18,19)),
p50 AS (SELECT album_id, APPROX_QUANTILES(prev_rev, 100)[OFFSET(50)] AS med FROM prev WHERE prev_rev > 0 GROUP BY 1),
u1 AS (SELECT album_id, user_id, a_start, a_end, uniq_close, alb_rev, last_d, rev_c4, rev_c3, uniq_c4, uniq_c3, l.lr AS lr, l.past AS past, l.excl AS excl FROM ua WHERE album_id IN (19,20)),
pop AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end, u.uniq_close, u.alb_rev, u.rev_c4, u.rev_c3, u.uniq_c4, u.uniq_c3, m.med,
    CASE WHEN p.user_id IS NULL THEN 'new' WHEN p.prev_fin OR p.prev_rev >= m.med THEN 'not_easy'
         WHEN p.prev_rev = 0 THEN 'easy_zero' ELSE 'easy_paid' END AS cls
  FROM u1 u LEFT JOIN prev p USING (album_id, user_id) JOIN p50 m USING (album_id)
  WHERE u.last_d = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
cp AS (
  SELECT album_id, user_id, alb_rev, uniq_close >= 144 AS fin, cls, med, k, miss
  FROM pop, UNNEST([
    STRUCT('c4' AS k, 144 - uniq_c4 AS miss),
    STRUCT('c3', 144 - uniq_c3)
  ])
  WHERE miss BETWEEN 3 AND 5
),
lab AS (
  SELECT album_id, k, miss, fin, alb_rev, med, label
  FROM cp, UNNEST(IF(cls = 'not_easy', [cls], [cls, 'easy_all'])) AS label
)
SELECT l.album_id, l.k, l.miss, l.label, COUNT(*) AS n, COUNTIF(l.fin) AS n_fin,
  ROUND(COUNTIF(l.fin) / COUNT(*), 3) AS fin_rate,
  ROUND(SUM(l.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev,
  ROUND(ANY_VALUE(l.med), 2) AS p50_prev
FROM lab l JOIN tot t USING (album_id)
GROUP BY 1,2,3,4 ORDER BY 1,2,3,4
;

-- ===== DICE 61/63 (dice-dreams-dbt); previous albums 59/61 =====
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MIN(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (59,61,63)
  GROUP BY 1
),
ud AS (
  SELECT album_id, user_id, date_dim,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-06' AND album_id IN (59,61,63) AND date_dim < album_end_date
),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (59,61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= a.a_end
  GROUP BY 1,2
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06'
),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
tot AS (
  SELECT a.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN alb a ON m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE a.album_id IN (61,63) AND m.user_id NOT IN (SELECT user_id FROM excl)
  GROUP BY 1
),
ua AS (
  SELECT u.album_id, u.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end, MAX(u.uniq) AS uniq_prev,
    SUM(u.spend) AS alb_rev, MAX(u.date_dim) AS last_d,
    SUM(IF(u.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), u.spend, 0)) AS rev_c4,
    SUM(IF(u.date_dim <= DATE_SUB(a.a_end, INTERVAL 3 DAY), u.spend, 0)) AS rev_c3,
    MAX(IF(u.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), u.uniq, NULL)) AS uniq_c4,
    MAX(IF(u.date_dim <= DATE_SUB(a.a_end, INTERVAL 3 DAY), u.uniq, NULL)) AS uniq_c3,
    ARRAY_AGG(STRUCT(u.lr AS lr, u.past AS past, u.excl AS excl) ORDER BY u.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud u JOIN alb a USING (album_id) GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_start, a_end, uniq_prev, alb_rev, last_d, rev_c4, rev_c3, uniq_c4, uniq_c3, l.lr AS lr, l.past AS past, l.excl AS excl FROM ua),
ub AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end, u.alb_rev, u.last_d, u.rev_c4, u.rev_c3, u.uniq_c4, u.uniq_c3,
    GREATEST(IFNULL(s.n_uniq, 0), IFNULL(u.uniq_prev, 0)) AS uniq_close, u.lr, u.past, u.excl
  FROM u1 u LEFT JOIN st s USING (album_id, user_id)
),
prev AS (SELECT album_id + 2 AS album_id, user_id, alb_rev AS prev_rev, uniq_close >= 144 AS prev_fin FROM ub WHERE album_id IN (59,61)),
p50 AS (SELECT album_id, APPROX_QUANTILES(prev_rev, 100)[OFFSET(50)] AS med FROM prev WHERE prev_rev > 0 GROUP BY 1),
pop AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end, u.uniq_close, u.alb_rev, u.rev_c4, u.rev_c3, u.uniq_c4, u.uniq_c3, m.med,
    CASE WHEN p.user_id IS NULL THEN 'new' WHEN p.prev_fin OR p.prev_rev >= m.med THEN 'not_easy'
         WHEN p.prev_rev = 0 THEN 'easy_zero' ELSE 'easy_paid' END AS cls
  FROM ub u LEFT JOIN prev p USING (album_id, user_id) JOIN p50 m USING (album_id)
  WHERE u.album_id IN (61,63) AND u.last_d = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
),
cp AS (
  SELECT album_id, user_id, alb_rev, uniq_close >= 144 AS fin, cls, med, k, miss
  FROM pop, UNNEST([
    STRUCT('c4' AS k, 144 - uniq_c4 AS miss),
    STRUCT('c3', 144 - uniq_c3)
  ])
  WHERE miss BETWEEN 3 AND 5
),
lab AS (
  SELECT album_id, k, miss, fin, alb_rev, med, label
  FROM cp, UNNEST(IF(cls = 'not_easy', [cls], [cls, 'easy_all'])) AS label
)
SELECT l.album_id, l.k, l.miss, l.label, COUNT(*) AS n, COUNTIF(l.fin) AS n_fin,
  ROUND(COUNTIF(l.fin) / COUNT(*), 3) AS fin_rate,
  ROUND(SUM(l.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev,
  ROUND(ANY_VALUE(l.med), 2) AS p50_prev
FROM lab l JOIN tot t USING (album_id)
GROUP BY 1,2,3,4 ORDER BY 1,2,3,4
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507); previous albums 13/14 =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND album_id IN (13,14,15) AND date_dim <= album_close_date
),
alb AS (SELECT album_id, MIN(a_start) AS a_start, MIN(a_end) AS a_end FROM ud WHERE album_id IN (14,15) GROUP BY 1),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
tot AS (
  SELECT a.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN alb a ON m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1
),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_close,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), spend, 0)) AS rev_c4,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), spend, 0)) AS rev_c3,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS uniq_c4,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), uniq, NULL)) AS uniq_c3,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
prev AS (SELECT album_id + 1 AS album_id, user_id, alb_rev AS prev_rev, uniq_close >= 144 AS prev_fin FROM ua WHERE album_id IN (13,14)),
p50 AS (SELECT album_id, APPROX_QUANTILES(prev_rev, 100)[OFFSET(50)] AS med FROM prev WHERE prev_rev > 0 GROUP BY 1),
u1 AS (SELECT album_id, user_id, a_start, a_end, uniq_close, alb_rev, last_d, rev_c4, rev_c3, uniq_c4, uniq_c3, l.lr AS lr, l.past AS past, l.excl AS excl FROM ua WHERE album_id IN (14,15)),
pop AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end, u.uniq_close, u.alb_rev, u.rev_c4, u.rev_c3, u.uniq_c4, u.uniq_c3, m.med,
    CASE WHEN p.user_id IS NULL THEN 'new' WHEN p.prev_fin OR p.prev_rev >= m.med THEN 'not_easy'
         WHEN p.prev_rev = 0 THEN 'easy_zero' ELSE 'easy_paid' END AS cls
  FROM u1 u LEFT JOIN prev p USING (album_id, user_id) JOIN p50 m USING (album_id)
  WHERE u.last_d = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
cp AS (
  SELECT album_id, user_id, alb_rev, uniq_close >= 144 AS fin, cls, med, k, miss
  FROM pop, UNNEST([
    STRUCT('c4' AS k, 144 - uniq_c4 AS miss),
    STRUCT('c3', 144 - uniq_c3)
  ])
  WHERE miss BETWEEN 3 AND 5
),
lab AS (
  SELECT album_id, k, miss, fin, alb_rev, med, label
  FROM cp, UNNEST(IF(cls = 'not_easy', [cls], [cls, 'easy_all'])) AS label
)
SELECT l.album_id, l.k, l.miss, l.label, COUNT(*) AS n, COUNTIF(l.fin) AS n_fin,
  ROUND(COUNTIF(l.fin) / COUNT(*), 3) AS fin_rate,
  ROUND(SUM(l.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev,
  ROUND(ANY_VALUE(l.med), 2) AS p50_prev
FROM lab l JOIN tot t USING (album_id)
GROUP BY 1,2,3,4 ORDER BY 1,2,3,4
;
