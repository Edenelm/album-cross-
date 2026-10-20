# Handoff prompt — album cross-studio analysis (2026-10-20, end of day)

Continue the cross-studio album analysis (Dice Dreams, Domino Dreams, Disney Solitaire). Chat in Hebrew, deck text in simple English. Read `CLAUDE.md` first, then this file.

## Where the deck stands
- Live deck: https://claude.ai/artifact/6UUb91x2vHULkaM4g73uQr — version 72 (89 slides). Claude Code can read and publish it with the Artifact tool (`project/deck.json` + `project/slides/<id>.html`); re-read before every publish.
- Built as a story (approved by Eden 2026-10-20, `claude/storyline-2026-10-20.md`): opening (story in one slide, chapter map) → Ch1 where the album makes money → Ch2 who is where at the end → Ch3 how the album gets closed → Ch4 those left behind → Ch5 after the album → Ch6 three game cases (Domino 20, Dice grand prize, Disney gate) → Ch7 what to do → method → appendix (nothing deleted). Slide titles are messages; each chapter divider has an "Answer:" line.
- Eden's rules for slides: big message headline, a chart that shows the message, recommendations and conclusions; every population shows its share of album revenue; normalize when games differ (e.g. number of rares); show one album per game where she asked (rare-timeline).

## Done today (all in `claude/`, all committed and pushed on branch claude/album-analysis-continuation-fb8c4f, PR https://github.com/Edenelm/album-cross-/pull/1)
- `deck-review-2026-10-20.md` — full deck review; Dice grand-prize slides rerun with the 144-only finisher rule + a no-prize comparison (late finishers with prize codes 4–7 buy 4–8 pts later than no-prize payers in albums 59/61/63; Light/Mid code 7: 7–11 pts; $700+ no delay).
- `revshare-fill-2026-10-20.md` — revenue share for every population (Disney test-1 group = 62–63% of album revenue).
- `dryness-last-week-2026-10-20.md` — Disney near players go dry a week out with nothing to buy (hypothesis "Disney never goes dry" rejected); plus Dice after-close checks: free rolls, spend, and total payout by end status.
- `rare-timeline-2026-10-20.md` — median payer rare timeline, normalized: per rare the pace is similar; the real gap is the longest wait (Dice 14% of the album vs Domino 30% / Disney 35%).
- Grand-prize docs (Eden's, in the dice_dreams_ba repo `analysis/album_grand_prize/`) are in the deck (prize-tier, prize-return, prize-domino, prize-rec).

## Open — start here
1. **Payout by the Mixpanel definitions (Eden: "adapt yourself to the Mixpanel definitions").**
   - **Dice** (board "Payout Monitoring" 10105792, tile "Payout" bookmark 80568688): Payout % = (B − C) / A × 100.
     A = Sum of "Bet multiplier + prime Cost" on `roll` (bet_mult in the listed values).
     B = Sum of `amount` on `rolls in`, amount 1–750,000, custom property "Rolls In - Source (Grouped)" (id 11919) NOT in RV, Roll Timer, Daily Gift & Anti-Churn, Invite Friends, Deep Links, Pending Reward, DDJ.
     C = Sum of `amount` on `rolls in`, amount 1–750,000, custom property "Source (Purchase Complete)" (id 9113) ≠ Others.
     Filter: cohort "had roll balance greater then 1.2M" (5834170) excluded; the board also excludes `excluded_reason` set and events with amount > 1M.
     The 11919 / 9113 formulas use source, subsource, campaign_name, reward_syntax_final, event_name, placement, purchase_sku — read them with `Get-Custom-Property` and port them to SQL.
     Curated `20_core.rolls_in_out_vw` lacks campaign_name / subsource, so an exact port needs the raw Mixpanel tables (dice-dreams.mp_dice_dreams_prod.rolls_in / roll) — ask Eden before using raw/staging. An approximate version (source names only, purchases from `purchase_completed_vw`, 220 GB) is the last-but-one section of `claude/dryness_last_week_queries.sql`; Eden saw it and said yes to running, then asked to match Mixpanel exactly — confirm which before running.
   - **Disney RTP** (Eden's link = unsaved Insights "Total RTP for Level Starts with Coins in/Out Filters"; same structure as saved report 91373288 "Total RTP - Trend"): RTP = (C − B) / A, sums of "Coins in Allowance" (custom property 5560156):
     A = `coins out` source = "level start"; B = `coins out` source in extra tiles / undo / wild / trade; C = `coins in` from the ~60 gameplay sources listed in that report (album completed, album set completed, level completed, marketplace, duplicates, events…), MTX campaign name not containing "offer" or "store".
     Every event: Coins in Allowance 0–1,000 and coins_balance_in_allowance 0–5,000. (The saved report also has Level ID ≥ 100 and a T122 breakdown; Eden's link has neither.)
     Needs Disney raw Mixpanel views (`solitaire-dreams-411507.mp_raw_prod_vw`) — ask Eden for approval first.
   - **Domino:** definition not shared yet — ask Eden for the Mixpanel link.
   - Goal: daily payout by album end status (finished / 1 short / 2–3 short / 4+ short), days close−3..close+7 vs mid album, with each group's share of album revenue; then show whether low payout after close shows up in spend (Dice spend check already done: days 1–3 ×0.79–0.90 for finishers and near-missers, ×1.0 for far players).
   - Then replace the deck slide `payout-near` (free-rolls index, not the Mixpanel payout) with the Mixpanel-definition payout.
2. Album-payout metric in Eden's ODS file differs per game (Domino "Pay Out – Album" fraction, Dice "Payout (With all Purchases)", Disney "Album RTP") — deck shows shape only, not level comparisons.
3. Still open from the review: album-effect revenue shares; INDEX.md not updated with today's docs; deck-structure-2026-10-20.md is superseded by storyline-2026-10-20.md.

## Working rules (unchanged)
BigQuery projects dice-dreams-dbt / domino-dreams-dbt / solitaire-dreams-411507 (write tables fully qualified); dry-run first; queries saved in `claude/*.sql` with a results doc; finisher = 144 by the end of the close day; payer = paid on any album day incl. close day; album revenue = album-table spend start..close−1; standard population; separate fact / interpretation / hypothesis; whole numbers; every population with its share of album revenue. Heavy queries (≈100 GB+) and raw/staging datasets: ask Eden first. Commit as Edenelm <117096871+Edenelm@users.noreply.github.com>.
