-- 2026-10-22 (Eden): revenue in the last 10 days before close (d -10..-1, close day out) from purchases of Goldens.
-- All players (same scope as the 'goldens-week' slide). Bought Golden = first receipt of a Golden set sticker whose source is paid
-- (any route: pack, specific-sticker offer, bought Wild/Joker; Eden: "the main thing is he bought a Golden, no matter how").
-- Paid rule per game = the slide's rule (Dice Pricing% pack key; Domino validated campaign rule; Disney purchase / purchase_gift; Market not counted).
-- Revenue measures (no ID links a purchase to a sticker):
--   min10 = sum of purchases that were followed by a bought new Golden within 10 minutes (Dice, Domino; Disney has no purchase timestamps).
--   day   = all purchase revenue of the player on a day they got a bought new Golden (all games; upper bound).
-- Denominator = all purchase revenue in the same 10 days, same purchase table.

-- ===== Dice (dice-dreams-dbt) — albums 61, 63 =====
WITH alb AS (
  SELECT album_id, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-15' AND album_id IN (61, 63) GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, s.sticker_type AS t, s.sticker_collected_ts AS ts, s.sticker_collected_date AS dt,
    IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AS paid
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (61, 63) AND s.is_sticker_collected
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
gold AS (
  SELECT st.album_id, st.user_id, st.ts, st.dt
  FROM st JOIN alb a USING (album_id)
  WHERE st.t = 'golden' AND st.paid AND DATE_DIFF(st.dt, a.a_end, DAY) BETWEEN -10 AND -1),
pur AS (
  SELECT a.album_id, v.user_id, v.timestamp AS ts, DATE(v.timestamp) AS dt, v.external_order_id AS oid, v.purchase_amount AS amt
  FROM `dice-dreams-dbt.20_core.purchase_completed_vw` v JOIN alb a ON DATE_DIFF(DATE(v.timestamp), a.a_end, DAY) BETWEEN -10 AND -1
  WHERE v.pdate BETWEEN DATE '2026-07-15' AND DATE '2026-09-07' AND v.purchase_amount > 0
  QUALIFY ROW_NUMBER() OVER (PARTITION BY v.user_id, v.timestamp, v.external_order_id ORDER BY v.timestamp) = 1),
p10 AS (
  SELECT DISTINCT p.album_id, p.user_id, p.ts, p.oid, p.amt
  FROM pur p JOIN gold g ON g.album_id = p.album_id AND g.user_id = p.user_id
    AND g.ts BETWEEN p.ts AND TIMESTAMP_ADD(p.ts, INTERVAL 10 MINUTE)),
gday AS (SELECT DISTINCT album_id, user_id, dt FROM gold),
tot AS (SELECT album_id, SUM(amt) AS rev, COUNT(DISTINCT user_id) AS payers FROM pur GROUP BY 1),
gb AS (SELECT album_id, COUNT(DISTINCT user_id) AS n FROM gold GROUP BY 1),
l10 AS (SELECT album_id, COUNT(DISTINCT user_id) AS n, SUM(amt) AS r FROM p10 GROUP BY 1),
rd AS (SELECT p.album_id, COUNT(DISTINCT p.user_id) AS n, SUM(p.amt) AS r FROM pur p JOIN gday d USING (album_id, user_id, dt) GROUP BY 1)
SELECT t.album_id, ROUND(t.rev) AS rev_10d, t.payers, gb.n AS golden_buyers,
  l10.n AS buyers_linked_10min, ROUND(l10.r) AS rev_min10, rd.n AS buyers_paying_that_day, ROUND(rd.r) AS rev_day
FROM tot t LEFT JOIN gb USING (album_id) LEFT JOIN l10 USING (album_id) LEFT JOIN rd USING (album_id) ORDER BY 1;

-- ===== Domino (domino-dreams-dbt) — albums 19, 20 =====
WITH alb AS (
  SELECT album_id, MAX(album_close_date) AS a_end
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (19, 20) GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, LOWER(s.sticker_type) AS t, s.sticker_collected_min_ts AS ts, s.sticker_collected_min_date AS dt,
    (   (IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Offer%'
         AND NOT REGEXP_CONTAINS(IFNULL(s.new_sticker_mtx_campaign_name, ''), r'SeasonPass|DreamPass|Info|ecn_Rewa'))
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Store%'
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%ActivePassToGetJoker%'
     OR s.new_sticker_source = 'purchase' OR s.new_sticker_source LIKE '1+%') AS paid
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (19, 20) AND s.user_collected_sticker_flag
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
gold AS (
  SELECT st.album_id, st.user_id, st.ts, st.dt
  FROM st JOIN alb a USING (album_id)
  WHERE st.t = 'golden' AND st.paid AND DATE_DIFF(st.dt, a.a_end, DAY) BETWEEN -10 AND -1),
pur AS (
  SELECT a.album_id, p.user_id, p.timestamp AS ts, DATE(p.timestamp) AS dt, p.external_order_id AS oid, p.total_usd_amount AS amt
  FROM `domino-dreams-dbt.prod_20_core.core_purchase` p JOIN alb a ON DATE_DIFF(DATE(p.timestamp), a.a_end, DAY) BETWEEN -10 AND -1
  WHERE p.date_dim BETWEEN DATE '2026-07-15' AND DATE '2026-10-12' AND p.total_usd_amount > 0
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.user_id, p.timestamp, p.external_order_id ORDER BY p.timestamp) = 1),
p10 AS (
  SELECT DISTINCT p.album_id, p.user_id, p.ts, p.oid, p.amt
  FROM pur p JOIN gold g ON g.album_id = p.album_id AND g.user_id = p.user_id
    AND g.ts BETWEEN p.ts AND TIMESTAMP_ADD(p.ts, INTERVAL 10 MINUTE)),
gday AS (SELECT DISTINCT album_id, user_id, dt FROM gold),
tot AS (SELECT album_id, SUM(amt) AS rev, COUNT(DISTINCT user_id) AS payers FROM pur GROUP BY 1),
gb AS (SELECT album_id, COUNT(DISTINCT user_id) AS n FROM gold GROUP BY 1),
l10 AS (SELECT album_id, COUNT(DISTINCT user_id) AS n, SUM(amt) AS r FROM p10 GROUP BY 1),
rd AS (SELECT p.album_id, COUNT(DISTINCT p.user_id) AS n, SUM(p.amt) AS r FROM pur p JOIN gday d USING (album_id, user_id, dt) GROUP BY 1)
SELECT t.album_id, ROUND(t.rev) AS rev_10d, t.payers, gb.n AS golden_buyers,
  l10.n AS buyers_linked_10min, ROUND(l10.r) AS rev_min10, rd.n AS buyers_paying_that_day, ROUND(rd.r) AS rev_day
FROM tot t LEFT JOIN gb USING (album_id) LEFT JOIN l10 USING (album_id) LEFT JOIN rd USING (album_id) ORDER BY 1;

-- ===== Disney (solitaire-dreams-411507) — albums 14, 15 — day measure only =====
WITH alb AS (
  SELECT album_id, MAX(album_close_date) AS a_end
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14, 15) GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, LOWER(s.sticker_type) AS t, s.sticker_collected_min_date AS dt,
    IFNULL(s.new_sticker_source, '') IN ('purchase', 'purchase_gift') AS paid
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND s.album_id IN (14, 15) AND s.user_collected_sticker_flag
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
gday AS (
  SELECT DISTINCT st.album_id, st.user_id, st.dt
  FROM st JOIN alb a USING (album_id)
  WHERE st.t = 'golden' AND st.paid AND DATE_DIFF(st.dt, a.a_end, DAY) BETWEEN -10 AND -1),
pur AS (
  SELECT a.album_id, f.user_id, f.date_dim AS dt, SUM(f.gross_revenues) AS amt
  FROM `solitaire-dreams-411507.bi_prod.fact_purchase_channels` f JOIN alb a ON DATE_DIFF(f.date_dim, a.a_end, DAY) BETWEEN -10 AND -1
  WHERE f.date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-05'
  GROUP BY 1, 2, 3 HAVING SUM(f.gross_revenues) > 0),
tot AS (SELECT album_id, SUM(amt) AS rev, COUNT(DISTINCT user_id) AS payers FROM pur GROUP BY 1),
gb AS (SELECT album_id, COUNT(DISTINCT user_id) AS n FROM gday GROUP BY 1),
rd AS (SELECT p.album_id, COUNT(DISTINCT p.user_id) AS n, SUM(p.amt) AS r FROM pur p JOIN gday d USING (album_id, user_id, dt) GROUP BY 1)
SELECT t.album_id, ROUND(t.rev) AS rev_10d, t.payers, gb.n AS golden_buyers, rd.n AS buyers_paying_that_day, ROUND(rd.r) AS rev_day
FROM tot t LEFT JOIN gb USING (album_id) LEFT JOIN rd USING (album_id) ORDER BY 1;

-- ===== Dice CORRECTED (used for results): Pricing_CP / Pricing_DDJ removed from 'bought' (not purchases, see golden-purchase-revenue-2026-10-22.md); adds per-day bought-Golden players (new/old/all) =====
WITH alb AS (
  SELECT album_id, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-15' AND album_id IN (61, 63) GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, s.sticker_type AS t, s.sticker_collected_ts AS ts, s.sticker_collected_date AS dt,
    IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AS paid_old,
    IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AND NOT REGEXP_CONTAINS(IFNULL(s.sticker_pack_key, ''), r'^Pricing_(CP|DDJ)(_|$)') AS paid
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (61, 63) AND s.is_sticker_collected
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
g0 AS (
  SELECT st.album_id, st.user_id, st.ts, st.dt, DATE_DIFF(st.dt, a.a_end, DAY) AS d, st.paid, st.paid_old
  FROM st JOIN alb a USING (album_id)
  WHERE st.t = 'golden' AND DATE_DIFF(st.dt, a.a_end, DAY) BETWEEN -10 AND -1),
gold AS (SELECT album_id, user_id, ts, dt FROM g0 WHERE paid),
pur AS (
  SELECT a.album_id, v.user_id, v.timestamp AS ts, DATE(v.timestamp) AS dt, v.external_order_id AS oid, v.purchase_amount AS amt
  FROM `dice-dreams-dbt.20_core.purchase_completed_vw` v JOIN alb a ON DATE_DIFF(DATE(v.timestamp), a.a_end, DAY) BETWEEN -10 AND -1
  WHERE v.pdate BETWEEN DATE '2026-07-15' AND DATE '2026-09-07' AND v.purchase_amount > 0
  QUALIFY ROW_NUMBER() OVER (PARTITION BY v.user_id, v.timestamp, v.external_order_id ORDER BY v.timestamp) = 1),
p10 AS (
  SELECT DISTINCT p.album_id, p.user_id, p.ts, p.oid, p.amt
  FROM pur p JOIN gold g ON g.album_id = p.album_id AND g.user_id = p.user_id
    AND g.ts BETWEEN p.ts AND TIMESTAMP_ADD(p.ts, INTERVAL 10 MINUTE)),
gday AS (SELECT DISTINCT album_id, user_id, dt FROM gold),
tot AS (SELECT album_id, SUM(amt) AS rev, COUNT(DISTINCT user_id) AS payers FROM pur GROUP BY 1),
gb AS (SELECT album_id, COUNT(DISTINCT user_id) AS n FROM gold GROUP BY 1),
l10 AS (SELECT album_id, COUNT(DISTINCT user_id) AS n, SUM(amt) AS r FROM p10 GROUP BY 1),
rd AS (SELECT p.album_id, COUNT(DISTINCT p.user_id) AS n, SUM(p.amt) AS r FROM pur p JOIN gday d USING (album_id, user_id, dt) GROUP BY 1),
daily AS (
  SELECT album_id, STRING_AGG(FORMAT('%d:%d/%d/%d', d, n_new, n_old, n_any), ' ' ORDER BY d) AS by_day
  FROM (SELECT album_id, d, COUNT(DISTINCT IF(paid, user_id, NULL)) AS n_new, COUNT(DISTINCT IF(paid_old, user_id, NULL)) AS n_old,
          COUNT(DISTINCT user_id) AS n_any FROM g0 GROUP BY 1, 2)
  GROUP BY 1)
SELECT t.album_id, ROUND(t.rev) AS rev_10d, t.payers, gb.n AS golden_buyers,
  l10.n AS buyers_linked_10min, ROUND(l10.r) AS rev_min10, rd.n AS buyers_paying_that_day, ROUND(rd.r) AS rev_day, daily.by_day
FROM tot t LEFT JOIN gb USING (album_id) LEFT JOIN l10 USING (album_id) LEFT JOIN rd USING (album_id) LEFT JOIN daily USING (album_id) ORDER BY 1
;

-- ===== Daily series for the rebuilt goldens-week slide (Dice 63 corrected rule, Domino 19, Disney 14) =====
-- Players per day with >=1 bought new Golden / >=1 gameplay (not bought) new Golden / any new Golden, d -10..-1.
-- Dice
WITH alb AS (SELECT 63 AS album_id, DATE '2026-09-07' AS a_end),
st AS (
  SELECT s.user_id, s.sticker_type AS t, s.sticker_collected_date AS dt,
    IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AND NOT REGEXP_CONTAINS(IFNULL(s.sticker_pack_key, ''), r'^Pricing_(CP|DDJ)(_|$)') AS paid
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND s.album_id = 63 AND s.is_sticker_collected
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1)
SELECT DATE_DIFF(dt, DATE '2026-09-07', DAY) AS d, COUNT(DISTINCT IF(paid, user_id, NULL)) AS bought,
  COUNT(DISTINCT IF(NOT paid, user_id, NULL)) AS gameplay, COUNT(DISTINCT user_id) AS any_golden
FROM st WHERE t = 'golden' AND DATE_DIFF(dt, DATE '2026-09-07', DAY) BETWEEN -10 AND -1 GROUP BY 1 ORDER BY 1;

-- ===== 2026-10-23 (Eden, option B): share of ACTIVE PAYERS that day who got a bought new Golden, d -10..-1 =====
-- Payer = album-table spend > 0 on any album day incl. close day. Active = active flag in the daily album table that day. All players (slide scope).
-- Dice 63
WITH ud AS (
  SELECT user_id, date_dim, IFNULL(is_active, FALSE) AS act, IFNULL(spent_in_album_today, 0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date),
pay AS (SELECT user_id FROM ud GROUP BY 1 HAVING SUM(spend) > 0),
ap AS (SELECT DATE_DIFF(u.date_dim, DATE '2026-09-07', DAY) AS d, u.user_id FROM ud u JOIN pay USING (user_id)
       WHERE u.act AND DATE_DIFF(u.date_dim, DATE '2026-09-07', DAY) BETWEEN -10 AND -1),
st AS (
  SELECT s.user_id, s.sticker_type AS t, s.sticker_collected_date AS dt,
    IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AND NOT REGEXP_CONTAINS(IFNULL(s.sticker_pack_key, ''), r'^Pricing_(CP|DDJ)(_|$)') AS paid
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND s.album_id = 63 AND s.is_sticker_collected
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
gb AS (SELECT DISTINCT DATE_DIFF(dt, DATE '2026-09-07', DAY) AS d, user_id FROM st WHERE t = 'golden' AND paid)
SELECT ap.d, COUNT(*) AS active_payers, COUNTIF(gb.user_id IS NOT NULL) AS bought_golden,
  ROUND(COUNTIF(gb.user_id IS NOT NULL) / COUNT(*), 4) AS share
FROM ap LEFT JOIN gb USING (d, user_id) GROUP BY 1 ORDER BY 1;
-- Domino 19 and Disney 14: same logic. Domino: prod_40_mart.user_daily_album (active_flag, album_spent_today), int_user_album_stickers, validated campaign rule.
-- Disney: bi_prod.user_daily_album (active_flag, album_spent_today), dim_user_album_stickers, new_sticker_source purchase / purchase_gift.
-- Close date = MAX(album_close_date) of the album; window d -10..-1; ran 2026-10-23 (Domino 12.6 GB, Disney 37.5 GB).

-- ===== 2026-10-23 (Eden): which Golden offers ran on which of the last 10 days =====
-- Bought new Golden (same rules) per day, split by offer: Dice pack key type (first two parts), Domino / Disney mtx campaign name.
-- Output per offer: buyers per day d-10..-1 ("d:players"), offers with 100+ buyers in total.
-- Dice 63
WITH st AS (
  SELECT s.user_id, s.sticker_type AS t, s.sticker_collected_date AS dt, IFNULL(s.sticker_pack_key, '') AS pk
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND s.album_id = 63 AND s.is_sticker_collected
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
g AS (
  SELECT DATE_DIFF(dt, DATE '2026-09-07', DAY) AS d, REGEXP_EXTRACT(pk, r'^[^_]*_[^_]*') AS offer, user_id FROM st
  WHERE t = 'golden' AND pk LIKE 'Pricing%' AND NOT REGEXP_CONTAINS(pk, r'^Pricing_(CP|DDJ)(_|$)')
    AND DATE_DIFF(dt, DATE '2026-09-07', DAY) BETWEEN -10 AND -1),
od AS (SELECT offer, d, COUNT(DISTINCT user_id) AS n FROM g GROUP BY 1, 2)
SELECT offer, SUM(n) AS buyer_days, STRING_AGG(FORMAT('%d:%d', d, n), ' ' ORDER BY d) AS by_day
FROM od GROUP BY 1 HAVING SUM(n) >= 100 ORDER BY 2 DESC;
