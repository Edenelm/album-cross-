-- Eden 2026-10-23: "if a far payer who did not pay gets more Royals, will she pay to finish?" Descriptive check (not a test), Disney 14/15 (solitaire-dreams-411507).
-- Population: standard population (MidDis rules), middle payers P50-95 of spend so far at 75% of the album, 4+ stickers missing on the row 14 days before close,
--   active on 5+ of days 14..8 before close. Split: got >=1 new Royal from a FREE source in days 14..8 (yes / no).
-- Outcomes: share who paid in days 14..8 (before) and days 7..1 (after), $ per player in each window, share 1-3 missing at close-1, share 0 missing at close-1.
WITH excluded AS (SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile` WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, DATE_DIFF(a.album_close_date, a.date_dim, DAY) AS dbc,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d, DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    IFNULL(a.login_ratio, -1) AS lr, IFNULL(a.user_album_count, 0) AS uac, IFNULL(a.album_spent_today, 0) AS spend, IFNULL(a.active_flag, FALSE) AS act,
    IFNULL(a.unique_common_stickers_lt, 0) + IFNULL(a.unique_golden_stickers_lt, 0) + IFNULL(a.unique_royal_stickers_tl, 0) AS held
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND a.album_id IN (14, 15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, MIN(d) AS first_d,
    SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far,
    ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS lr_last, ARRAY_AGG(uac ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS uac_last,
    ARRAY_AGG(IF(dbc >= 14, held, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS held_14,
    ARRAY_AGG(held ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS held_end,
    COUNTIF(act AND dbc BETWEEN 8 AND 14) AS act_days_pre,
    SUM(IF(dbc BETWEEN 8 AND 14, spend, 0)) AS spend_pre, SUM(IF(dbc BETWEEN 1 AND 7, spend, 0)) AS spend_post
  FROM r0 GROUP BY 1, 2),
tgt AS (SELECT * FROM ua WHERE lr_last >= 0.5 AND uac_last > 1 AND first_d <= CAST(CEIL(0.75 * n) AS INT64) - 1),
p AS (SELECT tgt.*, IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr FROM tgt),
far AS (SELECT album_id, user_id, spend_pre, spend_post, 144 - held_end AS m_end FROM p
        WHERE so_far > 0 AND pr >= 0.5 AND pr < 0.95 AND 144 - held_14 >= 4 AND act_days_pre >= 5),
cl AS (SELECT album_id, MAX(album_close_date) AS a_close FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
       WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND album_id IN (14, 15) GROUP BY 1),
fr AS (
  SELECT DISTINCT s.album_id, s.user_id
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN cl USING (album_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND s.album_id IN (14, 15)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal'
    AND IFNULL(s.new_sticker_source, '') NOT IN ('purchase', 'purchase_gift')
    AND DATE_DIFF(cl.a_close, s.sticker_collected_min_date, DAY) BETWEEN 8 AND 14)
SELECT f.album_id, fr.user_id IS NOT NULL AS got_free_royal_d14_8, COUNT(*) AS players,
  ROUND(AVG(IF(f.spend_pre > 0, 1, 0)), 3) AS paid_d14_8, ROUND(AVG(IF(f.spend_post > 0, 1, 0)), 3) AS paid_d7_1,
  ROUND(AVG(f.spend_pre), 2) AS usd_d14_8, ROUND(AVG(f.spend_post), 2) AS usd_d7_1,
  ROUND(AVG(IF(f.m_end BETWEEN 1 AND 3, 1, 0)), 3) AS near_at_close, ROUND(AVG(IF(f.m_end = 0, 1, 0)), 3) AS done_by_close_1,
  ROUND(AVG(IF(f.spend_pre = 0 AND f.spend_post > 0, 1, 0)), 3) AS started_paying_d7_1,
  ROUND(SAFE_DIVIDE(COUNTIF(f.spend_pre = 0 AND f.spend_post > 0), COUNTIF(f.spend_pre = 0)), 3) AS of_nonpayers_d14_8_paid_d7_1
FROM far f LEFT JOIN fr USING (album_id, user_id) GROUP BY 1, 2 ORDER BY 1, 2;
