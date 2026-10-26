# Conflicts, resolutions and open decisions (built 2026-10-26; patched 2026-10-26 after the main pull: PRs #30/#31)
The rule is the register (`decisions-definitions-register.md`). It wins every conflict (CLAUDE.md "Start here" 3). Below, R means resolved and O means open (Eden decides).

## Conflicts
| # | Conflict | Resolution | Source |
|---|---|---|---|
| C1 | Finisher = 144 at end of close day vs on close−1 | R: end of the close day | register; c/finisher-recount-2026-10-19.md |
| C2 | Payer with or without the close day | R: includes the close day | c/payer-close-day-2026-10-20.md; register |
| C3 | Album segment definitions differ by doc | R: codes 1–7 as in register | register |
| C4 | Target "30% of album revenue" | R: restated as finishers = 20/23/24% of game purchase revenue (Dice/Domino/Disney) and about 10% of payers. O: targets per group. The "effort" framing was not adopted: c/dice65-end-2026-10-24.md has only "effortless", and the worktree uses "effort" for 3 vs 4–5 missing | CLAUDE.md line 31; register |
| C5 | Domino comparison albums 17/19 vs 19/20 | R: 19/20, with album 20 shown alone when it differs; 17 is history only (register line 9, 10-21). Line 8 is an old row that still says 17/19: fix it (D11). **Re-checked 10-26 on the merged register: still NOT fixed** (only change: +1 row, dormant 10-25). Topic 6 uses a 3-album set: Dice 59/61/63, Domino 17/19/20, Disney 12/14/15 | register lines 8–9; CLAUDE.md line 30; c/topic6-calendar-neutral-return-2026-10-24.md |
| C6 | Ranges vs averages across albums | R: show ranges when albums differ. Topic 6 adds 3-album averages ("agreed 3-album set") as a second measure | CLAUDE.md; c/topic6-normal-week-check-2026-10-24.md |
| C7 | "~120K Disney potential" in old notes | R: gone from the current INDEX; not to be quoted. The only "~120" left is 120 finishers a day in c/payout-mixpanel-def-2026-10-20.md | INDEX.md |
| C8 | days_milestone as a rare source | O, history only. It appears only in old root files: topic5_rare_sources_queries.sql, royal-sources-layer-mapping, endgame-last-week, domino-album20-royal-sources, topic5-rare-sources | root files |
| C9 | Topic 6/7 and early-finishers docs take end status on close−1 (Dice daily table), not end of close day; Part 1 slide 34 uses 2–3 short at close-day end | R: both are valid cuts, but say which one on the slide. Do not mix numbers across cuts | c/topic6-short-payers-2026-10-24.md |
| C10 | Latest handoff: CLAUDE.md says 10-25, but 10-26 exists | R: c/next-session-prompt-2026-10-26.md is the latest; both were written 10-24. No handoff covers the 10-25 work (topic 7, story checks) or the 10-25/26 Domino dx work (now merged; INDEX.md rows are its only summary) | file headers |
| C11 | INDEX.md stale (header "updated 2026-10-21"; about 65 docs from 10-19 to 10-25 missing) | R: route through MASTER-INDEX.md; INDEX.md is history. 10-26 merge added 9 Domino dx rows, header still 10-21 | INDEX.md line 1 |
| C12 | Disney 2–3-short finish "25% vs 42–51%" | R: replaced by topic 4 last-8: 16–25% everywhere | c/topic4-last8-finish-2026-10-22.md |
| C13 | "Dice cuts payout least after close" (a6s7, t6j, t6k) | R: album 63 only. Over 3 albums Dice −10% and Domino −11% are about the same, and Disney −16% cuts most. Fix the wording on a6s7/t6j/t6k | c/topic6-payout-3albums-2026-10-24.md |
| C14 | Two Google decks: ALBUM END (1vtw…) vs "Copy of ALBUM END" (1rUG…) | O: topics 0–3 slides were built in the copy (10-22), later work in ALBUM END. Check in the live deck which one holds what | data-story-review line 35; c/next-session-prompt-2026-10-23.md |
| C15 | Old finisher numbers; Dice first-album fix | R: use the recount. Old Dice standard-population shares are about ×0.84–0.86 of the right values | c/finisher-recount-2026-10-19.md; data-story-review line 18 |
| C16 | Decision deck and spec (10-21) predate the topic review and use Domino 17/19 in places | R: reference only; numbers in topic cards win | c/final-analysis-spec-2026-10-21.md |
| C17 | "Album 20's easier end raised payer finishers +44%" (spec §4 ch7, domino-cases) reads as causal | R: say "fits, not proven". The end lift cannot be attributed to the 3-sticker gate (week before as strong; 18 stronger) and 20 is a slight ARPDAU recovery, not an improvement | c/domino-dx-end-lift-2026-10-26.md; c/domino-dx-t1-story-check-2026-10-26.md |
| C18 | "The Domino easy gate holds 3 Goldens" (10-23 prompt) | R: album 19 only (Easy 5 = 2 Royals + 3 Goldens). Album 20 Easy = Hard = 3 (2 Royals + 1 Golden). Gate differs by album | c/domino-dx-map-2026-10-25.md |
| C19 | c/rares_by_time_median_2026-10-26.sql names results doc rares-by-time-median-2026-10-26.md, which is not in main or any worktree | O: rerun or ask Eden where the numbers went | sql header |
| C20 | "Two Puzzle Jokers" in album 20 (spec, older docs) | R: two end puzzles: JokerPuzzle (to close−4, mostly 1 Joker) + SummerFeverPuzzle (last 4 days, 60% used 2) | c/domino-dx-t4-2026-10-25.md |
| C21 | Golden-buy-share slide: main has d20/s15 (10-23); branch has the Dice 65 / Domino 20 / Disney 15 rerun | O: pending D-W2 merge; then golden_buy_share_d20_s15 is superseded | c/golden-buy-share-d65-d20-s15-2026-10-25.md (branch) |

## Decisions for Eden (open)
1. **D1:** targets per group (spend level or experience), and how to weight the cross-game target.
2. **D2:** keep, rewrite or replace s6a (slide 59, "misleading"). s6c/s6d tell the same story more fairly.
3. **D3:** are non-paying finishers (Domino RV path) a group we want, or a leak?
4. **D4:** Dice top-payer prize test. Pick the arm (2-day prize vs 250K / 300K) and the sizes (t7d / t7e / t7h are alternatives).
5. **D5:** test order (t9_slide proposal: evidence from a real test first; the Disney end tests share players, so run them one after another).
6. **D6:** review topic 7. It has not been reviewed yet, and t7 has 8 slides across two scripts.
7. **D7:** product facts still unknown: are Disney Market tokens bought or earned? Which Dice Trail layer gives the Wild?
8. **D8:** check in the live deck every row marked "unv", the stand-move duplicate slide, and the leftover vipa_slide_lg2 shape.
9. **D9:** replace the CLAUDE.md "Start here" with index/CLAUDE.md.proposed-start-here.md, which points to the 10-26 prompt and to MASTER-INDEX instead of INDEX.md.
10. **D10:** after D9, keep INDEX.md as history or delete it.
11. **D11:** fix register line 8, the comparison-album row: drop Domino 17/19, or mark it history. Still open after the 10-26 merge.

## Worktree decisions (.claude/worktrees; never open them for normal work)
- **D-W1, domino-focused-presentation-090d0d: RESOLVED 10-26.** Merged to main (PRs #30/#31): 35 files + INDEX.md (+9 rows) + register (+1 row). Main kept the 090d0d slide_domino_chapter_2026-10-26.py (14,593 B, same md5). The trove-install-script-c45ac8 variant (15,594 B) was not merged → drop with the worktree.
- **D-W2, branch claude/albums-seen-october (worktree recursing-villani-518ad8):** pushed, NOT merged (5 commits, 10 files, 10-25): albums-seen-october (slide 11/12), cohort-end-lift-pooled (slide 16), golden-buy-share-d65-d20-s15, median-missing-at-close (slide 23), newer dice65-pu-trail (+Q5 PU/PAU: 63 +7%, 65 −8%). Merge?
- **D-W3, paid-player-album-time-245a75:** branch merged, but payer-time-to-first-album-2026-10-21 (.md/.sql, v2) was never committed (untracked in the worktree). Commit or drop?
- **D-W4, continue-session-20c65f:** uncommitted topic3-reruns-2026-10-22 with SQL. It found "nothing changes" plus 19/20 sources. Probably abandoned: drop?
- **D-W5, 0990b2:** only unique file is claude/excel/README.md (Excel data files, 10-21). Main has no excel folder. Copy it or drop it?
- **The other 18 worktrees** hold only older copies of main files and can be deleted when Eden wants: fb8c4f, 084dc7, f3d3c4, 692f62, 08d705, bbb29a, f81bfe, 57e8e2, 74c990, eb9da8, d058de, e6e02c, e72d71, f58756, 6bf421, b07b6c, c19416, 58fb22.
