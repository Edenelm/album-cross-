# Next session (written 2026-10-24, end of session; branch claude/topic6-after-album-2026-10-24, PR 15 open — it also carries PR 14)

## Eden's request (her words, translated) — do it alone, do not wait for approval
"Continue alone — a fast, good researcher who finds where the problem is and where the solution is (not only Disney, all games). Continue with what happens after the album — e.g. in Dice, players who finish take longer to recover. Who are they mainly, what happens to the 200K players, and how should the prize be improved and for whom (a test proposal). Little text, more visual, simple titles. Add slides; I will arrange and decide at the end. Do not repeat the same message on several slides; pass the message short and clear, without showing many things across many slides. Don't wait for my approval, just do what I asked."
Also: she did not want an opening/divider slide for topic 6 (none added).

## How to work (Eden, this session)
- Add slides to ALBUM END (1vtwRvOAocgcZfrxl8uBfpOzIt7wkGbkCtxEBgFB4FvM) without asking; never delete existing slides; she skips/arranges herself.
- One message per slide, one visual, one key number; title = what is plotted, short; detail in speaker notes. Show all three games side by side with the SAME measures (she objected when one card showed $ and the others %).
- Spend levels always low → high (≤$2, $2–5, $5–20, >$20; $0 first when shown) — same order as t5a/t5b.
- Revenue share for every population; money only from data (gap to own pace / pool size), never from an assumed lift.
- Commit + push + PR at the end of a stretch (she approved this flow all session).

## Where topic 6 stands
- Results: `claude/topic6-after-album-2026-10-24.md` + `claude/topic6_after_album_2026-10-24.sql` — first 7 days after the close date (next album days 2–8) vs own album pace, by spend level × end status. Finished ≥ pace, 1–3 a bit below, 4+ about half, all games.
- Slides built (after r2_slide): s6a_slide (week after close vs own pace, $2–20 payers, finished vs 4+: Dice 110/52, Domino 140/49, Disney 128/59) and s6b_slide (one gap per game; same 3 measures per card).
- Open check: were far payers already slowing before the end (last-quarter spend vs pace)? Soften s6a wording if yes.

## The next task: Dice finishers recover slowly — who, the 200K tier, the prize, a test
Known (verify the numbers before using them, then go further):
- `claude/post-album-events-2026-10-19.md`: only in Dice do finishers buy below their habit after the album. Slow group = Light + Mid veteran payers with a 100K–200K prize: 47% of payer finishers, 8.4% of album revenue (album 63); prize = 4–8 days of their own play; bought by day 7 −7 to −12 pts, spend days 1–7 18–33% below habit. High / Top payers: prize = 1.5–2 days of play, back at habit.
- `claude/deck-review-actions-2026-10-21.md` rows seg-return / prize-tier / prize-return / prize-rec: the 200K tier grew from 12.6K players (album 59) to 32.7K (album 65); in album 63, 41% of it spent under $150 (1.1% of revenue); the album returns 13% of rolls played to $2K+ payers vs 24% to $150–699; proposal 250K / 350K for 1,863 stable $1K+/$2K+ payers (11% of game revenue), 25K → 100K for 2,361 new $700+. Rejected earlier by Eden: split prize / Grand Prize Rush.
- This session's s6b: Dice finishers $2–20 a day start the next album at 110% of own pace vs Domino 140%, Disney 128%.
Suggested path (fast): (1) one query — Dice 63 (and 65 if closed: Dice 65 closed 2026-10-19, next album 67) payer finishers by prize code (album_reward_code 1–7; 7 = 200K) × spend level: players, % of revenue, prize as days of own rolls, week-1 spend vs own pace; (2) find who loses the most money (players × gap), not only %; (3) one test proposal: prize sized to the player's own play (e.g. ~2–3 days of rolls) — smaller / paid over days for the oversized Light/Mid group, bigger for top payers — Control vs Test, measures: week-1 revenue per payer and next-album revenue. Thresholds/prize sizes = options for management.
Slides to add (max 2–3, no repeated message): "Who finishes in Dice, by prize and spend level" (visual), "Prize in days of own play vs return to buying" (visual), "Test: prize sized to the player" (Control | Test card).
Also check other games for the same issue briefly (Domino / Disney finishers are fine: 140% / 128% — say so in one line, no extra slide).

## Deck mechanics (Google Slides connector)
- Generator: `claude/slide_t5_story_2026-10-24.py` (helpers dup/txt/color/bar/fill/box/tbox; copies of t5d_slide (bars) and t5c_slide (card rows)). Copied shapes keep a 3,000,000 EMU base size: set scaleX/scaleY = real size ÷ 3e6 (bar scaleX 0.1981, value label 0.2591 × 0.0853).
- Duplicating a skipped slide copies the skip: clear it with updateSlideProperties {isSkipped:false}.
- The revision ID changes on every read, so guarded writes fail; Eden approved unguarded writes for new slides (see memory album-end-deck-revision-lock).
- Thumbnails: read_slide_page_thumbnail → curl to claude/slides/*.png → check visually (titles over ~70 chars wrap at 24pt).
- Speaker notes: read notesProperties.speakerNotesObjectId, then deleteText (if not empty) + insertText.
