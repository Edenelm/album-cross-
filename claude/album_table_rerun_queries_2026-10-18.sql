-- v2 (2026-10-18): revenue/payer from the album table spend column (per decisions register). Results matched the daily-metrics version within 0-1 pt.
-- ===== np_dice =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim < album_end_date
),
udm AS (SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act, FALSE AS bad FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-09-07'),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
spend_alb AS (SELECT u.album_id, u.user_id, SUM(u.spend) AS sp FROM ud u JOIN fin f USING (album_id, user_id) GROUP BY 1,2),
rev_udm AS (
  SELECT f.album_id, f.user_id, SUM(IFNULL(m.rev,0)) AS rv
  FROM fin f LEFT JOIN udm m ON m.user_id = f.user_id AND m.date_dim BETWEEN f.a_start AND DATE_SUB(f.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
cls AS (
  SELECT f.album_id, f.user_id, IF(IFNULL(a.sp,0) > 0, 'payer', 'nonpayer') AS grp_new, IF(IFNULL(r.rv,0) > 0, 'payer', 'nonpayer') AS grp_old
  FROM fin f LEFT JOIN spend_alb a USING (album_id, user_id) LEFT JOIN rev_udm r USING (album_id, user_id)
),
first_st AS (
  SELECT f.album_id, f.user_id, s.sticker_collected_ts AS ts, COALESCE(NULLIF(s.sticker_source, ''), CASE WHEN s.sticker_pack_key LIKE '%Puzzle_Collection%' THEN 'puzzle_collection' WHEN s.sticker_pack_key LIKE '%Merge_Collection%' THEN 'merge_collection' END, CONCAT('camp:', IFNULL(s.sticker_mtx_campaign_name, '(null)'))) AS src, IFNULL(s.collected_from_wild, FALSE) AS wj, LOWER(s.sticker_type) AS stype
  FROM fin f JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-03-15' AND DATE '2026-09-07' AND s.album_id IN (59,61,63) AND s.is_sticker_collected
    AND s.sticker_collected_date >= f.a_start AND s.sticker_collected_date < f.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1
),
last_st AS (SELECT album_id, user_id, src, wj, stype FROM first_st QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) = 1),
j AS (SELECT c.album_id, c.grp_new, IFNULL(l.src,'(none)') AS src, IFNULL(l.wj,FALSE) AS wj, IFNULL(l.stype,'(none)') AS stype FROM cls c LEFT JOIN last_st l USING (album_id, user_id)),
rk AS (SELECT album_id, grp_new, src, wj, stype, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id, grp_new ORDER BY COUNT(*) DESC) AS rn FROM j GROUP BY 1,2,3,4,5)
SELECT 'cls' AS t, album_id, grp_new, grp_old AS detail, CAST(NULL AS BOOL) AS wj, CAST(NULL AS STRING) AS stype, COUNT(*) AS n FROM cls GROUP BY 1,2,3,4
UNION ALL
SELECT 'src', album_id, grp_new, IF(rn <= 8, src, 'Other'), IF(rn <= 8, wj, NULL), IF(rn <= 8, stype, NULL), SUM(n) FROM rk GROUP BY 1,2,3,4,5,6
ORDER BY t, album_id, grp_new, n DESC

-- ===== np_domino =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim < album_close_date
),
udm AS (SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev, IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12'),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
spend_alb AS (SELECT u.album_id, u.user_id, SUM(u.spend) AS sp FROM ud u JOIN fin f USING (album_id, user_id) GROUP BY 1,2),
rev_udm AS (
  SELECT f.album_id, f.user_id, SUM(IFNULL(m.rev,0)) AS rv
  FROM fin f LEFT JOIN udm m ON m.user_id = f.user_id AND m.date_dim BETWEEN f.a_start AND DATE_SUB(f.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
cls AS (
  SELECT f.album_id, f.user_id, IF(IFNULL(a.sp,0) > 0, 'payer', 'nonpayer') AS grp_new, IF(IFNULL(r.rv,0) > 0, 'payer', 'nonpayer') AS grp_old
  FROM fin f LEFT JOIN spend_alb a USING (album_id, user_id) LEFT JOIN rev_udm r USING (album_id, user_id)
),
first_st AS (
  SELECT f.album_id, f.user_id, s.sticker_collected_min_ts AS ts, COALESCE(NULLIF(s.new_sticker_source, ''), CONCAT('camp:', IFNULL(s.new_sticker_mtx_campaign_name, '(null)'))) AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj, LOWER(s.sticker_type) AS stype
  FROM fin f JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-02-01' AND DATE '2026-10-12' AND s.album_id IN (17,19,20) AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= f.a_start AND s.sticker_collected_min_date < f.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
last_st AS (SELECT album_id, user_id, src, wj, stype FROM first_st QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) = 1),
j AS (SELECT c.album_id, c.grp_new, IFNULL(l.src,'(none)') AS src, IFNULL(l.wj,FALSE) AS wj, IFNULL(l.stype,'(none)') AS stype FROM cls c LEFT JOIN last_st l USING (album_id, user_id)),
rk AS (SELECT album_id, grp_new, src, wj, stype, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id, grp_new ORDER BY COUNT(*) DESC) AS rn FROM j GROUP BY 1,2,3,4,5)
SELECT 'cls' AS t, album_id, grp_new, grp_old AS detail, CAST(NULL AS BOOL) AS wj, CAST(NULL AS STRING) AS stype, COUNT(*) AS n FROM cls GROUP BY 1,2,3,4
UNION ALL
SELECT 'src', album_id, grp_new, IF(rn <= 8, src, 'Other'), IF(rn <= 8, wj, NULL), IF(rn <= 8, stype, NULL), SUM(n) FROM rk GROUP BY 1,2,3,4,5,6
ORDER BY t, album_id, grp_new, n DESC

-- ===== np_disney =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND album_id IN (12,14,15) AND date_dim < album_close_date
),
udm AS (SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05'),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
spend_alb AS (SELECT u.album_id, u.user_id, SUM(u.spend) AS sp FROM ud u JOIN fin f USING (album_id, user_id) GROUP BY 1,2),
rev_udm AS (
  SELECT f.album_id, f.user_id, SUM(IFNULL(m.rev,0)) AS rv
  FROM fin f LEFT JOIN udm m ON m.user_id = f.user_id AND m.date_dim BETWEEN f.a_start AND DATE_SUB(f.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
cls AS (
  SELECT f.album_id, f.user_id, IF(IFNULL(a.sp,0) > 0, 'payer', 'nonpayer') AS grp_new, IF(IFNULL(r.rv,0) > 0, 'payer', 'nonpayer') AS grp_old
  FROM fin f LEFT JOIN spend_alb a USING (album_id, user_id) LEFT JOIN rev_udm r USING (album_id, user_id)
),
first_st AS (
  SELECT f.album_id, f.user_id, s.sticker_collected_min_ts AS ts, COALESCE(NULLIF(s.new_sticker_source, ''), CONCAT('camp:', IFNULL(s.new_sticker_mtx_campaign_name, '(null)'))) AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj, LOWER(s.sticker_type) AS stype
  FROM fin f JOIN `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND s.album_id IN (12,14,15) AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) != 'magic'
    AND s.sticker_collected_min_date >= f.a_start AND s.sticker_collected_min_date < f.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
last_st AS (SELECT album_id, user_id, src, wj, stype FROM first_st QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) = 1),
j AS (SELECT c.album_id, c.grp_new, IFNULL(l.src,'(none)') AS src, IFNULL(l.wj,FALSE) AS wj, IFNULL(l.stype,'(none)') AS stype FROM cls c LEFT JOIN last_st l USING (album_id, user_id)),
rk AS (SELECT album_id, grp_new, src, wj, stype, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id, grp_new ORDER BY COUNT(*) DESC) AS rn FROM j GROUP BY 1,2,3,4,5)
SELECT 'cls' AS t, album_id, grp_new, grp_old AS detail, CAST(NULL AS BOOL) AS wj, CAST(NULL AS STRING) AS stype, COUNT(*) AS n FROM cls GROUP BY 1,2,3,4
UNION ALL
SELECT 'src', album_id, grp_new, IF(rn <= 8, src, 'Other'), IF(rn <= 8, wj, NULL), IF(rn <= 8, stype, NULL), SUM(n) FROM rk GROUP BY 1,2,3,4,5,6
ORDER BY t, album_id, grp_new, n DESC

-- ===== tg_dice =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim < album_end_date
),
udm AS (SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act, FALSE AS bad FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-09-07'),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
alb0 AS (SELECT album_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM ud GROUP BY 1),
alb AS (SELECT album_id, a_start, a_end, LAG(album_id) OVER (ORDER BY a_start) AS prev_id FROM alb0),
tgt AS (
  SELECT a.album_id, a.a_start, a.a_end, a.prev_id,
    DATE_ADD(a.a_start, INTERVAL CAST(FLOOR(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) DAY) AS q4_start
  FROM alb a WHERE a.album_id IN (61,63)
),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.q4_start, t.prev_id, u.uniq AS uniq_end
  FROM ud u JOIN tgt t USING (album_id)
  WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
c4 AS (SELECT u.album_id, u.user_id, u.uniq AS uniq_c4 FROM ud u JOIN tgt t USING (album_id) WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 4 DAY)),
cur AS (
  SELECT p.album_id, p.user_id,
    SUM(u.spend) AS rev_alb,
    SUM(IF(u.date_dim <= DATE_SUB(p.a_end, INTERVAL 4 DAY), u.spend, 0)) AS rev_c4,
    SUM(IF(u.date_dim < p.q4_start, u.spend, 0)) AS rev_q
  FROM pop p JOIN ud u ON u.album_id = p.album_id AND u.user_id = p.user_id
  GROUP BY 1,2
),
prev AS (
  SELECT p.album_id, p.user_id, SUM(u.spend) AS rev_prev
  FROM pop p JOIN ud u ON u.album_id = p.prev_id AND u.user_id = p.user_id
  GROUP BY 1,2
),
act AS (
  SELECT p.album_id, p.user_id,
    COUNTIF(m.act AND m.date_dim >= p.a_start AND m.date_dim < p.q4_start) AS ad_q,
    COUNTIF(m.act AND m.date_dim >= pa.a_start AND m.date_dim < pa.a_end) AS ad_prev
  FROM pop p JOIN alb pa ON pa.album_id = p.prev_id
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim >= pa.a_start AND m.date_dim < p.a_end
  GROUP BY 1,2
),
payers AS (
  SELECT p.album_id, p.user_id, p.uniq_end, IFNULL(c4.uniq_c4,0) AS uniq_c4, c.rev_alb, c.rev_c4,
    SAFE_DIVIDE(IFNULL(pv.rev_prev,0), a.ad_prev) AS lvl_x, SAFE_DIVIDE(c.rev_q, a.ad_q) AS tier_x
  FROM pop p JOIN cur c USING (album_id, user_id) LEFT JOIN prev pv USING (album_id, user_id)
  LEFT JOIN act a USING (album_id, user_id) LEFT JOIN c4 USING (album_id, user_id)
  WHERE c.rev_alb > 0
),
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
  SELECT album_id, dim, 'all', COUNT(*), SUM(rev_alb), SUM(rev_c4), COUNTIF(uniq_end >= 144), SUM(IF(uniq_end >= 144, rev_alb, 0)),
    COUNTIF(uniq_c4 >= 144), SUM(IF(uniq_c4 >= 144, rev_c4, 0))
  FROM d GROUP BY 1,2
)
SELECT album_id, dim, grp, n AS payers,
  ROUND(100 * n / SUM(IF(grp = 'all', n, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_payers,
  ROUND(100 * rev / SUM(IF(grp = 'all', rev, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_rev,
  ROUND(100 * fin_n / n, 1) AS fin_pct_end,
  ROUND(100 * SAFE_DIVIDE(fin_rev, rev), 1) AS fin_revshare_end
FROM agg WHERE dim = 'level' ORDER BY album_id, dim, grp

-- ===== tg_domino =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12' AND album_id IN (18,19,20) AND date_dim < album_close_date
),
udm AS (SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev, IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12'),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
alb0 AS (SELECT album_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM ud GROUP BY 1),
alb AS (SELECT album_id, a_start, a_end, LAG(album_id) OVER (ORDER BY a_start) AS prev_id FROM alb0),
tgt AS (
  SELECT a.album_id, a.a_start, a.a_end, a.prev_id,
    DATE_ADD(a.a_start, INTERVAL CAST(FLOOR(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) DAY) AS q4_start
  FROM alb a WHERE a.album_id IN (19,20)
),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.q4_start, t.prev_id, u.uniq AS uniq_end
  FROM ud u JOIN tgt t USING (album_id)
  WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
c4 AS (SELECT u.album_id, u.user_id, u.uniq AS uniq_c4 FROM ud u JOIN tgt t USING (album_id) WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 4 DAY)),
cur AS (
  SELECT p.album_id, p.user_id,
    SUM(u.spend) AS rev_alb,
    SUM(IF(u.date_dim <= DATE_SUB(p.a_end, INTERVAL 4 DAY), u.spend, 0)) AS rev_c4,
    SUM(IF(u.date_dim < p.q4_start, u.spend, 0)) AS rev_q
  FROM pop p JOIN ud u ON u.album_id = p.album_id AND u.user_id = p.user_id
  GROUP BY 1,2
),
prev AS (
  SELECT p.album_id, p.user_id, SUM(u.spend) AS rev_prev
  FROM pop p JOIN ud u ON u.album_id = p.prev_id AND u.user_id = p.user_id
  GROUP BY 1,2
),
act AS (
  SELECT p.album_id, p.user_id,
    COUNTIF(m.act AND m.date_dim >= p.a_start AND m.date_dim < p.q4_start) AS ad_q,
    COUNTIF(m.act AND m.date_dim >= pa.a_start AND m.date_dim < pa.a_end) AS ad_prev
  FROM pop p JOIN alb pa ON pa.album_id = p.prev_id
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim >= pa.a_start AND m.date_dim < p.a_end
  GROUP BY 1,2
),
payers AS (
  SELECT p.album_id, p.user_id, p.uniq_end, IFNULL(c4.uniq_c4,0) AS uniq_c4, c.rev_alb, c.rev_c4,
    SAFE_DIVIDE(IFNULL(pv.rev_prev,0), a.ad_prev) AS lvl_x, SAFE_DIVIDE(c.rev_q, a.ad_q) AS tier_x
  FROM pop p JOIN cur c USING (album_id, user_id) LEFT JOIN prev pv USING (album_id, user_id)
  LEFT JOIN act a USING (album_id, user_id) LEFT JOIN c4 USING (album_id, user_id)
  WHERE c.rev_alb > 0
),
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
  SELECT album_id, dim, 'all', COUNT(*), SUM(rev_alb), SUM(rev_c4), COUNTIF(uniq_end >= 144), SUM(IF(uniq_end >= 144, rev_alb, 0)),
    COUNTIF(uniq_c4 >= 144), SUM(IF(uniq_c4 >= 144, rev_c4, 0))
  FROM d GROUP BY 1,2
)
SELECT album_id, dim, grp, n AS payers,
  ROUND(100 * n / SUM(IF(grp = 'all', n, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_payers,
  ROUND(100 * rev / SUM(IF(grp = 'all', rev, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_rev,
  ROUND(100 * fin_n / n, 1) AS fin_pct_end,
  ROUND(100 * SAFE_DIVIDE(fin_rev, rev), 1) AS fin_revshare_end
FROM agg WHERE dim = 'level' ORDER BY album_id, dim, grp

-- ===== tg_disney =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND album_id IN (13,14,15) AND date_dim < album_close_date
),
udm AS (SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05'),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
alb0 AS (SELECT album_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM ud GROUP BY 1),
alb AS (SELECT album_id, a_start, a_end, LAG(album_id) OVER (ORDER BY a_start) AS prev_id FROM alb0),
tgt AS (
  SELECT a.album_id, a.a_start, a.a_end, a.prev_id,
    DATE_ADD(a.a_start, INTERVAL CAST(FLOOR(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) DAY) AS q4_start
  FROM alb a WHERE a.album_id IN (14,15)
),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.q4_start, t.prev_id, u.uniq AS uniq_end
  FROM ud u JOIN tgt t USING (album_id)
  WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
c4 AS (SELECT u.album_id, u.user_id, u.uniq AS uniq_c4 FROM ud u JOIN tgt t USING (album_id) WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 4 DAY)),
cur AS (
  SELECT p.album_id, p.user_id,
    SUM(u.spend) AS rev_alb,
    SUM(IF(u.date_dim <= DATE_SUB(p.a_end, INTERVAL 4 DAY), u.spend, 0)) AS rev_c4,
    SUM(IF(u.date_dim < p.q4_start, u.spend, 0)) AS rev_q
  FROM pop p JOIN ud u ON u.album_id = p.album_id AND u.user_id = p.user_id
  GROUP BY 1,2
),
prev AS (
  SELECT p.album_id, p.user_id, SUM(u.spend) AS rev_prev
  FROM pop p JOIN ud u ON u.album_id = p.prev_id AND u.user_id = p.user_id
  GROUP BY 1,2
),
act AS (
  SELECT p.album_id, p.user_id,
    COUNTIF(m.act AND m.date_dim >= p.a_start AND m.date_dim < p.q4_start) AS ad_q,
    COUNTIF(m.act AND m.date_dim >= pa.a_start AND m.date_dim < pa.a_end) AS ad_prev
  FROM pop p JOIN alb pa ON pa.album_id = p.prev_id
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim >= pa.a_start AND m.date_dim < p.a_end
  GROUP BY 1,2
),
payers AS (
  SELECT p.album_id, p.user_id, p.uniq_end, IFNULL(c4.uniq_c4,0) AS uniq_c4, c.rev_alb, c.rev_c4,
    SAFE_DIVIDE(IFNULL(pv.rev_prev,0), a.ad_prev) AS lvl_x, SAFE_DIVIDE(c.rev_q, a.ad_q) AS tier_x
  FROM pop p JOIN cur c USING (album_id, user_id) LEFT JOIN prev pv USING (album_id, user_id)
  LEFT JOIN act a USING (album_id, user_id) LEFT JOIN c4 USING (album_id, user_id)
  WHERE c.rev_alb > 0
),
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
  SELECT album_id, dim, 'all', COUNT(*), SUM(rev_alb), SUM(rev_c4), COUNTIF(uniq_end >= 144), SUM(IF(uniq_end >= 144, rev_alb, 0)),
    COUNTIF(uniq_c4 >= 144), SUM(IF(uniq_c4 >= 144, rev_c4, 0))
  FROM d GROUP BY 1,2
)
SELECT album_id, dim, grp, n AS payers,
  ROUND(100 * n / SUM(IF(grp = 'all', n, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_payers,
  ROUND(100 * rev / SUM(IF(grp = 'all', rev, 0)) OVER (PARTITION BY album_id, dim), 1) AS pct_rev,
  ROUND(100 * fin_n / n, 1) AS fin_pct_end,
  ROUND(100 * SAFE_DIVIDE(fin_rev, rev), 1) AS fin_revshare_end
FROM agg WHERE dim = 'level' ORDER BY album_id, dim, grp

