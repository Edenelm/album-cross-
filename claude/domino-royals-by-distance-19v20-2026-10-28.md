# Domino 19 vs 20: Royals filled per day by distance group (2026-10-28)
Question (Eden): Royals look the same in 19 and 20 — check by distance group.
Query (domino-dreams-dbt, user_daily_album lifetime counters, 9 GB): standard-population payers; group fixed at the end of d−11 by set stickers missing (common+golden+royal of 144): near ≤6, mid 7–15, far 16+. Per day d−10..d−1: % of missing Royals (of 9) filled that day, payers active that day; avg Royals missing at start of day. Same logic as domino_golden_fill_rate_19v20_2026-10-27.sql.

| Group at d−11 | Album | Payers | % payers | % album rev | Royals filled/day d−10..−6 | d−5..−1 | Royals missing at start of d−1 |
|---|---|---|---|---|---|---|---|
| near ≤6 | 19 | 7,411 | 6% | 27% | 1–3% | 2–13% (rises d−3..−1) | 1.5 |
| near ≤6 | 20 | 22,731 | 21% | 49% | 1% | 2–9% (rises d−4..−3) | 1.6 |
| mid 7–15 | 19 | 55,779 | 47% | 56% | 5–9% | 2–7% | 2.7 |
| mid 7–15 | 20 | 54,124 | 51% | 42% | 3–5% | 4–10% (peak d−4/−3) | 2.6 |
| far 16+ | 19 | 56,011 | 47% | 17% | 3–5% | 2–4% | 5.3 |
| far 16+ | 20 | 29,907 | 28% | 9% | 1–4% | 3–6% | 5.1 |

- Fact: within each distance group, payers end with the same Royals missing in 19 and 20 (1.5 vs 1.6, 2.7 vs 2.6, 5.3 vs 5.1). Eden's reading holds: Royals did not improve.
- Fact: timing differs — 19 gave Royals earlier (mid group 5–9% a day d−10..−6), 20 later (peak d−4/−3); near-group Royals come only at the very end in both (gate).
- Fact: the big difference is group size: at d−11, 20 already had 21% of payers (49% of album revenue) within 6 stickers vs 6% (27%) in 19; far 28% vs 47%.
- Reading: 20's advantage was built before the last 10 days (more payers already close), not by Royals at the end. Fits m19 (even to day 33, 20 ahead from ~day 35 = 15 days before close).
