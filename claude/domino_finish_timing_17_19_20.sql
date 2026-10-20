-- 2026-10-18 (Eden approved, ran): Domino 17 vs 19 vs 20 finish day. 16.4 GB. Results: claude/approved-batch-2026-10-18.md
-- Population (same as the last3days slide): not first album, login ratio >= 0.5 on the last full day, not special, not suspected cheater.
-- Finish day = first day with 144 unique set stickers (common + golden + royal) in user_daily_album. Close day excluded.
-- d = finish day - close day (-1 = last full day); finishes 8+ days before close grouped as -8.
-- payer = album_spent_today > 0 during the album. Both payer finishers and all finishers are returned.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim < album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d, SUM(spend) > 0 AS payer,
    ARRAY_AGG(STRUCT(lr, past, excl) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l, MAX(date_dim) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, payer FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
)
SELECT album_id, GREATEST(-8, DATE_DIFF(fin_d, a_end, DAY)) AS d,
  COUNTIF(payer) AS fin_payers, COUNT(*) AS fin_all
FROM pop WHERE fin_d IS NOT NULL GROUP BY 1,2
UNION ALL
SELECT album_id, 0 AS d, COUNTIF(payer) AS pop_payers, COUNT(*) AS pop_all FROM pop GROUP BY 1
ORDER BY 1,2;
-- d = 0 row = population size (payers / all), used for finish rate.
