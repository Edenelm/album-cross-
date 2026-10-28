-- 2026-10-28 (Eden): size of the "Pick Your Golden" test audience = standard-population payers with 1+ Golden missing
-- at the end of close-11 (10 days before close). % of payers and % of album revenue (spend before close day). Domino 20 (28 Goldens), Disney 15 (24 Goldens).
-- ===== DOMINO 20 =====
WITH ud AS (
  SELECT user_id, date_dim, album_close_date AS a_end, IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac,
    IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, IFNULL(unique_golden_stickers_lt,0) AS g
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
pay AS (
  SELECT user_id, SUM(IF(date_dim < a_end, spend, 0)) AS rev,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 11 DAY), g, NULL)) AS g11
  FROM ud GROUP BY user_id, a_end
  HAVING MAX(IF(date_dim < a_end, date_dim, NULL)) = DATE_SUB(a_end, INTERVAL 1 DAY)
    AND ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND ARRAY_AGG(IF(date_dim < a_end, uac, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
    AND NOT LOGICAL_OR(excl) AND SUM(spend) > 0)
SELECT COUNT(*) AS payers, COUNTIF(IFNULL(g11,0) < 28) AS aud, ROUND(100*COUNTIF(IFNULL(g11,0) < 28)/COUNT(*),1) AS pct_payers,
  ROUND(SUM(IF(IFNULL(g11,0) < 28, rev, 0))) AS aud_rev, ROUND(100*SUM(IF(IFNULL(g11,0) < 28, rev, 0))/SUM(rev),1) AS pct_rev
FROM pay WHERE user_id NOT IN (SELECT user_id FROM bad);
-- Disney 15: same query on solitaire-dreams-411507.bi_prod.user_daily_album (album_id 15, 24 Goldens), exclusions from bi_prod.solitaire_user_daily_metrics_agg_df (exclude_reason IS NOT NULL).
-- RESULTS 2026-10-28: Domino 20: 106,760 of 106,762 payers (100%), 99.7% of album rev. Disney 15: 325,842 of 325,842 (100%), 100%.
-- => "1+ Golden missing at d-11" is not a usable entry rule: end-locked Goldens are missing for everyone. Needs: count only Goldens open at d-11 (gate list per level needed).
-- RERUN 2026-10-28, open Goldens only at d-11 (Domino 20: Easy 3 locked -> g11 < 25, Hard 1 locked -> g11 < 27, segment = first album_segment row;
-- Disney 15: 2 locked (Eden) -> g11 < 22):
-- Domino 20: Easy 88,523 of 97,937 + Hard 8,810 of 8,825 = 97,333 payers (91% of payers), 87% of album rev ($11,192,877).
-- Disney 15: 299,896 of 325,842 payers (92%), 66% of album rev ($23,964,728).
-- OPTION C (Eden 2026-10-28): 1+ open Golden missing AND <=6 set stickers missing (of 144, locked ones included) at end of d-11:
-- Domino 20: 14,417 of 106,762 payers (13.5%), 36.9% of album rev ($4,735,432). Disney 15: 11,476 of 325,842 (3.5%), 10.6% ($3,882,357).
