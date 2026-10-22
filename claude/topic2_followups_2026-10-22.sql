-- Topic 2 follow-ups (Eden 2026-10-22). Results: claude/topic2-followups-2026-10-22.md
-- E: end status (finished / 1-3 / 4+ missing) WITH first-album payers, share of game revenue: first_album_finish_rate_queries.sql with end status added
--    (Domino 19/20, Disney 14/15); Dice = the DICE FIX query from that file unchanged (it already splits by end status and new first-album flag).
-- W: Wild / Joker reach as a share of players (not only stickers per 100): EndWin queries unchanged up to the groups, then for days 4-1 before close:
--    players with >= 1 Wild/Joker-filled new sticker, and stickers per receiver. Dice uses the fixed first-album rule.
-- ===== W. Wild / Joker reach as share of players, last 4 days (Domino 19/20) =====
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d,
    DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend, IFNULL(a.active_flag, FALSE) AS act,
    144 - (IFNULL(a.unique_common_stickers_lt, 0) + IFNULL(a.unique_golden_stickers_lt, 0) + IFNULL(a.unique_royal_stickers_tl, 0)) AS miss
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND a.album_id IN (19, 20)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(n) AS n, CAST(CEIL(0.75 * ANY_VALUE(n)) AS INT64) AS cp,
    SUM(spend) AS total, MIN(d) AS first_d, SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far, MIN(miss) AS m_end,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row
  FROM r0 GROUP BY 1, 2),
tgt AS (
  SELECT album_id, user_id, a_start, n, total, so_far, m_end FROM ua
  WHERE last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1 AND first_d <= cp - 1),
p AS (
  SELECT album_id, user_id, a_start, n, total, so_far, m_end,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM tgt),
g AS (
  SELECT album_id, user_id, a_start, n, total,
    CASE WHEN pr < 0.5 THEN '1 weak' WHEN pr < 0.95 THEN '2 middle' ELSE '3 strong' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0),
gs AS (SELECT album_id, grp, st, COUNT(*) AS players, SUM(total) AS rev FROM g GROUP BY 1, 2, 3),
sk AS (
  SELECT g.album_id, g.grp, g.st, g.user_id, g.n, g.a_start, LOWER(s.sticker_type) AS typ, IFNULL(s.collected_by_joker_flag, FALSE) AS wild,
    s.new_sticker_mtx_campaign_name IS NOT NULL AS paid, s.sticker_collected_min_date AS cdate
  FROM g JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = g.album_id AND s.user_id = g.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND s.album_id IN (19, 20) AND s.user_collected_sticker_flag
  QUALIFY ROW_NUMBER() OVER (PARTITION BY g.album_id, g.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
wd AS (
  SELECT album_id, grp, st, COUNTIF(wild) AS wild_stickers, COUNT(DISTINCT IF(wild, user_id, NULL)) AS wild_users
  FROM sk WHERE n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 1 AND 4 GROUP BY 1, 2, 3)
SELECT gs.album_id, gs.grp, gs.st, gs.players, IFNULL(wd.wild_users, 0) AS wild_users, IFNULL(wd.wild_stickers, 0) AS wild_stickers,
  ROUND(100 * IFNULL(wd.wild_users, 0) / gs.players, 1) AS pct_players_with_wild,
  ROUND(100 * IFNULL(wd.wild_stickers, 0) / gs.players, 1) AS wild_per100,
  ROUND(SAFE_DIVIDE(wd.wild_stickers, wd.wild_users), 2) AS stickers_per_receiver
FROM gs LEFT JOIN wd USING (album_id, grp, st)
ORDER BY 1, 2, 3
;
-- ===== W. Wild / Joker reach as share of players, last 4 days (Disney 14/15) =====
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d,
    DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend, IFNULL(a.active_flag, FALSE) AS act,
    144 - (IFNULL(a.unique_common_stickers_lt, 0) + IFNULL(a.unique_golden_stickers_lt, 0) + IFNULL(a.unique_royal_stickers_tl, 0)) AS miss
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND a.album_id IN (14, 15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(n) AS n, CAST(CEIL(0.75 * ANY_VALUE(n)) AS INT64) AS cp,
    SUM(spend) AS total, MIN(d) AS first_d, SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far, MIN(miss) AS m_end,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row
  FROM r0 GROUP BY 1, 2),
tgt AS (
  SELECT album_id, user_id, a_start, n, total, so_far, m_end FROM ua
  WHERE last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1 AND first_d <= cp - 1),
p AS (
  SELECT album_id, user_id, a_start, n, total, so_far, m_end,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM tgt),
g AS (
  SELECT album_id, user_id, a_start, n, total,
    CASE WHEN pr < 0.5 THEN '1 weak' WHEN pr < 0.95 THEN '2 middle' ELSE '3 strong' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0),
gs AS (SELECT album_id, grp, st, COUNT(*) AS players, SUM(total) AS rev FROM g GROUP BY 1, 2, 3),
sk AS (
  SELECT g.album_id, g.grp, g.st, g.user_id, g.n, g.a_start, LOWER(s.sticker_type) AS typ, IFNULL(s.collected_by_joker_flag, FALSE) AS wild,
    s.new_sticker_mtx_campaign_name IS NOT NULL AS paid, s.sticker_collected_min_date AS cdate
  FROM g JOIN `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s ON s.album_id = g.album_id AND s.user_id = g.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND s.album_id IN (14, 15) AND s.user_collected_sticker_flag
  QUALIFY ROW_NUMBER() OVER (PARTITION BY g.album_id, g.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
wd AS (
  SELECT album_id, grp, st, COUNTIF(wild) AS wild_stickers, COUNT(DISTINCT IF(wild, user_id, NULL)) AS wild_users
  FROM sk WHERE n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 1 AND 4 GROUP BY 1, 2, 3)
SELECT gs.album_id, gs.grp, gs.st, gs.players, IFNULL(wd.wild_users, 0) AS wild_users, IFNULL(wd.wild_stickers, 0) AS wild_stickers,
  ROUND(100 * IFNULL(wd.wild_users, 0) / gs.players, 1) AS pct_players_with_wild,
  ROUND(100 * IFNULL(wd.wild_stickers, 0) / gs.players, 1) AS wild_per100,
  ROUND(SAFE_DIVIDE(wd.wild_stickers, wd.wild_users), 2) AS stickers_per_receiver
FROM gs LEFT JOIN wd USING (album_id, grp, st)
ORDER BY 1, 2, 3
;
-- ===== W. Wild / Joker reach as share of players, last 4 days (Dice 61/63) =====
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end, 35 AS n UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07', 42),
hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07'
  GROUP BY 1),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.a_start, alb.n,
    DATE_DIFF(a.date_dim, alb.a_start, DAY) AS d,
    a.album_login_ratio AS lr, h.first_album_seen < a.album_id AS returning,
    IFNULL(a.spent_in_album_today, 0) AS spend, IFNULL(a.is_active, FALSE) AS act,
    144 - IFNULL(a.unique_stickers_lt, 0) AS miss
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id) JOIN hist h USING (user_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
tgt AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_st, ANY_VALUE(n) AS n_, SUM(spend) AS total,
    SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far, MIN(miss) AS m_end
  FROM r0 GROUP BY 1, 2
  HAVING LOGICAL_AND(returning) AND MIN(d) <= CAST(CEIL(0.75 * ANY_VALUE(n)) AS INT64) - 1
     AND ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
p AS (
  SELECT album_id, user_id, a_st AS a_start, n_ AS n, total, so_far, m_end,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM tgt),
g AS (
  SELECT album_id, user_id, a_start, n, total,
    CASE WHEN pr < 0.5 THEN '1 weak' WHEN pr < 0.95 THEN '2 middle' ELSE '3 strong' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0),
gs AS (SELECT album_id, grp, st, COUNT(*) AS players, SUM(total) AS rev FROM g GROUP BY 1, 2, 3),
sk AS (
  SELECT g.album_id, g.grp, g.st, g.user_id, g.n, g.a_start, LOWER(s.sticker_type) AS typ, IFNULL(s.collected_from_wild, FALSE) AS wild,
    s.sticker_mtx_campaign_name IS NOT NULL AS paid, s.sticker_collected_date AS cdate
  FROM g JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = g.album_id AND s.user_id = g.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63) AND s.is_sticker_collected
  QUALIFY ROW_NUMBER() OVER (PARTITION BY g.album_id, g.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
wd AS (
  SELECT album_id, grp, st, COUNTIF(wild) AS wild_stickers, COUNT(DISTINCT IF(wild, user_id, NULL)) AS wild_users
  FROM sk WHERE n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 1 AND 4 GROUP BY 1, 2, 3)
SELECT gs.album_id, gs.grp, gs.st, gs.players, IFNULL(wd.wild_users, 0) AS wild_users, IFNULL(wd.wild_stickers, 0) AS wild_stickers,
  ROUND(100 * IFNULL(wd.wild_users, 0) / gs.players, 1) AS pct_players_with_wild,
  ROUND(100 * IFNULL(wd.wild_stickers, 0) / gs.players, 1) AS wild_per100,
  ROUND(SAFE_DIVIDE(wd.wild_stickers, wd.wild_users), 2) AS stickers_per_receiver
FROM gs LEFT JOIN wd USING (album_id, grp, st)
ORDER BY 1, 2, 3
;

-- ===== E. End status with first-album payers (Domino 19/20) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) <= 1 AS first_alb, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
alb AS (SELECT album_id, MIN(a_start) AS a_start, MIN(a_end) AS a_end FROM ud GROUP BY 1),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(special_user_flag,FALSE) OR IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
tot AS (
  SELECT a.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN alb a ON m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_close,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS spend_incl_close, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, first_alb, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, uniq_close, alb_rev, spend_incl_close, last_d, l.lr AS lr, l.first_alb AS first_alb, l.excl AS excl FROM u0),
pop AS (
  SELECT album_id, first_alb, alb_rev,
    CASE WHEN uniq_close >= 144 THEN 'm0' WHEN uniq_close >= 141 THEN 'm1_3' ELSE 'm4p' END AS end_status
  FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND NOT excl AND lr >= 0.5 AND spend_incl_close > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
)
SELECT p.album_id, p.first_alb, p.end_status, COUNT(*) AS payers, ROUND(SUM(p.alb_rev)) AS rev,
  ROUND(SUM(p.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev, ROUND(ANY_VALUE(t.game_rev)) AS game_rev
FROM pop p JOIN tot t USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2,3
;

-- ===== E. End status with first-album payers (Disney 14/15) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) <= 1 AS first_alb, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
alb AS (SELECT album_id, MIN(a_start) AS a_start, MIN(a_end) AS a_end FROM ud GROUP BY 1),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-05'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
tot AS (
  SELECT a.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN alb a ON m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_close,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS spend_incl_close, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, first_alb, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, uniq_close, alb_rev, spend_incl_close, last_d, l.lr AS lr, l.first_alb AS first_alb, l.excl AS excl FROM u0),
pop AS (
  SELECT album_id, first_alb, alb_rev,
    CASE WHEN uniq_close >= 144 THEN 'm0' WHEN uniq_close >= 141 THEN 'm1_3' ELSE 'm4p' END AS end_status
  FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND NOT excl AND lr >= 0.5 AND spend_incl_close > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
)
SELECT p.album_id, p.first_alb, p.end_status, COUNT(*) AS payers, ROUND(SUM(p.alb_rev)) AS rev,
  ROUND(SUM(p.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev, ROUND(ANY_VALUE(t.game_rev)) AS game_rev
FROM pop p JOIN tot t USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2,3
;

-- ===== E. End status with first-album payers (Dice 61/63) = DICE FIX query =====
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MIN(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id IN (61,63)
  GROUP BY 1
),
hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07'
  GROUP BY 1
),
ud AS (
  SELECT d.album_id, d.user_id, d.date_dim, a.a_end,
    IFNULL(d.unique_common_stickers_lt,0) + IFNULL(d.unique_golden_stickers_lt,0) + IFNULL(d.unique_super_stickers_lt,0) AS uniq,
    d.album_login_ratio_until_this_day AS lr, IFNULL(d.user_past_album_count,0) = 0 AS old_first, IFNULL(d.is_excluded,FALSE) AS excl,
    IFNULL(d.spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` d JOIN alb a USING (album_id)
  WHERE d.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND d.album_id IN (61,63) AND d.date_dim <= a.a_end
),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= a.a_end
  GROUP BY 1,2
),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
tot AS (
  SELECT a.album_id, SUM(IFNULL(m.revenues_sum,0)) AS game_rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m JOIN alb a ON m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE m.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND m.user_id NOT IN (SELECT user_id FROM excl)
  GROUP BY 1
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_prev,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS spend_incl_close,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, old_first, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, uniq_prev, alb_rev, spend_incl_close, last_d, l.lr AS lr, l.old_first AS old_first, l.excl AS excl FROM u0),
pop AS (
  SELECT u.album_id, u.old_first, h.first_album_seen = u.album_id AS new_first, u.alb_rev,
    GREATEST(IFNULL(s.n_uniq,0), IFNULL(u.uniq_prev,0)) AS uniq_close
  FROM u1 u LEFT JOIN st s USING (album_id, user_id) LEFT JOIN hist h USING (user_id)
  WHERE u.last_d = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND NOT u.excl AND u.lr >= 0.5 AND u.spend_incl_close > 0
)
SELECT p.album_id, p.old_first, p.new_first,
  CASE WHEN p.uniq_close >= 144 THEN 'm0' WHEN p.uniq_close >= 141 THEN CONCAT('m', CAST(144 - p.uniq_close AS STRING)) ELSE 'm4p' END AS end_status,
  COUNT(*) AS payers, ROUND(SUM(p.alb_rev)) AS rev, ROUND(ANY_VALUE(t.game_rev)) AS game_rev
FROM pop p JOIN tot t USING (album_id)
GROUP BY 1,2,3,4 ORDER BY 1,2,3,4
;
