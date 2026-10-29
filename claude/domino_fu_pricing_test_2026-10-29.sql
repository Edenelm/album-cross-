-- 2026-10-29 Domino album 20: "FU Pricing Joker Test" (randomised, assignment campaign FUPricingJokerTest, 5-11.10.2026).
-- Arms (mtx_segment_key): Joker_Pricing_FU_Control / Joker_Pricing_FU_Test (/ Not_FU = not at FU, not compared).
-- ITT: every player assigned to an FU arm. Entry = first assignment day. Players seen in both FU arms dropped. Cheaters / special dropped.
-- Pre = 14 days before each player's own entry (album spend, user_daily_album). Window = entry .. 11.10 (last full album day; close 12.10 not in album revenue).
-- FU-priced offers = the 4 campaigns with FU_Test/FU_Control price segments: 1+9 album Joker, 1+12 (4th of July) Joker, 1PO Joker, Buy Them All+.
-- Puzzle offers = Joker Puzzle 1PO, 1PO Joker Puzzle 1.6CZ, 1PO Golden Puzzle 1.6CZ, Sunny Deal Double Resource 1.6CZ Puzzle.
-- Sources: prod_10_staging.stg_mtx_event_triggered_vw (assignment), stg_purchase_completed_vw (offer buys, $), prod_40_mart.user_daily_album (spend, stickers), prod_30_intermediate.int_user_album_stickers (last sticker).
WITH asg0 AS (
  SELECT user_id, mtx_segment_key AS arm, MIN(pdate) AS d_in
  FROM `domino-dreams-dbt.prod_10_staging.stg_mtx_event_triggered_vw`
  WHERE pdate BETWEEN DATE '2026-10-05' AND DATE '2026-10-11' AND album_id = 20
    AND LOWER(mtx_campaign_name) LIKE 'fupricingjokertest%'
    AND mtx_segment_key IN ('def_Joker_Pricing_FU_Control', 'def_Joker_Pricing_FU_Test')
  GROUP BY 1, 2
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-18' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
asg AS (
  SELECT user_id, ANY_VALUE(a0.arm) AS arm, MIN(a0.d_in) AS d_in FROM asg0 a0
  WHERE user_id NOT IN (SELECT user_id FROM bad)
  GROUP BY 1 HAVING COUNT(DISTINCT a0.arm) = 1
),
ud AS (
  SELECT user_id, album_id, date_dim, IFNULL(album_spent_today,0) AS spend,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-18' AND album_id IN (20, 21)
),
tot AS (SELECT SUM(spend) AS alb20_rev FROM ud WHERE album_id = 20 AND date_dim < DATE '2026-10-12' AND user_id NOT IN (SELECT user_id FROM bad)),
u AS (
  SELECT a.user_id, a.arm, a.d_in,
    SUM(IF(d.album_id = 20 AND d.date_dim BETWEEN DATE_SUB(a.d_in, INTERVAL 14 DAY) AND DATE_SUB(a.d_in, INTERVAL 1 DAY), d.spend, 0)) AS pre14,
    SUM(IF(d.album_id = 20 AND d.date_dim BETWEEN a.d_in AND DATE '2026-10-11', d.spend, 0)) AS win,
    SUM(IF(d.album_id = 20 AND d.date_dim < DATE '2026-10-12', d.spend, 0)) AS alb_rev,
    MAX(IF(d.album_id = 20 AND d.date_dim = DATE_SUB(a.d_in, INTERVAL 1 DAY), 144 - d.uniq, NULL)) AS miss_in,
    MAX(IF(d.album_id = 20, d.uniq, NULL)) AS uniq_end,
    SUM(IF(d.album_id = 21 AND d.date_dim BETWEEN DATE '2026-10-12' AND DATE '2026-10-18', d.spend, 0)) AS next7,
    COUNTIF(d.album_id = 21 AND d.date_dim BETWEEN DATE '2026-10-12' AND DATE '2026-10-18') AS next7_days
  FROM asg a LEFT JOIN ud d ON d.user_id = a.user_id
  GROUP BY 1, 2, 3
),
p0 AS (
  SELECT user_id, pdate, external_order_id, LOWER(REGEXP_EXTRACT(mtx_campaign_name, r'^([^|]+)')) AS camp,
    SAFE_CAST(usd_amount AS FLOAT64) AS usd
  FROM `domino-dreams-dbt.prod_10_staging.stg_purchase_completed_vw`
  WHERE pdate BETWEEN DATE '2026-10-05' AND DATE '2026-10-11'
),
p AS (
  SELECT p0.user_id, ANY_VALUE(p0.camp) AS camp, ANY_VALUE(p0.usd) AS usd
  FROM p0 JOIN asg a ON a.user_id = p0.user_id AND p0.pdate >= a.d_in
  GROUP BY p0.user_id, p0.external_order_id
),
pu AS (
  SELECT user_id,
    COUNTIF(camp IN ('1+9albumjokercardinbigresource','1+124thofjulyjokercardinbigresource','1pojoker','buythemall+')) AS fu_n,
    SUM(IF(camp IN ('1+9albumjokercardinbigresource','1+124thofjulyjokercardinbigresource','1pojoker','buythemall+'), usd, 0)) AS fu_usd,
    COUNTIF(camp IN ('jokerpuzzle1po','1pojokerpuzzle1.6cz(aboutx2puzzlesthan1+12)','1pogoldenpuzzle1.6cz','sunnydealdoublereasource1.6czpuzzle')) AS pz_n,
    SUM(IF(camp IN ('jokerpuzzle1po','1pojokerpuzzle1.6cz(aboutx2puzzlesthan1+12)','1pogoldenpuzzle1.6cz','sunnydealdoublereasource1.6czpuzzle'), usd, 0)) AS pz_usd,
    COUNT(*) AS all_n, SUM(usd) AS all_usd
  FROM p GROUP BY 1
),
st AS (
  SELECT s.user_id,
    ARRAY_AGG(STRUCT(LOWER(IFNULL(s.new_sticker_mtx_campaign_name,'')) AS c, IFNULL(s.collected_by_joker_flag,FALSE) AS j)
      ORDER BY s.sticker_collected_min_ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS last
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN asg a ON a.user_id = s.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND s.album_id = 20
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal')
  GROUP BY 1
),
st1 AS (SELECT user_id, last.c AS last_c, last.j AS last_j FROM st),
j AS (
  SELECT u.*, IFNULL(pu.fu_n,0) AS fu_n, IFNULL(pu.fu_usd,0) AS fu_usd, IFNULL(pu.pz_n,0) AS pz_n, IFNULL(pu.pz_usd,0) AS pz_usd,
    IFNULL(pu.all_n,0) AS all_n, IFNULL(pu.all_usd,0) AS all_usd,
    u.uniq_end >= 144 AS fin,
    u.uniq_end >= 144 AND st1.last_c LIKE 'summerfeverpuzzle%' AS fin_sf,
    u.uniq_end >= 144 AND st1.last_c LIKE 'jokerpuzzle%' AS fin_jp,
    u.uniq_end >= 144 AND REGEXP_CONTAINS(st1.last_c, r'1\+9album|1\+124thofjuly|1pojoker\||^1pojoker$|buythemall') AS fin_fu_offer,
    CASE WHEN u.miss_in IS NULL THEN 'x' WHEN u.miss_in <= 2 THEN '1_1-2' WHEN u.miss_in = 3 THEN '2_3' WHEN u.miss_in <= 6 THEN '3_4-6' ELSE '4_7+' END AS miss_grp
  FROM u LEFT JOIN pu USING (user_id) LEFT JOIN st1 USING (user_id)
)
SELECT IFNULL(miss_grp, 'all') AS miss_grp, REPLACE(arm, 'def_Joker_Pricing_', '') AS arm,
  COUNT(*) AS players, ROUND(SUM(alb_rev) / MAX(t.alb20_rev), 4) AS sh_alb20_rev,
  ROUND(AVG(pre14), 2) AS pre14_pp, ROUND(AVG(win), 2) AS win_pp, ROUND(AVG(IF(win > 0, 1, 0)), 4) AS payer_rate_win,
  ROUND(AVG(IF(fu_n > 0, 1, 0)), 4) AS buy_fu_offer, ROUND(AVG(fu_n), 3) AS fu_buys_pp, ROUND(AVG(fu_usd), 2) AS fu_usd_pp,
  ROUND(SAFE_DIVIDE(SUM(fu_usd), SUM(fu_n)), 2) AS fu_price_avg,
  ROUND(AVG(IF(pz_n > 0, 1, 0)), 4) AS buy_puzzle_offer, ROUND(AVG(pz_usd), 2) AS pz_usd_pp,
  ROUND(AVG(all_n), 3) AS buys_pp, ROUND(SAFE_DIVIDE(SUM(all_usd), SUM(all_n)), 2) AS price_avg,
  ROUND(AVG(IF(fin, 1, 0)), 4) AS fin_rate, ROUND(AVG(IF(fin_sf, 1, 0)), 4) AS fin_last_sf, ROUND(AVG(IF(fin_jp, 1, 0)), 4) AS fin_last_jp,
  ROUND(AVG(IF(fin_fu_offer, 1, 0)), 4) AS fin_last_fu_offer,
  ROUND(AVG(IF(all_n = 0, 1, 0)), 4) AS no_buy_rate,
  ROUND(AVG(next7), 2) AS next7_pp, ROUND(AVG(next7_days), 2) AS next7_days_pp,
  ROUND(AVG(IF(all_n = 0 AND pre14 > 0, next7_days, NULL)), 2) AS next7_days_prepayer_nobuy
FROM j CROSS JOIN tot t
GROUP BY GROUPING SETS ((arm), (miss_grp, arm))
ORDER BY miss_grp, arm
;
-- Q2: noise (SD per arm) + the player-level route: shown an FU-priced Joker offer -> bought a puzzle offer after it
--     -> a puzzle Joker (SummerFever / JokerPuzzle) filled a new sticker after that buy -> finished. Same asg / ITT as Q1.
WITH asg0 AS (
  SELECT user_id, mtx_segment_key AS arm, MIN(pdate) AS d_in
  FROM `domino-dreams-dbt.prod_10_staging.stg_mtx_event_triggered_vw`
  WHERE pdate BETWEEN DATE '2026-10-05' AND DATE '2026-10-11' AND album_id = 20
    AND LOWER(mtx_campaign_name) LIKE 'fupricingjokertest%'
    AND mtx_segment_key IN ('def_Joker_Pricing_FU_Control', 'def_Joker_Pricing_FU_Test')
  GROUP BY 1, 2
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-18' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
asg AS (
  SELECT user_id, ANY_VALUE(a0.arm) AS arm, MIN(a0.d_in) AS d_in FROM asg0 a0
  WHERE user_id NOT IN (SELECT user_id FROM bad)
  GROUP BY 1 HAVING COUNT(DISTINCT a0.arm) = 1
),
ud AS (
  SELECT user_id, album_id, date_dim, IFNULL(album_spent_today,0) AS spend,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-09-20' AND DATE '2026-10-18' AND album_id IN (20, 21)
),
u AS (
  SELECT a.user_id, a.arm, a.d_in,
    SUM(IF(d.album_id = 20 AND d.date_dim BETWEEN DATE_SUB(a.d_in, INTERVAL 14 DAY) AND DATE_SUB(a.d_in, INTERVAL 1 DAY), d.spend, 0)) AS pre14,
    SUM(IF(d.album_id = 20 AND d.date_dim BETWEEN a.d_in AND DATE '2026-10-11', d.spend, 0)) AS win,
    MAX(IF(d.album_id = 20, d.uniq, NULL)) >= 144 AS fin,
    SUM(IF(d.album_id = 21 AND d.date_dim BETWEEN DATE '2026-10-12' AND DATE '2026-10-18', d.spend, 0)) AS next7
  FROM asg a LEFT JOIN ud d ON d.user_id = a.user_id
  GROUP BY 1, 2, 3
),
ex AS (
  SELECT t.user_id, MIN(t.timestamp) AS ex_ts
  FROM `domino-dreams-dbt.prod_10_staging.stg_mtx_event_triggered_vw` t JOIN asg a ON a.user_id = t.user_id
  WHERE t.pdate BETWEEN DATE '2026-10-05' AND DATE '2026-10-11' AND t.album_id = 20
    AND LOWER(REGEXP_EXTRACT(t.mtx_campaign_name, r'^([^|]+)')) IN ('1+9albumjokercardinbigresource','1+124thofjulyjokercardinbigresource','1pojoker','buythemall+')
  GROUP BY 1
),
pz AS (
  SELECT p.user_id, MIN(p.timestamp) AS pz_ts
  FROM `domino-dreams-dbt.prod_10_staging.stg_purchase_completed_vw` p JOIN asg a ON a.user_id = p.user_id
  WHERE p.pdate BETWEEN DATE '2026-10-05' AND DATE '2026-10-11'
    AND LOWER(REGEXP_EXTRACT(p.mtx_campaign_name, r'^([^|]+)')) IN ('jokerpuzzle1po','1pojokerpuzzle1.6cz(aboutx2puzzlesthan1+12)','1pogoldenpuzzle1.6cz','sunnydealdoublereasource1.6czpuzzle')
  GROUP BY 1
),
jf AS (
  SELECT s.user_id, ARRAY_AGG(s.sticker_collected_min_ts ORDER BY s.sticker_collected_min_ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS jf_last_ts
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN asg a ON a.user_id = s.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-10-05' AND DATE '2026-10-12' AND s.album_id = 20
    AND s.user_collected_sticker_flag AND IFNULL(s.collected_by_joker_flag, FALSE)
    AND REGEXP_CONTAINS(LOWER(s.new_sticker_mtx_campaign_name), r'^(summerfeverpuzzle|jokerpuzzle)')
  GROUP BY 1
),
j AS (
  SELECT u.*, ex.ex_ts IS NOT NULL AS shown, pz.pz_ts IS NOT NULL AND pz.pz_ts > ex.ex_ts AS pz_after,
    pz.pz_ts IS NOT NULL AND pz.pz_ts > ex.ex_ts AND jf.jf_last_ts > pz.pz_ts AS fill_after,
    pz.pz_ts IS NOT NULL AND pz.pz_ts > ex.ex_ts AND jf.jf_last_ts > pz.pz_ts AND u.fin AS chain_fin
  FROM u LEFT JOIN ex USING (user_id) LEFT JOIN pz USING (user_id) LEFT JOIN jf USING (user_id)
)
SELECT REPLACE(arm, 'def_Joker_Pricing_', '') AS arm, COUNT(*) AS players,
  ROUND(AVG(pre14), 3) AS pre14_pp, ROUND(STDDEV(pre14), 2) AS pre14_sd,
  ROUND(AVG(win), 3) AS win_pp, ROUND(STDDEV(win), 2) AS win_sd,
  ROUND(AVG(next7), 3) AS next7_pp, ROUND(STDDEV(next7), 2) AS next7_sd,
  ROUND(AVG(IF(shown, 1, 0)), 4) AS shown_fu_offer,
  COUNTIF(pz_after) AS n_puzzle_buy_after_shown, COUNTIF(fill_after) AS n_then_puzzle_joker_fill, COUNTIF(chain_fin) AS n_then_finished
FROM j GROUP BY 1 ORDER BY 1
;
-- Q3: album 21 days 1-14 (12-25.10) by arm, same asg / ITT as Q1 (bad window extended to 25.10).
--     Per player: pre14 (14 days before own entry), week 1, week 2, days 1-14, payer rate, active days, $500 cap check;
--     Q3b: per-player (d14 - pre14) mean and SD for the DiD noise range.
--     (same asg CTEs as Q2; outputs: d14 26.075 vs 24.756, DiD -0.914 $ [-1.717, -0.111])
WITH asg0 AS (
  SELECT user_id, mtx_segment_key AS arm, MIN(pdate) AS d_in
  FROM `domino-dreams-dbt.prod_10_staging.stg_mtx_event_triggered_vw`
  WHERE pdate BETWEEN DATE '2026-10-05' AND DATE '2026-10-11' AND album_id = 20
    AND LOWER(mtx_campaign_name) LIKE 'fupricingjokertest%'
    AND mtx_segment_key IN ('def_Joker_Pricing_FU_Control', 'def_Joker_Pricing_FU_Test')
  GROUP BY 1, 2
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-25' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
asg AS (
  SELECT user_id, ANY_VALUE(a0.arm) AS arm, MIN(a0.d_in) AS d_in FROM asg0 a0
  WHERE user_id NOT IN (SELECT user_id FROM bad)
  GROUP BY 1 HAVING COUNT(DISTINCT a0.arm) = 1
),
ud AS (
  SELECT user_id, album_id, date_dim, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-09-20' AND DATE '2026-10-25' AND album_id IN (20, 21)
),
u AS (
  SELECT a.user_id, a.arm,
    SUM(IF(d.album_id = 20 AND d.date_dim BETWEEN DATE_SUB(a.d_in, INTERVAL 14 DAY) AND DATE_SUB(a.d_in, INTERVAL 1 DAY), d.spend, 0)) AS pre14,
    SUM(IF(d.album_id = 21 AND d.date_dim BETWEEN DATE '2026-10-12' AND DATE '2026-10-18', d.spend, 0)) AS w1,
    SUM(IF(d.album_id = 21 AND d.date_dim BETWEEN DATE '2026-10-19' AND DATE '2026-10-25', d.spend, 0)) AS w2,
    SUM(IF(d.album_id = 21 AND d.date_dim BETWEEN DATE '2026-10-12' AND DATE '2026-10-25', d.spend, 0)) AS d14,
    COUNTIF(d.album_id = 21 AND d.date_dim BETWEEN DATE '2026-10-12' AND DATE '2026-10-25') AS days14,
    COUNTIF(d.album_id = 21 AND d.date_dim BETWEEN DATE '2026-10-12' AND DATE '2026-10-25' AND d.spend > 0) AS paydays14
  FROM asg a LEFT JOIN ud d ON d.user_id = a.user_id
  GROUP BY 1, 2
)
SELECT REPLACE(arm, 'def_Joker_Pricing_', '') AS arm, COUNT(*) AS players,
  ROUND(AVG(pre14), 3) AS pre14_pp, ROUND(STDDEV(pre14), 2) AS pre14_sd,
  ROUND(AVG(w1), 3) AS w1_pp, ROUND(STDDEV(w1), 2) AS w1_sd, ROUND(AVG(w2), 3) AS w2_pp, ROUND(STDDEV(w2), 2) AS w2_sd,
  ROUND(AVG(d14), 3) AS d14_pp, ROUND(STDDEV(d14), 2) AS d14_sd,
  ROUND(AVG(IF(d14 > 0, 1, 0)), 4) AS payer_rate_14, ROUND(AVG(days14), 2) AS active_days_14,
  ROUND(AVG(IF(days14 = 0, 1, 0)), 4) AS not_active_14, ROUND(AVG(paydays14), 3) AS paydays_pp,
  ROUND(AVG(LEAST(d14, 500)), 3) AS d14_capped500_pp,
  ROUND(AVG(d14 - pre14), 3) AS diff_pp, ROUND(STDDEV(d14 - pre14), 2) AS diff_sd
FROM u GROUP BY 1 ORDER BY 1
