-- Topic 6 point 2b (Eden asked 2026-10-24): payers 1-2 short — do the ones whose payout fell more after close spend less in the week after?
-- Population and spend measures = claude/topic6_short_payers_2026-10-24.sql, latest album only (Dice 63, Domino 20, Disney 15).
-- Payout per player = Part 1 slide 36 definition (claude/payout_mixpanel_def_queries.sql, per-player section; album prizes left out; same Mixpanel filters):
--   ratio = own payout days +1..+3 after close / own payout close-18..-5. Buckets (my choice): lower <0.9 / same 0.9-1.1 / higher >1.1; z_na = did not play in both windows.
-- Dice: the 1.2M-balance cohort goes to z_na (left out as in slide 36). Results: claude/topic6-short-payers-2026-10-24.md (section 'Payout split').

-- ===== DISNEY 15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id = 15 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end, MAX(a.uniq) >= 144 AS cf,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_close_date) AS a_end FROM `solitaire-dreams-411507.bi_prod.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-05' AND album_id = 15 GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.album_spent_today,0)) AS rev7, COUNTIF(IFNULL(n.album_spent_today,0) > 0) AS pay_days7
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 1
  WHERE n.date_dim BETWEEN DATE '2026-08-25' AND DATE '2026-10-12' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN u.uniq_end >= 144 THEN 'a_finished' WHEN u.uniq_end >= 142 THEN 'b_1_2' WHEN u.uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status, u.cf
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
s AS (SELECT * FROM t WHERE status = 'b_1_2'),
pop AS (SELECT s.user_id, c.a_end FROM s CROSS JOIN cl c),
ev AS (
  SELECT user_id, pdate AS d, timestamp AS ts, 'in' AS dir, IFNULL(source,'') AS source, SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) AS units,
    coins_balance_in_allowance AS bal
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-08'
  UNION ALL
  SELECT user_id, pdate, timestamp, 'out', IFNULL(source,''), SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)), coins_balance_in_allowance
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-08'
),
e2 AS (SELECT user_id, d, ts, dir, source, units, bal, (units BETWEEN 0 AND 1000 AND bal BETWEEN 0 AND 5000) AS ok,
  source IN ('album completed','album set completed','album','magic set completed','magic sets grand prize','duplicates','album tutorial','album set potion retro') AS alb_src,
  source IN (
      'album completed','album set completed','area completed','conveyor_belt','crafting','duplicates','friend_invite','level completed',
      'marketplace','mini_collection','momentum','mtx challenge','race','rate us','wild undone','fortune_flight','','crafting_daily_dish',
      'gamified_8box','magic set completed','magic sets grand prize','album','blast','catcher','challenge','tournament','Trio-Panel',
      'Trio-Grand-Prize','trade','tick-tock','sleigh-trails','icy-bars','holiday_tree','forever-after-trade','flytext','farmers-market-chef',
      'enough DR','duel','scrolling','tierrun_grand_prize','album set potion retro','trivia','potion tutorial','mf tier completed',
      'mf milestone 3 reached','mf milestone 2 reached mf tier completed','mf milestone 2 reached','mf milestone 1 reached mf tier completed',
      'mf milestone 1 reached mf milestone 2 reached mf tier completed','mf milestone 1 reached mf milestone 2 reached mf milestone 3 reached',
      'mf milestone 1 reached mf milestone 2 reached','mf milestone 1 reached','mf grand prize','level start','album tutorial',
      'mf milestone 2 reached mf milestone 3 reached','mf milestone 2 reached mf milestone 3 reached mf tier completed',
      'mf milestone 1 reached mf milestone 2 reached mf milestone 3 reached mf tier completed','mf milestone 3 reached mf tier completed',
      'lightyear-trail','welcomeback','merge milestone reached','merge event completed','disney_moments') AS c_src FROM ev),
day AS (
  SELECT user_id, d,
    SUM(IF(dir = 'out' AND source = 'level start' AND ok, units, 0)) AS a_stake,
    SUM(IF(dir = 'out' AND source IN ('extra tiles','undo','wild','trade') AND ok, units, 0)) AS b_boost,
    SUM(IF(dir = 'in' AND c_src AND ok, units, 0)) AS c_won,
    SUM(IF(dir = 'in' AND c_src AND alb_src AND ok, units, 0)) AS c_album
  FROM e2 GROUP BY 1,2
),
x AS (
  SELECT p.user_id, DATE_DIFF(dy.d, p.a_end, DAY) AS dk, dy.a_stake, dy.b_boost, dy.c_won, dy.c_album
  FROM pop p JOIN day dy ON dy.user_id = p.user_id AND dy.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 3 DAY)),
pp AS (
  SELECT user_id,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN -18 AND -5, c_won - c_album, 0)), SUM(IF(dk BETWEEN -18 AND -5, a_stake + b_boost, 0))) AS mid,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN 1 AND 3, c_won - c_album, 0)), SUM(IF(dk BETWEEN 1 AND 3, a_stake + b_boost, 0))) AS post
  FROM x GROUP BY 1
  HAVING SUM(IF(dk BETWEEN -18 AND -5, a_stake + b_boost, 0)) > 0 AND SUM(IF(dk BETWEEN 1 AND 3, a_stake + b_boost, 0)) > 0),
pb AS (
  SELECT s.tier, s.alb_rev, s.last7, s.pace, s.rev7, s.pay_days7, SAFE_DIVIDE(p.post, p.mid) AS ratio,
    CASE WHEN p.mid IS NULL OR p.mid <= 0 THEN 'z_na' WHEN p.post / p.mid < 0.9 THEN 'p1_lower' WHEN p.post / p.mid <= 1.1 THEN 'p2_same' ELSE 'p3_higher' END AS pbucket
  FROM s LEFT JOIN pp p USING (user_id)),
agg AS (
  SELECT tier, pbucket, alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb
  UNION ALL SELECT tier, 'all', alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb
  UNION ALL SELECT 'all', pbucket, alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb WHERE tier != 't0_0'
  UNION ALL SELECT 'all', 'all', alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb WHERE tier != 't0_0')
SELECT tier, pbucket, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, ROUND(APPROX_QUANTILES(ratio, 2)[OFFSET(1)], 2) AS med_payout_ratio,
  ROUND(SAFE_DIVIDE(SUM(last7) / 7, SUM(pace)), 3) AS last7_vs_pace,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d
FROM agg CROSS JOIN tot WHERE tier != 't0_0' GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DOMINO 20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end, MAX(a.uniq) >= 144 AS cf,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-05' AND album_id = 20 GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.album_spent_today,0)) AS rev7, COUNTIF(IFNULL(n.album_spent_today,0) > 0) AS pay_days7
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 1
  WHERE n.date_dim BETWEEN DATE '2026-08-25' AND DATE '2026-10-19' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN u.uniq_end >= 144 THEN 'a_finished' WHEN u.uniq_end >= 142 THEN 'b_1_2' WHEN u.uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status, u.cf
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
s AS (SELECT * FROM t WHERE status = 'b_1_2'),
pop AS (SELECT s.user_id, c.a_end FROM s CROSS JOIN cl c),
ev AS (
  SELECT user_id, pdate AS d, timestamp AS ts, 'in' AS dir, source, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)) AS units, mp_country_code, coins_balance_in_allowance AS bal
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-15'
  UNION ALL
  SELECT user_id, pdate, timestamp, 'out', source, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)), mp_country_code, coins_balance_in_allowance
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-15'
),
e2 AS (SELECT user_id, d, ts, dir, source, units, bal, (units BETWEEN 0 AND 1000) AS ok, IFNULL(mp_country_code,'') NOT IN ('IL','RO') AS ctry,
  source IN ('album completed','album set completed','album set pixie retro','album tutorial','bonus set completed','bonus sets grand prize','duplicates','deluxe grand prize','deluxe tier completed','sets_mania') AS alb_src,
  source IN ('level completed',
      'album completed','album set completed','album set pixie retro','album tutorial','area completed','battleship - tier reward',
      'blast grand prize','blast reward','blast tier complete','bonus set completed','bonus sets grand prize','chef_ingredients_from_levels',
      'collaboration building','collaboration grand prize','collaboration tier','crafting grand prize','crafting item completed',
      'dream pass free','duel','duplicates','empty blast','farmers-market-chef','franklins_booster_kiosk_marketplace',
      'hidden object consolation prize','hidden objects grand prize','hidden objects tier completed','marketplace','mini_collection',
      'momentum','mtx challenge','pet milestone 1 reached','pet milestone 1 reached pet milestone 2 reached',
      'pet milestone 1 reached pet milestone 2 reached pet milestone 3 reached',
      'pet milestone 1 reached pet milestone 2 reached pet milestone 3 reached pet tier completed',
      'pet milestone 1 reached pet milestone 2 reached pet tier completed','pet milestone 1 reached pet tier completed',
      'pet milestone 2 reached','pet milestone 2 reached pet milestone 3 reached','pet milestone 2 reached pet milestone 3 reached pet tier completed',
      'pet milestone 2 reached pet tier completed','pet milestone 3 reached','pet milestone 3 reached pet tier completed','pet tier completed',
      'pet tutorial','pixel_path','pixie tutorial','pixie_reward','race','royal_tower_consolation_prize','royal_tower_grand_prize',
      'royal_tower_prize','summer-kiosk','swamp grand prize','swamp tier completed','tournament','tournament_progress_bar',
      'trail - grand reward','trail - tier reward','trail-twister','wonders wheel','pet tier','adventure-wheel','battleship - dr reward',
      'color-book','deluxe grand prize','deluxe tier completed','fortune_flight','friday-the-13th-twister','icy-bars','jungle-wheel',
      'merge - board reward','merge - free items carry over','merge - grand prize','pixel_path_first_try_bonus','pixel_path_grand_prize',
      'pixel_path_tier_completed','sets_mania','sprint','sweet-treats','trail - tile reward') AS w_src FROM ev),
day AS (
  SELECT user_id, d,
    SUM(IF(dir = 'out' AND source IN ('level start','wild','undo','extra tiles') AND ok AND ctry, units, 0)) AS spent,
    SUM(IF(dir = 'in' AND w_src AND ok AND ctry, units, 0)) AS won,
    SUM(IF(dir = 'in' AND w_src AND alb_src AND ok AND ctry, units, 0)) AS won_album
  FROM e2 GROUP BY 1,2
),
x AS (
  SELECT p.user_id, DATE_DIFF(dy.d, p.a_end, DAY) AS dk, dy.spent, dy.won, dy.won_album
  FROM pop p JOIN day dy ON dy.user_id = p.user_id AND dy.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 3 DAY)),
pp AS (
  SELECT user_id,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN -18 AND -5, won - won_album, 0)), SUM(IF(dk BETWEEN -18 AND -5, spent, 0))) AS mid,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN 1 AND 3, won - won_album, 0)), SUM(IF(dk BETWEEN 1 AND 3, spent, 0))) AS post
  FROM x GROUP BY 1
  HAVING SUM(IF(dk BETWEEN -18 AND -5, spent, 0)) > 0 AND SUM(IF(dk BETWEEN 1 AND 3, spent, 0)) > 0),
pb AS (
  SELECT s.tier, s.alb_rev, s.last7, s.pace, s.rev7, s.pay_days7, SAFE_DIVIDE(p.post, p.mid) AS ratio,
    CASE WHEN p.mid IS NULL OR p.mid <= 0 THEN 'z_na' WHEN p.post / p.mid < 0.9 THEN 'p1_lower' WHEN p.post / p.mid <= 1.1 THEN 'p2_same' ELSE 'p3_higher' END AS pbucket
  FROM s LEFT JOIN pp p USING (user_id)),
agg AS (
  SELECT tier, pbucket, alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb
  UNION ALL SELECT tier, 'all', alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb
  UNION ALL SELECT 'all', pbucket, alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb WHERE tier != 't0_0'
  UNION ALL SELECT 'all', 'all', alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb WHERE tier != 't0_0')
SELECT tier, pbucket, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, ROUND(APPROX_QUANTILES(ratio, 2)[OFFSET(1)], 2) AS med_payout_ratio,
  ROUND(SAFE_DIVIDE(SUM(last7) / 7, SUM(pace)), 3) AS last7_vs_pace,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d
FROM agg CROSS JOIN tot WHERE tier != 't0_0' GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DICE 63 (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-09-05' AND album_id = 63 GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.spent_in_album_today,0)) AS rev7, COUNTIF(IFNULL(n.spent_in_album_today,0) > 0) AS pay_days7
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 2
  WHERE n.date_dim BETWEEN DATE '2026-07-28' AND DATE '2026-09-14' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN u.uniq_end >= 144 THEN 'a_finished' WHEN u.uniq_end >= 142 THEN 'b_1_2' WHEN u.uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
s AS (SELECT t.* FROM t WHERE t.status = 'b_1_2'),
pop AS (SELECT s.user_id, c.a_end FROM s CROSS JOIN cl c),
ro AS (  -- the 1.2M balance cohort, curated
  SELECT user_id, date_dim AS d, IFNULL(rolls_max,0) AS bal_max
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
  WHERE date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-09-10'
),
bigbal AS (SELECT DISTINCT user_id FROM ro WHERE bal_max > 1200000),
rl AS (  -- [STG] A = stake per player-day
  SELECT user_id, pdate AS d, SUM(bet_mult + IFNULL(prime_cost, 0)) AS stake, ARRAY_AGG(rolls_balance IGNORE NULLS ORDER BY timestamp DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_end
  FROM `dice-dreams-dbt.10_staging.stg_roll_vw`
  WHERE pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-10'
    AND bet_mult IN (1,2,3,5,8,10,25,50,100,200,250,400,500,800,1000,1500,2000,2500,4000,5000,6000,10000)
  GROUP BY 1,2
),
ri AS (  -- [STG] rolls in events with the Mixpanel properties
  SELECT user_id, pdate AS d, amount,
    IFNULL(source,'') AS a, IFNULL(subsource,'') AS sub, IFNULL(campaign_name,'') AS cmp, IFNULL(reward_syntax_final,'') AS rsf,
    IFNULL(event_name,'') AS evn, IFNULL(subsource2,'') AS sub2, IFNULL(CAST(campaign_id AS STRING),'') AS cid,
    IFNULL(placement,'') AS plc, '' AS sku  -- purchase_sku not in the view
  FROM `dice-dreams-dbt.10_staging.stg_rolls_in_vw`
  WHERE pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-10'
    AND amount BETWEEN 1 AND 750000
),
ri_g AS (
  SELECT user_id, d, amount,
    CASE  -- 11919 "Rolls In - Source (Grouped)", rules in Mixpanel order
      WHEN REGEXP_CONTAINS(a, r'MQ') THEN 'Lava Quest'
      WHEN REGEXP_CONTAINS(a, r'Offer') OR REGEXP_CONTAINS(a, r'ScrollingOffer') THEN 'Purchase'
      WHEN REGEXP_CONTAINS(a, r'Aztec|Submarines_Refactor') OR a IN ('Royal_Fortune','USA_Fortune') THEN 'Aztec'
      WHEN (REGEXP_CONTAINS(rsf, r'merge') AND a = '') OR a IN ('mergegrandprize','mergetierreward') THEN 'Merge'
      WHEN a = 'AnteBet' THEN 'AnteBet'
      WHEN a IN ('', 'PendingRewards') THEN 'Pending Reward'
      WHEN REGEXP_CONTAINS(a, r'SlotMachine|SLOT MACHINE') THEN 'SlotMachine'
      WHEN REGEXP_CONTAINS(a, r'Duel') THEN 'Duel'
      WHEN REGEXP_CONTAINS(a, r'ColoringBook') THEN 'ColoringBook'
      WHEN a = 'Daily_Tasks' THEN 'Daily Tasks'
      WHEN a = 'WeeklyGoals' THEN 'WeeklyGoals'
      WHEN a = 'SecretPassage' THEN 'SecretPassage'
      WHEN a = 'VerticalQuest_8_Locked' THEN 'Purchase'
      WHEN REGEXP_CONTAINS(a, r'Puzzle') AND REGEXP_CONTAINS(cmp, r'GoldenPuzzle') AND REGEXP_CONTAINS(cmp, r'TopLayer') THEN 'GoldenPuzzle'
      WHEN REGEXP_CONTAINS(a, r'Puzzle|puzzle') THEN 'Puzzle'
      WHEN REGEXP_CONTAINS(a, r'Stories') THEN 'Stories'
      WHEN REGEXP_CONTAINS(cmp, r'AntiChurn') OR REGEXP_CONTAINS(sub, r'DailyGift')
        OR a IN ('RewardCalendar','1Plus6_WelcomeBack','7_Rewards_Kingdoms_NoCloseButton') THEN 'Daily Gift & Anti-Churn'
      WHEN a IN ('attack','Card - Coins','steal','rob','Card','sheilds payback','joker','rps','Card - Rolls','shields payback',
                 'ContentUnlock','FB incentive','Generic_Reward_NoCloseButton','shields_gained') THEN 'Core Wager'
      WHEN a = 'invite friend' THEN 'Invite Friends'
      WHEN a = 'Peonball' THEN 'PeonBall'
      WHEN a IN ('Progress Bar','ProgressBarV2','Progress Bar V2') THEN 'Progress Bar'
      WHEN a IN ('set_completed','Duplication exchange','SeasonalChaseComplete')
        OR REGEXP_CONTAINS(a, r'album|SetComplete|Heist|SET|set|pixie') THEN 'Album'
      WHEN REGEXP_CONTAINS(LOWER(a), r'twister') OR REGEXP_CONTAINS(a, r'TileTwister') THEN 'Tile Twister'
      WHEN REGEXP_CONTAINS(a, r'FortuneWheel') THEN 'Fortune Wheel'
      WHEN a = 'Dream Pass' THEN 'Dream Pass'
      WHEN a = 'cl' OR REGEXP_CONTAINS(cmp, r'Candyland') THEN 'Candy Land'
      WHEN a = 'BuildWithFriends' OR REGEXP_CONTAINS(a, r'bwf') THEN 'BuildWithFriends'
      WHEN REGEXP_CONTAINS(a, r'ChampionsChamber') THEN 'Champions Chamber'
      WHEN a IN ('building complete','town gift','TownReward','peon_gift','SagaMap3D','peon-gift') OR REGEXP_CONTAINS(a, r'peonball') THEN 'Kingdom Gifts'
      WHEN a IN ('roll timer','rolls timer') THEN 'Roll Timer'
      WHEN REGEXP_CONTAINS(a, r'Trail|boss_tile') OR a = 'tile' THEN 'Trail'
      WHEN a IN ('Tournament','tournament','CustomerSupportReward','Tournament - Chest','chest reward') THEN 'Tournament - Chests'
      WHEN a = 'Tournament - Final Reward' THEN 'Tournament - Final Reward'
      WHEN a = 'tournament V2' AND sub = 'tournament_grand_prize' THEN 'Tournament - Final Reward'
      WHEN REGEXP_CONTAINS(a, r'blast') THEN 'Blast'
      WHEN REGEXP_CONTAINS(a, r'Tournament') THEN 'Tournament - Chests'
      WHEN REGEXP_CONTAINS(sub, r'YCR|PTS_Carnival|SuperQuest|KingdomQuest|TurkeyPower')
        OR a IN ('Challenge Bracket','Home_Makeover','Dynamic_Path_v3')
        OR REGEXP_CONTAINS(a, r'Madness|Challenge|ThisOrThat|3ToWin|Quest') THEN 'Quest / Challenge'
      WHEN REGEXP_CONTAINS(a, r'RV') OR REGEXP_CONTAINS(cmp, r'_RV|_Opportunistic|NO RV') OR a = 'advertisement reward' THEN 'RV'
      WHEN a IN ('Pets Feature','Pets') OR REGEXP_CONTAINS(a, r'PropChase_Hunt|Pet') THEN 'Pet'
      WHEN REGEXP_CONTAINS(a, r'BoomBoard') THEN 'BoomBoard'
      WHEN a = 'DeepLinkReward' THEN 'Deep Links'
      WHEN REGEXP_CONTAINS(a, r'Frank') THEN 'Chef'
      WHEN a = 'DoodlesCollection' THEN 'Doodle'
      WHEN a = 'parallel roads' THEN 'Parallel Roads'
      WHEN a = 'Market_With_PB_v3' THEN 'Market'
      WHEN REGEXP_CONTAINS(cmp, r'DDJ') THEN 'DDJ'
      WHEN REGEXP_CONTAINS(a, r'Coupon_Book') THEN 'Others'
      ELSE 'Purchase' END AS grp11919,
    (  -- 9113 "Source (Purchase Complete)" ≠ Others
         REGEXP_CONTAINS(LOWER(sub), r'1+16') OR REGEXP_CONTAINS(cmp, r'1Plus16|OnePlusSixteen|1PlusX_16')
      OR REGEXP_CONTAINS(LOWER(a), r'oneplustwelve|fpff|honeyroadshort|discoroadshort|dp_|_dp|dt_|_dt')
      OR REGEXP_CONTAINS(LOWER(cmp), r'1plus12|1plus10|1plus8|1plus6|scrolling|deepdivejourney|dt_for_dreampass|savingssuperhero|6box|pfp|1plus2|1plussurprise')
      OR REGEXP_CONTAINS(a, r'OnePlusThre|6Boxes|Limited_Stock|BuildYourBundle|VerticalQuest_8_Locked|DP_Big_Chest|Six_resource_offer|Big|Direct_Purchase')
      OR a IN ('vertical pass','Dream Pass','Special Offer')
      OR REGEXP_CONTAINS(sub, r'Happy Hour|1Plus3|Decoy') OR REGEXP_CONTAINS(LOWER(sub), r'bigand')
      OR REGEXP_CONTAINS(cmp, r'Whammy|HoneyRoad|Honey_Road|1Plus3|OnePlusThree|Decoy|Journey|_HappyHour|Octopus|Horizontal|SixWedgesWheel|Big|Stickers_Golden_Test|7Rewards|Pricing_Protocol-Megalomania|PinataRush|SixBox|6Box|Superhero|Revealing_Offer|1plus1|FPFF|Royal_Puzzle|Pixies|FairyTaleOffer|Bundle')
      OR cmp = '1Plus2' OR (REGEXP_CONTAINS(cmp, r'K40') AND a = 'scrolling offer')
      OR REGEXP_CONTAINS(evn, r"BigAndBigger|BigAnd|DragonPackOffer|BigRoll|SavingSuperhero|Revealing_Offer|Pixie's|PickYourCard|FTD Plan|ContinuityPlan|OOR|Decoy|SafeOr|MissingSpecificSticker|MissingSticker|Sale|FatherDay|Memorial_Day")
      OR evn IN ('020122_V2 - Same Price Same Value untill Kingdom 4','020122_V2 - Same Price Same Value untill Kingdom 5','030122_V3 - Same price, better discount')
      OR sub IN ('com.superplay.mtx_beginner_deal_1','com.superplay.mtx_special_offer_2usd_1','A 1+2','A15+ (1+2 Group)','Offer  1-3','Offer 4','First Timer Pack',
                 '10684','10681','11879','11880','23100','24023','25290','7510') OR REGEXP_CONTAINS(sub, r'10685')
      OR (REGEXP_CONTAINS(sub, r'Bundle') AND a = 'Store') OR (REGEXP_CONTAINS(sku, r'Bundle') AND REGEXP_CONTAINS(a, r'Store'))
      OR REGEXP_CONTAINS(sub2, r'playpoints')
      OR cid IN ('BlastOutOfPicks','BlastPicksBalanceTapped','TrailOutOfSpins')
      OR plc IN ('com.superplay.coin_large_pack','com.superplay.coin_medium_pack','com.superplay.coin_small_pack','com.superplay.coin_xxl_pack',
                 'com.superplay.coin_tiny_pack','com.superplay.coin_xl_pack','com.superplay.roll_large_pack','com.superplay.roll_medium_pack',
                 'com.superplay.roll_small_pack','com.superplay.roll_tiny_pack','com.superplay.roll_xl_pack','com.superplay.roll_xxl_pack',
                 'com.superplay.out_of_rolls','com.superplay.out_of_coins')
      -- Piggy list (exact SKUs in 9113): 2/3/5 usd_ftd_piggy, 2..35 usd_piggy, 40..95 step 5, 125, 150
      OR plc IN (SELECT CONCAT('com.superplay.mtx_special_offer_', CAST(x AS STRING), 'usd_piggy') FROM UNNEST(
                   ARRAY_CONCAT(GENERATE_ARRAY(2,35), GENERATE_ARRAY(40,95,5), [125,150])) x)
      OR plc IN ('com.superplay.mtx_special_offer_2usd_ftd_piggy','com.superplay.mtx_special_offer_3usd_ftd_piggy','com.superplay.mtx_special_offer_5usd_ftd_piggy')
      -- Bundle / Special Offer SKU lists in 9113 (…usd_1, …usd_2, …usd_4, ftd_1/ftd_2, subdollar): exact list
      OR plc IN (SELECT CONCAT('com.superplay.mtx_special_offer_', s) FROM UNNEST([
           '4usd_1','6usd_1','7usd_1','8usd_1','11usd_1','13usd_1','20usd_1','30usd_1','50usd_1','25usd_1','15usd_1','100usd_1','40usd_1',
           '35usd_1','18usd_1','65usd_1','45usd_1','55usd_1','85usd_1','75usd_1','3usd_1','5usd_1','60usd_1','70usd_1','80usd_1','16usd_1',
           '90usd_1','9usd_1','12usd_1','14usd_1','17usd_1','22usd_1','6usd_ftd_1','10usd_1','10usd_ftd_1','7usd_ftd_1','8usd_ftd_1',
           '9usd_ftd_1','5usd_ftd_1','3usd_ftd_1','4usd_ftd_1',
           '3usd_2','4usd_2','5usd_2','6usd_2','7usd_2','8usd_2','9usd_2','10usd_2','11usd_2','12usd_2','13usd_2','14usd_2','15usd_2',
           '16usd_2','17usd_2','18usd_2','19usd_2','20usd_2','21usd_2','22usd_2','23usd_2','24usd_2','25usd_2','26usd_2','27usd_2',
           '28usd_2','29usd_2','30usd_2','31usd_2','32usd_2','33usd_2','34usd_2','35usd_2','40usd_2','60usd_2','55usd_2','45usd_2',
           '50usd_2','65usd_2','80usd_2','70usd_2','85usd_2','90usd_2','100usd_2','2usd_2','75usd_2',
           '4usd_4','2usd_4','7usd_4','3usd_4','20usd_4','8usd_4','16usd_4','10usd_4','6usd_4','5usd_4','22usd_4','14usd_4','12usd_4',
           '9usd_4','11usd_4','13usd_4','15usd_4','17usd_4','19usd_4','21usd_4','23usd_4','80usd_4','100usd_4','18usd_4','24usd_4',
           '25usd_4','26usd_4','27usd_4','28usd_4','29usd_4','30usd_4','31usd_4','32usd_4','33usd_4','35usd_4','40usd_4','45usd_4',
           '50usd_4','55usd_4','60usd_4','65usd_4','75usd_4','85usd_4','90usd_3','90usd_4',
           '4usd_ftd_2','3usd_ftd_2','2usd_ftd_2','5usd_ftd_2','subdollar_1']) s)
    ) AS is_purchase_9113
  FROM ri
),
rin AS (
  SELECT user_id, d,
    SUM(IF(grp11919 NOT IN ('RV','Roll Timer','Daily Gift & Anti-Churn','Invite Friends','Deep Links','Pending Reward','DDJ'), amount, 0)) AS b_in,
    SUM(IF(is_purchase_9113, amount, 0)) AS c_bought,
    SUM(IF(grp11919 = 'Album', amount, 0)) AS b_album
  FROM ri_g GROUP BY 1,2
),
x AS (
  SELECT p.user_id, DATE_DIFF(r.d, p.a_end, DAY) AS dk, r.stake, IFNULL(i.b_in,0) AS b_in, IFNULL(i.c_bought,0) AS c_bought, IFNULL(i.b_album,0) AS b_album
  FROM pop p JOIN rl r ON r.user_id = p.user_id AND r.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 3 DAY)
  LEFT JOIN rin i ON i.user_id = p.user_id AND i.d = r.d
  WHERE p.user_id NOT IN (SELECT user_id FROM bigbal)),
pp AS (
  SELECT user_id,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN -18 AND -5, b_in - c_bought - b_album, 0)), SUM(IF(dk BETWEEN -18 AND -5, stake, 0))) AS mid,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN 1 AND 3, b_in - c_bought - b_album, 0)), SUM(IF(dk BETWEEN 1 AND 3, stake, 0))) AS post
  FROM x GROUP BY 1
  HAVING SUM(IF(dk BETWEEN -18 AND -5, stake, 0)) > 0 AND SUM(IF(dk BETWEEN 1 AND 3, stake, 0)) > 0),
pb AS (
  SELECT s.tier, s.alb_rev, s.last7, s.pace, s.rev7, s.pay_days7, SAFE_DIVIDE(p.post, p.mid) AS ratio,
    CASE WHEN p.mid IS NULL OR p.mid <= 0 THEN 'z_na' WHEN p.post / p.mid < 0.9 THEN 'p1_lower' WHEN p.post / p.mid <= 1.1 THEN 'p2_same' ELSE 'p3_higher' END AS pbucket
  FROM s LEFT JOIN pp p USING (user_id)),
agg AS (
  SELECT tier, pbucket, alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb
  UNION ALL SELECT tier, 'all', alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb
  UNION ALL SELECT 'all', pbucket, alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb WHERE tier != 't0_0'
  UNION ALL SELECT 'all', 'all', alb_rev, last7, pace, rev7, pay_days7, ratio FROM pb WHERE tier != 't0_0')
SELECT tier, pbucket, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, ROUND(APPROX_QUANTILES(ratio, 2)[OFFSET(1)], 2) AS med_payout_ratio,
  ROUND(SAFE_DIVIDE(SUM(last7) / 7, SUM(pace)), 3) AS last7_vs_pace,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d
FROM agg CROSS JOIN tot WHERE tier != 't0_0' GROUP BY 1, 2 ORDER BY 1, 2;
