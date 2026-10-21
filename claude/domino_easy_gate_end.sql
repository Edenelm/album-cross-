-- Domino 19/20: end status by easy / hard segment (2026-10-21, Eden). Results: claude/domino-easy-gate-end-2026-10-21.md. 10.9 GB, domino-dreams-dbt.
-- Standard population payers (album-table spend > 0 start..close-1). Segment = album_segment on the player's first row (easy / hard; other not shown).
-- End status at the end of the close day: finished / 1-3 missing / 4-5 missing (the easy gate = 2 Royals + 3 Goldens) / 6-10 / 11+.
-- only_gate_types = the missing count equals missing Goldens (of 28) + missing Royals (of 9), i.e. no Commons missing.
-- sh_game_rev = group album spend / total game purchase revenue during the album (all players, cheaters / test excluded).
WITH alb AS (SELECT 19 AS album_id, DATE '2026-07-06' AS a_start, DATE '2026-08-24' AS a_end UNION ALL SELECT 20, DATE '2026-08-24', DATE '2026-10-12'),
ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(unique_golden_stickers_lt,0) AS gold, IFNULL(unique_royal_stickers_tl,0) AS royal,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    album_segment AS seg
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
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
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_close, MAX(gold) AS gold_close, MAX(royal) AS royal_close,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    ARRAY_AGG(seg IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg0
  FROM ud GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, a_end, uniq_close, gold_close, royal_close, alb_rev, last_d, seg0, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT album_id, user_id, uniq_close, gold_close, royal_close, alb_rev, seg0 FROM u1
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
lab AS (
  SELECT album_id, alb_rev,
    CASE WHEN LOWER(seg0) LIKE '%easy%' THEN 'easy' WHEN LOWER(seg0) LIKE '%hard%' THEN 'hard' ELSE 'other' END AS seg,
    CASE WHEN uniq_close >= 144 THEN '0_finished' WHEN uniq_close >= 141 THEN '1_miss_1_3' WHEN uniq_close >= 139 THEN '2_miss_4_5'
         WHEN uniq_close >= 134 THEN '3_miss_6_10' ELSE '4_miss_11plus' END AS dist,
    uniq_close BETWEEN 139 AND 143 AND 144 - uniq_close = (28 - gold_close) + (9 - royal_close) AS only_gate_types
  FROM pop
)
SELECT album_id, seg, dist, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, seg), 4) AS sh_seg_payers,
  ROUND(SUM(alb_rev) / SUM(SUM(alb_rev)) OVER (PARTITION BY album_id, seg), 4) AS sh_seg_rev,
  ROUND(SUM(alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev,
  COUNTIF(only_gate_types) AS n_only_gold_royal_missing
FROM lab JOIN tot t USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2,3
;
