-- 2026-10-25 Domino diagnosis, topic 2 (gate structure from data, not from config).
-- Q: which golden/royal stickers could only be obtained by joker (= locked to the end), per album and per Easy/Hard segment?
-- Release proxy per sticker = first day with >= 200 non-joker first collections (my threshold, to skip testers / noise).
-- Segment = album_segment on the player's first album row (same rule as gate_distance_finish_queries.sql).
-- Results: claude/domino-dx-map-2026-10-25.md
WITH seg AS (
  SELECT album_id, user_id,
    ARRAY_AGG(album_segment IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg0
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20)
  GROUP BY 1,2
),
st AS (
  SELECT s.album_id, s.sticker_id, LOWER(s.sticker_type) AS t, s.phase,
    CASE WHEN LOWER(g.seg0) LIKE '%easy%' THEN 'easy' WHEN LOWER(g.seg0) LIKE '%hard%' THEN 'hard' ELSE 'other' END AS seg,
    s.sticker_collected_min_date AS dt, IFNULL(s.collected_by_joker_flag, FALSE) AS jk
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
  JOIN seg g USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND s.album_id IN (19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('golden','royal')
),
d AS (
  SELECT album_id, sticker_id, t, phase, seg, dt, COUNTIF(NOT jk) AS n_nonjk, COUNT(*) AS n
  FROM st GROUP BY 1,2,3,4,5,6
)
SELECT album_id, seg, sticker_id, t, phase,
  MIN(IF(n_nonjk >= 200, dt, NULL)) AS rel_d,
  SUM(n) AS collectors, ROUND(1 - SUM(n_nonjk) / SUM(n), 3) AS sh_joker
FROM d WHERE seg != 'other'
GROUP BY 1,2,3,4,5
HAVING sh_joker >= 0.5 OR rel_d >= DATE '2026-08-10' AND album_id = 19 OR rel_d >= DATE '2026-09-28' AND album_id = 20
ORDER BY 1,2,6,3
