-- 2026-10-29 Domino album 20: FU pricing hypothesis, step 1 (mechanism and data map). domino-dreams-dbt.
-- Q1: date coverage of the curated exposure log (offer triggered). Result: 2026-01-01..2026-04-15 only -> no album 20.
SELECT MAX(date_dim) AS last_day, MIN(date_dim) AS first_day, COUNT(DISTINCT date_dim) AS days
FROM `domino-dreams-dbt.prod_20_core.core_mtx_event_triggered`
WHERE date_dim BETWEEN '2026-01-01' AND '2026-10-28';

-- Q2: what the album-20 end puzzles gave: new stickers by campaign, sticker type and Joker flag (26.9-12.10).
SELECT REGEXP_EXTRACT(LOWER(new_sticker_mtx_campaign_name), r'^([^|]+)') AS camp,
  LOWER(sticker_type) AS sticker_type, IFNULL(collected_by_joker_flag, FALSE) AS by_joker,
  COUNT(*) AS stickers, COUNT(DISTINCT user_id) AS players,
  MIN(sticker_collected_min_date) AS d0, MAX(sticker_collected_min_date) AS d1
FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers`
WHERE sticker_collected_min_date BETWEEN DATE '2026-09-26' AND DATE '2026-10-12' AND album_id = 20
  AND user_collected_sticker_flag
  AND REGEXP_CONTAINS(LOWER(new_sticker_mtx_campaign_name), r'summerfever|jokerpuzzle')
GROUP BY 1,2,3 ORDER BY 1, stickers DESC;

-- Q3 (staging, Eden OK 2026-10-29): album-end offer purchases 5-12.10 by campaign, SKU column and stickers missing at the end of the day before
--     (price / CZ = usd_amount / smart_segments.cz_c at purchase). Result in the doc, table "Price vs CZ by distance".
WITH p AS (
  SELECT user_id, pdate, LOWER(REGEXP_EXTRACT(mtx_campaign_name, r'^([^|]+)')) AS camp,
    mtx_template_sku_column_name AS sku_col, purchase_sku, SAFE_CAST(usd_amount AS FLOAT64) AS usd,
    SAFE_CAST(JSON_VALUE(smart_segments, '$.cz_c') AS FLOAT64) AS cz, external_order_id
  FROM `domino-dreams-dbt.prod_10_staging.stg_purchase_completed_vw`
  WHERE pdate BETWEEN DATE '2026-10-05' AND DATE '2026-10-12'
),
p1 AS (SELECT user_id, pdate, camp, sku_col, ANY_VALUE(purchase_sku) AS sku, ANY_VALUE(usd) AS usd, ANY_VALUE(cz) AS cz
  FROM p GROUP BY user_id, pdate, camp, sku_col, external_order_id),
ud AS (
  SELECT user_id, date_dim, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-10-04' AND DATE '2026-10-11' AND album_id = 20
),
j AS (SELECT p1.*, 144 - ud.uniq AS miss_start FROM p1 LEFT JOIN ud ON ud.user_id = p1.user_id AND ud.date_dim = DATE_SUB(p1.pdate, INTERVAL 1 DAY))
SELECT camp, sku_col,
  CASE WHEN miss_start IS NULL THEN 'x_unknown' WHEN miss_start <= 0 THEN '0_done' WHEN miss_start <= 2 THEN '1_1-2' WHEN miss_start <= 3 THEN '2_3' WHEN miss_start <= 6 THEN '3_4-6' ELSE '4_7+' END AS miss_grp,
  COUNT(*) AS buys, COUNT(DISTINCT user_id) AS buyers, ROUND(SUM(usd)) AS usd, APPROX_QUANTILES(usd, 2)[OFFSET(1)] AS usd_med,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(usd, cz), 2)[OFFSET(1)], 2) AS x_cz_med, MIN(pdate) AS d0, MAX(pdate) AS d1
FROM j WHERE REGEXP_CONTAINS(camp, r'album|joker|puzzle|final|coloring|sunny|1\+9|1\+12|1\+4|btaplus|bta\+|buythemall')
GROUP BY 1,2,3 HAVING buys >= 20 ORDER BY camp, sku_col, miss_grp;

-- Q4 (staging): exposure (offer triggered) 5-11.10 by campaign, mtx_segment_key and stickers missing -> found the FU price segments and the test.
WITH t AS (
  SELECT user_id, pdate, LOWER(REGEXP_EXTRACT(mtx_campaign_name, r'^([^|]+)')) AS camp, mtx_segment_key AS seg
  FROM `domino-dreams-dbt.prod_10_staging.stg_mtx_event_triggered_vw`
  WHERE pdate BETWEEN DATE '2026-10-05' AND DATE '2026-10-11' AND album_id = 20
    AND REGEXP_CONTAINS(LOWER(mtx_campaign_name), r'joker|puzzle|final|buythemall|1\+2album|sunny')
),
ud AS (
  SELECT user_id, date_dim, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-10-04' AND DATE '2026-10-10' AND album_id = 20
),
j AS (SELECT t.*, 144 - ud.uniq AS miss FROM t LEFT JOIN ud ON ud.user_id = t.user_id AND ud.date_dim = DATE_SUB(t.pdate, INTERVAL 1 DAY))
SELECT camp, seg,
  CASE WHEN miss IS NULL THEN 'x' WHEN miss <= 0 THEN '0_done' WHEN miss <= 2 THEN '1_1-2' WHEN miss <= 3 THEN '2_3' WHEN miss <= 6 THEN '3_4-6' ELSE '4_7+' END AS miss_grp,
  COUNT(DISTINCT user_id) AS users, MIN(pdate) AS d0, MAX(pdate) AS d1
FROM j GROUP BY 1,2,3 HAVING users >= 200 ORDER BY camp, seg, miss_grp;

-- Q5: denominator, album-20 players active 5-11.10 = 892,727.
SELECT COUNT(DISTINCT user_id) AS active_players_5_11_oct
FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
WHERE date_dim BETWEEN DATE '2026-10-05' AND DATE '2026-10-11' AND album_id = 20;
