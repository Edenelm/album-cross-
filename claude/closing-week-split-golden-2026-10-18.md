# Closing week: closing tool bought vs gameplay, and new Goldens per day (run 2026-10-18, approved by Eden)

Scope: all players, distinct players per day, first receipt of each sticker, d = date − close (close day excluded), d −10…−1. Rule (Eden): bought with money = bought; everything else = gameplay (Market included).
SQL: `claude/closing_week_split_golden_queries.sql`. Scans: Dice 17.4 GB, Domino 24.5 GB, Disney 54.6 GB.
QA: Dice 63 bought Wilds and Domino 19 bought/gameplay Jokers reproduce the earlier S1 numbers exactly; Disney 14 bought + Market = the earlier "bought or Market" line.

## Why the Dice slide had no gameplay-Wild line
The earlier S1 counted only Wilds with a `Pricing%` pack (bought). Event Wilds (Trail final reward, Blast grand prize, Bonus Wheel) were never counted per day. Now added.

## Closing tool, players per day (d −7 … −1)
| Game / album | Bought | Gameplay |
|---|---|---|
| Dice 63 | 4,659 · 8,683 · 6,985 · 9,808 · 13,427 · 14,569 · 14,745 | 18,498 · 188 · 43 · 31 · 9,850 · 20,720 · 19,188 (d−8: 49,314) |
| Dice 61 | 4,271 · 6,303 · 5,803 · 8,560 · 12,006 · 12,879 · 13,110 | 9 · 8 · 2,813 · 11 · 8,206 · 39,477 · 38,129 |
| Domino 19 | 26 · 613 · 1,440 · 1,659 · 1,768 · 772 · 961 | 8,945 · 5,933 · 3,894 · 3,644 · 9,455 · 19,584 · 35,628 |
| Domino 17 | 1,989 · 1,046 · 2,982 · 3,353 · 3,245 · 2,268 · 1,706 | 9,516 · 9,345 · 7,846 · 4,337 · 1,588 · 3,142 · 4,567 |
| Disney 14 | 1 · 0 · 0 · 3 · 0 · 4,360 · 8,825 | Market 4 · 2 · 3 · 248 · 3,364 · 8,909 · 23,402; other 3,152 · 2,650 · 2,590 · 2,497 · 2,104 · 3,018 · 5,417 |
| Disney 15 | 584 · 512 · 532 · 201 · 4,198 · 4,709 · 8,810 | Market ~0 · 0 · 0 · 0 · 180 · 8,845 · 18,610; other 3,619 · 3,436 · 2,938 · 5,515 · 5,167 · 6,888 · 11,192 |

Facts:
- Dice event Wilds come in bursts (album 63: 49K at d−8, then ~0 for d−6…−4). In the last 2 days more Dice players get a gameplay Wild than a bought one, but finishers close mostly with bought Wilds (69% vs 17% of finishing stickers, album 63).
- Disney gives ~2–3.5K gameplay (non-Market) Jokers a day all week; the paid sale opens d−2 (14) / d−3 (15). Which stickers those early gameplay Jokers fill (and whether they can fill Royal 131) is not measured → Needs Validation.

## New Goldens, players per day (d −10 … −1), bought / all Golden takers
- Dice 63 bought: 19.5K, 13.4K, 12.3K, **44.7K (d−7)**, 30.7K, 24.3K, 43.5K, 29.7K, 18.8K, 15.8K; share 5–6% until d−8, 16–22% after. Album 61: 13K → 71K at d−7, 72K at d−4.
- Domino 19 bought: 2.9–7.8K a day, 3–8% of Golden takers (album 17: 5–11K, 2–9%).
- Disney 14 bought: 4.2–20K a day, 1.3–7%, rising to 7% on the last day (album 15: 3.9–18K, 1–6%).
- Gameplay Golden takers fall in all games as albums fill (Dice 63 327K → 87K; Disney 14 647K → 199K; Domino 19 peaks 186K at d−7, ~105K at the end).
- All Goldens, not only gate Goldens. Domino purchase rule not validated on Goldens.

## Deck
v32: `closing-week` rebuilt (bought solid vs gameplay dashed in all games; title "Dice Sells the Closing Tool All Week; Disney Only in the Last 2 Days"; Royal 131 line removed, it stays on `tangled`). New slide `goldens-week` after `goldens` in Chapter 3: "Goldens Come From Gameplay; Only Dice Sells Them at Scale".
