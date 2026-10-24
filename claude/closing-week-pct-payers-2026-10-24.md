# Closing week, % of payers using the Wild / Joker per day — fix of Part 1 slide 24 (2026-10-24)

Eden asked to fix the existing slide 24 of "Album Analysis Across Three Games, Part 1" ("Dice Sells Wilds All Week; Domino Gives Jokers; Disney Sells Only at the End").
SQL: `claude/closing_week_pct_payers_2026-10-24.sql` (dice-dreams-dbt 84 GB, domino-dreams-dbt 12 GB, solitaire-dreams-411507 24 GB).
Slide: new copy `p24fix` right after p24 (p24 kept as is). Chart drawn as shapes by `claude/slide_p24_fix_2026-10-24.py` (Domino legend moved by hand to x 4,980,000). Image: `claude/slides/part1-p24fix.png`.

## What changed
- Albums: Dice 63, Domino 20, Disney 15 (were Dice 63, Domino 19, Disney 14) — topic-0 decision (Domino 19/20, 20 when it differs; latest albums).
- Measure: % of the album's standard-population payers (were counts of all players). Payers: Dice 63 203,118 · Domino 20 106,762 · Disney 15 325,842.
- One scale (0–12%) in all panels (was own scale per panel).
- Title describes the chart: "Payers Using the Wild / Joker per Day, Last 7 Days Before Close".

## Results (% of payers, days 7 → 1 before close; bought / gameplay)
| Game | 7 | 6 | 5 | 4 | 3 | 2 | 1 |
|---|---|---|---|---|---|---|---|
| Dice 63 | 1.8 / 1.3 | 3.3 / 0.0 | 2.6 / 0.0 | 3.7 / 0.0 | 5.1 / 1.9 | 5.6 / 4.0 | 5.8 / 3.5 |
| Domino 20 | 1.1 / 1.4 | 0.6 / 1.3 | 0.6 / 2.4 | 1.3 / 5.9 | 1.1 / 11.3 | 1.0 / 6.9 | 0.8 / 4.0 |
| Disney 15 | 0.1 / 0.0 | 0.1 / 0.0 | 0.1 / 0.0 | 0.05 / 0.7 | 1.0 / 0.6 | 1.2 / 2.1 | 2.0 / 4.2 |

## Reading
- Same message as before, now on the right albums and comparable: Dice sells Wilds every day (2–6% of payers); Domino 20 gives Jokers free (Puzzle event, 11% three days out), bought ~1%; Disney sells mostly in the last 3 days (1–2%), about 0.1% a day before.
- Correction to the old title: Disney 15 does sell a Joker from 7 days out, but to ~400 payers a day.
