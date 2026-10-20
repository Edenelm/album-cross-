-- Payer includes the close day (Eden, 2026-10-20). Results: claude/payer-close-day-2026-10-20.md
-- pay_old = album-table spend > 0 start..close-1; pay_new = start..close day. Revenue stays start..close-1.

-- ===== DICE 59/61/63 (dice-dreams-dbt, 22.1 GB) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev_old, SUM(IF(date_dim = a_end, spend, 0)) AS rev_close,
    MAX(IF(date_dim = a_end, 1, 0)) AS has_close_row,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, rev_old, rev_close, has_close_row FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (59,61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2
),
j AS (
  SELECT p.album_id, p.rev_old, p.rev_close, p.has_close_row, IFNULL(s.n_uniq, 0) >= 144 AS fin,
    p.rev_old > 0 AS pay_old, p.rev_old + p.rev_close > 0 AS pay_new
  FROM pop p LEFT JOIN st s USING (album_id, user_id)
)
SELECT album_id, COUNT(*) AS n, COUNTIF(has_close_row = 1) AS with_close_row,
  COUNTIF(pay_old) AS payers_old, COUNTIF(pay_new) AS payers_new, COUNTIF(pay_new AND NOT pay_old) AS close_only_payers,
  ROUND(SUM(IF(pay_new AND NOT pay_old, rev_close, 0))) AS close_only_rev, ROUND(SUM(rev_close)) AS close_day_rev_all, ROUND(SUM(rev_old)) AS rev_old,
  COUNTIF(fin) AS fin_all, COUNTIF(fin AND pay_old) AS fin_pay_old, COUNTIF(fin AND pay_new) AS fin_pay_new,
  COUNTIF(fin AND pay_new AND NOT pay_old) AS fin_close_only
FROM j GROUP BY 1 ORDER BY 1;

-- ===== DOMINO 17/19/20 (domino-dreams-dbt, 16.4 GB) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) >= 144 AS fin,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev_old, SUM(IF(date_dim = a_end, spend, 0)) AS rev_close,
    MAX(IF(date_dim = a_end, 1, 0)) AS has_close_row,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
j AS (
  SELECT album_id, fin, rev_old, rev_close, has_close_row, rev_old > 0 AS pay_old, rev_old + rev_close > 0 AS pay_new FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
)
SELECT album_id, COUNT(*) AS n, COUNTIF(has_close_row = 1) AS with_close_row,
  COUNTIF(pay_old) AS payers_old, COUNTIF(pay_new) AS payers_new, COUNTIF(pay_new AND NOT pay_old) AS close_only_payers,
  ROUND(SUM(IF(pay_new AND NOT pay_old, rev_close, 0))) AS close_only_rev, ROUND(SUM(rev_close)) AS close_day_rev_all, ROUND(SUM(rev_old)) AS rev_old,
  COUNTIF(fin) AS fin_all, COUNTIF(fin AND pay_old) AS fin_pay_old, COUNTIF(fin AND pay_new) AS fin_pay_new,
  COUNTIF(fin AND pay_new AND NOT pay_old) AS fin_close_only
FROM j GROUP BY 1 ORDER BY 1;

-- ===== DISNEY 12/14/15 (solitaire-dreams-411507, 39.3 GB) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-05' AND album_id IN (12,14,15) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) >= 144 AS fin,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev_old, SUM(IF(date_dim = a_end, spend, 0)) AS rev_close,
    MAX(IF(date_dim = a_end, 1, 0)) AS has_close_row,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
j AS (
  SELECT album_id, fin, rev_old, rev_close, has_close_row, rev_old > 0 AS pay_old, rev_old + rev_close > 0 AS pay_new FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
)
SELECT album_id, COUNT(*) AS n, COUNTIF(has_close_row = 1) AS with_close_row,
  COUNTIF(pay_old) AS payers_old, COUNTIF(pay_new) AS payers_new, COUNTIF(pay_new AND NOT pay_old) AS close_only_payers,
  ROUND(SUM(IF(pay_new AND NOT pay_old, rev_close, 0))) AS close_only_rev, ROUND(SUM(rev_close)) AS close_day_rev_all, ROUND(SUM(rev_old)) AS rev_old,
  COUNTIF(fin) AS fin_all, COUNTIF(fin AND pay_old) AS fin_pay_old, COUNTIF(fin AND pay_new) AS fin_pay_new,
  COUNTIF(fin AND pay_new AND NOT pay_old) AS fin_close_only
FROM j GROUP BY 1 ORDER BY 1;

-- ===== DOMINO 20 two-Puzzle closers with close-day payer flag (domino-dreams-dbt, 17.1 GB) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-12'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
alb AS (SELECT album_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM ud GROUP BY 1),
u AS (
  SELECT user_id, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev_alb, SUM(IF(date_dim = a_end, spend, 0)) AS rev_close,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud WHERE album_id = 20 GROUP BY 1
),
pop0 AS (
  SELECT user_id, a_end, fin_d, rev_alb, rev_close FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
tot AS (SELECT SUM(rev_alb) AS pop_rev FROM pop0),
pop AS (SELECT user_id, a_end, fin_d, rev_alb, rev_close FROM pop0 WHERE fin_d IS NOT NULL),
prv_rev AS (
  SELECT u.user_id, SUM(u.spend) AS rev_prev FROM ud u JOIN alb a USING (album_id)
  WHERE u.album_id = 19 AND u.date_dim < a.a_end AND u.user_id IN (SELECT user_id FROM pop) GROUP BY 1
),
prv_act AS (
  SELECT m.user_id, COUNTIF(m.act) AS ad_prev FROM udm m JOIN alb a ON a.album_id = 19
  WHERE m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY) AND m.user_id IN (SELECT user_id FROM pop) GROUP BY 1
),
st AS (
  SELECT p.user_id, s.sticker_collected_min_ts AS ts, s.sticker_collected_min_date AS d, IFNULL(s.new_sticker_source, '') AS src
  FROM pop p JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = 20 AND s.user_id = p.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-01' AND DATE '2026-10-12' AND s.album_id = 20 AND s.user_collected_sticker_flag
    AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= p.fin_d
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
last2 AS (
  SELECT user_id, COUNTIF(src = 'Puzzle') AS puz2
  FROM (SELECT user_id, src FROM st QUALIFY ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY ts DESC) <= 2)
  GROUP BY 1
),
d AS (
  SELECT p.user_id, p.fin_d < p.a_end AS fin_old, p.rev_alb, p.rev_alb > 0 AS payer, p.rev_alb + p.rev_close > 0 AS payer_c,
    IFNULL(SAFE_DIVIDE(r.rev_prev, a.ad_prev), 0) >= 5 AS strong,
    IFNULL(l.puz2, 0) = 2 AS both_puzzle
  FROM pop p LEFT JOIN prv_rev r USING (user_id) LEFT JOIN prv_act a USING (user_id) LEFT JOIN last2 l USING (user_id)
)
SELECT rule, COUNT(*) AS finishers, COUNTIF(both_puzzle) AS two_puzzle,
  COUNTIF(both_puzzle AND payer) AS two_puzzle_paid, COUNTIF(both_puzzle AND NOT payer) AS two_puzzle_nonpay, COUNTIF(both_puzzle AND payer_c) AS two_puzzle_paid_c, COUNTIF(payer_c) AS fin_paid_c,
  COUNTIF(both_puzzle AND strong) AS two_puzzle_strong, ROUND(SUM(IF(both_puzzle AND strong, rev_alb, 0))) AS strong_rev,
  ROUND(SUM(IF(both_puzzle, rev_alb, 0))) AS two_puzzle_rev, ROUND(ANY_VALUE(tot.pop_rev)) AS pop_rev
FROM d CROSS JOIN tot CROSS JOIN UNNEST(IF(fin_old, ['old', 'new'], ['new'])) AS rule
GROUP BY 1 ORDER BY 1
;