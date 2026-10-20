-- Last two new stickers of non-paying finishers (2026-10-18). Non-payer = album-table spend = 0.
-- ===== dice =====
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
np AS (
  SELECT f.album_id, f.user_id, f.a_start, f.a_end FROM fin f JOIN ud u USING (album_id, user_id)
  GROUP BY 1,2,3,4 HAVING SUM(u.spend) = 0
),
first_st AS (
  SELECT f.album_id, f.user_id, s.sticker_collected_ts AS ts, COALESCE(NULLIF(s.sticker_source, ''), CASE WHEN s.sticker_pack_key LIKE '%Puzzle_Collection%' THEN 'puzzle_collection' WHEN s.sticker_pack_key LIKE '%Merge_Collection%' THEN 'merge_collection' END, CONCAT('camp:', IFNULL(s.sticker_mtx_campaign_name, '(null)'))) AS src, IFNULL(s.collected_from_wild, FALSE) AS wj, LOWER(s.sticker_type) AS stype
  FROM np f JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-03-15' AND DATE '2026-09-07' AND s.album_id IN (59,61,63) AND s.is_sticker_collected
    AND s.sticker_collected_date >= f.a_start AND s.sticker_collected_date < f.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1
),
r AS (SELECT album_id, user_id, ts, src, wj, stype, ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) AS rn FROM first_st),
pr AS (
  SELECT a.album_id, a.user_id, a.src AS src1, a.wj AS wj1, a.stype AS st1, b.src AS src2, b.wj AS wj2, b.stype AS st2,
    TIMESTAMP_DIFF(a.ts, b.ts, MINUTE) / 60 AS gap_h
  FROM r a LEFT JOIN r b ON b.album_id = a.album_id AND b.user_id = a.user_id AND b.rn = 2
  WHERE a.rn = 1
),
k AS (
  SELECT album_id, CONCAT(IFNULL(src2,'(none)'), IF(wj2,' [W]',''), ' (', IFNULL(st2,'-'), ')') AS prev2,
    CONCAT(src1, IF(wj1,' [W]',''), ' (', st1, ')') AS last1, gap_h, src1 = src2 AS same_src FROM pr
),
tot AS (SELECT album_id, COUNT(*) AS n_np, ROUND(100 * COUNTIF(same_src) / COUNT(*), 1) AS pct_same_src,
  ROUND(APPROX_QUANTILES(gap_h, 2)[OFFSET(1)], 1) AS median_gap_h, ROUND(100 * COUNTIF(gap_h <= 1) / COUNT(*), 1) AS pct_within_1h FROM k GROUP BY 1),
pairs AS (SELECT album_id, prev2, last1, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) AS rn FROM k GROUP BY 1,2,3),
p1 AS (SELECT album_id, last1 AS s, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) AS rn FROM k GROUP BY 1,2),
p2 AS (SELECT album_id, prev2 AS s, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) AS rn FROM k GROUP BY 1,2)
SELECT 'a_tot' AS t, album_id, CAST(n_np AS STRING) AS a, CONCAT('same_src%=', CAST(pct_same_src AS STRING), ' median_gap_h=', CAST(median_gap_h AS STRING), ' within1h%=', CAST(pct_within_1h AS STRING)) AS b, n_np AS n FROM tot
UNION ALL SELECT 'b_last', album_id, s, NULL, n FROM p1 WHERE rn <= 6
UNION ALL SELECT 'c_prev', album_id, s, NULL, n FROM p2 WHERE rn <= 6
UNION ALL SELECT 'd_pair', album_id, prev2, last1, n FROM pairs WHERE rn <= 6
ORDER BY t, album_id, n DESC

-- ===== domino =====
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
np AS (
  SELECT f.album_id, f.user_id, f.a_start, f.a_end FROM fin f JOIN ud u USING (album_id, user_id)
  GROUP BY 1,2,3,4 HAVING SUM(u.spend) = 0
),
first_st AS (
  SELECT f.album_id, f.user_id, s.sticker_collected_min_ts AS ts, COALESCE(NULLIF(s.new_sticker_source, ''), CONCAT('camp:', IFNULL(s.new_sticker_mtx_campaign_name, '(null)'))) AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj, LOWER(s.sticker_type) AS stype
  FROM np f JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-02-01' AND DATE '2026-10-12' AND s.album_id IN (17,19,20) AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= f.a_start AND s.sticker_collected_min_date < f.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
r AS (SELECT album_id, user_id, ts, src, wj, stype, ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) AS rn FROM first_st),
pr AS (
  SELECT a.album_id, a.user_id, a.src AS src1, a.wj AS wj1, a.stype AS st1, b.src AS src2, b.wj AS wj2, b.stype AS st2,
    TIMESTAMP_DIFF(a.ts, b.ts, MINUTE) / 60 AS gap_h
  FROM r a LEFT JOIN r b ON b.album_id = a.album_id AND b.user_id = a.user_id AND b.rn = 2
  WHERE a.rn = 1
),
k AS (
  SELECT album_id, CONCAT(IFNULL(src2,'(none)'), IF(wj2,' [W]',''), ' (', IFNULL(st2,'-'), ')') AS prev2,
    CONCAT(src1, IF(wj1,' [W]',''), ' (', st1, ')') AS last1, gap_h, src1 = src2 AS same_src FROM pr
),
tot AS (SELECT album_id, COUNT(*) AS n_np, ROUND(100 * COUNTIF(same_src) / COUNT(*), 1) AS pct_same_src,
  ROUND(APPROX_QUANTILES(gap_h, 2)[OFFSET(1)], 1) AS median_gap_h, ROUND(100 * COUNTIF(gap_h <= 1) / COUNT(*), 1) AS pct_within_1h FROM k GROUP BY 1),
pairs AS (SELECT album_id, prev2, last1, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) AS rn FROM k GROUP BY 1,2,3),
p1 AS (SELECT album_id, last1 AS s, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) AS rn FROM k GROUP BY 1,2),
p2 AS (SELECT album_id, prev2 AS s, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) AS rn FROM k GROUP BY 1,2)
SELECT 'a_tot' AS t, album_id, CAST(n_np AS STRING) AS a, CONCAT('same_src%=', CAST(pct_same_src AS STRING), ' median_gap_h=', CAST(median_gap_h AS STRING), ' within1h%=', CAST(pct_within_1h AS STRING)) AS b, n_np AS n FROM tot
UNION ALL SELECT 'b_last', album_id, s, NULL, n FROM p1 WHERE rn <= 6
UNION ALL SELECT 'c_prev', album_id, s, NULL, n FROM p2 WHERE rn <= 6
UNION ALL SELECT 'd_pair', album_id, prev2, last1, n FROM pairs WHERE rn <= 6
ORDER BY t, album_id, n DESC

-- ===== disney =====
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
np AS (
  SELECT f.album_id, f.user_id, f.a_start, f.a_end FROM fin f JOIN ud u USING (album_id, user_id)
  GROUP BY 1,2,3,4 HAVING SUM(u.spend) = 0
),
first_st AS (
  SELECT f.album_id, f.user_id, s.sticker_collected_min_ts AS ts, COALESCE(NULLIF(s.new_sticker_source, ''), CONCAT('camp:', IFNULL(s.new_sticker_mtx_campaign_name, '(null)'))) AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj, LOWER(s.sticker_type) AS stype
  FROM np f JOIN `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND s.album_id IN (12,14,15) AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) != 'magic'
    AND s.sticker_collected_min_date >= f.a_start AND s.sticker_collected_min_date < f.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
r AS (SELECT album_id, user_id, ts, src, wj, stype, ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) AS rn FROM first_st),
pr AS (
  SELECT a.album_id, a.user_id, a.src AS src1, a.wj AS wj1, a.stype AS st1, b.src AS src2, b.wj AS wj2, b.stype AS st2,
    TIMESTAMP_DIFF(a.ts, b.ts, MINUTE) / 60 AS gap_h
  FROM r a LEFT JOIN r b ON b.album_id = a.album_id AND b.user_id = a.user_id AND b.rn = 2
  WHERE a.rn = 1
),
k AS (
  SELECT album_id, CONCAT(IFNULL(src2,'(none)'), IF(wj2,' [W]',''), ' (', IFNULL(st2,'-'), ')') AS prev2,
    CONCAT(src1, IF(wj1,' [W]',''), ' (', st1, ')') AS last1, gap_h, src1 = src2 AS same_src FROM pr
),
tot AS (SELECT album_id, COUNT(*) AS n_np, ROUND(100 * COUNTIF(same_src) / COUNT(*), 1) AS pct_same_src,
  ROUND(APPROX_QUANTILES(gap_h, 2)[OFFSET(1)], 1) AS median_gap_h, ROUND(100 * COUNTIF(gap_h <= 1) / COUNT(*), 1) AS pct_within_1h FROM k GROUP BY 1),
pairs AS (SELECT album_id, prev2, last1, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) AS rn FROM k GROUP BY 1,2,3),
p1 AS (SELECT album_id, last1 AS s, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) AS rn FROM k GROUP BY 1,2),
p2 AS (SELECT album_id, prev2 AS s, COUNT(*) AS n, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) AS rn FROM k GROUP BY 1,2)
SELECT 'a_tot' AS t, album_id, CAST(n_np AS STRING) AS a, CONCAT('same_src%=', CAST(pct_same_src AS STRING), ' median_gap_h=', CAST(median_gap_h AS STRING), ' within1h%=', CAST(pct_within_1h AS STRING)) AS b, n_np AS n FROM tot
UNION ALL SELECT 'b_last', album_id, s, NULL, n FROM p1 WHERE rn <= 6
UNION ALL SELECT 'c_prev', album_id, s, NULL, n FROM p2 WHERE rn <= 6
UNION ALL SELECT 'd_pair', album_id, prev2, last1, n FROM pairs WHERE rn <= 6
ORDER BY t, album_id, n DESC

