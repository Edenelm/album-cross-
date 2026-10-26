-- 2026-10-25 Domino diagnosis, topic 2: payers at 1 / 2 / 3 / 4-5 / 6+ missing on close-4, by Easy/Hard, albums 19 and 20.
-- Population: standard-population payers (not first album, not special, not suspected cheater, login ratio >= 0.5 on last row before close,
--   row on close-1, album spend > 0 from start to close-1). Payer by spend to close-1 here (close-day-only payers left out: +0.2-0.4%).
-- State fixed BEFORE the outcome: missing on close-4 (max unique set stickers on rows up to close-4).
-- Outcomes: finished = 144 by end of close day (daily table; Domino updates the close-day row).
--   spend per active day before (start..close-4) vs after (close-3..close-1); close day left out (half day).
-- sh_game_rev = cell album spend (start..close-1) / total game purchase revenue during the album:
--   19 = $17,644,426; 20 = $16,269,671 (claude/game-revenue-rebase-2026-10-21.md).
-- Results: claude/domino-dx-map-2026-10-25.md
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, album_segment AS seg
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), spend, 0)) AS rev_pre,
    COUNTIF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY)) AS days_pre,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 3 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY), spend, 0)) AS rev_post,
    COUNTIF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 3 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS days_post,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS uniq_c4,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    ARRAY_AGG(seg IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg0
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, alb_rev, rev_pre, days_pre, rev_post, days_post, uniq_end >= 144 AS fin, 144 - uniq_c4 AS miss,
    CASE WHEN LOWER(seg0) LIKE '%easy%' THEN 'easy' WHEN LOWER(seg0) LIKE '%hard%' THEN 'hard' ELSE 'other' END AS seg
  FROM u0
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad)
),
b AS (
  SELECT *, CASE WHEN miss <= 0 THEN '0_done' WHEN miss = 1 THEN '1' WHEN miss = 2 THEN '2' WHEN miss = 3 THEN '3'
    WHEN miss <= 5 THEN '4-5' ELSE '6+' END AS bucket,
    IF(album_id = 19, 17644426, 16269671) AS game_rev
  FROM pop WHERE seg != 'other'
)
SELECT album_id, seg, bucket, COUNT(*) AS payers,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, seg), 3) AS sh_seg_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(game_rev), 4) AS sh_game_rev,
  ROUND(COUNTIF(fin) / COUNT(*), 3) AS fin_rate,
  ROUND(SUM(rev_pre) / SUM(days_pre), 2) AS usd_per_day_pre,
  ROUND(SUM(rev_post) / NULLIF(SUM(days_post),0), 2) AS usd_per_day_post,
  ROUND(SAFE_DIVIDE(SUM(rev_post) / NULLIF(SUM(days_post),0), SUM(rev_pre) / SUM(days_pre)), 2) AS lift_post_vs_pre
FROM b GROUP BY 1,2,3 ORDER BY 1,2,3
