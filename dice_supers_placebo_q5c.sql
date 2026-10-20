-- Q5c (2026-10-14) Placebo base rate for "purchase <=10 / <=60 min before last Super". Project dice-dreams-dbt.
-- Pop = Q5a (missing exactly 1 sticker at end of close-5, not excluded, login ratio last row >= 0.5) + NOT first album (user_past_album_count > 0).
-- Anchor = last Super first-collected before close-4 00:00 UTC. Placebo = same player, anchor -24h / -48h.
-- Placebo counted only if [anchor - 60 min] >= album start (12:00 UTC).
WITH alb AS (
  SELECT 61 AS album_id, TIMESTAMP '2026-06-22 12:00:00' AS a_start_ts, DATE '2026-07-27' AS a_end UNION ALL
  SELECT 63, TIMESTAMP '2026-07-27 12:00:00', DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.a_end, alb.a_start_ts, a.album_login_ratio,
    a.unique_stickers_lt AS u_all, a.unique_super_stickers_lt AS u_s, a.unique_golden_stickers_lt AS u_g,
    a.user_past_album_count AS past_albums
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
gold AS (SELECT album_id, MAX(u_g) AS n_gold FROM r GROUP BY 1),
usr AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, ANY_VALUE(a_start_ts) AS a_start_ts
  FROM r GROUP BY 1, 2
  HAVING ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
pop AS (
  SELECT u.album_id, u.user_id, u.a_start_ts, TIMESTAMP(DATE_SUB(u.a_end, INTERVAL 4 DAY)) AS w_start_ts,
    CASE WHEN 12 - e.u_s = 1 THEN 'Super' WHEN g.n_gold - e.u_g = 1 THEN 'Golden' ELSE 'Common' END AS missing
  FROM usr u JOIN r e ON e.album_id = u.album_id AND e.user_id = u.user_id AND e.date_dim = DATE_SUB(u.a_end, INTERVAL 5 DAY)
  JOIN gold g ON g.album_id = u.album_id
  WHERE 144 - e.u_all = 1 AND IFNULL(e.past_albums, 0) > 0),                 -- not first album
lastsup AS (
  SELECT p.album_id, p.user_id, MAX(s.sticker_collected_ts) AS last_super_ts
  FROM pop p JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
    ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63)
    AND s.sticker_type = 'super' AND s.is_sticker_collected AND s.sticker_collected_ts < p.w_start_ts
  GROUP BY 1, 2),
anc AS (  -- real anchor (shift 0) + placebo anchors (24h, 48h)
  SELECT p.album_id, p.user_id, p.missing, p.a_start_ts, sh AS shift_h,
    TIMESTAMP_SUB(l.last_super_ts, INTERVAL sh HOUR) AS anchor_ts
  FROM pop p JOIN lastsup l USING (album_id, user_id), UNNEST([0, 24, 48]) AS sh),
pur AS (  -- purchases in album before the window (deduped)
  SELECT p.album_id, p.user_id, v.timestamp AS ts
  FROM pop p JOIN `dice-dreams-dbt.20_core.purchase_completed_vw` v ON v.user_id = p.user_id
  WHERE v.pdate BETWEEN DATE '2026-06-22' AND DATE '2026-09-03'
    AND v.timestamp >= p.a_start_ts AND v.timestamp < p.w_start_ts AND v.purchase_amount IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (PARTITION BY v.user_id, v.timestamp, v.external_order_id ORDER BY v.timestamp) = 1),
hit AS (
  SELECT a.album_id, a.user_id, a.missing, a.shift_h,
    TIMESTAMP_SUB(a.anchor_ts, INTERVAL 60 MINUTE) >= a.a_start_ts AS eligible,
    LOGICAL_OR(pu.ts BETWEEN TIMESTAMP_SUB(a.anchor_ts, INTERVAL 10 MINUTE) AND a.anchor_ts) AS p10,
    LOGICAL_OR(pu.ts BETWEEN TIMESTAMP_SUB(a.anchor_ts, INTERVAL 60 MINUTE) AND a.anchor_ts) AS p60
  FROM anc a LEFT JOIN pur pu USING (album_id, user_id)
  GROUP BY 1, 2, 3, 4, 5)
SELECT album_id, missing, shift_h,
  COUNT(*) AS players_with_last_super, COUNTIF(eligible) AS eligible,
  ROUND(COUNTIF(eligible AND IFNULL(p10, FALSE)) / NULLIF(COUNTIF(eligible), 0), 3) AS share_pur_10m,
  ROUND(COUNTIF(eligible AND IFNULL(p60, FALSE)) / NULLIF(COUNTIF(eligible), 0), 3) AS share_pur_60m
FROM hit WHERE missing IN ('Super', 'Golden')
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3

