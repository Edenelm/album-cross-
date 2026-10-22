-- Topic 4 (Eden 2026-10-22): finishers by status on close-4; new stickers close-3..finish day split bought / Market (Disney only) / free. Same as follow-up 9 in topic4_last8_finish_2026-10-22.sql.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-12'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    SUM(spend) AS rev_all,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS lr,
    ARRAY_AGG(IF(date_dim < a_end, past, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS past,
    ARRAY_AGG(IF(date_dim < a_end, excl, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS excl,
    [MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 8, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 7, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 6, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 5, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 4, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 3, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 2, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 1, uniq, NULL))] AS st
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, st FROM u0
  WHERE fin_d IS NOT NULL AND last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_all > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
ent AS (
  SELECT album_id, user_id, a_end, fin_d, 144 - st[OFFSET(4)] AS m4
  FROM pop
  WHERE st[OFFSET(4)] IS NOT NULL AND 144 - st[OFFSET(4)] BETWEEN 1 AND 10
),
ks AS (
  SELECT e.album_id, e.user_id, e.m4, s.sticker_id, MIN(s.sticker_collected_min_date) AS d1,
    ARRAY_AGG((   (IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Offer%'
         AND NOT REGEXP_CONTAINS(IFNULL(s.new_sticker_mtx_campaign_name, ''), r'SeasonPass|DreamPass|Info|ecn_Rewa'))
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Store%'
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%ActivePassToGetJoker%'
     OR s.new_sticker_source = 'purchase' OR s.new_sticker_source LIKE '1+%') ORDER BY s.sticker_collected_min_ts LIMIT 1)[OFFSET(0)] AS bought,
    FALSE AS market
  FROM ent e JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = e.album_id AND s.user_id = e.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal')
  GROUP BY 1,2,3,4
),
win AS (
  SELECT k.album_id, k.user_id, k.m4, k.bought, k.market
  FROM ks k JOIN ent e USING (album_id, user_id)
  WHERE DATE_DIFF(e.a_end, k.d1, DAY) BETWEEN 0 AND 3 AND k.d1 <= e.fin_d
),
pu AS (
  SELECT e.album_id, e.user_id, e.m4, COUNT(w.user_id) AS n_new, COUNTIF(w.bought) AS n_bought,
    COUNTIF(w.market AND NOT w.bought) AS n_market, COUNTIF(NOT w.bought AND NOT w.market) AS n_free
  FROM ent e LEFT JOIN win w USING (album_id, user_id, m4)
  GROUP BY 1,2,3
)
SELECT album_id, CASE WHEN m4 <= 3 THEN '1: 1-3' WHEN m4 <= 6 THEN '2: 4-6' ELSE '3: 7-10' END AS grp,
  COUNT(*) AS finishers, ROUND(AVG(n_new), 2) AS new_per_player,
  ROUND(SUM(n_bought) / SUM(n_new), 3) AS sh_bought, ROUND(SUM(n_market) / SUM(n_new), 3) AS sh_market, ROUND(SUM(n_free) / SUM(n_new), 3) AS sh_free,
  ROUND(COUNTIF(n_bought > 0) / COUNT(*), 3) AS sh_players_any_bought,
  ROUND(COUNTIF(n_market > 0) / COUNT(*), 3) AS sh_players_any_market,
  ROUND(COUNTIF(n_bought = 0 AND n_market = 0) / COUNT(*), 3) AS sh_players_all_free
FROM pu GROUP BY 1,2 ORDER BY 1,2;
