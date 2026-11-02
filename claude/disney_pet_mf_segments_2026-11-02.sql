-- Disney Solitaire — PET feature (= Magical Friends, "mf") segments: size, finish rate, revenue share, difficulty.
-- Project: solitaire-dreams-411507. Run 2026-11-02 via BIFROST BigQuery MCP (dry-run first, then run).
-- Results: claude/disney-pet-mf-segments-2026-11-02.md
-- Seasons: S6 Pooh = campaign 13785 (2026-09-22 .. 2026-10-11, end date 10-12); S5 Simba = 13075 (2026-08-31 .. 2026-09-21).
-- Internal QA campaigns (13651, 13009) are left out by campaign id. Special users left out (special_user_flag).

-- Q1. Segments and players per season (all seasons since 2026-05)
SELECT mtx_campaign_id, mtx_campaign_name, mtx_campaign_start_date, mtx_campaign_end_date, mtx_segment_key, max_tier,
  COUNT(DISTINCT user_id) AS users, COUNTIF(special_user_flag) AS special
FROM `solitaire-dreams-411507.bi_entity_prod.mf_activation_season_ids`
WHERE mtx_campaign_start_date >= '2026-05-01'
GROUP BY 1,2,3,4,5,6
ORDER BY mtx_campaign_start_date, mtx_segment_key;

-- Q2. Boundary test: is the segment = gross $ spend in the 14 / 30 days before start? (S6) -> NO (median 0 in every segment)
WITH u AS (
  SELECT user_id, mtx_segment_key, user_mf_start_date
  FROM `solitaire-dreams-411507.bi_entity_prod.mf_activation_season_ids`
  WHERE mtx_campaign_id = 13785 AND mtx_campaign_end_date = '2026-10-12'
),
p AS (
  SELECT user_id, date_dim, user_daily_purchase_amount AS amt
  FROM `solitaire-dreams-411507.bi_entity_prod.fact_user_daily_purchase`
  WHERE date_dim BETWEEN '2026-08-01' AND '2026-09-30'
),
s AS (
  SELECT u.user_id, u.mtx_segment_key,
    COALESCE(SUM(IF(p.date_dim BETWEEN DATE_SUB(u.user_mf_start_date, INTERVAL 14 DAY) AND DATE_SUB(u.user_mf_start_date, INTERVAL 1 DAY), p.amt, 0)),0) AS spend14_prev,
    COALESCE(SUM(IF(p.date_dim BETWEEN DATE_SUB(u.user_mf_start_date, INTERVAL 30 DAY) AND DATE_SUB(u.user_mf_start_date, INTERVAL 1 DAY), p.amt, 0)),0) AS spend30_prev
  FROM u LEFT JOIN p ON p.user_id = u.user_id AND p.date_dim < DATE_ADD(u.user_mf_start_date, INTERVAL 1 DAY)
  GROUP BY 1,2
)
SELECT mtx_segment_key, COUNT(*) AS users,
  APPROX_QUANTILES(spend14_prev, 100)[OFFSET(50)] p50_14, APPROX_QUANTILES(spend14_prev, 100)[OFFSET(95)] p95_14,
  COUNTIF(spend14_prev < 30) lt30_14, COUNTIF(spend14_prev >= 30 AND spend14_prev < 60) b30_60_14, COUNTIF(spend14_prev >= 60) ge60_14,
  COUNTIF(spend30_prev < 30) lt30_30, COUNTIF(spend30_prev >= 30 AND spend30_prev < 60) b30_60_30, COUNTIF(spend30_prev >= 60) ge60_30
FROM s GROUP BY 1 ORDER BY 1;
-- (Also tested, also no clean cut: ltv_on_mf_start, previous-season tiers completed.)

-- Q3. Main table: players, finishers (10 tiers), payers, revenue in the season window, total game revenue (S6 + S5 no-reset arm)
WITH u AS (
  SELECT mtx_campaign_id AS cid, user_id,
    REGEXP_EXTRACT(mtx_segment_key, r'def_mf_(.*)_bw') AS seg,
    mtx_campaign_start_date AS cs, mtx_campaign_end_date AS ce
  FROM `solitaire-dreams-411507.bi_entity_prod.mf_activation_season_ids`
  WHERE mtx_campaign_id IN (13785, 13075) AND mtx_campaign_end_date IN ('2026-10-12','2026-09-22')
    AND NOT COALESCE(special_user_flag, FALSE)
    AND (mtx_campaign_id = 13785 OR mtx_segment_key LIKE '%no_resets')
),
pr AS (
  SELECT mtx_campaign_id AS cid, user_id, MAX(tiers_completed_lt) AS tiers, LOGICAL_OR(is_finisher) AS fin_flag,
    MAX(mf_spent_lt) AS mf_spent
  FROM `solitaire-dreams-411507.bi_prod.magical_friend_user_profile`
  WHERE date_dim BETWEEN '2026-08-31' AND '2026-10-31' AND mtx_campaign_id IN (13785, 13075)
  GROUP BY 1,2
),
p AS (
  SELECT user_id, date_dim, user_daily_purchase_amount AS amt
  FROM `solitaire-dreams-411507.bi_entity_prod.fact_user_daily_purchase`
  WHERE date_dim BETWEEN '2026-08-31' AND '2026-10-11'
),
tot AS (
  SELECT IF(date_dim <= '2026-09-21', 13075, 13785) AS cid, SUM(amt) AS game_rev_all
  FROM p GROUP BY 1
),
ug AS (
  SELECT u.cid, u.user_id, SUM(p.amt) AS game_rev
  FROM u JOIN p ON p.user_id = u.user_id AND p.date_dim BETWEEN u.cs AND DATE_SUB(u.ce, INTERVAL 1 DAY)
  GROUP BY 1,2
),
j AS (
  SELECT u.cid, u.seg, u.user_id, COALESCE(pr.tiers,0) tiers, COALESCE(pr.fin_flag,FALSE) fin_flag,
    COALESCE(pr.mf_spent,0) mf_spent, COALESCE(ug.game_rev,0) game_rev
  FROM u LEFT JOIN pr ON pr.cid=u.cid AND pr.user_id=u.user_id
  LEFT JOIN ug ON ug.cid=u.cid AND ug.user_id=u.user_id
)
SELECT j.cid, seg, COUNT(*) players, COUNTIF(tiers>=10) fin_tiers10, COUNTIF(fin_flag) fin_flag,
  COUNTIF(game_rev>0) payers, COUNTIF(mf_spent>0) mf_payers,
  ROUND(SUM(mf_spent)) mf_rev, ROUND(SUM(game_rev)) game_rev, ROUND(ANY_VALUE(tot.game_rev_all)) game_rev_all
FROM j JOIN tot ON tot.cid=j.cid
GROUP BY 1,2 ORDER BY 1,2;

-- Q4. Check: mf_spent_lt vs mf_spent_lt_mtx (both ≈ all spend in the window, not feature-attributed)
WITH u AS (
  SELECT user_id, REGEXP_EXTRACT(mtx_segment_key, r'def_mf_(.*)_bw') AS seg
  FROM `solitaire-dreams-411507.bi_entity_prod.mf_activation_season_ids`
  WHERE mtx_campaign_id = 13785 AND mtx_campaign_end_date = '2026-10-12' AND NOT COALESCE(special_user_flag, FALSE)
),
c AS (
  SELECT user_id, MAX(mf_spent_lt) AS mf_spent, MAX(mf_spent_lt_mtx) AS mf_spent_mtx
  FROM `solitaire-dreams-411507.bi_entity_prod.magical_friend_metrics_cumulative`
  WHERE date_dim BETWEEN '2026-09-22' AND '2026-10-12' AND mtx_campaign_id = 13785
  GROUP BY 1
)
SELECT seg, COUNT(*) players, COUNTIF(c.mf_spent_mtx > 0) mtx_payers, ROUND(SUM(c.mf_spent)) mf_spent, ROUND(SUM(c.mf_spent_mtx)) mf_spent_mtx
FROM u LEFT JOIN c USING(user_id) GROUP BY 1 ORDER BY 1;

-- Q5. Difficulty: Charm requirement per tier by segment (S6)
WITH u AS (
  SELECT user_id, REGEXP_EXTRACT(mtx_segment_key, r'def_mf_(.*)_bw') AS seg
  FROM `solitaire-dreams-411507.bi_entity_prod.mf_activation_season_ids`
  WHERE mtx_campaign_id = 13785 AND mtx_campaign_end_date = '2026-10-12' AND NOT COALESCE(special_user_flag, FALSE)
),
t AS (
  SELECT user_id, tier_id, dr_requirement
  FROM `solitaire-dreams-411507.bi_prod.magical_friend_tier`
  WHERE start_tier_try_ts >= '2026-09-22' AND start_tier_try_ts < '2026-10-13' AND mtx_campaign_id = 13785
)
SELECT u.seg, t.tier_id, COUNT(*) attempts,
  APPROX_TOP_COUNT(t.dr_requirement, 2) top_req, MIN(t.dr_requirement) mn, MAX(t.dr_requirement) mx
FROM t JOIN u USING(user_id)
GROUP BY 1,2 ORDER BY 1,2;

-- Q6. Inside each segment: does the requirement change with player value (LTV at start) or on retries? (S6, tiers 3 and 5)
WITH u AS (
  SELECT user_id, REGEXP_EXTRACT(mtx_segment_key, r'def_mf_(.*)_bw') AS seg
  FROM `solitaire-dreams-411507.bi_entity_prod.mf_activation_season_ids`
  WHERE mtx_campaign_id = 13785 AND mtx_campaign_end_date = '2026-10-12' AND NOT COALESCE(special_user_flag, FALSE)
),
pr AS (
  SELECT user_id, MAX(ltv_on_mf_start) ltv
  FROM `solitaire-dreams-411507.bi_prod.magical_friend_user_profile`
  WHERE date_dim BETWEEN '2026-09-22' AND '2026-10-20' AND mtx_campaign_id = 13785
  GROUP BY 1
),
t AS (
  SELECT user_id, tier_id, tier_try_number, dr_requirement
  FROM `solitaire-dreams-411507.bi_prod.magical_friend_tier`
  WHERE start_tier_try_ts >= '2026-09-22' AND start_tier_try_ts < '2026-10-13' AND mtx_campaign_id = 13785
    AND tier_id IN (3,5) AND dr_requirement IS NOT NULL
)
SELECT u.seg, t.tier_id,
  CASE WHEN pr.ltv IS NULL OR pr.ltv = 0 THEN 'a_0' WHEN pr.ltv < 100 THEN 'b_<100' WHEN pr.ltv < 1000 THEN 'c_100-1K' ELSE 'd_1K+' END ltv_b,
  IF(t.tier_try_number > 1, 'retry', 'first') try_type,
  COUNT(*) n, ROUND(AVG(t.dr_requirement)) avg_req, APPROX_QUANTILES(t.dr_requirement, 4) q
FROM t JOIN u USING(user_id) LEFT JOIN pr USING(user_id)
GROUP BY 1,2,3,4 ORDER BY 1,2,4,3;

-- Q7. Payers only (paid at least once on season days): revenue share of total game revenue, finish rate, finishers' revenue share inside the segment.
--     S5 includes both A/B arms (resets + no_resets), split by arm in the output.
WITH u AS (
  SELECT mtx_campaign_id AS cid, user_id,
    REGEXP_EXTRACT(mtx_segment_key, r'def_mf_(.*)_bw') AS seg,
    IF(mtx_segment_key LIKE '%no_resets', 'no_resets', 'resets') AS arm,
    mtx_campaign_start_date AS cs, mtx_campaign_end_date AS ce
  FROM `solitaire-dreams-411507.bi_entity_prod.mf_activation_season_ids`
  WHERE mtx_campaign_id IN (13785, 13075) AND mtx_campaign_end_date IN ('2026-10-12','2026-09-22')
    AND NOT COALESCE(special_user_flag, FALSE)
),
pr AS (
  SELECT mtx_campaign_id AS cid, user_id, MAX(tiers_completed_lt) AS tiers
  FROM `solitaire-dreams-411507.bi_prod.magical_friend_user_profile`
  WHERE date_dim BETWEEN '2026-08-31' AND '2026-10-31' AND mtx_campaign_id IN (13785, 13075)
  GROUP BY 1,2
),
p AS (
  SELECT user_id, date_dim, user_daily_purchase_amount AS amt
  FROM `solitaire-dreams-411507.bi_entity_prod.fact_user_daily_purchase`
  WHERE date_dim BETWEEN '2026-08-31' AND '2026-10-11'
),
tot AS (
  SELECT IF(date_dim <= '2026-09-21', 13075, 13785) AS cid, SUM(amt) AS game_rev_all,
    COUNT(DISTINCT IF(amt > 0, user_id, NULL)) AS game_payers_all
  FROM p GROUP BY 1
),
ug AS (
  SELECT u.cid, u.user_id, SUM(p.amt) AS rev
  FROM u JOIN p ON p.user_id = u.user_id AND p.date_dim BETWEEN u.cs AND DATE_SUB(u.ce, INTERVAL 1 DAY)
  GROUP BY 1,2
  HAVING SUM(p.amt) > 0
)
SELECT u.cid, u.seg, u.arm,
  COUNT(*) payers, COUNTIF(COALESCE(pr.tiers,0) >= 10) fin_payers,
  ROUND(SUM(ug.rev)) rev, ROUND(SUM(IF(COALESCE(pr.tiers,0) >= 10, ug.rev, 0))) fin_rev,
  ROUND(ANY_VALUE(tot.game_rev_all)) game_rev_all, ANY_VALUE(tot.game_payers_all) game_payers_all
FROM u JOIN ug ON ug.cid = u.cid AND ug.user_id = u.user_id
LEFT JOIN pr ON pr.cid = u.cid AND pr.user_id = u.user_id
JOIN tot ON tot.cid = u.cid
GROUP BY 1,2,3 ORDER BY 1,2,3;
