# Session log — 2026-10-14

## What ran
- Multi-agent workflow from `claude/agent-analysts-kickoff-prompt.md`: Dice, Domino, Disney and Cross-game analysts ran in parallel on BigQuery. A Critic then reviewed every claim and re-ran 3 key numbers. 5 agents, 0 errors.
- Full output: `claude/agent-analysis-2026-10-14.md` (Hebrew synthesis, then each agent's raw output with SQL appendices).

## Key decisions / corrections (supersede earlier docs)
- **Finish-rate standard:** 144 unique set stickers before close, with the close day excluded. Do not use game flags. Dice PU (not-first) finish rate: 8.1% / 10.5% (was 11.5% / 13.5% by flag). Domino: 5.7% / 4.5%. Disney: 3.8% / 4.1%.
- **Domino revenue column:** `album_spent_today` is gross revenue (ratio 0.99 to in-app + Stripe). Closed. The dbt doc saying "coins" is wrong.
- **Domino ARPDAU:** compute on active days (`active_flag`), not rows. Row-based levels are ~10% low.
- **Domino gate:** the final gate is release phase 6, not Royals. Album 17 is Golden-led; album 19 is Royal-led.
- **Disney gate:** the final gate is a locked trio, Royal 131 + 2 Goldens. The album-end "lift" is a 0.87× / 0.94× dip against matched weekdays.
- **Dice:** the "purchase → last Super" timing is Known, but causation stays Needs Validation (the placebo was too weak). Item 2 remains open.
- **Release-timing levers (all games):** Do Not Adopt Yet until each studio confirms its release calendar.

## Open next steps
1. Re-run Domino ARPDAU levels on active days.
2. Run the Dice placebo using the last Golden/Common pull in the same window.
3. Check the Disney revenue column (USD?).
4. Reword causal chart titles.
5. Request release calendars from all 3 studios.

---

## Second session (later 2026-10-14) — Dice placebo + album SEGMENTATION (Dice validation → Disney build)
Docs: `claude/dice-supers-mechanism-onepager-2026-10-12.md` (§5a), `claude/dice_supers_placebo_q5c.sql`, `claude/dice-segmentation-validation-2026-10-14.md` + `claude/dice_segmentation_validation_queries.sql`, `claude/disney-segmentation-build-2026-10-14.md` + `claude/disney_segmentation_queries.sql`. Next-session prompt for this thread: `claude/next-session-prompt-segmentation.md`.

### Dice placebo (one-pager §5a)
- Same player, same clock time −24h/−48h: purchase ≤10 min before the last Super 62–71% vs 0–3% placebo. Timing link Known; still no shared ID → not causal. (Note: the critic's open item 2 above proposes a stronger placebo — last Golden/Common pull; still open.)

### Dice segmentation validation (Known unless noted)
- Team uses the OUTPUT of the super-segment query in the last quarter (not the stored column); start date + album length are updated per album (61 = 35, 63 = 42).
- Pre-album difficulty: right for 84% of Easy payers, only 43–60% for Medium/Hard/Extreme; ~15% of Easy payers spend like Medium+.
- Spend curve: Hard/Extreme fit; Easy curve badly off (72–73% spent at last-quarter start vs 59–60% expected) → 6–8% of Easy payers one tier too high.
- Stored `album_super_segment_code` does not match the query (24–53% agreement in 61) → dashboards splitting by it may differ from targeting.
- Album 63 vs team goal table (tracker-aligned, day-4-to-end, revenue share): Easy above goal (+7 to +19); Medium on goal at tiers 1/3; Hard/Extreme under (−5 to −17), worst at tier 5.
- Verdict: keep the structure, revise (refit curves each album, one length base, align stored column); injection changes → A/B.

### Goal logic (Eden)
- Goal = bring each population to ≤3 stickers missing (of 144) at 4/3 days to end; target share differs by population; measured as REVENUE share (revenue album start → measurement day).

### Disney build (Eden decisions)
- Adopt the Dice method in Disney (no definition exists; `album_segment` = "def_default"). Spend only. Thresholds = management decision, not a copy of Dice shares.
- Chosen: option C levels by $/day of history: ≤2 / 2–5 / 5–20 / >20. Last-album history is as good as a 3-album average → use last album.
- Findings: reach of ≤3 missing at close−4 by level ≈ 24–28% / 34–37% / 50% / 67–69%; level 1 keeps 97% of players but ~57% of its revenue comes from the 3% who move up → daily tier required; spend pace is near-linear and stable across albums.
- Status: build full segmentation, Test vs current injections (A/B). Earlier Royal-trio release lever stays a separate Test.

### Next (segmentation thread)
- Disney D5: daily tier inside each level — projected album spend at last-quarter start = spend so far ÷ level curve; decision table (bins of projection × revenue share × ≤3-missing reach at close−4) → management picks tier cuts.
- Then: Disney D6 shadow tier daily for one album; Domino same process; Dice fixes list to the studio.

