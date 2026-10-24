-- 2026-10-24 (Eden): fix of the closing-week slide ("Dice Sells Wilds All Week; Domino Gives Jokers; Disney Sells Only at the End").
-- Changes vs claude/closing_week_split_golden_queries.sql: latest albums (Dice 63, Domino 20, Disney 15);
-- players = standard-population payers of the album (as topic 6: not first album, login ratio >= 0.5 on close-1, row on close-1, not excluded, paid on any album day);
-- result = % of those payers who got a new sticker with the Wild / Joker that day, bought vs gameplay (Eden's rule: bought with money = bought; all else = gameplay, Market included).

-- ===== Dice 63 (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT user_id, date_dim, album_end_date AS a_end, IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date),
pay AS (
  SELECT a.user_id FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1
  HAVING MAX(IF(a.date_dim < DATE '2026-09-07', a.date_dim, NULL)) = DATE '2026-09-06'
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND MAX(h.first_album_seen) < 63 AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0),
st AS (
  SELECT s.user_id, DATE_DIFF(s.sticker_collected_date, DATE '2026-09-07', DAY) AS d,
    IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AS paid
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pay p USING (user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-07-27' AND DATE '2026-09-06' AND s.album_id = 63
    AND s.is_sticker_collected AND IFNULL(s.collected_from_wild, FALSE)
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1)
SELECT d, (SELECT COUNT(*) FROM pay) AS payers,
  COUNT(DISTINCT IF(paid, user_id, NULL)) AS tool_bought, COUNT(DISTINCT IF(NOT paid, user_id, NULL)) AS tool_gameplay,
  ROUND(COUNT(DISTINCT IF(paid, user_id, NULL)) / (SELECT COUNT(*) FROM pay), 4) AS pct_bought,
  ROUND(COUNT(DISTINCT IF(NOT paid, user_id, NULL)) / (SELECT COUNT(*) FROM pay), 4) AS pct_gameplay
FROM st WHERE d BETWEEN -7 AND -1 GROUP BY 1 ORDER BY 1;

-- ===== Domino 20 (domino-dreams-dbt), close 2026-10-12 =====
WITH ud AS (
  SELECT user_id, date_dim, album_close_date AS a_end, IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac,
    IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
pay AS (
  SELECT a.user_id FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1
  HAVING MAX(IF(a.date_dim < DATE '2026-10-12', a.date_dim, NULL)) = DATE '2026-10-11'
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
    AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL),
st AS (
  SELECT s.user_id, DATE_DIFF(s.sticker_collected_min_date, DATE '2026-10-12', DAY) AS d,
    (   (IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Offer%'
         AND NOT REGEXP_CONTAINS(IFNULL(s.new_sticker_mtx_campaign_name, ''), r'SeasonPass|DreamPass|Info|ecn_Rewa'))
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Store%'
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%ActivePassToGetJoker%'
     OR s.new_sticker_source = 'purchase' OR s.new_sticker_source LIKE '1+%') AS paid
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pay p USING (user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-24' AND DATE '2026-10-11' AND s.album_id = 20
    AND s.user_collected_sticker_flag AND IFNULL(s.collected_by_joker_flag, FALSE)
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1)
SELECT d, (SELECT COUNT(*) FROM pay) AS payers,
  COUNT(DISTINCT IF(paid, user_id, NULL)) AS tool_bought, COUNT(DISTINCT IF(NOT paid, user_id, NULL)) AS tool_gameplay,
  ROUND(COUNT(DISTINCT IF(paid, user_id, NULL)) / (SELECT COUNT(*) FROM pay), 4) AS pct_bought,
  ROUND(COUNT(DISTINCT IF(NOT paid, user_id, NULL)) / (SELECT COUNT(*) FROM pay), 4) AS pct_gameplay
FROM st WHERE d BETWEEN -7 AND -1 GROUP BY 1 ORDER BY 1;

-- ===== Disney 15 (solitaire-dreams-411507), close 2026-10-05 =====
WITH ud AS (
  SELECT user_id, date_dim, album_close_date AS a_end, IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac,
    IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-06' AND album_id = 15 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-06' AND exclude_reason IS NOT NULL),
pay AS (
  SELECT a.user_id FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1
  HAVING MAX(IF(a.date_dim < DATE '2026-10-05', a.date_dim, NULL)) = DATE '2026-10-04'
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
    AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL),
st AS (
  SELECT s.user_id, DATE_DIFF(s.sticker_collected_min_date, DATE '2026-10-05', DAY) AS d,
    IFNULL(s.new_sticker_source, '') IN ('purchase', 'purchase_gift') AS paid
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pay p USING (user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-24' AND DATE '2026-10-04' AND s.album_id = 15
    AND s.user_collected_sticker_flag AND IFNULL(s.collected_by_joker_flag, FALSE)
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1)
SELECT d, (SELECT COUNT(*) FROM pay) AS payers,
  COUNT(DISTINCT IF(paid, user_id, NULL)) AS tool_bought, COUNT(DISTINCT IF(NOT paid, user_id, NULL)) AS tool_gameplay,
  ROUND(COUNT(DISTINCT IF(paid, user_id, NULL)) / (SELECT COUNT(*) FROM pay), 4) AS pct_bought,
  ROUND(COUNT(DISTINCT IF(NOT paid, user_id, NULL)) / (SELECT COUNT(*) FROM pay), 4) AS pct_gameplay
FROM st WHERE d BETWEEN -7 AND -1 GROUP BY 1 ORDER BY 1;
