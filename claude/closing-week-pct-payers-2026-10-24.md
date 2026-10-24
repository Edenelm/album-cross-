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
- Same message as before, now on the right albums and comparable: Dice sells Wilds every day (2–6% of payers); Domino 20 gives free Jokers in events (11% three days out), bought ~1%; Disney sells mostly in the last 3 days (1–2%), about 0.1% a day before.
- Correction to the old title: Disney 15 does sell a Joker from 7 days out, but to ~400 payers a day.

## Domino 20: where the free Jokers come from (checked 2026-10-24, Eden asked; 4.5 GB)
Same payers; non-paid Joker stickers by `new_sticker_source` / `new_sticker_mtx_campaign_name`, payers per day (days 5 → 1 before close):
| Source (campaign, dates) | 5 | 4 | 3 | 2 | 1 |
|---|---|---|---|---|---|
| Movie Twister event (AlbumMomentsTvTwister, t_Event, 8–9 Oct; + `_RC` variant) | 2 | 5,090 | 13,002 | 5,865 | 0 |
| Joker Puzzle (t_MiniCollection, 28 Sep – 7 Oct) | 2,234 | 1,442 | 0 | 0 | 0 |
| Summer Fever Puzzle (t_MiniCollection, 8–11 Oct) | 1 | 25 | 218 | 951 | 2,017 |
| Trail rewards (Collector's Trail 9 Oct, Summer Trail 11 Oct) | 1 | 1 | ~1,500 | ~1,570 | ~2,030 |
| Road to Glory (t_MtxEvent, 10–11 Oct) | 0 | 1 | 0 | 343 | 1,201 |
| Garden Blast (t_MiniGame, 10 Oct) | 1 | 1 | 0 | 636 | 532 |
- **Fact:** the peak 3 days before close is the Movie Twister event (13K payers that day; the two campaign variants may overlap), not the Puzzle. The Puzzle gave Jokers 5–4 days out (Joker Puzzle) and 2–1 days out (Summer Fever Puzzle).
- **Correction:** the earlier note "free Jokers mostly from the Puzzle event" was wrong for the peak; slide finding and notes fixed.
- **Not checked:** whether players had to pay to progress in Movie Twister; the validated paid rule classes it as gameplay.
