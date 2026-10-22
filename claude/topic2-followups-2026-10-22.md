# Topic 2 follow-ups (2026-10-22, Eden asked)

SQL: `claude/topic2_followups_2026-10-22.sql`. Projects: `dice-dreams-dbt`, `domino-dreams-dbt`, `solitaire-dreams-411507`. Albums Dice 61/63, Domino 19/20, Disney 14/15.

## E. End status with first-album payers added (share of game revenue)
Same population as slide 15 (login ratio 0.5+ on the last row before close, a row on close−1, exclusions), payers = album-table spend > 0 including the close day, end status at the end of the close day. "With" adds first-album payers (Dice: no row in an earlier album; Domino / Disney: `user_album_count` ≤ 1). Denominator = total game purchase revenue during the album.

| Album | Finished: without → with | 1–3 missing: without → with | 4+ missing: without → with | First-album payers' share |
|---|---|---|---|---|
| Dice 61 | 21% → 24% | 35% → 38% | 23% → 24% | 8% |
| Dice 63 | 26% → 28% | 42% → 45% | 14% → 15% | 7% |
| Domino 19 | 20% → 22% | 21% → 22% | 36% → 39% | 6% |
| Domino 20 | 27% → 29% | 35% → 37% | 16% → 17% | 5% |
| Disney 14 | 16% → 18% | 29% → 32% | 33% → 36% | 8% |
| Disney 15 | 18% → 20% | 29% → 31% | 34% → 36% | 5% |

- Check: the "without" columns reproduce slide 15 and `game-revenue-rebase-2026-10-21.md` (Domino 20.1 / 20.9 / 35.8; Disney 16.2 / 29.4 / 32.7); game revenue matches exactly (Domino 19 $17,644,426, Disney 14 $51,554,638, Dice 61 $25,341,918).
- Fact: adding first-album payers raises every bar by 1–3 points; the message holds and is a little stronger for Disney (4+ = 36% in both albums).
- Fact: with them, the three bars cover 83–87% of game revenue; the rest (13–17%) is payers with login ratio < 0.5 or no row on close−1, plus excluded or non-standard rows (split not measured).

## W. Wild / Joker reach as a share of players (middle payers, last 4 days before close)
Same groups as slide 16 (EndWin): middle = P50–95 of album spend before the last quarter; near = ended 1–3 short, far = 4+ short (last day before close). Received = at least one new sticker filled by Wild / Joker in days 4–1 before close.

| | Near: % who got ≥1 | Far: % who got ≥1 | Near: per 100 (slide) | Far: per 100 (slide) | Stickers per receiver (near) |
|---|---|---|---|---|---|
| Dice 61 / 63 | 36% / 24% → **30%** | 5% / 5% → **5%** | 47 / 31 → 39 | 7 / 6 → 6 | 1.3 |
| Domino 19 / 20 | 75% / 33% → **54%** | 10% / 4% → **7%** | 142 / 42 → 92 | 14 / 4 → 9 | 1.9 / 1.3 |
| Disney 14 / 15 | 14% / 24% → **19%** | 1% / 3% → **2%** | 15 / 30 → 23 | 1 / 3 → 2 | 1.1 / 1.3 |

- Check: per-100 numbers reproduce slide 16 and EndWin exactly.
- "39 per 100" is not "39%": a player can get more than one sticker from the Wild. The share of players is lower (Dice 30%, Domino 54%, Disney 19% of near middle payers); far middle payers 2–7%.
- Domino 19 near group is small (8,884 players, 75% received) vs album 20 (24,972, 33%); the easier end in album 20 brought many more players near.
