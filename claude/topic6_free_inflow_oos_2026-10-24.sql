-- Topic 6 (Eden approved 2026-10-24): stock is ~0 at close in all games (topic6_stock_by_status), so why does Dice come back slowest?
-- (a) Free inflow in days 1-3 after close: free coins/rolls per day (days 1-3) / own play per day close-18..-5 = days of play the game gives free each day.
--     Also free / play in the same days (share of play the game funded), days 1-3 vs mid-album (close-18..-5).
-- (b) Out of stock: share of active days with an out-of-stock day, days 1-3 vs mid-album; % of players out of stock at least once in days 1-3;
--     % who bought in days 1-3 (next album spend > 0, album table).
-- Out of stock: Dice not_enough_rolls_count > 0 (Eden's choice 2026-10-19); Domino prod_40_mart.user_daily_metrics.ooc_today_flag;
--   Disney bi_prod.solitaire_user_daily_metrics_agg_df.out_of_coins_counter > 0. Definitions differ by game -> compare days 1-3 with the same player's mid-album.
-- Free in (my choice, listed):
--   Dice   = rolls_in_sum - rolls_amount_from_purchase (30_intermediate.user_daily_rolls_in_out; rolls_in includes bought rolls, checked 2026-09-08). 1.2M cohort left out.
--   Domino = prod_10_staging.stg_coins_in_vw, units 0..1000, all sources except paid ones: purchase, 1plus1, 1_plus_6, dream pass premium, progress_offer,
--            scrolling, vault, store bundle gift, google play points, and except compensation, debug and '' (unknown source).
--   Disney = mp_raw_prod_vw.mp_coins_in_vw, units 0..1000, balance 0..5000, all sources except purchase, purchase_gift, scrolling, journey-panel,
--            raining_gift_premium, play points, free, compensation, level start and '' (unknown source).
-- Play: as topic6_stock_by_status (Dice rolls_out_sum; Domino int_rv_user_daily_coins_spent; Disney level start + boosters from mp_coins_out_vw).
-- Population, status and levels as topic6_payout_by_status. Active day = play > 0.
-- Results: claude/topic6-free-inflow-oos-2026-10-24.md

-- ===== DICE 63 (dice-dreams-dbt), close 2026-09-07 =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date),
u AS (
  SELECT a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < 63 AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1),
t AS (
  SELECT user_id, alb_rev,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 142 THEN 'b_1_2' WHEN uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status
  FROM u WHERE ok),
nb AS (
  SELECT user_id, COUNTIF(IFNULL(spent_in_album_today,0) > 0) AS buy_days
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-09-08' AND DATE '2026-09-10' AND album_id = 65 GROUP BY 1),
dd AS (
  SELECT user_id, date_dim AS d, IFNULL(rolls_out_sum,0) AS play, IFNULL(rolls_in_sum,0) - IFNULL(rolls_amount_from_purchase,0) AS free_in,
    IFNULL(not_enough_rolls_count,0) > 0 AS oos, IFNULL(rolls_max,0) > 1200000 AS big
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
  WHERE date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-09-10'),
w AS (
  SELECT user_id, IF(d <= DATE '2026-09-02', 'mid', 'post') AS win, play, free_in, oos, big
  FROM dd WHERE d <= DATE '2026-09-02' OR d >= DATE '2026-09-08'),
p AS (
  SELECT user_id, LOGICAL_OR(big) AS big,
    SUM(IF(win = 'mid', play, 0)) AS m_play, SUM(IF(win = 'mid', free_in, 0)) AS m_free,
    COUNTIF(win = 'mid' AND play > 0) AS m_act, COUNTIF(win = 'mid' AND play > 0 AND oos) AS m_oos,
    SUM(IF(win = 'post', play, 0)) AS p_play, SUM(IF(win = 'post', free_in, 0)) AS p_free,
    COUNTIF(win = 'post' AND play > 0) AS p_act, COUNTIF(win = 'post' AND play > 0 AND oos) AS p_oos
  FROM w GROUP BY 1),
g AS (
  SELECT t.status, t.tier, p.*, IFNULL(nb.buy_days, 0) AS buy_days
  FROM t JOIN p USING (user_id) LEFT JOIN nb USING (user_id)
  WHERE NOT p.big AND p.m_play > 0),
agg AS (
  SELECT status, 'all' AS lvl, g.* EXCEPT (status, tier) FROM g WHERE tier != 't0_0'
  UNION ALL SELECT status, 'l2_20', g.* EXCEPT (status, tier) FROM g WHERE tier IN ('t2_2_5','t3_5_20'))
SELECT status, lvl, COUNT(*) AS players, COUNTIF(p_act > 0) AS played_d1_3,
  ROUND(APPROX_QUANTILES(IF(p_act > 0, (p_free / 3) / (m_play / 14), NULL), 4)[OFFSET(2)], 2) AS med_free_days_post,
  ROUND(APPROX_QUANTILES((m_free / 14) / (m_play / 14), 4)[OFFSET(2)], 2) AS med_free_days_mid,
  ROUND(SAFE_DIVIDE(SUM(IF(p_act > 0, p_free, 0)), SUM(IF(p_act > 0, p_play, 0))), 3) AS free_share_post,
  ROUND(SAFE_DIVIDE(SUM(m_free), SUM(m_play)), 3) AS free_share_mid,
  ROUND(SAFE_DIVIDE(SUM(m_oos), SUM(m_act)), 3) AS oos_day_rate_mid,
  ROUND(SAFE_DIVIDE(SUM(p_oos), SUM(p_act)), 3) AS oos_day_rate_post,
  ROUND(SAFE_DIVIDE(COUNTIF(p_oos > 0), COUNTIF(p_act > 0)), 3) AS pct_oos_d1_3,
  ROUND(SAFE_DIVIDE(COUNTIF(buy_days > 0), COUNT(*)), 3) AS pct_bought_d1_3
FROM agg GROUP BY 1, 2 ORDER BY 2, 1;

-- ===== DOMINO 20 (domino-dreams-dbt), close 2026-10-12 =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1),
t AS (
  SELECT user_id, alb_rev,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 142 THEN 'b_1_2' WHEN uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status
  FROM u WHERE ok),
nb AS (
  SELECT user_id, COUNTIF(IFNULL(album_spent_today,0) > 0) AS buy_days
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-10-13' AND DATE '2026-10-15' AND album_id = 21 GROUP BY 1),
sp AS (
  SELECT user_id, date_dim AS d, IFNULL(spent_in_allowance,0) AS play
  FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_spent`
  WHERE date_dim BETWEEN DATE '2026-09-24' AND DATE '2026-10-15'),
fi AS (
  SELECT user_id, pdate AS d, SUM(SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64))) AS free_in
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-15'
    AND SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)) BETWEEN 0 AND 1000
    AND IFNULL(source,'') NOT IN ('purchase','1plus1','1_plus_6','dream pass premium','progress_offer','scrolling','vault','store bundle gift',
                                  'google play points','compensation','debug','')
  GROUP BY 1, 2),
oo AS (
  SELECT user_id, date_dim AS d, IFNULL(ooc_today_flag, FALSE) AS oos
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-09-24' AND DATE '2026-10-15'),
dd AS (
  SELECT sp.user_id, sp.d, sp.play, IFNULL(fi.free_in, 0) AS free_in, IFNULL(oo.oos, FALSE) AS oos
  FROM sp LEFT JOIN fi USING (user_id, d) LEFT JOIN oo USING (user_id, d)),
w AS (
  SELECT user_id, IF(d <= DATE '2026-10-07', 'mid', 'post') AS win, play, free_in, oos
  FROM dd WHERE d <= DATE '2026-10-07' OR d >= DATE '2026-10-13'),
p AS (
  SELECT user_id,
    SUM(IF(win = 'mid', play, 0)) AS m_play, SUM(IF(win = 'mid', free_in, 0)) AS m_free,
    COUNTIF(win = 'mid' AND play > 0) AS m_act, COUNTIF(win = 'mid' AND play > 0 AND oos) AS m_oos,
    SUM(IF(win = 'post', play, 0)) AS p_play, SUM(IF(win = 'post', free_in, 0)) AS p_free,
    COUNTIF(win = 'post' AND play > 0) AS p_act, COUNTIF(win = 'post' AND play > 0 AND oos) AS p_oos
  FROM w GROUP BY 1),
g AS (
  SELECT t.status, t.tier, p.*, IFNULL(nb.buy_days, 0) AS buy_days
  FROM t JOIN p USING (user_id) LEFT JOIN nb USING (user_id)
  WHERE p.m_play > 0),
agg AS (
  SELECT status, 'all' AS lvl, g.* EXCEPT (status, tier) FROM g WHERE tier != 't0_0'
  UNION ALL SELECT status, 'l2_20', g.* EXCEPT (status, tier) FROM g WHERE tier IN ('t2_2_5','t3_5_20'))
SELECT status, lvl, COUNT(*) AS players, COUNTIF(p_act > 0) AS played_d1_3,
  ROUND(APPROX_QUANTILES(IF(p_act > 0, (p_free / 3) / (m_play / 14), NULL), 4)[OFFSET(2)], 2) AS med_free_days_post,
  ROUND(APPROX_QUANTILES((m_free / 14) / (m_play / 14), 4)[OFFSET(2)], 2) AS med_free_days_mid,
  ROUND(SAFE_DIVIDE(SUM(IF(p_act > 0, p_free, 0)), SUM(IF(p_act > 0, p_play, 0))), 3) AS free_share_post,
  ROUND(SAFE_DIVIDE(SUM(m_free), SUM(m_play)), 3) AS free_share_mid,
  ROUND(SAFE_DIVIDE(SUM(m_oos), SUM(m_act)), 3) AS oos_day_rate_mid,
  ROUND(SAFE_DIVIDE(SUM(p_oos), SUM(p_act)), 3) AS oos_day_rate_post,
  ROUND(SAFE_DIVIDE(COUNTIF(p_oos > 0), COUNTIF(p_act > 0)), 3) AS pct_oos_d1_3,
  ROUND(SAFE_DIVIDE(COUNTIF(buy_days > 0), COUNT(*)), 3) AS pct_bought_d1_3
FROM agg GROUP BY 1, 2 ORDER BY 2, 1;

-- ===== DISNEY 15 (solitaire-dreams-411507), close 2026-10-05 =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id = 15 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1),
t AS (
  SELECT user_id, alb_rev,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 142 THEN 'b_1_2' WHEN uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status
  FROM u WHERE ok),
nb AS (
  SELECT user_id, COUNTIF(IFNULL(album_spent_today,0) > 0) AS buy_days
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-10-06' AND DATE '2026-10-08' AND album_id = 16 GROUP BY 1),
co AS (
  SELECT user_id, pdate AS d, SUM(SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64))) AS play
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-08'
    AND source IN ('level start','extra tiles','undo','wild','trade')
    AND SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) BETWEEN 0 AND 1000 AND coins_balance_in_allowance BETWEEN 0 AND 5000
  GROUP BY 1, 2),
fi AS (
  SELECT user_id, pdate AS d, SUM(SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64))) AS free_in
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-08'
    AND SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) BETWEEN 0 AND 1000 AND coins_balance_in_allowance BETWEEN 0 AND 5000
    AND IFNULL(source,'') NOT IN ('purchase','purchase_gift','scrolling','journey-panel','raining_gift_premium','play points','free',
                                  'compensation','level start','')
  GROUP BY 1, 2),
oo AS (
  SELECT user_id, date_dim AS d, IFNULL(out_of_coins_counter, 0) > 0 AS oos
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-09-17' AND DATE '2026-10-08'),
dd AS (
  SELECT co.user_id, co.d, co.play, IFNULL(fi.free_in, 0) AS free_in, IFNULL(oo.oos, FALSE) AS oos
  FROM co LEFT JOIN fi USING (user_id, d) LEFT JOIN oo USING (user_id, d)),
w AS (
  SELECT user_id, IF(d <= DATE '2026-09-30', 'mid', 'post') AS win, play, free_in, oos
  FROM dd WHERE d <= DATE '2026-09-30' OR d >= DATE '2026-10-06'),
p AS (
  SELECT user_id,
    SUM(IF(win = 'mid', play, 0)) AS m_play, SUM(IF(win = 'mid', free_in, 0)) AS m_free,
    COUNTIF(win = 'mid' AND play > 0) AS m_act, COUNTIF(win = 'mid' AND play > 0 AND oos) AS m_oos,
    SUM(IF(win = 'post', play, 0)) AS p_play, SUM(IF(win = 'post', free_in, 0)) AS p_free,
    COUNTIF(win = 'post' AND play > 0) AS p_act, COUNTIF(win = 'post' AND play > 0 AND oos) AS p_oos
  FROM w GROUP BY 1),
g AS (
  SELECT t.status, t.tier, p.*, IFNULL(nb.buy_days, 0) AS buy_days
  FROM t JOIN p USING (user_id) LEFT JOIN nb USING (user_id)
  WHERE p.m_play > 0),
agg AS (
  SELECT status, 'all' AS lvl, g.* EXCEPT (status, tier) FROM g WHERE tier != 't0_0'
  UNION ALL SELECT status, 'l2_20', g.* EXCEPT (status, tier) FROM g WHERE tier IN ('t2_2_5','t3_5_20'))
SELECT status, lvl, COUNT(*) AS players, COUNTIF(p_act > 0) AS played_d1_3,
  ROUND(APPROX_QUANTILES(IF(p_act > 0, (p_free / 3) / (m_play / 14), NULL), 4)[OFFSET(2)], 2) AS med_free_days_post,
  ROUND(APPROX_QUANTILES((m_free / 14) / (m_play / 14), 4)[OFFSET(2)], 2) AS med_free_days_mid,
  ROUND(SAFE_DIVIDE(SUM(IF(p_act > 0, p_free, 0)), SUM(IF(p_act > 0, p_play, 0))), 3) AS free_share_post,
  ROUND(SAFE_DIVIDE(SUM(m_free), SUM(m_play)), 3) AS free_share_mid,
  ROUND(SAFE_DIVIDE(SUM(m_oos), SUM(m_act)), 3) AS oos_day_rate_mid,
  ROUND(SAFE_DIVIDE(SUM(p_oos), SUM(p_act)), 3) AS oos_day_rate_post,
  ROUND(SAFE_DIVIDE(COUNTIF(p_oos > 0), COUNTIF(p_act > 0)), 3) AS pct_oos_d1_3,
  ROUND(SAFE_DIVIDE(COUNTIF(buy_days > 0), COUNT(*)), 3) AS pct_bought_d1_3
FROM agg GROUP BY 1, 2 ORDER BY 2, 1;
