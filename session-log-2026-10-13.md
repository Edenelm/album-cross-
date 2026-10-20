# Session log — 2026-10-12/13 (Cross-game album benchmark)

## Docs produced / updated (project)
- claude/dice-supers-mechanism-onepager-2026-10-12.md + claude/dice_supers_mechanism_queries.sql — Dice Supers mechanism one-pager (sections 1–6).
- claude/topic5-rare-sources-2026-10-12.md + claude/topic5_rare_sources_queries.sql — Topic 5 (5, 5b mapping v2, 5c Momentum Royal days, 5d first version).
- claude/topic5-5d-v3-domino-first-royal-gift-2026-10-13.md — 5d v4: population = PU NOT first album (all games) + Domino First_Royal_Gift → Daily / free gift. Supersedes old 5d.
- claude/topic5-5e-other-events-2026-10-13.md — "Other events" breakdown, Disney Promo Wheel dates, 5f Disney event groups (Promo / Mini game / PB / MTX challenge / Other), 5g Domino partial mapping + questions for the Domino team.
- claude/topic5-conclusions-2026-10-13.md — Topic 5 conclusions, CRO line, suggested A/B, open validations.
- **Draft CRO deck (Claude Slides artifact, English, 12 slides): https://claude.ai/artifact/HH8Bto7QWGeazMTHGau6Bp** — cover, scope, status, T1, T2 population, T2 album-end, T4 rares, Dice Supers gate, T5 chart, T5 Q4, decision table, next steps. Google Slides connector not connected (connect_incomplete).

## Decisions (Eden, 2026-10-13)
- First_Royal_Gift (Domino, campaign EV_Royal_Card_Popup%) = first-album experience → "Daily / free gift".
- Cross-game population rule for rare work: exclude players in their first album (Dice user_past_album_count > 0; Domino/Disney user_album_count > 1).
- "Other events" = one-off MTX events → being regrouped: Promo / Mini game / PB / MTX challenge / Quest / Other. Disney fully mapped (5f). Dice PropChase_Hunt = Parallel Quest → Quest. Domino partial (5g), Trail stays separate in Domino.

## Open items (priority order)
1. Domino event grouping — Eden asks Domino team (list in 5g). Then map Dice to the same groups, rerun 5d for all games, redraw chart, update deck slide 9.
2. Placebo base rate for "purchase ≤10 min before last Super" — design approved (−24h/−48h shift, not-first-album); query dry-run 15GB, not yet run.
3. Trail inconsistency: Disney trails in MTX challenge vs Domino/Dice Trail separate.
4. Disney team questions (Joker flag, duplicates, marketplace timing, paid/MTX list, Royal release calendar, scrolling/Promo Wheel paid?, user_album_count semantics).
5. Missing: paid vs free inside MTX events.
6. Older backlog: Topic 3 (album calendar); rerun Topic 2 population table (18-month rule); revenue column check Domino/Disney.

## Session notes
- Bifrost BQ multi-project lock = dice-dreams-dbt, domino-dreams-dbt, solitaire-dreams-411507; pass project= on every call.
- Latest Disney closed album = 15 (2026-08-24 → 2026-10-05); album 16 open 2026-10-05 → 2026-11-16.

