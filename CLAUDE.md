# Album Analysis Across Studios — Claude Code guide

Eden's cross-studio sticker-album analysis for Superplay: Dice Dreams, Domino Dreams and Disney Solitaire. The work feeds a deck for the product teams and the CRO.
This repo was moved from the claude.ai Project "Album Analysis Cross Studios" on 2026-10-20.

## Start here
1. `claude/next-session-prompt-2026-10-25.md` — the latest handoff (topic 6: Dice finishers, 200K prize, test). Older: `claude/next-session-prompt-2026-10-24.md`, `-10-21.md`.
2. `INDEX.md` — the map of every doc by topic, with status (current / superseded) and where the SQL is. Check it before starting any new check.
3. `decisions-definitions-register.md` — the source of truth for definitions. When it conflicts with an older doc, it wins.
4. The latest results: `claude/payer-close-day-2026-10-20.md`, `claude/remaining-recounts-2026-10-20.md`, `claude/finisher-recount-2026-10-19.md`.

## How to work with Eden
- Chat in Hebrew. Deck text in simple, clear English.
- Do not ask before running queries: dry-run first, then run, and save every query in `claude/*.sql` next to a results doc `claude/<topic>-<date>.md`.
- Every population shows players, share of players and share of album revenue.
- Separate fact / interpretation / hypothesis. No causal claims without a test; suggest a controlled test instead. Recommendations: adopt / test / do not adopt yet.
- Thresholds, cut-offs and targets are management decisions: show options.
- Whole numbers; ranges when albums differ. Show revenue share, not only player share.
- In Hebrew text: "רויאל"; Wild in Dice, Joker in Domino and Disney, "ווילד/ג'וקר" for all.
- Eden wants little text on slides: the message and one key number on the slide, detail in the speaker notes.

## Key definitions (full list in the register)
- **Finisher** = 144 unique set stickers by the END of the close day (close day included), not the in-game flag (Eden, 2026-10-19).
- **Payer** = paid on any album day, close day included (Eden, 2026-10-20). Close-day spend is NOT added to album revenue.
- **Album revenue** = album-table spend column (all in-game spend on album days, gross $) from album start to the day before close.
- **Close day** is left out of daily averages only (ARPDAU / revenue per active day at the end), because it is a half day.
- **Standard population**: not in the first album, not excluded, login ratio ≥ 0.5 on the last row before close, has a row on close−1.
- **Dice "album segment"** = final-prize code `album_reward_code` 1–7 (not Easy/Medium/Hard/Extreme).
- Dice album IDs jump by 2 (61, 63, …); the previous album = id − 2.
- Comparison albums: Dice 61/63, Domino 19/20 (17 where noted), Disney 14/15.
- Eden's target: about 10% of payers finish and finishers bring about 20–24% of total game purchase revenue during the album (= 30% of the old standard-population album revenue; restated 2026-10-21: Dice 20%, Domino 23%, Disney 24%); stronger players should finish more.

## Data (BigQuery)
- Projects: `dice-dreams-dbt`, `domino-dreams-dbt`, `solitaire-dreams-411507` (Disney). Pass the project on every call; write tables as `project.dataset.table`.
- Daily album tables: Dice `50_reporting.user_daily_album`; Domino `prod_40_mart.user_daily_album`; Disney `bi_prod.user_daily_album`.
- Sticker tables: Dice `30_intermediate.fact_user_album_stickers`; Domino `prod_30_intermediate.int_user_album_stickers`; Disney `bi_entity_prod.dim_user_album_stickers`.
- Dice: the daily album table does not update stickers on the close day — count close-day finishers from the sticker table.
- Exclusions: Dice `is_excluded`; Domino `special_user_flag` + `suspected_cheater_flag` (daily metrics); Disney `special_user_flag` + `exclude_reason` (daily metrics).
- In claude.ai this ran through the BIFROST BigQuery MCP server (and Mixpanel / Looker / Sheets servers). Claude Code needs the same MCP servers added (`claude mcp add …`) with the same company sign-in — ask the data team for the server URLs if they are not set up yet.
- That MCP's guardrail reads `alias.struct.field` as a table name: flatten STRUCT fields in a separate CTE. It blocks `SELECT *`.

## The deck
- Live deck (claude.ai Slides artifact, version 82): https://claude.ai/artifact/6UUb91x2vHULkaM4g73uQr — Claude Code reads and publishes it with the Artifact tool (`project/deck.json` + `project/slides/<id>.html`); re-read before every publish.
- Style: Eden's Deck Style Guide https://claude.ai/code/artifact/987682ea-ee39-493c-b5f8-4c28be9b2f0a — dark charcoal #212121, Oswald, gold #FFDF85 for the key concept, red #FF0B47 for problems, blue table headers #4285F4, footer "SuperPlay 2026".
- `claude/deck_v2_*.py` and `claude/deck_gen_x3.py` are the generator scripts used to build earlier versions.

## Docs added from the claude.ai Project (2026-10-20)
- `claude/claims-register.md` — what is valid / superseded / rejected (updated 2026-10-18). `claude/evidence-recheck-2026-10-18.md` wins where they conflict; its finisher numbers use the old rule (144 before the close day).
- `claude/album-analysis-v3-2026-10-15.md` — superseded by v4; history only.
- `claude/benchmark-queries.md` — Topic 4 rare-progression SQL for the three games + the Disney album-end ratio query; old payer rule (spend before the close day).

## Not in this repo
`agent-analysis-2026-10-14.md` is here but not in `claude/`.
`domino album onboarding.md` is here without its two embedded images.
Docs were copied text-for-text from the Project, not as original files; small differences are possible.

## Git
- Remote: https://github.com/Edenelm/album-cross-.git, branch `main`.
- Commit as `Edenelm <117096871+Edenelm@users.noreply.github.com>` — GitHub rejects pushes with the work email (email privacy).
