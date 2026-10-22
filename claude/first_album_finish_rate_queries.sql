-- Finish rate and finisher revenue share WITH vs WITHOUT first-album players (Eden, 2026-10-21). Results: claude/first-album-finish-rate-2026-10-21.md
-- Population: not excluded, login ratio >= 0.5 on the last row before close, row on close-1 (standard population filters),
--   split by first album (first_alb = TRUE) vs not. "Without" = the standard population; "with" = both rows summed.
-- Payer = album-table spend > 0 start..close day (Eden 2026-10-20). Revenue = album-table spend start..close-1.
-- Finisher = 144 unique set stickers by the end of the close day (Dice: sticker table).
-- sh_game_rev denominator = total game purchase revenue start..close-1, all players, excluded removed (opening-facts-2026-10-20).

-- ===== DICE 61/63 (dice-dreams-dbt) =====
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MIN(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id IN (61,63)
  GROUP BY 1
),
ud AS (
  SELECT d.album_id, d.user_id, d.date_dim, a.a_end,
    IFNULL(d.unique_common_stickers_lt,0) + IFNULL(d.unique_golden_stickers_lt,0) + IFNULL(d.unique_super_stickers_lt,0) AS uniq,
    d.album_login_ratio_until_this_day AS lr, IFNULL(d.user_past_album_count,0) = 0 AS first_alb, IFNULL(d.is_excluded,FALSE) AS excl,
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
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, first_alb, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, uniq_prev, alb_rev, spend_incl_close, last_d, l.lr AS lr, l.first_alb AS first_alb, l.excl AS excl FROM u0),
pop AS (
  SELECT u.album_id, u.first_alb, u.alb_rev, GREATEST(IFNULL(s.n_uniq,0), IFNULL(u.uniq_prev,0)) >= 144 AS fin
  FROM u1 u LEFT JOIN st s USING (album_id, user_id)
  WHERE u.last_d = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND NOT u.excl AND u.lr >= 0.5 AND u.spend_incl_close > 0
)
SELECT p.album_id, p.first_alb, COUNT(*) AS payers, COUNTIF(p.fin) AS finishers,
  ROUND(SUM(p.alb_rev)) AS payer_rev, ROUND(SUM(IF(p.fin, p.alb_rev, 0))) AS fin_rev, ROUND(ANY_VALUE(t.game_rev)) AS game_rev
FROM pop p JOIN tot t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DOMINO 17/19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) <= 1 AS first_alb, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim <= album_close_date
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
  SELECT album_id, first_alb, alb_rev, uniq_close >= 144 AS fin
  FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND NOT excl AND lr >= 0.5 AND spend_incl_close > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
)
SELECT p.album_id, p.first_alb, COUNT(*) AS payers, COUNTIF(p.fin) AS finishers,
  ROUND(SUM(p.alb_rev)) AS payer_rev, ROUND(SUM(IF(p.fin, p.alb_rev, 0))) AS fin_rev, ROUND(ANY_VALUE(t.game_rev)) AS game_rev
FROM pop p JOIN tot t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507) =====
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
  SELECT album_id, first_alb, alb_rev, uniq_close >= 144 AS fin
  FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND NOT excl AND lr >= 0.5 AND spend_incl_close > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
)
SELECT p.album_id, p.first_alb, COUNT(*) AS payers, COUNTIF(p.fin) AS finishers,
  ROUND(SUM(p.alb_rev)) AS payer_rev, ROUND(SUM(IF(p.fin, p.alb_rev, 0))) AS fin_rev, ROUND(ANY_VALUE(t.game_rev)) AS game_rev
FROM pop p JOIN tot t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DICE label check: album-63 players with user_past_album_count = 0 who also have rows in album 61 (3 GB) =====
WITH a63 AS (
  SELECT user_id, IFNULL(user_past_album_count, -1) AS past_cnt, IFNULL(spent_in_album_today,0) AS sp
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-06' AND album_id = 63
),
u63 AS (SELECT user_id, MIN(past_cnt) AS past_min, MAX(past_cnt) AS past_max, SUM(sp) AS rev FROM a63 GROUP BY 1),
in61 AS (
  SELECT DISTINCT user_id FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-07-31' AND album_id = 61
)
SELECT CASE WHEN u.past_max = -1 THEN 'null' WHEN u.past_max = 0 THEN 'zero' ELSE 'pos' END AS past_cnt,
  COUNT(*) AS users, COUNTIF(u.rev > 0) AS payers, ROUND(SUM(u.rev)) AS rev,
  COUNTIF(i.user_id IS NOT NULL) AS also_in_61, COUNTIF(i.user_id IS NOT NULL AND u.rev > 0) AS payers_in_61,
  ROUND(SUM(IF(i.user_id IS NOT NULL, u.rev, 0))) AS rev_in_61
FROM u63 u LEFT JOIN in61 i USING (user_id)
GROUP BY 1 ORDER BY 1
;

-- ===== DICE FIX (Eden 2026-10-21): first album = no row in any earlier album of user_daily_album (history from 2023-11-07) =====
-- Replaces user_past_album_count = 0. 152 GB. Output split by old flag x new flag x end status, so old and new standard populations can both be read.
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
