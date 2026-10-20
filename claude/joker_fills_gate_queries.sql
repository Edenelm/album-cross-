-- 2026-10-18 (Eden approved): Joker fills per day d-14..-1 by route and sticker type (all players, first receipt). Results: claude/approved-batch-2026-10-18.md
-- Disney 14/15 (50.0 GB)
WITH alb AS (
  SELECT album_id, MAX(album_close_date) AS a_end FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-10' AND DATE '2026-10-06' AND album_id IN (14, 15) GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, s.sticker_id, LOWER(s.sticker_type) AS t, DATE_DIFF(s.sticker_collected_min_date, a.a_end, DAY) AS d,
    IFNULL(s.new_sticker_source, '') AS src
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-10' AND DATE '2026-10-06' AND s.album_id IN (14, 15)
    AND s.user_collected_sticker_flag AND IFNULL(s.collected_by_joker_flag, FALSE) AND s.sticker_collected_min_date < a.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1)
SELECT album_id, d,
  CASE WHEN src IN ('purchase', 'purchase_gift') THEN 'bought' WHEN src = 'marketplace' THEN 'market' ELSE 'gameplay_other' END AS route,
  COUNT(*) AS joker_fills, COUNTIF(sticker_id = 131) AS r131, COUNTIF(t = 'royal' AND sticker_id != 131) AS other_royal,
  COUNTIF(t = 'golden') AS golden, COUNTIF(t = 'common') AS common, COUNT(DISTINCT user_id) AS players,
  ARRAY_AGG(src ORDER BY src LIMIT 1)[OFFSET(0)] AS ex_src
FROM st WHERE d BETWEEN -14 AND -1 GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
;
-- Domino 19/20 (20.8 GB)
WITH alb AS (
  SELECT album_id, MAX(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (19, 20) GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, s.sticker_id, LOWER(s.sticker_type) AS t, DATE_DIFF(s.sticker_collected_min_date, a.a_end, DAY) AS d,
    (   (IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Offer%'
         AND NOT REGEXP_CONTAINS(IFNULL(s.new_sticker_mtx_campaign_name, ''), r'SeasonPass|DreamPass|Info|ecn_Rewa'))
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Store%'
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%ActivePassToGetJoker%'
     OR s.new_sticker_source = 'purchase' OR s.new_sticker_source LIKE '1+%') AS paid
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (19, 20)
    AND s.user_collected_sticker_flag AND IFNULL(s.collected_by_joker_flag, FALSE) AND s.sticker_collected_min_date < a.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1)
SELECT album_id, d, IF(paid, 'bought', 'gameplay') AS route,
  COUNT(*) AS joker_fills, COUNTIF(t = 'royal') AS royal, COUNTIF(t = 'golden') AS golden, COUNTIF(t = 'common') AS common,
  COUNT(DISTINCT user_id) AS players
FROM st WHERE d BETWEEN -14 AND -1 GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
;
