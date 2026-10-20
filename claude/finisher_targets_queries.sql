-- Finisher targets by spend group (2026-10-18). Same body for all games; previous album = previous by start date (Dice ids jump by 2).
-- ===== DICE (61,63; prev 59,61) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim < album_end_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act, FALSE AS bad
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-09-07'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
alb0 AS (SELECT album_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM ud GROUP BY 1),
alb AS (SELECT album_id, a_start, a_end, LAG(album_id) OVER (ORDER BY a_start) AS prev_id FROM alb0),
tgt AS (
  SELECT a.album_id, a.a_start, a.a_end, p.a_start AS p_start, p.a_end AS p_end,
    DATE_ADD(a.a_start, INTERVAL CAST(FLOOR(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) DAY) AS q4_start
  FROM alb a JOIN alb p ON p.album_id = a.prev_id
  WHERE a.album_id IN (61,63)
),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.p_start, t.p_end, t.q4_start, u.uniq AS uniq_end
  FROM ud u JOIN tgt t USING (album_id)
  WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
c4 AS (
  SELECT u.album_id, u.user_id, u.uniq AS uniq_c4
  FROM ud u JOIN tgt t USING (album_id) WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 4 DAY)
),
pu AS (
  SELECT p.album_id, p.user_id, p.uniq_end, IFNULL(c.uniq_c4, 0) AS uniq_c4,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 4 DAY), m.rev, 0)) AS rev_c4,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.q4_start, INTERVAL 1 DAY), m.rev, 0)) AS rev_q,
    COUNTIF(m.act AND m.date_dim BETWEEN p.a_start AND DATE_SUB(p.q4_start, INTERVAL 1 DAY)) AS ad_q,
    SUM(IF(m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_prev,
    COUNTIF(m.act AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY)) AS ad_prev
  FROM pop p
  LEFT JOIN c4 c USING (album_id, user_id)
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.p_start AND p.a_end
  GROUP BY 1,2,3,4
),
payers AS (SELECT album_id, user_id, uniq_end, uniq_c4, rev_alb, rev_c4,
    SAFE_DIVIDE(rev_prev, ad_prev) AS lvl_x, SAFE_DIVIDE(rev_q, ad_q) AS tier_x
  FROM pu WHERE rev_alb > 0),
d AS (
  SELECT album_id, user_id, uniq_end, uniq_c4, rev_alb, rev_c4, s.dim,
    CASE WHEN s.x IS NULL OR s.x = 0 THEN 'g0' WHEN s.x <= 2 THEN 'g1_le2' WHEN s.x <= 5 THEN 'g2_2_5'
         WHEN s.x <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END AS grp
  FROM payers CROSS JOIN UNNEST([STRUCT('level' AS dim, lvl_x AS x), STRUCT('tier', tier_x)]) s
),
agg AS (
  SELECT album_id, dim, grp, COUNT(*) AS n, SUM(rev_alb) AS rev, SUM(rev_c4) AS rev4,
    COUNTIF(uniq_end >= 144) AS fin_n, SUM(IF(uniq_end >= 144, rev_alb, 0)) AS fin_rev,
    COUNTIF(uniq_c4 >= 144) AS fin4_n, SUM(IF(uniq_c4 >= 144, rev_c4, 0)) AS fin4_rev
  FROM d GROUP BY 1,2,3
  UNION ALL
  SELECT album_id, dim, 'all', COUNT(*), SUM(rev_alb), SUM(rev_c4),
    COUNTIF(uniq_end >= 144), SUM(IF(uniq_end >= 144, rev_alb, 0)),
    COUNTIF(uniq_c4 >= 144), SUM(IF(uniq_c4 >= 144, rev_c4, 0))
  FROM d GROUP BY 1,2
)
SELECT album_id, dim, grp, n AS payers,
  ROUND(100 * n / SUM(IF(grp = 'all', n, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_payers,
  ROUND(100 * rev / SUM(IF(grp = 'all', rev, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_rev,
  ROUND(100 * fin_n / n, 1) AS fin_pct_end,
  ROUND(100 * SAFE_DIVIDE(fin_rev, rev), 1) AS fin_revshare_end,
  ROUND(100 * fin4_n / n, 1) AS fin_pct_c4,
  ROUND(100 * SAFE_DIVIDE(fin4_rev, rev4), 1) AS fin_revshare_c4
FROM agg ORDER BY album_id, dim, grp

-- ===== DOMINO (19,20; prev 18,19) — window 2026-03-01..2026-10-12 =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12' AND album_id IN (18,19,20) AND date_dim < album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
alb0 AS (SELECT album_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM ud GROUP BY 1),
alb AS (SELECT album_id, a_start, a_end, LAG(album_id) OVER (ORDER BY a_start) AS prev_id FROM alb0),
tgt AS (
  SELECT a.album_id, a.a_start, a.a_end, p.a_start AS p_start, p.a_end AS p_end,
    DATE_ADD(a.a_start, INTERVAL CAST(FLOOR(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) DAY) AS q4_start
  FROM alb a JOIN alb p ON p.album_id = a.prev_id
  WHERE a.album_id IN (19,20)
),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.p_start, t.p_end, t.q4_start, u.uniq AS uniq_end
  FROM ud u JOIN tgt t USING (album_id)
  WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
c4 AS (
  SELECT u.album_id, u.user_id, u.uniq AS uniq_c4
  FROM ud u JOIN tgt t USING (album_id) WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 4 DAY)
),
pu AS (
  SELECT p.album_id, p.user_id, p.uniq_end, IFNULL(c.uniq_c4, 0) AS uniq_c4,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 4 DAY), m.rev, 0)) AS rev_c4,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.q4_start, INTERVAL 1 DAY), m.rev, 0)) AS rev_q,
    COUNTIF(m.act AND m.date_dim BETWEEN p.a_start AND DATE_SUB(p.q4_start, INTERVAL 1 DAY)) AS ad_q,
    SUM(IF(m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_prev,
    COUNTIF(m.act AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY)) AS ad_prev
  FROM pop p
  LEFT JOIN c4 c USING (album_id, user_id)
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.p_start AND p.a_end
  GROUP BY 1,2,3,4
),
payers AS (SELECT album_id, user_id, uniq_end, uniq_c4, rev_alb, rev_c4,
    SAFE_DIVIDE(rev_prev, ad_prev) AS lvl_x, SAFE_DIVIDE(rev_q, ad_q) AS tier_x
  FROM pu WHERE rev_alb > 0),
d AS (
  SELECT album_id, user_id, uniq_end, uniq_c4, rev_alb, rev_c4, s.dim,
    CASE WHEN s.x IS NULL OR s.x = 0 THEN 'g0' WHEN s.x <= 2 THEN 'g1_le2' WHEN s.x <= 5 THEN 'g2_2_5'
         WHEN s.x <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END AS grp
  FROM payers CROSS JOIN UNNEST([STRUCT('level' AS dim, lvl_x AS x), STRUCT('tier', tier_x)]) s
),
agg AS (
  SELECT album_id, dim, grp, COUNT(*) AS n, SUM(rev_alb) AS rev, SUM(rev_c4) AS rev4,
    COUNTIF(uniq_end >= 144) AS fin_n, SUM(IF(uniq_end >= 144, rev_alb, 0)) AS fin_rev,
    COUNTIF(uniq_c4 >= 144) AS fin4_n, SUM(IF(uniq_c4 >= 144, rev_c4, 0)) AS fin4_rev
  FROM d GROUP BY 1,2,3
  UNION ALL
  SELECT album_id, dim, 'all', COUNT(*), SUM(rev_alb), SUM(rev_c4),
    COUNTIF(uniq_end >= 144), SUM(IF(uniq_end >= 144, rev_alb, 0)),
    COUNTIF(uniq_c4 >= 144), SUM(IF(uniq_c4 >= 144, rev_c4, 0))
  FROM d GROUP BY 1,2
)
SELECT album_id, dim, grp, n AS payers,
  ROUND(100 * n / SUM(IF(grp = 'all', n, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_payers,
  ROUND(100 * rev / SUM(IF(grp = 'all', rev, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_rev,
  ROUND(100 * fin_n / n, 1) AS fin_pct_end,
  ROUND(100 * SAFE_DIVIDE(fin_rev, rev), 1) AS fin_revshare_end,
  ROUND(100 * fin4_n / n, 1) AS fin_pct_c4,
  ROUND(100 * SAFE_DIVIDE(fin4_rev, rev4), 1) AS fin_revshare_c4
FROM agg ORDER BY album_id, dim, grp

-- ===== DISNEY (14,15; prev 13,14) — window 2026-05-01..2026-10-05 =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND album_id IN (13,14,15) AND date_dim < album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
alb0 AS (SELECT album_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM ud GROUP BY 1),
alb AS (SELECT album_id, a_start, a_end, LAG(album_id) OVER (ORDER BY a_start) AS prev_id FROM alb0),
tgt AS (
  SELECT a.album_id, a.a_start, a.a_end, p.a_start AS p_start, p.a_end AS p_end,
    DATE_ADD(a.a_start, INTERVAL CAST(FLOOR(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) DAY) AS q4_start
  FROM alb a JOIN alb p ON p.album_id = a.prev_id
  WHERE a.album_id IN (14,15)
),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.p_start, t.p_end, t.q4_start, u.uniq AS uniq_end
  FROM ud u JOIN tgt t USING (album_id)
  WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
c4 AS (
  SELECT u.album_id, u.user_id, u.uniq AS uniq_c4
  FROM ud u JOIN tgt t USING (album_id) WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 4 DAY)
),
pu AS (
  SELECT p.album_id, p.user_id, p.uniq_end, IFNULL(c.uniq_c4, 0) AS uniq_c4,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 4 DAY), m.rev, 0)) AS rev_c4,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.q4_start, INTERVAL 1 DAY), m.rev, 0)) AS rev_q,
    COUNTIF(m.act AND m.date_dim BETWEEN p.a_start AND DATE_SUB(p.q4_start, INTERVAL 1 DAY)) AS ad_q,
    SUM(IF(m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_prev,
    COUNTIF(m.act AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY)) AS ad_prev
  FROM pop p
  LEFT JOIN c4 c USING (album_id, user_id)
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.p_start AND p.a_end
  GROUP BY 1,2,3,4
),
payers AS (SELECT album_id, user_id, uniq_end, uniq_c4, rev_alb, rev_c4,
    SAFE_DIVIDE(rev_prev, ad_prev) AS lvl_x, SAFE_DIVIDE(rev_q, ad_q) AS tier_x
  FROM pu WHERE rev_alb > 0),
d AS (
  SELECT album_id, user_id, uniq_end, uniq_c4, rev_alb, rev_c4, s.dim,
    CASE WHEN s.x IS NULL OR s.x = 0 THEN 'g0' WHEN s.x <= 2 THEN 'g1_le2' WHEN s.x <= 5 THEN 'g2_2_5'
         WHEN s.x <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END AS grp
  FROM payers CROSS JOIN UNNEST([STRUCT('level' AS dim, lvl_x AS x), STRUCT('tier', tier_x)]) s
),
agg AS (
  SELECT album_id, dim, grp, COUNT(*) AS n, SUM(rev_alb) AS rev, SUM(rev_c4) AS rev4,
    COUNTIF(uniq_end >= 144) AS fin_n, SUM(IF(uniq_end >= 144, rev_alb, 0)) AS fin_rev,
    COUNTIF(uniq_c4 >= 144) AS fin4_n, SUM(IF(uniq_c4 >= 144, rev_c4, 0)) AS fin4_rev
  FROM d GROUP BY 1,2,3
  UNION ALL
  SELECT album_id, dim, 'all', COUNT(*), SUM(rev_alb), SUM(rev_c4),
    COUNTIF(uniq_end >= 144), SUM(IF(uniq_end >= 144, rev_alb, 0)),
    COUNTIF(uniq_c4 >= 144), SUM(IF(uniq_c4 >= 144, rev_c4, 0))
  FROM d GROUP BY 1,2
)
SELECT album_id, dim, grp, n AS payers,
  ROUND(100 * n / SUM(IF(grp = 'all', n, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_payers,
  ROUND(100 * rev / SUM(IF(grp = 'all', rev, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_rev,
  ROUND(100 * fin_n / n, 1) AS fin_pct_end,
  ROUND(100 * SAFE_DIVIDE(fin_rev, rev), 1) AS fin_revshare_end,
  ROUND(100 * fin4_n / n, 1) AS fin_pct_c4,
  ROUND(100 * SAFE_DIVIDE(fin4_rev, rev4), 1) AS fin_revshare_c4
FROM agg ORDER BY album_id, dim, grp
