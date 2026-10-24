-- Eden 2026-10-24: VIP review, step 5. Dice "Exclusive VIP Gift" (campaign 010926_VIP_VipFualbumtreatment_GM, given Sep 1-2, album 63 day 37-38).
-- Stated rule (Eden's handoff, from the test deck): missed the previous album (61) by 3 stickers AND 4+ missing in the current album (63).
-- Population: album 63 standard-population payers with LTV >= $1K at album start (as in steps 2-3), with a row on Aug 31 (day before the gift).
-- Cells: tier x missing at end of album 61 close day (Jul 27) x missing in album 63 on Aug 31 x got the gift.
-- Outcomes (natural comparison, NOT a test): finished album 63 by end of close day; spend Sep 1-6 (last week) and close+1..+28 (album 65)
-- vs usual pace (album 63 days 0-20). Results: claude/vip-review-2026-10-24.md
WITH hist AS (SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(album_login_ratio,-1) AS lr,
    IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend, ltv_until_album_start AS ltv
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date),
u AS (
  SELECT a.user_id, ANY_VALUE(a.a_end) AS a_end, MAX(a.ltv) AS ltv,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) BETWEEN 0 AND 20, a.spend, 0)) AS s_a,
    SUM(IF(a.date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-09-06', a.spend, 0)) AS s_last6,
    SUM(a.spend) AS spend_incl_close, LOGICAL_OR(a.date_dim = DATE '2026-08-31') AS on_aug31,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < 63 AND NOT LOGICAL_OR(a.excl) AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1),
pop AS (SELECT user_id, ltv, s_a, s_last6 FROM u WHERE ok AND spend_incl_close > 0 AND ltv >= 1000 AND on_aug31),
s63 AS (
  SELECT s.user_id, COUNT(DISTINCT IF(s.sticker_collected_date <= DATE '2026-08-31', s.sticker_id, NULL)) AS n_aug31,
    COUNT(DISTINCT s.sticker_id) AS n_close
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND s.album_id = 63
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE)
  GROUP BY 1),
s61 AS (
  SELECT s.user_id, COUNT(DISTINCT s.sticker_id) AS n61
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-15' AND DATE '2026-07-27' AND s.album_id = 61
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE)
  GROUP BY 1),
rec AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.40_mart.fact_dynamic_resource_given`
  WHERE date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-09-02' AND campaign_name = '010926_VIP_VipFualbumtreatment_GM'),
nx AS (
  SELECT user_id, SUM(IFNULL(spent_in_album_today,0)) AS after28
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-09-08' AND DATE '2026-10-05' AND album_id = 65
  GROUP BY 1)
SELECT
  CASE WHEN p.ltv >= 5000 THEN '1_VIP_5K+' ELSE '2_1K-5K' END AS tier,
  CASE WHEN a.n61 IS NULL THEN 'not in 61' WHEN a.n61 >= 144 THEN '61 finished' WHEN a.n61 >= 141 THEN CONCAT('61 missed ', CAST(144 - a.n61 AS STRING))
       ELSE '61 missed 4+' END AS miss61,
  IF(144 - IFNULL(b.n_aug31,0) >= 4, '63 4+ on Aug31', '63 0-3 on Aug31') AS miss63,
  r.user_id IS NOT NULL AS got_gift,
  COUNT(1) AS n, COUNTIF(IFNULL(b.n_close,0) >= 144) AS finished63,
  ROUND(SUM(p.s_a) / 21) AS pace_day, ROUND(SUM(p.s_last6)) AS last6, ROUND(SUM(IFNULL(x.after28,0))) AS after28
FROM pop p LEFT JOIN s63 b USING (user_id) LEFT JOIN s61 a USING (user_id) LEFT JOIN rec r USING (user_id) LEFT JOIN nx x USING (user_id)
GROUP BY 1, 2, 3, 4 ORDER BY 1, 2, 3, 4;
