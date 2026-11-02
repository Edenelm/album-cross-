-- Dice Dreams — Pet feature segments: players, finish (adoption), payers, revenue shares, finishers' revenue share.
-- Project: dice-dreams-dbt. Run 2026-11-02 via BIFROST BigQuery MCP (dry-run first, then run).
-- Results: claude/dice-pet-segments-2026-11-02.md
-- Seasons: GoldenDog 2026-08-24..09-13, Skunk 2026-09-14..10-11 (season end day = next season's start, left out of revenue).
-- Segment = last digit of pet_segment_key (seg_<pet>_<control|test>_<1-7>); seg_pet label: 1-2 Easy, 3-4 Medium, 5-6 Hard, 7 seg_default.
-- Excluded users out (is_excluded). Finish = finish_level_9_timestamp IS NOT NULL (adoption).

-- Q1. Seasons and segment keys
SELECT pet_season_id, DATE(MIN(pet_season_start)) s, DATE(MAX(pet_season_end)) e, seg_pet, pet_segment_key,
  COUNT(DISTINCT user_id) users, COUNT(DISTINCT IF(finish_level_9_timestamp IS NOT NULL, user_id, NULL)) fin
FROM `dice-dreams-dbt.50_reporting.user_daily_pet`
WHERE date_dim BETWEEN '2026-08-15' AND '2026-11-01' AND NOT COALESCE(is_excluded, FALSE)
GROUP BY 1,4,5 HAVING users > 500 ORDER BY 2,1,4,5;

-- Q2. Main table by season x segment x arm
WITH pu AS (
  SELECT pet_season_id AS season, user_id,
    MAX(CAST(REGEXP_EXTRACT(pet_segment_key, r'_(\d+)$') AS INT64)) AS seg,
    MAX(REGEXP_EXTRACT(pet_segment_key, r'_(control|test)_')) AS arm,
    LOGICAL_OR(finish_level_9_timestamp IS NOT NULL) AS fin,
    MAX(season_ltv) AS pet_rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_pet`
  WHERE date_dim BETWEEN '2026-08-24' AND '2026-10-13' AND pet_season_id IN ('GoldenDog','Skunk')
    AND NOT COALESCE(is_excluded, FALSE)
  GROUP BY 1,2
),
g AS (
  SELECT user_id, date_dim, revenues_sum AS amt
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN '2026-08-24' AND '2026-10-11' AND revenues_sum > 0
),
gs AS (
  SELECT IF(date_dim <= '2026-09-13', 'GoldenDog', 'Skunk') AS season, user_id, SUM(amt) AS rev
  FROM g GROUP BY 1,2
),
tot AS (SELECT season, SUM(rev) game_rev_all, COUNT(*) game_payers_all FROM gs GROUP BY 1)
SELECT pu.season, pu.seg, pu.arm, COUNT(*) players, COUNTIF(pu.fin) fin,
  COUNTIF(gs.rev > 0) payers, COUNTIF(gs.rev > 0 AND pu.fin) fin_payers,
  ROUND(SUM(gs.rev)) game_rev, ROUND(SUM(IF(pu.fin, gs.rev, 0))) fin_game_rev,
  ROUND(SUM(pu.pet_rev)) pet_rev, ROUND(SUM(IF(pu.fin, pu.pet_rev, 0))) fin_pet_rev,
  ROUND(ANY_VALUE(tot.game_rev_all)) game_rev_all, ANY_VALUE(tot.game_payers_all) game_payers_all
FROM pu LEFT JOIN gs ON gs.season = pu.season AND gs.user_id = pu.user_id
JOIN tot ON tot.season = pu.season
GROUP BY 1,2,3 ORDER BY 1,2,3;

-- Q3. Segment meaning test: pre-season spend (14 / 28 / 56 days) by Skunk segment
WITH pu AS (
  SELECT user_id, MAX(CAST(REGEXP_EXTRACT(pet_segment_key, r'_(\d+)$') AS INT64)) AS seg
  FROM `dice-dreams-dbt.50_reporting.user_daily_pet`
  WHERE date_dim BETWEEN '2026-09-14' AND '2026-10-12' AND pet_season_id = 'Skunk' AND NOT COALESCE(is_excluded, FALSE)
  GROUP BY 1
),
pre AS (
  SELECT user_id,
    SUM(IF(date_dim >= '2026-08-31', revenues_sum, 0)) r14,
    SUM(IF(date_dim >= '2026-08-17', revenues_sum, 0)) r28,
    SUM(revenues_sum) r56
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN '2026-07-20' AND '2026-09-13' AND revenues_sum > 0
  GROUP BY 1
)
SELECT seg, COUNT(*) n,
  APPROX_QUANTILES(COALESCE(r14,0), 10) q14, APPROX_QUANTILES(COALESCE(r28,0), 10) q28,
  APPROX_QUANTILES(COALESCE(r56,0)/8, 10) q_week56
FROM pu LEFT JOIN pre USING(user_id) GROUP BY 1 ORDER BY 1;

-- Q4. Inside the top segments (4-6): payers by season spend band
WITH pu AS (
  SELECT pet_season_id AS season, user_id,
    MAX(CAST(REGEXP_EXTRACT(pet_segment_key, r'_(\d+)$') AS INT64)) AS seg,
    LOGICAL_OR(finish_level_9_timestamp IS NOT NULL) AS fin
  FROM `dice-dreams-dbt.50_reporting.user_daily_pet`
  WHERE date_dim BETWEEN '2026-08-24' AND '2026-10-13' AND pet_season_id IN ('GoldenDog','Skunk')
    AND NOT COALESCE(is_excluded, FALSE)
  GROUP BY 1,2
),
gs AS (
  SELECT IF(date_dim <= '2026-09-13', 'GoldenDog', 'Skunk') AS season, user_id, SUM(revenues_sum) AS rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN '2026-08-24' AND '2026-10-11' AND revenues_sum > 0
  GROUP BY 1,2
)
SELECT pu.season, pu.seg,
  CASE WHEN rev < 100 THEN 'a_<100' WHEN rev < 500 THEN 'b_100-500' WHEN rev < 1500 THEN 'c_500-1500' ELSE 'd_1500+' END band,
  COUNT(*) payers, COUNTIF(fin) fin, ROUND(SUM(rev)) rev
FROM pu JOIN gs ON gs.season = pu.season AND gs.user_id = pu.user_id
WHERE pu.seg IN (4,5,6)
GROUP BY 1,2,3 ORDER BY 1,2,3;

-- Q5. Segment check: cookies collected in the previous season (GoldenDog) by Skunk segment -> clean cut-offs (~10.3K / 13.5K / 17K / 21.5K / 28.5K)
WITH s AS (
  SELECT user_id, MAX(CAST(REGEXP_EXTRACT(pet_segment_key, r'_(\d+)$') AS INT64)) AS seg
  FROM `dice-dreams-dbt.50_reporting.user_daily_pet`
  WHERE date_dim BETWEEN '2026-09-14' AND '2026-10-12' AND pet_season_id = 'Skunk' AND NOT COALESCE(is_excluded, FALSE)
  GROUP BY 1
),
p AS (
  SELECT user_id, SUM(cookies_received_amount) cookies
  FROM `dice-dreams-dbt.50_reporting.user_daily_pet`
  WHERE date_dim BETWEEN '2026-08-24' AND '2026-09-14' AND pet_season_id = 'GoldenDog' AND NOT COALESCE(is_excluded, FALSE)
  GROUP BY 1
)
SELECT seg, COUNT(*) n, COUNTIF(p.user_id IS NULL) no_prev,
  MIN(p.cookies) mn, APPROX_QUANTILES(p.cookies, 20) q, MAX(p.cookies) mx
FROM s LEFT JOIN p USING(user_id)
GROUP BY 1 ORDER BY 1;
