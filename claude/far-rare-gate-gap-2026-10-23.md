# Far payers: last new rare vs gate open — rerun with one gate definition (2026-10-23)

**Question (Eden):** is the slide "In Disney, Far Payers Stop Getting Rares a Week Before the Gate Opens" right? Rerun on Disney 14/15 and Domino 19/20 with one gate definition.
**SQL:** `claude/far_rare_gate_gap_2026-10-23.sql` (Disney 63 GB, Domino 21 GB). Projects `solitaire-dreams-411507`, `domino-dreams-dbt`.
**Population (as the slide, MidDis / MidDom):** standard population; middle payers = P50–95 of spend so far at 75% of the album; far = 4+ missing at close−1.
**Last new rare** = day the player reached their final Royal count, days before close, revenue-weighted (as the slide) and median.
**Gate** = the scarcest Royal(s) at close (within 1.5× of the scarcest). Found from data: Disney 14 and 15 = R131 only; Domino 19 = R107 / R108; Domino 20 = R119 / R120 — matches the known gates (method check).
**Gate open** = first day on which Joker fills of the gate reach 0.1% of the standard population that day (my threshold; the fills jump from tens to hundreds/thousands, so the day barely moves with the threshold). Joker fill = new gate sticker with `collected_by_joker_flag` (flag = ever from a Joker pack; approximation).

| | Far middle payers | Their revenue | Last new Royal, days before close (rev-weighted / median) | Joker fills of the gate per day (whole population), from day 9 to 1 | Gate open (0.1%) | **Gap** |
|---|---|---|---|---|---|---|
| Dice 61 / 63 (topic-4 rerun, 2026-10-22) | 39,324 / 23,793 | $3.75M / $2.56M | 3.4 / 4.7 (Super) | — (studio: Wild sale from 7) | 7 | **0** |
| Domino 19 | 38,622 | $4,232,069 | 10.6 / 8 | 479, 1,383, 1,941, 1,279, 999, 1,058, 2,626, 5,309, 10,186 | 9 | **~2** |
| Domino 20 | 15,370 | $1,557,056 | 11.7 / 9 | 122, 175, 410, 418, 1,166, 4,588, 10,734, 9,021, 7,268 | 7 (big from 5–4) | **~5** |
| Disney 14 | 106,720 | $11,318,716 | 12.8 / 14 | 5, 1, 3, 1, 7, 130, 1,777, 5,315, 13,590 | 3 | **~10** |
| Disney 15 | 98,129 | $10,325,260 | 10.5 / 10 | 10, 110, 83, 57, 86, 1,241, 2,586, 5,540, 9,718 | 4 | **~6–7** |

Far middle payers' own Joker gate fills stay tiny even after the gate opens: at most 0.6% a day (Domino 19 1.8% on the close day, Disney 14 1.2%).

## Reading
- **Fact:** far middle payers get their last new Royal 10–13 days before close in Disney and Domino, vs 3–5 days in Dice. This holds in all four albums.
- **Fact:** Disney's gate opens 3–4 days before close in both albums → the gap is ~10 days (14) and ~6–7 days (15). "A week" holds as a round number for Disney (6–10 days).
- **Change vs the slide:** Domino 20 is NOT 0 — its gate (R119/R120) opens 5–7 days before close, so the gap is ~5 days, close to Disney 15. The old "0" counted Joker fills of any Royal, not the gate. Domino 19 ~2 days (slide said ~1).
- **Fact:** even after the gate opens, far middle payers almost never fill it (≤1–2% a day): 4+ missing, the gate is not what they lack first.
- **Interpretation:** the robust message is the first fact — in Domino and Disney the far payers' Royals stop ~10–13 days out, a week earlier than in Dice; the gate-open day adds detail but differs by album.
- Dice not rerun with this method (its gate open = studio sale timing); Dice last-rare timing is from the topic-4 rerun.
