-- 2026-10-28 (Eden): what brought Domino 20 payers closer before the last 10 days? Days 20..11 before close, albums 19 vs 20.
-- Standard-population payers. Per day: new set stickers (first copy, not jokers) per active payer, split by source category.
-- Categories: joker (source/campaign mentions Joker), kiosk, coloring, paid (t_Offer/t_Store/purchase/1+N), trail, steady (area/level/pet), events (rest).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end, DATE_DIFF(date_dim, album_close_date, DAY) AS d, IFNULL(active_flag,FALSE) AS act,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (SELECT album_id, user_id, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(d < 0, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l, MAX(IF(d < 0, d, NULL)) AS last_d
  FROM ud GROUP BY 1,2),
pop AS (SELECT album_id, user_id FROM u WHERE last_d = -1 AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0 AND user_id NOT IN (SELECT user_id FROM bad)),
act AS (SELECT ud.album_id, ud.d, COUNT(*) AS n FROM ud JOIN pop USING (album_id, user_id) WHERE ud.act AND ud.d BETWEEN -20 AND -11 GROUP BY 1,2),
cl AS (SELECT album_id, MAX(a_end) AS a_end FROM ud GROUP BY 1),
st AS (
  SELECT s.album_id, DATE_DIFF(s.sticker_collected_min_date, c.a_end, DAY) AS d, IFNULL(s.new_sticker_mtx_campaign_name,'') AS camp, LOWER(IFNULL(s.new_sticker_source,'')) AS src
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id) JOIN cl c USING (album_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (19,20) AND s.user_collected_sticker_flag
    AND LOWER(s.sticker_type) NOT LIKE '%joker%'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
x AS (SELECT album_id, d,
  CASE WHEN src LIKE '%joker%' OR LOWER(camp) LIKE '%joker%' THEN 'joker'
       WHEN camp LIKE 'GoldenKiosk%' OR src = 'kiosk' THEN 'kiosk'
       WHEN src LIKE '%coloring%' THEN 'coloring'
       WHEN (camp LIKE '%t_Offer%' AND NOT REGEXP_CONTAINS(camp, r'SeasonPass|DreamPass|Info|ecn_Rewa')) OR camp LIKE '%t_Store%' OR src = 'purchase' OR src LIKE '1+%' THEN 'paid'
       WHEN src LIKE '%trail%' THEN 'trail'
       WHEN src IN ('area completed','level end','pet tier') THEN 'steady'
       ELSE 'events' END AS cat
  FROM st WHERE d BETWEEN -20 AND -11),
agg AS (SELECT album_id, d, cat, COUNT(*) AS k FROM x GROUP BY 1,2,3)
SELECT g.album_id, g.d, ANY_VALUE(a.n) AS active_payers, ROUND(SUM(g.k) / ANY_VALUE(a.n), 2) AS new_per_payer,
  STRING_AGG(FORMAT('%s:%.2f', g.cat, g.k / a.n), ' ' ORDER BY g.k DESC) AS by_cat
FROM agg g JOIN act a USING (album_id, d) GROUP BY 1,2 ORDER BY 1,2;
