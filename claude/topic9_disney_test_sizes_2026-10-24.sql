-- Eden 2026-10-24 ("תריץ את 1"): sizes for two Disney test populations on the topic-9 test slides (tx_gate, tx_gold).
-- Albums Disney 14 / 15 (solitaire-dreams-411507). Population = standard population payers (same as disney_stalls_missing_2026-10-23.sql):
-- not first album, not excluded (special_user_flag / exclude_reason), login ratio >= 0.5 on the last row before close, row on close-1, paid on any album day incl. close.
-- Album revenue = album_spent_today from album start to close-1. Shares = % of these payers / % of their album revenue.
-- (a) tx_gate: payers who end 1-3 short = 141-143 unique set stickers (common + golden + royal) by the end of the close day; finishers = 144.
-- (b) tx_gold: payers missing >= 1 Golden at the end of close-10. Run 1 used all 24 Goldens -> 100% of payers (2 Goldens are locked to the end), not useful.
--     Run 2 (below): missing >= 1 Golden that was already out at close-10 = held by >= 1% of these payers by the end of close-10 (my threshold, to drop not-yet-released ones).
-- Results: claude/topic9-disney-test-sizes-2026-10-24.md
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS spend_all, SUM(IF(date_dim < a_end, spend, 0)) AS rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_end, rev FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND spend_all > 0 AND user_id NOT IN (SELECT user_id FROM bad_users)),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, ANY_VALUE(LOWER(s.sticker_type)) AS typ, MIN(s.sticker_collected_min_date) AS d
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (14,15)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
npay AS (SELECT album_id, COUNT(*) AS n FROM pop GROUP BY 1),
gavail AS (
  SELECT r.album_id, r.sticker_id FROM r JOIN pop p USING (album_id, user_id) JOIN npay USING (album_id)
  WHERE r.typ = 'golden' AND r.d <= DATE_SUB(p.a_end, INTERVAL 10 DAY)
  GROUP BY 1, 2 HAVING COUNT(*) >= 0.01 * ANY_VALUE(npay.n)
),
ngold AS (SELECT album_id, COUNT(*) AS n_gold FROM gavail GROUP BY 1),
per AS (
  SELECT p.album_id, p.user_id, p.rev,
    COUNT(r.sticker_id) AS uniq_close,
    COUNTIF(ga.sticker_id IS NOT NULL AND r.d <= DATE_SUB(p.a_end, INTERVAL 10 DAY)) AS gold_c10
  FROM pop p LEFT JOIN r USING (album_id, user_id) LEFT JOIN gavail ga ON ga.album_id = r.album_id AND ga.sticker_id = r.sticker_id
  GROUP BY 1,2,3
),
lab AS (
  SELECT per.*, CASE WHEN uniq_close >= 144 THEN 'finished' WHEN uniq_close >= 141 THEN '1-3 short' ELSE '4+ short' END AS end_status,
    gold_c10 < g.n_gold AS miss_gold_c10, g.n_gold
  FROM per JOIN ngold g USING (album_id)
)
SELECT album_id, grp, players, ROUND(100 * players / SUM(IF(grp = 'all payers', players, 0)) OVER (PARTITION BY album_id), 1) AS pct_payers,
  ROUND(100 * rev / SUM(IF(grp = 'all payers', rev, 0)) OVER (PARTITION BY album_id), 1) AS pct_album_rev, ROUND(rev) AS album_rev, finish_rate, n_gold
FROM (
  SELECT album_id, 'all payers' AS grp, COUNT(*) AS players, SUM(rev) AS rev, ROUND(100 * AVG(IF(end_status = 'finished', 1, 0)), 1) AS finish_rate, ANY_VALUE(n_gold) AS n_gold FROM lab GROUP BY 1
  UNION ALL
  SELECT album_id, CONCAT('end ', end_status), COUNT(*), SUM(rev), NULL, ANY_VALUE(n_gold) FROM lab GROUP BY 1, 2
  UNION ALL
  SELECT album_id, 'missing a released Golden at close-10', COUNT(*), SUM(rev), ROUND(100 * AVG(IF(end_status = 'finished', 1, 0)), 1), ANY_VALUE(n_gold) FROM lab WHERE miss_gold_c10 GROUP BY 1
  UNION ALL
  SELECT album_id, CONCAT('missing released Goldens at close-10: ', IF(n_gold - gold_c10 >= 4, '4+', CAST(n_gold - gold_c10 AS STRING))), COUNT(*), SUM(rev),
    ROUND(100 * AVG(IF(end_status = 'finished', 1, 0)), 1), ANY_VALUE(n_gold) FROM lab WHERE miss_gold_c10 GROUP BY 1, 2
)
ORDER BY album_id, grp;
