# Cross-game album comparison — working framework (Eden, 2026-10-07)

## Objective
Understand album differences across Dice Dreams, Domino Dreams, Disney Solitaire; find what each studio does well; decide which mechanics could be adapted elsewhere.
A mechanic existing in one game is NOT enough to recommend it. Before any recommendation:
1. Define the difference. 2. State the hypothesis about its impact. 3. Check data support. 4. Separate mechanic effect from population / game pace / economy differences. 5. Only then suggest adaptation. 6. If evidence is insufficient → propose an A/B test, not a proven recommendation.

## Terminology
Dice rare = Super; Domino/Disney rare = Royal. Don't assume same difficulty/role — check count, release timing, sources, drop rates, how much they block set/album completion. Shared term: `Rare Sticker` (keep original names too).

## Working method
One topic at a time; don't move on until Eden says continue. Analyse each topic on its own — do not link findings across topics while working; cross-topic dependencies are reviewed only after all topics are done (Eden, 2026-10-07). Per topic:
1. Comparison table across the 3 games. 2. Label each item Known / Needs Validation / Missing / Hypothesis. 3. Main analytical question. 4. Population, numerator, denominator, window. 5. Data needed per game. 6. Minimum quick analysis. 7. One main chart/table for the deck. 8. Biases / differences that could mislead. 9. Results that would support vs contradict adapting. 10. Adaptation per game only if data supports. 11. End with: preliminary conclusion, missing info, next step, slide title with no unsupported claim.
One main message + one primary visualization per topic.

## Topics
1. First album unlock point (Dice Kingdom 8, Domino Level 35, Disney Level 100) — active days / calendar days install→first album exposure for payers; P50/P75; % reaching within 7/14/30/60/90 days; % never; survivorship bias.
2. Current population by albums experienced (last-month avg): groups 1st, 2–3, 4–6, 7+; share, revenue share, payer share, ARPU/ARPPU, active days, current completion. Experienced album = actual exposure.
3. Album duration: total days, days all content available, days rare locked, ending period length, launch frequency; ARPDAU album-ending weekend vs avg of previous 14 days (excl. ending weekend). Longer ≠ easier — check content release, pack and new-sticker pace.
4. Number of Supers/Royals and collection pace: count, share of stickers, new vs total rare received, new-rare rate, days between new rares; daily rare_stickers_received_daily, new_rare_stickers_daily, duplicate_rare_stickers_daily, new_rare_sticker_rate, cumulative_unique_rare_stickers, rare_sticker_collection_percentage; P50/P75; by % of album time AND normalized 42-day axis (keep real pace changes).
5. Rare sticker sources: Dice = regular packs + Super Packs; Disney = Royal Packs only (not Common); Domino = TBD. Map pack types, drop rate, guaranteed vs probabilistic, free/purchasable, direct grants, availability timing, new vs duplicates per source.
6. Packs per paying player per day: per active day, P50/P75, % with ≥1 pack, by pack type, total/new stickers, new sticker rate; two views (all active payer-days vs pack days only).
7. Completion reward segmentation: rewards, assignment, variables, timing, can change mid-album, player/revenue share per segment, completion per segment, reward value vs player economy.
8. Locked stickers / completion blockers: Dice 3 (2 Supers + 1 Golden); Domino 5 Easy / 3 Hard (Hard: 2 Royals + 1 Golden); Disney 3 (1 Royal + 2 Goldens). Validate locked vs rare, release, sources, free/sold, players blocked, time to acquire, share of finishers who paid for it.
9. Releasing locked stickers near end: release day, days remaining, sale start, free availability, daily receivers, new vs dup, % completing set / album because of it.
10. Early finishers experience: prestige album, new feature, continued packs, pack conversion, extra goals, album revenue after finish, avg days finish→end. (Domino has prod_40_mart.user_daily_deluxe_album / _set — possible prestige album.)
11. Post-album payout for non-finishers: stickers/duplicates, album currency, auto-conversion and rate, progress-based, cap, % receiving, value; separate group with no balance.
12. Progression pace, completion, near-finishers: daily P50/P75 completion %, % reaching 25/50/75/100%, cumulative completion, missing 1 / 2–3 / one set, blocker sticker type, days spent as near-finisher.
13. Album design vs business outcomes: by progress group (0–25/25–50/50–75/75–99/Finished): share, payer rate, ARPU, ARPPU, revenue share, active days, retention, album revenue, completion. Not causal — control for pre-album performance, tenure, level, purchase history, prior albums, normal activity; else A/B test.

## Final deck order
1. Album structure differences 2. Population & first exposure 3. Pack/sticker pace 4. Rare stickers & sources 5. Locks, ending period, completion 6. Rewards for finishers & non-finishers 7. Impact on progression/engagement/monetization 8. What each game does well 9. What each studio can learn 10. Supported recommendations vs A/B tests.

Decision table: | Mechanic | Source game | Target game | Evidence | Risk | Required validation | Recommended action |
Statuses only: Adopt / Test / Do Not Adopt Yet.

| Mechanic | Source game | Target game | Evidence | Risk | Required validation | Recommended action |
|---|---|---|---|---|---|---|
| Earlier first-album gate | Domino (L35, median 1 active day to album) | Dice, Disney | Exposure speed differs (median 1 vs 3 active days) but no link to retention shown; appendix: payers who miss the album are 82–94% early churners, mostly far below the gate; only 0.1–0.7% of 7-day payers stay active near the gate | Exposing album before core loop is learned; economy impact | A/B test on gate level (Disney first, if pursued) | Do Not Adopt Yet |


## Topic 1 — Time to first album exposure (revised 2026-10-07)
**Question:** Among players who experienced their first album, how quickly did they get there?
Reach-rates, never-reached and gate-placement work are appendix context only (see Appendix A).

### Definitions (Eden)
- Population: installs 2026-03-01 → 2026-06-30 who experienced their first album within 90 days (calendar day 0–89); special/excluded users removed.
- Groups: (1) All first-album players. (2) Payers before album exposure = first purchase on or before the first-album calendar day. Purchases after exposure never count. **Main table = group 2.**
- Calendar days: install day = 0. Active days: install day = active day 1; counts active days from install through first-album day inclusive.
- "Within N active days" denominator = players in that group who experienced the first album within 90 days.
- Retention benchmark (context only, no causal claim): all eligible installs with day-0 activity; active exactly on calendar day 1 / 3 / 7 / 14 / 30.

### Sources
| | Dice (dice-dreams-dbt) | Domino (domino-dreams-dbt) | Disney (solitaire-dreams-411507) |
|---|---|---|---|
| Install | 50_reporting.user_profile.install_date | MIN(prod_40_mart.user_daily_metrics.first_seen_date) | bi_prod.user_profile.install_date |
| First album | MIN(30_intermediate.album_pop.user_album_start_date) where user_past_album_count = 0, is_excluded = FALSE | prod_40_mart.user_daily_album.user_album_start_date where user_album_count = 1 | bi_prod.user_daily_album.user_album_start_date where user_album_count = 1 |
| Active day | row in 50_reporting.user_daily_metrics_agg | sessions_today > 0 | row in bi_prod.solitaire_user_daily_metrics_agg_df |
| Payment | revenues_sum > 0 | number_of_purchases_today > 0 | trx_cnt > 0 |
| Exclusions | UDM view + album_pop.is_excluded | special_user_flag = FALSE, suspected_cheater_flag not TRUE | exclude_reason IS NULL |

### Validation
- Gates on first-album day: Dice 99.7% ≥ K8, Domino 99.8% ≥ L35, Disney 99.4% ≥ L100.
- Every first-album player has ≥ 1 active day before/at album (act0 = 0 in all games). Disney: 3 first-album players lack a day-0 row (negligible).
- Disney user_album_count clean. Dice user_past_album_count also tags returning players; OK for 2026 installs.

### Main table — Payers before album exposure
| Game | Players who experienced first album | Calendar P50 | Calendar P75 | Active P50 | Active P75 | Within 3 active days | Within 7 active days |
|---|---:|---:|---:|---:|---:|---:|---:|
| Dice | 142,592 | 2 | 8 | 3 | 6 | 60.5% | 79.5% |
| Domino | 63,459 | 0 | 1 | 1 | 2 | 94.5% | 99.4% |
| Disney | 505,374 | 3 | 6 | 3 | 5 | 51.4% | 87.8% |

### Supporting table — All first-album players
| Game | Players who experienced first album | Calendar P50 | Calendar P75 | Active P50 | Active P75 | Within 3 active days | Within 7 active days |
|---|---:|---:|---:|---:|---:|---:|---:|
| Dice | 639,192 | 4 | 9 | 4 | 6 | 43.4% | 80.9% |
| Domino | 1,103,046 | 0 | 2 | 1 | 2 | 89.4% | 98.8% |
| Disney | 2,092,742 | 4 | 9 | 5 | 7 | 34.0% | 75.6% |

### Full distribution
| Game / group | Cal P25 / P50 / P75 / P90 | Cal avg | Active P25 / P50 / P75 / P90 | Active avg | Within 1 / 3 / 7 / 14 / 30 active days |
|---|---|---:|---|---:|---|
| Dice — payers before | 1 / 2 / 8 / 29 | 7.94 | 2 / 3 / 6 / 23 | 6.88 | 21.7 / 60.5 / 79.5 / 85.7 / 94.0% |
| Dice — all | 2 / 4 / 9 / 24 | 8.56 | 2 / 4 / 6 / 10 | 6.01 | 9.6 / 43.4 / 80.9 / 92.9 / 97.3% |
| Domino — payers before | 0 / 0 / 1 / 3 | 1.51 | 1 / 1 / 2 / 3 | 1.66 | 60.0 / 94.5 / 99.4 / 99.9 / 100.0% |
| Domino — all | 0 / 0 / 2 / 5 | 2.57 | 1 / 1 / 2 / 4 | 1.96 | 51.8 / 89.4 / 98.8 / 99.9 / 100.0% |
| Disney — payers before | 1 / 3 / 6 / 12 | 5.69 | 2 / 3 / 5 / 8 | 4.27 | 10.1 / 51.4 / 87.8 / 98.8 / 99.9% |
| Disney — all | 2 / 4 / 9 / 20 | 8.45 | 3 / 5 / 7 / 10 | 5.70 | 5.5 / 34.0 / 75.6 / 96.6 / 99.8% |

Payers before album as share of first-album players: Dice 22.3%, Domino 5.8%, Disney 24.1%.

### Retention benchmark — all eligible installs (context only)
| Game | Installs (day-0 active) | D1 | D3 | D7 | D14 | D30 |
|---|---:|---:|---:|---:|---:|---:|
| Dice | 3,112,771 | 31.6% | 20.1% | 14.5% | 10.3% | 6.4% |
| Domino | 4,179,120 | 27.5% | 17.2% | 12.4% | 8.9% | 6.0% |
| Disney | 12,652,817 | 30.1% | 19.5% | 14.7% | 11.3% | 8.3% |

### Findings (Known)
- Fastest exposure: Domino. Payers before album reach it at a median of 1 active day (calendar day 0); Dice and Disney at 3 active days.
- Active-day gap at the median: 2 active days (Domino vs Dice/Disney). At P75: Domino 2, Disney 5, Dice 6.
- Median vs tail: Disney is tight (P75 5, P90 8; 98.8% within 14 active days). Dice payers have a long tail (P90 23 active days; 14.3% need more than 14 active days) even though the median is the same as Disney.
- Retention: the faster-exposure game (Domino) does not show higher early retention — it is lowest at D1–D14 and similar at D30. Disney is highest from D7 onward. No causal link is claimed in either direction.

### Needs Validation
- Same-day ordering: "paid on or before album day" includes purchases on the album day that may come after exposure. In Domino (album usually on install day) this group is effectively day-0 payers — only 5.8% of first-album players vs 22–24% elsewhere. Validate with event timestamps.
- Dice payer tail (P90 23 active days): check whether returning/reinstalled players or album_pop gaps drive it.
- Activity definition differs (Domino sessions_today > 0; Dice/Disney row existence) — affects active-day counts and retention.

### Recommended main chart
Horizontal percentile-range chart, one row per game, active days to first album, payers before album: bar P25→P75, tick at P50, dot at P90. Optional faded second bar per game for all first-album players. No non-reachers.

### Slide title (neutral)
"Time to first album: median 1 active day in Domino, 3 in Dice and Disney (payers before exposure)"

### Preliminary conclusion
Domino exposes the album almost immediately; Dice and Disney after ~3 active days, with Dice showing a longer tail. This is descriptive only. Any test of earlier exposure must be an A/B test on the gate; retention differences between games cannot be attributed to exposure speed.

## Appendix A — Reach rates and non-reachers (context only)
### A1. First-pass results (reach rates) — installs Mar–Jun 2026
| Metric | Dice | Domino | Disney |
|---|---|---|---|
| Installs | 3,112,771 | 4,179,120 | 12,652,967 |
| All installs reaching album in 7 / 14 / 30 / 60 / 90 days | 13.4 / 16.9 / 19.0 / 20.3 / 20.5% | 24.1 / 25.3 / 25.9 / 26.3 / 26.4% | 10.6 / 13.9 / 15.6 / 16.3 / 16.5% |
| Reachers: calendar days P50 / P75 | 4 / 9 | 0 / 2 | 4 / 9 |
| Reachers: active days P50 / P75 | 4 / 6 | 1 / 2 | 5 / 7 |
| Payers by checkpoint reaching album 7 / 14 / 30 / 60 / 90 | 70.1 / 75.7 / 81.4 / 86.8 / 87.2% | 94.3 / 95.3 / 95.8 / 96.1 / 96.2% | 74.4 / 81.3 / 84.6 / 86.0 / 86.5% |
| Payer reachers: calendar P50 / P75 | 2 / 7 | 0 / 1 | 3 / 6 |
| Payer reachers: active P50 / P75 | 3 / 6 | 1 / 2 | 4 / 6 |
| Of players active on day 30–37, reached album within 90d | 88.6% | 89.9% | 79.7% |

### A2. Follow-up (2026-10-07): payers who never reach the first album
Same cohort and exclusions (installs Mar 1 – Jun 30 2026, 90-day window). "By day N" = album started on install day 0 … N−1 (calendar days since install < N).

**Fixed payer cohort** = first purchase on install day 0–6 (first seven calendar days). Denominator no longer changes over time.

| Game | Fixed payer cohort | Reached by D7 | Reached by D14 | Reached by D30 | Reached by D60 | Reached by D90 | Did not reach by D90 | Non-reachers active D30–37 | Non-reachers active D83–90 | Median distance from gate |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Dice | 177,771 | 124,637 (70.1%) | 132,913 (74.8%) | 141,261 (79.5%) | 148,422 (83.5%) | 148,617 (83.6%) | 29,154 (16.4%) | 659 (2.3%) | 182 (0.6%) | 4 Kingdoms (max K4 vs gate K8) |
| Domino | 141,229 | 133,107 (94.2%) | 133,694 (94.7%) | 133,952 (94.8%) | 134,053 (94.9%) | 134,084 (94.9%) | 7,145 (5.1%) | 307 (4.3%) | 68 (1.0%) | 19 levels (max L16 vs gate L35) |
| Disney | 634,998 | 472,534 (74.4%) | 511,167 (80.5%) | 522,848 (82.3%) | 526,516 (82.9%) | 527,719 (83.1%) | 107,279 (16.9%) | 7,334 (6.8%) | 2,474 (2.3%) | 30 levels (max L69 vs gate L100) |

**Profile of fixed-cohort payers who did not reach the album by D90**
| Metric | Dice | Domino | Disney |
|---|---|---|---|
| Active days in first 90 days, P50 / P75 | 2 / 3 | 2 / 3 | 4 / 6 |
| Last active day since install, P50 / P75 | 1 / 4 | 1 / 6 | 5 / 18 |
| Active D30–37 / D60–67 / D83–90 | 2.3% / 0.9% / 0.6% | 4.3% / 1.6% / 1.0% | 6.8% / 3.2% / 2.3% |
| Max Kingdom/Level P50 / P75 | K4 / K5 | L16 / L26 | L69 / L87 |
| 90-day revenue per player: avg / P50 / P75 | $5.28 / $3.58 / $4.44 | $8.50 / $3.34 / $5.77 | $5.54 / $3.99 / $5.54 |
| 90-day revenue total (non-reachers) | $153.8K | $60.7K | $594.1K |
| For reference: avg 90-day revenue of fixed-cohort reachers | $125.66 | $98.34 | $146.16 |

Distance-from-gate buckets (max level reached in 90 days):
| Bucket | Dice (gate K8) | Domino (gate L35) | Disney (gate L100) |
|---|---|---|---|
| Rule — very close | K7 | L30–34 | L90–99 |
| Rule — moderately below | K5–6 | L20–29 | L70–89 |
| Rule — far below | ≤ K4 | < L20 | < L70 |
| At/above gate but no album record | 40 (0.1%) | 89 (1.2%) | 192 (0.2%) |
| Very close | 3,587 (12.3%) | 945 (13.2%) | 22,567 (21.0%) |
| Moderately below | 7,055 (24.2%) | 1,835 (25.7%) | 30,228 (28.2%) |
| Far below | 18,472 (63.4%) | 4,276 (59.8%) | 54,292 (50.6%) |

**Classification of non-reachers** (rules):
- Early churners: last active day < day 30.
- Active but far from gate: last active day ≥ 30 AND max level in "moderately below" or "far below" bucket.
- Active and close to gate: last active day ≥ 30 AND max level "very close" (or at/above gate with no album record).

| Group | Dice | Domino | Disney |
|---|---|---|---|
| Early churners | 27,424 (94.1%) | 6,493 (90.9%) | 88,247 (82.3%) |
| Active but far from gate | 1,473 (5.1%) | 499 (7.0%) | 14,360 (13.4%) |
| Active and close to gate | 257 (0.9%) | 153 (2.1%) | 4,672 (4.4%) |
| Active and close, as % of whole fixed cohort | 0.1% | 0.1% | 0.7% |

**Month-active validation (all installs, not just payers).** Note: active during days 30–37 does NOT mean the player stayed active until day 90.
| Metric | Dice | Domino | Disney |
|---|---|---|---|
| Players active during D30–37 | 311,791 | 402,343 | 1,626,584 |
| Reached album by D90 | 276,351 (88.6%) | 361,627 (89.9%) | 1,296,924 (79.7%) ✅ validated |
| Did not reach by D90 | 35,440 (11.4%) | 40,716 (10.1%) | 329,660 (20.3%) |
| Non-reachers: max level P50 / P75 | K2 / K4 | L13 / L24 | L33 / L67 |
| Non-reachers: last active day P50 / P75 | 35 / 45 | 36 / 51 | 37 / 61 |
| Non-reachers still active D60–67 | 2,742 (7.7%) | 3,812 (9.4%) | 41,797 (12.7%) |
| Non-reachers still active D83–90 | 1,758 (5.0%) | 2,602 (6.4%) | 28,246 (8.6%) |
| Non-reachers by bucket: at gate / very close / moderate / far | 0.2 / 6.8 / 14.6 / 78.4% | 3.6 / 9.3 / 22.3 / 64.8% | 0.4 / 9.2 / 13.5 / 76.9% |

Caveats: Dice month-active non-reachers sit at a median of K2 after 30+ days — low-progress players; Kingdom history may need a sanity check before using Dice in the deck. Small "at/above gate but no album record" groups (0.1–1.2%) are likely data gaps, not gate effects.

### A3. Non-reacher conclusion (gate placement)
- Payers who miss the first album are overwhelmingly early churners: 82–94% stop before day 30, median last active day 1 (Dice, Domino) and 5 (Disney), with 2–4 active days in total. They are mostly far below the gate (median 4 Kingdoms / 19 levels / 30 levels short).
- Only a small group stays active and gets close to the gate without the album: 257 payers in Dice (0.1% of the fixed cohort), 153 in Domino (0.1%), 4,672 in Disney (0.7%).
- Disney's lower month-active reach (79.7%) is validated. Its non-reachers who were active on days 30–37 are mostly far from L100 (median L33) and most stop shortly after (median last day 37). This points to slow progression plus churn, not to players waiting at the gate.
- Missed exposure is mainly a retention problem; a secondary progression-speed issue exists in Disney (13.4% of non-reaching payers stayed active but far from the gate). There is no evidence of a gate-placement problem in Dice or Disney.
- The data does not support changing the gate. Recommendation: **Do Not Adopt Yet** (gate change). If Disney wants to explore earlier exposure for slow progressors, that would require an A/B test — the reachable upside group is small (~19K payers active after day 30 out of 635K fixed-cohort payers).

(Former slide title for this appendix: "Payers who miss the first album mostly stop playing within days — few stay active near the gate")


## Topic 2 — Population by albums experienced (results 2026-10-07)
### Definitions (Eden)
- Month: September 2026. Population: active ≥ 1 day in September AND ≥ 1 album experienced by 30 Sep. "No album yet" shown separately (context).
- Albums experienced = every album exposed. Dice: COUNT(DISTINCT album_id) in 30_intermediate.album_pop (user_album_start_date ≤ 30 Sep, any is_excluded). Domino/Disney: MAX(user_album_count) in user_daily_album (Domino from 2024-01, Disney from 2025-01).
- Revenue = total game revenue in September (Dice revenues_sum; Domino in-app + Stripe; Disney gross_revenues). Payer = revenue > 0 in September.
- Activity/exclusions as Topic 1. Level = max end-of-day level in September (Domino level_id_end_day, Disney level_endday; Dice kingdom_id_enday for reference).
- Current album completion: dropped (Eden).

### Results — September 2026 (shares within album-exposed players)
| Game | Group | Players | Share players | Payers | Share payers | Payer rate | Revenue | Share revenue | ARPU | ARPPU | Active days avg / P50 | PU active days avg / P50 | Level P50 / P75 | PU level P50 / P75 |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| Dice | 1st | 121,550 | 12.6% | 26,833 | 10.4% | 22.1% | $842K | 4.2% | $6.93 | $31.38 | 7.3 / 5 | 9.8 / 8 | K14 / K36 | K34 / K52 |
| Dice | 2–3 | 203,275 | 21.1% | 50,840 | 19.6% | 25.0% | $4.79M | 23.6% | $23.57 | $94.25 | 13.5 / 11 | 21.2 / 24 | K67 / K133 | K138 / K208 |
| Dice | 4–6 | 126,759 | 13.1% | 32,212 | 12.4% | 25.4% | $3.03M | 14.9% | $23.90 | $94.04 | 13.9 / 11 | 22.4 / 26 | K161 / K228 | K244 / K283 |
| Dice | 7+ | 513,379 | 53.2% | 149,307 | 57.6% | 29.1% | $11.63M | 57.3% | $22.64 | $77.86 | 20.2 / 26 | 24.8 / 28 | K274 / K307 | K308 / K337 |
| Domino | 1st | 181,012 | 21.7% | 24,447 | 17.5% | 13.5% | $1.12M | 11.8% | $6.20 | $45.92 | 7.7 / 5 | 13.1 / 11 | L76 / L140 | L195 / L346 |
| Domino | 2–3 | 177,177 | 21.3% | 23,221 | 16.6% | 13.1% | $1.68M | 17.7% | $9.51 | $72.55 | 11.4 / 6 | 22.1 / 26 | L284 / L590 | L719 / L1168 |
| Domino | 4–6 | 161,251 | 19.4% | 27,242 | 19.5% | 16.9% | $1.99M | 21.0% | $12.37 | $73.21 | 14.3 / 12 | 24.0 / 28 | L884 / L1668 | L1879 / L2905 |
| Domino | 7+ | 313,742 | 37.7% | 64,590 | 46.3% | 20.6% | $4.72M | 49.6% | $15.03 | $73.01 | 18.3 / 23 | 24.6 / 29 | L3422 / L5823 | L5254 / L7680 |
| Disney | 1st | 234,736 | 11.1% | 61,831 | 15.7% | 26.3% | $3.58M | 11.5% | $15.26 | $57.93 | 12.2 / 10 | 15.4 / 14 | L163 / L243 | L228 / L356 |
| Disney | 2–3 | 430,843 | 20.3% | 65,441 | 16.7% | 15.2% | $5.90M | 19.0% | $13.70 | $90.18 | 13.6 / 10 | 23.5 / 28 | L387 / L654 | L719 / L1043 |
| Disney | 4–6 | 709,329 | 33.5% | 118,242 | 30.1% | 16.7% | $10.06M | 32.3% | $14.18 | $85.08 | 16.3 / 17 | 24.6 / 29 | L946 / L1519 | L1613 / L2383 |
| Disney | 7+ | 744,031 | 35.1% | 147,134 | 37.5% | 19.8% | $11.57M | 37.2% | $15.55 | $78.62 | 20.4 / 26 | 25.8 / 29 | L2239 / L3615 | L3470 / L5127 |

### Monetization — daily averages, September 2026 (Eden: main view)
Each metric is computed per calendar day per group, then averaged over the 30 days. ARPDAU = revenue ÷ DAU; daily payer rate = DPU ÷ DAU; daily ARPPU = revenue ÷ DPU.
| Game | Group | Avg DAU | Avg DPU | Daily payer rate | ARPDAU | Daily ARPPU | Avg daily revenue |
|---|---|---:|---:|---:|---:|---:|---:|
| Dice | 1st | 29,466 | 2,338 | 7.2% | $0.83 | $11.09 | $28.1K |
| Dice | 2–3 | 91,138 | 8,222 | 9.0% | $1.76 | $19.55 | $159.7K |
| Dice | 4–6 | 58,892 | 5,287 | 9.0% | $1.72 | $19.10 | $101.0K |
| Dice | 7+ | 346,109 | 23,056 | 6.7% | $1.12 | $16.81 | $387.5K |
| Domino | 1st | 46,392 | 2,527 | 5.5% | $0.80 | $14.66 | $37.4K |
| Domino | 2–3 | 67,009 | 3,485 | 5.2% | $0.84 | $16.12 | $56.2K |
| Domino | 4–6 | 76,735 | 4,468 | 5.8% | $0.87 | $14.87 | $66.5K |
| Domino | 7+ | 191,271 | 10,257 | 5.4% | $0.82 | $15.31 | $157.2K |
| Disney | 1st | 95,541 | 7,307 | 7.6% | $1.23 | $16.08 | $119.4K |
| Disney | 2–3 | 195,070 | 10,197 | 5.2% | $1.01 | $19.26 | $196.7K |
| Disney | 4–6 | 384,230 | 18,834 | 4.9% | $0.87 | $17.78 | $335.4K |
| Disney | 7+ | 505,474 | 23,099 | 4.6% | $0.76 | $16.65 | $385.6K |
Context — no album yet: ARPDAU Dice $0.04, Domino $0.005, Disney $0.03.
- Known: Per active day, 7+ players are not the highest spenders. Dice peaks at 2–6 albums ($1.72–1.76) and 7+ is $1.12; Disney declines with album count ($1.23 → $0.76); Domino is flat ($0.80–0.87).
- Known: 7+ revenue share comes from volume (more players × more active days), not from higher daily spend.
- The monthly ARPU / ARPPU table above stays as supporting context (it rewards groups with more active days).

Context — active in September, no album yet: Dice 519,871 (35.0% of all active; 0.15% of revenue), Domino 559,789 (40.2%; 0.04%), Disney 1,419,401 (40.1%; 0.2%). Mostly 1–2 active days, below gate.
Totals (album-exposed): Dice 964,963 players / 259,192 payers / $20.29M; Domino 833,182 / 139,500 / $9.52M; Disney 2,118,939 / 392,648 / $31.11M.

### Findings
- Known: 7+ album players hold the largest revenue share in all three games — Dice 57%, Domino 50%, Disney 37%. Disney revenue is spread more evenly (4–6 = 32%).
- Known: First-album players contribute 4.2% of revenue in Dice vs 11.5–11.8% in Domino and Disney.
- Known: Disney first-album players have the highest payer rate of any group in any game (26.3%) and ARPU in line with veterans ($15.26 vs $15.55). In Dice and Domino, first-album ARPU is ~$6–7, a third or less of later groups.
- Known: Dice ARPU is flat from 2–3 albums onward (~$23); Domino ARPU rises steadily with albums ($6 → $15).
- Hypothesis: Disney's first-album strength may reflect the L100 gate (players arrive later, more committed — Topic 1: 3–5 active days) rather than the album itself. Not testable from this cut.

### Needs Validation / biases
- Album count ≈ tenure. Max albums observed: Dice 21, Domino 15, Disney 13 — game age and history limit the 7+ group differently per game.
- Dice album_pop history appears to start ~21 albums back (Dice is at album 63+). Long-tenure Dice players who returned may be counted in 2–3 / 4–6 (2–3 group level P75 = K133 is high for ~3 months). Check album_pop start date.
- Domino/Disney: user_album_count ≠ COUNT(DISTINCT album_id) for ~1% of 7+ players (Domino 3,063; Disney 3,270). Minor.
- Revenue is September total game revenue, not album revenue; a single month includes album-end weekends differently per game.

### Topic 2 follow-up — ARPDAU during the last four full album days versus whole-album ARPDAU (final rule, 2026-10-07)
Replaces all earlier versions of this analysis. The close-date-inclusive Disney results (all cohorts below 1.0) are now QA only.

**Metric:** ARPDAU during the last four full album days versus whole-album ARPDAU, by calendar album × album-experience cohort.

**Rule (Eden) — same for Dice, Domino and Disney**
- Last four full album days = `close_date − 4` … `close_date − 1`.
- Whole album = player's first exposure … `close_date − 1`.
- The partial close date is excluded from both windows.
- Close date = Dice `album_end_date`; Domino and Disney `album_close_date`.
- Joins on `album_id` and date (the next album opens on the close date of the previous one).

**Method**
- Albums: completed calendar albums closing between 1 Oct 2025 and 7 Oct 2026.
  - Dice 49–63 (8), Domino 13–19 (7), Disney 7–15 (9).
  - Disney album 6 is QA only (history starts after its real opening date).
- Daily table: game × album × cohort × date, with one count per active player per date.
- Main ratio = (revenue ÷ active player-days in the last 4 full days) ÷ (revenue ÷ active player-days over the whole album).
  - Same game, album, cohort and revenue definition (album spend) on both sides.
  - Revenue and player-days are summed first, then divided. Not an average of player or daily ratios.
- Cohort (lifetime album number, assigned per calendar album; 1–6, 7+):
  - Disney: validated lifetime counter `user_album_count`.
  - Dice and Domino: order from available history; pre-history installs with fewer than 7 counted albums are left out as unidentified.
- Exclusions: unidentified cohorts, cells with fewer than 5,000 players and Disney album 6.
- Paying metrics:
  - `payer_day_rate` = paying player-days ÷ active player-days.
  - `revenue_per_paying_day` = revenue ÷ paying player-days.
  - ARPPU = revenue ÷ distinct payers (in the CSV).

**Main result — median ratio across valid calendar albums**
| Game | Cohort 1 | Cohort 2 | Cohort 3 | Cohort 4 | Cohort 5 | Cohort 6 | Cohort 7+ |
|---|---:|---:|---:|---:|---:|---:|---:|
| Dice | 1.08 | 1.12 | 1.19 | 1.18 | 1.17 | 1.21 | 1.22 |
| Domino | 1.13 | 1.16 | 1.22 | 1.17 | 1.16 | 1.16 | 1.18 |
| Disney | 1.01 | 0.98 | 1.03 | 1.03 | 1.04 | 1.04 | 1.06 |
| *albums per cell (Dice/Domino/Disney)* | 8/7/9 | 8/7/9 | 8/7/9 | 8/7/9 | 8/7/8 | 8/7/7 | 8/7/6 |

**Findings (Known unless marked)**
- All three games show an end-of-album ARPDAU lift, but of different sizes.
  - Dice: 1.08–1.22.
  - Domino: 1.13–1.22.
  - Disney: 0.98–1.06, close to flat.
- Lift rises from cohort 1 to cohort 3, then levels off: Dice 1.08 → 1.17–1.22; Domino 1.13 → 1.16–1.22; Disney 0.98–1.01 → 1.03–1.06.
- First-album players respond least in every game. In Dice and Disney their payer-day rate does not rise at the end (0.96–0.97 ×); the small lift comes from revenue per paying day.
- The pattern is album-driven.
  - Dice: 51, 53, 55 and 57 are high (up to 1.39); 49 and 59 are around or below 1.0.
  - Domino: 14 and 18 are highest (up to 1.34); 16 is lowest.
  - Disney: album 8 (Nov 2025 – Jan 2026) is the only strong album (1.18–1.40); albums 9–15 are 0.91–1.14.
- Strongest median lift by cohort: Domino for cohorts 1–3, Dice for cohorts 4–7+. Disney is lowest in every cohort.
- Small cells are not driving the results. Every Dice and Domino cell has more than 12K players; the four small Disney cells are left out.
- Hypothesis: album-specific ending mechanics or events explain more than cohort does. This needs the per-album ending calendar.

**Paying metrics (median)**
| Game | Metric (last 4 full days ÷ whole album, median) | 1 | 2 | 3 | 4 | 5 | 6 | 7+ |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| Dice | payer_day_rate | 0.97 | 1.05 | 1.10 | 1.07 | 1.08 | 1.05 | 1.07 |
| Dice | revenue_per_paying_day | 1.11 | 1.09 | 1.10 | 1.10 | 1.11 | 1.13 | 1.14 |
| Domino | payer_day_rate | 1.02 | 1.08 | 1.14 | 1.09 | 1.09 | 1.07 | 1.08 |
| Domino | revenue_per_paying_day | 1.11 | 1.09 | 1.05 | 1.07 | 1.04 | 1.06 | 1.07 |
| Disney | payer_day_rate | 0.96 | 0.96 | 1.02 | 1.02 | 1.02 | 1.01 | 1.02 |
| Disney | revenue_per_paying_day | 1.07 | 1.03 | 1.02 | 1.03 | 1.04 | 1.01 | 1.05 |

**QA 1 — close-date-inclusive version (end = close−3 … close; whole album to close). Not used for comparison.**
| Game | Cohort 1 | Cohort 2 | Cohort 3 | Cohort 4 | Cohort 5 | Cohort 6 | Cohort 7+ |
|---|---:|---:|---:|---:|---:|---:|---:|
| Dice | 0.96 | 0.99 | 1.08 | 1.03 | 1.02 | 1.05 | 1.07 |
| Domino | 0.97 | 1.03 | 1.07 | 1.04 | 1.01 | 1.04 | 1.05 |
| Disney | 0.90 | 0.87 | 0.92 | 0.92 | 0.92 | 0.93 | 0.94 |
- On the close date, DAU is normal but album revenue is about 35–40% of a normal day in all three games. That one partial day lowers every ratio by about 0.10–0.12.

**QA 2 — is the album opening date partial?**
Yes. The opening date has fewer active players and much lower revenue than the next day in every album: Dice: DAU 70%–76%, revenue 46%–55%, ARPDAU 66%–74% of the next day; Domino: DAU 77%–82%, revenue 54%–60%, ARPDAU 67%–74% of the next day; Disney: DAU 79%–84%, revenue 49%–57%, ARPDAU 60%–69% of the next day.
| Game | Album | Open-date DAU vs next day | Open-date revenue vs next day | Open-date ARPDAU vs next day |
|---|---|---:|---:|---:|
| Dice | 49 | 71% | 52% | 73% |
| Dice | 51 | 75% | 53% | 72% |
| Dice | 53 | 72% | 50% | 70% |
| Dice | 55 | 70% | 46% | 66% |
| Dice | 57 | 71% | 53% | 74% |
| Dice | 59 | 73% | 50% | 68% |
| Dice | 61 | 76% | 55% | 72% |
| Dice | 63 | 75% | 53% | 71% |
| Domino | 13 | 79% | 58% | 74% |
| Domino | 14 | 80% | 54% | 68% |
| Domino | 15 | 77% | 56% | 72% |
| Domino | 16 | 80% | 59% | 74% |
| Domino | 17 | 81% | 54% | 67% |
| Domino | 18 | 81% | 60% | 74% |
| Domino | 19 | 82% | 56% | 68% |
| Disney | 7 | 84% | 51% | 61% |
| Disney | 8 | 81% | 49% | 61% |
| Disney | 9 (no real activity on open date) | 0% | 0% | 36% |
| Disney | 10 | 79% | 50% | 63% |
| Disney | 11 | 81% | 53% | 66% |
| Disney | 12 | 84% | 50% | 60% |
| Disney | 13 | 84% | 55% | 66% |
| Disney | 14 | 83% | 52% | 63% |
| Disney | 15 | 82% | 57% | 69% |
Effect of also excluding the opening date from the whole-album baseline (median ratio):
| Game | Cohort 1 | Cohort 2 | Cohort 3 | Cohort 4 | Cohort 5 | Cohort 6 | Cohort 7+ |
|---|---:|---:|---:|---:|---:|---:|---:|
| Dice | 1.08 | 1.11 | 1.17 | 1.17 | 1.16 | 1.20 | 1.21 |
| Domino | 1.13 | 1.15 | 1.21 | 1.17 | 1.16 | 1.15 | 1.17 |
| Disney | 1.01 | 0.96 | 1.03 | 1.02 | 1.03 | 1.03 | 1.05 |
- Excluding the opening date changes ratios by −0.008 on average (range −0.022 to 0.000). Medians move by at most 0.02.
- Five cells cross 1.0, all within ±0.02 of 1.0: Disney 13 cohorts 4, 5 and 7+; Disney 14 cohort 5; Domino 16 cohort 4.
- Not material. The opening date stays in the main baseline; this is noted as a methodological point.

**QA 3 — weighted (main) vs average daily ARPDAU**
| Game | Measure | 1 | 2 | 3 | 4 | 5 | 6 | 7+ |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| Dice | Weighted (main) | 1.08 | 1.12 | 1.19 | 1.18 | 1.17 | 1.21 | 1.22 |
| Dice | Avg daily ARPDAU (QA) | 1.11 | 1.12 | 1.17 | 1.17 | 1.17 | 1.20 | 1.22 |
| Domino | Weighted (main) | 1.13 | 1.16 | 1.22 | 1.17 | 1.16 | 1.16 | 1.18 |
| Domino | Avg daily ARPDAU (QA) | 1.20 | 1.15 | 1.21 | 1.17 | 1.16 | 1.16 | 1.18 |
| Disney | Weighted (main) | 1.01 | 0.98 | 1.03 | 1.03 | 1.04 | 1.04 | 1.06 |
| Disney | Avg daily ARPDAU (QA) | 1.02 | 0.99 | 1.04 | 1.03 | 1.05 | 1.04 | 1.06 |
- Mean absolute difference per cell: 0.011; maximum 0.083 (Domino cohort 1, where new players keep arriving during the album).
- Two cells cross 1.0, both near it: Disney 9 cohort 1 (0.98 vs 1.02) and Disney 15 cohort 2 (1.00 vs 1.00).
- The conclusions are unchanged.

**Players whose cohort could not be identified (player-album pairs, left out)**
| Game | Method | Unidentified player-albums (left out) | Share per album |
|---|---|---:|---|
| Dice | Order from available history (album 22, Nov 2023 onward); pre-history installs with <7 counted albums left out | 602,609 | 5.3–7.9% |
| Domino | Order from available history (album 6, Jun 2024 onward); pre-history first_seen with <7 counted albums left out | 301,238 | 1.3–5.0% |
| Disney | Lifetime user_album_count validated against observed order (99.7–100% match); mismatches left out | 51,719 | 0.0–0.5% |

**Disney album-level results (main rule)**
| Calendar album | Album dates | Experience cohort | Active players | Whole-album ARPDAU | Last-4-full-days ARPDAU | Ratio | Uplift | QA: close-date incl. | QA: excl. open date | QA: avg daily |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 7 | 8 Oct 25 – 18 Nov 25 | 1 | 496,048 | $1.184 | $1.185 | 1.00 | +0% | 0.90 | 1.00 | 1.02 |
| 7 | 8 Oct 25 – 18 Nov 25 | 2 | 308,066 | $0.906 | $0.920 | 1.02 | +2% | 0.89 | 1.01 | 1.02 |
| 7 | 8 Oct 25 – 18 Nov 25 | 3 | 281,025 | $0.821 | $0.867 | 1.06 | +6% | 0.92 | 1.05 | 1.06 |
| 7 | 8 Oct 25 – 18 Nov 25 | 4 | 614,311 | $0.652 | $0.720 | 1.10 | +10% | 0.96 | 1.09 | 1.10 |
| 7 | 8 Oct 25 – 18 Nov 25 | 5 ⚠ <5K | 1,553 | $0.191 | $0.159 | 0.83 | -17% | 0.76 | 0.83 | 0.83 |
| 8 | 18 Nov 25 – 5 Jan 26 | 1 | 311,091 | $1.356 | $1.596 | 1.18 | +18% | 1.01 | 1.18 | 1.21 |
| 8 | 18 Nov 25 – 5 Jan 26 | 2 | 394,051 | $1.041 | $1.322 | 1.27 | +27% | 1.08 | 1.26 | 1.25 |
| 8 | 18 Nov 25 – 5 Jan 26 | 3 | 232,912 | $0.909 | $1.223 | 1.35 | +35% | 1.14 | 1.33 | 1.32 |
| 8 | 18 Nov 25 – 5 Jan 26 | 4 | 230,114 | $0.889 | $1.198 | 1.35 | +35% | 1.14 | 1.33 | 1.34 |
| 8 | 18 Nov 25 – 5 Jan 26 | 5 | 520,845 | $0.751 | $1.052 | 1.40 | +40% | 1.16 | 1.38 | 1.39 |
| 8 | 18 Nov 25 – 5 Jan 26 | 6 ⚠ <5K | 1,366 | $0.196 | $0.236 | 1.20 | +20% | 0.88 | 1.19 | 1.20 |
| 9 | 5 Jan 26 – 15 Feb 26 | 1 | 1,083,732 | $1.410 | $1.377 | 0.98 | -2% | 0.89 | 0.98 | 1.02 |
| 9 | 5 Jan 26 – 15 Feb 26 | 2 | 247,891 | $1.171 | $1.127 | 0.96 | -4% | 0.89 | 0.96 | 0.99 |
| 9 | 5 Jan 26 – 15 Feb 26 | 3 | 243,937 | $0.966 | $0.994 | 1.03 | +3% | 0.96 | 1.03 | 1.05 |
| 9 | 5 Jan 26 – 15 Feb 26 | 4 | 157,709 | $0.926 | $0.941 | 1.02 | +2% | 0.96 | 1.02 | 1.04 |
| 9 | 5 Jan 26 – 15 Feb 26 | 5 | 179,174 | $0.874 | $0.901 | 1.03 | +3% | 0.96 | 1.03 | 1.06 |
| 9 | 5 Jan 26 – 15 Feb 26 | 6 | 440,801 | $0.722 | $0.732 | 1.01 | +1% | 0.95 | 1.01 | 1.03 |
| 9 | 5 Jan 26 – 15 Feb 26 | 7+ ⚠ <5K | 1,178 | $0.168 | $0.193 | 1.15 | +15% | 1.12 | 1.15 | 1.15 |
| 10 | 16 Feb 26 – 6 Apr 26 | 1 | 1,314,478 | $1.366 | $1.429 | 1.05 | +5% | 0.92 | 1.05 | 1.04 |
| 10 | 16 Feb 26 – 6 Apr 26 | 2 | 820,117 | $1.201 | $1.176 | 0.98 | -2% | 0.85 | 0.97 | 0.98 |
| 10 | 16 Feb 26 – 6 Apr 26 | 3 | 175,033 | $1.107 | $1.213 | 1.10 | +10% | 0.96 | 1.09 | 1.09 |
| 10 | 16 Feb 26 – 6 Apr 26 | 4 | 175,113 | $1.002 | $1.085 | 1.08 | +8% | 0.95 | 1.07 | 1.08 |
| 10 | 16 Feb 26 – 6 Apr 26 | 5 | 129,467 | $0.952 | $1.037 | 1.09 | +9% | 0.96 | 1.08 | 1.09 |
| 10 | 16 Feb 26 – 6 Apr 26 | 6 | 142,697 | $0.910 | $0.991 | 1.09 | +9% | 0.95 | 1.08 | 1.09 |
| 10 | 16 Feb 26 – 6 Apr 26 | 7+ | 388,514 | $0.722 | $0.822 | 1.14 | +14% | 1.00 | 1.13 | 1.14 |
| 11 | 6 Apr 26 – 11 May 26 | 1 | 619,580 | $1.465 | $1.483 | 1.01 | +1% | 0.90 | 1.01 | 1.01 |
| 11 | 6 Apr 26 – 11 May 26 | 2 | 858,310 | $1.254 | $1.216 | 0.97 | -3% | 0.86 | 0.96 | 0.97 |
| 11 | 6 Apr 26 – 11 May 26 | 3 | 458,780 | $1.072 | $1.104 | 1.03 | +3% | 0.92 | 1.02 | 1.03 |
| 11 | 6 Apr 26 – 11 May 26 | 4 | 115,939 | $1.091 | $1.123 | 1.03 | +3% | 0.92 | 1.02 | 1.03 |
| 11 | 6 Apr 26 – 11 May 26 | 5 | 131,749 | $0.997 | $1.041 | 1.04 | +4% | 0.93 | 1.03 | 1.04 |
| 11 | 6 Apr 26 – 11 May 26 | 6 | 102,927 | $0.949 | $0.988 | 1.04 | +4% | 0.94 | 1.03 | 1.04 |
| 11 | 6 Apr 26 – 11 May 26 | 7+ | 452,409 | $0.780 | $0.826 | 1.06 | +6% | 0.95 | 1.05 | 1.06 |
| 12 | 11 May 26 – 22 Jun 26 | 1 | 676,850 | $1.325 | $1.309 | 0.99 | -1% | 0.88 | 0.99 | 0.97 |
| 12 | 11 May 26 – 22 Jun 26 | 2 | 479,903 | $1.129 | $1.029 | 0.91 | -9% | 0.81 | 0.90 | 0.92 |
| 12 | 11 May 26 – 22 Jun 26 | 3 | 603,826 | $0.942 | $0.919 | 0.98 | -2% | 0.87 | 0.97 | 0.98 |
| 12 | 11 May 26 – 22 Jun 26 | 4 | 334,052 | $0.932 | $0.954 | 1.02 | +2% | 0.90 | 1.01 | 1.03 |
| 12 | 11 May 26 – 22 Jun 26 | 5 | 104,059 | $0.945 | $0.993 | 1.05 | +5% | 0.92 | 1.04 | 1.05 |
| 12 | 11 May 26 – 22 Jun 26 | 6 | 119,890 | $0.867 | $0.910 | 1.05 | +5% | 0.93 | 1.04 | 1.05 |
| 12 | 11 May 26 – 22 Jun 26 | 7+ | 514,923 | $0.724 | $0.778 | 1.07 | +7% | 0.96 | 1.06 | 1.08 |
| 13 | 22 Jun 26 – 13 Jul 26 | 1 | 259,815 | $1.481 | $1.505 | 1.02 | +2% | 0.93 | 1.01 | 1.04 |
| 13 | 22 Jun 26 – 13 Jul 26 | 2 | 453,522 | $1.222 | $1.203 | 0.98 | -2% | 0.89 | 0.96 | 0.99 |
| 13 | 22 Jun 26 – 13 Jul 26 | 3 | 294,608 | $0.997 | $0.993 | 1.00 | -0% | 0.90 | 0.97 | 1.00 |
| 13 | 22 Jun 26 – 13 Jul 26 | 4 | 380,367 | $0.953 | $0.958 | 1.01 | +1% | 0.92 | 0.98 | 1.01 |
| 13 | 22 Jun 26 – 13 Jul 26 | 5 | 240,197 | $0.973 | $0.977 | 1.00 | +0% | 0.91 | 0.98 | 1.01 |
| 13 | 22 Jun 26 – 13 Jul 26 | 6 | 78,636 | $1.012 | $1.037 | 1.03 | +3% | 0.93 | 1.01 | 1.03 |
| 13 | 22 Jun 26 – 13 Jul 26 | 7+ | 537,459 | $0.812 | $0.825 | 1.02 | +2% | 0.92 | 1.00 | 1.02 |
| 14 | 13 Jul 26 – 24 Aug 26 | 1 | 349,528 | $1.245 | $1.203 | 0.97 | -3% | 0.85 | 0.97 | 0.94 |
| 14 | 13 Jul 26 – 24 Aug 26 | 2 | 244,722 | $1.258 | $1.153 | 0.92 | -8% | 0.81 | 0.91 | 0.92 |
| 14 | 13 Jul 26 – 24 Aug 26 | 3 | 384,551 | $0.973 | $0.930 | 0.96 | -4% | 0.84 | 0.95 | 0.96 |
| 14 | 13 Jul 26 – 24 Aug 26 | 4 | 272,830 | $0.900 | $0.896 | 1.00 | -0% | 0.87 | 0.99 | 1.00 |
| 14 | 13 Jul 26 – 24 Aug 26 | 5 | 341,931 | $0.849 | $0.854 | 1.01 | +1% | 0.88 | 1.00 | 1.01 |
| 14 | 13 Jul 26 – 24 Aug 26 | 6 | 225,170 | $0.872 | $0.888 | 1.02 | +2% | 0.89 | 1.01 | 1.02 |
| 14 | 13 Jul 26 – 24 Aug 26 | 7+ | 614,844 | $0.719 | $0.730 | 1.02 | +2% | 0.89 | 1.01 | 1.02 |
| 15 | 24 Aug 26 – 5 Oct 26 | 1 | 247,389 | $1.502 | $1.606 | 1.07 | +7% | 0.94 | 1.07 | 1.08 |
| 15 | 24 Aug 26 – 5 Oct 26 | 2 | 248,004 | $1.050 | $1.048 | 1.00 | -0% | 0.87 | 0.99 | 1.00 |
| 15 | 24 Aug 26 – 5 Oct 26 | 3 | 165,012 | $1.057 | $1.097 | 1.04 | +4% | 0.92 | 1.03 | 1.04 |
| 15 | 24 Aug 26 – 5 Oct 26 | 4 | 248,888 | $0.923 | $0.953 | 1.03 | +3% | 0.90 | 1.02 | 1.03 |
| 15 | 24 Aug 26 – 5 Oct 26 | 5 | 196,417 | $0.909 | $0.949 | 1.04 | +4% | 0.91 | 1.03 | 1.04 |
| 15 | 24 Aug 26 – 5 Oct 26 | 6 | 273,553 | $0.865 | $0.906 | 1.05 | +5% | 0.91 | 1.04 | 1.05 |
| 15 | 24 Aug 26 – 5 Oct 26 | 7+ | 750,850 | $0.781 | $0.835 | 1.07 | +7% | 0.93 | 1.06 | 1.07 |

Files: `album_end_ratio_heatmaps.png` (main rule, all games), `album_end_ratio_by_album_cohort.csv` (all cells, with main metric, QA columns, paying metrics, ARPPU and open-date totals).

## Topic 3 — Album duration & timing (not started)
- Rare-sticker progression moved to Topic 4 (Eden, 2026-10-07). Topic 3 may reference rare release timing but does not analyse rare progression.

## Topic 4 — Rare stickers: count and collection progression (in progress, 2026-10-07)
### 4a. Total rare stickers per album (Known)
| Game | Album | Rare type | Total rares | Album (set) stickers | Rare share | Source |
|---|---|---|---:|---:|---:|---|
| Dice | 61 | Super | 12 (rarity 1: 10, 2: 1, 3: 1) | 144 (104 Common, 28 Golden, 12 Super) | 8.3% | `dice-dreams-dbt.external_sources.album_stickers_profile` |
| Dice | 63 | Super | 12 | 144 | 8.3% | same |
| Domino | 17 | Royal | 8 | 144 (108 Common, 28 Golden, 8 Royal) | 5.6% | `domino-dreams-dbt.prod_50_reporting.album_sticker_progression` |
| Domino | 19 | Royal | 9 | 144 (107 Common, 28 Golden, 9 Royal) | 6.3% | same |
| Disney | 14 | Royal | 7 | 144 (113 Common, 24 Golden, 7 Royal) | 4.9% | `solitaire-dreams-411507.bi_entity_prod.album_sticker_progression` |
| Disney | 15 | Royal | 7 | 144 | 4.9% | same |
- Album size = set stickers only (Eden): 144 unique set stickers = album completed, in all three games. Dice Pixie (12) and Disney Magic (36) are outside the sets and are excluded from the denominator.
- Cross-check: the maximum player-level unique rare count in `user_daily_album` equals the total in every album (12/12, 8/9, 7/7).

### 4b. First-pass rare progression (superseded — supporting only)
Method: album payers, login ratio ≥ 0.5 (daily rows), P50 of unique rares held per day in album. Album days = close − open (partial close day excluded).

| Game | Album | Album days | P50 unique rares, last full day | Of total | Equivalent album-days per unique rare collected |
|---|---|---:|---:|---:|---:|
| Dice | 61 | 35 | 9 | 9 / 12 | 3.9 |
| Dice | 63 | 42 | 10 | 10 / 12 | 4.2 |
| Domino | 17 | 39 | 6 | 6 / 8 | 6.5 |
| Domino | 19 | 49 | 6 | 6 / 9 | 8.2 |
| Disney | 14 | 42 | 5 | 5 / 7 | 8.4 |
| Disney | 15 | 42 | 4 | 4 / 7 | 10.5 |

- "Equivalent album-days per unique rare collected" = album days ÷ P50 unique rares on the last full day. It is a summary ratio, not the observed time between rare receipts. It is lower when more rares exist, so it is not comparable across games without the totals above.
- The earlier "first rare" column was the first day on which the cumulative P50 reached 1. It was not the median of each player's actual first-receipt day. Being recomputed at player level (4c).
- Odd/even fluctuation (likely cause; confirm after rerun): in Domino and Disney `login_ratio` is recalculated every day (Known: it varies within the album for 85–90% of user-albums), so players near 0.5 likely move in and out of the filter. Dice `album_login_ratio` is fixed per user-album in album 63; in album 61 it varies for 305K of 1.12M user-albums (Needs Validation). Fix: fixed population per user-album, using the login ratio on the player's last row before the close date.

### 4c. Corrected rare progression — PU, login ratio ≥ 0.5, median (results 2026-10-07)
Definitions:
- Population fixed per user-album: PU (album spend > 0 before close), not excluded, login ratio on the player's last row before close ≥ 0.5. Eden: show PU + login ≥ 0.5 + median only.
- rare_collection_percentage = cumulative unique rares ÷ total rares in the album (Supers or Royals only, not all stickers). Days with no row carry the last value forward. Days counted from the player's first row in the album.
- New-rare day = a day where cumulative unique rares increase. Gap = days between consecutive new-rare days.
- Sources: `dice-dreams-dbt.50_reporting.user_daily_album` (is_excluded; 22 Jun–6 Sep 2026); `domino-dreams-dbt.prod_40_mart.user_daily_album` (special users + suspected cheaters from `user_daily_metrics`; 2 Apr–23 Aug 2026); `solitaire-dreams-411507.bi_prod.user_daily_album` (special users + `user_profile.exclude_reason`; 13 Jul–4 Oct 2026). Partial close date excluded.

P50 rare_collection_percentage at % of album duration:

| Game | Album | Total rares | PU | 10% | 25% | 50% | 75% | 90% | 100% |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Dice | 61 | 12 | 218K | 8% | 17% | 33% | 50% | 67% | 75% |
| Dice | 63 | 12 | 219K | 8% | 25% | 33% | 58% | 67% | 83% |
| Domino | 17 | 8 | 152K | 0% | 13% | 25% | 50% | 63% | 75% |
| Domino | 19 | 9 | 131K | 0% | 11% | 22% | 33% | 56% | 67% |
| Disney | 14 | 7 | 411K | 0% | 14% | 29% | 57% | 57% | 71% |
| Disney | 15 | 7 | 346K | 0% | 14% | 14% | 43% | 57% | 57% |

Supporting (raw P50 unique rares on last full day): Dice 9 / 10 of 12; Domino 6 of 8 / 6 of 9; Disney 5 / 4 of 7.

Player-level timing (P50):

| Game | Album | First new-rare day | PU with no rare | Gap between new-rare days (all gaps) | Player's own median gap | New-rare days with 2+ new rares |
|---|---|---:|---:|---:|---:|---:|
| Dice | 61 | 5 | 0.1% | 4 | 4 | 27% |
| Dice | 63 | 3 | 0.0% | 5 | 4 | 23% |
| Domino | 17 | 8 | 0.8% | 6 | 5 | 23% |
| Domino | 19 | 8 | 1.2% | 7 | 6 | 22% |
| Disney | 14 | 7 | 2.1% | 6 | 5 | 12% |
| Disney | 15 | 10 | 3.1% | 7 | 6 | 12% |

Findings (Known):
- At album end the median PU holds 75–83% of rares in Dice, 67–75% in Domino, 57–71% in Disney.
- Dice PU get rares earliest (first new-rare day 3–5 vs 7–10) and most often (gap 4–5 days vs 6–7).
- Domino and Disney have similar gaps (6–7 days); Disney PU are more likely to end with no rare (2–3% vs ≤1.2%).
- 22–27% of new-rare days in Dice and Domino bring 2+ new rares; 12% in Disney.
- Disney album 15 median is flat at 14% from 25% to 50% of the album.
Hypothesis: Disney first-rare day has a narrow P50–P75 range (7–8, 10–11) for all players and PU, suggesting a release gate. Check against the Royal release schedule.
Needs Validation: fluctuation fix — checkpoint player counts now only rise (late joiners), consistent with the daily `login_ratio` explanation.

## Status
- Topic 1 revised. Topic 2 results in, including the album-end ARPDAU follow-up (final rule: last four full album days). Topic 3 not started. Topic 4 in progress (rare totals + corrected PU progression done).

