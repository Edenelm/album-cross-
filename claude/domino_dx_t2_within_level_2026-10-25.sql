-- 2026-10-25 Domino diagnosis, topic 2: distance on close-4 WITHIN the same prior spend level, and what is missing.
-- Population: standard-population payers, albums 19/20 (same as domino_dx_close4_buckets_2026-10-25.sql).
-- Level (fixed before the outcome) = own album spend start..close-4 / album days start..close-4: <=2 / 2-5 / 5-20 / >20 $ a day.
-- State on close-4: missing total (bucket), missing goldens and royals (daily-table columns), commons = rest.
-- Gate (joker-only, from domino_dx_gate_structure_2026-10-25.sql): 20 = 2R+1G both segments; 19 easy = 2R+2G locked + G125 released on close-4; 19 hard = 2R+1G.
-- Outcomes: finished (144 by end of close day); $ a day close-3..close-1 vs before; high activity = login_ratio >= 0.8 on close-4 row.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    missing_golden_stickers_today AS mg, missing_royal_stickers_today AS mr,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, album_segment AS seg
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), spend, 0)) AS rev_pre,
    COUNTIF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY)) AS days_pre,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 3 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY), spend, 0)) AS rev_post,
    COUNTIF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 3 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS days_post,
    ARRAY_AGG(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), STRUCT(uniq, mg, mr, lr), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS c4,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    ARRAY_AGG(seg IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg0
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, alb_rev, rev_pre, days_pre, rev_post, days_post, uniq_end >= 144 AS fin,
    144 - c4.uniq AS miss, c4.mg AS mg, c4.mr AS mr, c4.lr >= 0.8 AS hi_act,
    SAFE_DIVIDE(rev_pre, days_pre) AS pd,
    CASE WHEN LOWER(seg0) LIKE '%easy%' THEN 'easy' WHEN LOWER(seg0) LIKE '%hard%' THEN 'hard' ELSE 'other' END AS seg
  FROM u0
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad)
),
b AS (
  SELECT *,
    CASE WHEN miss <= 0 THEN '0' WHEN miss <= 2 THEN '1-2' WHEN miss = 3 THEN '3' WHEN miss <= 5 THEN '4-5' WHEN miss <= 10 THEN '6-10' ELSE '11+' END AS bucket,
    CASE WHEN pd <= 2 THEN '1_le2' WHEN pd <= 5 THEN '2_2-5' WHEN pd <= 20 THEN '3_5-20' ELSE '4_20+' END AS lvl,
    IF(album_id = 19, 17644426, 16269671) AS game_rev
  FROM pop WHERE seg != 'other' AND miss > 0
)
SELECT album_id, seg, lvl, bucket, COUNT(*) AS payers,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, seg, lvl), 3) AS sh_lvl_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(game_rev), 4) AS sh_game_rev,
  ROUND(COUNTIF(fin) / COUNT(*), 3) AS fin_rate,
  ROUND(AVG(pd), 2) AS pd_pre,
  ROUND(SAFE_DIVIDE(SUM(rev_post) / NULLIF(SUM(days_post),0), SUM(rev_pre) / SUM(days_pre)), 2) AS lift,
  ROUND(AVG(IF(hi_act,1,0)), 2) AS sh_hi_act,
  ROUND(AVG(mr), 1) AS avg_mr, ROUND(AVG(mg), 1) AS avg_mg, ROUND(AVG(miss - IFNULL(mg,0) - IFNULL(mr,0)), 1) AS avg_mc
FROM b GROUP BY 1,2,3,4 ORDER BY 1,2,3,4
