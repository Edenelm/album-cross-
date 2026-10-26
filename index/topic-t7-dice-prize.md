# Topic 7: three natural cases, Dice grand prize (NOT reviewed by Eden yet)
**Finding:** the same 200K prize is 5 days of play for a ≤$2-a-day payer and 1 day for a >$20 payer. 28% of 200K payer finishers spend ≤$2 a day. The bigger the prize relative to own play, the fewer buy the next week (≤$2: 55% → 42%; $2–5: 70% → 65%) (c/topic7-dice-prize-2026-10-25.md).
## Key numbers
- The slow group is Light + Mid veterans with a 100–200K prize: 47% of payer finishers, 8.4% of revenue (album 63). The 200K tier grew from 12.6K players (album 59) to 32.7K (album 65). Proposal: 250K/350K for 1,863 payers. Eden rejected the split prize and Grand Prize Rush (c/next-session-prompt-2026-10-25.md).
- $2K+ payers spend about $2,000–2,800 every album and stay on 200K (c/topic7-fixed-prize-spend-2026-10-24.md). For them the prize is 0.74–1.0 days of play, and a 2-day prize means 400K–540K rolls (c/topic7-top-payers-2day-prize-2026-10-24.md).
- The >$20 drop after close happens in one album only: album 65 → 95% of pace, album 61 → 96%, album 63 → 84% (c/topic7-top-payers-2026-10-24.md).
- The other cases (spec ch7):
  - Domino 20's easier end: payer finishers +44%, revenue per player +3%.
  - Disney's late gate: R131 and the paid Joker open 3–4 days out.
  These are now in topic-domino-cases and topic-t4.
## Read in order
c/topic7-dice-prize-2026-10-25.md → c/topic7-top-payers-2026-10-24.md → c/topic7-fixed-prize-spend-2026-10-24.md → c/topic7-top-payers-2day-prize-2026-10-24.md → c/seg7-top-payers-2026-10-20.md
## SQL
c/topic7_dice_prize_2026-10-25.sql (user_daily_album + 30_intermediate.user_daily_rolls_in_out) · c/topic7_fixed_prize_spend_v2_2026-10-24.sql (the v1 file is superseded) · c/topic7_top_payers_2026-10-24.sql · c/topic7_top_payers_2day_prize_2026-10-24.sql
## Slides
- t7a, t7b, t7c (c/slide_t7_dice_prize_2026-10-25.py; PNGs c/slides/t7a–c.png). They overlap Part 1 slides 42–46.
- t7d–t7h (c/slide_t6_story_2026-10-24.py).
## Open
- Eden has not reviewed topic 7.
- Prize test arm and sizes: 2-day prize vs 250K/300K.
