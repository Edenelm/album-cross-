# Approved batch (Eden "מאשרת", 2026-10-18): Domino finish timing, Dice predictor, Joker fills on the gate, chapter 2–3 reorder

## 1. Domino 17 / 19 / 20 — on which day do payers finish (SQL: claude/domino_finish_timing_17_19_20.sql, 16.4 GB)
Standard population (not first album, login 0.5+ on last full day, not special, no suspected cheaters). Finish day = first day with 144 unique stickers. Close day excluded.
| Album | Payer finishers / payers | Finish rate | Last day | Last 3 days | Finished by end of 4 days before close |
|---|---|---|---|---|---|
| 17 | 7,783 / 135,609 | 5.7% | 39% | 63% | 37% |
| 19 | 5,319 / 118,955 | 4.5% | 57% | 93% | 7% |
| 20 | 8,548 / 106,520 | 8.0% | 31% | 85% | 15% |
Per day (payers, d −8 or earlier … −1): 17 = 131, 654, 740, 681, 686, 800, 1,087, 3,004; 19 = 8, 6, 11, 93, 242, 648, 1,296, 3,015; 20 = 1, 1, 26, 192, 1,037, 2,291, 2,387, 2,613. All finishers: 9,011 / 7,270 / 15,091 (17 by sticker-count rule in this query: 9,011 per nonpayer doc).
Reading: 17 finishes through the week (paid Jokers from d−7, Market d−7…−5); 19 is compressed into the last 3 days; 20 starts at d−4 (Puzzle event Jokers) and spreads over the last 4 days.

## 2. Dice — last album vs spend so far as predictor of the album spend group (SQL: claude/dice_predictor_queries.sql, 15.6 GB)
Same method as Disney D5b / Domino Dom6: share of album revenue whose actual group ($/day ≤2 / 2–5 / 5–20 / >20) is predicted right; curve from the other album; players present before the checkpoint.
| % of album | 61 hist / cur | 63 hist / cur |
|---|---|---|
| 10% | 58.9 / 49.2 | 58.6 / 51.1 |
| 25% | 58.6 / 62.4 | 58.2 / 63.2 |
| 50% | 58.4 / 75.3 | 58.0 / 74.6 |
| 75% | 58.4 / 86.2 | 58.0 / 86.3 |
Same pattern as Disney and Domino: history flat (~58%), current spend wins from 25% of the album. At 10% history is better in Dice (59 vs 50).

## 3. Joker fills on the gate, last 14 days (SQL: claude/joker_fills_gate_queries.sql; Disney 50.0 GB, Domino 20.8 GB)
All players, new stickers filled by a Joker, by route (bought / Market / other gameplay) and sticker type.
- **Disney 14:** other-gameplay Jokers 2.1–3.4K fills a day all along; they fill other Royals 290–410 a day but **Royal 131 only 1–48 a day until d−4**. R131 by Joker: d−4 197 (Market 162), d−3 2,089, d−2 6,306, d−1 15,696.
- **Disney 15:** R131 by gameplay Joker 39–135 a day from d−11 (Sugar Rush release), 1,522 at d−4; paid Jokers 500–900 a day d−8…−5 (R131 70–116 a day).
- Reading (Known for counts): before d−4 the gate sticker is essentially not available to Jokers in album 14 → answers the tangled "check first" question; the late tool and the late gate are the same constraint there.
- **Domino 19:** gameplay Jokers 120–270 Royal fills a day until d−10, then 4.2K at d−9 (event), 3.0–3.7K d−8…−7; paid from d−6. **Domino 20:** gameplay Jokers fill 400–900 Royals a day all along, 2K at d−5, 9K at d−4.
- Revised "days with nothing that moves the gate" (last new rare for far middle payers → Joker can fill gate): Dice 0, Domino ~1 (19) / 0 (20), **Disney ~7**. The earlier Domino "~3" assumed the paid sale only.

## Deck (v42)
- Ch2: q-ch3, last3days, **domino-weeks** (new: cumulative finish curves 17/19/20), closing-tools, closing-week, **routes** (×3, "Players Who Get a Wild / Joker Spend More at the End; Without One, Spend Falls by Half or More"), tangled (check answered), snap-ch3.
- Ch3: q-ch1, template, royals, goldens, goldens-week ("Why Dice Jumps: A Golden Sale 7 Days Before Close"), **royal-dip** (×3 timeline, "Only in Disney Do Players Wait a Week With Nothing That Moves the Gate"), snap-ch1.
- Moved to appendix A: dice-gate, progression, rares-pace (and earlier: history, album-effect). fixlist after open-checks.
- Ch6 predictor: three equal panels (Dice now same test).
- Section s5 description → "3 days before close".
