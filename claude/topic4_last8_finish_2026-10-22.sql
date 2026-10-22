-- Topic 4 (2026-10-22, Eden): finish rate of payers who REACHED 1-3 / 4-6 / 7-10 missing at any point in the last 8 days
-- (not only the close-8 cohort). Results: claude/topic4-last8-finish-2026-10-22.md
-- Status on day k before close (k = 8..1) = unique set stickers on the latest daily row on or before close-k
--   (unique counts are lifetime, so MAX over rows <= that date carries the status forward on inactive days).
-- Band membership: the player was in the band on at least one of days 8..1. Bands overlap: a player who went 7 -> 5 -> 2
--   counts in 7-10, 4-6 and 1-3. entry_k = first day (largest k) the player was in the band; 8 = already there at close-8 or earlier.
-- Finisher = 144 unique set stickers by the END of the close day. Dice: close day from the sticker table (daily table not updated on close day).
-- Population: standard (not first album, not excluded, login ratio >= 0.5 on the last row before close, row on close-1).
--   Dice "not first album" = a row in an earlier album of user_daily_album (fixed rule, register 2026-10-21).
-- Payer = album-table spend > 0 on any album day, close day included. Revenue numerator = album-table spend start..close-1.
-- sh_game_rev = numerator / total game purchase revenue during the album (opening-facts-2026-10-20.md:
--   Dice 61 25,342,929 / 63 30,317,756; Domino 19 17,644,426 / 20 16,269,671; Disney 14 51,554,638 / 15 44,887,998).
-- Output rows: entry_k NULL = band total; band 'all_payers' = every standard-population payer.

-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(uniq) >= 144 AS fin,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    [MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 8, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 7, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 6, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 5, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 4, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 3, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 2, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 1, uniq, NULL))] AS st
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, fin, alb_rev, rev_all, last_d, l.lr AS lr, l.past AS past, l.excl AS excl, st FROM u0),
pop AS (
  SELECT album_id, user_id, fin, alb_rev, st FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_all > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
bands AS (
  SELECT p.album_id, p.user_id, p.fin, p.alb_rev,
    CASE WHEN 144 - s BETWEEN 1 AND 3 THEN '1_3' WHEN 144 - s BETWEEN 4 AND 6 THEN '4_6' WHEN 144 - s BETWEEN 7 AND 10 THEN '7_10' END AS band,
    8 - i AS k
  FROM pop p CROSS JOIN UNNEST(p.st) AS s WITH OFFSET i
  WHERE s IS NOT NULL
),
entry AS (
  SELECT album_id, user_id, band, ANY_VALUE(fin) AS fin, ANY_VALUE(alb_rev) AS alb_rev, MAX(k) AS entry_k
  FROM bands WHERE band IS NOT NULL GROUP BY 1,2,3
  UNION ALL
  SELECT album_id, user_id, 'all_payers', fin, alb_rev, NULL FROM pop
),
game AS (SELECT 19 AS album_id, 17644426.0 AS game_rev UNION ALL SELECT 20, 16269671.0)
SELECT e.album_id, e.band, e.entry_k, COUNT(*) AS players, COUNTIF(e.fin) AS finishers,
  ROUND(COUNTIF(e.fin) / COUNT(*), 4) AS fin_rate, ROUND(SUM(e.alb_rev)) AS rev,
  ROUND(SUM(e.alb_rev) / ANY_VALUE(g.game_rev), 4) AS sh_game_rev
FROM entry e JOIN game g USING (album_id)
GROUP BY ROLLUP (e.album_id, e.band, e.entry_k)
HAVING e.album_id IS NOT NULL AND e.band IS NOT NULL AND NOT (e.band = 'all_payers' AND e.entry_k IS NULL AND GROUPING(e.entry_k) = 0)
ORDER BY 1, 2, 3
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507) =====
-- Same SQL as Domino with: table solitaire-dreams-411507.bi_prod.user_daily_album; bad users = exclude_reason IS NOT NULL in
-- solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df; dates 2026-07-13..2026-10-05; album_id IN (14,15);
-- game AS (SELECT 14 AS album_id, 51554638.0 AS game_rev UNION ALL SELECT 15, 44887998.0). Ran 2026-10-22, 22.0 GB.

-- ===== DICE 61/63 (dice-dreams-dbt) =====
-- Differences: not-first-album from history (fixed rule); close-day finishers from the sticker table; exclusions = is_excluded.
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
stk AS (
  SELECT album_id, user_id, COUNT(DISTINCT sticker_id) AS n_uniq, MAX(sticker_collected_date) AS last_d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers`
  WHERE sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (61,63)
    AND sticker_type IN ('common','golden','super') AND IFNULL(is_sticker_collected, TRUE)
  GROUP BY 1,2
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(IF(date_dim < a_end, uniq, NULL)) >= 144 AS fin_prev,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
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
  SELECT u.album_id, u.user_id, u.a_end, u.alb_rev, u.rev_all, u.last_d, u.lr, u.excl, u.st,
    IFNULL(u.fin_prev, FALSE) OR IFNULL(k.n_uniq >= 144 AND k.last_d <= u.a_end, FALSE) AS fin, h.first_album_seen
  FROM u0 u LEFT JOIN stk k USING (album_id, user_id) JOIN hist h USING (user_id)
),
pop AS (
  SELECT album_id, user_id, fin, alb_rev, st FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND first_album_seen < album_id AND NOT excl AND lr >= 0.5 AND rev_all > 0
),
bands AS (
  SELECT p.album_id, p.user_id, p.fin, p.alb_rev,
    CASE WHEN 144 - s BETWEEN 1 AND 3 THEN '1_3' WHEN 144 - s BETWEEN 4 AND 6 THEN '4_6' WHEN 144 - s BETWEEN 7 AND 10 THEN '7_10' END AS band,
    8 - i AS k
  FROM pop p CROSS JOIN UNNEST(p.st) AS s WITH OFFSET i
  WHERE s IS NOT NULL
),
entry AS (
  SELECT album_id, user_id, band, ANY_VALUE(fin) AS fin, ANY_VALUE(alb_rev) AS alb_rev, MAX(k) AS entry_k
  FROM bands WHERE band IS NOT NULL GROUP BY 1,2,3
  UNION ALL
  SELECT album_id, user_id, 'all_payers', fin, alb_rev, NULL FROM pop
),
game AS (SELECT 61 AS album_id, 25342929.0 AS game_rev UNION ALL SELECT 63, 30317756.0)
SELECT e.album_id, e.band, e.entry_k, COUNT(*) AS players, COUNTIF(e.fin) AS finishers,
  ROUND(COUNTIF(e.fin) / COUNT(*), 4) AS fin_rate, ROUND(SUM(e.alb_rev)) AS rev,
  ROUND(SUM(e.alb_rev) / ANY_VALUE(g.game_rev), 4) AS sh_game_rev
FROM entry e JOIN game g USING (album_id)
GROUP BY ROLLUP (e.album_id, e.band, e.entry_k)
HAVING e.album_id IS NOT NULL AND e.band IS NOT NULL AND NOT (e.band = 'all_payers' AND e.entry_k IS NULL AND GROUPING(e.entry_k) = 0)
ORDER BY 1, 2, 3
;

-- ===== DISNEY 14/15 follow-up (Eden 2026-10-22): did early-close finishers lift their spend more than late-close finishers? =====
-- Population: Disney finishers (144 by end of close day) who were 1-3 missing ("3 or fewer") on one of days 8..1 before close; entry = first such day.
-- Lift vs self: $ per active day in the last 4 days before close (close-4..close-1) / own $ per active day in days 14..9 before close
--   (usual week, before the 8-day window). Close day left out (half day). $ and activity from daily metrics (gross_revenues, sessions > 0).
-- Average per player first, then across players; ratio of group means. Also: share whose finish day was the close day.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05'
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
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, MAX(8 - i) AS entry_k
  FROM pop p CROSS JOIN UNNEST(p.st) AS s WITH OFFSET i
  WHERE 144 - s BETWEEN 1 AND 3
  GROUP BY 1,2
),
pu AS (
  SELECT e.album_id, e.user_id, e.entry_k, e.fin_d = e.a_end AS fin_close_day,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14)) AS base_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 4, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 4)) AS end_pd
  FROM ent e JOIN udm m ON m.user_id = e.user_id AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 14
  GROUP BY 1,2,3,4
)
SELECT album_id,
  CASE WHEN entry_k = 8 THEN '1: 8+ days out' WHEN entry_k >= 5 THEN '2: 7-5 days out' WHEN entry_k >= 3 THEN '3: 4-3 days out' ELSE '4: 2-1 days out' END AS entered,
  COUNT(*) AS finishers,
  ROUND(AVG(base_pd), 2) AS base_pd, ROUND(AVG(end_pd), 2) AS end_pd,
  ROUND(SAFE_DIVIDE(AVG(end_pd), AVG(base_pd)), 2) AS lift,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(end_pd, base_pd), 2)[OFFSET(1)], 2) AS median_player_lift,
  ROUND(COUNTIF(fin_close_day) / COUNT(*), 3) AS sh_fin_close_day
FROM pu WHERE base_pd IS NOT NULL AND end_pd IS NOT NULL
GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DISNEY 14/15 follow-up 2 (Eden 2026-10-22): same, with an earlier base (days 21..15 before close) next to days 14..9 =====
-- Population: Disney finishers (144 by end of close day) who were 1-3 missing ("3 or fewer") on one of days 8..1 before close; entry = first such day.
-- Lift vs self: $ per active day in the last 4 days before close (close-4..close-1) / own $ per active day in days 14..9 before close
--   (usual week, before the 8-day window). Close day left out (half day). $ and activity from daily metrics (gross_revenues, sessions > 0).
-- Average per player first, then across players; ratio of group means. Also: share whose finish day was the close day.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-10-05'
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
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, MAX(8 - i) AS entry_k
  FROM pop p CROSS JOIN UNNEST(p.st) AS s WITH OFFSET i
  WHERE 144 - s BETWEEN 1 AND 3
  GROUP BY 1,2
),
pu AS (
  SELECT e.album_id, e.user_id, e.entry_k, e.fin_d = e.a_end AS fin_close_day,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14)) AS base_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21)) AS base2_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 4, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 4)) AS end_pd
  FROM ent e JOIN udm m ON m.user_id = e.user_id AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 21
  GROUP BY 1,2,3,4
)
SELECT album_id,
  CASE WHEN entry_k = 8 THEN '1: 8+ days out' WHEN entry_k >= 5 THEN '2: 7-5 days out' WHEN entry_k >= 3 THEN '3: 4-3 days out' ELSE '4: 2-1 days out' END AS entered,
  COUNT(*) AS finishers,
  ROUND(AVG(base2_pd), 2) AS base2_pd, ROUND(AVG(base_pd), 2) AS base_pd, ROUND(AVG(end_pd), 2) AS end_pd,
  ROUND(SAFE_DIVIDE(AVG(end_pd), AVG(base2_pd)), 2) AS lift_vs_21_15,
  ROUND(SAFE_DIVIDE(AVG(end_pd), AVG(base_pd)), 2) AS lift_vs_14_9,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(end_pd, base2_pd), 2)[OFFSET(1)], 2) AS median_lift_vs_21_15
FROM pu WHERE base2_pd IS NOT NULL AND base_pd IS NOT NULL AND end_pd IS NOT NULL
GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DISNEY 14/15 follow-up 3 (Eden 2026-10-22): WHEN did the finishers finish, by when they got to 3 or fewer missing? =====
-- Same population as follow-up 1. finish day = first daily row with 144 (close day = 0 days before close).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05'
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
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, MAX(8 - i) AS entry_k
  FROM pop p CROSS JOIN UNNEST(p.st) AS s WITH OFFSET i
  WHERE 144 - s BETWEEN 1 AND 3
  GROUP BY 1,2
),
fd AS (
  SELECT album_id,
    CASE WHEN entry_k = 8 THEN '1: 8+ days out' WHEN entry_k >= 5 THEN '2: 7-5 days out' WHEN entry_k >= 3 THEN '3: 4-3 days out' ELSE '4: 2-1 days out' END AS entered,
    DATE_DIFF(a_end, fin_d, DAY) AS fin_k
  FROM ent
)
SELECT album_id, entered, COUNT(*) AS finishers,
  ROUND(COUNTIF(fin_k >= 8) / COUNT(*), 3) AS sh_fin_8plus,
  ROUND(COUNTIF(fin_k BETWEEN 5 AND 7) / COUNT(*), 3) AS sh_fin_7_5,
  ROUND(COUNTIF(fin_k = 4) / COUNT(*), 3) AS sh_fin_4,
  ROUND(COUNTIF(fin_k = 3) / COUNT(*), 3) AS sh_fin_3,
  ROUND(COUNTIF(fin_k = 2) / COUNT(*), 3) AS sh_fin_2,
  ROUND(COUNTIF(fin_k = 1) / COUNT(*), 3) AS sh_fin_1,
  ROUND(COUNTIF(fin_k = 0) / COUNT(*), 3) AS sh_fin_close_day
FROM fd GROUP BY 1,2 ORDER BY 1,2
;

-- ===== follow-up 4 (Eden 2026-10-22): Domino 19/20 and Dice 61/63 — finishers who got to 3 or fewer missing in the last 8 days:
-- when they finished and how much they lifted spend vs themselves (as Disney follow-ups 2-3).
-- Lift = $ per active day in close-4..close-1 / own $ per active day in days 21..15 (and 14..9) before close; average per player first.
-- Players need activity in all three windows for the lift columns (finish-day columns use all finishers).

-- ----- DOMINO 19/20 (domino-dreams-dbt) -----
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
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, MAX(8 - i) AS entry_k
  FROM pop p CROSS JOIN UNNEST(p.st) AS s WITH OFFSET i
  WHERE 144 - s BETWEEN 1 AND 3
  GROUP BY 1,2
),
pu AS (
  SELECT e.album_id, e.user_id, e.entry_k, DATE_DIFF(e.a_end, e.fin_d, DAY) AS fin_k,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21)) AS base2_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14)) AS base_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 4, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 4)) AS end_pd
  FROM ent e LEFT JOIN udm m ON m.user_id = e.user_id AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 21
  GROUP BY 1,2,3,4
),
g AS (
  SELECT album_id, fin_k, base2_pd, base_pd, end_pd,
    base2_pd IS NOT NULL AND base_pd IS NOT NULL AND end_pd IS NOT NULL AS ok,
    CASE WHEN entry_k = 8 THEN '1: 8+ days out' WHEN entry_k >= 5 THEN '2: 7-5 days out' WHEN entry_k >= 3 THEN '3: 4-3 days out' ELSE '4: 2-1 days out' END AS entered
  FROM pu
)
SELECT album_id, entered, COUNT(*) AS finishers,
  ROUND(COUNTIF(fin_k BETWEEN 4 AND 7) / COUNT(*), 3) AS sh_fin_7_4, ROUND(COUNTIF(fin_k = 3) / COUNT(*), 3) AS sh_fin_3,
  ROUND(COUNTIF(fin_k = 2) / COUNT(*), 3) AS sh_fin_2, ROUND(COUNTIF(fin_k = 1) / COUNT(*), 3) AS sh_fin_1,
  ROUND(COUNTIF(fin_k = 0) / COUNT(*), 3) AS sh_fin_close_day,
  COUNTIF(ok) AS n_lift,
  ROUND(AVG(IF(ok, base2_pd, NULL)), 2) AS base2_pd, ROUND(AVG(IF(ok, base_pd, NULL)), 2) AS base_pd, ROUND(AVG(IF(ok, end_pd, NULL)), 2) AS end_pd,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base2_pd, NULL))), 2) AS lift_vs_21_15,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base_pd, NULL))), 2) AS lift_vs_14_9,
  ROUND(APPROX_QUANTILES(IF(ok, SAFE_DIVIDE(end_pd, base2_pd), NULL), 2)[OFFSET(1)], 2) AS median_lift_vs_21_15
FROM g GROUP BY 1,2 ORDER BY 1,2
;

-- ----- DICE 61/63 (dice-dreams-dbt) -----
-- Finish day: first daily row with 144 before close; else the date the 144th unique sticker was first collected (sticker table), if on or before the close day.
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
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, MAX(8 - i) AS entry_k
  FROM pop p CROSS JOIN UNNEST(p.st) AS s WITH OFFSET i
  WHERE 144 - s BETWEEN 1 AND 3
  GROUP BY 1,2
),
pu AS (
  SELECT e.album_id, e.user_id, e.entry_k, DATE_DIFF(e.a_end, e.fin_d, DAY) AS fin_k,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21)) AS base2_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14)) AS base_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 4, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 4)) AS end_pd
  FROM ent e LEFT JOIN udm m ON m.user_id = e.user_id AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 1 AND 21
  GROUP BY 1,2,3,4
),
g AS (
  SELECT album_id, fin_k, base2_pd, base_pd, end_pd,
    base2_pd IS NOT NULL AND base_pd IS NOT NULL AND end_pd IS NOT NULL AS ok,
    CASE WHEN entry_k = 8 THEN '1: 8+ days out' WHEN entry_k >= 5 THEN '2: 7-5 days out' WHEN entry_k >= 3 THEN '3: 4-3 days out' ELSE '4: 2-1 days out' END AS entered
  FROM pu
)
SELECT album_id, entered, COUNT(*) AS finishers,
  ROUND(COUNTIF(fin_k BETWEEN 4 AND 7) / COUNT(*), 3) AS sh_fin_7_4, ROUND(COUNTIF(fin_k = 3) / COUNT(*), 3) AS sh_fin_3,
  ROUND(COUNTIF(fin_k = 2) / COUNT(*), 3) AS sh_fin_2, ROUND(COUNTIF(fin_k = 1) / COUNT(*), 3) AS sh_fin_1,
  ROUND(COUNTIF(fin_k = 0) / COUNT(*), 3) AS sh_fin_close_day,
  COUNTIF(ok) AS n_lift,
  ROUND(AVG(IF(ok, base2_pd, NULL)), 2) AS base2_pd, ROUND(AVG(IF(ok, base_pd, NULL)), 2) AS base_pd, ROUND(AVG(IF(ok, end_pd, NULL)), 2) AS end_pd,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base2_pd, NULL))), 2) AS lift_vs_21_15,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base_pd, NULL))), 2) AS lift_vs_14_9,
  ROUND(APPROX_QUANTILES(IF(ok, SAFE_DIVIDE(end_pd, base2_pd), NULL), 2)[OFFSET(1)], 2) AS median_lift_vs_21_15
FROM g GROUP BY 1,2 ORDER BY 1,2
;


-- ===== follow-up 5 (Eden 2026-10-22): aligned bins + corrected end window, all three games =====
-- Entry bins (first day at 3 or fewer missing): 8+ / 7-4 / 3 / 2 / 1 days before close. Finish bins: 7-4 / 3 / 2 / 1 / close day.
-- End $ per active day = the 4 days ending on the player's finish day (finish-3 .. finish, finish day included, close day included
--   when the player finished on it) — so no post-finish days count (Eden). Base = days 21-15 (and 14-9) before close.

-- ----- DOMINO -----
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
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, MAX(8 - i) AS entry_k
  FROM pop p CROSS JOIN UNNEST(p.st) AS s WITH OFFSET i
  WHERE 144 - s BETWEEN 1 AND 3
  GROUP BY 1,2
),
pu AS (
  SELECT e.album_id, e.user_id, e.entry_k, DATE_DIFF(e.a_end, e.fin_d, DAY) AS fin_k,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21)) AS base2_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14)) AS base_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3)) AS end_pd
  FROM ent e LEFT JOIN udm m ON m.user_id = e.user_id AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 0 AND 21
  GROUP BY 1,2,3,4
),
g AS (
  SELECT album_id, fin_k, base2_pd, base_pd, end_pd,
    base2_pd IS NOT NULL AND base_pd IS NOT NULL AND end_pd IS NOT NULL AS ok,
    CASE WHEN entry_k = 8 THEN '1: 8+ days out' WHEN entry_k >= 4 THEN '2: 7-4 days out' WHEN entry_k = 3 THEN '3: 3 days out'
         WHEN entry_k = 2 THEN '4: 2 days out' ELSE '5: 1 day out' END AS entered
  FROM pu
)
SELECT album_id, entered, COUNT(*) AS finishers,
  ROUND(COUNTIF(fin_k BETWEEN 4 AND 7) / COUNT(*), 3) AS sh_fin_7_4, ROUND(COUNTIF(fin_k = 3) / COUNT(*), 3) AS sh_fin_3,
  ROUND(COUNTIF(fin_k = 2) / COUNT(*), 3) AS sh_fin_2, ROUND(COUNTIF(fin_k = 1) / COUNT(*), 3) AS sh_fin_1,
  ROUND(COUNTIF(fin_k = 0) / COUNT(*), 3) AS sh_fin_close_day,
  COUNTIF(ok) AS n_lift,
  ROUND(AVG(IF(ok, base2_pd, NULL)), 2) AS base2_pd, ROUND(AVG(IF(ok, base_pd, NULL)), 2) AS base_pd, ROUND(AVG(IF(ok, end_pd, NULL)), 2) AS end_pd,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base2_pd, NULL))), 2) AS lift_vs_21_15,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base_pd, NULL))), 2) AS lift_vs_14_9,
  ROUND(APPROX_QUANTILES(IF(ok, SAFE_DIVIDE(end_pd, base2_pd), NULL), 2)[OFFSET(1)], 2) AS median_lift_vs_21_15
FROM g GROUP BY 1,2 ORDER BY 1,2

;

-- ----- DISNEY -----
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-10-05'
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
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, MAX(8 - i) AS entry_k
  FROM pop p CROSS JOIN UNNEST(p.st) AS s WITH OFFSET i
  WHERE 144 - s BETWEEN 1 AND 3
  GROUP BY 1,2
),
pu AS (
  SELECT e.album_id, e.user_id, e.entry_k, DATE_DIFF(e.a_end, e.fin_d, DAY) AS fin_k,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21)) AS base2_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14)) AS base_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3)) AS end_pd
  FROM ent e LEFT JOIN udm m ON m.user_id = e.user_id AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 0 AND 21
  GROUP BY 1,2,3,4
),
g AS (
  SELECT album_id, fin_k, base2_pd, base_pd, end_pd,
    base2_pd IS NOT NULL AND base_pd IS NOT NULL AND end_pd IS NOT NULL AS ok,
    CASE WHEN entry_k = 8 THEN '1: 8+ days out' WHEN entry_k >= 4 THEN '2: 7-4 days out' WHEN entry_k = 3 THEN '3: 3 days out'
         WHEN entry_k = 2 THEN '4: 2 days out' ELSE '5: 1 day out' END AS entered
  FROM pu
)
SELECT album_id, entered, COUNT(*) AS finishers,
  ROUND(COUNTIF(fin_k BETWEEN 4 AND 7) / COUNT(*), 3) AS sh_fin_7_4, ROUND(COUNTIF(fin_k = 3) / COUNT(*), 3) AS sh_fin_3,
  ROUND(COUNTIF(fin_k = 2) / COUNT(*), 3) AS sh_fin_2, ROUND(COUNTIF(fin_k = 1) / COUNT(*), 3) AS sh_fin_1,
  ROUND(COUNTIF(fin_k = 0) / COUNT(*), 3) AS sh_fin_close_day,
  COUNTIF(ok) AS n_lift,
  ROUND(AVG(IF(ok, base2_pd, NULL)), 2) AS base2_pd, ROUND(AVG(IF(ok, base_pd, NULL)), 2) AS base_pd, ROUND(AVG(IF(ok, end_pd, NULL)), 2) AS end_pd,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base2_pd, NULL))), 2) AS lift_vs_21_15,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base_pd, NULL))), 2) AS lift_vs_14_9,
  ROUND(APPROX_QUANTILES(IF(ok, SAFE_DIVIDE(end_pd, base2_pd), NULL), 2)[OFFSET(1)], 2) AS median_lift_vs_21_15
FROM g GROUP BY 1,2 ORDER BY 1,2

;

-- ----- DICE -----
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
  SELECT p.album_id, p.user_id, ANY_VALUE(p.a_end) AS a_end, ANY_VALUE(p.fin_d) AS fin_d, MAX(8 - i) AS entry_k
  FROM pop p CROSS JOIN UNNEST(p.st) AS s WITH OFFSET i
  WHERE 144 - s BETWEEN 1 AND 3
  GROUP BY 1,2
),
pu AS (
  SELECT e.album_id, e.user_id, e.entry_k, DATE_DIFF(e.a_end, e.fin_d, DAY) AS fin_k,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21)) AS base2_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14)) AS base_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3)) AS end_pd
  FROM ent e LEFT JOIN udm m ON m.user_id = e.user_id AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 0 AND 21
  GROUP BY 1,2,3,4
),
g AS (
  SELECT album_id, fin_k, base2_pd, base_pd, end_pd,
    base2_pd IS NOT NULL AND base_pd IS NOT NULL AND end_pd IS NOT NULL AS ok,
    CASE WHEN entry_k = 8 THEN '1: 8+ days out' WHEN entry_k >= 4 THEN '2: 7-4 days out' WHEN entry_k = 3 THEN '3: 3 days out'
         WHEN entry_k = 2 THEN '4: 2 days out' ELSE '5: 1 day out' END AS entered
  FROM pu
)
SELECT album_id, entered, COUNT(*) AS finishers,
  ROUND(COUNTIF(fin_k BETWEEN 4 AND 7) / COUNT(*), 3) AS sh_fin_7_4, ROUND(COUNTIF(fin_k = 3) / COUNT(*), 3) AS sh_fin_3,
  ROUND(COUNTIF(fin_k = 2) / COUNT(*), 3) AS sh_fin_2, ROUND(COUNTIF(fin_k = 1) / COUNT(*), 3) AS sh_fin_1,
  ROUND(COUNTIF(fin_k = 0) / COUNT(*), 3) AS sh_fin_close_day,
  COUNTIF(ok) AS n_lift,
  ROUND(AVG(IF(ok, base2_pd, NULL)), 2) AS base2_pd, ROUND(AVG(IF(ok, base_pd, NULL)), 2) AS base_pd, ROUND(AVG(IF(ok, end_pd, NULL)), 2) AS end_pd,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base2_pd, NULL))), 2) AS lift_vs_21_15,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base_pd, NULL))), 2) AS lift_vs_14_9,
  ROUND(APPROX_QUANTILES(IF(ok, SAFE_DIVIDE(end_pd, base2_pd), NULL), 2)[OFFSET(1)], 2) AS median_lift_vs_21_15
FROM g GROUP BY 1,2 ORDER BY 1,2

;


-- ===== follow-up 6 (Eden 2026-10-22): NON-overlapping groups by status on a fixed day (8 and 7 days before close) =====
-- Each payer counted once per day: missing stickers on the latest daily row on or before close-8 (and close-7).
-- finish rate (144 by end of close day), share of payers, share of game revenue. Same population as above.

-- ----- DOMINO -----
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(uniq) >= 144 AS fin,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    [MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 8, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 7, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 6, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 5, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 4, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 3, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 2, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 1, uniq, NULL))] AS st
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, fin, alb_rev, rev_all, last_d, l.lr AS lr, l.past AS past, l.excl AS excl, st FROM u0),
pop AS (
  SELECT album_id, user_id, fin, alb_rev, st FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_all > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cs AS (
  SELECT p.album_id, p.user_id, p.fin, p.alb_rev, x.d, 144 - x.s AS miss
  FROM pop p CROSS JOIN UNNEST([STRUCT(8 AS d, p.st[OFFSET(0)] AS s), STRUCT(7 AS d, p.st[OFFSET(1)] AS s)]) AS x
),
b AS (
  SELECT album_id, d, fin, alb_rev,
    CASE WHEN miss IS NULL THEN '9 no row yet' WHEN miss <= 0 THEN '0 finished' WHEN miss <= 3 THEN '1 1-3' WHEN miss <= 6 THEN '2 4-6'
         WHEN miss <= 10 THEN '3 7-10' ELSE '4 11+' END AS band
  FROM cs
),
game AS (SELECT 19 AS album_id, 17644426.0 AS game_rev UNION ALL SELECT 20, 16269671.0)
SELECT b.album_id, b.d, b.band, COUNT(*) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY b.album_id, b.d), 4) AS sh_payers,
  ROUND(COUNTIF(b.fin) / COUNT(*), 4) AS fin_rate,
  ROUND(SUM(b.alb_rev) / ANY_VALUE(g.game_rev), 4) AS sh_game_rev
FROM b JOIN game g USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2 DESC,3
;

-- ----- DISNEY -----
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(uniq) >= 144 AS fin,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    [MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 8, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 7, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 6, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 5, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 4, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 3, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 2, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 1, uniq, NULL))] AS st
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, fin, alb_rev, rev_all, last_d, l.lr AS lr, l.past AS past, l.excl AS excl, st FROM u0),
pop AS (
  SELECT album_id, user_id, fin, alb_rev, st FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_all > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cs AS (
  SELECT p.album_id, p.user_id, p.fin, p.alb_rev, x.d, 144 - x.s AS miss
  FROM pop p CROSS JOIN UNNEST([STRUCT(8 AS d, p.st[OFFSET(0)] AS s), STRUCT(7 AS d, p.st[OFFSET(1)] AS s)]) AS x
),
b AS (
  SELECT album_id, d, fin, alb_rev,
    CASE WHEN miss IS NULL THEN '9 no row yet' WHEN miss <= 0 THEN '0 finished' WHEN miss <= 3 THEN '1 1-3' WHEN miss <= 6 THEN '2 4-6'
         WHEN miss <= 10 THEN '3 7-10' ELSE '4 11+' END AS band
  FROM cs
),
game AS (SELECT 14 AS album_id, 51554638.0 AS game_rev UNION ALL SELECT 15, 44887998.0)
SELECT b.album_id, b.d, b.band, COUNT(*) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY b.album_id, b.d), 4) AS sh_payers,
  ROUND(COUNTIF(b.fin) / COUNT(*), 4) AS fin_rate,
  ROUND(SUM(b.alb_rev) / ANY_VALUE(g.game_rev), 4) AS sh_game_rev
FROM b JOIN game g USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2 DESC,3
;

-- ----- DICE -----
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
stk AS (
  SELECT album_id, user_id, COUNT(DISTINCT sticker_id) AS n_uniq, MAX(sticker_collected_date) AS last_d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers`
  WHERE sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (61,63)
    AND sticker_type IN ('common','golden','super') AND IFNULL(is_sticker_collected, TRUE)
  GROUP BY 1,2
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(IF(date_dim < a_end, uniq, NULL)) >= 144 AS fin_prev,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
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
  SELECT u.album_id, u.user_id, u.a_end, u.alb_rev, u.rev_all, u.last_d, u.lr, u.excl, u.st,
    IFNULL(u.fin_prev, FALSE) OR IFNULL(k.n_uniq >= 144 AND k.last_d <= u.a_end, FALSE) AS fin, h.first_album_seen
  FROM u0 u LEFT JOIN stk k USING (album_id, user_id) JOIN hist h USING (user_id)
),
pop AS (
  SELECT album_id, user_id, fin, alb_rev, st FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND first_album_seen < album_id AND NOT excl AND lr >= 0.5 AND rev_all > 0
),
cs AS (
  SELECT p.album_id, p.user_id, p.fin, p.alb_rev, x.d, 144 - x.s AS miss
  FROM pop p CROSS JOIN UNNEST([STRUCT(8 AS d, p.st[OFFSET(0)] AS s), STRUCT(7 AS d, p.st[OFFSET(1)] AS s)]) AS x
),
b AS (
  SELECT album_id, d, fin, alb_rev,
    CASE WHEN miss IS NULL THEN '9 no row yet' WHEN miss <= 0 THEN '0 finished' WHEN miss <= 3 THEN '1 1-3' WHEN miss <= 6 THEN '2 4-6'
         WHEN miss <= 10 THEN '3 7-10' ELSE '4 11+' END AS band
  FROM cs
),
game AS (SELECT 61 AS album_id, 25342929.0 AS game_rev UNION ALL SELECT 63, 30317756.0)
SELECT b.album_id, b.d, b.band, COUNT(*) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY b.album_id, b.d), 4) AS sh_payers,
  ROUND(COUNTIF(b.fin) / COUNT(*), 4) AS fin_rate,
  ROUND(SUM(b.alb_rev) / ANY_VALUE(g.game_rev), 4) AS sh_game_rev
FROM b JOIN game g USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2 DESC,3
;


-- ===== follow-up 7 (Eden 2026-10-22): last status in days 8-4 before close (= latest row on or before close-4), each payer once;
-- chance to finish in the last 4 days (close-3 .. close day). Already finished by close-4 shown as its own row.

-- ----- DOMINO -----
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(uniq) >= 144 AS fin,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    [MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 8, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 7, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 6, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 5, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 4, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 3, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 2, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 1, uniq, NULL))] AS st
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, fin, alb_rev, rev_all, last_d, l.lr AS lr, l.past AS past, l.excl AS excl, st FROM u0),
pop AS (
  SELECT album_id, user_id, fin, alb_rev, st FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_all > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cs AS (
  SELECT p.album_id, p.user_id, p.fin, p.alb_rev, x.d, 144 - x.s AS miss
  FROM pop p CROSS JOIN UNNEST([STRUCT(4 AS d, p.st[OFFSET(4)] AS s)]) AS x
),
b AS (
  SELECT album_id, d, fin, alb_rev,
    CASE WHEN miss IS NULL THEN '9 no row yet' WHEN miss <= 0 THEN '0 finished' WHEN miss <= 3 THEN '1 1-3' WHEN miss <= 6 THEN '2 4-6'
         WHEN miss <= 10 THEN '3 7-10' ELSE '4 11+' END AS band
  FROM cs
),
game AS (SELECT 19 AS album_id, 17644426.0 AS game_rev UNION ALL SELECT 20, 16269671.0)
SELECT b.album_id, b.d, b.band, COUNT(*) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY b.album_id, b.d), 4) AS sh_payers,
  ROUND(COUNTIF(b.fin) / COUNT(*), 4) AS fin_rate,
  ROUND(SUM(b.alb_rev) / ANY_VALUE(g.game_rev), 4) AS sh_game_rev
FROM b JOIN game g USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2 DESC,3
;

-- ----- DISNEY -----
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(uniq) >= 144 AS fin,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    [MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 8, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 7, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 6, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 5, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 4, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 3, uniq, NULL)),
     MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 2, uniq, NULL)), MAX(IF(DATE_DIFF(a_end, date_dim, DAY) >= 1, uniq, NULL))] AS st
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, fin, alb_rev, rev_all, last_d, l.lr AS lr, l.past AS past, l.excl AS excl, st FROM u0),
pop AS (
  SELECT album_id, user_id, fin, alb_rev, st FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_all > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cs AS (
  SELECT p.album_id, p.user_id, p.fin, p.alb_rev, x.d, 144 - x.s AS miss
  FROM pop p CROSS JOIN UNNEST([STRUCT(4 AS d, p.st[OFFSET(4)] AS s)]) AS x
),
b AS (
  SELECT album_id, d, fin, alb_rev,
    CASE WHEN miss IS NULL THEN '9 no row yet' WHEN miss <= 0 THEN '0 finished' WHEN miss <= 3 THEN '1 1-3' WHEN miss <= 6 THEN '2 4-6'
         WHEN miss <= 10 THEN '3 7-10' ELSE '4 11+' END AS band
  FROM cs
),
game AS (SELECT 14 AS album_id, 51554638.0 AS game_rev UNION ALL SELECT 15, 44887998.0)
SELECT b.album_id, b.d, b.band, COUNT(*) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY b.album_id, b.d), 4) AS sh_payers,
  ROUND(COUNTIF(b.fin) / COUNT(*), 4) AS fin_rate,
  ROUND(SUM(b.alb_rev) / ANY_VALUE(g.game_rev), 4) AS sh_game_rev
FROM b JOIN game g USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2 DESC,3
;

-- ----- DICE -----
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
stk AS (
  SELECT album_id, user_id, COUNT(DISTINCT sticker_id) AS n_uniq, MAX(sticker_collected_date) AS last_d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers`
  WHERE sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (61,63)
    AND sticker_type IN ('common','golden','super') AND IFNULL(is_sticker_collected, TRUE)
  GROUP BY 1,2
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(IF(date_dim < a_end, uniq, NULL)) >= 144 AS fin_prev,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
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
  SELECT u.album_id, u.user_id, u.a_end, u.alb_rev, u.rev_all, u.last_d, u.lr, u.excl, u.st,
    IFNULL(u.fin_prev, FALSE) OR IFNULL(k.n_uniq >= 144 AND k.last_d <= u.a_end, FALSE) AS fin, h.first_album_seen
  FROM u0 u LEFT JOIN stk k USING (album_id, user_id) JOIN hist h USING (user_id)
),
pop AS (
  SELECT album_id, user_id, fin, alb_rev, st FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND first_album_seen < album_id AND NOT excl AND lr >= 0.5 AND rev_all > 0
),
cs AS (
  SELECT p.album_id, p.user_id, p.fin, p.alb_rev, x.d, 144 - x.s AS miss
  FROM pop p CROSS JOIN UNNEST([STRUCT(4 AS d, p.st[OFFSET(4)] AS s)]) AS x
),
b AS (
  SELECT album_id, d, fin, alb_rev,
    CASE WHEN miss IS NULL THEN '9 no row yet' WHEN miss <= 0 THEN '0 finished' WHEN miss <= 3 THEN '1 1-3' WHEN miss <= 6 THEN '2 4-6'
         WHEN miss <= 10 THEN '3 7-10' ELSE '4 11+' END AS band
  FROM cs
),
game AS (SELECT 61 AS album_id, 25342929.0 AS game_rev UNION ALL SELECT 63, 30317756.0)
SELECT b.album_id, b.d, b.band, COUNT(*) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY b.album_id, b.d), 4) AS sh_payers,
  ROUND(COUNTIF(b.fin) / COUNT(*), 4) AS fin_rate,
  ROUND(SUM(b.alb_rev) / ANY_VALUE(g.game_rev), 4) AS sh_game_rev
FROM b JOIN game g USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2 DESC,3
;


-- ===== follow-up 8 (Eden 2026-10-22): slides 20-21 on the slide-19 definition =====
-- Finishers grouped by status on close-4 (last state in days 8-4): 1-3 / 4-6 / 7-10 missing; already finished by close-4 left out.
-- Finish day shares (3 / 2 / 1 / close day) and lift = $/active day in the 4 days ending on the finish day / days 21-15 (and 14-9).

-- ----- DOMINO -----
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
pu AS (
  SELECT e.album_id, e.user_id, e.m4, DATE_DIFF(e.a_end, e.fin_d, DAY) AS fin_k,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21)) AS base2_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14)) AS base_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3)) AS end_pd
  FROM ent e LEFT JOIN udm m ON m.user_id = e.user_id AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 0 AND 21
  GROUP BY 1,2,3,4
),
g AS (
  SELECT album_id, fin_k, base2_pd, base_pd, end_pd,
    base2_pd IS NOT NULL AND base_pd IS NOT NULL AND end_pd IS NOT NULL AS ok,
    CASE WHEN m4 <= 3 THEN '1: 1-3' WHEN m4 <= 6 THEN '2: 4-6' ELSE '3: 7-10' END AS entered
  FROM pu
)
SELECT album_id, entered, COUNT(*) AS finishers,
  ROUND(COUNTIF(fin_k BETWEEN 4 AND 7) / COUNT(*), 3) AS sh_fin_7_4, ROUND(COUNTIF(fin_k = 3) / COUNT(*), 3) AS sh_fin_3,
  ROUND(COUNTIF(fin_k = 2) / COUNT(*), 3) AS sh_fin_2, ROUND(COUNTIF(fin_k = 1) / COUNT(*), 3) AS sh_fin_1,
  ROUND(COUNTIF(fin_k = 0) / COUNT(*), 3) AS sh_fin_close_day,
  COUNTIF(ok) AS n_lift,
  ROUND(AVG(IF(ok, base2_pd, NULL)), 2) AS base2_pd, ROUND(AVG(IF(ok, base_pd, NULL)), 2) AS base_pd, ROUND(AVG(IF(ok, end_pd, NULL)), 2) AS end_pd,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base2_pd, NULL))), 2) AS lift_vs_21_15,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base_pd, NULL))), 2) AS lift_vs_14_9,
  ROUND(APPROX_QUANTILES(IF(ok, SAFE_DIVIDE(end_pd, base2_pd), NULL), 2)[OFFSET(1)], 2) AS median_lift_vs_21_15
FROM g GROUP BY 1,2 ORDER BY 1,2

;

-- ----- DISNEY -----
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-10-05'
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
pu AS (
  SELECT e.album_id, e.user_id, e.m4, DATE_DIFF(e.a_end, e.fin_d, DAY) AS fin_k,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21)) AS base2_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14)) AS base_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3)) AS end_pd
  FROM ent e LEFT JOIN udm m ON m.user_id = e.user_id AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 0 AND 21
  GROUP BY 1,2,3,4
),
g AS (
  SELECT album_id, fin_k, base2_pd, base_pd, end_pd,
    base2_pd IS NOT NULL AND base_pd IS NOT NULL AND end_pd IS NOT NULL AS ok,
    CASE WHEN m4 <= 3 THEN '1: 1-3' WHEN m4 <= 6 THEN '2: 4-6' ELSE '3: 7-10' END AS entered
  FROM pu
)
SELECT album_id, entered, COUNT(*) AS finishers,
  ROUND(COUNTIF(fin_k BETWEEN 4 AND 7) / COUNT(*), 3) AS sh_fin_7_4, ROUND(COUNTIF(fin_k = 3) / COUNT(*), 3) AS sh_fin_3,
  ROUND(COUNTIF(fin_k = 2) / COUNT(*), 3) AS sh_fin_2, ROUND(COUNTIF(fin_k = 1) / COUNT(*), 3) AS sh_fin_1,
  ROUND(COUNTIF(fin_k = 0) / COUNT(*), 3) AS sh_fin_close_day,
  COUNTIF(ok) AS n_lift,
  ROUND(AVG(IF(ok, base2_pd, NULL)), 2) AS base2_pd, ROUND(AVG(IF(ok, base_pd, NULL)), 2) AS base_pd, ROUND(AVG(IF(ok, end_pd, NULL)), 2) AS end_pd,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base2_pd, NULL))), 2) AS lift_vs_21_15,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base_pd, NULL))), 2) AS lift_vs_14_9,
  ROUND(APPROX_QUANTILES(IF(ok, SAFE_DIVIDE(end_pd, base2_pd), NULL), 2)[OFFSET(1)], 2) AS median_lift_vs_21_15
FROM g GROUP BY 1,2 ORDER BY 1,2

;

-- ----- DICE -----
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
pu AS (
  SELECT e.album_id, e.user_id, e.m4, DATE_DIFF(e.a_end, e.fin_d, DAY) AS fin_k,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 15 AND 21)) AS base2_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 9 AND 14)) AS base_pd,
    SAFE_DIVIDE(SUM(IF(DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3, m.rev, 0)),
      COUNTIF(m.act AND DATE_DIFF(e.fin_d, m.date_dim, DAY) BETWEEN 0 AND 3)) AS end_pd
  FROM ent e LEFT JOIN udm m ON m.user_id = e.user_id AND DATE_DIFF(e.a_end, m.date_dim, DAY) BETWEEN 0 AND 21
  GROUP BY 1,2,3,4
),
g AS (
  SELECT album_id, fin_k, base2_pd, base_pd, end_pd,
    base2_pd IS NOT NULL AND base_pd IS NOT NULL AND end_pd IS NOT NULL AS ok,
    CASE WHEN m4 <= 3 THEN '1: 1-3' WHEN m4 <= 6 THEN '2: 4-6' ELSE '3: 7-10' END AS entered
  FROM pu
)
SELECT album_id, entered, COUNT(*) AS finishers,
  ROUND(COUNTIF(fin_k BETWEEN 4 AND 7) / COUNT(*), 3) AS sh_fin_7_4, ROUND(COUNTIF(fin_k = 3) / COUNT(*), 3) AS sh_fin_3,
  ROUND(COUNTIF(fin_k = 2) / COUNT(*), 3) AS sh_fin_2, ROUND(COUNTIF(fin_k = 1) / COUNT(*), 3) AS sh_fin_1,
  ROUND(COUNTIF(fin_k = 0) / COUNT(*), 3) AS sh_fin_close_day,
  COUNTIF(ok) AS n_lift,
  ROUND(AVG(IF(ok, base2_pd, NULL)), 2) AS base2_pd, ROUND(AVG(IF(ok, base_pd, NULL)), 2) AS base_pd, ROUND(AVG(IF(ok, end_pd, NULL)), 2) AS end_pd,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base2_pd, NULL))), 2) AS lift_vs_21_15,
  ROUND(SAFE_DIVIDE(AVG(IF(ok, end_pd, NULL)), AVG(IF(ok, base_pd, NULL))), 2) AS lift_vs_14_9,
  ROUND(APPROX_QUANTILES(IF(ok, SAFE_DIVIDE(end_pd, base2_pd), NULL), 2)[OFFSET(1)], 2) AS median_lift_vs_21_15
FROM g GROUP BY 1,2 ORDER BY 1,2

;


-- ===== follow-up 9 (Eden 2026-10-22): how finishers closed the gap after close-4 — bought / Market / free =====
-- Finishers grouped by status on close-4 (1-3 / 4-6 / 7-10). New stickers (first receipt) from close-3 to the finish day.
-- Bought = with money (Dice Pricing pack; Domino validated campaign rule; Disney purchase / purchase_gift).
-- Market = Disney new_sticker_source 'marketplace' (tokens from play AND purchases) — own group (Eden). Free = everything else.

-- ----- DOMINO -----
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
FROM pu GROUP BY 1,2 ORDER BY 1,2
;

-- ----- DISNEY -----
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-10-05'
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
    ARRAY_AGG((IFNULL(s.new_sticker_source, '') IN ('purchase', 'purchase_gift')) ORDER BY s.sticker_collected_min_ts LIMIT 1)[OFFSET(0)] AS bought,
    ARRAY_AGG(IFNULL(s.new_sticker_source, '') = 'marketplace' ORDER BY s.sticker_collected_min_ts LIMIT 1)[OFFSET(0)] AS market
  FROM ent e JOIN `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s ON s.album_id = e.album_id AND s.user_id = e.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND s.album_id IN (14,15)
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
FROM pu GROUP BY 1,2 ORDER BY 1,2
;

-- ----- DICE -----
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
FROM pu GROUP BY 1,2 ORDER BY 1,2
;
