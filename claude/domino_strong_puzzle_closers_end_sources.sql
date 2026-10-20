-- 2026-10-18: Domino 20 — 393 strong (5$+/day prev album) finishers whose last two new stickers were both from Puzzle: sources/campaigns of new stickers in the last 7 days before close + their album and last-7-day spend.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12' AND album_id IN (18,19,20) AND date_dim < album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
alb0 AS (SELECT album_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM ud GROUP BY 1),
alb AS (SELECT album_id, a_start, a_end, LAG(album_id) OVER (ORDER BY a_start) AS prev_id FROM alb0),
tgt AS (
  SELECT a.album_id, a.a_start, a.a_end, a.prev_id, p.a_start AS p_start, p.a_end AS p_end
  FROM alb a JOIN alb p ON p.album_id = a.prev_id WHERE a.album_id IN (19,20)
),
pop AS (
  SELECT u.album_id, u.user_id, t.a_start, t.a_end, t.prev_id, t.p_start, t.p_end, u.uniq AS uniq_end
  FROM ud u JOIN tgt t USING (album_id)
  WHERE u.date_dim = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
cur AS (SELECT p.album_id, p.user_id, SUM(u.spend) AS rev_alb FROM pop p JOIN ud u USING (album_id, user_id) GROUP BY 1,2),
prv_rev AS (
  SELECT p.album_id, p.user_id, SUM(u.spend) AS rev_prev
  FROM pop p JOIN ud u ON u.user_id = p.user_id AND u.album_id = p.prev_id GROUP BY 1,2
),
prv_act AS (
  SELECT p.album_id, p.user_id, COUNTIF(m.act) AS ad_prev
  FROM pop p JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY) GROUP BY 1,2
),
st AS (
  SELECT p.album_id, p.user_id, s.sticker_collected_min_ts AS ts, IFNULL(s.new_sticker_source, '') AS src
  FROM pop p JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND s.album_id IN (19,20) AND s.user_collected_sticker_flag
    AND p.uniq_end >= 144 AND s.sticker_collected_min_date >= p.a_start AND s.sticker_collected_min_date < p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
last2 AS (
  SELECT album_id, user_id, COUNTIF(src = 'Puzzle') AS puzzle_in_last2
  FROM (SELECT album_id, user_id, src FROM st QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) <= 2)
  GROUP BY 1,2
),
d AS (
  SELECT p.album_id, p.user_id, p.uniq_end >= 144 AS fin, IFNULL(c.rev_alb, 0) AS rev_alb,
    CASE WHEN SAFE_DIVIDE(r.rev_prev, a.ad_prev) IS NULL OR SAFE_DIVIDE(r.rev_prev, a.ad_prev) = 0 THEN 'g0'
         WHEN SAFE_DIVIDE(r.rev_prev, a.ad_prev) <= 2 THEN 'g1_le2' WHEN SAFE_DIVIDE(r.rev_prev, a.ad_prev) <= 5 THEN 'g2_2_5'
         WHEN SAFE_DIVIDE(r.rev_prev, a.ad_prev) <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END AS grp,
    IFNULL(l.puzzle_in_last2, 0) = 2 AS both_puzzle
  FROM pop p LEFT JOIN cur c USING (album_id, user_id) LEFT JOIN prv_rev r USING (album_id, user_id)
  LEFT JOIN prv_act a USING (album_id, user_id) LEFT JOIN last2 l USING (album_id, user_id)
),
strong AS (
  SELECT d.album_id, d.user_id, p.a_start, p.a_end, d.rev_alb FROM d JOIN pop p USING (album_id, user_id)
  WHERE d.album_id = 20 AND d.fin AND d.both_puzzle AND d.grp IN ('g3_5_20','g4_20plus')
),
end_rev AS (
  SELECT s.user_id, SUM(u.spend) AS rev_last7 FROM strong s JOIN ud u ON u.user_id = s.user_id AND u.album_id = 20
    AND u.date_dim BETWEEN DATE_SUB(s.a_end, INTERVAL 7 DAY) AND DATE_SUB(s.a_end, INTERVAL 1 DAY) GROUP BY 1
),
st7 AS (
  SELECT s.user_id, IFNULL(NULLIF(x.new_sticker_source,''),'(empty)') AS src, IFNULL(x.new_sticker_mtx_campaign_name,'(null)') AS camp,
    IFNULL(x.collected_by_joker_flag, FALSE) AS joker
  FROM strong s JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` x ON x.album_id = 20 AND x.user_id = s.user_id
  WHERE x.sticker_collected_min_date BETWEEN DATE '2026-08-01' AND DATE '2026-10-12' AND x.album_id = 20 AND x.user_collected_sticker_flag
    AND x.sticker_collected_min_date BETWEEN DATE_SUB(s.a_end, INTERVAL 7 DAY) AND DATE_SUB(s.a_end, INTERVAL 1 DAY)
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, x.sticker_id ORDER BY x.sticker_collected_min_ts) = 1
),
tot AS (SELECT COUNT(*) AS n_users, SUM(rev_alb) AS rev_alb, (SELECT SUM(rev_last7) FROM end_rev) AS rev_last7, (SELECT COUNT(*) FROM st7) AS stickers7 FROM strong)
SELECT st7.src, st7.camp, st7.joker, COUNT(*) AS stickers, COUNT(DISTINCT st7.user_id) AS users,
  ROUND(100 * COUNT(*) / ANY_VALUE(tot.stickers7), 1) AS pct_stickers,
  ANY_VALUE(tot.n_users) AS group_users, ROUND(ANY_VALUE(tot.rev_alb)) AS group_rev_album, ROUND(ANY_VALUE(tot.rev_last7)) AS group_rev_last7
FROM st7 CROSS JOIN tot
GROUP BY 1,2,3 ORDER BY stickers DESC LIMIT 30
