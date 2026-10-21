-- Exact rebase to game purchase revenue (2026-10-21). Results: claude/game-revenue-rebase-2026-10-21.md
-- STATUS 2026-10-21: all three dry runs passed (Dice 23.4 GB, Domino 25.4 GB, Disney 35.8 GB); execution failed with BIFROST server errors
--   (export_query_csv and execute_query), and the server then stopped answering dry_run too.
-- DICE: RAN by Eden in the BigQuery console 2026-10-21 (raw result: claude/results/dice_game_revenue_rebase_2026-10-21.csv; verified). DOMINO, DISNEY: not run yet.
-- Check on rerun (R3): game_rev must match opening-facts-2026-10-20.md (Dice 61 $25,342,929 / 63 $30,317,756; Domino 19 $17,644,426 / 20 $16,269,671;
--   Disney 14 $51,554,638 / 15 $44,887,998); sh_std_rev for end_m0 must reproduce finisher-recount (Dice 26/31%, Domino 17/19 32/26%, Disney 21/22%).
-- For the slides weighting (spend groups), staircase (end status 0 / 1 / 2 / 3 / 4+ missing) and heavy-missers ($20+ a day, 2-3 missing).
-- Population: standard (not first album, not excluded, login ratio >= 0.5 on the last row before close, row on close-1), payers = album-table spend > 0 start..close-1.
-- Numerator = album-table spend start..close-1. sh_std_rev = share of the standard population's album revenue (old deck basis).
-- sh_game_rev = share of total game purchase revenue during the album (all players, start..close-1, cheaters / test excluded) = the deck-wide denominator (Eden 2026-10-20).
-- Group = $ per active day in the previous album (daily metrics). End status = unique set stickers at the END of the close day (finisher = 144).
-- Heavy = daily-metrics $ per active day over the album >= 20 and 2-3 missing at the end of the close day (as finisher_recount_queries.sql wave 3).

-- ===== DICE 61/63 (dice-dreams-dbt) =====
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MIN(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (59,61,63)
  GROUP BY 1
),
tgt AS (
  SELECT a.album_id, a.a_start, a.a_end, p.a_start AS p_start, p.a_end AS p_end
  FROM alb a JOIN alb p ON p.album_id = a.album_id - 2
  WHERE a.album_id IN (61,63)
),
ud AS (
  SELECT album_id, user_id, date_dim,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND album_id IN (61,63) AND date_dim < album_end_date
),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN tgt t USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= t.a_end
  GROUP BY 1,2
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-06'
),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
tot AS (
  SELECT t.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN tgt t ON m.date_dim BETWEEN t.a_start AND DATE_SUB(t.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM excl)
  GROUP BY 1
),
u0 AS (
  SELECT album_id, user_id, MAX(uniq) AS uniq_prev, SUM(spend) AS alb_rev, MAX(date_dim) AS last_d,
    ARRAY_AGG(STRUCT(lr, past, excl) ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, uniq_prev, alb_rev, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.p_start, t.p_end, u.alb_rev,
    GREATEST(IFNULL(s.n_uniq, 0), IFNULL(u.uniq_prev, 0)) AS uniq_close
  FROM u1 u JOIN tgt t USING (album_id) LEFT JOIN st s USING (album_id, user_id)
  WHERE u.last_d = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
),
pm AS (
  SELECT p.album_id, p.user_id, ANY_VALUE(p.alb_rev) AS alb_rev, ANY_VALUE(p.uniq_close) AS uniq_close, ANY_VALUE(p.p_start) AS p_start,
    SAFE_DIVIDE(SUM(IF(m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY), m.rev, 0)),
      COUNTIF(m.act AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY))) AS prev_pd,
    SAFE_DIVIDE(SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)),
      COUNTIF(m.act AND m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY))) AS alb_pd
  FROM pop p LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
lab AS (
  SELECT x.album_id, x.alb_rev, label FROM pm x
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    IF(x.p_start IS NOT NULL, [CONCAT('grp_', CASE WHEN IFNULL(x.prev_pd, 0) = 0 THEN 'g0' WHEN x.prev_pd <= 2 THEN 'g1_le2'
      WHEN x.prev_pd <= 5 THEN 'g2_2_5' WHEN x.prev_pd <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END)], []),
    [CONCAT('end_', CASE WHEN x.uniq_close >= 144 THEN 'm0' WHEN x.uniq_close >= 141 THEN CONCAT('m', CAST(144 - x.uniq_close AS STRING)) ELSE 'm4p' END)],
    IF(x.alb_pd >= 20 AND x.uniq_close BETWEEN 141 AND 142, ['heavy_m23'], []),
    ['all_payers'])) AS label
)
SELECT l.album_id, l.label, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(IF(l.label = 'all_payers', COUNT(*), 0)) OVER (PARTITION BY l.album_id), 4) AS sh_payers,
  ROUND(SUM(l.alb_rev)) AS alb_rev,
  ROUND(SUM(l.alb_rev) / SUM(IF(l.label = 'all_payers', SUM(l.alb_rev), 0)) OVER (PARTITION BY l.album_id), 4) AS sh_std_rev,
  ROUND(SUM(l.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev,
  ROUND(ANY_VALUE(t.game_rev)) AS game_rev
FROM lab l JOIN tot t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DOMINO 17/19/20 (domino-dreams-dbt); groups only for 19/20 (previous album 18/19) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12' AND album_id IN (17,18,19,20) AND date_dim <= album_close_date
),
alb AS (SELECT album_id, MIN(a_start) AS a_start, MIN(a_end) AS a_end FROM ud GROUP BY 1),
tgt AS (
  SELECT a.album_id, a.a_start, a.a_end, p.a_start AS p_start, p.a_end AS p_end
  FROM alb a LEFT JOIN alb p ON p.album_id = a.album_id - 1
  WHERE a.album_id IN (17,19,20)
),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(sessions_today,0) > 0 AS act, IFNULL(special_user_flag,FALSE) OR IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
tot AS (
  SELECT t.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN tgt t ON m.date_dim BETWEEN t.a_start AND DATE_SUB(t.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_close,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, uniq_close, alb_rev, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.p_start, t.p_end, u.alb_rev, u.uniq_close
  FROM u1 u JOIN tgt t USING (album_id)
  WHERE u.last_d = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
pm AS (
  SELECT p.album_id, p.user_id, ANY_VALUE(p.alb_rev) AS alb_rev, ANY_VALUE(p.uniq_close) AS uniq_close, ANY_VALUE(p.p_start) AS p_start,
    SAFE_DIVIDE(SUM(IF(m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY), m.rev, 0)),
      COUNTIF(m.act AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY))) AS prev_pd,
    SAFE_DIVIDE(SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)),
      COUNTIF(m.act AND m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY))) AS alb_pd
  FROM pop p LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN IFNULL(p.p_start, p.a_start) AND DATE_SUB(p.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
lab AS (
  SELECT x.album_id, x.alb_rev, label FROM pm x
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    IF(x.p_start IS NOT NULL, [CONCAT('grp_', CASE WHEN IFNULL(x.prev_pd, 0) = 0 THEN 'g0' WHEN x.prev_pd <= 2 THEN 'g1_le2'
      WHEN x.prev_pd <= 5 THEN 'g2_2_5' WHEN x.prev_pd <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END)], []),
    [CONCAT('end_', CASE WHEN x.uniq_close >= 144 THEN 'm0' WHEN x.uniq_close >= 141 THEN CONCAT('m', CAST(144 - x.uniq_close AS STRING)) ELSE 'm4p' END)],
    IF(x.alb_pd >= 20 AND x.uniq_close BETWEEN 141 AND 142, ['heavy_m23'], []),
    ['all_payers'])) AS label
)
SELECT l.album_id, l.label, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(IF(l.label = 'all_payers', COUNT(*), 0)) OVER (PARTITION BY l.album_id), 4) AS sh_payers,
  ROUND(SUM(l.alb_rev)) AS alb_rev,
  ROUND(SUM(l.alb_rev) / SUM(IF(l.label = 'all_payers', SUM(l.alb_rev), 0)) OVER (PARTITION BY l.album_id), 4) AS sh_std_rev,
  ROUND(SUM(l.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev,
  ROUND(ANY_VALUE(t.game_rev)) AS game_rev
FROM lab l JOIN tot t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507); previous album 13/14 =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND album_id IN (13,14,15) AND date_dim <= album_close_date
),
alb AS (SELECT album_id, MIN(a_start) AS a_start, MIN(a_end) AS a_end FROM ud GROUP BY 1),
tgt AS (
  SELECT a.album_id, a.a_start, a.a_end, p.a_start AS p_start, p.a_end AS p_end
  FROM alb a LEFT JOIN alb p ON p.album_id = a.album_id - 1
  WHERE a.album_id IN (14,15)
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
tot AS (
  SELECT t.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN tgt t ON m.date_dim BETWEEN t.a_start AND DATE_SUB(t.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_close,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, uniq_close, alb_rev, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.p_start, t.p_end, u.alb_rev, u.uniq_close
  FROM u1 u JOIN tgt t USING (album_id)
  WHERE u.last_d = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
pm AS (
  SELECT p.album_id, p.user_id, ANY_VALUE(p.alb_rev) AS alb_rev, ANY_VALUE(p.uniq_close) AS uniq_close, ANY_VALUE(p.p_start) AS p_start,
    SAFE_DIVIDE(SUM(IF(m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY), m.rev, 0)),
      COUNTIF(m.act AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY))) AS prev_pd,
    SAFE_DIVIDE(SUM(IF(m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY), m.rev, 0)),
      COUNTIF(m.act AND m.date_dim BETWEEN p.a_start AND DATE_SUB(p.a_end, INTERVAL 1 DAY))) AS alb_pd
  FROM pop p LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN IFNULL(p.p_start, p.a_start) AND DATE_SUB(p.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
lab AS (
  SELECT x.album_id, x.alb_rev, label FROM pm x
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    IF(x.p_start IS NOT NULL, [CONCAT('grp_', CASE WHEN IFNULL(x.prev_pd, 0) = 0 THEN 'g0' WHEN x.prev_pd <= 2 THEN 'g1_le2'
      WHEN x.prev_pd <= 5 THEN 'g2_2_5' WHEN x.prev_pd <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END)], []),
    [CONCAT('end_', CASE WHEN x.uniq_close >= 144 THEN 'm0' WHEN x.uniq_close >= 141 THEN CONCAT('m', CAST(144 - x.uniq_close AS STRING)) ELSE 'm4p' END)],
    IF(x.alb_pd >= 20 AND x.uniq_close BETWEEN 141 AND 142, ['heavy_m23'], []),
    ['all_payers'])) AS label
)
SELECT l.album_id, l.label, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(IF(l.label = 'all_payers', COUNT(*), 0)) OVER (PARTITION BY l.album_id), 4) AS sh_payers,
  ROUND(SUM(l.alb_rev)) AS alb_rev,
  ROUND(SUM(l.alb_rev) / SUM(IF(l.label = 'all_payers', SUM(l.alb_rev), 0)) OVER (PARTITION BY l.album_id), 4) AS sh_std_rev,
  ROUND(SUM(l.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev,
  ROUND(ANY_VALUE(t.game_rev)) AS game_rev
FROM lab l JOIN tot t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;
