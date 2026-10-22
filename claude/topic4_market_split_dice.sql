-- Topic 4 (Eden 2026-10-22): finishers by status on close-4; new stickers close-3..finish day split bought / Market (Disney only) / free. Same as follow-up 9 in topic4_last8_finish_2026-10-22.sql.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07'
  GROUP BY 1
),
stk1 AS (
  SELECT album_id, user_id, sticker_id, MIN(sticker_collected_date) AS d1
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers`
  WHERE sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (61,63)
    AND sticker_type IN ('common','golden','super') AND IFNULL(is_sticker_collected, TRUE)
  GROUP BY 1,2,3
),
stk AS (SELECT album_id, user_id, COUNT(*) AS n_uniq, MAX(d1) AS fin_d_stk FROM stk1 GROUP BY 1,2),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-05-25' AND DATE '2026-09-07'
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MIN(IF(date_dim < a_end AND uniq >= 144, date_dim, NULL)) AS fin_d_daily,
    SUM(spend) AS rev_all,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS lr,
    ARRAY_AGG(IF(date_dim < a_end, excl, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS excl,
    [MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 8, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 7, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 6, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 5, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 4, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 3, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 2, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 1, uniq, NULL))] AS st
  FROM ud GROUP BY 1,2
),
u1 AS (
  SELECT u.album_id, u.user_id, u.a_end, u.rev_all, u.last_d, u.lr, u.excl, u.st, h.first_album_seen,
    COALESCE(u.fin_d_daily, IF(k.n_uniq >= 144 AND k.fin_d_stk <= u.a_end, k.fin_d_stk, NULL)) AS fin_d
  FROM u0 u LEFT JOIN stk k USING (album_id, user_id) JOIN hist h USING (user_id)
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, st FROM u1
  WHERE fin_d IS NOT NULL AND last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND first_album_seen < album_id AND NOT excl AND lr >= 0.5 AND rev_all > 0
),
ent AS (
  SELECT album_id, user_id, a_end, fin_d, 144 - st[OFFSET(4)] AS m4
  FROM pop
  WHERE st[OFFSET(4)] IS NOT NULL AND 144 - st[OFFSET(4)] BETWEEN 1 AND 10
),
ks AS (
  SELECT e.album_id, e.user_id, e.m4, s.sticker_id, MIN(s.sticker_collected_date) AS d1,
    ARRAY_AGG(IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' ORDER BY s.sticker_collected_ts LIMIT 1)[OFFSET(0)] AS bought,
    FALSE AS market
  FROM ent e JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = e.album_id AND s.user_id = e.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE)
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
