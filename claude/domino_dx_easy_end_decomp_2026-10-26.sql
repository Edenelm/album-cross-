-- 2026-10-26 Domino: what explains the Easy end-of-album ARPDAU lift? Albums 17-20, Easy, standard population
-- (not first album, not special / suspected cheater, login_ratio >= 0.5 on the last row before close, a row on close-1; segment = first row).
-- Windows: last4 = close-4 .. close-1 (close day excluded), rest = open .. close-5. Same as domino_dx_end_lift Q5.
-- ARPDAU = revenue / active player-days = (payer-days / active player-days) x (purchases / payer-day) x ($ / purchase).
-- Revenue = in-app + Stripe gross (user_daily_metrics). Purchases = distinct external_order_id in core_purchase with total_usd_amount > 0, per user-day.
-- Contribution = ln(component ratio) / ln(ARPDAU ratio), so the three contributions add up to 100%.
-- Q1: decomposition
WITH al AS (
  SELECT 17 AS album_id, DATE '2026-04-02' AS d0, DATE '2026-05-11' AS d1 UNION ALL
  SELECT 18, DATE '2026-05-11', DATE '2026-07-06' UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
ab AS (
  SELECT t.album_id, t.user_id, t.date_dim, t.album_segment AS seg, IFNULL(t.user_album_count,1) AS uac, IFNULL(t.special_user_flag,FALSE) AS excl, t.login_ratio AS lr, a.d1
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` t JOIN al a ON t.album_id = a.album_id
  WHERE t.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND t.date_dim >= a.d0 AND t.date_dim < a.d1
),
pop AS (
  SELECT album_id, user_id,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', IF(LOWER(seg) LIKE '%hard%', 'hard', 'other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    ARRAY_AGG(uac ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS uac0, LOGICAL_OR(excl) AS excl,
    MAX(date_dim) AS last_d, ANY_VALUE(d1) AS d1, ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS lr_last
  FROM ab GROUP BY 1,2
),
p2 AS (
  SELECT album_id, user_id FROM pop
  WHERE seg0 = 'easy' AND uac0 > 1 AND NOT excl AND lr_last >= 0.5 AND last_d = DATE_SUB(d1, INTERVAL 1 DAY)
    AND user_id NOT IN (SELECT user_id FROM bad)
),
pur AS (
  SELECT c.user_id, c.date_dim, COUNT(DISTINCT c.external_order_id) AS n_pur
  FROM `domino-dreams-dbt.prod_20_core.core_purchase` c
  WHERE c.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-11' AND IFNULL(c.total_usd_amount,0) > 0
  GROUP BY 1,2
),
d AS (
  SELECT a.album_id, IF(u.date_dim >= DATE_SUB(a.d1, INTERVAL 4 DAY), 'last4', 'rest') AS per,
    COUNTIF(IFNULL(u.pau_flag,FALSE)) AS act_days,
    COUNTIF(IFNULL(u.pu_flag,FALSE)) AS pay_days,
    SUM(IFNULL(u.user_daily_inapp_purchase_amount,0) + IFNULL(u.user_daily_stripe_amount,0)) AS rev,
    SUM(IFNULL(q.n_pur,0)) AS n_pur,
    COUNT(DISTINCT u.date_dim) AS days
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` u
  JOIN al a ON u.date_dim >= a.d0 AND u.date_dim < a.d1
  JOIN p2 p ON p.user_id = u.user_id AND p.album_id = a.album_id
  LEFT JOIN pur q ON q.user_id = u.user_id AND q.date_dim = u.date_dim
  WHERE u.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12'
  GROUP BY 1,2
),
g AS (
  SELECT album_id, per, days, act_days, pay_days, rev, n_pur,
    rev / act_days AS arpdau, pay_days / act_days AS pay_rate, n_pur / pay_days AS pur_per_payday, rev / n_pur AS usd_per_pur
  FROM d
)
SELECT l.album_id, l.days AS last_days, r.days AS rest_days,
  ROUND(r.act_days / r.days) AS act_per_day_rest, ROUND(l.act_days / l.days) AS act_per_day_last4,
  ROUND(r.arpdau, 3) AS arpdau_rest, ROUND(l.arpdau, 3) AS arpdau_last4, ROUND(100 * (l.arpdau / r.arpdau - 1), 1) AS arpdau_lift_pct,
  ROUND(100 * r.pay_rate, 2) AS pay_rate_rest, ROUND(100 * l.pay_rate, 2) AS pay_rate_last4, ROUND(100 * (l.pay_rate / r.pay_rate - 1), 1) AS pay_rate_lift_pct,
  ROUND(r.pur_per_payday, 3) AS pur_per_payday_rest, ROUND(l.pur_per_payday, 3) AS pur_per_payday_last4, ROUND(100 * (l.pur_per_payday / r.pur_per_payday - 1), 1) AS freq_lift_pct,
  ROUND(r.usd_per_pur, 2) AS usd_per_pur_rest, ROUND(l.usd_per_pur, 2) AS usd_per_pur_last4, ROUND(100 * (l.usd_per_pur / r.usd_per_pur - 1), 1) AS price_lift_pct,
  ROUND(100 * LN(l.pay_rate / r.pay_rate) / LN(l.arpdau / r.arpdau), 0) AS contrib_pay_rate_pct,
  ROUND(100 * LN(l.pur_per_payday / r.pur_per_payday) / LN(l.arpdau / r.arpdau), 0) AS contrib_freq_pct,
  ROUND(100 * LN(l.usd_per_pur / r.usd_per_pur) / LN(l.arpdau / r.arpdau), 0) AS contrib_price_pct
FROM g l JOIN g r ON l.album_id = r.album_id AND l.per = 'last4' AND r.per = 'rest'
ORDER BY 1;

-- Q2: did more players start paying, or did non-payers' activity fall more? Same population (p2 CTE as Q1).
-- payers_rest = paid on any day open..close-5; payers_last4 = paid in close-4..close-1; new_payers_last4 = paid in last4 and never before in the album.
-- wk1 = the same Thursday-Sunday one week earlier (k = 8..11, k = days before the close date); new_payers_wk1 = first album payment in that block.
-- act_rate = active player-days / (players x days) per group and window; prior payers = paid before close-4.
-- (text: replace the m/d/g CTEs of Q1 with)
--   m AS (SELECT a.album_id, u.user_id, DATE_DIFF(a.d1, u.date_dim, DAY) AS k, IFNULL(u.pau_flag,FALSE) AS act, IFNULL(u.pu_flag,FALSE) AS pu
--         FROM user_daily_metrics u JOIN al a ON u.date_dim >= a.d0 AND u.date_dim < a.d1 JOIN p2 p ON p.user_id = u.user_id AND p.album_id = a.album_id
--         WHERE u.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12'),
--   usr AS (SELECT album_id, user_id, LOGICAL_OR(pu AND k > 4) AS paid_rest, LOGICAL_OR(pu AND k <= 4) AS paid_last4,
--           LOGICAL_OR(pu AND k BETWEEN 8 AND 11) AS paid_wk1, LOGICAL_OR(pu AND k > 11) AS paid_before_wk1, LOGICAL_OR(pu AND k BETWEEN 5 AND 11) AS paid_wk1_7,
--           COUNTIF(act AND k <= 4) AS act_last4, COUNTIF(act AND k > 4) AS act_rest FROM m GROUP BY 1,2),
--   cnt AS (SELECT album_id, COUNT(*) AS players, COUNTIF(paid_rest) AS payers_rest, COUNTIF(paid_last4) AS payers_last4,
--           COUNTIF(paid_last4 AND NOT paid_rest) AS new_payers_last4, COUNTIF(paid_wk1) AS payers_wk1, COUNTIF(paid_wk1 AND NOT paid_before_wk1) AS new_payers_wk1,
--           COUNTIF(paid_last4 AND NOT paid_wk1_7) AS payers_last4_not_prev7, COUNTIF(paid_rest AND NOT paid_last4) AS prior_payers_silent_last4,
--           SUM(IF(paid_rest, act_last4, 0)) / NULLIF(COUNTIF(paid_rest),0) / 4 AS act_pp_last4_prior_payers,
--           SUM(IF(paid_rest, act_rest, 0)) / NULLIF(COUNTIF(paid_rest),0) / ANY_VALUE(rest_days) AS act_pp_rest_prior_payers,
--           SUM(IF(NOT paid_rest, act_last4, 0)) / NULLIF(COUNTIF(NOT paid_rest),0) / 4 AS act_pp_last4_nonpayers,
--           SUM(IF(NOT paid_rest, act_rest, 0)) / NULLIF(COUNTIF(NOT paid_rest),0) / ANY_VALUE(rest_days) AS act_pp_rest_nonpayers
--           FROM usr JOIN (SELECT album_id, DATE_DIFF(d1, d0, DAY) - 4 AS rest_days FROM al) USING (album_id) GROUP BY 1)
--   SELECT album_id, players, payers_rest, payers_last4, new_payers_last4, payers_wk1, new_payers_wk1, payers_last4_not_prev7, prior_payers_silent_last4,
--     act_pp_* (x100) FROM cnt ORDER BY 1

-- Q3: purchases by price bucket (core_purchase, total_usd_amount, distinct external_order_id) per day, last4 vs rest, and concentration
-- (share of window revenue from the top 1% / top 10% of that window's payers, PERCENT_RANK on revenue). Same population.
--   pc AS (SELECT a.album_id, c.user_id, IF(c.date_dim >= DATE_SUB(a.d1, INTERVAL 4 DAY), 'last4', 'rest') AS per, DATE_DIFF(a.d1, a.d0, DAY) - 4 AS rest_days,
--          c.external_order_id AS oid, MAX(c.total_usd_amount) AS usd FROM core_purchase c JOIN al a ON c.date_dim >= a.d0 AND c.date_dim < a.d1
--          JOIN p2 p ON p.user_id = c.user_id AND p.album_id = a.album_id WHERE c.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-11' AND IFNULL(c.total_usd_amount,0) > 0 GROUP BY 1,2,3,4,5),
--   buckets: <5, 5-10, 10-20, 20-50, 50+ -> n per day, revenue per day, revenue share, extra revenue per day (last4 - rest);
--   concentration: pu AS (SELECT album_id, per, user_id, SUM(usd) AS rev FROM pc GROUP BY 1,2,3), rk AS (PERCENT_RANK() OVER (PARTITION BY album_id, per ORDER BY rev DESC)),
--   top1_share = SUM(IF(pr < 0.01, rev, 0)) / SUM(rev), top10_share likewise.

-- Q4: which offers gave the extra dollars (staging, approved by Eden 2026-10-26 for this topic: domino-dreams-dbt.prod_10_staging.stg_purchase_completed_vw).
-- camp = COALESCE(mtx_campaign_name, mtx_event_name, source, '(none)'); deduped by user + timestamp + external_order_id; usd_amount > 0; same population.
-- Q4a: top 7 campaigns per album by extra revenue per day (last4 - rest). Single offers carry their own dates, so they all look "new" at the end.
-- Q4b: grouped by offer type: '1_album_sticker_joker_offers' = name contains sticker|golden|joker|album|puzzle; '3_store'; '4_none'; '2_other_offers' = other |t_Offer| / st_ names;
--   and by the czw_ tag in the name (price weight vs comfort zone: >= 1 vs < 1 vs no tag). Output: n/day, revenue/day, extra/day, revenue share, $ per purchase, rest vs last4.

-- Q5 (Eden: how could album 17 have no locked stickers?): album 17 golden/royal stickers by Easy/Hard (segment = first album row):
-- release proxy = first day with >= 200 non-joker first collections; share collected by joker; share collected in the last 7 days (>= 2026-05-04);
-- top 3 non-joker sources (new_sticker_source). Source: prod_30_intermediate.int_user_album_stickers (user_collected_sticker_flag, collected_by_joker_flag).
-- Filter shown: sh_joker >= 0.2 OR release >= 2026-04-27 OR no release. Result: Easy R108 + G104/G106/G130 = scarce end stickers (20-50K collectors, 70-91% in the last week),
-- 27-32% by joker, main routes Market (duplicates), Empty / 1po offers, Temple/Blast/Pixel events -> my ">= 50% joker" rule missed them. "Gate 0" was wrong; 17 = 4 scarce end stickers, open routes.

-- ===== Domino chapter (Eden 2026-10-26): last-3-sticker sources + far-Easy verification. Results: claude/domino-dx-last3-sources-2026-10-26.md =====
-- Q6: sources of the last 3 stickers of finishers, albums 17-20. Finisher = 144 distinct stickers by the end of the close day (album 18: 168, rerun separately as Q7),
--   standard population Easy + Hard (p2 as above, both segments). Per finisher: ROW_NUMBER() over sticker_collected_min_ts DESC (ties by sticker_id) <= 3.
--   Grouped by collected_by_joker_flag x new_sticker_source x campaign kind (|t_Offer| or st_ = offer_campaign); n_gate = sticker in the album's gate set
--   (17: 108,104,106,130; 18: 167,168,162; 19: 107,108,130,101,125; 20: 119,120,139). Rows with n < 50 (30 for album 18) dropped. Source: prod_30_intermediate.int_user_album_stickers.
-- Q7: same as Q6 for album 18 with HAVING COUNT(DISTINCT sticker_id) >= 168.
-- Q8: far-Easy verification, albums 19-20: Easy payers (album_spent_today > 0 on any album day incl. close), standard population; missing at close-4 = 144 - stickers collected with
--   k >= 4 (k = days before the close date); groups done / 1-3 / 4-5 / 6-10 / 11+; share of payers, share of game revenue (spend open..close-1 / 17,644,426 and 16,269,671),
--   % with login_ratio >= 0.8 on the last row, missing royals (9 -), goldens (28 -), commons (107 -) at close-4, new golden+royal stickers per player by third
--   (k 33-48 / 17-32 / 5-16) and in the last 4 days (k 0-4).
