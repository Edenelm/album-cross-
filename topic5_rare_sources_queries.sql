-- Topic 5 (2026-10-12): new rares by source x quarter. Run each in its own project. Deduped per user x sticker; top 10 sources per album.

-- dice
WITH rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_start_date AS a_start, a.album_end_date AS a_end,
    a.album_login_ratio AS login_ratio, IFNULL(a.spent_in_album_today, 0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < a.album_end_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
st AS (
  SELECT p.album_id, p.user_id, IFNULL(NULLIF(s.sticker_source, ''), '(null)') AS src, IFNULL(s.collected_from_wild, FALSE) AS wj,
    LEAST(3, CAST(FLOOR(DATE_DIFF(s.sticker_collected_date, p.a_start, DAY) / DATE_DIFF(p.a_end, p.a_start, DAY) * 4) AS INT64)) AS q
  FROM pop p JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63)
    AND s.sticker_type = 'super' AND s.is_sticker_collected
    AND s.sticker_collected_date >= p.a_start AND s.sticker_collected_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
rk AS (SELECT album_id, src, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC, src) AS rn FROM st GROUP BY 1, 2),
lab AS (SELECT st.album_id, st.user_id, st.q, st.wj, IF(rk.rn <= 10, st.src, 'Other') AS source FROM st JOIN rk USING (album_id, src)),
pu AS (SELECT album_id, COUNT(*) AS pu FROM pop GROUP BY 1)
SELECT l.album_id, l.source, COUNT(*) AS new_rares, COUNT(DISTINCT l.user_id) AS players,
  ROUND(COUNT(DISTINCT l.user_id) / ANY_VALUE(pu.pu), 3) AS share_of_pu,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY l.album_id), 3) AS share_all,
  ROUND(COUNTIF(l.q = 0) / SUM(COUNTIF(l.q = 0)) OVER (PARTITION BY l.album_id), 3) AS share_q1,
  ROUND(COUNTIF(l.q = 1) / SUM(COUNTIF(l.q = 1)) OVER (PARTITION BY l.album_id), 3) AS share_q2,
  ROUND(COUNTIF(l.q = 2) / SUM(COUNTIF(l.q = 2)) OVER (PARTITION BY l.album_id), 3) AS share_q3,
  ROUND(COUNTIF(l.q = 3) / SUM(COUNTIF(l.q = 3)) OVER (PARTITION BY l.album_id), 3) AS share_q4
FROM lab l JOIN pu USING (album_id) GROUP BY 1, 2
UNION ALL
SELECT l.album_id, '~ WILD/JOKER flag (share of new rares)', COUNT(*), ANY_VALUE(pu.pu), NULL,
  ROUND(COUNTIF(l.wj) / COUNT(*), 3),
  ROUND(COUNTIF(l.wj AND l.q = 0) / NULLIF(COUNTIF(l.q = 0), 0), 3), ROUND(COUNTIF(l.wj AND l.q = 1) / NULLIF(COUNTIF(l.q = 1), 0), 3),
  ROUND(COUNTIF(l.wj AND l.q = 2) / NULLIF(COUNTIF(l.q = 2), 0), 3), ROUND(COUNTIF(l.wj AND l.q = 3) / NULLIF(COUNTIF(l.q = 3), 0), 3)
FROM lab l JOIN pu USING (album_id) GROUP BY 1, 2
ORDER BY album_id, share_all DESC;

-- domino
WITH excluded AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND suspected_cheater_flag),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start, a.album_close_date AS a_end, a.login_ratio,
    IFNULL(a.album_spent_today, 0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND a.album_id IN (17, 19)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
st AS (
  SELECT p.album_id, p.user_id, IFNULL(NULLIF(s.new_sticker_source, ''), '(null)') AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj,
    LEAST(3, CAST(FLOOR(DATE_DIFF(s.sticker_collected_min_date, p.a_start, DAY) / DATE_DIFF(p.a_end, p.a_start, DAY) * 4) AS INT64)) AS q
  FROM pop p JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND s.album_id IN (17, 19)
    AND LOWER(s.sticker_type) = 'royal' AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= p.a_start AND s.sticker_collected_min_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
rk AS (SELECT album_id, src, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC, src) AS rn FROM st GROUP BY 1, 2),
lab AS (SELECT st.album_id, st.user_id, st.q, st.wj, IF(rk.rn <= 10, st.src, 'Other') AS source FROM st JOIN rk USING (album_id, src)),
pu AS (SELECT album_id, COUNT(*) AS pu FROM pop GROUP BY 1)
SELECT l.album_id, l.source, COUNT(*) AS new_rares, COUNT(DISTINCT l.user_id) AS players,
  ROUND(COUNT(DISTINCT l.user_id) / ANY_VALUE(pu.pu), 3) AS share_of_pu,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY l.album_id), 3) AS share_all,
  ROUND(COUNTIF(l.q = 0) / SUM(COUNTIF(l.q = 0)) OVER (PARTITION BY l.album_id), 3) AS share_q1,
  ROUND(COUNTIF(l.q = 1) / SUM(COUNTIF(l.q = 1)) OVER (PARTITION BY l.album_id), 3) AS share_q2,
  ROUND(COUNTIF(l.q = 2) / SUM(COUNTIF(l.q = 2)) OVER (PARTITION BY l.album_id), 3) AS share_q3,
  ROUND(COUNTIF(l.q = 3) / SUM(COUNTIF(l.q = 3)) OVER (PARTITION BY l.album_id), 3) AS share_q4
FROM lab l JOIN pu USING (album_id) GROUP BY 1, 2
UNION ALL
SELECT l.album_id, '~ WILD/JOKER flag (share of new rares)', COUNT(*), ANY_VALUE(pu.pu), NULL,
  ROUND(COUNTIF(l.wj) / COUNT(*), 3),
  ROUND(COUNTIF(l.wj AND l.q = 0) / NULLIF(COUNTIF(l.q = 0), 0), 3), ROUND(COUNTIF(l.wj AND l.q = 1) / NULLIF(COUNTIF(l.q = 1), 0), 3),
  ROUND(COUNTIF(l.wj AND l.q = 2) / NULLIF(COUNTIF(l.q = 2), 0), 3), ROUND(COUNTIF(l.wj AND l.q = 3) / NULLIF(COUNTIF(l.q = 3), 0), 3)
FROM lab l JOIN pu USING (album_id) GROUP BY 1, 2
ORDER BY album_id, share_all DESC;

-- disney
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start, a.album_close_date AS a_end, a.login_ratio,
    IFNULL(a.album_spent_today, 0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND a.album_id IN (14, 15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
st AS (
  SELECT p.album_id, p.user_id, IFNULL(NULLIF(s.new_sticker_source, ''), '(null)') AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj,
    LEAST(3, CAST(FLOOR(DATE_DIFF(s.sticker_collected_min_date, p.a_start, DAY) / DATE_DIFF(p.a_end, p.a_start, DAY) * 4) AS INT64)) AS q
  FROM pop p JOIN `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND s.album_id IN (14, 15)
    AND LOWER(s.sticker_type) = 'royal' AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= p.a_start AND s.sticker_collected_min_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
rk AS (SELECT album_id, src, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC, src) AS rn FROM st GROUP BY 1, 2),
lab AS (SELECT st.album_id, st.user_id, st.q, st.wj, IF(rk.rn <= 10, st.src, 'Other') AS source FROM st JOIN rk USING (album_id, src)),
pu AS (SELECT album_id, COUNT(*) AS pu FROM pop GROUP BY 1)
SELECT l.album_id, l.source, COUNT(*) AS new_rares, COUNT(DISTINCT l.user_id) AS players,
  ROUND(COUNT(DISTINCT l.user_id) / ANY_VALUE(pu.pu), 3) AS share_of_pu,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY l.album_id), 3) AS share_all,
  ROUND(COUNTIF(l.q = 0) / SUM(COUNTIF(l.q = 0)) OVER (PARTITION BY l.album_id), 3) AS share_q1,
  ROUND(COUNTIF(l.q = 1) / SUM(COUNTIF(l.q = 1)) OVER (PARTITION BY l.album_id), 3) AS share_q2,
  ROUND(COUNTIF(l.q = 2) / SUM(COUNTIF(l.q = 2)) OVER (PARTITION BY l.album_id), 3) AS share_q3,
  ROUND(COUNTIF(l.q = 3) / SUM(COUNTIF(l.q = 3)) OVER (PARTITION BY l.album_id), 3) AS share_q4
FROM lab l JOIN pu USING (album_id) GROUP BY 1, 2
UNION ALL
SELECT l.album_id, '~ WILD/JOKER flag (share of new rares)', COUNT(*), ANY_VALUE(pu.pu), NULL,
  ROUND(COUNTIF(l.wj) / COUNT(*), 3),
  ROUND(COUNTIF(l.wj AND l.q = 0) / NULLIF(COUNTIF(l.q = 0), 0), 3), ROUND(COUNTIF(l.wj AND l.q = 1) / NULLIF(COUNTIF(l.q = 1), 0), 3),
  ROUND(COUNTIF(l.wj AND l.q = 2) / NULLIF(COUNTIF(l.q = 2), 0), 3), ROUND(COUNTIF(l.wj AND l.q = 3) / NULLIF(COUNTIF(l.q = 3), 0), 3)
FROM lab l JOIN pu USING (album_id) GROUP BY 1, 2
ORDER BY album_id, share_all DESC;

-- ===== 5d. Category by album quarter (mapping v2) — Dice =====
WITH rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_start_date AS a_start, a.album_end_date AS a_end,
    a.album_login_ratio AS login_ratio, IFNULL(a.spent_in_album_today, 0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < a.album_end_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
st AS (
  SELECT p.album_id, p.user_id, IFNULL(NULLIF(s.sticker_source, ''), '(null)') AS src, IFNULL(s.collected_from_wild, FALSE) AS wj, s.sticker_mtx_campaign_name AS camp,
    LEAST(3, CAST(FLOOR(DATE_DIFF(s.sticker_collected_date, p.a_start, DAY) / DATE_DIFF(p.a_end, p.a_start, DAY) * 4) AS INT64)) AS q
  FROM pop p JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63)
    AND s.sticker_type = 'super' AND s.is_sticker_collected
    AND s.sticker_collected_date >= p.a_start AND s.sticker_collected_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
c AS (SELECT album_id, q, CASE
    WHEN src = 'Pets Feature' THEN 'A Long feature'
    WHEN src LIKE 'Trail%' THEN 'Trail event'
    WHEN src IN ('RewardCalendar','WeeklyGoals') THEN 'B Daily'
    WHEN src = 'Duplication exchange' THEN 'E Dup exchange'
    WHEN src IN ('Dream Pass','DP_Big_Chest_WithStamp','Decoy_BuyAll','Decoy_Upgrade','OnePlusSixteen','OnePlusTwelve_V4','1PlusX','BuildYourBundle','Big_Chest_Animated_v2','Big_Chest_Animated_v3','1To2_BigChest_Animated') THEN 'D Paid offer'
    WHEN src IN ('(null)','Pending Rewards') THEN 'Unknown'
    WHEN src = 'SOCIAL SET COMPLETE' THEN 'Social'
    ELSE 'Other events' END AS cat FROM st)
SELECT album_id, q + 1 AS quarter, cat, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, q), 4) AS share
FROM c GROUP BY album_id, q, cat ORDER BY 1, 2, 3

-- ===== 5d — Domino =====
WITH excluded AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND suspected_cheater_flag),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start, a.album_close_date AS a_end, a.login_ratio,
    IFNULL(a.album_spent_today, 0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND a.album_id IN (17, 19)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
st AS (
  SELECT p.album_id, p.user_id, IFNULL(NULLIF(s.new_sticker_source, ''), '(null)') AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj, s.new_sticker_mtx_campaign_name AS camp,
    LEAST(3, CAST(FLOOR(DATE_DIFF(s.sticker_collected_min_date, p.a_start, DAY) / DATE_DIFF(p.a_end, p.a_start, DAY) * 4) AS INT64)) AS q
  FROM pop p JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND s.album_id IN (17, 19)
    AND LOWER(s.sticker_type) = 'royal' AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= p.a_start AND s.sticker_collected_min_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
c AS (SELECT album_id, q, CASE
    WHEN src = 'pixie_reward' THEN 'A Long feature'
    WHEN LOWER(src) LIKE '%momentum%' THEN 'Momentum'
    WHEN LOWER(src) LIKE '%trail%' AND LOWER(src) NOT LIKE '%tournament%' THEN 'Trail event'
    WHEN src = 'days_milestone' THEN 'B Daily'
    WHEN src = 'duplicates' THEN 'E Dup exchange'
    WHEN src = 'Market' THEN 'M Closing market'
    WHEN src IN ('joker','progress_offer','Missions','BuyThemAll','SeasonPass','OfferLuckyTwister','Box','mtx','1po') OR src LIKE '1+%' THEN 'D Paid offer'
    WHEN src = '(null)' THEN 'Unknown'
    WHEN src = 'collaboration grand prize' THEN 'Social'
    ELSE 'Other events' END AS cat FROM st)
SELECT album_id, q + 1 AS quarter, cat, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, q), 4) AS share
FROM c GROUP BY album_id, q, cat ORDER BY 1, 2, 3

-- ===== 5d — Disney =====
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start, a.album_close_date AS a_end, a.login_ratio,
    IFNULL(a.album_spent_today, 0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND a.album_id IN (14, 15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
st AS (
  SELECT p.album_id, p.user_id, IFNULL(NULLIF(s.new_sticker_source, ''), '(null)') AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj, s.new_sticker_mtx_campaign_name AS camp,
    LEAST(3, CAST(FLOOR(DATE_DIFF(s.sticker_collected_min_date, p.a_start, DAY) / DATE_DIFF(p.a_end, p.a_start, DAY) * 4) AS INT64)) AS q
  FROM pop p JOIN `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND s.album_id IN (14, 15)
    AND LOWER(s.sticker_type) = 'royal' AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= p.a_start AND s.sticker_collected_min_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
c AS (SELECT album_id, q, CASE
    WHEN LOWER(src) LIKE 'mf %' THEN 'A Long feature'
    WHEN src = 'momentum' THEN 'Momentum'
    WHEN LOWER(src) LIKE '%trail%' THEN 'Trail event'
    WHEN src = 'daily_reward' THEN 'B Daily'
    WHEN src = 'marketplace' THEN 'M Closing market'
    WHEN src = 'purchase' THEN 'D Paid offer'
    WHEN src = 'friend_invite' THEN 'Social'
    WHEN src IN ('(null)','backfill_data') THEN 'Unknown'
    ELSE 'Other events' END AS cat FROM st)
SELECT album_id, q + 1 AS quarter, cat, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, q), 4) AS share
FROM c GROUP BY album_id, q, cat ORDER BY 1, 2, 3

-- ===== 5d v2 — Dice with blank-source fix (Puzzle/Merge Collection via sticker_pack_key) =====
WITH rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_start_date AS a_start, a.album_end_date AS a_end,
    a.album_login_ratio AS login_ratio, IFNULL(a.spent_in_album_today, 0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < a.album_end_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
st AS (
  SELECT p.album_id, p.user_id, COALESCE(NULLIF(s.sticker_source, ''), CASE
      WHEN s.sticker_pack_key LIKE 'HGP_Puzzle_Collection%' THEN 'puzzle_collection_high_tier'
      WHEN s.sticker_pack_key LIKE 'HGP_Merge_Collection%' THEN 'merge_collection_high_tier'
      WHEN s.sticker_pack_key LIKE 'GP_Puzzle_Collection%' THEN 'puzzle_collection_last_tier'
      WHEN s.sticker_pack_key LIKE 'GP_Merge_Collection%' THEN 'merge_collection_last_tier' END, '(null)') AS src, IFNULL(s.collected_from_wild, FALSE) AS wj, s.sticker_mtx_campaign_name AS camp,
    LEAST(3, CAST(FLOOR(DATE_DIFF(s.sticker_collected_date, p.a_start, DAY) / DATE_DIFF(p.a_end, p.a_start, DAY) * 4) AS INT64)) AS q
  FROM pop p JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63)
    AND s.sticker_type = 'super' AND s.is_sticker_collected
    AND s.sticker_collected_date >= p.a_start AND s.sticker_collected_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
c AS (SELECT album_id, q, CASE
    WHEN src LIKE '%_collection_%_tier' THEN 'Collection (Puzzle/Merge)'
    WHEN src = 'Pets Feature' THEN 'A Long feature'
    WHEN src LIKE 'Trail%' THEN 'Trail event'
    WHEN src IN ('RewardCalendar','WeeklyGoals') THEN 'B Daily'
    WHEN src = 'Duplication exchange' THEN 'E Dup exchange'
    WHEN src IN ('Dream Pass','DP_Big_Chest_WithStamp','Decoy_BuyAll','Decoy_Upgrade','OnePlusSixteen','OnePlusTwelve_V4','1PlusX','BuildYourBundle','Big_Chest_Animated_v2','Big_Chest_Animated_v3','1To2_BigChest_Animated') THEN 'D Paid offer'
    WHEN src IN ('(null)','Pending Rewards') THEN 'Unknown'
    WHEN src = 'SOCIAL SET COMPLETE' THEN 'Social'
    ELSE 'Other events' END AS cat FROM st)
SELECT album_id, q + 1 AS quarter, cat, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, q), 4) AS share
FROM c GROUP BY album_id, q, cat ORDER BY 1, 2, 3
