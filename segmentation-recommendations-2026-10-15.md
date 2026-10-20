# Album segmentation — findings and recommendation per game (2026-10-15)

Sources: Disney D1–D5b (`claude/disney-segmentation-*.md`), Dice validation (`claude/dice-segmentation-validation-2026-10-14.md`), Domino Dom1–Dom6 (`claude/domino-segmentation-2026-10-15.md`).
Goal metric (Eden): revenue share of players at ≤3 missing (of 144) at close−4.

## Domino Dom5 / Dom6 results (run 2026-10-15; albums 19 / 20; same method as Disney D5 / D5b)
Dom5 — reach at close−4 by projected-$/day tier (at day 37 of 49) inside each history level (19 / 20):
| Level (history $/day) | Tier ≤2 | 2–5 | 5–20 | >20 |
|---|---|---|---|---|
| 1: ≤2 | 2 / 28 | 3 / 45 | 8 / 52 | 26 / 65 |
| 2: 2–5 | 2 / 35 | 3 / 47 | 6 / 55 | 23 / 65 |
| 3: 5–20 | 23 / 37 | 27 / 47 | 47 / 61 | 62 / 71 |
| 4: >20 | 29 / 33 | 30 / 34 | 52 / 64 | 73 / 73 |
Curve at day 37 (share of album spend): 0.71–0.78 by level (near-linear, like Disney). Calibration actual ÷ projected 0.90–1.04 for tiers ≥$1/day (album 19 top tiers over-projected 6–14%).
Dom6 — revenue correctly classified (history / current / combined): day 5: 55–56 / 53 / 58; day 13: 55–56 / 66 / 63–64; day 25: 55 / 77 / 73; day 37: 55 / 86–87 / 84–85. Top-level revenue caught: history 70–72 → current 83–84 at day 13. Pooled curve: 9% / 27% / 51% / 74–76% at 10 / 25 / 50 / 75% of album.
Reading: album 20 behaves like Disney (tier explains reach; level adds ~5–10 points at the top). Album 19: levels 1–2 (≈ easy version) near zero at every tier, levels 3–4 (≈ hard) normal → the easy/hard versions had different end-games in album 19 (Needs Validation with the Domino team). History vs current: identical to Disney — equal at day 5, current wins from ~25% of the album.

## Cross-game pattern (Known, Disney + Domino; Dice consistent)
1. Revenue is concentrated: players >$5/day ≈ 3.5–4% of players, ~50% of revenue.
2. History level is unstable: ~half of payers spend less than their history level; one album of history is as good as three.
3. From ~25% of the album, current spend predicts the album level better than history; at the last-quarter start the projected tier explains reach and the level adds little (Disney ≤5 pts, Domino album 20 ≤10 pts; Dice step 4: tier > difficulty).
4. Spend pace is near-linear in Disney and Domino (≈ 75–80% of album spend by 75% of time); Dice actual pace also near-linear (its Easy formula curve is wrong).
5. The movers-up (low history, high current spend) carry a large share of low-level revenue and are visible only through current spend.

## Recommendation per game
Decision (Eden, 2026-10-15): ONE structure for levels and tiers — 5 groups with the same cuts: 0 / ≤2 / 2–5 / 5–20 / >20 $/day (level = last album played, 0 = no spend in it; tier = projected $/day at the last-quarter start, 0 = no spend yet). Group 0 gets no revenue goal.

| Game | Pre-album level | Last-quarter tier | Goals | Status |
|---|---|---|---|---|
| Disney | Build 5 levels (Eden): 0 / ≤2 / 2–5 / 5–20 / >20 $/day from last album; used for album start and curve | 5 tiers by projected $/day, same cuts, from ~day 11 (current spend) | By tier, revenue share at close−4; tier 0 no goal; goal option still open | Test (shadow one album → A/B vs current injections) |
| Domino | Existing easy/hard ≈ one cut at $5/day; move to the same 5 levels for one cross-studio language | Same 5-tier projected $/day model (works on album 20) | Same as Disney | Do Not Adopt Yet — first confirm with the team whether easy/hard versions differ in content (album 19) and fix the −9999 unassigned daily segment; then Test |
| Dice | Probably drop as a targeting/goal dimension (Eden); difficulty may still be needed as album content (product question) | Replace level-relative tiers with the same absolute 5 tiers + refit curve each album | By tier | Do Not Adopt Yet — evidence query pending (Dice D5-equivalent: absolute projected bins × difficulty → reach) |

Open next: Dice evidence query; Domino team answers; goal-option decision; then the "2 missing instead of 3 for low spenders" question for all games.

