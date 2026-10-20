# Super Stickers — Cross-Game Analysis Spec

**SUPERSEDED (2026-10-07):** the source of truth is `super_sticker_comparison_handoff.md`. Read it first. The analysis there is locked/paused. This file keeps only the original request for reference.

## Locked in the handoff (summary)
- Two lines only, payers only, completed albums, integer P50, unweighted mean of 2 albums, x-axis = % of album (day = ROUND(p × album_number_of_days)), through 100%.
  - Dice: unique_super_stickers_lt, albums 61 & 63 → 10 at 100% (79.2% of 12-cap). New Super every 4.15 days (~10.6% of album).
  - Domino: Royal (unique_royal_stickers_tl), albums 18 & 19 → 7 at 100% (73.3% of own cap 10/9). New Royal every 7.73 days (~14.6% of album).
- Rejected: per-1K-players normalization, fixed-12 completion share, duplicates (set_total_super_stickers_today), P75, separate 61/63 curves, live albums (Dice 65, Domino 20).
- Disney Solitaire: out (no album ID locked).

## Resolved (Eden, Q16, 2026-10-07)
- Keep the Looker-style row-level `album_login_ratio >= 0.5` filter for the Super curve (consistency with Looker). Caveat recorded in the handoff's Decisions section: the column varies across a user's rows (~300K users per album), so the daily payer population is not fixed. Line not re-run against the engaged definition.
- Note: the general album benchmark (dice-album-data-setup.md) still uses the engaged definition. The two analyses use different populations on purpose.

## Original request (2026-10-06) — not all parts are in scope anymore
- Daily: supers_received_daily, new_supers_daily, duplicate_supers_daily, new_super_rate (new = not held before receipt from ANY source).
- Normalization per 1K participants + collection % (unique ÷ album total).
- Player progression P50/P75(/P90) of % unique collected.
- Charts: Daily Super Distribution (stacked new/dup per 1K); Cumulative Super Collection (P50/P75, 3 games).
- Summary: Game | Supers per 1K | New Super Rate | Final P50 | Final P75 | Share in final 7 days.

