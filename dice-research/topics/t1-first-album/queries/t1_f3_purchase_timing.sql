-- Topic 1 / F3: when do eligible first-album entrants pay, relative to entry, first set, first-album close and second-album start?
-- Project dice-dreams-dbt. First albums 57-65 (post-close +28-day window only for 57-63; 65 closes 2026-10-19).
-- Cells: group (EARLY / LATE, D-009) x rapid (4+ sets in days 0-6, first album) x paid before entry (first transaction ts from
--   user_daily_metrics_agg.ftd_ts earlier than the entry day).
-- Events: entry day 00:00 UTC; first set = first set completion in album A (fact_user_album_stickers.if_closed_set);
--   close = album A end timestamp (dim_album_season.album_end_ts) = second-album start (albums run back to back).
-- First purchase after entry, bucketed: before first set / first set .. close / close .. close+7d / close+7..14d / close+14..28d /
--   none by close+28d (none by close+14d for album 65). Repeat = 2+ purchases from entry to close.
-- Purchases: purchase_completed_vw, amount > 0, deduped on user + timestamp + external_order_id.
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, album_end_ts AS a_end_ts, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 65),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
d AS (
  SELECT u.user_id, u.album_id, u.date_dim, IFNULL(u.sets_completed_today, 0) AS sets, IFNULL(u.is_excluded, FALSE) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND u.album_id BETWEEN 57 AND 65 AND u.date_dim <= a.a_end),
p AS (SELECT user_id, album_id, MIN(date_dim) AS entry, LOGICAL_OR(ex) AS ex FROM d GROUP BY 1, 2),
b AS (
  SELECT p.user_id, p.album_id, p.entry, a.a_end, a.a_end_ts,
    CASE WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 1/3 THEN 'EARLY'
         WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days > 2/3 THEN 'LATE' END AS grp
  FROM p JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p.album_id AND NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl)
    AND p.entry <= DATE_SUB(a.a_end, INTERVAL 7 DAY)),
bb AS (
  SELECT b.*, SUM(IF(d.date_dim <= DATE_ADD(b.entry, INTERVAL 6 DAY), d.sets, 0)) >= 4 AS rapid
  FROM b JOIN d ON d.user_id = b.user_id AND d.album_id = b.album_id AND d.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 6 DAY)
  WHERE b.grp IS NOT NULL GROUP BY 1, 2, 3, 4, 5, 6),
fs AS (
  SELECT f.user_id, f.album_id, MIN(f.sticker_collected_ts) AS first_set_ts
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` f JOIN bb ON bb.user_id = f.user_id AND bb.album_id = f.album_id
  WHERE f.sticker_collected_date BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND f.album_id BETWEEN 57 AND 65
    AND f.sticker_collected_date BETWEEN bb.entry AND bb.a_end AND IFNULL(f.if_closed_set, FALSE)
    AND f.is_sticker_collected AND f.sticker_type IN ('common', 'golden', 'super')
  GROUP BY 1, 2),
ftd AS (
  SELECT bb.user_id, bb.album_id, MIN(m.ftd_ts) AS ftd_ts
  FROM bb JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m ON m.user_id = bb.user_id AND m.date_dim BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 6 DAY)
  WHERE m.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-25'
  GROUP BY 1, 2),
pu AS (
  SELECT x.user_id, x.ts, x.amt FROM (
    SELECT c.user_id, c.timestamp AS ts, c.purchase_amount AS amt,
      ROW_NUMBER() OVER (PARTITION BY c.user_id, c.timestamp, c.external_order_id ORDER BY c.timestamp) AS rn
    FROM `dice-dreams-dbt.20_core.purchase_completed_vw` c
    WHERE c.pdate BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND c.purchase_amount > 0 AND c.user_id IN (SELECT user_id FROM bb)) x
  WHERE x.rn = 1),
t AS (
  SELECT bb.grp, bb.rapid, bb.album_id, bb.a_end_ts,
    IFNULL(f.ftd_ts < TIMESTAMP(bb.entry), FALSE) AS paid_before_entry, s.first_set_ts,
    MIN(IF(pu.ts >= TIMESTAMP(bb.entry), pu.ts, NULL)) AS first_buy_ts,
    COUNTIF(pu.ts >= TIMESTAMP(bb.entry) AND pu.ts < bb.a_end_ts) AS n_to_close,
    SUM(IF(pu.ts >= TIMESTAMP(bb.entry) AND pu.ts < bb.a_end_ts, pu.amt, 0)) AS amt_to_close,
    MIN(IF(pu.ts >= bb.a_end_ts, pu.ts, NULL)) AS first_post_close_ts,
    SUM(IF(pu.ts >= bb.a_end_ts AND pu.ts < TIMESTAMP_ADD(bb.a_end_ts, INTERVAL 14 DAY), pu.amt, 0)) AS amt_close_14,
    COUNTIF(pu.ts >= bb.a_end_ts AND pu.ts < TIMESTAMP_ADD(bb.a_end_ts, INTERVAL 14 DAY)) AS n_close_14
  FROM bb LEFT JOIN ftd f USING (user_id, album_id) LEFT JOIN fs s USING (user_id, album_id)
  LEFT JOIN pu ON pu.user_id = bb.user_id AND pu.ts BETWEEN TIMESTAMP(bb.entry) AND TIMESTAMP_ADD(bb.a_end_ts, INTERVAL 28 DAY)
  GROUP BY bb.user_id, bb.album_id, 1, 2, 3, 4, 5, 6),
c AS (
  SELECT t.*, t.album_id <= 63 AS ok28,
    CASE WHEN first_buy_ts IS NULL THEN 'f_none_in_window'
         WHEN first_set_ts IS NOT NULL AND first_buy_ts < first_set_ts THEN 'a_before_first_set'
         WHEN first_set_ts IS NULL AND first_buy_ts < a_end_ts THEN 'a_before_first_set'
         WHEN first_buy_ts < a_end_ts THEN 'b_first_set_to_close'
         WHEN first_buy_ts < TIMESTAMP_ADD(a_end_ts, INTERVAL 7 DAY) THEN 'c_close_to_7d'
         WHEN first_buy_ts < TIMESTAMP_ADD(a_end_ts, INTERVAL 14 DAY) THEN 'd_close_7_14d'
         ELSE 'e_close_14_28d' END AS first_buy_when
  FROM t)
SELECT grp, IF(rapid, 'rapid', 'not_rapid') AS rapid, IF(paid_before_entry, 'paid_before_entry', 'new_payer_or_none') AS prior,
  COUNT(*) AS players,
  ROUND(AVG(IF(first_buy_when = 'a_before_first_set', 1, 0)), 3) AS sh_first_buy_before_first_set,
  ROUND(AVG(IF(first_buy_when = 'b_first_set_to_close', 1, 0)), 3) AS sh_first_buy_set_to_close,
  ROUND(AVG(IF(first_buy_when IN ('a_before_first_set', 'b_first_set_to_close'), 1, 0)), 3) AS sh_bought_in_album1,
  ROUND(AVG(IF(first_buy_when = 'c_close_to_7d', 1, 0)), 3) AS sh_first_buy_close_7d,
  ROUND(AVG(IF(first_buy_when = 'd_close_7_14d', 1, 0)), 3) AS sh_first_buy_close_7_14d,
  ROUND(AVG(IF(ok28, IF(first_buy_when = 'e_close_14_28d', 1, 0), NULL)), 3) AS sh_first_buy_close_14_28d_alb57_63,
  ROUND(AVG(IF(ok28, IF(first_buy_when = 'f_none_in_window', 1, 0), NULL)), 3) AS sh_no_buy_by_close28_alb57_63,
  ROUND(AVG(IF(first_buy_ts IS NULL OR first_buy_ts >= TIMESTAMP_ADD(a_end_ts, INTERVAL 14 DAY), 1, 0)), 3) AS sh_no_buy_by_close14,
  ROUND(AVG(IF(n_to_close >= 2, 1, 0)), 3) AS sh_repeat_in_album1, ROUND(AVG(IF(n_to_close >= 1, n_to_close, NULL)), 2) AS purchases_per_buyer_album1,
  ROUND(AVG(amt_to_close), 2) AS rev_entry_to_close_per_player,
  ROUND(AVG(IF(n_to_close >= 1, IF(n_close_14 >= 1, 1, 0), NULL)), 3) AS album1_buyers_buy_again_close14,
  APPROX_QUANTILES(IF(n_to_close >= 1 AND first_post_close_ts < TIMESTAMP_ADD(a_end_ts, INTERVAL 14 DAY), TIMESTAMP_DIFF(first_post_close_ts, a_end_ts, HOUR), NULL), 4) AS q_hours_close_to_next_buy_album1_buyers,
  ROUND(AVG(IF(n_to_close = 0, IF(n_close_14 >= 1, 1, 0), NULL)), 3) AS album1_nonbuyers_buy_close14,
  APPROX_QUANTILES(IF(n_to_close = 0 AND first_post_close_ts < TIMESTAMP_ADD(a_end_ts, INTERVAL 14 DAY), TIMESTAMP_DIFF(first_post_close_ts, a_end_ts, HOUR), NULL), 4) AS q_hours_close_to_first_buy_nonbuyers,
  ROUND(AVG(amt_close_14), 2) AS rev_close_14d_per_player
FROM c GROUP BY ROLLUP (1, 2, 3) ORDER BY 1, 2, 3;
