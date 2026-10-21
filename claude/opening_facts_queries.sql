-- Opening facts (Eden 2026-10-20). Results: claude/opening-facts-2026-10-20.md. All RAN.
-- 1) Config: sets / stickers by phase and type
SELECT album_id, phase, type, COUNT(DISTINCT set_id) AS sets, COUNT(DISTINCT sticker_id) AS stickers
FROM `dice-dreams-dbt.external_sources.album_stickers_profile` WHERE album_id IN (61,63) GROUP BY 1,2,3;
SELECT album_id, phase, LOWER(sticker_type) AS type, COUNT(DISTINCT set_id) AS sets, COUNT(DISTINCT sticker_id) AS stickers
FROM `domino-dreams-dbt.prod_50_reporting.album_sticker_progression` WHERE album_id IN (19,20) GROUP BY 1,2,3;
SELECT album_id, phase, LOWER(sticker_type) AS type, COUNT(DISTINCT set_id) AS sets, COUNT(DISTINCT sticker_id) AS stickers
FROM `solitaire-dreams-411507.bi_entity_prod.album_sticker_progression` WHERE album_id IN (14,15) GROUP BY 1,2,3;
-- 2) Opening day per sticker = first day with >= 1,000 players collecting it (Dice 63 fact_user_album_stickers joined to config phase;
--    Domino 20 int_user_album_stickers.phase; Disney 15 dim_user_album_stickers by type). See the session SQL in the doc for full text.
-- 3) End ARPDAU by experience: rule of cross-game-comparison-framework Topic 2 follow-up; experience = rank of album_id among the
--    player's albums since 2025-04-01 (Dice/Domino; installed before 2025-04-01 = 'veterans'), Disney user_album_count.
--    Denominator per album = game purchase revenue album start..close-1, all players minus exclusions; ad revenue separate.
-- 4) Standard-population album revenue per album (factor) = payer_close_day_queries.sql population, SUM(album spend start..close-1).

-- 3a) Dice 61/63 end ARPDAU by experience (28.7 GB)
WITH alb AS (SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end UNION ALL SELECT 63, DATE '2026-07-27', DATE '2026-09-07'),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.50_reporting.user_daily_album` WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-09-06' AND album_id <= 63 GROUP BY 1,2),
ordn AS (SELECT user_id, album_id, COUNT(*) OVER (PARTITION BY user_id ORDER BY album_id) AS n FROM hist),
m AS (SELECT user_id, date_dim, ANY_VALUE(install_date) AS install_date, SUM(IFNULL(revenues_sum,0)) AS rev, SUM(IFNULL(ad_revenues,0)) AS ad
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' GROUP BY 1,2),
tot AS (SELECT a.album_id, SUM(m.rev) AS game_rev, SUM(m.ad) AS game_ad FROM m JOIN alb a ON m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM excl) GROUP BY 1),
inst AS (SELECT user_id, MIN(install_date) AS install_date FROM m GROUP BY 1),
d AS (SELECT x.album_id, x.user_id, x.date_dim, a.a_end, IFNULL(x.spent_in_album_today, 0) AS rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x JOIN alb a ON a.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND x.date_dim < a.a_end AND x.date_dim >= x.user_album_start_date
    AND x.is_active AND NOT IFNULL(x.is_excluded, FALSE)),
g AS (SELECT d.album_id, d.user_id, d.date_dim, d.a_end, d.rev,
    CASE WHEN i.install_date IS NULL THEN 'unknown' WHEN i.install_date < DATE '2025-04-01' THEN 'veterans'
         WHEN o.n = 1 THEN '1' WHEN o.n <= 3 THEN '2-3' WHEN o.n <= 6 THEN '4-6' ELSE '7+' END AS grp
  FROM d LEFT JOIN ordn o USING (user_id, album_id) LEFT JOIN inst i USING (user_id))
SELECT g.album_id, grp, COUNT(DISTINCT user_id) AS players, ROUND(SUM(rev)) AS album_rev,
  ROUND(100 * SUM(rev) / ANY_VALUE(t.game_rev), 1) AS pct_game_purchase_rev, ROUND(SUM(rev) / COUNT(*), 3) AS arpdau_album,
  ROUND(SAFE_DIVIDE(SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY), rev, 0)), COUNTIF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY))), 3) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY), rev, 0)), COUNTIF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY))), SUM(rev) / COUNT(*)), 3) AS ratio_last4,
  ROUND(ANY_VALUE(t.game_rev)) AS game_purchase_rev, ROUND(ANY_VALUE(t.game_ad)) AS game_ad_rev
FROM g JOIN tot t USING (album_id) GROUP BY 1,2 ORDER BY 1,2;
-- 3b) Domino 19/20 (41.8 GB): same shape; m = prod_40_mart.user_daily_metrics (first_seen_date, in-app + Stripe, ad_revenues,
--     bad = special_user_flag OR suspected_cheater_flag); album table prod_40_mart.user_daily_album (album_spent_today, active_flag,
--     special_user_flag); windows 2026-07-06..08-24 / 08-24..10-12.
-- 3c) Disney 14/15 (17.3 GB): m = bi_prod.solitaire_user_daily_metrics_agg_df (gross_revenues, ad_revenues, exclude_reason);
--     album table bi_prod.user_daily_album (album_spent_today, active_flag, special_user_flag, user_album_count = experience);
--     windows 2026-07-13..08-24 / 08-24..10-05.
