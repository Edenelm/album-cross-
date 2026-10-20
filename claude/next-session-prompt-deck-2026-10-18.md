# Handoff prompt — continue the cross-studio album deck (updated after the v2 rebuild, deck version 46)

Paste this into the new conversation:

---

We are continuing the cross-studio album deck (Dice Dreams, Domino Dreams, Disney Solitaire) for the product teams and the CRO.

**Deck:** https://claude.ai/artifact/6UUb91x2vHULkaM4g73uQr (Slides type, version 46+, 74 slides; I may have edited it since — read it live before anything).
**Build notes:** `claude/deck-v2-build-2026-10-18.md` (order, framing changes, checks, open items). **Storyboard and critique:** `claude/storyboard-v2-2026-10-18.md`. **Build code:** `claude/deck_v2_lib.py`, `claude/deck_v2_new_slides.py`, `claude/deck_v2_revise.py`.

**Structure (approved):** opening (summary of strongest findings, six questions, how to read) → 1 role of the album → 2 progression and blockers → 3 progress into purchases and completions (incl. Domino 19 vs 20 with two readings of free Jokers) → 4 who stays behind (close−4 = existing goal definition) → 5 after completion (two windows: personal completion day vs official close; payout slide pending data) → 6 decisions first (measure vs test), per-game lessons, tests, targets (set / measured / proposed) → closing → method (weighting, predictor, Dice levels, multiplier, fixes, open checks) → appendix → questions the data rejected.

**Rules:** English in the deck, Hebrew in chat. One short message per title; title strength must match the evidence (observational comparisons say so). Same level of scrutiny for all three games; depth by evidence. Every population: players, player share, revenue share, period, denominator. Consistent game colors (Dice #6FA3FF, Domino #F5A04A, Disney #3CC8B4). QA, contradictions and correction history stay in working docs, not in the deck. The ~2% end-lift sizing is an illustration, not a cap. Do not assume today's finisher spend ratio holds for new finishers. Keep the close−4 goal definition; moving it needs a separate case. Do not invent the payout analysis.

**Open items:** payout data (pending from Eden); Disney completion prize and post-completion content; base of the Dice ×1.19 multiplier; groups slide still by previous album; per-album rare curve (Disney 50–60% jump); revenue share of test-1 population and of Dice last-day finishers.

**Working rules:** check project material first; show any new query (tables, filters) + dry run and get approval before running; album-day revenue = the spend column of the album table; non-payer = did not pay during the album; Dice album IDs jump by 2; fully qualified BigQuery tables.
