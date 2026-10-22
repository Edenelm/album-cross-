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

## Topic 2 (2026-10-22, new session)
- Dice reruns of B (stand at close−3), C (Wild reach) and D (strength) on the fixed population done (Eden approved): `dice-topic2-reruns-2026-10-22.md`. B and C unchanged (far share 51% / 30%; Wild 39 vs 6 per 100). D: rates unchanged, revenue shares up (above p95 33–35% of game revenue, finishers' share 21% / 26%).
- **Message (approved, Eden 2026-10-22):** "A third of revenue comes from payers who end far from finishing, and the closing tool does not reach them."
- Next: map topic 2 to slides (v82, decision deck, spec deck, Eden's "Copy of ALBUM END") and what to change.
- Slide map for topic 2 (2026-10-22). Eden's "Copy of ALBUM END" (14 slides): no topic-2 slide yet; slide 2 lists chapter 2 "Who is where at the end, by daily spend".
  - v82: #12 q2, #13 spend-lens, #14 target, #15 stand4, #25 tool-reach, #26 half-completions, #31 keep-playing, #32 heavy-missers, #47 disney-finishers, #53 targets, #59 groups, #65 far-revenue, #67 same-spend, #80 album-swings, #91 album-effect, #93 stand-move; passing: #2, #23, #27, #33, #36, #52, #55, #66.
  - Decision deck: #3 money, #17 groups-curve; passing #2 story, #21 closing, #6, #10, #14, #18. Spec deck: #3 ch2, #5 ch4, #6 ch5, #23 tgt-strength; passing #22, #11.
  - Issues: (1) "a third of revenue is 4+ away" holds for Disney (33/34%) and Domino 19 (36%), not Dice (23/14%) or Domino 20 (16%); (2) decision #3, v82 #26/#32/#33/#47/#67 use Domino 17/19 (decision: 19/20); (3) three bases side by side: share of revenue so far at close−3 ("about half"), game revenue at the end ("a third"), old standard-population revenue (#55, #59); (4) Dice numbers to update from the fixed population (finishers 21/26%, payers 78/82%, above p95 33/35%, below p95 44/46%, p95 $13.4–13.6, Wild 6 vs 39).
- **Message changed (Eden 2026-10-22, option A):** "In Disney, a third of revenue comes from payers who end far from finishing, and the closing tool does not reach them." (the first wording held only for Disney; Dice 14–23%, Domino 16–36%).
- Built in "Copy of ALBUM END" (Eden asked), as slides 15–16 after chapter 1, card style like slide 10, notes written: 15 "In Disney, a Third of Revenue Comes From Payers Who End Far" (end status per album, share of game revenue, 4+ in red); 16 "The Wild / Joker Reaches the Near, Almost Never the Far" (per 100 middle payers, last 4 days: 39 vs 6, 92 vs 9, 23 vs 2). Topic 2 closed unless Eden changes the slides.
- Follow-ups 2026-10-22 (`topic2-followups-2026-10-22.md`): with first-album payers the slide-15 bars rise 1–3 points (Disney 4+ = 36% / 36%); Wild reach as % of near middle payers who got ≥1 sticker: Dice 30%, Domino 54%, Disney 19% (far 5 / 7 / 2%). Slides 15–16 not changed yet.
- Slides 15–16 updated (Eden 2026-10-22): 15 now includes first-album payers (Dice 24/38/24, 28/45/15; Domino 22/22/39, 29/37/17; Disney 18/32/36, 20/31/36); 16 now shows % of middle payers who got ≥1 Wild/Joker sticker in the last 4 days (near vs far: Dice 30 vs 5, Domino 54 vs 7, Disney 19 vs 2). Notes rewritten. Topic 2 done; next = topic 3.

## Topic 3: rare supply (started 2026-10-22)
- **Message (approved, Eden 2026-10-22):** the difference is the long wait, not the pace (longest stretch without a new rare: 14% of album time in Dice vs about a third in Domino and Disney; per rare, the pace is similar).
- Reruns 2026-10-22 (`topic3-reruns-2026-10-22.md`): Dice timeline on the fixed population = unchanged; Domino rare sources on 19/20 = same picture (one-off events about half every quarter, dup exchange 23/37% in Q4; First Royal gift reaches returning payers too).
- Next: map topic 3 to slides.
- Slide map for topic 3 (2026-10-22). Eden's deck: slides 6 "Same 144 Stickers, Built Three Different Ways" and 7 "Album End" (gate + closing tool) are structure; no rare-supply slide yet.
  - v82: #18 q-rares (chapter 3 divider), #19 rare-timeline (core, message already "longest wait"), #20 rare-sources-mix, #21 rare-mechanics (from the teams, not data); appendix #66 royal-dip, #77 rares-cum and #78 rares-end (superseded, Domino 17, 3 albums), #79 sources; related #17 gates (topic 4), #90 dice-gate.
  - Decision deck: no rare slide; #2 story line 4 "Dice gives a rare every 4 days; Domino and Disney every 7, with 12–15 dry days" (pace framing), #13 dice-diag "every 4 days", #6 disney-what lever 2. Spec deck: #4 ch3 "In Domino and Disney, the longest wait for a new rare is 12–15 days" (absolute days).
  - Issues: (1) story line 4 / spec ch3 use the pace or absolute days, against the approved message (use % of album: 14% vs 26–35%); (2) #19 notes / subtitle: Dice payers 175,794 / 182,700 and "69% of game revenue" are the old population (now 194,603 / 204,893, 78% / 82%); (3) #79 Market 0–14% and dup exchange from Domino 17/19; on 19/20 Domino has no Market, dup exchange 23 / 37%, paid 10 / 4%; (4) #77–78 superseded, drop; (5) #21 mechanism not checked in data.
- Built in "Copy of ALBUM END" (Eden asked, 2026-10-22), after slide 16 (topic 2), card style, notes written: "Domino and Disney Payers Wait Up to a Third of the Album for a Rare" (longest wait as % of album, two albums per game: 14/14, 26/30, 28/35%, Disney in gold) and "One Steady Trail in Dice, Rotating Events in Domino and Disney" (main source share per quarter, latest album: Dice Trail 38/62/60/27, Domino events 46/52/47/47, Disney events 47/55/66/45).
- Eden 2026-10-22: the sources-by-quarter slide missed the message. Message (Eden): Dice always has a safe mechanism to get a Super; in Domino and Disney a Royal is promised only in a Royal-UI pack, not inside a pack of commons (less flexibility to give it), there is no steady handling of the Royal economy, and Royals come mostly from monetization events. Slide rebuilt as "Dice Always Has a Way to a Super; Domino and Disney Wait for Events" (three rows per game: always-on source / rare inside regular packs / main source with shares); mechanism labelled as from the product teams, not checked in data.
- Eden 2026-10-22 asked for one slide with the average of the last two albums: finish rate and finishers' share of game revenue. Built at the end of "Copy of ALBUM END": "Few Payers Finish, but They Bring 19–26% of Game Revenue" — same population as the end-status slide (first-album payers included): finish 11 / 8 / 5% (per album 11·12, 6·10, 5·5%), finishers' share 26 / 25 / 19% (24·28, 22·29, 18·20%). Notes give the standard-population numbers too (10·12, 6·10, 5·5%; 21·26, 20·27, 16·18%).

## Where we stopped (2026-10-22, second session)
- Topics 0–3 closed. Eden's deck "Copy of ALBUM END" now ends with: 15 end status (first-album payers included), 16 Wild / Joker reach as % of players, 17 longest wait for a rare, 18 "Dice Always Has a Way to a Super…", 19 finish rate and finishers' share (avg of last 2 albums). Eden moves slides herself.
- Topic 4 (how the album closes) step 1 shown; open: (1) rerun half-completions (finish rate by stickers missing 8 days out) and gates on Domino 19/20 (now 17/19) and Dice on the fixed population; (2) Eden to approve the message: "Every game closes in the last 4 days with a Wild / Joker. In Disney the week before is dry: nothing to get or buy until 3 days out, and near payers finish half as often." Open question for Disney team: are Market tokens bought or earned?
- Still parked: Dice 65 "too easy" check; Disney tenure-mix check. Other decks (v82, decision, spec) not updated; the needed changes are listed under topics 2–3 above.
- Uncommitted in worktree continue-session-20c65f: topic 3 reruns (claude/topic3-reruns-2026-10-22.md, .sql) and this log. PR #8 holds the topic 2 work.
