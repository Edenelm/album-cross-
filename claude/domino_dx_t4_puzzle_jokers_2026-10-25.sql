-- 2026-10-25 Domino diagnosis, topic 4: how the end-of-album puzzle Jokers are obtained.
-- Q1: per album (17/18/19/20), Joker-filled NEW set stickers whose first-collection campaign is a puzzle campaign:
--     campaign name, dates, players, stickers, and players with 1 vs 2+ such fills (= used 1 or 2 puzzle Jokers on new stickers).
-- Note: only Jokers USED on a new sticker are visible here; a Joker received and not used (or used on nothing new) is not.
WITH s AS (
  SELECT album_id, user_id,
    REGEXP_EXTRACT(LOWER(new_sticker_mtx_campaign_name), r'^([^|]+)') AS camp,
    sticker_collected_min_date AS dt, LOWER(sticker_type) AS t
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers`
  WHERE sticker_collected_min_date BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND album_id IN (17,18,19,20)
    AND user_collected_sticker_flag AND IFNULL(collected_by_joker_flag, FALSE)
    AND LOWER(new_sticker_mtx_campaign_name) LIKE '%puzzle%'
),
u AS (SELECT album_id, camp, user_id, COUNT(*) AS n, MIN(dt) AS d0, MAX(dt) AS d1 FROM s GROUP BY 1,2,3)
SELECT album_id, camp, MIN(d0) AS first_d, MAX(d1) AS last_d, COUNT(*) AS players, SUM(n) AS stickers,
  COUNTIF(n = 1) AS p_1, COUNTIF(n = 2) AS p_2, COUNTIF(n >= 3) AS p_3plus
FROM u GROUP BY 1,2 HAVING players >= 100 ORDER BY 1, players DESC
;
-- Q2: tier ladder and reward of the end puzzles (core_mini_collection_tier_completed = one row per tier completion).
-- Album 20: jokerpuzzle (28.9-8.10), summerfeverpuzzle (8-11.10); album 19: puzzle blitz / puzzlemissions (12-24.8).
SELECT REGEXP_EXTRACT(LOWER(mtx_campaign_name), r'^([^|]+)') AS camp, mini_collection_current_tier AS tier,
  ANY_VALUE(mini_collection_current_tier_reward) AS reward_example, COUNT(DISTINCT mini_collection_current_tier_reward) AS n_rewards,
  APPROX_QUANTILES(mini_collection_current_tier_items, 2)[OFFSET(1)] AS items_med,
  COUNT(DISTINCT user_id) AS users, MIN(date_dim) AS d0, MAX(date_dim) AS d1
FROM `domino-dreams-dbt.prod_20_core.core_mini_collection_tier_completed`
WHERE (date_dim BETWEEN DATE '2026-09-26' AND DATE '2026-10-12' OR date_dim BETWEEN DATE '2026-08-12' AND DATE '2026-08-24')
  AND REGEXP_CONTAINS(LOWER(mtx_campaign_name), r'jokerpuzzle|summerfever|puzzle ?blitz|puzzlemissions')
GROUP BY 1,2 ORDER BY 1,2
;
-- Q3: Album 18 JokerPuzzle reward ladder (proxy for design; core table ends 2026-07-07) + album 20 JokerPuzzle tier funnel (event 105537).
-- (query as run, see doc)
;
-- Q4: Album 20, standard population (ALL players). Who got the SummerFever puzzle Jokers (used on a new sticker), and what happened.
-- State fixed before SummerFever (opened 8.10 = close-4): missing on 7.10 (close-5), spend level = $/album day to 7.10, payer before 8.10.
-- sf = number of SummerFever Joker fills (0/1/2+); jp = used a JokerPuzzle Joker (28.9-8.10).
-- Outcomes: finished (144 by end of 12.10); $/day 8-11.10 vs $/day to 7.10; paid Joker fills 8-12.10; SF fill was the 144th sticker.
WITH ud AS (
  SELECT user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
u0 AS (
  SELECT user_id, MAX(uniq) AS uniq_end,
    MAX(IF(date_dim <= DATE '2026-10-07', uniq, NULL)) AS uniq_c5,
    SUM(IF(date_dim <= DATE '2026-10-07', spend, 0)) AS rev_pre, COUNTIF(date_dim <= DATE '2026-10-07') AS d_pre,
    SUM(IF(date_dim BETWEEN DATE '2026-10-08' AND DATE '2026-10-11', spend, 0)) AS rev_sf, COUNTIF(date_dim BETWEEN DATE '2026-10-08' AND DATE '2026-10-11') AS d_sf,
    SUM(IF(date_dim < DATE '2026-10-12', spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
    MAX(IF(date_dim < DATE '2026-10-12', date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < DATE '2026-10-12', STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1
),
u1 AS (SELECT user_id, uniq_end, uniq_c5, rev_pre, d_pre, rev_sf, d_sf, alb_rev, rev_all, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT * FROM u1
  WHERE last_d = DATE '2026-10-11' AND past AND NOT excl AND lr >= 0.5 AND user_id NOT IN (SELECT user_id FROM bad)
),
st AS (
  SELECT user_id,
    COUNTIF(IFNULL(collected_by_joker_flag,FALSE) AND LOWER(new_sticker_mtx_campaign_name) LIKE 'summerfeverpuzzle%') AS sf,
    COUNTIF(IFNULL(collected_by_joker_flag,FALSE) AND LOWER(new_sticker_mtx_campaign_name) LIKE 'jokerpuzzle%') AS jp,
    COUNTIF(sticker_collected_min_date >= DATE '2026-10-08' AND (
      (LOWER(new_sticker_mtx_campaign_name) LIKE '%t_offer%' AND NOT REGEXP_CONTAINS(LOWER(new_sticker_mtx_campaign_name), r'seasonpass|dreampass|info|ecn_rewa'))
      OR LOWER(new_sticker_mtx_campaign_name) LIKE '%t_store%' OR LOWER(new_sticker_mtx_campaign_name) LIKE '%activepasstogetjoker%'
      OR LOWER(IFNULL(new_sticker_source,'')) = 'purchase' OR LOWER(IFNULL(new_sticker_source,'')) LIKE '1+%')) AS paid_fills_end,
    ARRAY_AGG(LOWER(IFNULL(new_sticker_mtx_campaign_name,'')) ORDER BY sticker_collected_min_ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS last_camp
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers`
  WHERE sticker_collected_min_date BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20
    AND user_collected_sticker_flag AND LOWER(sticker_type) IN ('common','golden','royal')
  GROUP BY 1
),
j AS (
  SELECT p.*, IFNULL(s.sf,0) AS sf, IFNULL(s.jp,0) > 0 AS jp, IFNULL(s.paid_fills_end,0) AS paid_end,
    p.uniq_end >= 144 AND s.last_camp LIKE 'summerfeverpuzzle%' AS fin_by_sf,
    144 - p.uniq_c5 AS miss5, SAFE_DIVIDE(p.rev_pre, p.d_pre) AS pd
  FROM pop p LEFT JOIN st s USING (user_id)
)
SELECT
  CASE WHEN sf = 0 THEN '0' WHEN sf = 1 THEN '1' ELSE '2+' END AS sf_jokers,
  CASE WHEN rev_pre = 0 THEN '0_nonpayer_before' WHEN pd <= 2 THEN '1_le2' WHEN pd <= 5 THEN '2_2-5' WHEN pd <= 20 THEN '3_5-20' ELSE '4_20+' END AS lvl,
  COUNT(*) AS players, ROUND(SUM(alb_rev) / 16269671, 4) AS sh_game_rev,
  ROUND(AVG(IF(miss5 <= 3, 1, 0)), 3) AS sh_le3_on_c5, ROUND(AVG(miss5), 1) AS avg_miss_c5,
  ROUND(AVG(IF(jp,1,0)), 3) AS sh_jokerpuzzle,
  ROUND(AVG(IF(uniq_end >= 144,1,0)), 3) AS fin_rate, ROUND(AVG(IF(fin_by_sf,1,0)), 3) AS sh_last_sticker_sf,
  ROUND(SUM(rev_pre) / SUM(d_pre), 2) AS usd_day_pre, ROUND(SUM(rev_sf) / NULLIF(SUM(d_sf),0), 2) AS usd_day_sf,
  ROUND(AVG(IF(rev_sf > 0,1,0)), 3) AS sh_paid_8_11, ROUND(AVG(IF(paid_end > 0,1,0)), 3) AS sh_paid_joker_fill_end
FROM j GROUP BY 1,2 ORDER BY 1,2
