-- 2026-10-26 (Eden, item 1): Goldens progression of Domino Easy vs Hard paying players, albums 17 / 19 / 20, for the "Goldens Split After 70% of the Album" slide.
-- Population = the slide's: standard population payers (not first album, not special / suspected cheater, login_ratio >= 0.5 on the last row before close, row on close-1,
--   paid on any album day incl. close day); segment = album_segment on the first album row. Album length n_days = close - open + 1 (close day included, as in golden_timeline_2026-10-23.sql).
-- Measure = average share of the 28 Goldens held at the end of day round(n_days * k / 10), k = 1..10 (deciles of album time); missing_avg = 28 - average held.
-- Results: claude/domino-easy-goldens-progression-2026-10-26.md. Scan 32 GB.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, album_segment AS seg
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', IF(LOWER(seg) LIKE '%hard%', 'hard', 'other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_start, a_end, seg0, DATE_DIFF(a_end, a_start, DAY) + 1 AS n_days FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0 AND seg0 IN ('easy','hard')
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, DATE_DIFF(MIN(s.sticker_collected_min_date), ANY_VALUE(p.a_start), DAY) + 1 AS day
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND s.album_id IN (17,19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'golden' AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
dec AS (SELECT k FROM UNNEST(GENERATE_ARRAY(1, 10)) AS k),
held AS (
  SELECT p.album_id, p.seg0, p.user_id, d.k, COUNTIF(r.day <= CAST(ROUND(p.n_days * d.k / 10) AS INT64)) AS n_held
  FROM pop p CROSS JOIN dec d LEFT JOIN r ON r.album_id = p.album_id AND r.user_id = p.user_id GROUP BY 1,2,3,4
)
SELECT album_id, seg0, k AS decile, COUNT(*) AS payers, ROUND(100 * AVG(n_held) / 28, 1) AS pct_goldens_avg, ROUND(28 - AVG(n_held), 2) AS missing_avg
FROM held GROUP BY 1,2,3 ORDER BY 1,2,3;
