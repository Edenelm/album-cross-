-- Finisher recount 2026-10-19 (Eden approved). Finisher = 144 unique set stickers by END of close day. Results: claude/finisher-recount-2026-10-19.md

-- ===== DICE: finishers before close by daily table (old/new side by side, 10.2 GB) =====
-- RECOUNT wave 1 — DICE albums 59, 61, 63. Finisher = 144 unique set stickers by END of close day (Eden 2026-10-19).
-- Old rule kept side by side (144 on a row before the close day) to tie back to the deck.
-- Standard population: not first album, not excluded, login ratio >= 0.5 on the last row before close, has a row on close-1.
-- Revenue = album-table spend, album start .. close-1 (unchanged).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, DATE(user_album_finish_ts) AS flag_d
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    MIN(IF(flag_d <= a_end, flag_d, NULL)) AS flag_fin_d,
    MAX(IF(date_dim = a_end, 1, 0)) AS has_close_row,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, flag_fin_d, has_close_row, alb_rev, alb_rev > 0 AS payer,
    IF(fin_d IS NULL, NULL, DATE_DIFF(a_end, fin_d, DAY)) AS k
  FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
)
SELECT album_id, 'total' AS row_type, NULL AS k,
  COUNT(*) AS pop_all, COUNTIF(payer) AS pop_payers, ROUND(SUM(alb_rev)) AS pop_rev,
  COUNTIF(k >= 1) AS fin_all_old, COUNTIF(k >= 1 AND payer) AS fin_pay_old, ROUND(SUM(IF(k >= 1, alb_rev, 0))) AS fin_rev_old,
  COUNTIF(k >= 0) AS fin_all_new, COUNTIF(k >= 0 AND payer) AS fin_pay_new, ROUND(SUM(IF(k >= 0, alb_rev, 0))) AS fin_rev_new,
  COUNTIF(flag_fin_d IS NOT NULL) AS flag_all, COUNTIF(flag_fin_d IS NOT NULL AND payer) AS flag_pay,
  COUNTIF(flag_fin_d IS NOT NULL AND fin_d IS NULL) AS flag_not_144,
  COUNTIF(has_close_row = 1) AS with_close_row
FROM pop GROUP BY 1
UNION ALL
SELECT album_id, 'by_day', LEAST(k, 15),
  NULL, NULL, NULL, NULL, NULL, NULL,
  COUNT(*), COUNTIF(payer), ROUND(SUM(alb_rev)), NULL, NULL, NULL, NULL
FROM pop WHERE k >= 0 GROUP BY 1,3
ORDER BY 1, 2 DESC, 3
;

-- ===== DICE: close-day finishers from sticker table (27.7 GB) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-06' AND album_id IN (59,61,63) AND date_dim < album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d_daily,
    SUM(spend) AS alb_rev,
    ARRAY_AGG(STRUCT(lr, past, excl) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l, MAX(date_dim) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d_daily, alb_rev, alb_rev > 0 AS payer
  FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
st AS (
  SELECT album_id, user_id, COUNT(DISTINCT sticker_id) AS n_uniq, MAX(sticker_collected_ts) AS last_ts
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers`
  WHERE sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (59,61,63)
    AND sticker_type IN ('common','golden','super') AND IFNULL(is_sticker_collected, TRUE)
  GROUP BY 1,2
),
j AS (
  SELECT p.album_id, p.user_id, p.a_end, p.fin_d_daily, p.alb_rev, p.payer, s.n_uniq,
    IF(s.n_uniq >= 144 AND DATE(s.last_ts) <= p.a_end, DATE_DIFF(p.a_end, DATE(s.last_ts), DAY), NULL) AS k
  FROM pop p LEFT JOIN st s USING (album_id, user_id)
)
SELECT album_id, IFNULL(CAST(LEAST(k, 15) AS STRING), 'not_fin') AS k_bucket,
  COUNT(*) AS n, COUNTIF(payer) AS n_pay, ROUND(SUM(alb_rev)) AS rev,
  COUNTIF(fin_d_daily IS NOT NULL) AS daily_fin, COUNTIF(fin_d_daily IS NOT NULL AND payer) AS daily_fin_pay,
  COUNTIF(n_uniq > 144) AS over_144
FROM j GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DOMINO 17/19/20 (16.5 GB) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, IFNULL(album_finished_flag,FALSE) AS ff
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    MIN(IF(ff, date_dim, NULL)) AS flag_d,
    MAX(IF(date_dim = a_end, uniq, NULL)) AS uniq_close_row,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, flag_d, uniq_close_row, alb_rev, alb_rev > 0 AS payer,
    IF(fin_d IS NULL, NULL, DATE_DIFF(a_end, fin_d, DAY)) AS k
  FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
)
SELECT album_id, IFNULL(CAST(LEAST(k, 15) AS STRING), 'not_fin') AS k_bucket,
  COUNT(*) AS n, COUNTIF(payer) AS n_pay, ROUND(SUM(alb_rev)) AS rev,
  COUNTIF(flag_d IS NOT NULL) AS flag_fin, COUNTIF(flag_d IS NOT NULL AND payer) AS flag_fin_pay,
  COUNTIF(uniq_close_row IS NOT NULL) AS with_close_row
FROM pop GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DISNEY 12/14/15 (39.6 GB) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, IFNULL(album_finished_flag,FALSE) AS ff
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-05' AND album_id IN (12,14,15) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    MIN(IF(ff, date_dim, NULL)) AS flag_d,
    MAX(IF(date_dim = a_end, uniq, NULL)) AS uniq_close_row,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, flag_d, uniq_close_row, alb_rev, alb_rev > 0 AS payer,
    IF(fin_d IS NULL, NULL, DATE_DIFF(a_end, fin_d, DAY)) AS k
  FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
)
SELECT album_id, IFNULL(CAST(LEAST(k, 15) AS STRING), 'not_fin') AS k_bucket,
  COUNT(*) AS n, COUNTIF(payer) AS n_pay, ROUND(SUM(alb_rev)) AS rev,
  COUNTIF(flag_d IS NOT NULL) AS flag_fin, COUNTIF(flag_d IS NOT NULL AND payer) AS flag_fin_pay,
  COUNTIF(uniq_close_row IS NOT NULL) AS with_close_row
FROM pop GROUP BY 1,2 ORDER BY 1,2
;

-- ===== GROUPS by previous-album $/day — DICE 61/63 (23.5 GB) =====
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
  SELECT a.album_id, a.a_start, a.a_end, p.a_start AS p_start, p.a_end AS p_end
  FROM alb a JOIN alb p ON p.album_id = a.prev_id
  WHERE a.album_id IN (61,63)
),
finx AS (
  SELECT s.album_id, s.user_id, IF(COUNT(DISTINCT s.sticker_id) >= 144, 144, 0) AS uniq_max
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN alb0 a USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= a.a_end
  GROUP BY 1,2
),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.p_start, t.p_end, IFNULL(f.uniq_max, 0) >= 144 AS fin_new, u.uniq >= 144 AS fin_old
  FROM ud u JOIN tgt t USING (album_id) LEFT JOIN finx f USING (album_id, user_id)
  WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
pu AS (
  SELECT p.album_id, p.user_id, p.fin_new, p.fin_old,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb,
    SUM(IF(m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_prev,
    COUNTIF(m.act AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY)) AS ad_prev
  FROM pop p
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.p_start AND p.a_end
  GROUP BY 1,2,3,4
),
d AS (
  SELECT album_id, user_id, fin_new, fin_old, rev_alb, rev_alb > 0 AS payer,
    CASE WHEN SAFE_DIVIDE(rev_prev, ad_prev) IS NULL OR SAFE_DIVIDE(rev_prev, ad_prev) = 0 THEN 'g0'
         WHEN SAFE_DIVIDE(rev_prev, ad_prev) <= 2 THEN 'g1_le2' WHEN SAFE_DIVIDE(rev_prev, ad_prev) <= 5 THEN 'g2_2_5'
         WHEN SAFE_DIVIDE(rev_prev, ad_prev) <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END AS grp
  FROM pu
),
agg AS (
  SELECT album_id, grp, COUNT(*) AS elig, COUNTIF(fin_new) AS fin_all_new, COUNTIF(fin_old) AS fin_all_old,
    SUM(IF(fin_new, rev_alb, 0)) AS fin_rev_all_new,
    COUNTIF(payer) AS payers, SUM(rev_alb) AS rev, COUNTIF(payer AND fin_new) AS fin_pay_new, COUNTIF(payer AND fin_old) AS fin_pay_old,
    SUM(IF(fin_new, rev_alb, 0)) AS fin_rev_new
  FROM d GROUP BY 1,2
  UNION ALL
  SELECT album_id, 'all', COUNT(*), COUNTIF(fin_new), COUNTIF(fin_old), SUM(IF(fin_new, rev_alb, 0)),
    COUNTIF(payer), SUM(rev_alb), COUNTIF(payer AND fin_new), COUNTIF(payer AND fin_old), SUM(IF(fin_new, rev_alb, 0))
  FROM d GROUP BY 1
)
SELECT album_id, grp, elig, fin_all_old, fin_all_new, ROUND(fin_rev_all_new) AS fin_rev_new, payers, ROUND(rev) AS payer_rev,
  fin_pay_old, fin_pay_new
FROM agg ORDER BY album_id, grp
;

-- ===== GROUPS — DOMINO 19/20 (19.4 GB) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12' AND album_id IN (18,19,20) AND date_dim <= album_close_date
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
  SELECT a.album_id, a.a_start, a.a_end, p.a_start AS p_start, p.a_end AS p_end
  FROM alb a JOIN alb p ON p.album_id = a.prev_id
  WHERE a.album_id IN (19,20)
),
finx AS (SELECT album_id, user_id, MAX(uniq) AS uniq_max FROM ud WHERE album_id IN (19,20) GROUP BY 1,2),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.p_start, t.p_end, f.uniq_max >= 144 AS fin_new, u.uniq >= 144 AS fin_old
  FROM ud u JOIN tgt t USING (album_id) JOIN finx f USING (album_id, user_id)
  WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
pu AS (
  SELECT p.album_id, p.user_id, p.fin_new, p.fin_old,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb,
    SUM(IF(m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_prev,
    COUNTIF(m.act AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY)) AS ad_prev
  FROM pop p
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.p_start AND p.a_end
  GROUP BY 1,2,3,4
),
d AS (
  SELECT album_id, user_id, fin_new, fin_old, rev_alb, rev_alb > 0 AS payer,
    CASE WHEN SAFE_DIVIDE(rev_prev, ad_prev) IS NULL OR SAFE_DIVIDE(rev_prev, ad_prev) = 0 THEN 'g0'
         WHEN SAFE_DIVIDE(rev_prev, ad_prev) <= 2 THEN 'g1_le2' WHEN SAFE_DIVIDE(rev_prev, ad_prev) <= 5 THEN 'g2_2_5'
         WHEN SAFE_DIVIDE(rev_prev, ad_prev) <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END AS grp
  FROM pu
),
agg AS (
  SELECT album_id, grp, COUNT(*) AS elig, COUNTIF(fin_new) AS fin_all_new, COUNTIF(fin_old) AS fin_all_old,
    SUM(IF(fin_new, rev_alb, 0)) AS fin_rev_all_new,
    COUNTIF(payer) AS payers, SUM(rev_alb) AS rev, COUNTIF(payer AND fin_new) AS fin_pay_new, COUNTIF(payer AND fin_old) AS fin_pay_old,
    SUM(IF(fin_new, rev_alb, 0)) AS fin_rev_new
  FROM d GROUP BY 1,2
  UNION ALL
  SELECT album_id, 'all', COUNT(*), COUNTIF(fin_new), COUNTIF(fin_old), SUM(IF(fin_new, rev_alb, 0)),
    COUNTIF(payer), SUM(rev_alb), COUNTIF(payer AND fin_new), COUNTIF(payer AND fin_old), SUM(IF(fin_new, rev_alb, 0))
  FROM d GROUP BY 1
)
SELECT album_id, grp, elig, fin_all_old, fin_all_new, ROUND(fin_rev_all_new) AS fin_rev_new, payers, ROUND(rev) AS payer_rev,
  fin_pay_old, fin_pay_new
FROM agg ORDER BY album_id, grp
;

-- ===== GROUPS — DISNEY 14/15 (34.1 GB) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND album_id IN (13,14,15) AND date_dim <= album_close_date
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
  SELECT a.album_id, a.a_start, a.a_end, p.a_start AS p_start, p.a_end AS p_end
  FROM alb a JOIN alb p ON p.album_id = a.prev_id
  WHERE a.album_id IN (14,15)
),
finx AS (SELECT album_id, user_id, MAX(uniq) AS uniq_max FROM ud WHERE album_id IN (14,15) GROUP BY 1,2),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.p_start, t.p_end, f.uniq_max >= 144 AS fin_new, u.uniq >= 144 AS fin_old
  FROM ud u JOIN tgt t USING (album_id) JOIN finx f USING (album_id, user_id)
  WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
pu AS (
  SELECT p.album_id, p.user_id, p.fin_new, p.fin_old,
    SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb,
    SUM(IF(m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_prev,
    COUNTIF(m.act AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY)) AS ad_prev
  FROM pop p
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.p_start AND p.a_end
  GROUP BY 1,2,3,4
),
d AS (
  SELECT album_id, user_id, fin_new, fin_old, rev_alb, rev_alb > 0 AS payer,
    CASE WHEN SAFE_DIVIDE(rev_prev, ad_prev) IS NULL OR SAFE_DIVIDE(rev_prev, ad_prev) = 0 THEN 'g0'
         WHEN SAFE_DIVIDE(rev_prev, ad_prev) <= 2 THEN 'g1_le2' WHEN SAFE_DIVIDE(rev_prev, ad_prev) <= 5 THEN 'g2_2_5'
         WHEN SAFE_DIVIDE(rev_prev, ad_prev) <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END AS grp
  FROM pu
),
agg AS (
  SELECT album_id, grp, COUNT(*) AS elig, COUNTIF(fin_new) AS fin_all_new, COUNTIF(fin_old) AS fin_all_old,
    SUM(IF(fin_new, rev_alb, 0)) AS fin_rev_all_new,
    COUNTIF(payer) AS payers, SUM(rev_alb) AS rev, COUNTIF(payer AND fin_new) AS fin_pay_new, COUNTIF(payer AND fin_old) AS fin_pay_old,
    SUM(IF(fin_new, rev_alb, 0)) AS fin_rev_new
  FROM d GROUP BY 1,2
  UNION ALL
  SELECT album_id, 'all', COUNT(*), COUNTIF(fin_new), COUNTIF(fin_old), SUM(IF(fin_new, rev_alb, 0)),
    COUNTIF(payer), SUM(rev_alb), COUNTIF(payer AND fin_new), COUNTIF(payer AND fin_old), SUM(IF(fin_new, rev_alb, 0))
  FROM d GROUP BY 1
)
SELECT album_id, grp, elig, fin_all_old, fin_all_new, ROUND(fin_rev_all_new) AS fin_rev_new, payers, ROUND(rev) AS payer_rev,
  fin_pay_old, fin_pay_new
FROM agg ORDER BY album_id, grp
;

-- ===== dice_w2 =====
-- WAVE 2 recount — DICE 61/63. Finisher = 144 by END of close day; old rule (before close day) side by side.
-- Standard population, payers = album-table spend > 0 from start to close-1. Revenue / activity = daily metrics.
-- Usual = album start .. close-5. Last 4 = close-4 .. close-1. Window 1 = days 1-7 after own completion day. Window 2 = days 1-7 after close day.
-- The close day itself is left out of every daily average (half day).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-06' AND album_id IN (61,63) AND date_dim < album_end_date
),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq, DATE(MAX(s.sticker_collected_ts)) AS last_d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE)
  GROUP BY 1,2
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act, FALSE AS bad
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-16'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
maxd AS (SELECT MAX(date_dim) AS md FROM udm),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d0,
    MAX(IF(date_dim < a_end, uniq, NULL)) AS uniq_prev,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
u AS (
  SELECT u0.album_id, u0.user_id, u0.a_start, u0.a_end, u0.uniq_prev, u0.alb_rev, u0.l, u0.last_d,
    COALESCE(u0.fin_d0, IF(st.n_uniq >= 144 AND st.last_d <= u0.a_end, st.last_d, NULL)) AS fin_d,
    GREATEST(IFNULL(st.n_uniq, 0), IFNULL(u0.uniq_prev, 0)) AS uniq_close
  FROM u0 LEFT JOIN st USING (album_id, user_id)
),
pop AS (
  SELECT album_id, user_id, a_start, a_end, fin_d, uniq_close, uniq_prev, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pm AS (
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d,
    ANY_VALUE(p.uniq_close) AS uniq_close, ANY_VALUE(p.uniq_prev) AS uniq_prev, ANY_VALUE(p.alb_rev) AS alb_rev,
    SUM(IF(m.date_dim <= DATE_SUB(p.a_end, INTERVAL 5 DAY), m.rev, 0)) AS b_rev,
    COUNTIF(m.act AND m.date_dim <= DATE_SUB(p.a_end, INTERVAL 5 DAY)) AS b_ad,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 4 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)) AS l4_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 4 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY)) AS l4_ad,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 7 DAY) AND m.date_dim != p.a_end, m.rev, 0)) AS w1_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 7 DAY) AND m.date_dim != p.a_end) AS w1_ad,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 3 DAY) AND m.date_dim != p.a_end, m.rev, 0)) AS w13_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 3 DAY) AND m.date_dim != p.a_end) AS w13_ad,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.a_end, INTERVAL 1 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY), m.rev, 0)) AS w2_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_ADD(p.a_end, INTERVAL 1 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)) AS w2_ad
  FROM pop p LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.a_start AND DATE_ADD(p.a_end, INTERVAL 8 DAY)
  GROUP BY 1,2
),
lab AS (
  SELECT x.album_id, x.user_id, x.a_end, x.fin_d, x.alb_rev, x.b_rev, x.b_ad, x.l4_rev, x.l4_ad, x.w1_rev, x.w1_ad, x.w13_rev, x.w13_ad, x.w2_rev, x.w2_ad, label FROM pm x
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    IF(x.fin_d IS NOT NULL, ['w1_new'], []),
    IF(x.fin_d IS NOT NULL AND x.fin_d < x.a_end, ['w1_old'], []),
    IF(x.fin_d IS NOT NULL, [CONCAT('w1_t', CASE DATE_DIFF(x.a_end, x.fin_d, DAY) WHEN 0 THEN '0_close' WHEN 1 THEN '1_d1' WHEN 2 THEN '2_d23' WHEN 3 THEN '2_d23' ELSE '3_d4p' END)], []),
    [CONCAT('w2_new_', CASE WHEN x.uniq_close >= 144 THEN 'm0' WHEN x.uniq_close >= 141 THEN CONCAT('m', CAST(144 - x.uniq_close AS STRING)) ELSE 'm4p' END)],
    [CONCAT('w2_old_', CASE WHEN x.uniq_prev >= 144 THEN 'm0' WHEN x.uniq_prev >= 141 THEN CONCAT('m', CAST(144 - x.uniq_prev AS STRING)) ELSE 'm4p' END)],
    ['all_payers'])) AS label
),
agg AS (
SELECT album_id, label, COUNT(*) AS n, SUM(alb_rev) AS alb_rev,
  SUM(b_rev) AS b_rev, SUM(b_ad) AS b_ad, SUM(l4_rev) AS l4_rev, SUM(l4_ad) AS l4_ad,
  SUM(w1_rev) AS w1_rev, SUM(w1_ad) AS w1_ad, SUM(w13_rev) AS w13_rev, SUM(w13_ad) AS w13_ad,
  SUM(w2_rev) AS w2_rev, SUM(w2_ad) AS w2_ad,
  SUM(IF(fin_d IS NULL, 0, LEAST(7, GREATEST(0, DATE_DIFF(a_end, fin_d, DAY) - 1)))) AS w1_open_days,
  COUNTIF(fin_d IS NOT NULL AND DATE_ADD(fin_d, INTERVAL 1 DAY) >= a_end) AS next_d1,
  COUNTIF(fin_d IS NOT NULL AND DATE_ADD(fin_d, INTERVAL 3 DAY) >= a_end) AS next_d3,
  COUNTIF(fin_d IS NOT NULL AND DATE_ADD(fin_d, INTERVAL 7 DAY) <= md) AS n_obs_w1,
  COUNTIF(DATE_ADD(a_end, INTERVAL 7 DAY) <= md) AS n_obs_w2
FROM lab CROSS JOIN maxd
GROUP BY 1,2
)
SELECT album_id, label, n,
  ROUND(n / SUM(IF(label = 'all_payers', n, 0)) OVER (PARTITION BY album_id), 4) AS sh_payers,
  ROUND(alb_rev / SUM(IF(label = 'all_payers', alb_rev, 0)) OVER (PARTITION BY album_id), 4) AS sh_rev,
  ROUND(SAFE_DIVIDE(b_rev, b_ad), 2) AS arpdau_usual,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(l4_rev, l4_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS last4_vs_usual,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(w1_rev, w1_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS w1_d17_vs_usual,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(w13_rev, w13_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS w1_d13_vs_usual,
  ROUND(SAFE_DIVIDE(w1_open_days, 7 * n), 3) AS w1_open_share,
  ROUND(SAFE_DIVIDE(next_d1, n), 3) AS next_d1, ROUND(SAFE_DIVIDE(next_d3, n), 3) AS next_d3,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(w2_rev, w2_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS w2_d17_vs_usual,
  ROUND(SAFE_DIVIDE(w2_ad, 7 * n), 3) AS w2_active,
  n_obs_w1, n_obs_w2
FROM agg ORDER BY album_id, label
;

-- ===== domino_w2 =====
-- WAVE 2 recount — DOMINO 17/19/20. Finisher = 144 by END of close day; old rule (before close day) side by side.
-- Standard population, payers = album-table spend > 0 from start to close-1. Revenue / activity = daily metrics.
-- Usual = album start .. close-5. Last 4 = close-4 .. close-1. Window 1 = days 1-7 after own completion day. Window 2 = days 1-7 after close day.
-- The close day itself is left out of every daily average (half day).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-27'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
maxd AS (SELECT MAX(date_dim) AS md FROM udm),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    MAX(uniq) AS uniq_close, MAX(IF(date_dim < a_end, uniq, NULL)) AS uniq_prev,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_start, a_end, fin_d, uniq_close, uniq_prev, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pm AS (
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d,
    ANY_VALUE(p.uniq_close) AS uniq_close, ANY_VALUE(p.uniq_prev) AS uniq_prev, ANY_VALUE(p.alb_rev) AS alb_rev,
    SUM(IF(m.date_dim <= DATE_SUB(p.a_end, INTERVAL 5 DAY), m.rev, 0)) AS b_rev,
    COUNTIF(m.act AND m.date_dim <= DATE_SUB(p.a_end, INTERVAL 5 DAY)) AS b_ad,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 4 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)) AS l4_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 4 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY)) AS l4_ad,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 7 DAY) AND m.date_dim != p.a_end, m.rev, 0)) AS w1_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 7 DAY) AND m.date_dim != p.a_end) AS w1_ad,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 3 DAY) AND m.date_dim != p.a_end, m.rev, 0)) AS w13_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 3 DAY) AND m.date_dim != p.a_end) AS w13_ad,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.a_end, INTERVAL 1 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY), m.rev, 0)) AS w2_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_ADD(p.a_end, INTERVAL 1 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)) AS w2_ad
  FROM pop p LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.a_start AND DATE_ADD(p.a_end, INTERVAL 8 DAY)
  GROUP BY 1,2
),
lab AS (
  SELECT x.album_id, x.user_id, x.a_end, x.fin_d, x.alb_rev, x.b_rev, x.b_ad, x.l4_rev, x.l4_ad, x.w1_rev, x.w1_ad, x.w13_rev, x.w13_ad, x.w2_rev, x.w2_ad, label FROM pm x
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    IF(x.fin_d IS NOT NULL, ['w1_new'], []),
    IF(x.fin_d IS NOT NULL AND x.fin_d < x.a_end, ['w1_old'], []),
    IF(x.fin_d IS NOT NULL, [CONCAT('w1_t', CASE DATE_DIFF(x.a_end, x.fin_d, DAY) WHEN 0 THEN '0_close' WHEN 1 THEN '1_d1' WHEN 2 THEN '2_d23' WHEN 3 THEN '2_d23' ELSE '3_d4p' END)], []),
    [CONCAT('w2_new_', CASE WHEN x.uniq_close >= 144 THEN 'm0' WHEN x.uniq_close >= 141 THEN CONCAT('m', CAST(144 - x.uniq_close AS STRING)) ELSE 'm4p' END)],
    [CONCAT('w2_old_', CASE WHEN x.uniq_prev >= 144 THEN 'm0' WHEN x.uniq_prev >= 141 THEN CONCAT('m', CAST(144 - x.uniq_prev AS STRING)) ELSE 'm4p' END)],
    ['all_payers'])) AS label
),
agg AS (
SELECT album_id, label, COUNT(*) AS n, SUM(alb_rev) AS alb_rev,
  SUM(b_rev) AS b_rev, SUM(b_ad) AS b_ad, SUM(l4_rev) AS l4_rev, SUM(l4_ad) AS l4_ad,
  SUM(w1_rev) AS w1_rev, SUM(w1_ad) AS w1_ad, SUM(w13_rev) AS w13_rev, SUM(w13_ad) AS w13_ad,
  SUM(w2_rev) AS w2_rev, SUM(w2_ad) AS w2_ad,
  SUM(IF(fin_d IS NULL, 0, LEAST(7, GREATEST(0, DATE_DIFF(a_end, fin_d, DAY) - 1)))) AS w1_open_days,
  COUNTIF(fin_d IS NOT NULL AND DATE_ADD(fin_d, INTERVAL 1 DAY) >= a_end) AS next_d1,
  COUNTIF(fin_d IS NOT NULL AND DATE_ADD(fin_d, INTERVAL 3 DAY) >= a_end) AS next_d3,
  COUNTIF(fin_d IS NOT NULL AND DATE_ADD(fin_d, INTERVAL 7 DAY) <= md) AS n_obs_w1,
  COUNTIF(DATE_ADD(a_end, INTERVAL 7 DAY) <= md) AS n_obs_w2
FROM lab CROSS JOIN maxd
GROUP BY 1,2
)
SELECT album_id, label, n,
  ROUND(n / SUM(IF(label = 'all_payers', n, 0)) OVER (PARTITION BY album_id), 4) AS sh_payers,
  ROUND(alb_rev / SUM(IF(label = 'all_payers', alb_rev, 0)) OVER (PARTITION BY album_id), 4) AS sh_rev,
  ROUND(SAFE_DIVIDE(b_rev, b_ad), 2) AS arpdau_usual,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(l4_rev, l4_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS last4_vs_usual,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(w1_rev, w1_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS w1_d17_vs_usual,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(w13_rev, w13_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS w1_d13_vs_usual,
  ROUND(SAFE_DIVIDE(w1_open_days, 7 * n), 3) AS w1_open_share,
  ROUND(SAFE_DIVIDE(next_d1, n), 3) AS next_d1, ROUND(SAFE_DIVIDE(next_d3, n), 3) AS next_d3,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(w2_rev, w2_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS w2_d17_vs_usual,
  ROUND(SAFE_DIVIDE(w2_ad, 7 * n), 3) AS w2_active,
  n_obs_w1, n_obs_w2
FROM agg ORDER BY album_id, label
;

-- ===== disney_w2 =====
-- WAVE 2 recount — DISNEY 14/15. Finisher = 144 by END of close day; old rule (before close day) side by side.
-- Standard population, payers = album-table spend > 0 from start to close-1. Revenue / activity = daily metrics.
-- Usual = album start .. close-5. Last 4 = close-4 .. close-1. Window 1 = days 1-7 after own completion day. Window 2 = days 1-7 after close day.
-- The close day itself is left out of every daily average (half day).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-19'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
maxd AS (SELECT MAX(date_dim) AS md FROM udm),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    MAX(uniq) AS uniq_close, MAX(IF(date_dim < a_end, uniq, NULL)) AS uniq_prev,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_start, a_end, fin_d, uniq_close, uniq_prev, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pm AS (
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d,
    ANY_VALUE(p.uniq_close) AS uniq_close, ANY_VALUE(p.uniq_prev) AS uniq_prev, ANY_VALUE(p.alb_rev) AS alb_rev,
    SUM(IF(m.date_dim <= DATE_SUB(p.a_end, INTERVAL 5 DAY), m.rev, 0)) AS b_rev,
    COUNTIF(m.act AND m.date_dim <= DATE_SUB(p.a_end, INTERVAL 5 DAY)) AS b_ad,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 4 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)) AS l4_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 4 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY)) AS l4_ad,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 7 DAY) AND m.date_dim != p.a_end, m.rev, 0)) AS w1_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 7 DAY) AND m.date_dim != p.a_end) AS w1_ad,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 3 DAY) AND m.date_dim != p.a_end, m.rev, 0)) AS w13_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_ADD(p.fin_d, INTERVAL 1 DAY) AND DATE_ADD(p.fin_d, INTERVAL 3 DAY) AND m.date_dim != p.a_end) AS w13_ad,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.a_end, INTERVAL 1 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY), m.rev, 0)) AS w2_rev,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_ADD(p.a_end, INTERVAL 1 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)) AS w2_ad
  FROM pop p LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.a_start AND DATE_ADD(p.a_end, INTERVAL 8 DAY)
  GROUP BY 1,2
),
lab AS (
  SELECT x.album_id, x.user_id, x.a_end, x.fin_d, x.alb_rev, x.b_rev, x.b_ad, x.l4_rev, x.l4_ad, x.w1_rev, x.w1_ad, x.w13_rev, x.w13_ad, x.w2_rev, x.w2_ad, label FROM pm x
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    IF(x.fin_d IS NOT NULL, ['w1_new'], []),
    IF(x.fin_d IS NOT NULL AND x.fin_d < x.a_end, ['w1_old'], []),
    IF(x.fin_d IS NOT NULL, [CONCAT('w1_t', CASE DATE_DIFF(x.a_end, x.fin_d, DAY) WHEN 0 THEN '0_close' WHEN 1 THEN '1_d1' WHEN 2 THEN '2_d23' WHEN 3 THEN '2_d23' ELSE '3_d4p' END)], []),
    [CONCAT('w2_new_', CASE WHEN x.uniq_close >= 144 THEN 'm0' WHEN x.uniq_close >= 141 THEN CONCAT('m', CAST(144 - x.uniq_close AS STRING)) ELSE 'm4p' END)],
    [CONCAT('w2_old_', CASE WHEN x.uniq_prev >= 144 THEN 'm0' WHEN x.uniq_prev >= 141 THEN CONCAT('m', CAST(144 - x.uniq_prev AS STRING)) ELSE 'm4p' END)],
    ['all_payers'])) AS label
),
agg AS (
SELECT album_id, label, COUNT(*) AS n, SUM(alb_rev) AS alb_rev,
  SUM(b_rev) AS b_rev, SUM(b_ad) AS b_ad, SUM(l4_rev) AS l4_rev, SUM(l4_ad) AS l4_ad,
  SUM(w1_rev) AS w1_rev, SUM(w1_ad) AS w1_ad, SUM(w13_rev) AS w13_rev, SUM(w13_ad) AS w13_ad,
  SUM(w2_rev) AS w2_rev, SUM(w2_ad) AS w2_ad,
  SUM(IF(fin_d IS NULL, 0, LEAST(7, GREATEST(0, DATE_DIFF(a_end, fin_d, DAY) - 1)))) AS w1_open_days,
  COUNTIF(fin_d IS NOT NULL AND DATE_ADD(fin_d, INTERVAL 1 DAY) >= a_end) AS next_d1,
  COUNTIF(fin_d IS NOT NULL AND DATE_ADD(fin_d, INTERVAL 3 DAY) >= a_end) AS next_d3,
  COUNTIF(fin_d IS NOT NULL AND DATE_ADD(fin_d, INTERVAL 7 DAY) <= md) AS n_obs_w1,
  COUNTIF(DATE_ADD(a_end, INTERVAL 7 DAY) <= md) AS n_obs_w2
FROM lab CROSS JOIN maxd
GROUP BY 1,2
)
SELECT album_id, label, n,
  ROUND(n / SUM(IF(label = 'all_payers', n, 0)) OVER (PARTITION BY album_id), 4) AS sh_payers,
  ROUND(alb_rev / SUM(IF(label = 'all_payers', alb_rev, 0)) OVER (PARTITION BY album_id), 4) AS sh_rev,
  ROUND(SAFE_DIVIDE(b_rev, b_ad), 2) AS arpdau_usual,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(l4_rev, l4_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS last4_vs_usual,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(w1_rev, w1_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS w1_d17_vs_usual,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(w13_rev, w13_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS w1_d13_vs_usual,
  ROUND(SAFE_DIVIDE(w1_open_days, 7 * n), 3) AS w1_open_share,
  ROUND(SAFE_DIVIDE(next_d1, n), 3) AS next_d1, ROUND(SAFE_DIVIDE(next_d3, n), 3) AS next_d3,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(w2_rev, w2_ad), SAFE_DIVIDE(b_rev, b_ad)), 3) AS w2_d17_vs_usual,
  ROUND(SAFE_DIVIDE(w2_ad, 7 * n), 3) AS w2_active,
  n_obs_w1, n_obs_w2
FROM agg ORDER BY album_id, label
;

-- ===== dice_w3 =====
-- WAVE 3 recount — DICE 61/63. Finish rates inside groups; finisher = 144 by END of close day (old rule side by side).
-- Standard population payers. m8 = stickers missing on the row 8 days before close. wk = $ per active day in days 14..8 before close.
-- Heavy missers: $ per active day over the album (start..close-1) >= 20 and 2-3 missing at the end (old: close-1 row; new: end of close day).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-06' AND album_id IN (61,63) AND date_dim < album_end_date
),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq, DATE(MAX(s.sticker_collected_ts)) AS last_d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE)
  GROUP BY 1,2
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act, FALSE AS bad
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-15'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d0,
    MAX(IF(date_dim < a_end, uniq, NULL)) AS uniq_prev,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
u AS (
  SELECT u0.album_id, u0.user_id, u0.a_start, u0.a_end, u0.uniq_prev, u0.uniq_m8, u0.alb_rev, u0.l, u0.last_d,
    COALESCE(u0.fin_d0, IF(st.n_uniq >= 144 AND st.last_d <= u0.a_end, st.last_d, NULL)) AS fin_d,
    GREATEST(IFNULL(st.n_uniq, 0), IFNULL(u0.uniq_prev, 0)) AS uniq_close
  FROM u0 LEFT JOIN st USING (album_id, user_id)
),
pop AS (
  SELECT album_id, user_id, a_start, a_end, fin_d, uniq_close, uniq_prev, uniq_m8, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pm AS (
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, ANY_VALUE(p.uniq_close) AS uniq_close,
    ANY_VALUE(p.uniq_prev) AS uniq_prev, ANY_VALUE(p.uniq_m8) AS uniq_m8, ANY_VALUE(p.alb_rev) AS alb_rev,
    SAFE_DIVIDE(SUM(IF(m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 8 DAY), m.rev, 0)),
      COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 8 DAY))) AS wk_pd,
    SAFE_DIVIDE(SUM(IF(m.date_dim < p.a_end, m.rev, 0)), COUNTIF(m.act AND m.date_dim < p.a_end)) AS alb_pd,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.a_end, INTERVAL 1 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY), m.rev, 0)) AS post7,
    SUM(IF(m.date_dim <= DATE_SUB(p.a_end, INTERVAL 5 DAY), m.rev, 0)) / (DATE_DIFF(DATE_SUB(ANY_VALUE(p.a_end), INTERVAL 5 DAY), ANY_VALUE(p.a_start), DAY) + 1) * 7 AS exp7
  FROM pop p LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.a_start AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
  GROUP BY 1,2
),
lab AS (
  SELECT x.album_id, x.user_id, x.fin_d, x.a_end, x.alb_rev, x.post7, x.exp7, label FROM pm x
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    [CONCAT('m8_', CASE WHEN x.uniq_m8 IS NULL THEN 'na' WHEN x.uniq_m8 >= 144 THEN '0' WHEN x.uniq_m8 = 143 THEN '1' WHEN x.uniq_m8 >= 141 THEN '2_3'
       WHEN x.uniq_m8 >= 138 THEN '4_6' WHEN x.uniq_m8 >= 134 THEN '7_10' ELSE '11p' END)],
    IF(x.uniq_m8 BETWEEN 138 AND 140 AND x.wk_pd BETWEEN 5 AND 15, ['same_spend_4_6_5to15'], []),
    IF(x.alb_pd >= 20 AND x.uniq_prev BETWEEN 141 AND 142, ['heavy_m23_old'], []),
    IF(x.alb_pd >= 20 AND x.uniq_close BETWEEN 141 AND 142, ['heavy_m23_new'], []),
    IF(x.alb_pd >= 20 AND x.uniq_prev = 143, ['heavy_m1_old'], []),
    IF(x.alb_pd >= 20 AND x.uniq_close = 143, ['heavy_m1_new'], []),
    IF(x.alb_pd >= 20 AND x.fin_d IS NOT NULL, ['heavy_fin_new'], []),
    ['all_payers'])) AS label
)
SELECT album_id, label, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(IF(label = 'all_payers', COUNT(*), 0)) OVER (PARTITION BY album_id), 4) AS sh_payers,
  ROUND(SUM(alb_rev) / SUM(IF(label = 'all_payers', SUM(alb_rev), 0)) OVER (PARTITION BY album_id), 4) AS sh_rev,
  COUNTIF(fin_d < a_end) AS fin_old, COUNTIF(fin_d IS NOT NULL) AS fin_new,
  ROUND(COUNTIF(fin_d < a_end) / COUNT(*), 4) AS fin_rate_old, ROUND(COUNTIF(fin_d IS NOT NULL) / COUNT(*), 4) AS fin_rate_new,
  ROUND(SUM(post7)) AS post7, ROUND(SUM(exp7)) AS exp7
FROM lab GROUP BY 1,2 ORDER BY 1,2
;

-- ===== domino_w3 =====
-- WAVE 3 recount — DOMINO 17/19. Finish rates inside groups; finisher = 144 by END of close day (old rule side by side).
-- Standard population payers. m8 = stickers missing on the row 8 days before close. wk = $ per active day in days 14..8 before close.
-- Heavy missers: $ per active day over the album (start..close-1) >= 20 and 2-3 missing at the end (old: close-1 row; new: end of close day).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-08-24' AND album_id IN (17,19) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-09-02'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    MAX(uniq) AS uniq_close, MAX(IF(date_dim < a_end, uniq, NULL)) AS uniq_prev,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_start, a_end, fin_d, uniq_close, uniq_prev, uniq_m8, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pm AS (
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, ANY_VALUE(p.uniq_close) AS uniq_close,
    ANY_VALUE(p.uniq_prev) AS uniq_prev, ANY_VALUE(p.uniq_m8) AS uniq_m8, ANY_VALUE(p.alb_rev) AS alb_rev,
    SAFE_DIVIDE(SUM(IF(m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 8 DAY), m.rev, 0)),
      COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 8 DAY))) AS wk_pd,
    SAFE_DIVIDE(SUM(IF(m.date_dim < p.a_end, m.rev, 0)), COUNTIF(m.act AND m.date_dim < p.a_end)) AS alb_pd,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.a_end, INTERVAL 1 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY), m.rev, 0)) AS post7,
    SUM(IF(m.date_dim <= DATE_SUB(p.a_end, INTERVAL 5 DAY), m.rev, 0)) / (DATE_DIFF(DATE_SUB(ANY_VALUE(p.a_end), INTERVAL 5 DAY), ANY_VALUE(p.a_start), DAY) + 1) * 7 AS exp7
  FROM pop p LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.a_start AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
  GROUP BY 1,2
),
lab AS (
  SELECT x.album_id, x.user_id, x.fin_d, x.a_end, x.alb_rev, x.post7, x.exp7, label FROM pm x
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    [CONCAT('m8_', CASE WHEN x.uniq_m8 IS NULL THEN 'na' WHEN x.uniq_m8 >= 144 THEN '0' WHEN x.uniq_m8 = 143 THEN '1' WHEN x.uniq_m8 >= 141 THEN '2_3'
       WHEN x.uniq_m8 >= 138 THEN '4_6' WHEN x.uniq_m8 >= 134 THEN '7_10' ELSE '11p' END)],
    IF(x.uniq_m8 BETWEEN 138 AND 140 AND x.wk_pd BETWEEN 5 AND 15, ['same_spend_4_6_5to15'], []),
    IF(x.alb_pd >= 20 AND x.uniq_prev BETWEEN 141 AND 142, ['heavy_m23_old'], []),
    IF(x.alb_pd >= 20 AND x.uniq_close BETWEEN 141 AND 142, ['heavy_m23_new'], []),
    IF(x.alb_pd >= 20 AND x.uniq_prev = 143, ['heavy_m1_old'], []),
    IF(x.alb_pd >= 20 AND x.uniq_close = 143, ['heavy_m1_new'], []),
    IF(x.alb_pd >= 20 AND x.fin_d IS NOT NULL, ['heavy_fin_new'], []),
    ['all_payers'])) AS label
)
SELECT album_id, label, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(IF(label = 'all_payers', COUNT(*), 0)) OVER (PARTITION BY album_id), 4) AS sh_payers,
  ROUND(SUM(alb_rev) / SUM(IF(label = 'all_payers', SUM(alb_rev), 0)) OVER (PARTITION BY album_id), 4) AS sh_rev,
  COUNTIF(fin_d < a_end) AS fin_old, COUNTIF(fin_d IS NOT NULL) AS fin_new,
  ROUND(COUNTIF(fin_d < a_end) / COUNT(*), 4) AS fin_rate_old, ROUND(COUNTIF(fin_d IS NOT NULL) / COUNT(*), 4) AS fin_rate_new,
  ROUND(SUM(post7)) AS post7, ROUND(SUM(exp7)) AS exp7
FROM lab GROUP BY 1,2 ORDER BY 1,2
;

-- ===== disney_w3 =====
-- WAVE 3 recount — DISNEY 14/15. Finish rates inside groups; finisher = 144 by END of close day (old rule side by side).
-- Standard population payers. m8 = stickers missing on the row 8 days before close. wk = $ per active day in days 14..8 before close.
-- Heavy missers: $ per active day over the album (start..close-1) >= 20 and 2-3 missing at the end (old: close-1 row; new: end of close day).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-13'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    MAX(uniq) AS uniq_close, MAX(IF(date_dim < a_end, uniq, NULL)) AS uniq_prev,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_start, a_end, fin_d, uniq_close, uniq_prev, uniq_m8, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pm AS (
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, ANY_VALUE(p.uniq_close) AS uniq_close,
    ANY_VALUE(p.uniq_prev) AS uniq_prev, ANY_VALUE(p.uniq_m8) AS uniq_m8, ANY_VALUE(p.alb_rev) AS alb_rev,
    SAFE_DIVIDE(SUM(IF(m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 8 DAY), m.rev, 0)),
      COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 8 DAY))) AS wk_pd,
    SAFE_DIVIDE(SUM(IF(m.date_dim < p.a_end, m.rev, 0)), COUNTIF(m.act AND m.date_dim < p.a_end)) AS alb_pd,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(p.a_end, INTERVAL 1 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY), m.rev, 0)) AS post7,
    SUM(IF(m.date_dim <= DATE_SUB(p.a_end, INTERVAL 5 DAY), m.rev, 0)) / (DATE_DIFF(DATE_SUB(ANY_VALUE(p.a_end), INTERVAL 5 DAY), ANY_VALUE(p.a_start), DAY) + 1) * 7 AS exp7
  FROM pop p LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.a_start AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
  GROUP BY 1,2
),
lab AS (
  SELECT x.album_id, x.user_id, x.fin_d, x.a_end, x.alb_rev, x.post7, x.exp7, label FROM pm x
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    [CONCAT('m8_', CASE WHEN x.uniq_m8 IS NULL THEN 'na' WHEN x.uniq_m8 >= 144 THEN '0' WHEN x.uniq_m8 = 143 THEN '1' WHEN x.uniq_m8 >= 141 THEN '2_3'
       WHEN x.uniq_m8 >= 138 THEN '4_6' WHEN x.uniq_m8 >= 134 THEN '7_10' ELSE '11p' END)],
    IF(x.uniq_m8 BETWEEN 138 AND 140 AND x.wk_pd BETWEEN 5 AND 15, ['same_spend_4_6_5to15'], []),
    IF(x.alb_pd >= 20 AND x.uniq_prev BETWEEN 141 AND 142, ['heavy_m23_old'], []),
    IF(x.alb_pd >= 20 AND x.uniq_close BETWEEN 141 AND 142, ['heavy_m23_new'], []),
    IF(x.alb_pd >= 20 AND x.uniq_prev = 143, ['heavy_m1_old'], []),
    IF(x.alb_pd >= 20 AND x.uniq_close = 143, ['heavy_m1_new'], []),
    IF(x.alb_pd >= 20 AND x.fin_d IS NOT NULL, ['heavy_fin_new'], []),
    ['all_payers'])) AS label
)
SELECT album_id, label, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(IF(label = 'all_payers', COUNT(*), 0)) OVER (PARTITION BY album_id), 4) AS sh_payers,
  ROUND(SUM(alb_rev) / SUM(IF(label = 'all_payers', SUM(alb_rev), 0)) OVER (PARTITION BY album_id), 4) AS sh_rev,
  COUNTIF(fin_d < a_end) AS fin_old, COUNTIF(fin_d IS NOT NULL) AS fin_new,
  ROUND(COUNTIF(fin_d < a_end) / COUNT(*), 4) AS fin_rate_old, ROUND(COUNTIF(fin_d IS NOT NULL) / COUNT(*), 4) AS fin_rate_new,
  ROUND(SUM(post7)) AS post7, ROUND(SUM(exp7)) AS exp7
FROM lab GROUP BY 1,2 ORDER BY 1,2
;
