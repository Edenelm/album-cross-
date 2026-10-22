# End lift by number of albums experienced, full history groups (2026-10-22)

Eden asked for the end lift in the same groups as her revenue slide (1 / 2–3 / 4–6 / 7–12 / 13+). SQL: `claude/end_lift_by_experience_full_history.sql` (Dice 81 GB, Domino 75 GB, Disney 67 GB).
Population (as end-growth): all players who received the album, active days, close day excluded, game exclusions. Albums seen = distinct albums with rows in `user_daily_album` up to and including this one (history: Dice from 2023-11-07, Domino from 2024-06-10, Disney from launch), so 13+ is a floor. Lift = last-4-days ARPDAU ÷ whole-album ARPDAU − 1, per album; slide = average of the two albums. Share = group's album-table spend ÷ game purchase revenue during the album (opening-facts denominators).

| Albums seen | Dice 61 / 63 → avg | Domino 19 / 20 → avg | Disney 14 / 15 → avg |
|---|---|---|---|
| 1 | +17% / +21% → **+19%** (12% of rev) | +10% / +6% → **+8%** (12%) | −3% / +7% → **+2%** (11%) |
| 2–3 | +10% / +16% → **+13%** (23%) | +19% / +22% → **+20%** (19%) | −6% / +1% → **−2%** (23%) |
| 4–6 | +18% / +19% → **+19%** (13%) | +15% / +18% → **+16%** (21%) | +1% / +4% → **+2%** (33%) |
| 7–12 | +11% / +23% → **+17%** (11%) | +18% / +23% → **+20%** (27%) | 7+: +2% / +7% → **+4%** (30%) |
| 13+ | +15% / +24% → **+20%** (40%) | +18% / +22% → **+20%** (19%) | (in 7+; 24K active days in album 15) |

- Fact: in Dice and Domino every experience group lifts at the end, the longest-tenure (13+) as much as the rest; in Disney no group lifts more than +7% in either album.
- Disney matches the earlier exp-end slide (same 1 / 2–3 / 4–6 / 7+ split: −2% to +4%). Dice / Domino now use full history instead of "since Apr 2025 + installed-before bucket".
- ARPDAU by group (whole album): Disney 1st album $1.25 / $1.50 vs 7+ $0.72 / $0.78; Dice 1st $1.64 / $1.49 vs 13+ $1.03 / $1.06; Domino flatter ($0.71–0.97).
