-- Non-paying finishers + last new sticker source (2026-10-18). Disney run with albums 12-15 and magic excluded (13 = 0 finishers, 21-day album).
-- ===== DICE =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-15' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim = DATE_SUB(album_end_date, INTERVAL 1 DAY)
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, FALSE AS bad
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-09-07'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end
  FROM ud u
  WHERE u.date_dim = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.uniq >= 144 AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
pay AS (
  SELECT f.album_id, f.user_id, SUM(IF(m.date_dim BETWEEN f.a_start AND DATE_SUB(f.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb
  FROM fin f LEFT JOIN udm m ON m.user_id = f.user_id AND m.date_dim BETWEEN f.a_start AND f.a_end
  GROUP BY 1,2
),
first_st AS (
  SELECT f.album_id, f.user_id, s.sticker_collected_ts AS ts, COALESCE(NULLIF(s.sticker_source, ''), CASE WHEN s.sticker_pack_key LIKE '%Puzzle_Collection%' THEN 'puzzle_collection' WHEN s.sticker_pack_key LIKE '%Merge_Collection%' THEN 'merge_collection' END, CONCAT('camp:', IFNULL(s.sticker_mtx_campaign_name, '(null)'))) AS src, IFNULL(s.collected_from_wild, FALSE) AS wj, LOWER(s.sticker_type) AS stype
  FROM fin f JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-04-15' AND DATE '2026-09-07' AND s.album_id IN (59,61,63) AND s.is_sticker_collected
    AND s.sticker_collected_date >= f.a_start AND s.sticker_collected_date < f.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1
),
last_st AS (
  SELECT album_id, user_id, src, wj, stype FROM first_st
  QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) = 1
),
j AS (
  SELECT p.album_id, IF(p.rev_alb > 0, 'payer', 'nonpayer') AS pay_grp,
    IFNULL(l.src, '(none)') AS src, IFNULL(l.wj, FALSE) AS wj, IFNULL(l.stype, '(none)') AS stype
  FROM pay p LEFT JOIN last_st l USING (album_id, user_id)
),
rk AS (SELECT album_id, pay_grp, src, wj, stype, COUNT(*) AS n,
  ROW_NUMBER() OVER (PARTITION BY album_id, pay_grp ORDER BY COUNT(*) DESC) AS rn FROM j GROUP BY 1,2,3,4,5)
SELECT album_id, pay_grp, IF(rn <= 8, src, 'Other') AS src, IF(rn <= 8, wj, NULL) AS wj, IF(rn <= 8, stype, NULL) AS stype, SUM(n) AS n,
  SUM(SUM(n)) OVER (PARTITION BY album_id, pay_grp) AS grp_n,
  SUM(SUM(n)) OVER (PARTITION BY album_id) AS album_fin
FROM rk GROUP BY 1,2,3,4,5 ORDER BY album_id, pay_grp, n DESC

-- ===== DOMINO =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim = DATE_SUB(album_close_date, INTERVAL 1 DAY)
),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end
  FROM ud u
  WHERE u.date_dim = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.uniq >= 144 AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
pay AS (
  SELECT f.album_id, f.user_id, SUM(IF(m.date_dim BETWEEN f.a_start AND DATE_SUB(f.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb
  FROM fin f LEFT JOIN udm m ON m.user_id = f.user_id AND m.date_dim BETWEEN f.a_start AND f.a_end
  GROUP BY 1,2
),
first_st AS (
  SELECT f.album_id, f.user_id, s.sticker_collected_min_ts AS ts, COALESCE(NULLIF(s.new_sticker_source, ''), CONCAT('camp:', IFNULL(s.new_sticker_mtx_campaign_name, '(null)'))) AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj, LOWER(s.sticker_type) AS stype
  FROM fin f JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-02-01' AND DATE '2026-10-12' AND s.album_id IN (17,19,20) AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= f.a_start AND s.sticker_collected_min_date < f.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
last_st AS (
  SELECT album_id, user_id, src, wj, stype FROM first_st
  QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) = 1
),
j AS (
  SELECT p.album_id, IF(p.rev_alb > 0, 'payer', 'nonpayer') AS pay_grp,
    IFNULL(l.src, '(none)') AS src, IFNULL(l.wj, FALSE) AS wj, IFNULL(l.stype, '(none)') AS stype
  FROM pay p LEFT JOIN last_st l USING (album_id, user_id)
),
rk AS (SELECT album_id, pay_grp, src, wj, stype, COUNT(*) AS n,
  ROW_NUMBER() OVER (PARTITION BY album_id, pay_grp ORDER BY COUNT(*) DESC) AS rn FROM j GROUP BY 1,2,3,4,5)
SELECT album_id, pay_grp, IF(rn <= 8, src, 'Other') AS src, IF(rn <= 8, wj, NULL) AS wj, IF(rn <= 8, stype, NULL) AS stype, SUM(n) AS n,
  SUM(SUM(n)) OVER (PARTITION BY album_id, pay_grp) AS grp_n,
  SUM(SUM(n)) OVER (PARTITION BY album_id) AS album_fin
FROM rk GROUP BY 1,2,3,4,5 ORDER BY album_id, pay_grp, n DESC

-- ===== DISNEY (as run: albums 12,13,14,15; window 2026-05-11..; + AND LOWER(s.sticker_type) != 'magic') =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-05' AND album_id IN (12,13,14,15) AND date_dim = DATE_SUB(album_close_date, INTERVAL 1 DAY)
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-05'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end
  FROM ud u
  WHERE u.date_dim = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.uniq >= 144 AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
pay AS (
  SELECT f.album_id, f.user_id, SUM(IF(m.date_dim BETWEEN f.a_start AND DATE_SUB(f.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb
  FROM fin f LEFT JOIN udm m ON m.user_id = f.user_id AND m.date_dim BETWEEN f.a_start AND f.a_end
  GROUP BY 1,2
),
first_st AS (
  SELECT f.album_id, f.user_id, s.sticker_collected_min_ts AS ts, COALESCE(NULLIF(s.new_sticker_source, ''), CONCAT('camp:', IFNULL(s.new_sticker_mtx_campaign_name, '(null)'))) AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj, LOWER(s.sticker_type) AS stype
  FROM fin f JOIN `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-05-11' AND DATE '2026-10-05' AND s.album_id IN (12,13,14,15) AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) != 'magic'
    AND s.sticker_collected_min_date >= f.a_start AND s.sticker_collected_min_date < f.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
last_st AS (
  SELECT album_id, user_id, src, wj, stype FROM first_st
  QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) = 1
),
j AS (
  SELECT p.album_id, IF(p.rev_alb > 0, 'payer', 'nonpayer') AS pay_grp,
    IFNULL(l.src, '(none)') AS src, IFNULL(l.wj, FALSE) AS wj, IFNULL(l.stype, '(none)') AS stype
  FROM pay p LEFT JOIN last_st l USING (album_id, user_id)
),
rk AS (SELECT album_id, pay_grp, src, wj, stype, COUNT(*) AS n,
  ROW_NUMBER() OVER (PARTITION BY album_id, pay_grp ORDER BY COUNT(*) DESC) AS rn FROM j GROUP BY 1,2,3,4,5)
SELECT album_id, pay_grp, IF(rn <= 8, src, 'Other') AS src, IF(rn <= 8, wj, NULL) AS wj, IF(rn <= 8, stype, NULL) AS stype, SUM(n) AS n,
  SUM(SUM(n)) OVER (PARTITION BY album_id, pay_grp) AS grp_n,
  SUM(SUM(n)) OVER (PARTITION BY album_id) AS album_fin
FROM rk GROUP BY 1,2,3,4,5 ORDER BY album_id, pay_grp, n DESC
