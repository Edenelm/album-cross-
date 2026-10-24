-- 2026-10-24 (Eden): Domino 20 payers who got a Joker from the Movie Twister event (AlbumMomentsTvTwister, 8-9 Oct = 4-3 days before close 12 Oct):
-- did they buy in the two event days, and how much above their own habit / comfort zone?
-- Population: standard-population payers of album 20 (as claude/closing_week_pct_payers_2026-10-24.sql). Comparison: same payers without a Movie Twister Joker.
-- Purchases: prod_10_staging.stg_purchase_completed_vw (staging, approved by Eden 2026-10-18 for CZ), usd_amount, deduped (user + time + order id).
-- CZ = smart_segments.cz_c at the purchase (as claude/domino_strong_closers_price_vs_cz.sql). Habit week = 1-7 Oct (the 7 days before the event).
WITH ud AS (
  SELECT user_id, date_dim, album_close_date AS a_end, IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac,
    IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
pay AS (
  SELECT a.user_id, SUM(IF(a.date_dim < DATE '2026-10-12', a.spend, 0)) AS alb_rev FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1
  HAVING MAX(IF(a.date_dim < DATE '2026-10-12', a.date_dim, NULL)) = DATE '2026-10-11'
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
    AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL),
mt AS (
  SELECT s.user_id, MIN(s.sticker_collected_min_ts) AS j_ts
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pay p USING (user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-10-07' AND DATE '2026-10-11' AND s.album_id = 20
    AND s.user_collected_sticker_flag AND IFNULL(s.collected_by_joker_flag, FALSE) AND s.new_sticker_source = 'MovieTwister'
  GROUP BY 1),
pur AS (
  SELECT p.user_id, p.timestamp AS ts, SAFE_CAST(p.usd_amount AS FLOAT64) AS price,
    SAFE_CAST(JSON_VALUE(p.smart_segments, '$.cz_c') AS FLOAT64) AS cz
  FROM `domino-dreams-dbt.prod_10_staging.stg_purchase_completed_vw` p JOIN pay USING (user_id)
  WHERE p.pdate BETWEEN DATE '2026-09-30' AND DATE '2026-10-10' AND DATE(p.timestamp) BETWEEN DATE '2026-10-01' AND DATE '2026-10-09'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.user_id, p.timestamp, p.external_order_id ORDER BY p.mp_processing_time_ms) = 1),
u AS (
  SELECT y.user_id, ANY_VALUE(y.alb_rev) AS alb_rev, ANY_VALUE(m.j_ts) IS NOT NULL AS got_mt,
    SUM(IF(DATE(r.ts) <= DATE '2026-10-07' AND r.price > 0, r.price, 0)) AS rev_wk,
    COUNTIF(DATE(r.ts) <= DATE '2026-10-07' AND r.price > 0) AS n_wk,
    SUM(IF(DATE(r.ts) >= DATE '2026-10-08' AND r.price > 0, r.price, 0)) AS rev_ev,
    COUNTIF(DATE(r.ts) >= DATE '2026-10-08' AND r.price > 0) AS n_ev,
    MAX(IF(DATE(r.ts) >= DATE '2026-10-08' AND r.price > 0, r.price, NULL)) AS max_ev,
    MAX(IF(DATE(r.ts) >= DATE '2026-10-08' AND r.price > 0 AND r.cz > 0, r.price / r.cz, NULL)) AS max_ev_vs_cz,
    LOGICAL_OR(DATE(r.ts) >= DATE '2026-10-08' AND r.price > 0 AND r.ts <= m.j_ts) AS bought_before_joker
  FROM pay y LEFT JOIN mt m USING (user_id) LEFT JOIN pur r USING (user_id) GROUP BY 1),
tot AS (SELECT COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM u)
SELECT got_mt, COUNT(*) AS payers, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_album_rev,
  ROUND(AVG(IF(n_ev > 0, 1, 0)), 3) AS bought_in_2_days,
  ROUND(AVG(IF(bought_before_joker, 1, 0)), 3) AS bought_before_joker,
  ROUND(SAFE_DIVIDE(SUM(rev_ev) / 2, SUM(rev_wk) / 7), 2) AS spend_per_day_vs_habit_week,
  -- among buyers in the 2 days who also bought in the habit week
  COUNTIF(n_ev > 0 AND n_wk > 0) AS buyers_both,
  ROUND(SAFE_DIVIDE(COUNTIF(n_ev > 0 AND n_wk > 0 AND max_ev > rev_wk / n_wk), COUNTIF(n_ev > 0 AND n_wk > 0)), 3) AS max_price_above_own_avg,
  ROUND(APPROX_QUANTILES(IF(n_ev > 0 AND n_wk > 0, max_ev / (rev_wk / n_wk), NULL), 2)[OFFSET(1)], 2) AS med_max_price_vs_own_avg,
  -- CZ, among buyers in the 2 days with a known CZ
  COUNTIF(max_ev_vs_cz IS NOT NULL) AS buyers_with_cz,
  ROUND(SAFE_DIVIDE(COUNTIF(max_ev_vs_cz > 1), COUNTIF(max_ev_vs_cz IS NOT NULL)), 3) AS bought_above_cz,
  ROUND(APPROX_QUANTILES(max_ev_vs_cz, 2)[OFFSET(1)], 2) AS med_max_price_vs_cz,
  ROUND(SUM(rev_ev)) AS rev_2_days
FROM u, tot GROUP BY 1 ORDER BY 1 DESC

-- Who got the Domino 20 end Jokers, by end status, middle payers (P50-95 of spend so far at 75% of the album, as far-rare-gate-gap-2026-10-23) (Eden 2026-10-24: does the 11-12 day rare drought slide fit?)
-- Ran with the same pay CTE plus so_far (spend up to 2026-09-29) and uniq_end; Joker stickers 5-11 Oct by source (MovieTwister or any) and sticker type. 5.1 GB.
