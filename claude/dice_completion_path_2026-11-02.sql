-- Dice chapter, topic 2 (Eden 2026-11-02): the completion path.
-- Connects each payer's state before the end (stickers missing at close-8 and close-4), the spend level fixed before the end window,
-- end-window spend, bought album items, locked-sticker status and the outcome (early finisher / late finisher / not finished).
-- Albums 63 (07-27..09-07) and 65 (09-07..10-19): both 42 days, both close on Monday. Project dice-dreams-dbt.
-- Population: standard-population payers (fixed first-album rule = has a row in an earlier album; not excluded; login ratio >= 0.5 on the
--   last row before close; row on close-1; spent on any album day). Same as dice65_end_2026-10-24.sql.
-- Spend level = album $ a day in the first 75% of the album (0 / <=2 / 2-5 / 5-20 / >20), fixed before the end window.
-- Finisher = 144 unique set stickers by the end of the close day (sticker table). Early = 144 by close-4 (before the final weekend);
--   late = reached 144 on close-3..close day.
-- End window = close-3..close-1 (Fri-Sun). End spend vs own pace = end-window $ a day / first-75% $ a day.
-- Bought album item in the end window (close-3..close) = a new set sticker filled by a paid Wild (pack Pricing%) or bought directly
--   (Pricing% except Pricing_CP / Pricing_DDJ, which are not purchases; golden-purchase-revenue-2026-10-22.md). Fill date, not buy date.
-- Locked stickers (found from data, dice65-end-2026-10-24.md): 63 S143/S132/G129 · 65 S142/S120/G140.
-- Results: claude/dice-completion-path-2026-11-02.md
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-10-19' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-10-19' AND album_id IN (63,65) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 3 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS end_rev,
    COUNTIF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 3 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY) AND a.spend > 0) AS end_pay_days,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 8 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c8,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c4,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev, end_rev, end_pay_days, miss_c8, miss_c4, so_far / q_days AS pace,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier
  FROM u WHERE ok),
gate AS (
  SELECT 63 AS album_id, 143 AS sticker_id UNION ALL SELECT 63, 132 UNION ALL SELECT 63, 129
  UNION ALL SELECT 65, 142 UNION ALL SELECT 65, 120 UNION ALL SELECT 65, 140),
st AS (
  SELECT p.album_id, p.user_id, s.sticker_id, s.sticker_collected_date AS d, DATE_DIFF(s.sticker_collected_date, p.a_end, DAY) AS dd,
    (IFNULL(s.collected_from_wild, FALSE) AND IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%')
      OR (IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AND s.sticker_pack_key NOT LIKE 'Pricing_CP%' AND s.sticker_pack_key NOT LIKE 'Pricing_DDJ%') AS paid
  FROM pop p JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-07-27' AND DATE '2026-10-19' AND s.album_id IN (63,65)
    AND s.is_sticker_collected AND s.sticker_type IN ('common','golden','super') AND s.sticker_collected_date <= p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_ts, s.sticker_pack_key) = 1),
ps AS (
  SELECT st.album_id, st.user_id, COUNT(*) AS uniq_close,
    (ARRAY_AGG(st.dd ORDER BY st.d, st.sticker_id))[SAFE_OFFSET(143)] AS fin_dd,
    COUNTIF(g.sticker_id IS NOT NULL) AS gate_held,
    COUNTIF(st.paid AND st.dd >= -3) AS paid_end_n
  FROM st LEFT JOIN gate g USING (album_id, sticker_id) GROUP BY 1,2),
j AS (
  SELECT p.*, IFNULL(ps.uniq_close, 0) AS uniq_close, ps.fin_dd, IFNULL(ps.gate_held, 0) AS gate_held, IFNULL(ps.paid_end_n, 0) AS paid_end_n,
    CASE WHEN IFNULL(ps.uniq_close, 0) < 144 THEN 'c_not' WHEN ps.fin_dd <= -4 THEN 'a_early' ELSE 'b_late' END AS outcome,
    CASE WHEN p.miss_c4 = 0 THEN 'm0' WHEN p.miss_c4 <= 3 THEN 'm1_3' WHEN p.miss_c4 <= 6 THEN 'm4_6' WHEN p.miss_c4 <= 10 THEN 'm7_10' ELSE 'm11p' END AS c4_bucket
  FROM pop p LEFT JOIN ps USING (album_id, user_id))
SELECT album_id, tier, c4_bucket, outcome, COUNT(*) AS players, ROUND(SUM(alb_rev), 0) AS alb_rev, ROUND(SUM(end_rev), 0) AS end_rev,
  ROUND(SUM(pace) * 3, 0) AS end_rev_at_own_pace, COUNTIF(end_pay_days > 0) AS paid_in_end_window,
  COUNTIF(paid_end_n > 0) AS bought_album_item_end, SUM(paid_end_n) AS bought_album_items_end,
  COUNTIF(uniq_close < 144 AND gate_held < 3) AS not_fin_missing_gate, SUM(IF(uniq_close < 144, 144 - uniq_close, 0)) AS not_fin_missing_sum,
  SUM(IF(uniq_close < 144, 3 - gate_held, 0)) AS not_fin_gate_missing_sum, ROUND(AVG(miss_c8), 2) AS avg_miss_c8
FROM j GROUP BY 1,2,3,4 ORDER BY 1,2,3,4;

-- ===== Run 2 (Eden 2026-11-02: base the Dice potential on typical albums, not 65): albums 59 (05-04..06-22, 49 days) and 61 (06-22..07-27, 35 days) =====
-- Same query; only albums, date windows and locked stickers change. Locked 59 = S143/S108/G141 (1% of holders 3/5/6 days before close, found with Q2a of dice65_end_2026-10-24.sql); 61 = S143/S120/G142.
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-10-19' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-07-27' AND album_id IN (59,61) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 3 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS end_rev,
    COUNTIF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 3 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY) AND a.spend > 0) AS end_pay_days,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 8 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c8,
    144 - IFNULL(ARRAY_AGG(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)], 0) AS miss_c4,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev, end_rev, end_pay_days, miss_c8, miss_c4, so_far / q_days AS pace,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier
  FROM u WHERE ok),
gate AS (
  SELECT 59 AS album_id, 143 AS sticker_id UNION ALL SELECT 59, 108 UNION ALL SELECT 59, 141
  UNION ALL SELECT 61, 143 UNION ALL SELECT 61, 120 UNION ALL SELECT 61, 142),
st AS (
  SELECT p.album_id, p.user_id, s.sticker_id, s.sticker_collected_date AS d, DATE_DIFF(s.sticker_collected_date, p.a_end, DAY) AS dd,
    (IFNULL(s.collected_from_wild, FALSE) AND IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%')
      OR (IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AND s.sticker_pack_key NOT LIKE 'Pricing_CP%' AND s.sticker_pack_key NOT LIKE 'Pricing_DDJ%') AS paid
  FROM pop p JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-04' AND DATE '2026-07-27' AND s.album_id IN (59,61)
    AND s.is_sticker_collected AND s.sticker_type IN ('common','golden','super') AND s.sticker_collected_date <= p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_ts, s.sticker_pack_key) = 1),
ps AS (
  SELECT st.album_id, st.user_id, COUNT(*) AS uniq_close,
    (ARRAY_AGG(st.dd ORDER BY st.d, st.sticker_id))[SAFE_OFFSET(143)] AS fin_dd,
    COUNTIF(g.sticker_id IS NOT NULL) AS gate_held,
    COUNTIF(st.paid AND st.dd >= -3) AS paid_end_n
  FROM st LEFT JOIN gate g USING (album_id, sticker_id) GROUP BY 1,2),
j AS (
  SELECT p.*, IFNULL(ps.uniq_close, 0) AS uniq_close, ps.fin_dd, IFNULL(ps.gate_held, 0) AS gate_held, IFNULL(ps.paid_end_n, 0) AS paid_end_n,
    CASE WHEN IFNULL(ps.uniq_close, 0) < 144 THEN 'c_not' WHEN ps.fin_dd <= -4 THEN 'a_early' ELSE 'b_late' END AS outcome,
    CASE WHEN p.miss_c4 = 0 THEN 'm0' WHEN p.miss_c4 <= 3 THEN 'm1_3' WHEN p.miss_c4 <= 6 THEN 'm4_6' WHEN p.miss_c4 <= 10 THEN 'm7_10' ELSE 'm11p' END AS c4_bucket
  FROM pop p LEFT JOIN ps USING (album_id, user_id))
SELECT album_id, tier, c4_bucket, outcome, COUNT(*) AS players, ROUND(SUM(alb_rev), 0) AS alb_rev, ROUND(SUM(end_rev), 0) AS end_rev,
  ROUND(SUM(pace) * 3, 0) AS end_rev_at_own_pace, COUNTIF(end_pay_days > 0) AS paid_in_end_window,
  COUNTIF(paid_end_n > 0) AS bought_album_item_end, SUM(paid_end_n) AS bought_album_items_end,
  COUNTIF(uniq_close < 144 AND gate_held < 3) AS not_fin_missing_gate, SUM(IF(uniq_close < 144, 144 - uniq_close, 0)) AS not_fin_missing_sum,
  SUM(IF(uniq_close < 144, 3 - gate_held, 0)) AS not_fin_gate_missing_sum, ROUND(AVG(miss_c8), 2) AS avg_miss_c8
FROM j GROUP BY 1,2,3,4 ORDER BY 1,2,3,4;
