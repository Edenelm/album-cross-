-- 2026-10-27: Domino 20, Easy payers: stickers missing at close, weighted by where the money is (Eden).
-- Same population and sticker rules as median_missing_at_close_2026-10-25.sql (Domino part) + segment (album_segment on first row) + album revenue (start..close-1).
-- Output per total missing (cap 15+): payers, % of Easy payers, % of Easy album revenue, % of all-payer album revenue, avg missing by type.
-- Revenue-weighted median = the missing count where cumulative Easy revenue (sorted by missing, ascending) passes 50%.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, album_segment AS seg
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', IF(LOWER(seg) LIKE '%hard%', 'hard', 'other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_end, alb_rev, seg0 FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND rev_c > 0 AND user_id NOT IN (SELECT user_id FROM bad_users)),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, ANY_VALUE(LOWER(s.sticker_type)) AS typ
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id = 20
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
tsize AS (SELECT album_id, typ, COUNT(DISTINCT sticker_id) AS n_typ FROM r GROUP BY 1,2),
held AS (SELECT album_id, user_id, typ, COUNT(*) AS h FROM r GROUP BY 1,2,3),
miss AS (
  SELECT p.user_id, p.seg0, p.alb_rev, t.typ, t.n_typ - IFNULL(h.h, 0) AS m
  FROM pop p JOIN tsize t USING (album_id) LEFT JOIN held h ON h.album_id = p.album_id AND h.user_id = p.user_id AND h.typ = t.typ
),
pl AS (
  SELECT user_id, ANY_VALUE(seg0) AS seg0, ANY_VALUE(alb_rev) AS alb_rev, SUM(m) AS t,
    SUM(IF(typ='common', m, 0)) AS mc, SUM(IF(typ='golden', m, 0)) AS mg, SUM(IF(typ='royal', m, 0)) AS mr
  FROM miss GROUP BY 1
),
tot AS (SELECT SUM(alb_rev) AS rev_all, SUM(IF(seg0='easy', alb_rev, 0)) AS rev_easy, COUNTIF(seg0='easy') AS n_easy FROM pl),
g AS (
  SELECT LEAST(t, 15) AS missing, COUNT(*) AS payers, SUM(alb_rev) AS rev,
    ROUND(AVG(mc),2) AS avg_common, ROUND(AVG(mg),2) AS avg_golden, ROUND(AVG(mr),2) AS avg_royal
  FROM pl WHERE seg0 = 'easy' GROUP BY 1
)
SELECT g.missing, g.payers, ROUND(100*g.payers/tot.n_easy,1) AS pct_easy_payers,
  ROUND(100*g.rev/tot.rev_easy,1) AS pct_easy_rev, ROUND(100*g.rev/tot.rev_all,1) AS pct_all_album_rev,
  ROUND(100*SUM(g.rev) OVER (ORDER BY g.missing)/tot.rev_easy,1) AS cum_pct_easy_rev,
  ROUND(g.rev/g.payers,1) AS rev_per_payer, g.avg_common, g.avg_golden, g.avg_royal
FROM g CROSS JOIN tot ORDER BY g.missing
