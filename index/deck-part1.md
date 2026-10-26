# Part 1 deck map (Google Slides 1WS07a_8A_IDJ1HndTBG34qHD5-sJx8WNDzhVAkv3zwQ), plus v82 / Part 2
Part 1 is the Google Slides export of evidence deck v82, from the opening to chapter 7. Part 2 (1CQVnRMr…) holds chapter 8, the method and the appendix.
- Only the positions below are confirmed by repo files. Every other v82 code has its Part 1 position marked **unv: check live deck**.
- The per-slide Finding / Why / Action text is in c/deck-review-actions-2026-10-21.md, "Lines per slide" (v81–82). Final slide lines are in c/final-deck-bottom-lines-2026-10-21.md.
- Numbers on these slides are from 10-20/21. Where a topic card has a newer number, the card wins, and the slide is marked "replaced" in that card.

## A. Part 1 slides confirmed by repo files
| # | Code | Title / message | Key numbers | Card | Source doc | SQL | Script | PNG | Status |
|---|---|---|---|---|---|---|---|---|---|
| 24 | closing-week | Dice Sells Wilds All Week; Domino Gives Jokers; Disney Sells Only at the End | Dice 5K→15K buyers a day | t4 | c/closing-week-split-golden-2026-10-18.md; c/closing-week-pct-payers-2026-10-24.md | c/closing_week_split_golden_queries.sql | – | – | live |
| after 24 | p24fix | % of payers using the closing tool per day (Dice 63 / Domino 20 / Disney 15, one scale) | – | t4 | c/closing-week-pct-payers-2026-10-24.md | c/closing_week_pct_payers_2026-10-24.sql | slide_p24_fix_2026-10-24.py | part1-p24fix.png | live (10-24) |
| after p24fix | p24rec | Test: Disney Joker from 7 days out, sold vs event reward | – | targets | c/closing-week-pct-payers-2026-10-24.md; c/domino-movie-twister-purchases-2026-10-24.md | c/domino_movie_twister_purchases_2026-10-24.sql | slide_p24_rec_2026-10-24.py | part1-p24rec.png | proposed |
| 31 | keep-playing | Far middle payers stay active after their last new rare but spend little. Edited 10-22: Finding 51–72% → 46–72%; Why 10–22% → 8–22%; Dice bar 51% → 46% | 46–72% active, 1–3% of revenue | t4 | c/data-story-review-2026-10-21.md §Topic 3 (fixed numbers: c/topic4-dice-far-rares-fixed-2026-10-22.md) | – | – | part1-slide31-2026-10-22.png | live, updated |
| 34 | heavy-missers | $20+ payers 2–3 short at close-day end, last 4 days vs usual. A different cut from topic 6 (close−1, 1–2 short) | <1% of payers, 7% / 7–8% / 3–4% of revenue | t6 | c/topic6-short-payers-2026-10-24.md (explains the difference) | – | – | – | live (different cut, see C9) |
| 36 | payout-near | Payout days 1–3 of next album vs mid-album, by end status (album prizes left out) | finishers −12–19% Domino/Disney, Dice +3–4% | t6 | c/topic6-payout-by-status-2026-10-24.md; c/topic6-payout-prizes-by-level-2026-10-24.md | c/topic6_payout_by_status_2026-10-24.sql | – | – | live; **replaced in meaning** by t6k/t6l (with prizes) |
| 38–41 | domino-3albums · domino-easier · jokers · jokers-test | Domino 20 easier end (two Puzzle Jokers): paying finishers +44%, spend held; 41 = test one vs two Puzzle Jokers | 7,039 → 10,148; 520 closers 2.3% | domino-cases | c/domino-easy-end-pays-twice-2026-10-24.md; c/domino-easy-gate-end-2026-10-21.md | (in docs) | – | – | live; order within 38–41 unv |
| 42–46 | seg-return · prize-tier · prize-return · prize-domino · prize-rec | Dice 200K prize (chapter 7) | 12.6K→32.7K tier; 13% vs 24% rolls back | t7 | c/seg7-top-payers-2026-10-20.md; c/topic7-dice-prize-2026-10-25.md | c/seg7_top_payers_dice.sql | – | – | live; numbers superseded by ALBUM END t7a–t7h (card t7) |
| 47 | Disney test 1 | First proposed Disney end test | – | targets | c/domino-easy-end-pays-twice-2026-10-24.md line 36 | – | – | – | unv |

## B. Other v82 codes (Part 1 position unv)
Each line gives the code, its card and the key number from deck-review-actions.
- **Opening and structure.** structure (t4; 12 Supers 8% on days 31–36 vs 7 Royals) · exp-mix (tenure; 96/88/88% past first album) · exp-end (tenure) · end-growth (t1; Disney 11–15 −1% to +8%) · payout-shape (t6; ×2.5–2.9 last 4 days) · end-worth (t1; ≈2% of album revenue; ≤$0.7M for Disney).
- **Spend levels and standing.** spend-lens (t5; 54–56% still 4+ away) · target (targets; 5–11% of payers, 17–23% of revenue) · stand4 (t2; 41–53%) · progression (t4) · gates (t4; 2–11% hold the gate sticker).
- **Rares.** rare-timeline (t3; 14/30/35%) · rare-sources-mix (t3; Domino orange split 10-26: c/domino-rare-sources-split-2026-10-26.md) · rare-mechanics (t3).
- **The last days.** last3days (t4; 88/91/99%) · tool-reach (t2; 23–92 vs 2–9 per 100) · half-completions (t2; 42/51/25%) · dryness (t5; 39K players, 21%) · tangled (t3; Royal 131).
- **Free path and returns.** rv-path (nonpayers-rv; 43% of Domino 20 finishers never paid) · staircase and finishers-hold (t6) · disney-finishers (t1; 2.1×).
- **Tests and targets.** tests (targets; six tests) · targets (targets; Dice 11.2% vs 10%).
- Several numbers in these rows were corrected later: the finisher numbers (C15) and Disney "25% vs 42–51%" (C12). Check the card before quoting.

## Part 2 / v82 artifact / decision deck
- **Part 2:** chapter 8 (targets), method, appendix. There is no slide list in the repo, so all rows are **unv: check live deck**.
- **v82 artifact (96 slides):** generators are c/deck_v2_*.py and c/deck_gen_x3.py. The slide list is in c/deck-structure-2026-10-20.md.
- **Decision deck (22 slides, 10-21):** c/final-deck-bottom-lines-2026-10-21.md. It is reference only and uses Domino 17/19 in places (C16).
