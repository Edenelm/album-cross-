-- Dice 65 added 2026-10-25 (Eden: slide 'Share of Active Payers Who Bought a New Golden' on Dice 65 / Domino 20 / Disney 15).
-- Dice paid rule = corrected rule (Pricing% pack key, without Pricing_CP / Pricing_DDJ), as golden_purchase_revenue_2026-10-22.sql. 9 GB. Results: golden-buy-share-d65-d20-s15-2026-10-25.md

-- ===== DICE 65 (dice-dreams-dbt) =====
WITH alb AS (SELECT MAX(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album`
             WHERE date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-10-25' AND album_id = 65),
ud AS (
  SELECT u.user_id, DATE_DIFF(u.date_dim, a.a_end, DAY) AS d, IFNULL(u.is_active, FALSE) AS act, IFNULL(u.spent_in_album_today, 0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u CROSS JOIN alb a
  WHERE u.date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-10-25' AND u.album_id = 65 AND u.date_dim <= u.album_end_date),
pay AS (SELECT user_id FROM ud GROUP BY 1 HAVING SUM(spend) > 0),
ap AS (SELECT u.d, u.user_id FROM ud u JOIN pay USING (user_id) WHERE u.act AND u.d BETWEEN -10 AND -1),
st AS (
  SELECT s.user_id, s.sticker_type AS t, s.sticker_collected_date AS dt, IFNULL(s.sticker_pack_key, '') AS offer,
    IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AND NOT REGEXP_CONTAINS(IFNULL(s.sticker_pack_key, ''), r'^Pricing_(CP|DDJ)(_|$)') AS paid
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-09-01' AND DATE '2026-10-25' AND s.album_id = 65 AND IFNULL(s.is_sticker_collected, TRUE)
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
gb AS (SELECT DATE_DIFF(st.dt, a.a_end, DAY) AS d, st.user_id, st.offer FROM st CROSS JOIN alb a
       WHERE st.t = 'golden' AND st.paid AND DATE_DIFF(st.dt, a.a_end, DAY) BETWEEN -10 AND -1),
gbu AS (SELECT DISTINCT d, user_id FROM gb),
offs AS (SELECT d, STRING_AGG(FORMAT('%s:%d', offer, n), ' | ' ORDER BY n DESC) AS offers
         FROM (SELECT d, offer, COUNT(DISTINCT user_id) AS n FROM gb GROUP BY 1, 2 HAVING COUNT(DISTINCT user_id) >= 100) GROUP BY 1)
SELECT ap.d, COUNT(*) AS active_payers, COUNTIF(gbu.user_id IS NOT NULL) AS bought_golden,
  ROUND(COUNTIF(gbu.user_id IS NOT NULL) / COUNT(*), 4) AS share, ANY_VALUE(offs.offers) AS offers
FROM ap LEFT JOIN gbu USING (d, user_id) LEFT JOIN offs USING (d) GROUP BY 1 ORDER BY 1
;

-- Eden 2026-10-23 (option A): rerun slide 'Share of Active Payers Who Bought a New Golden, per Day, Last 10 Days' on Domino 20 / Disney 15
-- (same albums as the Golden / all-144 / missing-at-close slides). Same rules as golden_purchase_revenue_2026-10-22.sql (option B section + offers section).
-- Output per day d -10..-1: active payers, payers with a bought new Golden, share, and offers with 100+ Golden buyers that day ("offer:n").

-- ===== DOMINO 20 (domino-dreams-dbt) =====
WITH alb AS (SELECT MAX(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
             WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND album_id = 20),
ud AS (
  SELECT u.user_id, DATE_DIFF(u.date_dim, a.a_end, DAY) AS d, IFNULL(u.active_flag, FALSE) AS act, IFNULL(u.album_spent_today, 0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` u CROSS JOIN alb a
  WHERE u.date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND u.album_id = 20 AND u.date_dim <= u.album_close_date),
pay AS (SELECT user_id FROM ud GROUP BY 1 HAVING SUM(spend) > 0),
ap AS (SELECT u.d, u.user_id FROM ud u JOIN pay USING (user_id) WHERE u.act AND u.d BETWEEN -10 AND -1),
st AS (
  SELECT s.user_id, LOWER(s.sticker_type) AS t, s.sticker_collected_min_date AS dt, IFNULL(s.new_sticker_mtx_campaign_name, s.new_sticker_source) AS offer,
    (   (IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Offer%'
         AND NOT REGEXP_CONTAINS(IFNULL(s.new_sticker_mtx_campaign_name, ''), r'SeasonPass|DreamPass|Info|ecn_Rewa'))
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Store%'
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%ActivePassToGetJoker%'
     OR s.new_sticker_source = 'purchase' OR s.new_sticker_source LIKE '1+%') AS paid
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND s.album_id = 20 AND s.user_collected_sticker_flag
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
gb AS (SELECT DATE_DIFF(st.dt, a.a_end, DAY) AS d, st.user_id, st.offer FROM st CROSS JOIN alb a
       WHERE st.t = 'golden' AND st.paid AND DATE_DIFF(st.dt, a.a_end, DAY) BETWEEN -10 AND -1),
gbu AS (SELECT DISTINCT d, user_id FROM gb),
offs AS (SELECT d, STRING_AGG(FORMAT('%s:%d', offer, n), ' | ' ORDER BY n DESC) AS offers
         FROM (SELECT d, offer, COUNT(DISTINCT user_id) AS n FROM gb GROUP BY 1, 2 HAVING COUNT(DISTINCT user_id) >= 100) GROUP BY 1)
SELECT ap.d, COUNT(*) AS active_payers, COUNTIF(gbu.user_id IS NOT NULL) AS bought_golden,
  ROUND(COUNTIF(gbu.user_id IS NOT NULL) / COUNT(*), 4) AS share, ANY_VALUE(offs.offers) AS offers
FROM ap LEFT JOIN gbu USING (d, user_id) LEFT JOIN offs USING (d) GROUP BY 1 ORDER BY 1;

-- ===== DISNEY 15 (solitaire-dreams-411507) =====
WITH alb AS (SELECT MAX(album_close_date) AS a_end FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
             WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND album_id = 15),
ud AS (
  SELECT u.user_id, DATE_DIFF(u.date_dim, a.a_end, DAY) AS d, IFNULL(u.active_flag, FALSE) AS act, IFNULL(u.album_spent_today, 0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` u CROSS JOIN alb a
  WHERE u.date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND u.album_id = 15 AND u.date_dim <= u.album_close_date),
pay AS (SELECT user_id FROM ud GROUP BY 1 HAVING SUM(spend) > 0),
ap AS (SELECT u.d, u.user_id FROM ud u JOIN pay USING (user_id) WHERE u.act AND u.d BETWEEN -10 AND -1),
st AS (
  SELECT s.user_id, LOWER(s.sticker_type) AS t, s.sticker_collected_min_date AS dt, IFNULL(s.new_sticker_mtx_campaign_name, s.new_sticker_source) AS offer,
    IFNULL(s.new_sticker_source, '') IN ('purchase', 'purchase_gift') AS paid
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND s.album_id = 15 AND s.user_collected_sticker_flag
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
gb AS (SELECT DATE_DIFF(st.dt, a.a_end, DAY) AS d, st.user_id, st.offer FROM st CROSS JOIN alb a
       WHERE st.t = 'golden' AND st.paid AND DATE_DIFF(st.dt, a.a_end, DAY) BETWEEN -10 AND -1),
gbu AS (SELECT DISTINCT d, user_id FROM gb),
offs AS (SELECT d, STRING_AGG(FORMAT('%s:%d', offer, n), ' | ' ORDER BY n DESC) AS offers
         FROM (SELECT d, offer, COUNT(DISTINCT user_id) AS n FROM gb GROUP BY 1, 2 HAVING COUNT(DISTINCT user_id) >= 100) GROUP BY 1)
SELECT ap.d, COUNT(*) AS active_payers, COUNTIF(gbu.user_id IS NOT NULL) AS bought_golden,
  ROUND(COUNTIF(gbu.user_id IS NOT NULL) / COUNT(*), 4) AS share, ANY_VALUE(offs.offers) AS offers
FROM ap LEFT JOIN gbu USING (d, user_id) LEFT JOIN offs USING (d) GROUP BY 1 ORDER BY 1;
