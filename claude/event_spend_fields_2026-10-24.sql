-- Eden 2026-10-24: what do the post-album event spend fields count? Docs (BigQuery column descriptions, Confluence Deluxe pages) do not define them.
-- Check: event spend vs the player's full in-game spend that day (album table album_spent_today, one value per user-day).
-- Results: claude/event-spend-fields-2026-10-24.md

-- 1) Domino (domino-dreams-dbt), Deluxe table internal check, albums 19 / 20 (7 MB)
WITH d AS (
  SELECT album_id, IFNULL(deluxe_album_spent_today, 0) AS dlx, IFNULL(album_spent_today, 0) AS alb, IFNULL(deluxe_purchase_flag, FALSE) AS dlx_buy
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_deluxe_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-24' AND album_id IN (19, 20))
SELECT album_id, COUNTIF(alb > 0) AS days_with_spend, COUNTIF(dlx > 0) AS days_with_deluxe_spend,
  COUNTIF(dlx > 0 AND ABS(dlx - alb) < 0.01) AS deluxe_equals_all, COUNTIF(dlx > 0 AND dlx < alb - 0.01) AS deluxe_part_of_all,
  COUNTIF(dlx > alb + 0.01) AS deluxe_above_all, COUNTIF(alb > 0 AND dlx = 0) AS spend_but_no_deluxe_spend,
  COUNTIF(dlx_buy) AS deluxe_purchase_flag_days, ROUND(SUM(dlx)) AS deluxe_spend, ROUND(SUM(alb)) AS all_spend_same_rows
FROM d GROUP BY 1 ORDER BY 1;

-- 2) Domino album 20, Deluxe spend vs full daily spend in the main album table, by day type (2.0 GB)
WITH dl AS (
  SELECT user_id, date_dim, IFNULL(deluxe_album_spent_today, 0) AS dlx,
    CASE WHEN date_dim = user_deluxe_album_start_date THEN '1 Deluxe start day'
         WHEN date_dim >= album_close_date THEN '3 close day or later'
         ELSE '2 other days' END AS day_type
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_deluxe_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-24' AND album_id = 20 AND IFNULL(deluxe_album_spent_today, 0) > 0),
m AS (
  SELECT user_id, date_dim, MAX(IFNULL(album_spent_today, 0)) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-24'
  GROUP BY 1, 2)
SELECT day_type, COUNT(1) AS deluxe_spend_days, COUNTIF(ABS(dl.dlx - m.spend) < 0.01) AS equal_to_full_spend,
  COUNTIF(dl.dlx < m.spend - 0.01) AS below_full_spend, ROUND(SUM(dl.dlx)) AS deluxe_spend, ROUND(SUM(m.spend)) AS full_spend
FROM dl LEFT JOIN m USING (user_id, date_dim) GROUP BY 1 ORDER BY 1;

-- 3) Disney (solitaire-dreams-411507), Legendary ids 43560 / 50303, magic_spent_today vs full daily spend (14.1 GB)
WITH mg AS (
  SELECT user_id, date_dim, magic_event_id, IFNULL(magic_spent_today, 0) AS mgc,
    IF(date_dim = user_magic_start_date, '1 event start day', '2 other days') AS day_type
  FROM `solitaire-dreams-411507.bi_prod.user_daily_magic_event`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-24' AND magic_event_id IN (43560, 50303) AND IFNULL(magic_spent_today, 0) > 0),
m AS (
  SELECT user_id, date_dim, MAX(IFNULL(album_spent_today, 0)) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-24'
  GROUP BY 1, 2)
SELECT magic_event_id, day_type, COUNT(1) AS event_spend_days, COUNTIF(m.user_id IS NULL) AS no_row_in_album_table,
  COUNTIF(ABS(mg.mgc - m.spend) < 0.01) AS equal_to_full_spend, COUNTIF(mg.mgc < m.spend - 0.01) AS below_full_spend,
  COUNTIF(mg.mgc > m.spend + 0.01) AS above_full_spend, ROUND(SUM(mg.mgc)) AS event_spend, ROUND(SUM(m.spend)) AS full_spend
FROM mg LEFT JOIN m USING (user_id, date_dim) GROUP BY 1, 2 ORDER BY 1, 2;
