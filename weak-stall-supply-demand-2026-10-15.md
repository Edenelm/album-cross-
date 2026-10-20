# Supply vs demand — where weak players get stuck (Disney 14/15, Domino 19/20, Dice 61/63) — 2026-10-15

Question (Eden, follow-up to end-state-by-tier): weak players' revenue ends far (4+ missing) in Disney/Domino. Did they stop early (demand) or keep collecting and run out of time / rare stickers (supply/pace)?
Queries: StallDis (solitaire-dreams-411507, 23.1 GB) and StallDom (domino-dreams-dbt, 10.1 GB). Population and relative groups = RelDis/RelDom (weak = P0–50 of spend so far at last-quarter start among payers; strong = P95+). Only players who did not finish.
Definitions: stall day = first day the player reached his final missing count (any sticker type). After stall: active days (active_flag) / remaining pre-close days; spend after stall. All metrics revenue-weighted. Average of the two albums.

| Game | Group | End state | Stalled in last 10% of album | Stalled 75–90% | Days stuck | Active rate after stall | Revenue spent after stall | Revenue of those paying after stall | Missing Golden | Missing Royal | Missing total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Disney | Weak | 4+ | 65% | 32% | 3.1 | 67% | 2.4% | 11% | 5.0 | 3.2 | 11.1 |
| Disney | Weak | 1–3 | 60% | 38% | 3.2 | 95% | 7.2% | 26% | 1.5 | 0.9 | 2.5 |
| Disney | Strong | 4+ | 32% | 43% | 6.7 | 56% | 3.4% | 42% | 3.4 | 1.8 | 7.0 |
| Domino | Weak | 4+ | 69% | 26% | 3.3 | 54% | 1.6% | 8% | 5.0 | 4.3 | 10.8 |
| Domino | Weak | 1–3 | 94% | 7% | 1.4 | 94% | 3.7% | 21% | 0.8 | 1.6 | 2.4 |
| Domino | Strong | 4+ | 33% | 38% | 8.4 | 38% | 1.9% | 31% | 5.2 | 2.9 | 9.2 |

Album differences: Disney weak 4+ missing total 9.3 (14) vs 12.9 (15); Domino strong 4+ active after stall 47% (19) vs 29% (20). Other metrics stable.

## Reading
- Known: weak players stuck at 4+ did NOT stop early — ~95% kept gaining stickers into the last quarter, most into the last 10% of the album; only ~3 days with no progress before close.
- Known: but they end very far — ~11 missing, of which ~8 are Goldens + Royals (Disney 5.0 G + 3.2 R; Domino 5.0 G + 4.3 R). Commons are mostly done.
- Known: in the final days they are only partly active (54–67%) and barely pay (≤2.4% of their revenue after the stall).
- Known (contrast): strong players who end at 4+ stall earlier (only ~32% in the last 10%), stay stuck 7–8 days, and activity drops to 38–56% → closer to a give-up (demand) pattern.
- Not causal. Any change → A/B.

## By sticker type (StallTypeDis 20.4 GB / StallTypeDom 10.1 GB, 2026-10-15)
Stall day per type = first day the player reached his final count of that type (= day of his last new sticker of that type), as % of album length. Rare stall = later of Golden / Royal. Revenue-weighted, average of the two albums. Domino type sums match the total (player counts identical to StallDom).

| Game | Group | End state | Last new common | Last new Golden | Last new Royal | Rares frozen before last quarter | Rares frozen before commons | Days with no new rare | Active after rare freeze | Revenue after rare freeze |
|---|---|---|---|---|---|---|---|---|---|---|
| Disney | Weak | 4+ | 85% | 87% | 71% | 5% | 20% | 3.7 | 70% | 2.9% |
| Disney | Weak | 1–3 | 80% | 88% | 86% | 3% | 1% | 3.2 | 95% | 7.2% |
| Disney | Strong | 4+ | 75% | 76% | 65% | 33% | 23% | 7.9 | 60% | 5.1% |
| Domino | Weak | 4+ | 80% | 90% | 79% | 7% | 10% | 3.8 | 57% | 1.9% |
| Domino | Weak | 1–3 | 76% | 95% | 89% | 0% | 0% | 1.4 | 94% | 3.7% |
| Domino | Strong | 4+ | 69% | 79% | 70% | 32% | 11% | 8.9 | 40% | 2.4% |

Album difference: Disney weak 4+ "rares frozen before commons" 10% (14) vs 31% (15). Rest stable.

Reading:
- Known: the earlier caveat does not hold broadly — for weak 4+ players, rares did not freeze early while commons continued (only 5–7% of revenue had rares frozen before the last quarter; 10–20% froze rares before commons).
- Known: Goldens keep arriving almost to the end (87–90% of the album). Royals are the type that stops first: last new Royal at ~71% (Disney ≈ day 30 of 42) and ~79% (Domino ≈ day 38 of 49) → ~10–12 days with no new Royal, vs 86–89% for weak players who end at 1–3.
- Hypothesis: the weak-player gap at the end is mainly a slow overall pace plus a Royal drought in the last quarter; Goldens are still flowing. Candidate lever to test: a Royal source for the weak group in the last quarter / earlier Royal supply. A/B only.
- Strong 4+ again look different: rares frozen before the last quarter for ~1/3 of revenue, ~8–9 days with no new rare, activity down to 40–60% → give-up pattern.

## Dice comparison (StallDice, dice-dreams-dbt, 6.0 GB, 2026-10-15)
Same population/groups as RelDice (albums 61/63). Activity = is_active. Rare = later of Golden / Super (Supers = gate, 12 per album). Revenue-weighted, average of the two albums. Query shown and approved in chat.

| Group | End state | Stalled in last 10% | Days stuck | Active after stall | Revenue after stall | Last new common | Last new Golden | Last new Super | Rares frozen before last quarter | Missing Super | Missing total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Weak | 4+ | 79% | 2.0 | 44% | 0.8% | 86% | 89% | 87% | 4% | 4.7 | 11.2 |
| Weak | 1–3 | 80% | 1.7 | 94% | 2.7% | 81% | 89% | 92% | 0% | 1.7 | 2.5 |
| Strong | 4+ | 56% | 3.9 | 44% | 1.3% | 77% | 83% | 80% | 17% | 3.5 | 7.6 |

Album differences: weak 4+ active after stall 50% (61) vs 39% (63). Rest stable.

Reading (Dice vs Disney/Domino):
- Known: weak players who end far look the same in all three games — ~11 missing at the end, kept collecting into the last quarter, low activity and almost no spend after the stall.
- Known: the difference is the gate sticker's timing. Dice weak 4+ get their last new Super at ~87% of the album (~4–5 days before close); Disney/Domino weak 4+ get their last new Royal at 71% / 79% (~10–12 days before close).
- Known: the difference between games is how MUCH weak-group revenue ends far (4+ = Dice 41% vs Disney 83% / Domino 71%), not how far-off players behave.
- Hypothesis: the earlier/longer Royal drought in Disney/Domino may be part of why more weak revenue ends far there. Candidate test: Royal supply for the weak group in the last quarter. A/B only.

