# Evidence re-check against original results + deck content v1 (2026-10-18, night)

Deck content (living doc, English): https://claude.ai/code/artifact/8ffefe07-808e-48fd-809f-34921e9e81e1
Eden's request: re-derive conclusions from the original result files (not the syntheses), and write the deck in simple, clear English.
Method: 4 read-only reviewers re-read the originals by cluster (baseline/rares/Dice gate; endgame/Disney/far players; finishers/post-completion/non-payers/Domino 19-20; segmentation) and checked v4, day-synthesis and claims-register against them. No new queries.

## Story after re-check
The albums are built the same but end differently. Disney's gap is completions, not spend. Most revenue that ends far cannot be reached at the very end; levers sit about a week earlier, and only an A/B can size them.

## Conclusions that changed (supersede claims-register / v4 / day-synthesis where they conflict)
| Earlier | Now | Source |
|---|---|---|
| Disney flat end = spend problem | Completion problem: same-stratum last-week spend ratio equal across games (e.g. 4–6 short, $5–15: 0.79/0.78, 0.80/0.75, 0.79/0.75); whole-population ratio lower due to mix (Disney far more players near the gate) + regression + album 15 baseline inflated by Royal 131 at d−11 | endgame-s1-s4 |
| Short window "proven" for completions | Hypothesis: tangled with late gate release; album 15 had early trickle yet same finish rates; Domino 19 finished 47% of 2–3 short with late paid Joker via gameplay Jokers. Precondition: can a Joker pick Royal 131 before release? | endgame-s1-s4, endgame-last-week |
| Staircase after close = cost of missing | Mostly selection (groups by end state; missing-3 already ×0.4–0.6 in last 4 days) | post-completion App. 4 |
| $20+ missing 2–3 drop after close; ~$120K/album Disney upside | Pullback starts before close (last 4 days ~61–63% of base); week after = partial recovery. "$120K" not traceable to any result — dropped. Upper bounds: excess vs $20+ finishers Disney ~$200–280K/week, vs $20+ missing-1 ~$160–180K | post-completion App. 4b/5 |
| Second Puzzle Joker: 2–3% of revenue at risk | That is the closers' total album spend; realistic extra with one Joker ≈ $10–20K (hypothesis) | domino-strong-puzzle-closers |
| Most rares from paid (MTX) events | Not supported; paid/free unknown for most sources | topic5, royal-sources-layer-mapping |
| Disney days 10–8 royal drought 15 vs ~40 per 100 | ~half the gap once normalised per rare (2.1 / 4.8 / 3.8); royals still arrive days 7–5 | middle-payers-stall |
| Current spend classifies 88% correctly | Circular after ~day 11; only day 5–11 fair (day 5: 56 vs 54–55, combined 59; day 11: 56 vs 65) | disney-segmentation-d5b |
| Domino 19 Jokers ~46% paid | Mostly gameplay by checked purchase flag (961 paid vs 35.6K gameplay on d−1) | endgame-s1-s4 round 2 |
| Domino paid Joker from 7 days | Album 17 yes; album 19 from d−5 | endgame-s1-s4 |
| "3-album history no better than last album" for Domino | Tested only in Disney | segmentation docs |
| Multipliers ×1.1–1.3 / ×1.7–2.0 vs ×1.6 / ×2.6 | First pair = to revenue-share target; second = to 10% finishers. Under final target (~10% / ≥30%) finish rate binds in Domino/Disney (10% → 43–45% revshare, upper bound) | finisher-targets |
| Small fixes | Magical Friend 10–36%; Dice $ per paying day $31–48; Disney extra finishers 7.6–11K; Domino RV ~75–150 views/day, 24–29 days; middle far 7–9% = last 7 days; v4 F2 Dice row = 2.5/6.5/8.5/7; v4 ז6 Medium tier 5 gap −8/−11, Extreme tier 0 above goal (+7/+5) | various |

## Checked and rejected (new queries, 2026-10-18)
| Hypothesis | Result | Source |
|---|---|---|
| Short albums end stronger (Eden) | Not supported. All albums opened since Apr 2025, players who received the album (also login 0.5+): end growth vs rest of album unrelated to length in Dice (corr −0.02); in Domino/Disney longer albums end higher, driven by outliers (Jan 5 holiday closes, Disney launch album, Domino 18). Absolute last-4 ARPDAU follows time, not length. | claude/album-length-end-arpdau-2026-10-18.md |
| Short Disney albums are better because they have no mid-album lull | Not supported. Disney 11/13 had the highest whole-album ARPDAU vs neighbours (+7%/+8%), but long Disney albums have no mid-album dip either; album 13's lift came from two 2-day stretches (weekend 27–28 Jun, 4 July weekend). Event calendar not checked. | claude/album-length-whole-album-addendum-2026-10-18.md |
| Data flag | Dice 49 with login 0.5+ filter: only 365K players and −9% end growth — likely broken last-row login ratio (album 51 opened a day before 49 closed). Excluded. | same |

## New sizing found in originals
- End lift worth ≈2% of album revenue; closing Disney's gap ≈$0.7M/album upper bound.
- Disney early-window population: payers ≤6 short at d−8 = 104,901 (28.3%, album 14) / 73,978 (22.8%, 15); non-finishers 95,030 / 65,136. Revenue share MISSING.
- Disney needs ≈+20K paying finishers/album to reach 10%; Dice-level end completion would add only 7.6–11K.
- Disney movers-up from level 1 ≈16% of total revenue.
- RV value Domino 20 ≈ $24–42K = 0.15–0.26% of album revenue.

## Cross-cutting caveats found
- Segmentation and Disney checks filter on login ratio on the LAST row (look-ahead → survivors).
- Topic 4c and Dice one-pager sections 1–3 include first-album payers (~20% of PU) and were not rerun on the standard population.
- Dice "peak at 2–6 albums" not robust to source table.

## Test priority (deck slide 53)
1. Disney earlier closing window (+ optional Royal source days 14–8). 2. Completion path for $20+ 2–3 short before d−4 (Disney, then Dice). 3. Dice opener for last-day finishers. 4. Domino one vs two Puzzle Jokers (paused). 5. More Super slots.

## Open (small queries / owners)
Revenue share of test-1 population (Eden: not needed for now); Domino 20 post-completion (after 20.10); Joker vs Royal 131 release (Disney team); remaining-spend validation of current-spend tier; end funnel with pre-defined groups; Disney event calendar for albums 11/13.
