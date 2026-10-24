# Topic 6 rebuilt: spend per day in the last week before close and the week after, by end status (2026-10-24)

Eden: ALBUM END slide 59 (s6a) was not clear; payers who slow down had already started slowing before the end (topic 5). Rebuild, with separate slides for finishers and non-finishers.
SQL: `claude/topic6_before_after_2026-10-24.sql` (Disney 25 GB, Domino 10 GB, Dice 104 GB). Slides: s6c_slide (finishers), s6d_slide (non-finishers) after s6a_slide; generator `claude/slide_s6_before_after_2026-10-24.py`; images `claude/slides/s6c.png`, `s6d.png`.

## Definitions
- As topic 6: standard-population payers; spend level = album $ a day before the last quarter (= own pace); status on close−1: finished / 1–2 / 3 / 4+ missing.
- Last week = close−7 … close−1. Week after = close+1 … close+7 (next album days 2–8). Both as % of own pace (group totals).
- Slides use $2–20 a day payers (t2 + t3 combined).

## Results, $2–20 a day — last week → week after (% of own pace)
| Game / album | Finished | 1–2 missing | 3 missing | 4+ missing |
|---|---|---|---|---|
| Dice 63 | 229 → 110 (9,579 · 13%) | 135 → 90 (11,747 · 13%) | 51 → 75 (20,163 · 18%) | 29 → 52 (13,181 · 10%) |
| Domino 20 | 217 → 140 (4,025 · 14%) | 120 → 103 (5,749 · 14%) | 65 → 88 (9,192 · 17%) | 24 → 49 (6,566 · 11%) |
| Disney 15 | 188 → 128 (7,498 · 8%) | 150 → 108 (10,190 · 9%) | 82 → 84 (16,748 · 13%) | 44 → 59 (50,901 · 26%) |
| Dice 61 | 229 → 129 | 135 → 105 | 63 → 92 | 42 → 82 |
| Domino 19 | 225 → 134 | 141 → 110 | 105 → 104 | 43 → 64 |
| Disney 14 | 179 → 135 | 136 → 111 | 88 → 92 | 39 → 59 |
(players · % of standard-population payers' album revenue, latest album.)
Over $20 a day finishers: Dice 63 136 → 85, Domino 20 122 → 101, Disney 15 110 → 86.

## Reading
- **Fact:** payers who end 4+ away were already at 24–44% of their pace in the last week; the week after is higher (49–59%), not lower. The "start at half" in the old slide is the slowdown that began before the end, not a new drop. (Eden's point confirmed.)
- **Fact:** finishers double their pace in the last week and start the next album above it; Dice the lowest (110% / 129%).
- **Fact:** payers 1–2 short push in the last week (120–150%) and come back to about their pace (90–111%); Dice 63 the lowest (90%).
- **Interpretation:** the after-album question is not "who drops after the end" but "why the ones who pushed (finished or 1–2 short) come back at different levels" — Eden's next points: (1) finishers' return vs prize size / game structure, which game and population, revenue share; (2) 1–2 short payers and the payout after the album.
