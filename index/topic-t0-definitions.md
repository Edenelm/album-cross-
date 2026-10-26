# Topic 0: definitions, population, denominator (CLOSED 10-21)
**Message (approved):** every number is counted on the same players, the same albums and the same denominator, and the slide says who it is about (c/data-story-review-2026-10-21.md §Topic 0).
## Current rules (register = source of truth)
- **Finisher:** 144 unique set stickers by the END of the close day, not the game flag (Eden 10-19; register row "סיום"). Dice: close-day finishers come from 30_intermediate.fact_user_album_stickers, because the daily table does not update stickers on the close day.
- **Payer:** paid on any album day, close day included. Album revenue runs from album start to close−1 (10-20).
- **Denominator:** total in-game purchase revenue during the album, all players, without cheaters or test users. RV is shown separately (register 10-20). Finisher target restated: 20/23/24% of game revenue (= 30% of the old base) (register 10-21).
- **Standard population:** not in the first album, not excluded, login ratio ≥0.5 on the last row before close, and has a row on close−1 (CLAUDE.md).
- **Dice first-album fix:** 19–22K returning payers were missing. Finisher revenue share moves 18→21% (album 61) and 21→26% (album 63). Old Dice standard-population shares are about ×0.84–0.86 of the right value (data-story-review §Topic 0). Domino and Disney do not have this problem (c/open-checks-2026-10-24.md §A).
## Key numbers
- Payers who finish: 11.2 / 7.7 / 5.2%. Their share of game revenue: 19 / 23 / 17% (c/final-analysis-spec-2026-10-21.md §6; c/game-revenue-rebase-2026-10-21.md). Close-day finishers are 15–27% of finishers (c/finisher-recount-2026-10-19.md).
## Read in order
1. decisions-definitions-register.md 2. c/finisher-recount-2026-10-19.md 3. c/payer-close-day-2026-10-20.md 4. c/opening-facts-2026-10-20.md 5. c/game-revenue-rebase-2026-10-21.md 6. c/first-album-finish-rate-2026-10-21.md 7. c/open-checks-2026-10-24.md §A
## SQL
c/finisher_recount_queries.sql · c/game_revenue_rebase_queries.sql · c/first_album_finish_rate_queries.sql · c/open_checks_2026-10-24.sql · c/revshare_fill_queries_2026-10-20.sql (old base)
## Do not read (superseded)
- Root album-analysis-v2/v3/v4, the claims-register numbers (replaced by c/evidence-recheck-2026-10-18.md, then by finisher-recount).
- Old flag finish rates 11.5/13.5% and 8.1/10.5%.
- c/revshare-fill-2026-10-20.md as a base: it uses the old base, so multiply by the factor (Dice 0.67–0.69, Domino 0.77–0.79, Disney 0.78–0.81).
## Open
- Register line 8 (old row) still says Domino 17/19, but line 9 (2026-10-21, Eden) overrides it: Domino base 19/20 across the deck, 17 is history only. See conflicts-and-decisions.md C5. Re-checked 2026-10-26 on the merged register: still not fixed.
- Register row added 2026-10-25 (Domino): dormant players = lowered their purchase pace and get a treatment to return; `8boxdormantcampaign` is a dormant treatment, not a general route.
