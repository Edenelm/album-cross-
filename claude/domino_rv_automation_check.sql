-- Open check (deck slide open-checks / rv-path): is the ~93 views a day of Domino 20 non-paying finishers automated viewing? (2026-10-21)
-- Results: claude/open-checks-2026-10-21.md. Project domino-dreams-dbt. Staging view approved by Eden for this analysis (same source as domino_rv_rewards_queries.sql).
-- Population: Domino 20 non-paying finishers (standard population, 144 by end of close day, album-table spend = 0 incl. close day) = the 7,517 of rv-path.
-- Per player: views, days with views, distinct hours of day with views (UTC), max views in one clock hour, median gap between consecutive views (seconds),
--   share of gaps under 20 s (shorter than a rewarded video can play = double events or automation), share of views between 00:00 and 05:00 UTC.
-- Output: distribution over players (thresholds below are my choice, for reading only; not a verdict).
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
  SELECT user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1
),
u1 AS (SELECT user_id, a_end, uniq_end, rev_c, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u),
fin AS (
  SELECT user_id FROM u1
  WHERE uniq_end >= 144 AND last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_c = 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
ev AS (
  SELECT a.user_id, a.timestamp AS ts, a.pdate,
    TIMESTAMP_DIFF(a.timestamp, LAG(a.timestamp) OVER (PARTITION BY a.user_id ORDER BY a.timestamp), SECOND) AS gap_s
  FROM `domino-dreams-dbt.prod_10_staging.stg_ad_watch_completed_vw` a JOIN fin f USING (user_id)
  WHERE a.pdate BETWEEN DATE '2026-08-24' AND DATE '2026-10-11'
),
hourly AS (SELECT user_id, TIMESTAMP_TRUNC(ts, HOUR) AS h, COUNT(*) AS v FROM ev GROUP BY 1,2),
per_user AS (
  SELECT e.user_id, COUNT(*) AS views, COUNT(DISTINCT e.pdate) AS days, COUNT(DISTINCT EXTRACT(HOUR FROM e.ts)) AS hours_of_day,
    APPROX_QUANTILES(e.gap_s, 100)[OFFSET(50)] AS med_gap_s,
    SAFE_DIVIDE(COUNTIF(e.gap_s < 20), COUNTIF(e.gap_s IS NOT NULL)) AS sh_gap_lt20,
    SAFE_DIVIDE(COUNTIF(EXTRACT(HOUR FROM e.ts) < 5), COUNT(*)) AS sh_night,
    (SELECT MAX(v) FROM hourly h WHERE h.user_id = e.user_id) AS max_per_hour
  FROM ev e GROUP BY 1
)
SELECT COUNT(*) AS players, SUM(views) AS views,
  APPROX_QUANTILES(views, 100)[OFFSET(50)] AS med_views, APPROX_QUANTILES(views / days, 100)[OFFSET(50)] AS med_views_per_day,
  APPROX_QUANTILES(med_gap_s, 100)[OFFSET(50)] AS med_of_med_gap_s, APPROX_QUANTILES(max_per_hour, 100)[OFFSET(50)] AS med_max_per_hour,
  APPROX_QUANTILES(hours_of_day, 100)[OFFSET(50)] AS med_hours_of_day,
  COUNTIF(max_per_hour >= 60) AS p_max60_per_hour, COUNTIF(hours_of_day >= 20) AS p_20plus_hours, COUNTIF(sh_gap_lt20 >= 0.5) AS p_half_gaps_lt20,
  COUNTIF(med_gap_s < 40) AS p_med_gap_lt40, COUNTIF(sh_night >= 0.3) AS p_night30,
  COUNTIF(views >= 2000) AS p_2000plus, COUNTIF(views >= 2000 AND (max_per_hour >= 60 OR hours_of_day >= 20 OR med_gap_s < 40)) AS p_2000plus_flagged
FROM per_user
;
