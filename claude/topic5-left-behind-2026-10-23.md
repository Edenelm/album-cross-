# Topic 5: those left behind — reruns on the fixed populations (2026-10-23)

Eden: "run all three". SQL: `claude/topic5_left_behind_2026-10-23.sql` (Disney 28 GB `solitaire-dreams-411507`, Domino 12 GB `domino-dreams-dbt`, Dice 107 GB `dice-dreams-dbt`).

## Definitions
- Population: standard-population payers (not first album — Dice by history row; not excluded; login ratio >= 0.5 on the last row before close; row on close-1; paid on any album day incl. close). Albums Dice 61/63, Domino 19/20, Disney 14/15.
- End status = unique set stickers on close-1 (Dice daily table does not update stickers on the close day, so close-day finishers count as 1+ missing here).
- Heavy near-missers = 2-3 missing on close-1 and album revenue before close / album days >= $20 a day (same threshold as the old slide).
- Shares: of all standard-population payers and of their album revenue (album days before close).
- "Before" = days 21-8 before close; "last week" = days 7-1. $ per day = per player-day; play per active day (Dice rolls out, Domino coins spent, Disney levels played). Finishers: days after their own finish day are left out.
- Caveat: groups are defined by where players END, so players who slowed down are more likely to be in the far groups (selection, not cause).

## Results (per album; change = last week vs before)
| Album | Group | Players | % of payers | % of album revenue | Active days | $ per day | Play per active day | Paid in last 14 days |
|---|---|---|---|---|---|---|---|---|
| Dice 61 | Finished | 15,957 | 8% | 23% | 93 → 96% | $7.37 → $14.62 (+98%) | +105% | 99% |
| Dice 61 | 4+ missing | 109,759 | 56% | 31% | 86 → 80% | $1.60 → $0.83 (−48%) | −25% | 62% |
| Dice 61 | Heavy 2-3 missing | 1,638 | 1% | 11% | 96 → 93% | $38.92 → $25.05 (−36%) | −33% | 98% |
| Dice 63 | Finished | 20,965 | 10% | 28% | 93 → 95% | $7.40 → $14.23 (+92%) | +92% | 100% |
| Dice 63 | 4+ missing | 69,469 | 34% | 18% | 81 → 70% | $1.50 → $0.56 (−63%) | −36% | 52% |
| Dice 63 | Heavy 2-3 missing | 1,838 | 1% | 11% | 95 → 93% | $39.29 → $22.15 (−44%) | −38% | 98% |
| Domino 19 | Finished | 5,322 | 4% | 22% | 95 → 97% | $11.91 → $16.99 (+43%) | +47% | 96% |
| Domino 19 | 4+ missing | 98,632 | 83% | 49% | 86 → 80% | $1.30 → $0.75 (−42%) | −28% | 60% |
| Domino 19 | Heavy 2-3 missing | 489 | 0.4% | 6% | 94 → 91% | $35.73 → $23.78 (−33%) | −29% | 100% |
| Domino 20 | Finished | 8,557 | 8% | 31% | 94 → 97% | $9.33 → $14.63 (+57%) | +78% | 96% |
| Domino 20 | 4+ missing | 58,113 | 54% | 22% | 83 → 77% | $0.84 → $0.38 (−55%) | −21% | 52% |
| Domino 20 | Heavy 2-3 missing | 457 | 0.4% | 6% | 94 → 92% | $34.30 → $18.56 (−46%) | −33% | 98% |
| Disney 14 | Finished | 14,038 | 4% | 17% | 95 → 97% | $11.06 → $15.59 (+41%) | +21% | 98% |
| Disney 14 | 4+ missing | 285,654 | 77% | 43% | 88 → 84% | $1.38 → $0.78 (−43%) | −19% | 57% |
| Disney 14 | Heavy 2-3 missing | 2,731 | 0.7% | 9% | 96 → 91% | $33.99 → $23.78 (−30%) | −30% | 100% |
| Disney 15 | Finished | 13,185 | 4% | 18% | 95 → 97% | $12.29 → $16.68 (+36%) | +43% | 99% |
| Disney 15 | 4+ missing | 263,164 | 81% | 43% | 89 → 85% | $1.35 → $0.83 (−39%) | −8% | 59% |
| Disney 15 | Heavy 2-3 missing | 2,500 | 0.8% | 10% | 96 → 90% | $39.28 → $23.84 (−39%) | −24% | 100% |

Other groups (1 missing; 2-3 missing, all) are in the SQL output: 1 missing spends more in the last week (+23% to +55%); 2-3 missing spend about the same or less (+3% to −33%).

## Reading
- **Fact (A, keep playing):** far payers (4+) stay around: 70-85% of days active in the last week, but they spend 39-63% less a day than the week before; only 52-62% pay anything in the last 14 days ($8-16 per player).
- **Fact (A):** they are a big part of the money: Dice 18-31%, Domino 22-49%, Disney 43% of album revenue.
- **Fact (B, heavy near-missers):** 0.4-1% of payers, but Dice 11%, Disney 9-10%, Domino 6% of album revenue (old slide: 10.5 / 9.3 / 4.5-5.6% — same picture on the fixed base).
- **Fact (C, give up):** in the last week heavy near-missers spend 30-46% less a day and play 24-38% less, while their activity barely drops (90-93% of days). Finishers do the opposite (+36% to +98% spend).
- **Interpretation:** the players who will not make it pull back in the last week — they still log in but stop spending and play less. Consistent with giving up on the album (not tested; the old win-rate check was not rerun).
- Old v82 numbers to replace: keep-playing ("near 93-94%, far about half the days / 72% Disney" → far 70-85% active in the last week), heavy-missers shares above, give-up Disney "$35 → $22" → $34-39 → $24.
