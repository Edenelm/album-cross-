# Domino — easy vs hard gate vs the ≤3 target (DomGate, run 2026-10-15)

Eden: show Domino against the ≤3-missing target even for easy, to show that with a 5-sticker gate (easy = 2 Royals + 3 Goldens; hard = 2 Royals + 1 Golden) the target is out of reach and revenue gets stuck.
Project domino-dreams-dbt, prod_40_mart.user_daily_album, albums 19/20, 11.9 GB. Population: not special, not cheater, user_album_count > 1, login ratio last row >= 0.5, close day excluded. Segment = album_segment on first row (19: def_album14_easy/hard; 20: def_album15_easy/hard). Revenue share = revenue album start -> measurement day. "Only gate" = missing exactly 2 Royals and the rest Goldens.

## Revenue share by state (album 19 / album 20)
| Segment | Checkpoint | <=3 missing (incl. finished) | 4-5 missing | 6+ | Of 4-5: missing only 2R+G |
|---|---|---|---|---|---|
| Easy | close-4 | 5% / 45% | 46% / 28% | 49% / 27% | 88% / 66% |
| Hard | close-4 | 58% / 66% | 19% / 20% | 23% / 13% | 69% / 66% |
| Easy | close-1 | 32% / 72% | 34% / 13% | 34% / 15% | 71% / 40% |
| Hard | close-1 | 72% / 86% | 11% / 6% | 16% / 8% | 60% / 48% |
Easy 4-5 at close-4: 46K players / 26K payers (19); 47K / 22K (20). Missing mix of easy 4-5 at close-4, album 19: 1.9 Royals + 2.8 Goldens = the whole 5-sticker gate.
Easy at <=3 at close-4, album 20: missing 1.9 Royals + 0.8 Goldens = looks like the HARD gate (2R+1G).

## Reading
- Known (album 19): the easy target of <=3 at close-4 was out of reach — 5% of easy revenue; 46% of easy revenue sat at 4-5 missing, 88% of them missing exactly the 5 gate stickers (2R+3G). Hard: 58% reached.
- Known (album 20): easy did NOT behave like a 5-sticker gate — 45% reached <=3 at close-4, and those players were missing ~2 Royals + ~1 Golden (= hard gate). Either the easy gate in album 20 was 2R+1G, or 2 of the 3 gate Goldens were released earlier for easy. Needs Validation with the Domino team.
- Albums differ a lot -> show separately, not averaged.
- Implication: the <=3 target is valid for easy only when the easy gate is 3 stickers at the checkpoint. Album 19 is the clean example of revenue stuck behind the gate (~46% of easy revenue at close-4; easy ~half of album revenue -> roughly a quarter of album revenue, approximate).
- Not causal.

## SQL (DomGate, run 2026-10-15, 11.9 GB, domino-dreams-dbt)
```sql
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c, a.login_ratio, a.user_album_count, a.album_segment,
    IFNULL(a.album_spent_today, 0) AS sp,
    144 - (IFNULL(a.unique_common_stickers_lt, 0) + IFNULL(a.unique_golden_stickers_lt, 0) + IFNULL(a.unique_royal_stickers_tl, 0)) AS miss,
    IFNULL(a.missing_royal_stickers_today, 0) AS mr, IFNULL(a.missing_golden_stickers_today, 0) AS mg
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND a.album_id IN (19, 20)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
u AS (
  SELECT album_id, user_id,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l,
    ARRAY_AGG(album_segment IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg,
    SUM(IF(date_dim <= DATE_SUB(c, INTERVAL 4 DAY), sp, 0)) AS rev_c4,
    SUM(sp) AS rev_end,
    ARRAY_AGG(IF(date_dim <= DATE_SUB(c, INTERVAL 4 DAY), STRUCT(miss, mr, mg), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS s4,
    ARRAY_AGG(STRUCT(miss, mr, mg) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS se
  FROM r GROUP BY 1, 2),
f AS (
  SELECT album_id, IFNULL(seg, '(null)') AS seg, rev_c4, rev_end, s4, se
  FROM u WHERE l.lr >= 0.5 AND l.uac > 1),
x AS (
  SELECT album_id, seg, 'a close-4' AS k, rev_c4 AS rev, s4.miss AS miss, s4.mr AS mr, s4.mg AS mg FROM f WHERE s4 IS NOT NULL
  UNION ALL
  SELECT album_id, seg, 'b close-1', rev_end, se.miss, se.mr, se.mg FROM f),
y AS (
  SELECT album_id, seg, k, rev, mr, mg, miss,
    CASE WHEN miss <= 0 THEN '0 finished' WHEN miss <= 3 THEN '1-3' WHEN miss <= 5 THEN '4-5' ELSE '6+' END AS st,
    (mr = 2 AND mr + mg = miss) AS only_gate
  FROM x)
SELECT album_id, seg, k, st, COUNT(*) AS players, COUNTIF(rev > 0) AS payers,
  ROUND(SUM(rev) / SUM(SUM(rev)) OVER (PARTITION BY album_id, seg, k), 3) AS rev_share,
  ROUND(COUNTIF(only_gate) / COUNT(*), 3) AS share_missing_only_2R_plus_G,
  ROUND(AVG(mr), 2) AS avg_missing_royal, ROUND(AVG(mg), 2) AS avg_missing_golden
FROM y GROUP BY 1, 2, 3, 4 ORDER BY 1, 2, 3, 4
```
Revenue definition (Eden asked 2026-10-15): album_spent_today summed per player from album open through the checkpoint day (inclusive); all of a player's revenue is assigned to his state at the end of that day; share = state revenue / segment revenue. It is total game spend on album days, not album-only purchases.

