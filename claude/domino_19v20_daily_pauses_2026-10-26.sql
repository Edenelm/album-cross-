-- 2026-10-26: Domino 19 vs 20, median paying player, per album day: new set stickers, new Goldens, cumulative held.
-- Standard population payers (not first album, not special / suspected cheater, lr>=0.5 on last row before close, row on close-1, paid any album day incl close).
-- Set sticker = any collected sticker_type except joker. New = first receipt (MIN sticker_collected_min_date). Day 1 = album open day; last day = close day.
-- Output per album: series 'day:p50 new stickers:p50 new goldens:p50 stickers held:p50 goldens held' + N payers.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_start, a_end FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, LOWER(ANY_VALUE(s.sticker_type)) = 'golden' AS is_g,
    DATE_DIFF(MIN(s.sticker_collected_min_date), ANY_VALUE(p.a_start), DAY) + 1 AS day
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) NOT LIKE '%joker%' AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
alen AS (SELECT album_id, MIN(a_start) AS a_start, DATE_DIFF(ANY_VALUE(a_end), ANY_VALUE(a_start), DAY) + 1 AS n_days FROM pop GROUP BY 1),
grid AS (SELECT p.album_id, p.user_id, day FROM pop p JOIN alen USING (album_id), UNNEST(GENERATE_ARRAY(1, alen.n_days)) AS day),
daily AS (SELECT album_id, user_id, day, COUNT(*) AS n_new, COUNTIF(is_g) AS g_new FROM r GROUP BY 1,2,3),
cum AS (
  SELECT g.album_id, g.day, IFNULL(d.n_new,0) AS n_new, IFNULL(d.g_new,0) AS g_new,
    SUM(IFNULL(d.n_new,0)) OVER (PARTITION BY g.album_id, g.user_id ORDER BY g.day) AS n_held,
    SUM(IFNULL(d.g_new,0)) OVER (PARTITION BY g.album_id, g.user_id ORDER BY g.day) AS g_held
  FROM grid g LEFT JOIN daily d USING (album_id, user_id, day)
),
agg AS (
  SELECT album_id, day, COUNT(*) AS n,
    APPROX_QUANTILES(n_new,100)[OFFSET(50)] AS m_new, APPROX_QUANTILES(g_new,100)[OFFSET(50)] AS m_g,
    APPROX_QUANTILES(n_held,100)[OFFSET(50)] AS m_held, APPROX_QUANTILES(g_held,100)[OFFSET(50)] AS m_gheld,
    ROUND(AVG(n_new),1) AS avg_new
  FROM cum GROUP BY 1,2
)
SELECT a.album_id, ANY_VALUE(l.a_start) AS open_date, MAX(a.n) AS payers,
  STRING_AGG(FORMAT('%d:%d:%d:%d:%d:%.1f', a.day, a.m_new, a.m_g, a.m_held, a.m_gheld, a.avg_new), ' ' ORDER BY a.day) AS series
FROM agg a JOIN alen l USING (album_id) GROUP BY 1 ORDER BY 1;
