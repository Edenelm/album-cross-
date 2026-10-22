-- Topic 3 reruns (Eden approved 2026-10-22). Results: claude/topic3-reruns-2026-10-22.md
-- A. Dice rare timeline (rare_timeline_queries.sql, Dice) with the fixed first-album rule: not first album = a row in an earlier album
--    of user_daily_album (history from 2023-11-01), replacing user_past_album_count > 0. Nothing else changed.
-- B. Domino rare sources by quarter (topic5 5d v4: PU, not first album, First Royal gift line) on albums 19/20 instead of 17/19.
--    Dates moved to the 19/20 window (2026-07-06 .. 2026-10-12). Nothing else changed.

-- ===== A. Dice 61/63 rare timeline, fixed population =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07'
  GROUP BY 1
),
ud AS (
  SELECT d.album_id, d.user_id, d.date_dim, d.album_start_date AS a_start, d.album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, h.first_album_seen < d.album_id AS past, IFNULL(d.is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` d JOIN hist h USING (user_id)
  WHERE d.date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND d.album_id IN (61,63) AND d.date_dim <= d.album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_start, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
pop AS (SELECT album_id, user_id, a_start, a_end, alb_rev FROM pop0 WHERE rev_c > 0),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_date) AS d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type = 'super' AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2,3
),
rd AS (SELECT r.album_id, r.user_id, DATE_DIFF(r.d, p.a_start, DAY) + 1 AS day FROM r JOIN pop p USING (album_id, user_id)),
alen AS (SELECT album_id, DATE_DIFF(ANY_VALUE(a_end), ANY_VALUE(a_start), DAY) + 1 AS n_days FROM pop GROUP BY 1),
grid AS (SELECT p.album_id, p.user_id, day FROM pop p JOIN alen USING (album_id), UNNEST(GENERATE_ARRAY(1, alen.n_days)) AS day),
daily AS (SELECT album_id, user_id, day, COUNT(*) AS new_r FROM rd GROUP BY 1,2,3),
cum AS (
  SELECT g.album_id, g.day, IFNULL(dl.new_r, 0) AS new_r,
    SUM(IFNULL(dl.new_r, 0)) OVER (PARTITION BY g.album_id, g.user_id ORDER BY g.day) AS held
  FROM grid g LEFT JOIN daily dl USING (album_id, user_id, day)
),
gaps AS (
  SELECT album_id, user_id, day - IFNULL(LAG(day) OVER (PARTITION BY album_id, user_id ORDER BY day), 0) AS gap,
    ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY day) AS k
  FROM (SELECT DISTINCT album_id, user_id, day FROM rd)
),
pg AS (SELECT album_id, user_id, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS own_med FROM gaps GROUP BY 1,2),
endh AS (SELECT album_id, user_id, COUNT(*) AS n_r FROM rd GROUP BY 1,2)
SELECT 'day' AS row_type, album_id, day, COUNT(*) AS n,
  APPROX_QUANTILES(held, 4)[OFFSET(1)] AS p25, APPROX_QUANTILES(held, 4)[OFFSET(2)] AS p50, APPROX_QUANTILES(held, 4)[OFFSET(3)] AS p75,
  ROUND(AVG(IF(new_r > 0, 1, 0)), 3) AS got_new, NULL AS gap_med, NULL AS gap_le4, NULL AS own_med, NULL AS first_day, NULL AS rev_share
FROM cum GROUP BY 1,2,3
UNION ALL
SELECT 'gap', gs.album_id, NULL, gs.n_gaps, NULL, NULL, NULL, NULL, gs.gap_med, gs.gap_le4, os.own_med, gs.first_day, rs.rev_share
FROM (SELECT album_id, COUNT(*) AS n_gaps, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS gap_med, ROUND(AVG(IF(gap <= 4, 1, 0)), 3) AS gap_le4,
        APPROX_QUANTILES(IF(k = 1, gap, NULL), 2 IGNORE NULLS)[OFFSET(1)] AS first_day FROM gaps GROUP BY 1) gs
JOIN (SELECT album_id, APPROX_QUANTILES(own_med, 2)[OFFSET(1)] AS own_med FROM pg GROUP BY 1) os USING (album_id)
JOIN (SELECT p.album_id, ROUND(SUM(p.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share FROM pop p JOIN tot t USING (album_id) GROUP BY 1) rs USING (album_id)
ORDER BY 1,2,3
;

-- ===== B. Domino 19/20 rare sources by quarter (5d v4) =====
WITH excluded AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND suspected_cheater_flag),
rows_ AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start, a.album_close_date AS a_end, a.login_ratio, a.user_album_count,
    IFNULL(a.album_spent_today, 0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND a.album_id IN (19, 20)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5 AND MIN(user_album_count) > 1),
st AS (
  SELECT p.album_id, p.user_id, IFNULL(NULLIF(s.new_sticker_source, ''), '(null)') AS src, IFNULL(s.collected_by_joker_flag, FALSE) AS wj, s.new_sticker_mtx_campaign_name AS camp,
    LEAST(3, CAST(FLOOR(DATE_DIFF(s.sticker_collected_min_date, p.a_start, DAY) / DATE_DIFF(p.a_end, p.a_start, DAY) * 4) AS INT64)) AS q
  FROM pop p JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND s.album_id IN (19, 20)
    AND LOWER(s.sticker_type) = 'royal' AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= p.a_start AND s.sticker_collected_min_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
c AS (SELECT album_id, q, CASE
    WHEN IFNULL(camp,'') LIKE 'EV_Royal_Card_Popup%' THEN 'B0 First Royal gift'
    WHEN src = 'pixie_reward' THEN 'A Long feature'
    WHEN LOWER(src) LIKE '%momentum%' THEN 'Momentum'
    WHEN LOWER(src) LIKE '%trail%' AND LOWER(src) NOT LIKE '%tournament%' THEN 'Trail event'
    WHEN src = 'days_milestone' THEN 'B Daily'
    WHEN src = 'duplicates' THEN 'E Dup exchange'
    WHEN src = 'Market' THEN 'M Closing market'
    WHEN src IN ('joker','progress_offer','Missions','BuyThemAll','SeasonPass','OfferLuckyTwister','Box','mtx','1po') OR src LIKE '1+%' THEN 'D Paid offer'
    WHEN src = '(null)' THEN 'Unknown'
    WHEN src = 'collaboration grand prize' THEN 'Social'
    ELSE 'Other events' END AS cat FROM st)
SELECT album_id, q + 1 AS quarter, cat, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, q), 4) AS share
FROM c GROUP BY album_id, q, cat ORDER BY 1, 2, 3
;
