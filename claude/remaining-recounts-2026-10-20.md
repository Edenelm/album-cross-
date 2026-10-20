# Remaining recounts with the new finisher rule (2026-10-20, Eden: "ספירות שנשארו")

Finisher = 144 unique set stickers by the END of the close day (Eden, 2026-10-19). Every query runs old and new side by side; where the old slide value came from a saved query, the old rule reproduces it.
SQL: claude/remaining_recounts_queries.sql (Dice 23.1 GB, Domino 48.6 GB, Disney 73.6 GB, Domino 20 puzzle 17.2 GB).
Population: standard (not first album, not excluded, login ratio 0.5+ on the last row before close, row on close−1); payer = album-table spend > 0 from start to close−1. Finishing sticker = the player's last first-receipt sticker (by timestamp) up to the finish day.
Deck: version 66 — 11 slides updated (last3days, domino-3albums, dice-close, closing-week, nonpayer-share, routes, disney-finishers, puzzle-joker, jokers, jokers-test, tests).

## 1. Last sticker via Wild / Joker (paying finishers)
| Album | Old → new | Close-day finishers | Paid Wild/Joker, new (old) |
|---|---|---|---|
| Dice 61 / 63 | 89.8 → 89.8% / 86.5 → 88.1% | 89.8% / 96.2% | 61.4% (57.9) / 71.2% (69.4) |
| Domino 17 / 19 / 20 | 44.7 → 41.1% / 95.5 → 95.8% / 94.8 → 94.8% | 22.8% / 96.8% / 95.2% | 18.3% / 10.9% / 12.2% |
| Disney 14 / 15 | 86.1 → 86.1% / 69.0 → 71.0% | 86.0% / 78.3% | 19.9% / 22.7% |
Deck averages (Dice 61/63, Domino 19/20, Disney 14/15): 89% / 95% / 79% (was 89 / 95 / 78). Dice paid Wild: 61–71% (was 58–69%). Dice paying finishers' last Super via Wild: 96% / 95% (different base from the dice-close card "78–84% of final Supers", which stays as is).
Non-paying finishers (new): Domino 20 last sticker a Puzzle Joker 60% (unchanged); Disney last sticker from the Market 79% / 78% (Market Joker 79% / 59%); Dice 98% via a Wild. Dice: some close-day "non-paying" finishers bought a Wild on the close day itself (album revenue counts to close−1 only): paid Wild share of Dice non-paying finishers 9% / 26% (old 0.3% / 1.7%).

## 2. Finishers' end spend (disney-finishers rows)
Paying finishers; before = days 14–8 before close; last full day = close−1, spend per active player (album-table spend; activity = daily metrics sessions); pay rate = share of the group paying per day, days 3–1 vs 14–8.
| | Dice 61 / 63 | Domino 17 / 19 | Disney 14 / 15 | Average new (old) |
|---|---|---|---|---|
| Spend last full day vs before, new | 2.36 / 2.27 | 1.56 / 2.05 | 2.19 / 2.07 | 2.3 / 1.8 / 2.1 (2.4 / 1.9 / 2.3) |
| Same, old rule (this query) | 2.44 / 2.36 | 1.53 / 2.08 | 2.39 / 2.20 | 2.4 / 1.8 / 2.3 |
| Pay rate last 3 days vs before, new | 1.90 / 1.78 | 1.36 / 1.57 | 1.58 / 1.66 | 1.8 / 1.5 / 1.6 (2.0 / 1.5 / 1.8) |
| Same, old rule (this query) | 2.03 / 1.90 | 1.35 / 1.64 | 1.72 / 1.79 | 2.0 / 1.5 / 1.8 |
Old rule reproduces the deck for Dice and Disney; Domino spend 1.8 vs 1.9 on the old slide (method, not definition: the definition leaves Domino at 1.8).
Close-day finishers lift less: spend ×1.4–1.9, pay rate ×1.1–1.4 — they pull the averages down a little.

## 3. Routes: finish rate by Wild / Joker route (payers 4–6 missing 8 days before close)
Route = Wild / Joker fill in days 7–1 before close (bought / gameplay only / none), as in the chart; Dice bought = Pricing pack; Domino = validated campaign rule; Disney = purchase / purchase_gift (Market = gameplay). Spend ratios on the slide do not depend on the finisher rule and were not rerun.
| Route | Dice 61 / 63 | Domino 17 / 19 | Disney 14 / 15 | Average new (old, this query) |
|---|---|---|---|---|
| Bought | 58.1 / 60.0% | 63.8 / 60.3% | 68.6 / 58.0% | 59 / 62 / 63% (53 / 58 / 57%) |
| Gameplay only | 14.2 / 9.5% | 50.4 / 26.8% | 65.1 / 50.1% | 12 / 39 / 58% (7 / 33 / 53%) |
| None | 1.9 / 1.6% | 6.3 / 1.2% | 2.5 / 2.0% | 2 / 4 / 2% (0 / 2 / 0%) |
Group sizes (bought / gameplay / none): Dice 7,816 / 2,639 / 19,155 and 18,426 / 3,073 / 40,418; Domino 2,191 / 2,173 / 10,171 and 1,278 / 8,536 / 12,871; Disney 3,596 / 6,985 / 78,287 and 3,551 / 4,983 / 42,076.
The "none" finishers closed with a Wild / Joker on the close day itself: with the close day counted in the route, none = 0–0.4%, except Domino 17 (5%, players who finished before the last week).
The old rule here reproduces round 3 (Domino) and round 4 (Dice) of endgame-s1-s4; the slide note had 53 / 53 / 59 and 7 / 32 / 52 from the matched round 4 (Domino / Disney 2–5 pts off; that query was not saved).

## 4. Domino 20 two-Puzzle closers (puzzle-joker, jokers, jokers-test, tests)
| | Old (reproduces deck) | New |
|---|---|---|
| Finishers (all, standard population) | 15,091 | 17,665 |
| Last two new stickers both from the Puzzle | 3,223 (21%) | 3,991 (23%) |
| of which paid in the album | 1,092 | 1,490 |
| did not pay | 2,131 | 2,501 |
| Strong ($5+ per active day in album 19) | 393 | 520 |
| Strong group's album spend | $287K (1.8% of $16.1M) | $367K (2.3%) |
| Finishers without them | 11,868 (+63% vs 19's 7,270) | 13,674 (+37% vs 19's 9,992) |
Stake hypothesis scaled by the strong group: $10–20K → $13–26K. The "~3% of last-week stickers from offers" and "89% bought above CZ" are from the 393-player run (not rerun).

## Facts / interpretation
- Fact: counting close-day finishers barely moves how the album is closed: Wild / Joker share of the last sticker is unchanged in Dice and Domino 19/20 and +2 pts in Disney 15; Domino 17 drops 4 pts (close-day finishers there closed with a Joker only 23% of the time).
- Fact: finishers' end-of-album lift is a little smaller with close-day finishers (spend ×2.3 / 1.8 / 2.1, pay rate ×1.8 / 1.5 / 1.6).
- Fact: the route message holds — without a Wild / Joker in the last week almost no one finishes (2–4%, all via a close-day Wild / Joker).
- Fact: the two-Puzzle group grows 24% (3,223 → 3,991); the strong part 32% (393 → 520).
- Interpretation: none of the deck's messages change; only numbers.
