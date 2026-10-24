# Topic 9: Disney test sizes, locked stickers and Goldens (2026-10-24)

SQL: `claude/topic9_disney_test_sizes_2026-10-24.sql` (solitaire-dreams-411507, 56.6 GB, two runs).
Population: Disney 14 / 15 standard-population payers (not first album, not excluded, login ratio ≥ 0.5 on the last row before close, row on close−1, paid on any album day including close).
Album revenue = album spend from album start to close−1. % = share of these payers / of their album revenue.
End status = unique set stickers by the end of the close day (144 = finished, 141–143 = 1–3 short).

## (a) Locked-sticker test (tx_gate): who it touches
| | Disney 14 | Disney 15 |
|---|---|---|
| All payers | 371,049 · $40,371,383 | 325,842 · $36,513,467 |
| Finished | 21,518 (5.8%) · 22.7% of revenue | 18,967 (5.8%) · 24.7% |
| End 1–3 short | 75,805 (20.4%) · 38.3% | 52,655 (16.2%) · 37.0% |
| End 4+ short | 273,726 (73.8%) · 39.0% | 254,220 (78.0%) · 38.3% |

- The change reaches every payer. The group it is aimed at, those who end 1–3 short, is 16–20% of payers and 37–38% of album revenue.
- From the old gates slide (not rerun): 86–97% of near-finishers miss a locked sticker.

## (b) Golden test (tx_gold): payers missing a Golden 10 days before close
- Run 1 counted all 24 Goldens: 100% of payers miss one, because 2 Goldens are locked to the end. Not useful.
- Run 2 counted only the 22 Goldens already out at close−10. A Golden counts as out when at least 1% of these payers hold it by the end of close−10. The 1% is my threshold.

| Released Goldens missing at close−10 | Disney 14: players · % payers · % revenue · finish rate | Disney 15 |
|---|---|---|
| Any (1+) | 358,358 · 96.6% · 85.8% · 5.3% | 288,971 · 88.7% · 57.2% · 4.1% |
| 1 | 17,746 · 4.8% · 12.8% · 15.0% | 27,206 · 8.3% · 16.8% · 12.8% |
| 2 | 35,512 · 9.6% · 19.0% · 10.8% | 25,480 · 7.8% · 8.7% · 7.9% |
| 3 | 57,873 · 15.6% · 22.2% · 8.4% | 39,279 · 12.1% · 9.3% · 5.3% |
| 4+ | 247,227 · 66.6% · 31.8% · 3.0% | 197,006 · 60.5% · 22.4% · 2.1% |

- **Fact:** almost every Disney payer still misses a Golden that is already out 10 days before close: 89–97% of payers, 57–86% of album revenue.
- **Fact:** 1–3 missing at close−10 is 28–30% of payers and 35–54% of album revenue. Their finish rate is 5–15%, against 2–3% for those missing 4+.
- **Choice for the test:** "missing a Golden" covers almost everyone. A narrower entry rule, such as 1–3 released Goldens missing, gives a clearer target group. The rule is a management choice.
- **Caveat:** albums 14 and 15 differ a lot in the revenue share of those missing 1–3 (54% vs 35%), so the size depends on the album.
