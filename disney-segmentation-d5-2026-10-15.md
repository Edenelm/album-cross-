# Disney segmentation — Step D5: daily tier inside each option-C level (run 2026-10-15)

Continues `claude/disney-segmentation-build-2026-10-14.md` (D1–D4). Project `solitaire-dreams-411507`, table `bi_prod.user_daily_album` + `bi_prod.user_profile` (excluded).

## Definition (Eden approved as shown)
- Level = option C from the LAST album played (h1): ≤2 / 2–5 / 5–20 / >20 $/day.
- Checkpoint = last-quarter start, day CEIL(0.75 × 42) = 32; spend so far = through end of day 31.
- Projected album $/day = spend so far ÷ level curve value ÷ 42. Curve = pooled share of album spend at the checkpoint (payers), taken from the OTHER album (out-of-sample): L1 0.750 / L2 0.775–0.780 / L3 0.783–0.788 / L4 0.795–0.803.
- Population: not special, not excluded, user_album_count > 1, login ratio on last row before close ≥ 0.5 (standing rule), present in the album by the checkpoint; close day excluded.
- Reach = revenue share of players at ≤3 missing (of 144) at close−4 / close−3 (revenue album start → that day).
- Raw bins (0, ≤0.25, 0.25–0.5, 0.5–1, 1–2, 2–5, 5–10, 10–20, 20–50, >50) with sums are in the query output; options below are composed from them.

## Results
Calibration (Known): actual ÷ projected album spend = 0.95–1.03 for every bin with projection ≥ $1/day, both albums, all levels. Below $1/day projection under-shoots (actual 1.1–2.8×) — small payers keep buying; negligible revenue.

Option A — tier cuts = the same $ cuts as the levels, applied to the projection (0 / ≤2 / 2–5 / 5–20 / >20). Reach at close−4, album 14 / 15:
| Tier (projected $/day) | Level 1 | Level 2 | Level 3 | Level 4 |
|---|---|---|---|---|
| ≤2 (paid so far) | 15 / 9 | 19 / 13 | 21 / 15 | 26 / 16 |
| 2–5 | 27 / 23 | 28 / 23 | 29 / 24 | 28 / 27 |
| 5–20 | 44 / 45 | 42 / 43 | 47 / 46 | 48 / 49 |
| >20 | 67 / 69 | 64 / 67 | 66 / 67 | 71 / 74 |
Close−3 adds 2–5 points everywhere.

Players % / revenue % of the level by option-A tier (album 14 / 15):
| Tier | Level 1 | Level 2 | Level 3 | Level 4 |
|---|---|---|---|---|
| 0 (no spend yet) | 78 / 78 · 2% rev | 8 · 0% | 4 · 0% | 1–2 · 0% |
| ≤2 | 19 · 43% | 39–43 · 14–16% | 14–15 · 2–3% | 3 · 0% |
| 2–5 | 2.1–2.2 · 26–27% | 34–36 · 37% | 25–28 · 11–14% | 5–6 · 1% |
| 5–20 | 0.7 · 22% | 15–17 · 39–42% | 48–50 · 61–63% | 37–44 · 17–23% |
| >20 | 0.1 · 6–7% | 0.7–0.8 · 7–8% | 5–7 · 21–25% | 46–53 · 76–82% |

Option B — finer top (≤1 / 1–5 / 5–10 / 10–20 / 20–50 / >50): reach at close−4 ≈ 7–19 / 18–28 / 35–40 / 48–55 / 59–67 / 67–84 — again near-identical across levels.

## Reading
- Known: at the checkpoint, the projected tier explains reach; the pre-album level adds almost nothing once the tier is known (same tier → within ~5 points across levels). Same pattern as Dice step 4 (tier > difficulty).
- Known: projection with the level curve is well calibrated (±5%) where the revenue is.
- Known: level 1 — 0.8% of its players project >$5/day and bring 28–29% of the level's revenue; they reach like level 3–4 players (44–69%). The daily tier catches the "movers up" found in D3.
- Known: album 15 sits 4–11 points below album 14 in the low/mid tiers; top tiers equal → album-level design effect, as in Dice 61 vs 63.
- Known: tier 0 (no spend by the checkpoint) is 78% of level 1; its revenue share at ≤3 missing is unstable (17–28%) because its revenue is tiny.
- Hypothesis: one universal tier table (projected $/day) can serve all levels in the last quarter; the level then matters mainly for the first three quarters (difficulty / injection plan) and for the curve value.
- Not causal: paying buys stickers.

## Options for management (Eden to decide)
1. Option A — 5 tiers, same cuts as levels (0 / ≤2 / 2–5 / 5–20 / >20). One language for levels and tiers; clean steps ~15 → 25 → 45 → 68%.
2. Option B — 7 tiers with a finer top (adds 5–10 / 10–20 / 20–50 / >50). Splits where revenue concentrates (levels 3–4); more cells, some small (L1–L2 >50: 26–79 players).
3. Hybrid — option A for levels 1–2, option B top split for levels 3–4.

## Next
Eden picks tier cuts → goal table per level × tier (target revenue share at close−4) → D6 shadow tier for one album → A/B vs current injections.

## SQL (Dis5)
Same CTEs as Dis4 for population/level; `u` sums spend through day cp−1, revenue and min-missing through close−4/−3; `curve` = SUM(so_far)/SUM(total) per album × level on payers; `p` joins the OTHER album's curve; `proj_daily = so_far / s75 / n`; binned and aggregated per album × level × bin with rev_c4 / rev_c4_le3 / rev_c3 / rev_c3_le3 / players / share columns / actual_vs_projected. Full text: see `claude/disney_segmentation_queries.sql` → to append as Dis5 (query text identical to the one approved in chat 2026-10-15; 45.6 GB).

