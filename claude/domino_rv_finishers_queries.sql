-- DRAFT 2026-10-18 (not run): Domino 17/19/20 finishers (payer / nonpayer) — RV during album days.
-- RV source: prod_20_core.core_ad_watch_completed (Mixpanel 'ad watch completed'; ~99.9% rewarded_video_flag=True). Cross-check: prod_30_intermediate.int_user_daily_rv.
-- Finisher / payer definitions as in nonpayer_finishers_queries.sql (144 stickers on last full day, not first album, login ratio >= 0.5, exclusions; payer = album_spent_today > 0).

-- ===== Q1: summary per album x group =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim < album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cls AS (
  SELECT f.album_id, f.user_id, f.a_start, f.a_end, IF(SUM(u.spend) > 0, 'payer', 'nonpayer') AS grp
  FROM fin f JOIN ud u USING (album_id, user_id) GROUP BY 1,2,3,4
),
ev AS (
  SELECT user_id, date_dim, IFNULL(ad_revenue,0) AS rev,
    REGEXP_CONTAINS(LOWER(IFNULL(reward_syntax_actual,'')), r'sticker|joker') AS album_reward
  FROM `domino-dreams-dbt.prod_20_core.core_ad_watch_completed`
  WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12'
),
per_user AS (
  SELECT c.album_id, c.grp, c.user_id, DATE_DIFF(c.a_end, c.a_start, DAY) AS album_days,
    COUNT(e.user_id) AS views, COUNT(DISTINCT e.date_dim) AS rv_days, IFNULL(SUM(e.rev),0) AS rv_rev,
    COUNTIF(e.album_reward) AS album_reward_views
  FROM cls c LEFT JOIN ev e ON e.user_id = c.user_id AND e.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2,3,4
),
xchk AS (
  SELECT c.album_id, c.user_id, SUM(IFNULL(r.ad_daily_revenue,0)) AS rv_rev_int, SUM(IFNULL(r.daily_trx_count,0)) AS views_int
  FROM cls c LEFT JOIN (SELECT user_id, date_dim, ad_daily_revenue, daily_trx_count FROM `domino-dreams-dbt.prod_30_intermediate.int_user_daily_rv` WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12') r
    ON r.user_id = c.user_id AND r.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
)
SELECT p.album_id, p.grp, COUNT(*) AS n, MAX(p.album_days) AS album_days,
  ROUND(100 * COUNTIF(p.views > 0) / COUNT(*), 1) AS pct_watched_rv,
  ROUND(AVG(p.views), 0) AS avg_rv_views,
  ROUND(APPROX_QUANTILES(IF(p.views > 0, p.views, NULL), 2)[OFFSET(1)], 0) AS median_views_watchers,
  ROUND(AVG(p.rv_days), 1) AS avg_rv_days,
  ROUND(AVG(p.rv_rev), 2) AS avg_rv_rev,
  ROUND(SUM(p.rv_rev)) AS total_rv_rev,
  ROUND(100 * COUNTIF(p.album_reward_views > 0) / COUNT(*), 1) AS pct_got_album_reward_from_rv,
  ROUND(100 * SUM(p.album_reward_views) / NULLIF(SUM(p.views), 0), 1) AS pct_views_album_reward,
  ROUND(AVG(x.views_int), 0) AS avg_views_int_xchk,
  ROUND(AVG(x.rv_rev_int), 2) AS avg_rv_rev_int_xchk
FROM per_user p JOIN xchk x USING (album_id, user_id)
GROUP BY 1,2 ORDER BY 1,2;

-- ===== Q2: where RV was opened (placement) and which offer (mtx_event_name), nonpayer vs payer finishers =====
-- same CTEs ud / bad_users / fin / cls as Q1, then:
-- SELECT c.album_id, c.grp, IFNULL(e.placement,'(none)') AS placement, IFNULL(e.mtx_event_name,'(none)') AS mtx_event_name,
--   COUNT(*) AS views, COUNT(DISTINCT c.user_id) AS users, ROUND(SUM(IFNULL(e.ad_revenue,0))) AS rv_rev
-- FROM cls c JOIN core_ad_watch_completed e ON e.user_id = c.user_id AND e.date_dim BETWEEN c.a_start AND c.a_end - 1
-- GROUP BY 1,2,3,4 HAVING views >= 100 ORDER BY 1,2,5 DESC  (top rows only, via export_query_csv)

-- ===== RUN 2026-10-18 (Eden narrowed scope): views / RV days / RV revenue only, from int_user_daily_rv (19 GB) =====
-- CTEs ud / bad_users / fin / cls as in Q1, then:
-- rv AS (SELECT user_id, date_dim, IFNULL(ad_daily_revenue,0) AS rev, IFNULL(daily_trx_count,0) AS views
--        FROM `domino-dreams-dbt.prod_30_intermediate.int_user_daily_rv` WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12'),
-- per_user AS (SELECT c.album_id, c.grp, c.user_id, IFNULL(SUM(r.views),0) AS views, COUNTIF(r.views > 0) AS rv_days, IFNULL(SUM(r.rev),0) AS rv_rev
--   FROM cls c LEFT JOIN rv r ON r.user_id = c.user_id AND r.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY) GROUP BY 1,2,3)
-- SELECT album_id, grp, COUNT(*) n, pct views>0, AVG(views), median views among watchers, AVG(rv_days), AVG(rv_rev), SUM(rv_rev) GROUP BY 1,2
