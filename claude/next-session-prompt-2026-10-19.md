# Handoff prompt — album cross-studio analysis (updated 2026-10-20, late evening)

Paste this into the new conversation:

---

We are continuing the cross-studio album analysis (Dice Dreams, Domino Dreams, Disney Solitaire). Chat in Hebrew, deck text in simple English. Don't ask before running queries; dry-run first, then run.

**Read first:** `claude/payer-close-day-2026-10-20.md` and `claude/remaining-recounts-2026-10-20.md` (latest), `claude/finisher-recount-2026-10-19.md`, then `claude/post-album-events-2026-10-19.md`, then `INDEX.md` and `decisions-definitions-register.md`.

**Definition decided by Eden (2026-10-19):** finisher = 144 unique set stickers by the END of the close day (close day included), not the game flag. The close day is left out only of daily averages (ARPDAU / revenue per active day at the end), because it is a half day. Dice: the daily album table does not update stickers on the close day — count close-day finishers from `30_intermediate.fact_user_album_stickers`.

**Payer decided by Eden (2026-10-20):** payer = paid on any album day, close day included; close-day spend is not added to album revenue. Impact is tiny (payers +0.2–0.4%, rates and revenue shares unchanged); see `claude/payer-close-day-2026-10-20.md`. Deck v67.

**Done:**
- Recount in three waves (2026-10-19) + the remaining recounts (2026-10-20): every finisher number in the deck now uses the new rule. Old rule reproduces the deck in every query, so the deltas are the definition only. No message changed.
- Remaining recounts (2026-10-20): last sticker via Wild / Joker 89% / 95% / 79% (Dice paid Wild 61–71%; Domino 17 41%); finishers' spend on the last full day ×2.3 / 1.8 / 2.1 and pay rate last 3 days ×1.8 / 1.5 / 1.6 (close-day finishers lift less); finish rate by route bought 59 / 62 / 63%, gameplay only 12 / 39 / 58%, none 2 / 4 / 2% (all via a close-day Wild / Joker); Domino 20 two-Puzzle closers 3,223 → 3,991 (1,490 paid), strong 393 → 520, $367K = 2.3%, stake $13–26K.
- Headline: payer finish rate Dice 11.2%, Domino 7.7%, Disney 5.2%; finishers' revenue share 29% / 30% / 21%.
- Deck version 66 (2026-10-20): 11 slides updated by the remaining recounts. Earlier: v54 (28 slides to the new definition), v56–62 Dice grand-prize story in Chapter 5 (seg-return by album segment 1–7, prize-fit table by segment, seg7-top: $700+ payers in segment 7 = 1,427 players, 0.32% of players, 11.7% of revenue, prize lasts 1.4 days; prize-rec Recommendation A: 250K / 350K tiers for stable top payers, sized by daily rolls), v65 stand4 shows 3 days before close. Eden wants little text on slides: message + key number on the slide, detail in notes. Deck: https://claude.ai/artifact/6UUb91x2vHULkaM4g73uQr

**Where we stand (post-album / finishers):**
- Dice is the only game where payer finishers return to buying below their own habit; the gap sits in late finishers and in Light/Mid veterans with a big grand prize (codes 4–7). Driver = the roll stock from the grand prize.
- Recommendation A (bigger prize for stable top payers) is in the deck. B (Split prize / Grand Prize Rush) rejected by Eden; no replacement yet.
- The proposal docs (dice_album_grand_prize_findings.md / _test_proposal.md) are not in the project; the deck uses the tiers as summarised in post-album-events. Check the exact tiers / groups against the proposal if Eden shares it.
- Post-album events carry early finishers' spend but do not explain the Dice gap. Deluxe DiD: ~15% of Deluxe spend looks added (estimate); only a holdout would prove it.

**Open:**
- A replacement test idea for Dice Light/Mid veterans (make them burn rolls / return faster).
- stand-move repeats stand4's 4→3 move; Eden has not decided whether to remove it.
- Not rerun (noted in notes): dice-close card "78–84% of final Supers via Wild" and the Golden-sale card (population incl. first album); routes slide spend ratios (matched round 4, query not saved; not definition-dependent); 89% above-CZ and ~3% offers for the old 393 strong closers.
- GitHub repo https://github.com/Edenelm/album-cross-.git: push still blocked until the repo is added to the session sources.

**Working rules:** BigQuery projects dice-dreams-dbt / domino-dreams-dbt / solitaire-dreams-411507 (pass project= on every call); the BigQuery MCP guardrail reads `alias.struct.field` as a table name — flatten STRUCT fields in a separate CTE; album-day revenue = album-table spend column; non-payer = did not pay during the album, close day included; Dice album IDs jump by 2; Dice "album segment" = final-prize code 1–7; every population shows players, share and album revenue share; separate fact / interpretation / hypothesis. Re-read the deck live before any republish. Slide renders: Oswald woff2 from npm @fontsource-variable/oswald.
