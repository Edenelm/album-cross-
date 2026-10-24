-- 2026-10-21 (Eden): where does the high payout of the last 4 days come from, Domino vs the other games? Approved to run.
-- Wins by source class in three periods: a_mid = close-18..close-5, b_last4 = close-4..close-1, c_close = the close day.
-- Population: standard-population payers (paid on any album day incl. close day), all end statuses. Same staging views and
-- Mixpanel filters as payout_mixpanel_def_queries.sql (Domino: amount 0..1000 units, not IL/RO; Disney: 0..1000 and balance 0..5000;
-- Dice: the 1.2M-balance cohort left out, 'rolls in' 1..750,000, Mixpanel source grouping 11919, purchases 9113 subtracted).
-- Rows: album x period x source class; won_units, pct_of_won (share of all counted wins), payout_points (= won / coins spent x 100,
-- the source's contribution to the payout %), payout_pct_total (the period's game payout on the Mixpanel formula).
-- Results: claude/payout-by-source-last4-2026-10-21.md

-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, rev_c, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u),
pop AS (
  SELECT album_id, user_id, a_end FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
ev AS (
  SELECT user_id, pdate AS d, 'in' AS dir, IFNULL(source,'') AS source, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)) AS units, mp_country_code
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-24' OR pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-12'
  UNION ALL
  SELECT user_id, pdate, 'out', IFNULL(source,''), SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)), mp_country_code
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-24' OR pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-12'
),
e2 AS (
  SELECT user_id, d, dir, source, units FROM ev
  WHERE units BETWEEN 0 AND 1000 AND IFNULL(mp_country_code,'') NOT IN ('IL','RO')
),
per AS (
  SELECT p.album_id, e.user_id, e.d, e.dir, e.source, e.units,
    CASE WHEN e.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_SUB(p.a_end, INTERVAL 5 DAY) THEN 'a_mid'
         WHEN e.d BETWEEN DATE_SUB(p.a_end, INTERVAL 4 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY) THEN 'b_last4'
         ELSE 'c_close' END AS period,
    e.source IN ('album completed','album set completed','album set pixie retro','album tutorial','bonus set completed','bonus sets grand prize','duplicates','deluxe grand prize','deluxe tier completed','sets_mania') AS alb_src,
    e.source IN ('level completed',
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
      'pixel_path_tier_completed','sets_mania','sprint','sweet-treats','trail - tile reward') AS w_src
  FROM e2 e JOIN pop p USING (user_id)
  WHERE e.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND p.a_end
),
tot AS (
  SELECT album_id, period,
    SUM(IF(dir = 'out' AND source IN ('level start','wild','undo','extra tiles'), units, 0)) AS spent,
    SUM(IF(dir = 'in' AND w_src, units, 0)) AS won,
    COUNT(DISTINCT IF(dir = 'out' AND source = 'level start', user_id, NULL)) AS players,
    COUNT(DISTINCT d) AS days
  FROM per GROUP BY 1,2
),
src AS (
  SELECT album_id, period, CASE WHEN alb_src OR source = 'level completed' THEN source ELSE 'other' END AS src, SUM(units) AS won
  FROM per WHERE dir = 'in' AND w_src GROUP BY 1,2,3
)
SELECT s.album_id, s.period, s.src, ROUND(s.won) AS won_units,
  ROUND(100 * s.won / t.won, 1) AS pct_of_won,
  ROUND(100 * s.won / t.spent, 1) AS payout_points,
  ROUND(100 * t.won / t.spent, 1) AS payout_pct_total,
  t.players, t.days
FROM src s JOIN tot t USING (album_id, period)
ORDER BY 1,2, won_units DESC
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, rev_c, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u),
pop AS (
  SELECT album_id, user_id, a_end FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
ev AS (
  SELECT user_id, pdate AS d, 'in' AS dir, IFNULL(source,'') AS source, SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) AS units, coins_balance_in_allowance AS bal
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-24' OR pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-05'
  UNION ALL
  SELECT user_id, pdate, 'out', IFNULL(source,''), SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)), coins_balance_in_allowance
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-24' OR pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-05'
),
e2 AS (SELECT user_id, d, dir, source, units FROM ev WHERE units BETWEEN 0 AND 1000 AND bal BETWEEN 0 AND 5000),
per AS (
  SELECT p.album_id, e.user_id, e.d, e.dir, e.source, e.units,
    CASE WHEN e.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_SUB(p.a_end, INTERVAL 5 DAY) THEN 'a_mid'
         WHEN e.d BETWEEN DATE_SUB(p.a_end, INTERVAL 4 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY) THEN 'b_last4'
         ELSE 'c_close' END AS period,
    e.source IN ('album completed','album set completed','album','magic set completed','magic sets grand prize','duplicates','album tutorial','album set potion retro') AS alb_src,
    e.source IN (
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
      'lightyear-trail','welcomeback','merge milestone reached','merge event completed','disney_moments') AS c_src
  FROM e2 e JOIN pop p USING (user_id)
  WHERE e.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND p.a_end
),
tot AS (
  SELECT album_id, period,
    SUM(IF(dir = 'out' AND source = 'level start', units, 0)) AS stake,
    SUM(IF(dir = 'out' AND source IN ('extra tiles','undo','wild','trade'), units, 0)) AS boost,
    SUM(IF(dir = 'in' AND c_src, units, 0)) AS won,
    COUNT(DISTINCT IF(dir = 'out' AND source = 'level start', user_id, NULL)) AS players,
    COUNT(DISTINCT d) AS days
  FROM per GROUP BY 1,2
),
src AS (
  SELECT album_id, period, CASE WHEN alb_src OR source = 'level completed' THEN source ELSE 'other' END AS src, SUM(units) AS won
  FROM per WHERE dir = 'in' AND c_src GROUP BY 1,2,3
)
SELECT s.album_id, s.period, s.src, ROUND(s.won) AS won_units,
  ROUND(100 * s.won / t.won, 1) AS pct_of_won,
  ROUND(100 * s.won / t.stake, 1) AS payout_points,
  ROUND(100 * (t.won - t.boost) / t.stake, 1) AS rtp_pct_total,
  ROUND(100 * t.won / t.stake, 1) AS won_over_stake_pct,
  t.players, t.days
FROM src s JOIN tot t USING (album_id, period)
ORDER BY 1,2, won_units DESC
;

-- ===== DICE 61/63 (dice-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, rev_c, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u),
ro AS (
  SELECT user_id, IFNULL(rolls_max,0) AS bal_max
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
  WHERE date_dim BETWEEN DATE '2026-07-09' AND DATE '2026-07-27' OR date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-09-07'
),
bigbal AS (SELECT DISTINCT user_id FROM ro WHERE bal_max > 1200000),
pop AS (
  SELECT album_id, user_id, a_end FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bigbal)
),
rl AS (
  SELECT user_id, pdate AS d, SUM(bet_mult + IFNULL(prime_cost, 0)) AS stake
  FROM `dice-dreams-dbt.10_staging.stg_roll_vw`
  WHERE (pdate BETWEEN DATE '2026-07-09' AND DATE '2026-07-27' OR pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-07')
    AND bet_mult IN (1,2,3,5,8,10,25,50,100,200,250,400,500,800,1000,1500,2000,2500,4000,5000,6000,10000)
  GROUP BY 1,2
),
ri AS (
  SELECT user_id, pdate AS d, amount,
    IFNULL(source,'') AS a, IFNULL(subsource,'') AS sub, IFNULL(campaign_name,'') AS cmp, IFNULL(reward_syntax_final,'') AS rsf,
    IFNULL(event_name,'') AS evn, IFNULL(subsource2,'') AS sub2, IFNULL(CAST(campaign_id AS STRING),'') AS cid,
    IFNULL(placement,'') AS plc, '' AS sku
  FROM `dice-dreams-dbt.10_staging.stg_rolls_in_vw`
  WHERE (pdate BETWEEN DATE '2026-07-09' AND DATE '2026-07-27' OR pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-07')
    AND amount BETWEEN 1 AND 750000
),
ri_g AS (
  SELECT user_id, d, amount,
    CASE
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
    (
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
      OR plc IN (SELECT CONCAT('com.superplay.mtx_special_offer_', CAST(x AS STRING), 'usd_piggy') FROM UNNEST(
                   ARRAY_CONCAT(GENERATE_ARRAY(2,35), GENERATE_ARRAY(40,95,5), [125,150])) x)
      OR plc IN ('com.superplay.mtx_special_offer_2usd_ftd_piggy','com.superplay.mtx_special_offer_3usd_ftd_piggy','com.superplay.mtx_special_offer_5usd_ftd_piggy')
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
    ) AS is_purchase
  FROM ri
),
per_in AS (
  SELECT p.album_id, i.user_id, i.d, i.amount, i.grp11919, i.is_purchase,
    CASE WHEN i.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_SUB(p.a_end, INTERVAL 5 DAY) THEN 'a_mid'
         WHEN i.d BETWEEN DATE_SUB(p.a_end, INTERVAL 4 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY) THEN 'b_last4'
         ELSE 'c_close' END AS period
  FROM ri_g i JOIN pop p USING (user_id)
  WHERE i.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND p.a_end
    AND i.grp11919 NOT IN ('RV','Roll Timer','Daily Gift & Anti-Churn','Invite Friends','Deep Links','Pending Reward','DDJ')
),
per_st AS (
  SELECT p.album_id, r.user_id, r.d, r.stake,
    CASE WHEN r.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_SUB(p.a_end, INTERVAL 5 DAY) THEN 'a_mid'
         WHEN r.d BETWEEN DATE_SUB(p.a_end, INTERVAL 4 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY) THEN 'b_last4'
         ELSE 'c_close' END AS period
  FROM rl r JOIN pop p USING (user_id)
  WHERE r.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND p.a_end
),
tot AS (
  SELECT s.album_id, s.period, SUM(s.stake) AS stake, COUNT(DISTINCT s.user_id) AS players, COUNT(DISTINCT s.d) AS days,
    ANY_VALUE(i.b_in) AS b_in, ANY_VALUE(i.c_bought) AS c_bought
  FROM per_st s JOIN (SELECT album_id, period, SUM(amount) AS b_in, SUM(IF(is_purchase, amount, 0)) AS c_bought FROM per_in GROUP BY 1,2) i USING (album_id, period)
  GROUP BY 1,2
),
src AS (
  SELECT album_id, period, grp11919 AS src, SUM(amount) AS won, SUM(IF(is_purchase, amount, 0)) AS bought
  FROM per_in GROUP BY 1,2,3
)
SELECT s.album_id, s.period, s.src, ROUND(s.won) AS won_rolls, ROUND(s.bought) AS bought_rolls,
  ROUND(100 * s.won / t.b_in, 1) AS pct_of_in,
  ROUND(100 * (s.won - s.bought) / t.stake, 1) AS payout_points,
  ROUND(100 * (t.b_in - t.c_bought) / t.stake, 1) AS payout_pct_total,
  t.players, t.days
FROM src s JOIN tot t USING (album_id, period)
WHERE s.won >= 0.01 * t.b_in OR s.src = 'Album'
ORDER BY 1,2, won_rolls DESC
;
