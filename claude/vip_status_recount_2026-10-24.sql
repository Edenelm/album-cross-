-- Eden 2026-10-24: review of vip_album_end_analysis_handoff.md, step 2.
-- Recount end-of-album status by LTV tier with the DECK definitions:
--   population = standard population (not first album, not excluded / cheater, login ratio >= 0.5 on the last row before close, row on close-1);
--   payer = album spend > 0 on any album day incl. the close day; revenue = album-table spend, album start to close-1;
--   finisher = 144 unique set stickers by the END of the close day (Dice: sticker table, because the Dice daily table misses close-day stickers);
--   status: finished / 1-3 missing / 4+ missing at the end of the close day.
--   tier = LTV at album start: VIP $5K+ / $1K-5K / under $1K (Eden's handoff definition).
-- Albums: Dice 63, 65 · Domino 19, 20 · Disney 14, 15. Results: claude/vip-review-2026-10-24.md

-- ===== DICE 63 / 65 (dice-dreams-dbt) =====
WITH hist AS (SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-10-19' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end, IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, ltv_until_album_start AS ltv
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-10-19' AND album_id IN (63, 65) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS rev, SUM(a.spend) AS spend_incl_close,
    MAX(a.ltv) AS ltv,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1, 2),
pop AS (SELECT album_id, user_id, a_end, rev, ltv FROM u WHERE ok AND spend_incl_close > 0),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-07-27' AND DATE '2026-10-19' AND s.album_id IN (63, 65)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1, 2)
SELECT p.album_id,
  CASE WHEN p.ltv >= 5000 THEN '1_VIP_5K+' WHEN p.ltv >= 1000 THEN '2_1K-5K' ELSE '3_<1K' END AS tier,
  CASE WHEN IFNULL(s.n_uniq,0) >= 144 THEN 'a_finished' WHEN IFNULL(s.n_uniq,0) >= 141 THEN 'b_1-3' ELSE 'c_4plus' END AS status,
  COUNT(1) AS payers, ROUND(SUM(p.rev)) AS rev
FROM pop p LEFT JOIN st s USING (album_id, user_id) GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;

-- ===== DOMINO 19 / 20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, ltv_on_album_start AS ltv
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19, 20) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end, MAX(ltv) AS ltv,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev, SUM(spend) AS spend_incl_close,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1, 2)
SELECT album_id,
  CASE WHEN ltv >= 5000 THEN '1_VIP_5K+' WHEN ltv >= 1000 THEN '2_1K-5K' ELSE '3_<1K' END AS tier,
  CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 141 THEN 'b_1-3' ELSE 'c_4plus' END AS status,
  COUNT(1) AS payers, ROUND(SUM(rev)) AS rev
FROM u
WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND spend_incl_close > 0
  AND user_id NOT IN (SELECT user_id FROM bad)
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;

-- ===== DISNEY 14 / 15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, ltv_on_album_start AS ltv
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14, 15) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end, MAX(ltv) AS ltv,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev, SUM(spend) AS spend_incl_close,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1, 2)
SELECT album_id,
  CASE WHEN ltv >= 5000 THEN '1_VIP_5K+' WHEN ltv >= 1000 THEN '2_1K-5K' ELSE '3_<1K' END AS tier,
  CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end >= 141 THEN 'b_1-3' ELSE 'c_4plus' END AS status,
  COUNT(1) AS payers, ROUND(SUM(rev)) AS rev
FROM u
WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND spend_incl_close > 0
  AND user_id NOT IN (SELECT user_id FROM bad)
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;

-- ===== STEP 1: Dice VIP FU album treatment ("Exclusive VIP Gift") recipients (dice-dreams-dbt, 48.9 GB) =====
-- Campaign names found in 20_core.dim_campaign; production runs 190726 / 010926 / 131026 (test and QA copies left out).
SELECT campaign_name, event_name, source, dr_key, COUNT(DISTINCT user_id) AS users, MIN(date_dim) AS first_d, MAX(date_dim) AS last_d, SUM(dr_amount) AS amount
FROM `dice-dreams-dbt.40_mart.fact_dynamic_resource_given`
WHERE date_dim BETWEEN DATE '2026-07-15' AND DATE '2026-10-24'
  AND campaign_name IN ('190726_VIP_VipFualbumtreatment_GM', '010926_VIP_VipFualbumtreatment_GM', '131026_VIP_VipFualbumtreatment13Or10Or26_GM')
GROUP BY 1, 2, 3, 4 ORDER BY 1, users DESC;
