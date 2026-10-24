-- Eden 2026-10-24: what happened at the end of Dice 65 (end lift +3%, first flat Dice end).
-- Q1: were payers too far, so they did not reach <=3 missing before the album's last weekend?
--   Dice albums close on Monday; close-4 = end of Thursday = the last day before the final weekend (same cut as topic 5).
--   Population, tiers and reach exactly as topic5_tiers_2026-10-23.sql (Dice part), albums 61 / 63 / 65.
--   Tier = album spend per day in the first 75% of the album (cuts 0 / <=2 / 2-5 / 5-20 / >20 $ a day). Reach = <=3 missing at close-4.
--   Missing at close-4 buckets: 0 / 1-3 / 4-6 / 7-10 / 11+. Finished / near / far use the last row before close (close-1); the daily table
--   does not update stickers on the close day, so close-day finishers count as 1-3 here (fine for the reach question).
-- Q2: the locked end stickers (1 Golden + 2 Supers) — how did finishers get them, free or paid? (second query below)
-- Results: claude/dice65-end-2026-10-24.md

-- ===== Q1 (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-10-19' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-10-19' AND album_id IN (61,63,65) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    SUM(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.spend, 0)) AS rev_c4,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c4,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
t AS (
  SELECT album_id, user_id, alb_rev, rev_c4, miss_c4, uniq_end,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier
  FROM u WHERE ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1)
SELECT t.album_id, IFNULL(tier, 'all') AS tier, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 3) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 3) AS share_rev,
  ROUND(AVG(IF(miss_c4 <= 3, 1, 0)), 3) AS reach_players, ROUND(SAFE_DIVIDE(SUM(IF(miss_c4 <= 3, rev_c4, 0)), SUM(rev_c4)), 3) AS reach_rev_share,
  ROUND(AVG(IF(miss_c4 = 0, 1, 0)), 3) AS c4_done, ROUND(AVG(IF(miss_c4 BETWEEN 1 AND 3, 1, 0)), 3) AS c4_1_3,
  ROUND(AVG(IF(miss_c4 BETWEEN 4 AND 6, 1, 0)), 3) AS c4_4_6, ROUND(AVG(IF(miss_c4 BETWEEN 7 AND 10, 1, 0)), 3) AS c4_7_10,
  ROUND(AVG(IF(miss_c4 >= 11, 1, 0)), 3) AS c4_11plus, APPROX_QUANTILES(miss_c4, 2)[OFFSET(1)] AS med_miss_c4,
  ROUND(AVG(IF(uniq_end >= 144, 1, 0)), 3) AS done_close1, ROUND(AVG(IF(uniq_end BETWEEN 141 AND 143, 1, 0)), 3) AS near_close1
FROM t JOIN tot USING (album_id) GROUP BY GROUPING SETS ((t.album_id, tier), (t.album_id)) ORDER BY 1, 2;

-- ===== Q2a: find the locked end stickers from data (dice-dreams-dbt) =====
-- Locked = the 2 Supers and 1 Golden that reach 1% of the album's sticker holders latest (check: 61 should give S143 / S120 / G142, 63 S132 / S143 / G129).
WITH alb AS (
  SELECT album_id, MAX(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-10-19' AND album_id IN (61,63,65) GROUP BY 1),
k AS (
  SELECT s.album_id, s.sticker_id, ANY_VALUE(s.sticker_type) AS typ, s.user_id, MIN(s.sticker_collected_date) AS d1
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-10-19' AND s.album_id IN (61,63,65)
    AND s.sticker_type IN ('golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= a.a_end
  GROUP BY 1,2,4),
holders AS (SELECT album_id, COUNT(DISTINCT user_id) AS n FROM k GROUP BY 1),
daily AS (SELECT album_id, sticker_id, ANY_VALUE(typ) AS typ, d1, COUNT(*) AS c FROM k GROUP BY 1,2,4),
cum AS (SELECT album_id, sticker_id, typ, d1, SUM(c) OVER (PARTITION BY album_id, sticker_id ORDER BY d1) AS cc FROM daily),
reach AS (
  SELECT c.album_id, c.sticker_id, ANY_VALUE(c.typ) AS typ, MIN(IF(c.cc >= 0.01 * h.n, c.d1, NULL)) AS d_1pct
  FROM cum c JOIN holders h USING (album_id) GROUP BY 1,2)
SELECT r.album_id, r.typ, r.sticker_id, DATE_DIFF(r.d_1pct, a.a_end, DAY) AS d_1pct_vs_close,
  ROW_NUMBER() OVER (PARTITION BY r.album_id, r.typ ORDER BY r.d_1pct DESC, r.sticker_id) AS rk
FROM reach r JOIN alb a USING (album_id)
QUALIFY rk <= 4
ORDER BY 1, 2, rk;

-- ===== Q2b: how paying finishers got the 3 locked stickers (dice-dreams-dbt) =====
-- Locked (from Q2a, checks match the old slide): 61 S143/S120/G142 · 63 S143/S132/G129 · 65 S142/S120/G140.
-- Population: Q1 standard-population payers; finisher = 144 unique set stickers by the end of the close day (sticker table).
-- Source of the first copy of each locked sticker: Wild-filled -> paid Wild if pack key Pricing% else free Wild (source | pack);
--   direct -> paid if pack key Pricing% except Pricing_CP / Pricing_DDJ (not purchases, golden-purchase-revenue-2026-10-22.md); else source | pack.
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-10-19' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-10-19' AND album_id IN (61,63,65) AND date_dim <= album_end_date),
pop AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_end) AS a_end
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2
  HAVING MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0),
gate AS (
  SELECT 61 AS album_id, 143 AS sticker_id UNION ALL SELECT 61, 120 UNION ALL SELECT 61, 142
  UNION ALL SELECT 63, 143 UNION ALL SELECT 63, 132 UNION ALL SELECT 63, 129
  UNION ALL SELECT 65, 142 UNION ALL SELECT 65, 120 UNION ALL SELECT 65, 140),
st AS (
  SELECT p.album_id, p.user_id, p.a_end, s.sticker_id, s.sticker_collected_date AS d, IFNULL(s.collected_from_wild, FALSE) AS wild,
    IFNULL(s.sticker_pack_key, '') AS pk, IFNULL(NULLIF(s.sticker_source, ''), '(none)') AS src
  FROM pop p JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-01' AND DATE '2026-10-19' AND s.album_id IN (61,63,65)
    AND s.is_sticker_collected AND s.sticker_type IN ('common','golden','super') AND s.sticker_collected_date <= p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
fin AS (SELECT album_id, user_id FROM st GROUP BY 1,2 HAVING COUNT(*) >= 144),
g AS (
  SELECT st.album_id, st.user_id, DATE_DIFF(st.d, st.a_end, DAY) AS dd,
    CASE WHEN st.wild AND st.pk LIKE 'Pricing%' THEN 'Wild, paid'
         WHEN st.wild THEN CONCAT('Wild, free: ', st.src, ' | ', REGEXP_REPLACE(st.pk, r'[0-9]+', '#'))
         WHEN st.pk LIKE 'Pricing%' AND st.pk NOT LIKE 'Pricing_CP%' AND st.pk NOT LIKE 'Pricing_DDJ%' THEN 'Direct, paid'
         ELSE CONCAT('Direct, free: ', st.src, ' | ', REGEXP_REPLACE(st.pk, r'[0-9]+', '#')) END AS how
  FROM st JOIN fin USING (album_id, user_id) JOIN gate USING (album_id, sticker_id)),
u AS (SELECT album_id, user_id, LOGICAL_OR(STARTS_WITH(how, 'Wild, paid') OR STARTS_WITH(how, 'Direct, paid')) AS any_paid FROM g GROUP BY 1,2)
SELECT 'source' AS kind, album_id, how, COUNT(*) AS n, ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 3) AS share,
  APPROX_QUANTILES(dd, 2)[OFFSET(1)] AS med_day_vs_close
FROM g GROUP BY 2, 3 HAVING n >= 100
UNION ALL
SELECT 'finishers', album_id, 'paid for >=1 locked sticker', COUNTIF(any_paid), ROUND(AVG(IF(any_paid, 1, 0)), 3), COUNT(*)
FROM u GROUP BY 2
ORDER BY kind, album_id, n DESC;
