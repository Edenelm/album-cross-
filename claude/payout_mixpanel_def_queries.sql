-- Daily payout by album end status, by the exact Mixpanel definitions (Eden 2026-10-20). NOT RUN YET.
-- Results: claude/payout-mixpanel-def-2026-10-20.md (after the run)
-- Population: standard population payers (paid on any album day incl. close day); end status at the END of the close day:
--   a_finished (144) / b_miss1 / c_miss2_3 / d_miss4plus. Album revenue = album-table spend start..close-1; rev_share = group's share
--   of the standard population's album revenue. Periods: mid album = close-18..close-5 (pooled), then each day close-3..close+7.
-- Payout = group sums per day (sum of numerator ÷ sum of denominator over all players in the group), as Mixpanel does.
-- Close dates (curated): Dice 61 = 2026-07-27, 63 = 2026-09-07; Domino 19 = 2026-08-24, 20 = 2026-10-12;
--   Disney 14 = 2026-08-24, 15 = 2026-10-05.
-- Staging tables marked [STG]: approved by Eden 2026-10-20; columns checked with describe_table.
-- Known gaps vs Mixpanel: Dice stg_rolls_in_vw has no purchase_sku (one 9113 rule: Bundle SKU + Store source is skipped);
--   Disney mp_coins_in_vw has no MTX campaign name, so the 'not offer / not store' filter on C cannot be applied.

-- ===== DICE 61/63 (dice-dreams-dbt) — Mixpanel board 10105792, tile "Payout" (bookmark 80568688) =====
-- Payout % = (B − C) ÷ A × 100
--   A = rolls staked: bet_mult + prime_cost on `roll` (custom property 5891206), bet_mult in the tile's 22 values —
--       exact, from 10_staging.stg_roll_vw.
--   B = `rolls in` amount 1..750,000 where "Rolls In - Source (Grouped)" (11919) is NOT RV / Roll Timer / Daily Gift & Anti-Churn /
--       Invite Friends / Deep Links / Pending Reward / DDJ. 11919 ported in full below (first matching rule wins, as in IFS).
--   C = `rolls in` amount 1..750,000 where "Source (Purchase Complete)" (9113) ≠ Others = the rolls that came from a purchase.
--       9113 returns "Others" only when no rule matches, so C = OR of all its rules (ported below; rules that can never match in
--       Mixpanel — an upper-case pattern on LOWER(...) — are left out, they change nothing).
--   Filter: players in cohort "had roll balance greater then 1.2M" (5834170) left out = roll balance above 1.2M on any day in the window.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop0 p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2
),
pop AS (
  SELECT p.album_id, p.user_id, p.a_end, p.alb_rev,
    CASE WHEN IFNULL(s.n_uniq,0) >= 144 THEN 'a_finished' WHEN 144 - IFNULL(s.n_uniq,0) = 1 THEN 'b_miss1'
         WHEN 144 - IFNULL(s.n_uniq,0) <= 3 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp
  FROM pop0 p LEFT JOIN st s USING (album_id, user_id) WHERE p.rev_c > 0
),
g AS (
  SELECT album_id, grp, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS player_share,
    ROUND(SUM(alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
  FROM pop JOIN (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1) t USING (album_id) GROUP BY 1,2
),
ro AS (  -- the 1.2M balance cohort, curated
  SELECT user_id, date_dim AS d, IFNULL(rolls_max,0) AS bal_max
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
  WHERE date_dim BETWEEN DATE '2026-07-09' AND DATE '2026-08-03' OR date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-09-14'
),
bigbal AS (SELECT DISTINCT user_id FROM ro WHERE bal_max > 1200000),
rl AS (  -- [STG] A = stake per player-day
  SELECT user_id, pdate AS d, SUM(bet_mult + IFNULL(prime_cost, 0)) AS stake
  FROM `dice-dreams-dbt.10_staging.stg_roll_vw`
  WHERE (pdate BETWEEN DATE '2026-07-09' AND DATE '2026-08-03' OR pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-14')
    AND bet_mult IN (1,2,3,5,8,10,25,50,100,200,250,400,500,800,1000,1500,2000,2500,4000,5000,6000,10000)
  GROUP BY 1,2
),
ri AS (  -- [STG] rolls in events with the Mixpanel properties
  SELECT user_id, pdate AS d, amount,
    IFNULL(source,'') AS a, IFNULL(subsource,'') AS sub, IFNULL(campaign_name,'') AS cmp, IFNULL(reward_syntax_final,'') AS rsf,
    IFNULL(event_name,'') AS evn, IFNULL(subsource2,'') AS sub2, IFNULL(CAST(campaign_id AS STRING),'') AS cid,
    IFNULL(placement,'') AS plc, '' AS sku  -- purchase_sku not in the view
  FROM `dice-dreams-dbt.10_staging.stg_rolls_in_vw`
  WHERE (pdate BETWEEN DATE '2026-07-09' AND DATE '2026-08-03' OR pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-14')
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
    SUM(IF(is_purchase_9113, amount, 0)) AS c_bought
  FROM ri_g GROUP BY 1,2
),
x AS (
  SELECT p.album_id, p.grp, DATE_DIFF(r.d, p.a_end, DAY) AS dk, r.stake, IFNULL(i.b_in,0) AS b_in, IFNULL(i.c_bought,0) AS c_bought
  FROM pop p JOIN rl r ON r.user_id = p.user_id AND r.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
  LEFT JOIN rin i ON i.user_id = p.user_id AND i.d = r.d
  WHERE p.user_id NOT IN (SELECT user_id FROM bigbal)
),
per AS (
  SELECT album_id, grp, IF(dk BETWEEN -18 AND -5, 'mid', CAST(dk AS STRING)) AS period,
    ROUND(100 * SAFE_DIVIDE(SUM(b_in) - SUM(c_bought), SUM(stake)), 1) AS payout_pct
  FROM x WHERE dk BETWEEN -18 AND -5 OR dk BETWEEN -3 AND 7 GROUP BY 1,2,3
)
SELECT g.album_id, g.grp, g.n, g.player_share, g.rev_share,
  STRING_AGG(CONCAT(per.period, ':', CAST(per.payout_pct AS STRING)), ' ' ORDER BY IF(per.period = 'mid', -99, CAST(per.period AS INT64))) AS payout_by_period
FROM g JOIN per USING (album_id, grp) GROUP BY 1,2,3,4,5 ORDER BY 1,2
;

-- ===== DOMINO 19/20 (domino-dreams-dbt) — Mixpanel "Total Game Payout" (report 88122971, board 6965999) =====
-- Payout = (A + B) ÷ (C + D), all in "Amount in Allowance" (67276) = COALESCE(amount, coins) ÷ coins_allowance
--   A = `coins in` from the 81 gameplay sources listed in the report; B = `coins in` source 'level completed'
--   C = `coins out` source 'level start'; D = `coins out` source in ('wild','undo','extra tiles')
--   Global filters: Amount in Allowance 0..1,000 on every event; Excluded User false (= special player / deactivated → our
--   special_user_flag + suspected_cheater_flag exclusion); country not Israel / Romania; "Excluded Events" only covers March–April 2023
--   → no effect here.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-19' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (
  SELECT album_id, user_id, a_end, uniq_end, alb_rev, rev_c FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN 144 - uniq_end = 1 THEN 'b_miss1'
         WHEN 144 - uniq_end <= 3 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp
  FROM pop0 WHERE rev_c > 0
),
g AS (
  SELECT album_id, grp, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS player_share,
    ROUND(SUM(alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
  FROM pop JOIN (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1) t USING (album_id) GROUP BY 1,2
),
ev AS (  -- [STG] coins in + coins out events
  SELECT user_id, pdate AS d, 'in' AS dir, source, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)) AS units, mp_country_code
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-19'
  UNION ALL
  SELECT user_id, pdate, 'out', source, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)), mp_country_code
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-19'
),
day AS (
  SELECT user_id, d,
    SUM(IF(dir = 'in' AND source IN ('level completed',
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
      'pixel_path_tier_completed','sets_mania','sprint','sweet-treats','trail - tile reward'), units, 0)) AS won,
    SUM(IF(dir = 'out' AND source IN ('level start','wild','undo','extra tiles'), units, 0)) AS spent
  FROM ev WHERE units BETWEEN 0 AND 1000 AND IFNULL(mp_country_code,'') NOT IN ('IL','RO')
  GROUP BY 1,2
),
x AS (
  SELECT p.album_id, p.grp, DATE_DIFF(dy.d, p.a_end, DAY) AS dk, dy.won, dy.spent
  FROM pop p JOIN day dy ON dy.user_id = p.user_id AND dy.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
),
per AS (
  SELECT album_id, grp, IF(dk BETWEEN -18 AND -5, 'mid', CAST(dk AS STRING)) AS period,
    ROUND(100 * SAFE_DIVIDE(SUM(won), SUM(spent)), 1) AS payout_pct
  FROM x WHERE dk BETWEEN -18 AND -5 OR dk BETWEEN -3 AND 7 GROUP BY 1,2,3
)
SELECT g.album_id, g.grp, g.n, g.player_share, g.rev_share,
  STRING_AGG(CONCAT(per.period, ':', CAST(per.payout_pct AS STRING)), ' ' ORDER BY IF(per.period = 'mid', -99, CAST(per.period AS INT64))) AS payout_by_period
FROM g JOIN per USING (album_id, grp) GROUP BY 1,2,3,4,5 ORDER BY 1,2
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507) — Mixpanel "Total RTP" (Eden's link; same as saved report 91373288 without
--       Level ID ≥ 100 and without the T122 breakdown) =====
-- RTP = (C − B) ÷ A, all in "Coins in Allowance" (5560156) = amount ÷ coins_allowance on coins in / coins out
--   A = `coins out` source 'level start'; B = `coins out` source in ('extra tiles','undo','wild','trade')
--   C = `coins in` from the 63 gameplay sources in the report, MTX campaign name not containing 'offer' / 'store'
--   Every event: Coins in Allowance 0..1,000 and coins_balance_in_allowance 0..5,000.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (
  SELECT album_id, user_id, a_end, uniq_end, alb_rev, rev_c FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN 144 - uniq_end = 1 THEN 'b_miss1'
         WHEN 144 - uniq_end <= 3 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp
  FROM pop0 WHERE rev_c > 0
),
g AS (
  SELECT album_id, grp, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS player_share,
    ROUND(SUM(alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
  FROM pop JOIN (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1) t USING (album_id) GROUP BY 1,2
),
ev AS (  -- [STG] coins in + coins out events (Disney Mixpanel views); no MTX campaign name column → cmp = ''
  SELECT user_id, pdate AS d, 'in' AS dir, IFNULL(source,'') AS source, SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) AS units,
    coins_balance_in_allowance AS bal, '' AS cmp
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-12'
  UNION ALL
  SELECT user_id, pdate, 'out', IFNULL(source,''), SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)), coins_balance_in_allowance, ''
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-12'
),
day AS (
  SELECT user_id, d,
    SUM(IF(dir = 'out' AND source = 'level start', units, 0)) AS a_stake,
    SUM(IF(dir = 'out' AND source IN ('extra tiles','undo','wild','trade'), units, 0)) AS b_boost,
    SUM(IF(dir = 'in' AND NOT REGEXP_CONTAINS(LOWER(cmp), r'offer|store') AND source IN (
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
      'lightyear-trail','welcomeback','merge milestone reached','merge event completed','disney_moments'), units, 0)) AS c_won
  FROM ev WHERE units BETWEEN 0 AND 1000 AND bal BETWEEN 0 AND 5000
  GROUP BY 1,2
),
x AS (
  SELECT p.album_id, p.grp, DATE_DIFF(dy.d, p.a_end, DAY) AS dk, dy.a_stake, dy.b_boost, dy.c_won
  FROM pop p JOIN day dy ON dy.user_id = p.user_id AND dy.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
),
per AS (
  SELECT album_id, grp, IF(dk BETWEEN -18 AND -5, 'mid', CAST(dk AS STRING)) AS period,
    ROUND(100 * SAFE_DIVIDE(SUM(c_won) - SUM(b_boost), SUM(a_stake)), 1) AS rtp_pct
  FROM x WHERE dk BETWEEN -18 AND -5 OR dk BETWEEN -3 AND 7 GROUP BY 1,2,3
)
SELECT g.album_id, g.grp, g.n, g.player_share, g.rev_share,
  STRING_AGG(CONCAT(per.period, ':', CAST(per.rtp_pct AS STRING)), ' ' ORDER BY IF(per.period = 'mid', -99, CAST(per.period AS INT64))) AS rtp_by_period
FROM g JOIN per USING (album_id, grp) GROUP BY 1,2,3,4,5 ORDER BY 1,2
;

-- ===================== DIAGNOSTICS (Eden 2026-10-20: daily axis, peak vs after, why Disney −73..−85%, biases) =====================
-- Same population, groups and Mixpanel filters as above. Per group × day: players who played (staked), stake / wins / boosters per
-- playing player (in allowance units or rolls), the album-prize part of wins, payout with and without album prizes, how much the
-- Mixpanel filters drop (Disney balance 0..5,000; Domino amount 0..1,000; Dice 1.2M-balance cohort), median end-of-day balance.

-- ===== DISNEY diagnostic =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (
  SELECT album_id, user_id, a_end, uniq_end, alb_rev, rev_c FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN 144 - uniq_end = 1 THEN 'b_miss1'
         WHEN 144 - uniq_end <= 3 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp
  FROM pop0 WHERE rev_c > 0
),
g AS (
  SELECT album_id, grp, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS player_share,
    ROUND(SUM(alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
  FROM pop JOIN (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1) t USING (album_id) GROUP BY 1,2
),
ev AS (
  SELECT user_id, pdate AS d, timestamp AS ts, 'in' AS dir, IFNULL(source,'') AS source, SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) AS units,
    coins_balance_in_allowance AS bal
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-12'
  UNION ALL
  SELECT user_id, pdate, timestamp, 'out', IFNULL(source,''), SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)), coins_balance_in_allowance
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-12'
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
    SUM(IF(dir = 'in' AND c_src, units, 0)) AS c_all,
    ARRAY_AGG(bal IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_end
  FROM e2 GROUP BY 1,2
),
x AS (
  SELECT p.album_id, p.grp, DATE_DIFF(dy.d, p.a_end, DAY) AS dk, dy.a_all, dy.a_stake, dy.b_boost, dy.c_won, dy.c_album, dy.c_all, dy.bal_end
  FROM pop p JOIN day dy ON dy.user_id = p.user_id AND dy.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
)
SELECT album_id, grp, IF(dk BETWEEN -18 AND -5, 'mid', CAST(dk AS STRING)) AS period,
  ROUND(COUNTIF(a_all > 0) / IF(MIN(dk) <= -5, 14, 1)) AS players_playing,
  ROUND(SUM(a_stake) / COUNTIF(a_all > 0), 1) AS a_stake_pp,
  ROUND(SUM(b_boost) / COUNTIF(a_all > 0), 1) AS b_boost_pp,
  ROUND(SUM(c_won) / COUNTIF(a_all > 0), 1) AS c_won_pp,
  ROUND(SUM(c_album) / COUNTIF(a_all > 0), 1) AS c_album_pp,
  ROUND(100 * SAFE_DIVIDE(SUM(c_won) - SUM(b_boost), SUM(a_stake)), 1) AS rtp_pct,
  ROUND(100 * SAFE_DIVIDE(SUM(c_won - c_album) - SUM(b_boost), SUM(a_stake)), 1) AS rtp_no_album_pct,
  ROUND(100 * (1 - SAFE_DIVIDE(SUM(a_stake), SUM(a_all))), 1) AS stake_dropped_pct,
  ROUND(100 * (1 - SAFE_DIVIDE(SUM(c_won), SUM(c_all))), 1) AS won_dropped_pct,
  APPROX_QUANTILES(bal_end, 2)[OFFSET(1)] AS bal_median
FROM x WHERE dk BETWEEN -18 AND -5 OR dk BETWEEN -3 AND 7
GROUP BY 1,2,3 ORDER BY 1,2, IF(period = 'mid', -99, CAST(period AS INT64))
;

-- ===== DOMINO diagnostic =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-19' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (
  SELECT album_id, user_id, a_end, uniq_end, alb_rev, rev_c FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN 144 - uniq_end = 1 THEN 'b_miss1'
         WHEN 144 - uniq_end <= 3 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp
  FROM pop0 WHERE rev_c > 0
),
g AS (
  SELECT album_id, grp, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS player_share,
    ROUND(SUM(alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
  FROM pop JOIN (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1) t USING (album_id) GROUP BY 1,2
),
ev AS (
  SELECT user_id, pdate AS d, timestamp AS ts, 'in' AS dir, source, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)) AS units, mp_country_code, coins_balance_in_allowance AS bal
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-19'
  UNION ALL
  SELECT user_id, pdate, timestamp, 'out', source, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)), mp_country_code, coins_balance_in_allowance
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-19'
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
    SUM(IF(dir = 'out' AND source = 'level start' AND ctry, units, 0)) AS a_all,
    SUM(IF(dir = 'out' AND source IN ('level start','wild','undo','extra tiles') AND ok AND ctry, units, 0)) AS spent,
    SUM(IF(dir = 'out' AND source = 'level start' AND ok AND ctry, units, 0)) AS stake,
    SUM(IF(dir = 'in' AND w_src AND ok AND ctry, units, 0)) AS won,
    SUM(IF(dir = 'in' AND w_src AND alb_src AND ok AND ctry, units, 0)) AS won_album,
    SUM(IF(dir = 'in' AND source = 'level completed' AND ok AND ctry, units, 0)) AS won_level,
    SUM(IF(dir = 'in' AND w_src AND ctry, units, 0)) AS won_all,
    ARRAY_AGG(bal IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_end
  FROM e2 GROUP BY 1,2
),
x AS (
  SELECT p.album_id, p.grp, DATE_DIFF(dy.d, p.a_end, DAY) AS dk, dy.a_all, dy.spent, dy.stake, dy.won, dy.won_album, dy.won_level, dy.won_all, dy.bal_end
  FROM pop p JOIN day dy ON dy.user_id = p.user_id AND dy.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
)
SELECT album_id, grp, IF(dk BETWEEN -18 AND -5, 'mid', CAST(dk AS STRING)) AS period,
  ROUND(COUNTIF(a_all > 0) / IF(MIN(dk) <= -5, 14, 1)) AS players_playing,
  ROUND(SUM(stake) / COUNTIF(a_all > 0), 1) AS stake_pp,
  ROUND(SUM(spent - stake) / COUNTIF(a_all > 0), 1) AS boosters_pp,
  ROUND(SUM(won) / COUNTIF(a_all > 0), 1) AS won_pp,
  ROUND(SUM(won_level) / COUNTIF(a_all > 0), 1) AS won_level_pp,
  ROUND(SUM(won_album) / COUNTIF(a_all > 0), 1) AS won_album_pp,
  ROUND(100 * SAFE_DIVIDE(SUM(won), SUM(spent)), 1) AS payout_pct,
  ROUND(100 * SAFE_DIVIDE(SUM(won - won_album), SUM(spent)), 1) AS payout_no_album_pct,
  ROUND(100 * (1 - SAFE_DIVIDE(SUM(won), SUM(won_all))), 1) AS won_dropped_pct,
  APPROX_QUANTILES(bal_end, 2)[OFFSET(1)] AS bal_median
FROM x WHERE dk BETWEEN -18 AND -5 OR dk BETWEEN -3 AND 7
GROUP BY 1,2,3 ORDER BY 1,2, IF(period = 'mid', -99, CAST(period AS INT64))
;

-- ===== DICE diagnostic =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop0 p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2
),
pop AS (
  SELECT p.album_id, p.user_id, p.a_end, p.alb_rev,
    CASE WHEN IFNULL(s.n_uniq,0) >= 144 THEN 'a_finished' WHEN 144 - IFNULL(s.n_uniq,0) = 1 THEN 'b_miss1'
         WHEN 144 - IFNULL(s.n_uniq,0) <= 3 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp
  FROM pop0 p LEFT JOIN st s USING (album_id, user_id) WHERE p.rev_c > 0
),
g AS (
  SELECT album_id, grp, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS player_share,
    ROUND(SUM(alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
  FROM pop JOIN (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1) t USING (album_id) GROUP BY 1,2
),
ro AS (  -- the 1.2M balance cohort, curated
  SELECT user_id, date_dim AS d, IFNULL(rolls_max,0) AS bal_max
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
  WHERE date_dim BETWEEN DATE '2026-07-09' AND DATE '2026-08-03' OR date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-09-14'
),
bigbal AS (SELECT DISTINCT user_id FROM ro WHERE bal_max > 1200000),
rl AS (  -- [STG] A = stake per player-day
  SELECT user_id, pdate AS d, SUM(bet_mult + IFNULL(prime_cost, 0)) AS stake, ARRAY_AGG(rolls_balance IGNORE NULLS ORDER BY timestamp DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_end
  FROM `dice-dreams-dbt.10_staging.stg_roll_vw`
  WHERE (pdate BETWEEN DATE '2026-07-09' AND DATE '2026-08-03' OR pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-14')
    AND bet_mult IN (1,2,3,5,8,10,25,50,100,200,250,400,500,800,1000,1500,2000,2500,4000,5000,6000,10000)
  GROUP BY 1,2
),
ri AS (  -- [STG] rolls in events with the Mixpanel properties
  SELECT user_id, pdate AS d, amount,
    IFNULL(source,'') AS a, IFNULL(subsource,'') AS sub, IFNULL(campaign_name,'') AS cmp, IFNULL(reward_syntax_final,'') AS rsf,
    IFNULL(event_name,'') AS evn, IFNULL(subsource2,'') AS sub2, IFNULL(CAST(campaign_id AS STRING),'') AS cid,
    IFNULL(placement,'') AS plc, '' AS sku  -- purchase_sku not in the view
  FROM `dice-dreams-dbt.10_staging.stg_rolls_in_vw`
  WHERE (pdate BETWEEN DATE '2026-07-09' AND DATE '2026-08-03' OR pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-14')
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
  SELECT p.album_id, p.grp, DATE_DIFF(r.d, p.a_end, DAY) AS dk, r.stake, r.bal_end, IFNULL(i.b_in,0) AS b_in, IFNULL(i.c_bought,0) AS c_bought,
    IFNULL(i.b_album,0) AS b_album, p.user_id IN (SELECT user_id FROM bigbal) AS big
  FROM pop p JOIN rl r ON r.user_id = p.user_id AND r.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
  LEFT JOIN rin i ON i.user_id = p.user_id AND i.d = r.d
)
SELECT album_id, grp, IF(dk BETWEEN -18 AND -5, 'mid', CAST(dk AS STRING)) AS period,
  ROUND(COUNTIF(NOT big) / IF(MIN(dk) <= -5, 14, 1)) AS players_playing,
  ROUND(COUNTIF(big) / IF(MIN(dk) <= -5, 14, 1)) AS players_big_left_out,
  ROUND(SUM(IF(NOT big, stake, 0)) / COUNTIF(NOT big)) AS stake_pp,
  ROUND(SUM(IF(NOT big, b_in - c_bought, 0)) / COUNTIF(NOT big)) AS free_in_pp,
  ROUND(SUM(IF(NOT big, b_album, 0)) / COUNTIF(NOT big)) AS album_in_pp,
  ROUND(SUM(IF(NOT big, c_bought, 0)) / COUNTIF(NOT big)) AS bought_pp,
  ROUND(100 * SAFE_DIVIDE(SUM(IF(NOT big, b_in - c_bought, 0)), SUM(IF(NOT big, stake, 0))), 1) AS payout_pct,
  ROUND(100 * SAFE_DIVIDE(SUM(IF(NOT big, b_in - c_bought - b_album, 0)), SUM(IF(NOT big, stake, 0))), 1) AS payout_no_album_pct,
  ROUND(100 * SAFE_DIVIDE(SUM(b_in - c_bought), SUM(stake)), 1) AS payout_incl_big_pct,
  APPROX_QUANTILES(IF(NOT big, bal_end, NULL), 2)[OFFSET(1)] AS bal_median
FROM x WHERE dk BETWEEN -18 AND -5 OR dk BETWEEN -3 AND 7
GROUP BY 1,2,3 ORDER BY 1,2, IF(period = 'mid', -99, CAST(period AS INT64))
;

-- ===================== PER-PLAYER MEDIAN CHECK (Eden 2026-10-20) =====================
-- Groups finished / 1 missing / 2 missing. Per player: own no-prize payout mid album (close−18..−5) and days +1..+3; median across players.
-- Disney metric = gameplay wins (no album prizes) ÷ (level-start stake + boosters) — Eden's choice 2026-10-20 instead of Mixpanel Total RTP.

-- ===== DISNEY =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (
  SELECT album_id, user_id, a_end, uniq_end, alb_rev, rev_c FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN 144 - uniq_end = 1 THEN 'b_miss1'
         WHEN 144 - uniq_end = 2 THEN 'c_miss2' ELSE 'z_other' END AS grp
  FROM pop0 WHERE rev_c > 0
),
g AS (
  SELECT album_id, grp, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS player_share,
    ROUND(SUM(alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
  FROM pop JOIN (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1) t USING (album_id) GROUP BY 1,2
),
ev AS (
  SELECT user_id, pdate AS d, timestamp AS ts, 'in' AS dir, IFNULL(source,'') AS source, SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)) AS units,
    coins_balance_in_allowance AS bal
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-12'
  UNION ALL
  SELECT user_id, pdate, timestamp, 'out', IFNULL(source,''), SAFE_DIVIDE(amount, SAFE_CAST(coins_allowance AS FLOAT64)), coins_balance_in_allowance
  FROM `solitaire-dreams-411507.mp_raw_prod_vw.mp_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-12'
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
    SUM(IF(dir = 'in' AND c_src, units, 0)) AS c_all,
    ARRAY_AGG(bal IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_end
  FROM e2 GROUP BY 1,2
),
x AS (
  SELECT p.album_id, p.grp, p.user_id, DATE_DIFF(dy.d, p.a_end, DAY) AS dk, dy.a_all, dy.a_stake, dy.b_boost, dy.c_won, dy.c_album, dy.c_all, dy.bal_end
  FROM pop p JOIN day dy ON dy.user_id = p.user_id AND dy.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
),
pp AS (
  SELECT album_id, grp, user_id,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN -18 AND -5, c_won - c_album, 0)), SUM(IF(dk BETWEEN -18 AND -5, a_stake + b_boost, 0))) AS mid,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN 1 AND 3, c_won - c_album, 0)), SUM(IF(dk BETWEEN 1 AND 3, a_stake + b_boost, 0))) AS post
  FROM x WHERE grp <> 'z_other'
  GROUP BY 1,2,3
  HAVING SUM(IF(dk BETWEEN -18 AND -5, a_stake + b_boost, 0)) > 0 AND SUM(IF(dk BETWEEN 1 AND 3, a_stake + b_boost, 0)) > 0
)
SELECT album_id, grp, COUNT(*) AS players_both_periods,
  ROUND(100 * APPROX_QUANTILES(mid, 2)[OFFSET(1)]) AS median_mid,
  ROUND(100 * APPROX_QUANTILES(post, 2)[OFFSET(1)]) AS median_post,
  ROUND(APPROX_QUANTILES(IF(mid > 0, post / mid, NULL), 4)[OFFSET(1)], 2) AS ratio_p25,
  ROUND(APPROX_QUANTILES(IF(mid > 0, post / mid, NULL), 4)[OFFSET(2)], 2) AS ratio_median,
  ROUND(APPROX_QUANTILES(IF(mid > 0, post / mid, NULL), 4)[OFFSET(3)], 2) AS ratio_p75,
  ROUND(100 * COUNTIF(post < mid) / COUNT(*)) AS pct_players_lower
FROM pp GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DOMINO =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-19' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (
  SELECT album_id, user_id, a_end, uniq_end, alb_rev, rev_c FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN 144 - uniq_end = 1 THEN 'b_miss1'
         WHEN 144 - uniq_end = 2 THEN 'c_miss2' ELSE 'z_other' END AS grp
  FROM pop0 WHERE rev_c > 0
),
g AS (
  SELECT album_id, grp, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS player_share,
    ROUND(SUM(alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
  FROM pop JOIN (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1) t USING (album_id) GROUP BY 1,2
),
ev AS (
  SELECT user_id, pdate AS d, timestamp AS ts, 'in' AS dir, source, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)) AS units, mp_country_code, coins_balance_in_allowance AS bal
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-19'
  UNION ALL
  SELECT user_id, pdate, timestamp, 'out', source, SAFE_DIVIDE(COALESCE(amount, coins), SAFE_CAST(coins_allowance AS FLOAT64)), mp_country_code, coins_balance_in_allowance
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw`
  WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-08-31' OR pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-19'
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
    SUM(IF(dir = 'out' AND source = 'level start' AND ctry, units, 0)) AS a_all,
    SUM(IF(dir = 'out' AND source IN ('level start','wild','undo','extra tiles') AND ok AND ctry, units, 0)) AS spent,
    SUM(IF(dir = 'out' AND source = 'level start' AND ok AND ctry, units, 0)) AS stake,
    SUM(IF(dir = 'in' AND w_src AND ok AND ctry, units, 0)) AS won,
    SUM(IF(dir = 'in' AND w_src AND alb_src AND ok AND ctry, units, 0)) AS won_album,
    SUM(IF(dir = 'in' AND source = 'level completed' AND ok AND ctry, units, 0)) AS won_level,
    SUM(IF(dir = 'in' AND w_src AND ctry, units, 0)) AS won_all,
    ARRAY_AGG(bal IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_end
  FROM e2 GROUP BY 1,2
),
x AS (
  SELECT p.album_id, p.grp, p.user_id, DATE_DIFF(dy.d, p.a_end, DAY) AS dk, dy.a_all, dy.spent, dy.stake, dy.won, dy.won_album, dy.won_level, dy.won_all, dy.bal_end
  FROM pop p JOIN day dy ON dy.user_id = p.user_id AND dy.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
),
pp AS (
  SELECT album_id, grp, user_id,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN -18 AND -5, won - won_album, 0)), SUM(IF(dk BETWEEN -18 AND -5, spent, 0))) AS mid,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN 1 AND 3, won - won_album, 0)), SUM(IF(dk BETWEEN 1 AND 3, spent, 0))) AS post
  FROM x WHERE grp <> 'z_other'
  GROUP BY 1,2,3
  HAVING SUM(IF(dk BETWEEN -18 AND -5, spent, 0)) > 0 AND SUM(IF(dk BETWEEN 1 AND 3, spent, 0)) > 0
)
SELECT album_id, grp, COUNT(*) AS players_both_periods,
  ROUND(100 * APPROX_QUANTILES(mid, 2)[OFFSET(1)]) AS median_mid,
  ROUND(100 * APPROX_QUANTILES(post, 2)[OFFSET(1)]) AS median_post,
  ROUND(APPROX_QUANTILES(IF(mid > 0, post / mid, NULL), 4)[OFFSET(1)], 2) AS ratio_p25,
  ROUND(APPROX_QUANTILES(IF(mid > 0, post / mid, NULL), 4)[OFFSET(2)], 2) AS ratio_median,
  ROUND(APPROX_QUANTILES(IF(mid > 0, post / mid, NULL), 4)[OFFSET(3)], 2) AS ratio_p75,
  ROUND(100 * COUNTIF(post < mid) / COUNT(*)) AS pct_players_lower
FROM pp GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DICE =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop0 p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2
),
pop AS (
  SELECT p.album_id, p.user_id, p.a_end, p.alb_rev,
    CASE WHEN IFNULL(s.n_uniq,0) >= 144 THEN 'a_finished' WHEN 144 - IFNULL(s.n_uniq,0) = 1 THEN 'b_miss1'
         WHEN 144 - IFNULL(s.n_uniq,0) = 2 THEN 'c_miss2' ELSE 'z_other' END AS grp
  FROM pop0 p LEFT JOIN st s USING (album_id, user_id) WHERE p.rev_c > 0
),
g AS (
  SELECT album_id, grp, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS player_share,
    ROUND(SUM(alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
  FROM pop JOIN (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1) t USING (album_id) GROUP BY 1,2
),
ro AS (  -- the 1.2M balance cohort, curated
  SELECT user_id, date_dim AS d, IFNULL(rolls_max,0) AS bal_max
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
  WHERE date_dim BETWEEN DATE '2026-07-09' AND DATE '2026-08-03' OR date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-09-14'
),
bigbal AS (SELECT DISTINCT user_id FROM ro WHERE bal_max > 1200000),
rl AS (  -- [STG] A = stake per player-day
  SELECT user_id, pdate AS d, SUM(bet_mult + IFNULL(prime_cost, 0)) AS stake, ARRAY_AGG(rolls_balance IGNORE NULLS ORDER BY timestamp DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_end
  FROM `dice-dreams-dbt.10_staging.stg_roll_vw`
  WHERE (pdate BETWEEN DATE '2026-07-09' AND DATE '2026-08-03' OR pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-14')
    AND bet_mult IN (1,2,3,5,8,10,25,50,100,200,250,400,500,800,1000,1500,2000,2500,4000,5000,6000,10000)
  GROUP BY 1,2
),
ri AS (  -- [STG] rolls in events with the Mixpanel properties
  SELECT user_id, pdate AS d, amount,
    IFNULL(source,'') AS a, IFNULL(subsource,'') AS sub, IFNULL(campaign_name,'') AS cmp, IFNULL(reward_syntax_final,'') AS rsf,
    IFNULL(event_name,'') AS evn, IFNULL(subsource2,'') AS sub2, IFNULL(CAST(campaign_id AS STRING),'') AS cid,
    IFNULL(placement,'') AS plc, '' AS sku  -- purchase_sku not in the view
  FROM `dice-dreams-dbt.10_staging.stg_rolls_in_vw`
  WHERE (pdate BETWEEN DATE '2026-07-09' AND DATE '2026-08-03' OR pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-14')
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
  SELECT p.album_id, p.grp, p.user_id, DATE_DIFF(r.d, p.a_end, DAY) AS dk, r.stake, r.bal_end, IFNULL(i.b_in,0) AS b_in, IFNULL(i.c_bought,0) AS c_bought,
    IFNULL(i.b_album,0) AS b_album, p.user_id IN (SELECT user_id FROM bigbal) AS big
  FROM pop p JOIN rl r ON r.user_id = p.user_id AND r.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)
  LEFT JOIN rin i ON i.user_id = p.user_id AND i.d = r.d
),
pp AS (
  SELECT album_id, grp, user_id,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN -18 AND -5, b_in - c_bought - b_album, 0)), SUM(IF(dk BETWEEN -18 AND -5, stake, 0))) AS mid,
    SAFE_DIVIDE(SUM(IF(dk BETWEEN 1 AND 3, b_in - c_bought - b_album, 0)), SUM(IF(dk BETWEEN 1 AND 3, stake, 0))) AS post
  FROM x WHERE grp <> 'z_other' AND NOT big
  GROUP BY 1,2,3
  HAVING SUM(IF(dk BETWEEN -18 AND -5, stake, 0)) > 0 AND SUM(IF(dk BETWEEN 1 AND 3, stake, 0)) > 0
)
SELECT album_id, grp, COUNT(*) AS players_both_periods,
  ROUND(100 * APPROX_QUANTILES(mid, 2)[OFFSET(1)]) AS median_mid,
  ROUND(100 * APPROX_QUANTILES(post, 2)[OFFSET(1)]) AS median_post,
  ROUND(APPROX_QUANTILES(IF(mid > 0, post / mid, NULL), 4)[OFFSET(1)], 2) AS ratio_p25,
  ROUND(APPROX_QUANTILES(IF(mid > 0, post / mid, NULL), 4)[OFFSET(2)], 2) AS ratio_median,
  ROUND(APPROX_QUANTILES(IF(mid > 0, post / mid, NULL), 4)[OFFSET(3)], 2) AS ratio_p75,
  ROUND(100 * COUNTIF(post < mid) / COUNT(*)) AS pct_players_lower
FROM pp GROUP BY 1,2 ORDER BY 1,2
;
