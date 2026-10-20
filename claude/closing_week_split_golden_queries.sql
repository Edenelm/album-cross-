-- 2026-10-18: closing week (paid vs gameplay closing tool) + new Goldens per day. RAN after Eden approval. Results: claude/closing-week-split-golden-2026-10-18.md
-- All players (same scope as the closing-week slide). Distinct players per day. "New" = first receipt of that sticker by the player.
-- (a) closing tool split: paid vs gameplay (Eden's rule: anything not bought with money = gameplay; Market = gameplay).
-- (b) new Golden: players who got at least one new Golden that day, split paid vs gameplay.

-- ===== Dice (dice-dreams-dbt) — albums 61, 63 =====
WITH alb AS (
  SELECT album_id, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-15' AND album_id IN (61, 63) GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, s.sticker_type AS t, DATE_DIFF(s.sticker_collected_date, a.a_end, DAY) AS d,
    IFNULL(s.collected_from_wild, FALSE) AS wild, IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AS paid
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-15' AND DATE '2026-09-15' AND s.album_id IN (61, 63)
    AND s.is_sticker_collected AND s.sticker_collected_date < a.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1)
SELECT album_id, d,
  COUNT(DISTINCT IF(wild AND paid, user_id, NULL)) AS tool_paid,
  COUNT(DISTINCT IF(wild AND NOT paid, user_id, NULL)) AS tool_gameplay,
  COUNT(DISTINCT IF(t = 'golden', user_id, NULL)) AS golden_any,
  COUNT(DISTINCT IF(t = 'golden' AND paid, user_id, NULL)) AS golden_paid,
  COUNT(DISTINCT IF(t = 'golden' AND NOT paid, user_id, NULL)) AS golden_gameplay,
  COUNTIF(t = 'golden') AS new_goldens
FROM st WHERE d BETWEEN -10 AND -1 GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== Domino (domino-dreams-dbt) — albums 17, 19 =====
-- Paid rule as validated 2026-10-15 (99.8-100% within 10 min of a purchase).
WITH alb AS (
  SELECT album_id, MAX(album_close_date) AS a_end
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-08-31' AND album_id IN (17, 19) GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, LOWER(s.sticker_type) AS t, DATE_DIFF(s.sticker_collected_min_date, a.a_end, DAY) AS d,
    IFNULL(s.collected_by_joker_flag, FALSE) AS wild,
    (   (IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Offer%'
         AND NOT REGEXP_CONTAINS(IFNULL(s.new_sticker_mtx_campaign_name, ''), r'SeasonPass|DreamPass|Info|ecn_Rewa'))
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Store%'
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%ActivePassToGetJoker%'
     OR s.new_sticker_source = 'purchase' OR s.new_sticker_source LIKE '1+%') AS paid
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-01' AND DATE '2026-08-31' AND s.album_id IN (17, 19)
    AND s.user_collected_sticker_flag AND s.sticker_collected_min_date < a.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1)
SELECT album_id, d,
  COUNT(DISTINCT IF(wild AND paid, user_id, NULL)) AS tool_paid,
  COUNT(DISTINCT IF(wild AND NOT paid, user_id, NULL)) AS tool_gameplay,
  COUNT(DISTINCT IF(t = 'golden', user_id, NULL)) AS golden_any,
  COUNT(DISTINCT IF(t = 'golden' AND paid, user_id, NULL)) AS golden_paid,
  COUNT(DISTINCT IF(t = 'golden' AND NOT paid, user_id, NULL)) AS golden_gameplay,
  COUNTIF(t = 'golden') AS new_goldens
FROM st WHERE d BETWEEN -10 AND -1 GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== Disney (solitaire-dreams-411507) — albums 14, 15 =====
-- Paid = new_sticker_source purchase / purchase_gift. Market (marketplace) = gameplay by Eden's rule, shown separately.
WITH alb AS (
  SELECT album_id, MAX(album_close_date) AS a_end
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-10' AND DATE '2026-10-06' AND album_id IN (14, 15) GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, LOWER(s.sticker_type) AS t, DATE_DIFF(s.sticker_collected_min_date, a.a_end, DAY) AS d,
    IFNULL(s.collected_by_joker_flag, FALSE) AS wild,
    IFNULL(s.new_sticker_source, '') IN ('purchase', 'purchase_gift') AS paid,
    IFNULL(s.new_sticker_source, '') = 'marketplace' AS market
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-10' AND DATE '2026-10-06' AND s.album_id IN (14, 15)
    AND s.user_collected_sticker_flag AND s.sticker_collected_min_date < a.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1)
SELECT album_id, d,
  COUNT(DISTINCT IF(wild AND paid, user_id, NULL)) AS tool_paid,
  COUNT(DISTINCT IF(wild AND market, user_id, NULL)) AS tool_market,
  COUNT(DISTINCT IF(wild AND NOT paid AND NOT market, user_id, NULL)) AS tool_gameplay_other,
  COUNT(DISTINCT IF(t = 'golden', user_id, NULL)) AS golden_any,
  COUNT(DISTINCT IF(t = 'golden' AND paid, user_id, NULL)) AS golden_paid,
  COUNT(DISTINCT IF(t = 'golden' AND NOT paid, user_id, NULL)) AS golden_gameplay,
  COUNTIF(t = 'golden') AS new_goldens
FROM st WHERE d BETWEEN -10 AND -1 GROUP BY 1, 2 ORDER BY 1, 2;
