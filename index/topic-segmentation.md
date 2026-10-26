# Segmentation (spend levels, Easy/Hard, album segment)
- **One structure (register 10-15):** 5 groups by $ a day: 0 / ≤2 / 2–5 / 5–20 / >20. Level = last album. Tier = expected spend at the start of the last quarter. Group 0 has no target. In topic 5 and later, the spend level is album $ a day before the last quarter (own pace).
- **Display rule:** always order levels low → high, with $0 first (CLAUDE.md / 10-24 prompt).
- **Dice "album segment"** = album_reward_code 1–7, not Easy/Medium/Hard/Extreme (register 10-19).
- **Data issues:**
  - Disney has no album segment field.
  - Dice's stored segment column disagrees with the team query for part of the upper levels.
  - Domino's daily segment is −9999 on about 26% of rows (spec §11).
- **Old recommendation (10-15):** 5 groups. Disney = Test; the others = Do Not Adopt Yet (segmentation-recommendations-2026-10-15.md).
- Domino Easy/Hard = album_segment on the player's first album row; no player outside both (c/domino-easy-hard-splits-2026-10-26.md). Gate per segment: card dx.
## Read
- segmentation-recommendations-2026-10-15.md (root)
- per game: dice-segmentation-validation-2026-10-14.md, disney-segmentation-build-2026-10-14.md, disney-segmentation-d5-2026-10-15.md / -d5b-, domino-segmentation-2026-10-15.md, dice_album_user_segmentation.md
- c/profile_easy_medium_dice.sql (Dice Easy/Medium profile)
## SQL
dice_segmentation_validation_queries.sql · disney_segmentation_queries.sql · disney_segmentation_queries_d5.sql (root, 10-14/15) · c/dice_predictor_queries.sql
## Superseded
next-session-prompt-segmentation.md (old entry point)
