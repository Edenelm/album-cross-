# Deck storyline v4 — proposal for review (2026-10-20)

Supersedes v3 (same file) and the chapter order in `storyline-2026-10-20.md` once approved. Nothing is deleted.

## Deck-wide rules (Eden, 2026-10-20)
1. **Every population = size + share of total game revenue during the album**, side by side, in the slide body.
   Denominator (proposal, one for the whole deck): **all in-game revenue of all players on album days, album start .. close−1** ("total game revenue during the album").
   Current slides use a smaller denominator — the standard population's album revenue. Every share gets re-based (see "Data work"); until then each slide labels which one it shows.
2. **Seasons:** show 2–3 seasons only when the difference between them is part of the message. Otherwise one number per game — the average of comparable albums, or the latest completed album — and the subtitle says which.
3. Title = message, one key number on the slide, detail in the notes.

## Opening (fixed order, Eden)
| # | Section | Shows | Season approach | Status |
|---|---|---|---|---|
| A | **The three albums, side by side** | Comparison table: album length; total stickers (144 in sets + Pixie 12 / Magic 36 outside); commons / goldens / rares (104/28/12 · 107–108/28/8–9 · 113/24/7); rare share (8% / 6% / 5%); number of sets; content-unlock timing (Dice Pixie phase; Domino 6 release phases; Disney —); end gate; end tool (Wild / Joker / Joker from Market); album unlock (kingdom 8 / level 35 / level 100) | Latest completed album per game | Partly ready (`album-chapter0-baseline-facts`). **Missing: number of sets, unlock timing** |
| B | **September revenue by album experience** | Share of September game revenue (and players) by how many albums the player has experienced: 1st, 2nd, 3rd, 4th, 5th, 6th, 7+, plus a separate "installed before Apr 2025" row. Aggregation: player's count of albums started by 30 Sep; all in-game revenue in September; active ≥1 day in September | One month, no seasons | Coarse version exists (1 / 2–3 / 4–6 / 7+, Dice + Domino rerun, Disney older table). **Needs rerun by single album number, all three games** |
| C | **End-of-album ARPDAU by album experience** | Avg ARPDAU of the last 4 full days (close−4..−1), by the ordinal album the player is in (their 1st, 2nd, 3rd…), vs the same players' album average. Clearly labeled: "player's Nth album", not the game's album ID | Average of comparable albums | **New query** |
| D | **Every album ends higher, except Disney in 2026** | End lift per album (last 4 days ÷ album average) | Seasons — here the trend across albums IS the message | Ready (`end-growth`, `album-length-end-arpdau-2026-10-18.md`) |

## After the opening — proposed order and why
| # | Chapter | Business question | Why it comes here | Main slides | Season approach |
|---|---|---|---|---|---|
| 1 | **Who is where at the end** | Who makes the end lift? | D shows money peaks at the end → who is there: few finishers with 21–34% of revenue, most end money still far, and the album ends on a few late rare stickers | target, stand4, far-revenue, progression, gates | Average (finisher rates differ little); Domino 20 noted |
| 2 | **Where rare stickers come from** | How does each game hand out Supers / Royals? | Ch 1 ends on "the last stickers are rares" → where do rares come from: Dice drips through one always-on Trail and controls who gets the last Supers; Domino pulses via events, then duplicate exchange; Disney spreads few Royals over changing events, longest wait 28–35% of the album vs 14% in Dice | sources, rare-timeline, royal-dip, NEW rare-sources-mix, NEW rare-mechanics | Latest album (mix is stable); Domino 19 vs 20 only if it differs |
| 3 | **How the album gets closed** | What actually closes it? | With that supply, the close happens in the last 4 days with a Wild / Joker reaching the near; Disney goes dry a week out; in Domino a **free RV path** closes it for non-payers | last3days, closing-week, tool-reach, half-completions, same-spend, dryness, tangled, NEW rv-path, nonpayer-share | Latest album; RV = Domino 20 (the season where it matters) |
| 4 | **Those left behind** | What happens to players who don't close? | The close reaches only the near → the far fade, heavy near-missers slow down | royal-dip moves to Ch 2; keep-playing, heavy-missers, give-up, staircase | Average |
| 5 | **After the album** | Does finishing use a player up, and what does the next album give back? | Finishers aren't used up, but the next album opens with almost no payback, and in Disney / Domino finishers get a weaker game (−12% to −19% per player) | finishers-hold, next-album, payout-after, payout-near, dice-lastday | payout-near shows both seasons (they agree, ranges small) → simplify to average |
| 6 | **Three game cases** | Do the levers we see actually move money? | Each case tests one lever from Ch 2–5 | domino-3albums … disney-finishers | Seasons — the season changes ARE the cases |
| 7 | **What each game should do** | What should each team change? | Closes the chain: finding → change → why → status | NEW one slide per game, then decisions, tests, targets | — |

### Chapter 7 — recommendations (draft, each tied to a finding)
**Disney**
- More Royals and more chances to get one through the album → longest wait 28–35%, no new rares ~7 days before the gate, dryness a week out. *Test.*
- Let a Royal drop from a regular pack / bundle for eligible players without promising it up front (Dice-style), instead of only from a pack shown as a Royal pack → one offer serves different players, rare supply tunable per player. *Product change → test.* (Mechanism per Eden; data check offered.)
- Soft landing for finishers and 1-short in days 1–3 of the next album → −13% to −19% per player, finishers 21–22% of revenue (current basis). *Test.*

**Domino**
- Cap RV views per day / album; take sticker packs and Puzzle pieces out of the RV badge → 43% of album-20 finishers never paid; RV gave ~18 stickers each plus Puzzle fuel; one view ≈ $0.002; revenue at risk ≈ $45K ≈ 0.35% of album revenue. *Test.*
- One-vs-two Joker test → both readings fit. *Test.*
- Head start in the first event of the new album for players near the end → payout −12% / −19%, the gap is event rewards. *Test.*

**Dice**
- 250K / 350K grand prize for stable top payers → smaller share back, 11% of revenue. *Test.*
- No payout change after close → the typical finisher does not drop. *Do not adopt.*
- Watch heavy late finishers' spend in days 1–14 → they start the next album slowest. *Measure.*

## Data work before building (each needs a run)
1. Structure table: number of sets per game and content-unlock timing — from the album config / team (not in our docs).
2. Section B: September revenue by single album number, three games, total game revenue denominator (~curated, light).
3. Section C: last-4-days ARPDAU by player's Nth album (curated album tables, ~50–80 GB per game).
4. Re-base every population share in the deck to total game revenue during the album (curated, light per slide).
5. Optional: check the rare-pack mechanism in data (Disney pack type of every Royal; Dice Super delivery inside bundles by segment).
