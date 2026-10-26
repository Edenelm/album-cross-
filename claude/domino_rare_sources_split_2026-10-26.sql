-- Domino album 20: new Royals by source per album quarter, with the slide's orange "closing tools" split into
-- duplicates / paid offer / Market. Same population, quarter rule and category CASE as
-- domino-album20-royal-sources-2026-10-17.md (source of the Domino panel on deck slide rare-sources-mix).
-- Adds N new Royals and N players (players with >=1 new Royal in that quarter; pop = all players in the population).
WITH excluded AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-01' AND DATE '2026-10-16' AND suspected_cheater_flag),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start, a.album_close_date AS a_end,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-08-01' AND DATE '2026-10-16' AND a.album_id = 20
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND MIN(user_album_count) > 1
    AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
st AS (
  SELECT p.user_id, IFNULL(NULLIF(s.new_sticker_source, ''), '(null)') AS src,
    LEAST(3, CAST(FLOOR(DATE_DIFF(s.sticker_collected_min_date, p.a_start, DAY) / DATE_DIFF(p.a_end, p.a_start, DAY) * 4) AS INT64)) + 1 AS quarter
  FROM pop p JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
    ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-01' AND DATE '2026-10-16' AND s.album_id = 20
    AND LOWER(s.sticker_type) = 'royal' AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= p.a_start AND s.sticker_collected_min_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
lab AS (
  SELECT quarter, user_id, src, CASE
    WHEN src = 'pixie_reward' THEN 'Long feature'
    WHEN LOWER(src) LIKE '%momentum%' THEN 'Momentum'
    WHEN LOWER(src) LIKE '%trail%' AND LOWER(src) NOT LIKE '%tournament%' THEN 'Trail'
    WHEN src = 'days_milestone' THEN 'Daily'
    WHEN src = 'duplicates' THEN 'Orange: Dup exchange'
    WHEN src = 'Market' THEN 'Orange: Market'
    WHEN src IN ('joker','progress_offer','Missions','BuyThemAll','SeasonPass','OfferLuckyTwister','Box','mtx','1po') OR src LIKE '1+%' THEN 'Orange: Paid offer'
    WHEN src = '(null)' THEN 'Unknown' ELSE 'Other events' END AS cat
  FROM st)
SELECT quarter, cat, COUNT(*) AS n_rares, COUNT(DISTINCT user_id) AS n_players_cat,
  SUM(COUNT(*)) OVER (PARTITION BY quarter) AS n_rares_q,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY quarter), 4) AS share,
  STRING_AGG(DISTINCT IF(STARTS_WITH(cat,'Orange'), src, NULL), ',') AS orange_srcs,
  (SELECT COUNT(*) FROM pop) AS pop_players
FROM lab GROUP BY quarter, cat
UNION ALL
SELECT quarter, 'ALL', COUNT(*), COUNT(DISTINCT user_id), COUNT(*), 1, NULL, NULL FROM lab GROUP BY quarter
ORDER BY quarter, cat
