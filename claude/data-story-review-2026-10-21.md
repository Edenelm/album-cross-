# Data-story review, topic by topic (started 2026-10-21)

Eden is rebuilding the deck herself. We go one topic at a time: question → findings (from the original queries and docs) → meaning → one-line message → which slides show it today (evidence deck v82, decision deck, spec deck) and what to change. Next topic only when Eden says so.
Topic map: 0 definitions and denominator · 1 where the money is in the album · 2 who finishes and who is far · 3 rare supply · 4 how the album closes · 5 those left behind · 6 after the album · 7 three natural cases · 8 targets · 9 recommendations and test order. Targets are not discussed before topic 8 (Eden).

## Topic 0: definitions and denominator (closed 2026-10-21)
**Message (approved):** every number is counted on the same players, the same albums and the same denominator, and the slide says who it is about.

**Decisions**
- Domino base albums = 19/20 everywhere; album 20 is shown on its own when it differs (Eden). Album 17 is history only.
- Dice "first album" = no row in any earlier album in `user_daily_album`, not `user_past_album_count` = 0 (Eden approved the fix). Results: `first-album-finish-rate-2026-10-21.md`.

**Findings to keep**
- Domino 17/19 vs 20 tell different end stories: 4+ missing 33% (17/19) vs 16% (20) of game revenue; finishers 22% vs 27%.
- The same metric appears on different populations (Disney end lift −2 to +4% / −1 to +8% / −3 to +3%; Dice prize group 1,427 vs 1,863; Disney test-1 scope 62–63% vs 49–50% = old vs new basis). Each slide must say who.
- Finish rates are of payers past their first album with login ratio ≥ 0.5 and a row on close−1, not of all payers.
- First-album players barely change finish rates (all games within 0.6 points); they add 1–3 points to the finishers' revenue share in Domino / Disney. Domino 20 first-album payers finished 15% vs 9.5% (1,174 finishers; hypothesis: the easier end).
- Dice label fix: 19–22K returning payers were missing from the Dice standard population. Finish rate unchanged (10% / 12%); finishers' share of game revenue 18% → 21% (61) and 21% → 26% (63); every Dice standard-population revenue share was about x0.84–0.86 of the right value. Dice payers now 78–82% of game revenue, like Domino / Disney.

**Slides (as of 2026-10-21)**
- v82 #4 "How to Read the Numbers": the definitions slide. Missing: which slides use Domino 17; that rates are of the standard population. Too much text (game colours card).
- v82 #2 "The Story in One Slide": Domino finisher range 20–27% already on 19/20. Dice range 18–21% is too low after the fix (21–26%).
- v82 #60 "Fix These Before Segments Drive Targets": add the Dice first-album column issue.
- Decision deck #3 "At the End, a Third of the Money Is 4+ Stickers Away": Domino bar is on 17/19 (against the decision); Dice bar on the old Dice population. Content is topic 2.
- Decision deck #19 "What Starts Now Without a Test…": definitions card lacks population and base albums.
- Spec deck #1 (cover, definitions in notes only) and #27 "Numbers the specification does not give" (working list, not a slide to show).
- Google Slides copies not read (exports of the above; Eden's chapter-1 rework belongs to topic 1).

**Proposed slide (Eden builds):** one slide "How We Count" with five short lines (Finisher · Payer · Who · Revenue share · Albums: Dice 61/63 · Domino 19/20, 20 alone when it differs · Disney 14/15); the rest in the notes. Add the Dice column issue to the data-fix slide.

**Open**
- Every Dice revenue share in the decks must be rerun on the fixed population (spend groups, $20+ near-missers, staircase, targets…) — redo per topic as we reach it.
- Domino / Disney `user_album_count` not checked the same way (the payer revenue factors 0.77–0.81 look normal).

**Added 2026-10-22 (Eden approved):** new slide 11 in Eden's Google Slides "Copy of ALBUM END" (https://docs.google.com/presentation/d/1rUG2NSBJD2worjTyQyKf_iiprL6feUQUuaKAlsJyllE): "Most Revenue Comes From Players Past Their First Album" — revenue share only, one card per game, albums seen 1 / 2–3 / 4–6 / 7–12 / 13+ (Disney 7+), numbers from `albums-all-players-2026-10-21.md`; notes rewritten. Slide 10 left as is: its Dice first-album revenue reads 8% (should be 4%) and its legend labels (7–12, 13+) do not match its numbers (old 7+ / installed-before-Apr-2025 buckets).

## Topic 1: where the money is in the album (in progress 2026-10-22)
**Message (agreed):** the last days are the strongest days of the album, which is why we aim there; the lift is worth about 2% of revenue; in Disney the end does not lift.
- Eden: say that Disney revenue is falling and the album, which should push players to their top spend at the end, does not do it either (two facts, no causal link). Label holiday spikes (Disney 8, Domino 14 closed 5 Jan; Disney 3 = launch; Domino 18 = 14 sets). Drop "the value of the end is completions" (not shown).
- Use the per-album end lift (all players) in the story line, not the by-experience range; the experience slide says "by experience group".
- Reruns 2026-10-22: Dice 65 added → **+3% end lift, the first flat Dice end since Apr 2025** (data checked complete); Dice 7+ with the fixed count = same result. `dice-end-lift-65-7plus-2026-10-22.md`.
- **Parked to the end of the review (Eden 2026-10-22):** check of Eden's Dice 65 hypothesis (album too easy: weekend Trail finished easily, more rolls in from the game, less effort needed at the end). Plan: (1) Trail top-tier reach and days to finish, (2) non-purchase rolls in ÷ rolls staked by day to close, (3) payers 0–3 missing at 8 and 4 days before close + finish rate, (4) daily spend by days to close — 65 vs 61/63.
- Done 2026-10-22: Dice 65 added to slide 13 of "Copy of ALBUM END" (Dice card redrawn as shapes; 65 marked flat in red). Title now inaccurate — open: (a) "…Except Disney in 2026 and Dice 65" or (b) keep + note under the Dice chart.
- Eden 2026-10-22: changed slide 13 title herself to "Every Album Ends Higher, Except Disney in 2026 and Dice 65". Topic 1 closed; no further summary wanted.
- Topic 1 appendix slides checked 2026-10-22 (v82 #73 album-curves, #74 end-trend, #75 endlift-7): all numbers match the sources. Missing Dice 65 (album ARPDAU $1.31, last-4 $1.35, 7+ end lift +3%): it changes end-trend for Dice (53→65 last-4 only +3%, not "up"). endlift-7 compares last 4 days with the REST of the album (end-growth: with the whole album) → 1–4 points higher; label or align. Eden: not now.
- Topic 1 (2026-10-22): end lift by albums seen rerun with full-history groups (`end-lift-by-experience-2026-10-22.md`); new slide added to Eden's deck after slide 12.
- Topic 1 (2026-10-22): same-player cohort album 1→7 (`cohort-end-lift-2026-10-22.md`): Disney flat after album 1, same players' ARPDAU −34%; slide added after the experience slide.

## Where we stopped (2026-10-22, end of session)
- Topic 0 closed. Topic 1 closed (Eden: no further summary). Eden's deck "Copy of ALBUM END" now has new slides: 11 revenue share by albums seen; 13 end lift by albums seen (1/2–3/4–6/7–12/13+); 14 same players album 1→7 (kept as is, Eden 2026-10-22); 15 end-growth with Dice 65.
- Story opening discussed (not yet built): two Disney declines — level (ARPDAU −18% albums 10→15; same players −34% album 1→7) and flat end (album mechanics, hypothesis → tests 1/2). Chain: what it is not (new players, payout, front-loading, length) → what is different (rare supply, dry week, players far) → test.
- Topic 2 (who finishes / who is far) started: findings A–D shown; open: approve Dice reruns of stand3 / tool-reach / strength shares on the fixed population; agree the wording "A third of revenue comes from payers who end far from finishing, and the closing tool does not reach them".
- Parked to the end: Dice 65 "too easy" check (plan above); Disney mix check (ARPDAU with album-10 tenure mix held fixed).
- Nothing committed in this worktree (claude/*.md, *.sql, register edits).
