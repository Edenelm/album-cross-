-- 2026-10-27 (Eden): Domino 19 vs 20 for the slides 'Share of Active Payers Who Bought a New Golden, per Day, Last 10 Days' and
-- '% Of All PU Get Wild / Joker Last 7 Days Before Close' (both showed album 20 only). Domino only, standard-population payers (as topic 6 / closing_week_pct_payers_2026-10-24.sql).
-- Per album and day d = -10..-1 before close: % of standard payers active that day who got a NEW Golden / Royal that day, split bought / Kiosk (GoldenKiosk, MagicalKiosk = Market) / other gameplay;
-- and % of ALL standard payers who got a new sticker with a Joker that day, bought / gameplay. Paid rule = validated Domino campaign rule (Eden: bought with money = bought, else gameplay, Market included).
WITH alb AS (
  SELECT 19 AS album_id, DATE '2026-07-06' AS a_start, DATE '2026-08-24' AS a_end UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'),
ud AS (
  SELECT u.album_id, u.user_id, u.date_dim, a.a_end, IFNULL(u.login_ratio,-1) AS lr, IFNULL(u.user_album_count,1) AS uac,
    IFNULL(u.special_user_flag,FALSE) AS excl, IFNULL(u.album_spent_today,0) AS spend, IFNULL(u.active_flag,FALSE) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` u JOIN alb a ON a.album_id = u.album_id AND u.date_dim BETWEEN a.a_start AND a.a_end
  WHERE u.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND u.album_id IN (19, 20)),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
pay AS (
  SELECT a.album_id, a.user_id FROM ud a GROUP BY a.album_id, a.user_id, a.a_end
  HAVING MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(a.a_end, INTERVAL 1 DAY)
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
    AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0),
pay2 AS (SELECT p.album_id, p.user_id FROM pay p WHERE p.user_id NOT IN (SELECT user_id FROM bad)),
npay AS (SELECT album_id, COUNT(*) AS payers FROM pay2 GROUP BY 1),
ap AS (SELECT u.album_id, DATE_DIFF(u.date_dim, u.a_end, DAY) AS d, u.user_id FROM ud u JOIN pay2 USING (album_id, user_id)
       WHERE u.act AND DATE_DIFF(u.date_dim, u.a_end, DAY) BETWEEN -10 AND -1),
st AS (
  SELECT s.album_id, s.user_id, LOWER(s.sticker_type) AS t, DATE_DIFF(s.sticker_collected_min_date, a.a_end, DAY) AS d,
    IFNULL(s.collected_by_joker_flag, FALSE) AS joker,
    CASE WHEN (IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Offer%'
               AND NOT REGEXP_CONTAINS(IFNULL(s.new_sticker_mtx_campaign_name, ''), r'SeasonPass|DreamPass|Info|ecn_Rewa'))
           OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Store%'
           OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%ActivePassToGetJoker%'
           OR s.new_sticker_source = 'purchase' OR s.new_sticker_source LIKE '1+%' THEN 'bought'
         WHEN LOWER(IFNULL(s.new_sticker_mtx_campaign_name, '')) LIKE '%kiosk%' THEN 'kiosk'
         ELSE 'gameplay' END AS src
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN alb a USING (album_id) JOIN pay2 p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND s.album_id IN (19, 20) AND s.user_collected_sticker_flag
    AND DATE_DIFF(s.sticker_collected_min_date, a.a_end, DAY) BETWEEN -10 AND -1),
rare AS (SELECT album_id, d, user_id, t, src FROM st WHERE t IN ('golden', 'royal') GROUP BY 1,2,3,4,5),
act AS (SELECT album_id, d, COUNT(*) AS active_payers FROM ap GROUP BY 1, 2),
rare_n AS (
  SELECT r.album_id, r.d,
    COUNT(DISTINCT IF(t='golden' AND src='bought', r.user_id, NULL)) AS g_bought, COUNT(DISTINCT IF(t='golden' AND src='kiosk', r.user_id, NULL)) AS g_kiosk,
    COUNT(DISTINCT IF(t='golden' AND src='gameplay', r.user_id, NULL)) AS g_game,
    COUNT(DISTINCT IF(t='royal' AND src='bought', r.user_id, NULL)) AS r_bought, COUNT(DISTINCT IF(t='royal' AND src='kiosk', r.user_id, NULL)) AS r_kiosk,
    COUNT(DISTINCT IF(t='royal' AND src='gameplay', r.user_id, NULL)) AS r_game
  FROM rare r JOIN ap USING (album_id, d, user_id) GROUP BY 1, 2),
jok AS (SELECT album_id, d, COUNT(DISTINCT IF(src='bought', user_id, NULL)) AS j_bought, COUNT(DISTINCT IF(src<>'bought', user_id, NULL)) AS j_game
        FROM st WHERE joker GROUP BY 1, 2)
SELECT a.album_id, a.d, n.payers, a.active_payers,
  ROUND(100*r.g_bought/a.active_payers,1) AS g_bought, ROUND(100*r.g_kiosk/a.active_payers,1) AS g_kiosk, ROUND(100*r.g_game/a.active_payers,1) AS g_game,
  ROUND(100*r.r_bought/a.active_payers,1) AS r_bought, ROUND(100*r.r_kiosk/a.active_payers,1) AS r_kiosk, ROUND(100*r.r_game/a.active_payers,1) AS r_game,
  ROUND(100*IFNULL(j.j_bought,0)/n.payers,1) AS j_bought_pct_payers, ROUND(100*IFNULL(j.j_game,0)/n.payers,1) AS j_game_pct_payers
FROM act a JOIN npay n USING (album_id) LEFT JOIN rare_n r USING (album_id, d) LEFT JOIN jok j USING (album_id, d)
ORDER BY 1, 2
