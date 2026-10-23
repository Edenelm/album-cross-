-- Eden 2026-10-23: "in lull days or burst days, is there an anomaly in the economy, e.g. high payout on days many stickers are released?"
-- Disney 15 (solitaire-dreams-411507), standard-population payers (paid any album day incl. close), all players, per album day.
-- Payout = Mixpanel "Total RTP" (C won - B boosters) / A level-start stake, allowance units, same filters as payout_mixpanel_def_queries.sql.
-- Album-prize coins = album / set / duplicates sources. New stickers per payer = day-to-day change of unique stickers (daily album table).
WITH ud AS (
  SELECT user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, IFNULL(active_flag,FALSE) AS act
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-05' AND album_id = 15 AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS lr_l,
    ARRAY_AGG(IF(date_dim < a_end, uac, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uac_l,
    ARRAY_AGG(IF(date_dim < a_end, excl, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS excl_l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1
),
pop AS (
  SELECT u.user_id, a_start, a_end FROM u LEFT JOIN bad_users b ON b.user_id = u.user_id
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND uac_l > 1 AND NOT excl_l AND lr_l >= 0.5 AND rev_c > 0 AND b.user_id IS NULL
),
pd AS (
  SELECT d.user_id, d.date_dim, DATE_DIFF(d.date_dim, p.a_start, DAY) + 1 AS ad, d.spend, d.act,
    d.uniq - LAG(d.uniq) OVER (PARTITION BY d.user_id ORDER BY d.date_dim) AS new_st
  FROM ud d JOIN pop p USING (user_id) WHERE d.date_dim < p.a_end
),
ev AS (
  SELECT user_id, pdate AS d, timestamp AS ts, 'in' AS dir, IFNULL(source,'') AS source,
    SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) AS units, coins_balance_in_allowance AS bal
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_in_vw` WHERE pdate BETWEEN DATE '2026-08-15' AND DATE '2026-10-05'
  UNION ALL
  SELECT user_id, pdate, timestamp, 'out', IFNULL(source,''), SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)), coins_balance_in_allowance
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_out_vw` WHERE pdate BETWEEN DATE '2026-08-15' AND DATE '2026-10-05'
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
    SUM(IF(dir = 'out' AND source = 'level start', units, 0)) AS a_all,
    SUM(IF(dir = 'out' AND source = 'level start' AND ok, units, 0)) AS a_stake,
    SUM(IF(dir = 'out' AND source IN ('extra tiles','undo','wild','trade') AND ok, units, 0)) AS b_boost,
    SUM(IF(dir = 'in' AND c_src AND ok, units, 0)) AS c_won,
    SUM(IF(dir = 'in' AND c_src AND alb_src AND ok, units, 0)) AS c_album,
    ARRAY_AGG(bal IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_end
  FROM e2 GROUP BY 1,2
),
x AS (
  SELECT pd.ad, pd.spend, pd.act, pd.new_st, IFNULL(dy.a_all,0) AS a_all, IFNULL(dy.a_stake,0) AS a_stake, IFNULL(dy.b_boost,0) AS b_boost,
    IFNULL(dy.c_won,0) AS c_won, IFNULL(dy.c_album,0) AS c_album, dy.bal_end
  FROM pd LEFT JOIN day dy ON dy.user_id = pd.user_id AND dy.d = pd.date_dim
)
SELECT ad AS album_day, COUNT(*) AS payers, COUNTIF(a_all > 0) AS playing,
  ROUND(AVG(new_st), 2) AS new_stickers_pp,
  ROUND(SAFE_DIVIDE(SUM(spend), COUNTIF(act)), 2) AS usd_per_active,
  ROUND(SAFE_DIVIDE(COUNTIF(spend > 0), COUNTIF(act)), 3) AS paying_share,
  ROUND(SAFE_DIVIDE(SUM(a_stake), COUNTIF(a_all > 0)), 1) AS stake_pp,
  ROUND(SAFE_DIVIDE(SUM(c_won), COUNTIF(a_all > 0)), 1) AS won_pp,
  ROUND(SAFE_DIVIDE(SUM(c_album), COUNTIF(a_all > 0)), 1) AS album_coins_pp,
  ROUND(100 * SAFE_DIVIDE(SUM(c_won) - SUM(b_boost), SUM(a_stake)), 1) AS rtp_pct,
  ROUND(100 * SAFE_DIVIDE(SUM(c_won - c_album) - SUM(b_boost), SUM(a_stake)), 1) AS rtp_no_album_pct,
  APPROX_QUANTILES(bal_end, 2)[OFFSET(1)] AS bal_median
FROM x GROUP BY 1 ORDER BY 1
