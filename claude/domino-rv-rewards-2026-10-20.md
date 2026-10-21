# Domino album 20 — what an RV gives finishers, and its role in completing the album (2026-10-20)

SQL: `claude/domino_rv_rewards_queries.sql` (Q1 14 GB, Q2 321 GB, `domino-dreams-dbt`). Staging views, because the curated
`prod_20_core.core_ad_watch_completed` ends in July 2026. Finishers = standard population, 144 by end of close day; payer = paid on any album day.

## What one RV gives (reward_syntax_actual, non-paying finishers, top rewards)
- Almost all views come from the placement **"badge tapped"** (an always-available RV badge); "OutOfCoinsAny" and "ReturnFromLevel" are small.
- Each view gives a small bundle, rotating: a **sticker pack** (`rv_pack_1/2/3_easy`), **Puzzle event pieces** (`dr-puzzle-holloween` ×5 or ×10),
  Blast picks (`dr-garden-blast` ×2), Trail energy (×5), a free entry, a free undo, or coins — plus a hidden RV counter (`dr-packaroo-hidden-rv`, `dr-hidden-ecnm`).

## Per finisher, album 20
| | Non-paying finishers | Paying finishers |
|---|---|---|
| Players | 7,517 | 10,148 |
| Album revenue | $0 | $4,408,996 (27% of game purchase revenue during the album; 34% on the old standard-population basis) |
| Watched an RV | 91% | 32% |
| Views per watcher (median / average) | 2,887 / 3,508 | 11 / 45 |
| Days with RV (watchers) | 31 | 6 |
| Ad revenue per view | $0.0019 | $0.12 |
| Ad revenue, total | $45,084 (0.28% of game purchase revenue during the album; 8% of game ad revenue) | $17,496 |
| Sticker packs per view | 0.18 | 0.09 |
| Puzzle pieces per view | 1.45 | 0.75 |
| Sticker packs from RV per watcher | 644 | 4 |
| Puzzle pieces from RV per watcher | 5,094 | 34 |
| New stickers from RV packs per player | 18 | 0.1 |
| New stickers from Puzzle Jokers per player | 2.4 | 1.9 |
| Puzzle pieces received that came from RV | ≥13% (reward text); 94% by the RV flag | 0% / 14% |

## Reading
- Fact: one view is worth almost nothing — $0.0019 of ad revenue, 0.18 of a sticker pack, 1.5 Puzzle pieces. But a non-paying finisher watches ~2,900 times
  (≈93 a day), so the small reward adds up: ~640 sticker packs and ~5,100 Puzzle pieces per player in one album.
- Fact: RV packs gave a non-paying finisher 18 new stickers on average (≈10–12% of the album's new stickers). Paying finishers got 0.1.
- Fact: RV also feeds the Puzzle event, and the Puzzle Joker gave 60% of non-payers' last sticker (`nonpayer-finishers-2026-10-18.md`).
- Interpretation: RV is a full free path to the album for players who never pay: stickers directly, plus fuel for the event that closes it.
- Caveats: the RV flag on resource events (94%) looks like a player-level flag, not a per-event source — the 13% from reward text is the safe lower bound.
  "New sticker" events per player are 180 (above 144), so counts include some repeats. ~93 views a day may include automated viewing — not checked.
- Non-paying finishers here are 7,517 (earlier doc: 6,543 under the older finisher rule).

## Recommendation (test)
- Cap RV views per day and per album (cap level = management decision; today the median non-paying finisher watches ~93 a day).
- Review the RV reward table: take sticker packs and Puzzle pieces out of the RV badge, or cut them in the last third of the album; keep coins / energy.
- Money at risk is small: RV revenue from non-paying finishers = $45,084 = 0.28% of game purchase revenue during the album (8% of game ad revenue, $0.55M).
- Test vs control: finish rate of non-payers, payer conversion, retention and ad revenue, days 1–14 of the next album.
