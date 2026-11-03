# Handoff — Dice chapter (2026-11-02)

Start: `index/topic-dice-chapter.md`, then `claude/dice-research-map-2026-11-02.md` (Eden's next phase: research map, no slides yet), then `claude/dice-chapter-2026-11-02.md`.

## Done (2026-11-02)
- Status map of Dice from the existing docs: what to keep, gaps A–E, top 3 questions, superseded list (dice-chapter §1–5).
- Topic 2 (completion path) run on 59/61/63 + 65: `dice-completion-path-2026-11-02.md`, SQL `dice_completion_path_2026-11-02.sql` (runs 1 and 2), CSVs in `claude/results/`.
- Draft charts dc1–dc4 (`claude/slides/dice/`, generator `dice_chapter_charts_2026-11-02.py`; matplotlib is not installed system-wide — use a venv). Not in any deck.

- Linkage audit, purchase → sticker (album 63): `dice-sticker-source-vs-purchase-2026-11-02.md`. New paid rule = sticker_source = purchase.source (+ campaign_id) ≤10 min; pack rule superseded. Rerun 'bought' numbers of the completion path with it before slides.

- Eden's 5 checks (11-02/03): first album, entry third (new / returning / continuing), duplicates per day, rolls before finish, prize vs those rolls: `dice-entry-dups-rolls-2026-11-02.md`, SQL `dice_entry_dups_rolls_2026-11-02.sql`. Done 11-03: where first-third new players stop (§6). Open: duplicates by sticker type, did new stoppers get more duplicates before stopping than similar new players who stayed, comparison group for general new-player churn, Disney/Domino prize rule (ask the teams).

## Decisions / rules from Eden this session
- Base for Dice's album potential = typical albums 59/61/63. 65 is the exception (only flat end since April 2025); show it as one case, do not build conclusions on it. The 65-vs-63 analysis already exists.

## Next (in order) — after Eden picks the direction from the research map
0. Research map written 2026-11-02 (existing material only). Recommended start = topic 4 (journey to completion): linkage audit on 63 first.
1. Topic 4 + 3 on 59/61/63: what the $5+ payers 1–3 short at close−4 bought in the final weekend (product, price; `20_core.purchase_completed_vw`), whether they had a Wild offer (look for an offer-exposure table in 50→40→30→20), and the closing cost (Wilds needed × price) vs what finishers paid. Then the last 3 stickers of every finisher: type, order, source, timing gaps, Wild vs direct, purchase within 10 minutes vs only same day. Compare with players at the same level and distance at the same day, not by status at close.
1b. Strong players defined before the album (album segment Hard/Extreme, reward code 7): size, in-album level, finish timing, album-linked share of spend.
2. First album (topic 1): agree definitions with Eden first (entry day vs album start, early vs late entry, first rare, first set, first purchase).
3. Eden to review: dc1–dc4, the potential scenario (§3 of the chapter doc), the order of questions.

## Open questions
- Why $5+ near payers do not buy the closer: price / no offer / gave up — not known.
- Early finishers: "money moved earlier" checked on 63 only.
- Nothing committed yet (branch claude/daze-completion-analysis-eae481) unless Eden approved it after this note.
