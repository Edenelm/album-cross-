-- Domino album 20 — what a rewarded video (RV) gives finishers, and its role in completing the album (Eden 2026-10-20). RAN.
-- Results: claude/domino-rv-rewards-2026-10-20.md
-- Curated prod_20_core.core_ad_watch_completed ends in July 2026 → staging views (approved by Eden for this analysis):
--   prod_10_staging.stg_ad_watch_completed_vw (placement, reward_syntax_actual, ad_revenue), stg_dynamic_resource_in_vw,
--   stg_album_sticker_collected_vw (pack_key, new_sticker, source).
-- Finishers = standard population, 144 by end of close day (2026-10-12); payer = paid on any album day incl. close day.

-- Q1: views by placement × reward (top 40) — 14 GB. See doc for the top rows.
-- (same population CTEs as Q2; rv = stg_ad_watch_completed_vw pdate 2026-08-24..2026-10-11, GROUP BY pay, placement, reward_syntax_actual)

-- Q2: per-finisher summary — 321 GB
WITH ud AS (
  SELECT user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end, SUM(spend) AS rev_c, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1
),
fin AS (
  SELECT user_id, alb_rev, IF(rev_c > 0, 'payer', 'non_payer') AS pay
  FROM u WHERE uniq_end >= 144 AND last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
rv AS (
  SELECT a.user_id, COUNT(*) AS views, COUNT(DISTINCT a.pdate) AS rv_days, SUM(IFNULL(a.ad_revenue,0)) AS ad_rev,
    SUM(ARRAY_LENGTH(REGEXP_EXTRACT_ALL(IFNULL(a.reward_syntax_actual,''), r'sticker_pack:'))) AS packs,
    SUM((SELECT IFNULL(SUM(CAST(x AS INT64)),0) FROM UNNEST(REGEXP_EXTRACT_ALL(IFNULL(a.reward_syntax_actual,''), r'dr-puzzle-[a-z]+:(\d+)')) x)) AS puzzle_dr,
    SUM((SELECT IFNULL(SUM(CAST(x AS INT64)),0) FROM UNNEST(REGEXP_EXTRACT_ALL(IFNULL(a.reward_syntax_actual,''), r'dr-garden-blast:(\d+)')) x)) AS blast_dr,
    SUM((SELECT IFNULL(SUM(CAST(x AS INT64)),0) FROM UNNEST(REGEXP_EXTRACT_ALL(IFNULL(a.reward_syntax_actual,''), r'trail-energy-v3:(\d+)')) x)) AS trail_energy,
    COUNTIF(REGEXP_CONTAINS(IFNULL(a.reward_syntax_actual,''), r'coins:')) AS coin_views
  FROM `domino-dreams-dbt.prod_10_staging.stg_ad_watch_completed_vw` a JOIN fin f USING (user_id)
  WHERE a.pdate BETWEEN DATE '2026-08-24' AND DATE '2026-10-12'
  GROUP BY 1
),
dr AS (
  SELECT d.user_id,
    SUM(IF(REGEXP_CONTAINS(IFNULL(d.dynamic_resource_id,''), r'^dr-puzzle'), d.amount, 0)) AS puzzle_in_all,
    SUM(IF(REGEXP_CONTAINS(IFNULL(d.dynamic_resource_id,''), r'^dr-puzzle') AND LOWER(IFNULL(d.rewarded_video_flag,'')) = 'true', d.amount, 0)) AS puzzle_in_rv
  FROM `domino-dreams-dbt.prod_10_staging.stg_dynamic_resource_in_vw` d JOIN fin f USING (user_id)
  WHERE d.pdate BETWEEN DATE '2026-08-24' AND DATE '2026-10-12'
  GROUP BY 1
),
stk AS (
  SELECT s.user_id,
    COUNTIF(s.new_sticker AND REGEXP_CONTAINS(LOWER(IFNULL(s.pack_key,'')), r'^rv_pack')) AS new_from_rv_pack,
    COUNTIF(s.new_sticker AND LOWER(IFNULL(s.source,'')) = 'joker' AND REGEXP_CONTAINS(LOWER(IFNULL(s.mtx_event_name,'') || IFNULL(s.mtx_campaign_name,'')), r'puzzle')) AS new_from_puzzle_joker,
    COUNTIF(s.new_sticker) AS new_all
  FROM `domino-dreams-dbt.prod_10_staging.stg_album_sticker_collected_vw` s JOIN fin f USING (user_id)
  WHERE s.pdate BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND s.album_id = 20
  GROUP BY 1
)
SELECT f.pay, COUNT(*) AS finishers, ROUND(SUM(f.alb_rev)) AS album_rev,
  ROUND(100 * COUNTIF(rv.views > 0) / COUNT(*)) AS pct_watched,
  ROUND(AVG(IF(rv.views > 0, rv.views, NULL))) AS avg_views_watchers,
  APPROX_QUANTILES(IF(rv.views > 0, rv.views, NULL), 2)[OFFSET(1)] AS median_views_watchers,
  ROUND(AVG(IF(rv.views > 0, rv.rv_days, NULL))) AS avg_rv_days,
  ROUND(SUM(rv.ad_rev)) AS ad_rev_total, ROUND(SAFE_DIVIDE(SUM(rv.ad_rev), SUM(rv.views)), 4) AS ad_rev_per_view,
  ROUND(SAFE_DIVIDE(SUM(rv.packs), SUM(rv.views)), 3) AS packs_per_view,
  ROUND(SAFE_DIVIDE(SUM(rv.puzzle_dr), SUM(rv.views)), 2) AS puzzle_per_view,
  ROUND(AVG(IF(rv.views > 0, rv.packs, NULL))) AS avg_packs_watchers,
  ROUND(AVG(IF(rv.views > 0, rv.puzzle_dr, NULL))) AS avg_puzzle_from_rv_watchers,
  ROUND(AVG(IF(rv.views > 0, rv.blast_dr, NULL))) AS avg_blast_from_rv_watchers,
  ROUND(100 * SAFE_DIVIDE(SUM(dr.puzzle_in_rv), SUM(dr.puzzle_in_all)), 1) AS pct_puzzle_resource_from_rv_flag,
  ROUND(100 * SAFE_DIVIDE(SUM(rv.puzzle_dr), SUM(dr.puzzle_in_all)), 1) AS pct_puzzle_resource_from_rv_syntax,
  ROUND(AVG(stk.new_from_rv_pack), 1) AS avg_new_stickers_from_rv_packs,
  ROUND(AVG(stk.new_from_puzzle_joker), 1) AS avg_new_from_puzzle_joker,
  ROUND(AVG(stk.new_all), 1) AS avg_new_stickers_logged
FROM fin f LEFT JOIN rv USING (user_id) LEFT JOIN dr USING (user_id) LEFT JOIN stk USING (user_id)
GROUP BY 1 ORDER BY 1;
