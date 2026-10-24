# ARPDAU slides with the new/veteran share held fixed, all three games (2026-10-25)

Eden asked to fix the "Avg Arpdau Whole Album" and "Avg Arpdau Last 4 Days" slides for the Disney finding (player mix), using the same method in every game.
SQL: `claude/mix_fixed_arpdau_2026-10-25.sql` (Dice 81 GB, Domino 80 GB, Disney 67 GB).
Population as the slides: all players who received the album, active days, close day excluded, game exclusions.
Groups = albums seen (1 / 2–3 / 4–6 / 7+). "If the share of new vs veteran players stayed as in the first album" = each album's ARPDAU per group, weighted by the first album's share of active days.

| Game (albums) | Whole album: actual | Whole album: same new/veteran share | Last 4 days: actual | Last 4 days: same share |
|---|---|---|---|---|
| Dice (53 → 63) | +33% ($0.99 → $1.32) | +28% | +22% ($1.29 → $1.58) | +22% |
| Domino (15 → 20) | +6% ($0.84 → $0.89) | +6% | +14% ($0.93 → $1.06) | +11% |
| Disney (10 → 15) | −18% ($1.11 → $0.91) | **−1%** | −19% ($1.21 → $0.98) | **+3%** |

Share of active days, first vs last album (1 / 2–3 / 4–6 / 7+): Dice 12/12/7/69% → 9/17/11/63%; Domino 30/21/14/35% → 11/18/20/51%; Disney 29/36/16/19% → 6/17/34/44%.
- **Fact:** Dice and Domino barely change when the share is held fixed; their trends are real.
- **Fact:** Disney's fall disappears: −18% → −1% (whole album), −19% → +3% (last 4 days). It is the shift from new to veteran players, not a weaker album.
- Slide changes: "If the share of new vs veteran players stayed as in album X" line added under each card on the whole-album slide; notes updated on both slides. On the last-4-days slide Eden removed the added lines (left as she set it; notes updated).
