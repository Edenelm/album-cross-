# Middle payers — where the money ending far sits (Disney / Domino / Dice) — 2026-10-15

Follow-up to claude/weak-stall-supply-demand-2026-10-15.md (same definitions). Eden asked whether the stall findings can make money; check 1 = middle payer groups.

## Middle payers (MidDis 20.4 GB / MidDom 10.1 GB / MidDice 6.0 GB, 2026-10-15)
Same queries as StallTypeDis/StallTypeDom/StallDice with groups P50–80 and P80–95 of spend so far (among payers). Shown and approved in chat. Revenue-weighted, average of the two albums. Gate = Royal (Disney/Domino), Super (Dice).

| Game | Group | End | Last new common | Last new Golden | Last new gate sticker | Rares frozen before last quarter | Days with no new rare | Active after rare freeze | Revenue after rare freeze |
|---|---|---|---|---|---|---|---|---|---|
| Disney | P50–80 | 4+ | 83% | 86% | 73% | 8% | 4.3 | 73% | 3.1% |
| Disney | P50–80 | 1–3 | 79% | 87% | 83% | 5% | 3.5 | 94% | 6.8% |
| Disney | P80–95 | 4+ | 79% | 82% | 72% | 15% | 5.4 | 70% | 3.6% |
| Disney | P80–95 | 1–3 | 76% | 86% | 79% | 8% | 3.9 | 93% | 6.7% |
| Domino | P50–80 | 4+ | 77% | 89% | 79% | 9% | 4.3 | 55% | 2.0% |
| Domino | P50–80 | 1–3 | 73% | 94% | 87% | 0% | 1.7 | 93% | 3.1% |
| Domino | P80–95 | 4+ | 74% | 87% | 76% | 13% | 5.3 | 51% | 2.1% |
| Domino | P80–95 | 1–3 | 72% | 93% | 85% | 0% | 2.1 | 93% | 3.0% |
| Dice | P50–80 | 4+ | 83% | 88% | 86% | 5% | 2.4 | 51% | 0.9% |
| Dice | P50–80 | 1–3 | 79% | 88% | 92% | 0% | 1.9 | 93% | 2.3% |
| Dice | P80–95 | 4+ | 81% | 87% | 85% | 8% | 2.8 | 50% | 1.0% |
| Dice | P80–95 | 1–3 | 77% | 87% | 91% | 1% | 2.0 | 93% | 2.5% |

Album differences: Disney "rares frozen before commons" for 4+ 9% (14) vs 23–26% (15); Domino P50–80 4+ active 62% (19) vs 48% (20).

### Where the money sits — share of ALBUM revenue held by players who end at 4+ missing
(group share of album revenue × group's 4+ share, from RelDis/RelDom/RelDice; averages of two albums)
| Game | Weak P0–50 | P50–80 | P80–95 | Strong P95+ | Total at 4+ |
|---|---|---|---|---|---|
| Disney | 5% | 13% | 15% | 10% | ~43% |
| Domino | 4% | 10% | 12% | 9% | ~35% |
| Dice | 2.5% | 6.5% | 8.5% | 7% | ~24% |

Reading:
- Known: the largest pool of revenue ending far is the MIDDLE (P50–95): Disney ~28%, Domino ~22%, Dice ~15% of album revenue. Weak players are only 2.5–5%.
- Known: the Royal pattern repeats in every paying group in Disney/Domino — players who end at 4+ get their last new Royal at ~72–79% of the album (~10–11 days before close) vs 79–87% for those ending at 1–3. In Dice the last new Super comes at ~85–86% (~5–6 days before close).
- Known: middle players who end far in Disney stay ~70% active after their rares freeze but spend almost nothing (3–4% of their revenue) — still playing, not progressing, not paying. Domino/Dice ~50% active.
- Hypothesis (money): the Disney/Domino vs Dice gap (~13 / ~11 pts of album revenue sitting at 4+) is concentrated in middle payers and coincides with a ~10-day Royal gap in the last quarter. If Royal arrival for active middle players can be moved later / made available (offer or free source), some of that could convert. Needs: (1) free vs paid Royal sources in the last quarter (is it supply or not buying?), (2) A/B.

## SQL

```sql
-- MidDis (2026-10-15) Disney 14/15: same as StallTypeDis, groups = P50-80 / P80-95 (middle payers). Stall day per type + activity/spend after rare stall.
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d,
    DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend, IFNULL(a.active_flag, FALSE) AS act,
    IFNULL(a.unique_common_stickers_lt, 0) AS uc, IFNULL(a.unique_golden_stickers_lt, 0) AS ug, IFNULL(a.unique_royal_stickers_tl, 0) AS ur
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND a.album_id IN (14, 15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
r1 AS (
  SELECT album_id, user_id, date_dim, d, n, login_ratio, user_album_count, spend, act, uc, ug, ur,
    MAX(uc) OVER w AS uc_end, MAX(ug) OVER w AS ug_end, MAX(ur) OVER w AS ur_end
  FROM r0 WINDOW w AS (PARTITION BY album_id, user_id)),
r2 AS (
  SELECT album_id, user_id, date_dim, d, n, login_ratio, user_album_count, spend, act, uc_end, ug_end, ur_end,
    MIN(IF(uc = uc_end, d, NULL)) OVER w AS c_st, MIN(IF(ug = ug_end, d, NULL)) OVER w AS g_st, MIN(IF(ur = ur_end, d, NULL)) OVER w AS r_st
  FROM r1 WINDOW w AS (PARTITION BY album_id, user_id)),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, CAST(CEIL(0.75 * ANY_VALUE(n)) AS INT64) AS cp, SUM(spend) AS total, MIN(d) AS first_d,
    SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far,
    144 - (ANY_VALUE(uc_end) + ANY_VALUE(ug_end) + ANY_VALUE(ur_end)) AS m_end,
    ANY_VALUE(c_st) AS c_st, ANY_VALUE(g_st) AS g_st, ANY_VALUE(r_st) AS r_st,
    SUM(IF(d > GREATEST(g_st, r_st), spend, 0)) AS spend_after_rare, COUNTIF(d > GREATEST(g_st, r_st) AND act) AS act_after_rare,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row
  FROM r2 GROUP BY 1, 2),
tgt AS (
  SELECT album_id, n, total, so_far, m_end, c_st, g_st, r_st, GREATEST(g_st, r_st) AS rare_st, spend_after_rare, act_after_rare,
    (n - 1) - GREATEST(g_st, r_st) AS rare_days_after
  FROM ua WHERE last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1 AND first_d <= cp - 1),
p AS (
  SELECT album_id, n, total, so_far, m_end, c_st, g_st, r_st, rare_st, spend_after_rare, act_after_rare, rare_days_after,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM tgt),
f AS (
  SELECT album_id, n, total, m_end, c_st, g_st, r_st, rare_st, spend_after_rare, act_after_rare, rare_days_after,
    CASE WHEN pr >= 0.5 AND pr < 0.8 THEN 'P50-80' WHEN pr >= 0.8 AND pr < 0.95 THEN 'P80-95' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0)
SELECT album_id, grp, st, COUNT(*) AS players, ROUND(SUM(total)) AS rev,
  ROUND(SUM(total * c_st / n) / SUM(total), 3) AS rev_w_common_stall_pct,
  ROUND(SUM(total * g_st / n) / SUM(total), 3) AS rev_w_golden_stall_pct,
  ROUND(SUM(total * r_st / n) / SUM(total), 3) AS rev_w_royal_stall_pct,
  ROUND(SUM(IF(rare_st / n < 0.75, total, 0)) / SUM(total), 3) AS rev_rare_stuck_before_q4,
  ROUND(SUM(IF(rare_st < c_st, total, 0)) / SUM(total), 3) AS rev_rare_stuck_before_commons,
  ROUND(SUM(total * rare_days_after) / SUM(total), 1) AS rev_w_rare_days_stuck,
  ROUND(SAFE_DIVIDE(SUM(act_after_rare), SUM(rare_days_after)), 3) AS active_rate_after_rare_stall,
  ROUND(SUM(spend_after_rare) / SUM(total), 3) AS share_rev_after_rare_stall
FROM f WHERE grp IS NOT NULL GROUP BY 1,2,3 ORDER BY 1,2,3
```

```sql
-- MidDom (2026-10-15) Domino 19/20: same as StallTypeDom, groups = P50-80 / P80-95 (middle payers). Stall day per type + activity/spend after rare stall.
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d,
    DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend, IFNULL(a.active_flag, FALSE) AS act,
    IFNULL(a.unique_common_stickers_lt, 0) AS uc, IFNULL(a.unique_golden_stickers_lt, 0) AS ug, IFNULL(a.unique_royal_stickers_tl, 0) AS ur
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND a.album_id IN (19, 20)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
r1 AS (
  SELECT album_id, user_id, date_dim, d, n, login_ratio, user_album_count, spend, act, uc, ug, ur,
    MAX(uc) OVER w AS uc_end, MAX(ug) OVER w AS ug_end, MAX(ur) OVER w AS ur_end
  FROM r0 WINDOW w AS (PARTITION BY album_id, user_id)),
r2 AS (
  SELECT album_id, user_id, date_dim, d, n, login_ratio, user_album_count, spend, act, uc_end, ug_end, ur_end,
    MIN(IF(uc = uc_end, d, NULL)) OVER w AS c_st, MIN(IF(ug = ug_end, d, NULL)) OVER w AS g_st, MIN(IF(ur = ur_end, d, NULL)) OVER w AS r_st
  FROM r1 WINDOW w AS (PARTITION BY album_id, user_id)),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, CAST(CEIL(0.75 * ANY_VALUE(n)) AS INT64) AS cp, SUM(spend) AS total, MIN(d) AS first_d,
    SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far,
    144 - (ANY_VALUE(uc_end) + ANY_VALUE(ug_end) + ANY_VALUE(ur_end)) AS m_end,
    ANY_VALUE(c_st) AS c_st, ANY_VALUE(g_st) AS g_st, ANY_VALUE(r_st) AS r_st,
    SUM(IF(d > GREATEST(g_st, r_st), spend, 0)) AS spend_after_rare, COUNTIF(d > GREATEST(g_st, r_st) AND act) AS act_after_rare,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row
  FROM r2 GROUP BY 1, 2),
tgt AS (
  SELECT album_id, n, total, so_far, m_end, c_st, g_st, r_st, GREATEST(g_st, r_st) AS rare_st, spend_after_rare, act_after_rare,
    (n - 1) - GREATEST(g_st, r_st) AS rare_days_after
  FROM ua WHERE last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1 AND first_d <= cp - 1),
p AS (
  SELECT album_id, n, total, so_far, m_end, c_st, g_st, r_st, rare_st, spend_after_rare, act_after_rare, rare_days_after,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM tgt),
f AS (
  SELECT album_id, n, total, m_end, c_st, g_st, r_st, rare_st, spend_after_rare, act_after_rare, rare_days_after,
    CASE WHEN pr >= 0.5 AND pr < 0.8 THEN 'P50-80' WHEN pr >= 0.8 AND pr < 0.95 THEN 'P80-95' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0)
SELECT album_id, grp, st, COUNT(*) AS players, ROUND(SUM(total)) AS rev,
  ROUND(SUM(total * c_st / n) / SUM(total), 3) AS rev_w_common_stall_pct,
  ROUND(SUM(total * g_st / n) / SUM(total), 3) AS rev_w_golden_stall_pct,
  ROUND(SUM(total * r_st / n) / SUM(total), 3) AS rev_w_royal_stall_pct,
  ROUND(SUM(IF(rare_st / n < 0.75, total, 0)) / SUM(total), 3) AS rev_rare_stuck_before_q4,
  ROUND(SUM(IF(rare_st < c_st, total, 0)) / SUM(total), 3) AS rev_rare_stuck_before_commons,
  ROUND(SUM(total * rare_days_after) / SUM(total), 1) AS rev_w_rare_days_stuck,
  ROUND(SAFE_DIVIDE(SUM(act_after_rare), SUM(rare_days_after)), 3) AS active_rate_after_rare_stall,
  ROUND(SUM(spend_after_rare) / SUM(total), 3) AS share_rev_after_rare_stall
FROM f WHERE grp IS NOT NULL GROUP BY 1,2,3 ORDER BY 1,2,3
```

```sql
-- MidDice (2026-10-15) Dice 61/63: same as StallDice, groups = P50-80 / P80-95 (middle payers).
-- stall = first day reaching final count: total / commons / Goldens / Supers. Rare stall = later of Golden / Super. After stall: is_active days and spend.
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end, 35 AS n UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07', 42),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.n, CAST(CEIL(0.75 * alb.n) AS INT64) AS cp,
    DATE_DIFF(a.date_dim, alb.a_start, DAY) AS d,
    a.album_login_ratio AS lr, a.user_past_album_count AS past,
    IFNULL(a.spent_in_album_today, 0) AS spend, IFNULL(a.is_active, FALSE) AS act,
    IFNULL(a.unique_stickers_lt, 0) AS ua_, IFNULL(a.unique_common_stickers_lt, 0) AS uc,
    IFNULL(a.unique_golden_stickers_lt, 0) AS ug, IFNULL(a.unique_super_stickers_lt, 0) AS us
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
r1 AS (
  SELECT album_id, user_id, date_dim, n, cp, d, lr, past, spend, act, ua_, uc, ug, us,
    MAX(ua_) OVER w AS ua_end, MAX(uc) OVER w AS uc_end, MAX(ug) OVER w AS ug_end, MAX(us) OVER w AS us_end
  FROM r0 WINDOW w AS (PARTITION BY album_id, user_id)),
r2 AS (
  SELECT album_id, user_id, date_dim, n, cp, d, lr, past, spend, act, ua_end, uc_end, ug_end, us_end,
    MIN(IF(ua_ = ua_end, d, NULL)) OVER w AS t_st, MIN(IF(uc = uc_end, d, NULL)) OVER w AS c_st,
    MIN(IF(ug = ug_end, d, NULL)) OVER w AS g_st, MIN(IF(us = us_end, d, NULL)) OVER w AS s_st
  FROM r1 WINDOW w AS (PARTITION BY album_id, user_id)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, ANY_VALUE(cp) AS cpv, SUM(spend) AS total, SUM(IF(d <= cp - 1, spend, 0)) AS so_far,
    144 - ANY_VALUE(ua_end) AS m_end, 12 - ANY_VALUE(us_end) AS miss_super,
    ANY_VALUE(t_st) AS t_st, ANY_VALUE(c_st) AS c_st, ANY_VALUE(g_st) AS g_st, ANY_VALUE(s_st) AS s_st,
    SUM(IF(d > t_st, spend, 0)) AS spend_after, COUNTIF(d > t_st AND act) AS act_after,
    SUM(IF(d > GREATEST(g_st, s_st), spend, 0)) AS spend_after_rare, COUNTIF(d > GREATEST(g_st, s_st) AND act) AS act_after_rare
  FROM r2 GROUP BY 1, 2
  HAVING MIN(past) > 0 AND MIN(d) <= ANY_VALUE(cp) - 1
     AND ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
p AS (
  SELECT album_id, n, total, so_far, m_end, miss_super, t_st, c_st, g_st, s_st, GREATEST(g_st, s_st) AS rare_st,
    spend_after, act_after, spend_after_rare, act_after_rare,
    (n - 1) - t_st AS days_after, (n - 1) - GREATEST(g_st, s_st) AS rare_days_after,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM u),
f AS (
  SELECT album_id, n, total, m_end, miss_super, t_st, c_st, g_st, s_st, rare_st, spend_after, act_after, spend_after_rare, act_after_rare,
    days_after, rare_days_after,
    CASE WHEN pr >= 0.5 AND pr < 0.8 THEN 'P50-80' WHEN pr >= 0.8 AND pr < 0.95 THEN 'P80-95' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0)
SELECT album_id, grp, st, COUNT(*) AS players, ROUND(SUM(total)) AS rev,
  ROUND(SUM(IF(t_st / n >= 0.9, total, 0)) / SUM(total), 3) AS rev_stall_last_10pct,
  ROUND(SUM(IF(t_st / n >= 0.75 AND t_st / n < 0.9, total, 0)) / SUM(total), 3) AS rev_stall_75_90,
  ROUND(SUM(total * days_after) / SUM(total), 1) AS rev_w_days_stuck,
  ROUND(SAFE_DIVIDE(SUM(act_after), SUM(days_after)), 3) AS active_rate_after_stall,
  ROUND(SUM(spend_after) / SUM(total), 3) AS share_rev_after_stall,
  ROUND(SUM(total * c_st / n) / SUM(total), 3) AS rev_w_common_stall_pct,
  ROUND(SUM(total * g_st / n) / SUM(total), 3) AS rev_w_golden_stall_pct,
  ROUND(SUM(total * s_st / n) / SUM(total), 3) AS rev_w_super_stall_pct,
  ROUND(SUM(IF(rare_st / n < 0.75, total, 0)) / SUM(total), 3) AS rev_rare_stuck_before_q4,
  ROUND(SUM(IF(rare_st < c_st, total, 0)) / SUM(total), 3) AS rev_rare_stuck_before_commons,
  ROUND(SUM(total * rare_days_after) / SUM(total), 1) AS rev_w_rare_days_stuck,
  ROUND(SAFE_DIVIDE(SUM(act_after_rare), SUM(rare_days_after)), 3) AS active_rate_after_rare_stall,
  ROUND(SUM(spend_after_rare) / SUM(total), 3) AS share_rev_after_rare_stall,
  ROUND(SUM(total * miss_super) / SUM(total), 2) AS rev_w_missing_super,
  ROUND(SUM(total * m_end) / SUM(total), 2) AS rev_w_missing_total
FROM f WHERE grp IS NOT NULL GROUP BY 1,2,3 ORDER BY 1,2,3
```

## Wild (joker) timing — Eden, 2026-10-15
- [Eden] Wild is sold from ~7 days before close in Dice and Domino; in Disney only ~3–4 days before close.
- Combined with the stall data (Hypothesis): a "dead zone" with no new Royal and no Wild yet —
  - Disney: last new Royal ~11 days before close → Wild at 3–4 → ~7 days with nothing that moves the gate.
  - Domino: last new Royal ~10 days before close → Wild at 7 → ~3 days.
  - Dice: last new Super ~5–6 days before close, Wild already on sale from 7 → no gap.
- Fits the observation that Disney middle 4+ players stay ~70% active after rares freeze but spend ~3%.
- Candidate test: Wild earlier in Disney (7 days, like Dice/Domino) — A/B.
- Needs Validation: whether a Wild-filled slot counts in unique_royal/golden_lt (Disney/Domino have number_of_jokers_today/lt); Wild uptake by group in the last week.

## Last 14 days by window (EndWin, 2026-10-15) — Disney 91.7 GB / Domino 27.2 GB / Dice 22.9 GB
Run without showing first (Eden: "just run"). Same population/relative groups; groups = weak P0–50 / middle P50–95 / strong P95+, end state 1–3 vs 4+. Windows = days before close: 14–11 / 10–8 / 7–5 / 4–1. Sticker tables: Disney bi_entity_prod.dim_user_album_stickers, Domino prod_30_intermediate.int_user_album_stickers, Dice 30_intermediate.fact_user_album_stickers (first collection per user×sticker). Per-100 = stickers per 100 players in the group. Averages of the two albums.

Middle payers (P50–95):
| Metric | Disney 4+ | Disney 1–3 | Domino 4+ | Domino 1–3 | Dice 4+ | Dice 1–3 |
|---|---|---|---|---|---|---|
| Wild-filled stickers per 100, days 7–5 | ~0 | ~0 | 4 | 17 | 4 | 11 |
| Wild-filled stickers per 100, days 4–1 | 2 | 23 | 9 | 92 | 7 | 40 |
| New gate stickers per 100, days 10–8 | 15 | 34 | 41 | 57 | 45 | 73 |
| New gate stickers per 100, days 7–5 | 32 | 49 | 39 | 42 | 36 | 76 |
| Active rate days 14–11 → 4–1 | 89% → 83% | ~95% | 83% → 74% | ~95% | 86% → 75% | ~95% |
| Payers in days 4–1 | 36% | 69% | 29% | 72% | 29% | 58% |
| Share of group revenue spent in last 7 days | 9% | 20% | 7% | 17% | 9% | 18% |

Reading:
- Known: players who end far (4+) barely use Wild in ANY game when it is open (2–9 Wild stickers per 100 players in the last 4 days) vs 23–92 for those ending at 1–3. → Wild timing is NOT a lever for the 4+ pool; Wild is a near-finisher tool.
- Known: Disney near-finishers (1–3) use Wild far less (23 per 100) than Domino (92) / Dice (40) — consistent with Wild open only 3–4 days in Disney. Their last-7-days spend share (~20%) is similar to Domino/Dice though.
- Known: the "Royal drought" is partial, not zero: Disney middle 4+ get 15 new Royals per 100 players in days 10–8 (vs ~40 in Domino/Dice), then 32 per 100 in days 7–5. The dip at 10–8 days is Disney-specific.
- Known: far players are still mostly active (74–89%) and ~30–36% pay in the last 4 days, but their spend share is low (7–9% in the last week).
- Missing: paid vs free — mtx campaign name is filled on almost all gate stickers (paid proxy ≈ total), so it is NOT a usable paid flag. Paid/free split still open.
- Hypothesis (revised): moving Wild earlier in Disney would mostly affect near-finishers (1–3), not the 4+ pool. Money question = does earlier Wild add spend from near-finishers or just shift timing → A/B. The 4+ pool needs something before the last week (mid-album pace / Royal supply), not Wild.

### SQL (EndWin)

```sql
-- EndWin Disney 14/15 (2026-10-15): last 14 days before close by window, per relative group x end state.
-- Activity, payers, spend, new gate (Royal) stickers split wild / paid (mtx campaign, proxy) / other, new Goldens, wild-filled stickers of any type.
WITH excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d,
    DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend, IFNULL(a.active_flag, FALSE) AS act,
    144 - (IFNULL(a.unique_common_stickers_lt, 0) + IFNULL(a.unique_golden_stickers_lt, 0) + IFNULL(a.unique_royal_stickers_tl, 0)) AS miss
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND a.album_id IN (14, 15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(n) AS n, CAST(CEIL(0.75 * ANY_VALUE(n)) AS INT64) AS cp,
    SUM(spend) AS total, MIN(d) AS first_d, SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far, MIN(miss) AS m_end,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row
  FROM r0 GROUP BY 1, 2),
tgt AS (
  SELECT album_id, user_id, a_start, n, total, so_far, m_end FROM ua
  WHERE last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1 AND first_d <= cp - 1),
p AS (
  SELECT album_id, user_id, a_start, n, total, so_far, m_end,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM tgt),
g AS (
  SELECT album_id, user_id, a_start, n, total,
    CASE WHEN pr < 0.5 THEN '1 weak' WHEN pr < 0.95 THEN '2 middle' ELSE '3 strong' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0),
gs AS (SELECT album_id, grp, st, COUNT(*) AS players, SUM(total) AS rev FROM g GROUP BY 1, 2, 3),
uw AS (
  SELECT g.album_id, g.grp, g.st, g.user_id,
    CASE WHEN g.n - r.d BETWEEN 11 AND 14 THEN 'a 14-11' WHEN g.n - r.d BETWEEN 8 AND 10 THEN 'b 10-8'
         WHEN g.n - r.d BETWEEN 5 AND 7 THEN 'c 7-5' ELSE 'd 4-1' END AS w,
    COUNTIF(r.act) AS act_days, SUM(r.spend) AS spend
  FROM g JOIN r0 r ON r.album_id = g.album_id AND r.user_id = g.user_id
  WHERE g.n - r.d BETWEEN 1 AND 14 GROUP BY 1, 2, 3, 4, 5),
wa AS (SELECT album_id, grp, st, w, SUM(act_days) AS act_days, SUM(spend) AS spend, COUNTIF(spend > 0) AS payers FROM uw GROUP BY 1, 2, 3, 4),
sk AS (
  SELECT g.album_id, g.grp, g.st, g.n, g.a_start, LOWER(s.sticker_type) AS typ, IFNULL(s.collected_by_joker_flag, FALSE) AS wild,
    s.new_sticker_mtx_campaign_name IS NOT NULL AS paid, s.sticker_collected_min_date AS cdate
  FROM g JOIN `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s ON s.album_id = g.album_id AND s.user_id = g.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND s.album_id IN (14, 15) AND s.user_collected_sticker_flag
  QUALIFY ROW_NUMBER() OVER (PARTITION BY g.album_id, g.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
sw AS (
  SELECT album_id, grp, st,
    CASE WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 11 AND 14 THEN 'a 14-11' WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 8 AND 10 THEN 'b 10-8'
         WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 5 AND 7 THEN 'c 7-5' ELSE 'd 4-1' END AS w,
    COUNTIF(typ = 'royal') AS gate_new, COUNTIF(typ = 'royal' AND wild) AS gate_wild, COUNTIF(typ = 'royal' AND paid AND NOT wild) AS gate_paid,
    COUNTIF(typ = 'golden') AS golden_new, COUNTIF(wild) AS wild_any
  FROM sk WHERE n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 1 AND 14 GROUP BY 1, 2, 3, 4)
SELECT wa.album_id, wa.grp, wa.st, wa.w, gs.players,
  ROUND(wa.act_days / (gs.players * CASE wa.w WHEN 'a 14-11' THEN 4 WHEN 'b 10-8' THEN 3 WHEN 'c 7-5' THEN 3 ELSE 4 END), 3) AS active_rate,
  ROUND(wa.payers / gs.players, 3) AS payer_rate,
  ROUND(wa.spend / gs.rev, 3) AS share_of_group_rev,
  ROUND(100 * IFNULL(sw.gate_new, 0) / gs.players, 1) AS gate_new_per100,
  ROUND(100 * IFNULL(sw.gate_wild, 0) / gs.players, 1) AS gate_wild_per100,
  ROUND(100 * IFNULL(sw.gate_paid, 0) / gs.players, 1) AS gate_paid_per100,
  ROUND(100 * IFNULL(sw.golden_new, 0) / gs.players, 1) AS golden_new_per100,
  ROUND(100 * IFNULL(sw.wild_any, 0) / gs.players, 1) AS wild_any_per100
FROM wa JOIN gs USING (album_id, grp, st) LEFT JOIN sw USING (album_id, grp, st, w)
ORDER BY 1, 2, 3, 4
```

```sql
-- EndWin Domino 19/20 (2026-10-15): last 14 days before close by window, per relative group x end state.
-- Activity, payers, spend, new gate (Royal) stickers split wild / paid (mtx campaign, proxy) / other, new Goldens, wild-filled stickers of any type.
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d,
    DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend, IFNULL(a.active_flag, FALSE) AS act,
    144 - (IFNULL(a.unique_common_stickers_lt, 0) + IFNULL(a.unique_golden_stickers_lt, 0) + IFNULL(a.unique_royal_stickers_tl, 0)) AS miss
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND a.album_id IN (19, 20)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(n) AS n, CAST(CEIL(0.75 * ANY_VALUE(n)) AS INT64) AS cp,
    SUM(spend) AS total, MIN(d) AS first_d, SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far, MIN(miss) AS m_end,
    ARRAY_AGG(STRUCT(login_ratio AS lr, user_album_count AS uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS last_row
  FROM r0 GROUP BY 1, 2),
tgt AS (
  SELECT album_id, user_id, a_start, n, total, so_far, m_end FROM ua
  WHERE last_row.lr >= 0.5 AND IFNULL(last_row.uac, 0) > 1 AND first_d <= cp - 1),
p AS (
  SELECT album_id, user_id, a_start, n, total, so_far, m_end,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM tgt),
g AS (
  SELECT album_id, user_id, a_start, n, total,
    CASE WHEN pr < 0.5 THEN '1 weak' WHEN pr < 0.95 THEN '2 middle' ELSE '3 strong' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0),
gs AS (SELECT album_id, grp, st, COUNT(*) AS players, SUM(total) AS rev FROM g GROUP BY 1, 2, 3),
uw AS (
  SELECT g.album_id, g.grp, g.st, g.user_id,
    CASE WHEN g.n - r.d BETWEEN 11 AND 14 THEN 'a 14-11' WHEN g.n - r.d BETWEEN 8 AND 10 THEN 'b 10-8'
         WHEN g.n - r.d BETWEEN 5 AND 7 THEN 'c 7-5' ELSE 'd 4-1' END AS w,
    COUNTIF(r.act) AS act_days, SUM(r.spend) AS spend
  FROM g JOIN r0 r ON r.album_id = g.album_id AND r.user_id = g.user_id
  WHERE g.n - r.d BETWEEN 1 AND 14 GROUP BY 1, 2, 3, 4, 5),
wa AS (SELECT album_id, grp, st, w, SUM(act_days) AS act_days, SUM(spend) AS spend, COUNTIF(spend > 0) AS payers FROM uw GROUP BY 1, 2, 3, 4),
sk AS (
  SELECT g.album_id, g.grp, g.st, g.n, g.a_start, LOWER(s.sticker_type) AS typ, IFNULL(s.collected_by_joker_flag, FALSE) AS wild,
    s.new_sticker_mtx_campaign_name IS NOT NULL AS paid, s.sticker_collected_min_date AS cdate
  FROM g JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = g.album_id AND s.user_id = g.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND s.album_id IN (19, 20) AND s.user_collected_sticker_flag
  QUALIFY ROW_NUMBER() OVER (PARTITION BY g.album_id, g.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
sw AS (
  SELECT album_id, grp, st,
    CASE WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 11 AND 14 THEN 'a 14-11' WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 8 AND 10 THEN 'b 10-8'
         WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 5 AND 7 THEN 'c 7-5' ELSE 'd 4-1' END AS w,
    COUNTIF(typ = 'royal') AS gate_new, COUNTIF(typ = 'royal' AND wild) AS gate_wild, COUNTIF(typ = 'royal' AND paid AND NOT wild) AS gate_paid,
    COUNTIF(typ = 'golden') AS golden_new, COUNTIF(wild) AS wild_any
  FROM sk WHERE n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 1 AND 14 GROUP BY 1, 2, 3, 4)
SELECT wa.album_id, wa.grp, wa.st, wa.w, gs.players,
  ROUND(wa.act_days / (gs.players * CASE wa.w WHEN 'a 14-11' THEN 4 WHEN 'b 10-8' THEN 3 WHEN 'c 7-5' THEN 3 ELSE 4 END), 3) AS active_rate,
  ROUND(wa.payers / gs.players, 3) AS payer_rate,
  ROUND(wa.spend / gs.rev, 3) AS share_of_group_rev,
  ROUND(100 * IFNULL(sw.gate_new, 0) / gs.players, 1) AS gate_new_per100,
  ROUND(100 * IFNULL(sw.gate_wild, 0) / gs.players, 1) AS gate_wild_per100,
  ROUND(100 * IFNULL(sw.gate_paid, 0) / gs.players, 1) AS gate_paid_per100,
  ROUND(100 * IFNULL(sw.golden_new, 0) / gs.players, 1) AS golden_new_per100,
  ROUND(100 * IFNULL(sw.wild_any, 0) / gs.players, 1) AS wild_any_per100
FROM wa JOIN gs USING (album_id, grp, st) LEFT JOIN sw USING (album_id, grp, st, w)
ORDER BY 1, 2, 3, 4
```

```sql
-- EndWin Dice 61/63 (2026-10-15): last 14 days before close by window, per relative group x end state.
-- Activity (is_active), payers, spend, new gate (Super) stickers split wild / paid (mtx campaign, proxy) / other, new Goldens, wild-filled stickers of any type.
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end, 35 AS n UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07', 42),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.a_start, alb.n,
    DATE_DIFF(a.date_dim, alb.a_start, DAY) AS d,
    a.album_login_ratio AS lr, a.user_past_album_count AS past,
    IFNULL(a.spent_in_album_today, 0) AS spend, IFNULL(a.is_active, FALSE) AS act,
    144 - IFNULL(a.unique_stickers_lt, 0) AS miss
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
tgt AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_st, ANY_VALUE(n) AS n_, SUM(spend) AS total,
    SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far, MIN(miss) AS m_end
  FROM r0 GROUP BY 1, 2
  HAVING MIN(past) > 0 AND MIN(d) <= CAST(CEIL(0.75 * ANY_VALUE(n)) AS INT64) - 1
     AND ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
p AS (
  SELECT album_id, user_id, a_st AS a_start, n_ AS n, total, so_far, m_end,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM tgt),
g AS (
  SELECT album_id, user_id, a_start, n, total,
    CASE WHEN pr < 0.5 THEN '1 weak' WHEN pr < 0.95 THEN '2 middle' ELSE '3 strong' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0),
gs AS (SELECT album_id, grp, st, COUNT(*) AS players, SUM(total) AS rev FROM g GROUP BY 1, 2, 3),
uw AS (
  SELECT g.album_id, g.grp, g.st, g.user_id,
    CASE WHEN g.n - r.d BETWEEN 11 AND 14 THEN 'a 14-11' WHEN g.n - r.d BETWEEN 8 AND 10 THEN 'b 10-8'
         WHEN g.n - r.d BETWEEN 5 AND 7 THEN 'c 7-5' ELSE 'd 4-1' END AS w,
    COUNTIF(r.act) AS act_days, SUM(r.spend) AS spend
  FROM g JOIN r0 r ON r.album_id = g.album_id AND r.user_id = g.user_id
  WHERE g.n - r.d BETWEEN 1 AND 14 GROUP BY 1, 2, 3, 4, 5),
wa AS (SELECT album_id, grp, st, w, SUM(act_days) AS act_days, SUM(spend) AS spend, COUNTIF(spend > 0) AS payers FROM uw GROUP BY 1, 2, 3, 4),
sk AS (
  SELECT g.album_id, g.grp, g.st, g.n, g.a_start, LOWER(s.sticker_type) AS typ, IFNULL(s.collected_from_wild, FALSE) AS wild,
    s.sticker_mtx_campaign_name IS NOT NULL AS paid, s.sticker_collected_date AS cdate
  FROM g JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = g.album_id AND s.user_id = g.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63) AND s.is_sticker_collected
  QUALIFY ROW_NUMBER() OVER (PARTITION BY g.album_id, g.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
sw AS (
  SELECT album_id, grp, st,
    CASE WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 11 AND 14 THEN 'a 14-11' WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 8 AND 10 THEN 'b 10-8'
         WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 5 AND 7 THEN 'c 7-5' ELSE 'd 4-1' END AS w,
    COUNTIF(typ = 'super') AS gate_new, COUNTIF(typ = 'super' AND wild) AS gate_wild, COUNTIF(typ = 'super' AND paid AND NOT wild) AS gate_paid,
    COUNTIF(typ = 'golden') AS golden_new, COUNTIF(wild) AS wild_any
  FROM sk WHERE n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 1 AND 14 GROUP BY 1, 2, 3, 4)
SELECT wa.album_id, wa.grp, wa.st, wa.w, gs.players,
  ROUND(wa.act_days / (gs.players * CASE wa.w WHEN 'a 14-11' THEN 4 WHEN 'b 10-8' THEN 3 WHEN 'c 7-5' THEN 3 ELSE 4 END), 3) AS active_rate,
  ROUND(wa.payers / gs.players, 3) AS payer_rate,
  ROUND(wa.spend / gs.rev, 3) AS share_of_group_rev,
  ROUND(100 * IFNULL(sw.gate_new, 0) / gs.players, 1) AS gate_new_per100,
  ROUND(100 * IFNULL(sw.gate_wild, 0) / gs.players, 1) AS gate_wild_per100,
  ROUND(100 * IFNULL(sw.gate_paid, 0) / gs.players, 1) AS gate_paid_per100,
  ROUND(100 * IFNULL(sw.golden_new, 0) / gs.players, 1) AS golden_new_per100,
  ROUND(100 * IFNULL(sw.wild_any, 0) / gs.players, 1) AS wild_any_per100
FROM wa JOIN gs USING (album_id, grp, st) LEFT JOIN sw USING (album_id, grp, st, w)
ORDER BY 1, 2, 3, 4```

