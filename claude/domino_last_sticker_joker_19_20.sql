-- 2026-10-19 (Eden asked to run album 20; ran, 19.04 GB, domino-dreams-dbt).
-- Domino 19 (check) and 20: share of paying finishers whose finishing (last new) sticker was Joker-filled.
-- Population = same as domino_finish_timing_17_19_20.sql (not first album, login ratio >= 0.5 on last full day, not special, not suspected cheater, payer = spent during album).
-- Result: album 19 = 5,319 payer finishers, 95.5% last sticker via Joker (matches endgame-last-week 95.5%); last sticker Royal 51% / Golden 48% / Common 1%.
--         album 20 = 8,548 payer finishers, 94.8% via Joker; last sticker Royal 80% / Golden 18% / Common 2%.
-- Used on deck slides last3days (Domino 19/20 average 95%) and domino-3albums (17: 45% from endgame-last-week; 19: 96%; 20: 95%).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim < album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d, SUM(spend) > 0 AS payer,
    ARRAY_AGG(STRUCT(lr, past, excl) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l, MAX(date_dim) AS last_d
  FROM ud GROUP BY 1,2
),
fin AS (
  SELECT album_id, user_id, a_end, fin_d FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users) AND payer AND fin_d IS NOT NULL
),
last_st AS (
  SELECT f.album_id, f.user_id, LOWER(s.sticker_type) AS t, IFNULL(s.collected_by_joker_flag, FALSE) AS jk
  FROM fin f JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
    ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND s.album_id IN (19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal')
    AND s.sticker_collected_min_date <= f.fin_d
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id ORDER BY s.sticker_collected_min_ts DESC) = 1
)
SELECT album_id, COUNT(*) AS payer_finishers,
  ROUND(COUNTIF(jk) / COUNT(*), 3) AS last_via_joker,
  ROUND(COUNTIF(t = 'royal') / COUNT(*), 3) AS last_royal,
  ROUND(COUNTIF(t = 'golden') / COUNT(*), 3) AS last_golden,
  ROUND(COUNTIF(t = 'common') / COUNT(*), 3) AS last_common
FROM last_st GROUP BY 1 ORDER BY 1
