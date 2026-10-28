-- 2026-10-28 (Eden): albums 17-20, standard-population payers: how many were near FU (141+ of 144 set stickers) at the end of close-4,
-- and their share of album revenue. Set sticker = any type except joker; held = first receipt <= close-4.
-- Album revenue = album-table spend from open to close-1 (register). Tests Eden's hypothesis: 18+20 (end lift) had more payers near FU than 17+19.
-- v2 (used): FU threshold = each album's own total minus 3 (album 18 has 168 set stickers: 127 common, 31 golden, 10 royal). v1 assumed 144 and was wrong for 18.
-- Query below is the v2 that was run.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND album_id IN (17,18,19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c, SUM(IF(date_dim < a_end, spend, 0)) AS rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_end, rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)),
s0 AS (
  SELECT s.album_id, s.user_id, s.sticker_id, s.sticker_collected_min_date AS d
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-01' AND DATE '2026-10-12' AND s.album_id IN (17,18,19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) NOT LIKE '%joker%' AND s.sticker_collected_min_date <= p.a_end
),
tot AS (SELECT album_id, COUNT(DISTINCT sticker_id) AS n_tot FROM s0 GROUP BY 1),
st AS (SELECT s0.album_id, s0.user_id, COUNT(DISTINCT s0.sticker_id) AS held FROM s0 JOIN pop p USING (album_id, user_id)
       WHERE s0.d <= DATE_SUB(p.a_end, INTERVAL 4 DAY) GROUP BY 1,2),
x AS (SELECT p.album_id, p.rev, t.n_tot - IFNULL(st.held,0) AS miss FROM pop p JOIN tot t USING (album_id) LEFT JOIN st USING (album_id, user_id))
SELECT album_id, ANY_VALUE(t.n_tot) AS n_tot, COUNT(*) AS payers,
  COUNTIF(miss BETWEEN 1 AND 3) AS fu_not_done, ROUND(100*COUNTIF(miss BETWEEN 1 AND 3)/COUNT(*),1) AS pct_payers,
  ROUND(100*SUM(IF(miss BETWEEN 1 AND 3, rev, 0))/SUM(rev),1) AS pct_rev,
  COUNTIF(miss = 0) AS done_c4, ROUND(100*COUNTIF(miss <= 3)/COUNT(*),1) AS pct_payers_0_3, ROUND(100*SUM(IF(miss <= 3, rev, 0))/SUM(rev),1) AS pct_rev_0_3
FROM x JOIN tot t USING (album_id) GROUP BY 1 ORDER BY 1;
