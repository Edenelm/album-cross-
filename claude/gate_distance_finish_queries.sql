-- 2026-10-21 (Eden): payers who were exactly 3 / 4 / 5 stickers short 4 and 3 days before close - what share finished (144 by the end of the close day)?
-- Domino easy vs hard, compared with Dice (album_segment Easy/Medium/Hard/Extreme) and Disney (no segment field: spend groups only).
-- Results: claude/gate-distance-finish-2026-10-21.md
-- Population: standard-population payers (not first album, not excluded, login ratio >= 0.5 on the last row before close, row on close-1, album-table spend > 0 start..close-1).
-- Checkpoint state: missing = 144 - max unique set stickers on rows up to close-4 (k = c4) or close-3 (k = c3). Rows kept: missing 3, 4, 5.
-- Segment = album_segment on the player's first album row. Group = album spend so far / days so far at the checkpoint (0 / <=2 / 2-5 / 5-20 / >20 $ a day): my choice, same cut as stand_close4_queries.sql, so "same characteristics" can be compared across games.
-- fin_rate = finishers / players in the cell. sh_game_rev = the cell's album spend (start..close-1) / total game purchase revenue during the album (all players, cheaters / test excluded).

-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    album_segment AS seg
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
alb AS (SELECT album_id, MIN(a_start) AS a_start, MIN(a_end) AS a_end FROM ud GROUP BY 1),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(special_user_flag,FALSE) OR IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
tot AS (
  SELECT a.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN alb a ON m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_close,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), spend, 0)) AS rev_c4,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), spend, 0)) AS rev_c3,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS uniq_c4,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), uniq, NULL)) AS uniq_c3,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    ARRAY_AGG(seg IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg0
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_start, a_end, uniq_close, alb_rev, last_d, rev_c4, rev_c3, uniq_c4, uniq_c3, seg0, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT album_id, user_id, a_start, a_end, uniq_close, alb_rev, rev_c4, rev_c3, uniq_c4, uniq_c3,
    CASE WHEN LOWER(seg0) LIKE '%easy%' THEN 'easy' WHEN LOWER(seg0) LIKE '%hard%' THEN 'hard' ELSE 'other' END AS seg
  FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cp AS (
  SELECT album_id, user_id, alb_rev, uniq_close >= 144 AS fin, seg, k, miss,
    CASE WHEN IFNULL(pd, 0) = 0 THEN '0' WHEN pd <= 2 THEN '1_le2' WHEN pd <= 5 THEN '2_2_5' WHEN pd <= 20 THEN '3_5_20' ELSE '4_20plus' END AS grp
  FROM pop, UNNEST([
    STRUCT('c4' AS k, 144 - uniq_c4 AS miss, SAFE_DIVIDE(rev_c4, DATE_DIFF(DATE_SUB(a_end, INTERVAL 4 DAY), a_start, DAY) + 1) AS pd),
    STRUCT('c3', 144 - uniq_c3, SAFE_DIVIDE(rev_c3, DATE_DIFF(DATE_SUB(a_end, INTERVAL 3 DAY), a_start, DAY) + 1))
  ])
  WHERE miss BETWEEN 3 AND 5
),
lab AS (
  SELECT album_id, k, miss, fin, alb_rev, label
  FROM cp, UNNEST([CONCAT('seg_', seg), CONCAT('grp_', grp), 'all']) AS label
  WHERE label != 'seg_other'
)
SELECT l.album_id, l.k, l.miss, l.label, COUNT(*) AS n, COUNTIF(l.fin) AS n_fin,
  ROUND(COUNTIF(l.fin) / COUNT(*), 3) AS fin_rate,
  ROUND(SUM(l.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev
FROM lab l JOIN tot t USING (album_id)
GROUP BY 1,2,3,4 ORDER BY 1,2,3,4
;

-- ===== DICE 61/63 (dice-dreams-dbt) =====
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MIN(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND album_id IN (61,63)
  GROUP BY 1
),
ud AS (
  SELECT album_id, user_id, date_dim,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, album_segment AS seg
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND album_id IN (61,63) AND date_dim < album_end_date
),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= a.a_end
  GROUP BY 1,2
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06'
),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
tot AS (
  SELECT a.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN alb a ON m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM excl)
  GROUP BY 1
),
u0 AS (
  SELECT u.album_id, u.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end, MAX(u.uniq) AS uniq_prev,
    SUM(u.spend) AS alb_rev, MAX(u.date_dim) AS last_d,
    SUM(IF(u.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), u.spend, 0)) AS rev_c4,
    SUM(IF(u.date_dim <= DATE_SUB(a.a_end, INTERVAL 3 DAY), u.spend, 0)) AS rev_c3,
    MAX(IF(u.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), u.uniq, NULL)) AS uniq_c4,
    MAX(IF(u.date_dim <= DATE_SUB(a.a_end, INTERVAL 3 DAY), u.uniq, NULL)) AS uniq_c3,
    ARRAY_AGG(STRUCT(u.lr AS lr, u.past AS past, u.excl AS excl) ORDER BY u.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    ARRAY_AGG(u.seg IGNORE NULLS ORDER BY u.date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg0
  FROM ud u JOIN alb a USING (album_id) GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_start, a_end, uniq_prev, alb_rev, last_d, rev_c4, rev_c3, uniq_c4, uniq_c3, seg0, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end, u.alb_rev, u.rev_c4, u.rev_c3, u.uniq_c4, u.uniq_c3,
    GREATEST(IFNULL(s.n_uniq, 0), IFNULL(u.uniq_prev, 0)) AS uniq_close,
    IFNULL(LOWER(u.seg0), 'none') AS seg
  FROM u1 u LEFT JOIN st s USING (album_id, user_id)
  WHERE u.last_d = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
),
cp AS (
  SELECT album_id, user_id, alb_rev, uniq_close >= 144 AS fin, seg, k, miss,
    CASE WHEN IFNULL(pd, 0) = 0 THEN '0' WHEN pd <= 2 THEN '1_le2' WHEN pd <= 5 THEN '2_2_5' WHEN pd <= 20 THEN '3_5_20' ELSE '4_20plus' END AS grp
  FROM pop, UNNEST([
    STRUCT('c4' AS k, 144 - uniq_c4 AS miss, SAFE_DIVIDE(rev_c4, DATE_DIFF(DATE_SUB(a_end, INTERVAL 4 DAY), a_start, DAY) + 1) AS pd),
    STRUCT('c3', 144 - uniq_c3, SAFE_DIVIDE(rev_c3, DATE_DIFF(DATE_SUB(a_end, INTERVAL 3 DAY), a_start, DAY) + 1))
  ])
  WHERE miss BETWEEN 3 AND 5
),
lab AS (
  SELECT album_id, k, miss, fin, alb_rev, label
  FROM cp, UNNEST([CONCAT('seg_', seg), CONCAT('grp_', grp), 'all']) AS label
)
SELECT l.album_id, l.k, l.miss, l.label, COUNT(*) AS n, COUNTIF(l.fin) AS n_fin,
  ROUND(COUNTIF(l.fin) / COUNT(*), 3) AS fin_rate,
  ROUND(SUM(l.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev
FROM lab l JOIN tot t USING (album_id)
GROUP BY 1,2,3,4 ORDER BY 1,2,3,4
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507); album_segment is 'def_default' for every row, so spend groups only =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
alb AS (SELECT album_id, MIN(a_start) AS a_start, MIN(a_end) AS a_end FROM ud GROUP BY 1),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
tot AS (
  SELECT a.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN alb a ON m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_close,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), spend, 0)) AS rev_c4,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), spend, 0)) AS rev_c3,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS uniq_c4,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), uniq, NULL)) AS uniq_c3,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_start, a_end, uniq_close, alb_rev, last_d, rev_c4, rev_c3, uniq_c4, uniq_c3, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT album_id, user_id, a_start, a_end, uniq_close, alb_rev, rev_c4, rev_c3, uniq_c4, uniq_c3
  FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cp AS (
  SELECT album_id, user_id, alb_rev, uniq_close >= 144 AS fin, k, miss,
    CASE WHEN IFNULL(pd, 0) = 0 THEN '0' WHEN pd <= 2 THEN '1_le2' WHEN pd <= 5 THEN '2_2_5' WHEN pd <= 20 THEN '3_5_20' ELSE '4_20plus' END AS grp
  FROM pop, UNNEST([
    STRUCT('c4' AS k, 144 - uniq_c4 AS miss, SAFE_DIVIDE(rev_c4, DATE_DIFF(DATE_SUB(a_end, INTERVAL 4 DAY), a_start, DAY) + 1) AS pd),
    STRUCT('c3', 144 - uniq_c3, SAFE_DIVIDE(rev_c3, DATE_DIFF(DATE_SUB(a_end, INTERVAL 3 DAY), a_start, DAY) + 1))
  ])
  WHERE miss BETWEEN 3 AND 5
),
lab AS (
  SELECT album_id, k, miss, fin, alb_rev, label
  FROM cp, UNNEST([CONCAT('grp_', grp), 'all']) AS label
)
SELECT l.album_id, l.k, l.miss, l.label, COUNT(*) AS n, COUNTIF(l.fin) AS n_fin,
  ROUND(COUNTIF(l.fin) / COUNT(*), 3) AS fin_rate,
  ROUND(SUM(l.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev
FROM lab l JOIN tot t USING (album_id)
GROUP BY 1,2,3,4 ORDER BY 1,2,3,4
;
