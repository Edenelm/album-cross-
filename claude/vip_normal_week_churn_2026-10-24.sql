-- Eden 2026-10-24: VIP review, step 3 (normal-week check) + churn after close.
-- Same population and status as vip_status_recount_2026-10-24.sql (standard population, payer incl. close day,
-- status at the END of the close day; Dice from the sticker table). Tiers: VIP $5K+ and $1K-5K (LTV at album start).
-- Usual pace = $ a day in album days 0-20. Windows vs usual pace:
--   mid7 = album days 21-27 (a normal mid-album week, no close); after7 = close+1..+7; after28 = close+1..+28 (next album table).
-- Churn = no active day in close+15..+28 (next album table: Dice is_active, Domino / Disney active_flag).
-- Albums with 28 days after close: Dice 63 (next 65), Domino 19 (next 20), Disney 14 (next 15).
-- Results: claude/vip-review-2026-10-24.md

-- ===== DOMINO 19 -> 20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, ltv_on_album_start AS ltv
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-08-24' AND album_id = 19 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-09-21' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end, MAX(ltv) AS ltv,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev, SUM(spend) AS spend_incl_close,
    SUM(IF(DATE_DIFF(date_dim, a_start, DAY) BETWEEN 0 AND 20, spend, 0)) AS s_a,
    SUM(IF(DATE_DIFF(date_dim, a_start, DAY) BETWEEN 21 AND 27, spend, 0)) AS s_b,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1),
pop AS (
  SELECT user_id, rev, s_a, s_b,
    CASE WHEN ltv >= 5000 THEN '1_VIP_5K+' ELSE '2_1K-5K' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 141 THEN 'b_1-3' ELSE 'c_4plus' END AS status
  FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND spend_incl_close > 0
    AND ltv >= 1000 AND user_id NOT IN (SELECT user_id FROM bad)),
nx AS (
  SELECT user_id,
    SUM(IF(date_dim <= DATE '2026-08-31', IFNULL(album_spent_today,0), 0)) AS after7,
    SUM(IFNULL(album_spent_today,0)) AS after28,
    COUNTIF(date_dim >= DATE '2026-09-08' AND IFNULL(active_flag,FALSE)) AS act_15_28
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-25' AND DATE '2026-09-21' AND album_id = 20
  GROUP BY 1)
SELECT tier, status, COUNT(1) AS n, ROUND(SUM(rev)) AS rev, ROUND(SUM(s_a) / 21) AS pace_day, ROUND(SUM(s_b)) AS mid7,
  ROUND(SUM(IFNULL(x.after7,0))) AS after7, ROUND(SUM(IFNULL(x.after28,0))) AS after28,
  COUNTIF(IFNULL(x.act_15_28,0) = 0) AS churned_15_28
FROM pop p LEFT JOIN nx x USING (user_id) GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DISNEY 14 -> 15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, ltv_on_album_start AS ltv
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-08-24' AND album_id = 14 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-09-21' AND exclude_reason IS NOT NULL),
u AS (
  SELECT user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end, MAX(ltv) AS ltv,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev, SUM(spend) AS spend_incl_close,
    SUM(IF(DATE_DIFF(date_dim, a_start, DAY) BETWEEN 0 AND 20, spend, 0)) AS s_a,
    SUM(IF(DATE_DIFF(date_dim, a_start, DAY) BETWEEN 21 AND 27, spend, 0)) AS s_b,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1),
pop AS (
  SELECT user_id, rev, s_a, s_b,
    CASE WHEN ltv >= 5000 THEN '1_VIP_5K+' ELSE '2_1K-5K' END AS tier,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 141 THEN 'b_1-3' ELSE 'c_4plus' END AS status
  FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND spend_incl_close > 0
    AND ltv >= 1000 AND user_id NOT IN (SELECT user_id FROM bad)),
nx AS (
  SELECT user_id,
    SUM(IF(date_dim <= DATE '2026-08-31', IFNULL(album_spent_today,0), 0)) AS after7,
    SUM(IFNULL(album_spent_today,0)) AS after28,
    COUNTIF(date_dim >= DATE '2026-09-08' AND IFNULL(active_flag,FALSE)) AS act_15_28
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-25' AND DATE '2026-09-21' AND album_id = 15
  GROUP BY 1)
SELECT tier, status, COUNT(1) AS n, ROUND(SUM(rev)) AS rev, ROUND(SUM(s_a) / 21) AS pace_day, ROUND(SUM(s_b)) AS mid7,
  ROUND(SUM(IFNULL(x.after7,0))) AS after7, ROUND(SUM(IFNULL(x.after28,0))) AS after28,
  COUNTIF(IFNULL(x.act_15_28,0) = 0) AS churned_15_28
FROM pop p LEFT JOIN nx x USING (user_id) GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DICE 63 -> 65 (dice-dreams-dbt) =====
WITH hist AS (SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(album_login_ratio,-1) AS lr,
    IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend, ltv_until_album_start AS ltv
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date),
u AS (
  SELECT a.user_id, ANY_VALUE(a.a_end) AS a_end, MAX(a.ltv) AS ltv,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS rev, SUM(a.spend) AS spend_incl_close,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) BETWEEN 0 AND 20, a.spend, 0)) AS s_a,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) BETWEEN 21 AND 27, a.spend, 0)) AS s_b,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < 63 AND NOT LOGICAL_OR(a.excl) AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1),
pop0 AS (SELECT user_id, a_end, rev, s_a, s_b, ltv FROM u WHERE ok AND spend_incl_close > 0 AND ltv >= 1000),
st AS (
  SELECT s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop0 p USING (user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND s.album_id = 63
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1),
pop AS (
  SELECT p.user_id, p.rev, p.s_a, p.s_b,
    CASE WHEN p.ltv >= 5000 THEN '1_VIP_5K+' ELSE '2_1K-5K' END AS tier,
    CASE WHEN IFNULL(s.n_uniq,0) >= 144 THEN 'a_finished' WHEN IFNULL(s.n_uniq,0) >= 141 THEN 'b_1-3' ELSE 'c_4plus' END AS status
  FROM pop0 p LEFT JOIN st s USING (user_id)),
nx AS (
  SELECT user_id,
    SUM(IF(date_dim <= DATE '2026-09-14', IFNULL(spent_in_album_today,0), 0)) AS after7,
    SUM(IFNULL(spent_in_album_today,0)) AS after28,
    COUNTIF(date_dim >= DATE '2026-09-22' AND IFNULL(is_active,FALSE)) AS act_15_28
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-09-08' AND DATE '2026-10-05' AND album_id = 65
  GROUP BY 1)
SELECT tier, status, COUNT(1) AS n, ROUND(SUM(rev)) AS rev, ROUND(SUM(s_a) / 21) AS pace_day, ROUND(SUM(s_b)) AS mid7,
  ROUND(SUM(IFNULL(x.after7,0))) AS after7, ROUND(SUM(IFNULL(x.after28,0))) AS after28,
  COUNTIF(IFNULL(x.act_15_28,0) = 0) AS churned_15_28
FROM pop p LEFT JOIN nx x USING (user_id) GROUP BY 1, 2 ORDER BY 1, 2;
