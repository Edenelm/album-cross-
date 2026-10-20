-- DRAFT 2026-10-18: Domino 19 vs 20 — (a) finisher mix by player strength, (b) finishers who closed with two puzzle stickers.
-- Strength = $ per active day in the PREVIOUS album (prev by open date; 18 for 19, 19 for 20). $ = album_spent_today (album table), active days = sessions_today > 0 (metrics).
-- Groups as in finisher_targets: g0 (0 / no data), <=2, 2-5, 5-20, >20 $/day.
-- Population = eligible players on last full day (not first album, login ratio >= 0.5, exclusions). Finisher = 144.
-- Revenue = album_spent_today over the album days. Last two new stickers: int_user_album_stickers (same logic as before).
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
g AS (
  SELECT album_id, grp, COUNT(*) AS eligible, COUNTIF(fin) AS finishers, COUNTIF(fin AND rev_alb > 0) AS fin_payers,
    SUM(IF(fin, rev_alb, 0)) AS fin_rev, COUNTIF(fin AND both_puzzle) AS fin_last2_puzzle,
    COUNTIF(fin AND both_puzzle AND rev_alb > 0) AS fin_last2_puzzle_payers, SUM(IF(fin AND both_puzzle, rev_alb, 0)) AS fin_last2_puzzle_rev
  FROM d GROUP BY 1,2
  UNION ALL
  SELECT album_id, 'all', COUNT(*), COUNTIF(fin), COUNTIF(fin AND rev_alb > 0), SUM(IF(fin, rev_alb, 0)),
    COUNTIF(fin AND both_puzzle), COUNTIF(fin AND both_puzzle AND rev_alb > 0), SUM(IF(fin AND both_puzzle, rev_alb, 0))
  FROM d GROUP BY 1
)
SELECT album_id, grp, eligible, finishers,
  ROUND(100 * finishers / eligible, 1) AS fin_rate,
  ROUND(100 * finishers / SUM(IF(grp = 'all', finishers, 0)) OVER (PARTITION BY album_id), 1) AS pct_of_finishers,
  ROUND(100 * fin_payers / NULLIF(finishers, 0), 1) AS pct_payers_fin,
  ROUND(fin_rev) AS fin_rev, ROUND(fin_rev / NULLIF(finishers, 0), 2) AS rev_per_finisher,
  fin_last2_puzzle, fin_last2_puzzle_payers, ROUND(fin_last2_puzzle_rev) AS fin_last2_puzzle_rev
FROM g ORDER BY album_id, grp
