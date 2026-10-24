# Next session (written 2026-10-24; branch claude/album-end-slides-08d705, PR 16 open)

## Where we are
- Eden is reviewing the story topic by topic (map and approved messages: `claude/data-story-review-2026-10-21.md`). Topics 0–5 closed. Topic 6 (after the album) rebuilt today; topic 7 (three natural cases) not reviewed yet; 8–9 not started.
- Topic 6 rebuilt (`claude/topic6-before-after-2026-10-24.md`): ALBUM END slide 59 (s6a) was misleading — far payers were already at 24–44% of own pace in the last week before close, then 49–59% the week after (higher, not lower). New slides s6c_slide (finishers) and s6d_slide (non-finishers 1–2 / 3 / 4+) right after s6a; notes written. s6a kept (Eden decides).
- Finishers, $2–20 a day, last week → week after (% of own album pace): Dice 63 229 → 110, Domino 20 217 → 140, Disney 15 188 → 128 (prev albums 129 / 134 / 135). Dice lowest in both albums.
- 1–2 short: Dice 63 135 → 90, Domino 20 120 → 103, Disney 15 150 → 108.

## Next tasks (Eden, in this order)
1. **Finishers return at different levels** — depends on prize size or how the game is built after the album. Find which game is the problem, which specific population, and its revenue share. Start from Dice (lowest return): finishers by prize-days of own play × spend level (`claude/topic7-dice-prize-2026-10-25.md`, t7a–t7c slides; they overlap Part 1 slides 42–46), and compare with Domino/Disney finishers on the same measure (last week → week after). Show players, % of payers, % of album revenue.
2. **Payers 1–2 stickers short** — what happened after the album, and how the post-close payout (Part 1 deck slide 36: payout days 1–3 vs mid-album, by end status) affects them. Same population and windows as topic 6 rebuild.

## Rules for this work (Eden)
- Always compare the week after with the **last week before close**, not only with album pace (slowdown starts before the end).
- Separate slides for finishers and non-finishers; same measures in all three games; spend levels low → high; little text; title = what is plotted.
- Every population: players, % of payers, % of album revenue. Money only from data.
- Add slides to ALBUM END without asking, never delete; commit + push at the end of a stretch.

## Other things done this session (for reference)
- Part 1 deck (1WS07a_8A_IDJ1HndTBG34qHD5-sJx8WNDzhVAkv3zwQ): p24fix (closing tool per day, % of payers, Dice 63 / Domino 20 / Disney 15, one scale) and p24rec (test: Disney Joker earlier, sold vs event) after slide 24. Domino 20 free-Joker peak = Movie Twister event; its 19,125 payers (18% of payers, 31% of revenue) spent ×1.83 their habit in the 2 days, 52% above CZ; far middle payers barely got Jokers (6%). Docs: `closing-week-pct-payers-2026-10-24.md`, `domino-movie-twister-purchases-2026-10-24.md`.
- Domino easy end and next-album start: `domino-easy-end-pays-twice-2026-10-24.md` (fits, not proven).
- Dice >$20 drop = album 63 only: `topic7-top-payers-2026-10-24.md`.

## Mechanics
- Slides drawn with createShape are stored on a 3,000,000 EMU base: to move/resize, read size and set scale = real ÷ 3e6. Replacing text resets style in the Part 1 deck — re-apply Oswald size/colour. Part 1 deck has no BLANK layout: use layoutId p50.
- Generators: `claude/slide_s6_before_after_2026-10-24.py`, `slide_t7_dice_prize_2026-10-25.py` (helpers), `slide_p24_fix_2026-10-24.py`, `slide_p24_rec_2026-10-24.py`.
