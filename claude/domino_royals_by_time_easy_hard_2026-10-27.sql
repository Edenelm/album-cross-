-- 2026-10-27: Domino Easy vs Hard, average % of the album's Royals held by % of album time (10% steps + close), albums 17/19/20.
-- Same population and segment rule as Q1 of domino_easy_hard_splits_2026-10-26.sql (standard-population payers; segment = album_segment on first row).
-- Feeds slide ehline_slide (line chart in the style of "% of the album's Rares Collected, by % of Album Time"). Results: claude/domino-easy-hard-splits-2026-10-26.md §1b
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
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, DATE_DIFF(MIN(s.sticker_collected_min_date), ANY_VALUE(p.a_start), DAY) + 1 AS day
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND s.album_id IN (17,19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal' AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
nroy AS (SELECT album_id, COUNT(DISTINCT sticker_id) AS n_roy FROM r GROUP BY 1),
steps AS (SELECT s FROM UNNEST(GENERATE_ARRAY(1, 10)) AS s),
held AS (
  SELECT p.album_id, p.seg0, p.user_id, st.s, COUNTIF(r.day <= CAST(ROUND(p.n_days * st.s / 10) AS INT64)) AS h
  FROM pop p CROSS JOIN steps st LEFT JOIN r ON r.album_id = p.album_id AND r.user_id = p.user_id
  GROUP BY 1,2,3,4
)
SELECT h.album_id, h.seg0, h.s * 10 AS pct_time, COUNT(*) AS payers, ROUND(100 * AVG(h.h) / ANY_VALUE(n.n_roy), 1) AS pct_royals
FROM held h JOIN nroy n USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2,3
