# Topic 1: first album, presentation notes (build slides from this file; no rerun needed)
Updated 2026-11-03. Detailed evidence: `findings.md` (sections named below). Definitions: `../../DECISIONS.md` (D-005, D-006, D-008, D-009), `../../CONTEXT.md`.
Common to every slide below:
- **Population:** eligible first-album entrants (D-009), first albums 57–65, entry date ≤ close − 7. **LATE** (final third) = 235,686 players, 1.5% of game revenue; **EARLY** (first third) = 401,974, 5.9%.
- **Revenue share** = player revenue on album days start..close−1 / all game revenue on those days, pooled over albums 57–65, excluded users removed. **Cohort share** = share of the group's revenue from entry to close.
- **Notes line:** end each slide with `Source: findings.md <section> | SQL: <file> | Result: <csv>`.

## Use these (supported)
| # | Takeaway (one line) | Key numbers | Window | Validation | Limitation | Source | Suggested visual |
|---|---|---|---|---|---|---|---|
| P1 | Late and early first-album entrants are the same kind of player | Install 3 vs 4 days before entry; 7.8% vs 7.9% prior payers; kingdom 6; week-1 active days 4.75 vs 4.63 | Before entry; days 0–6 | Same in all 5 albums | Install date from game metrics view | findings D-1 · t1_f1 · t1_f1_env_vs_treatment_2026-11-03.csv | Small side-by-side profile cards |
| P2 | Late entrants collect 30% more stickers and 3x the sets in week 1, and spend the same | New 55 vs 39; sets 1.8 vs 0.6; ≥1 set 43% vs 26%; revenue $6.05 vs $5.54; payers 23.5% vs 22.5% | Days 0–6, first album | Per album: late > early in all 5 | Top 1% = 47% of cohort revenue | findings 0-A · t1_e1 · t1_e1_eligible_core_2026-11-03.csv | Paired bars: stickers, sets, revenue (late gold) |
| P3 | Richer packs late in the album explain most of the gap, for everyone | New per pack at 50–74 stickers held, first → last third: early 0.45 → 0.92, veterans 0.48 → 1.00; late (last third) 0.97 | Packs of the first album, by calendar third | Veterans 10% sample; same collection bucket | Bucket width 25; pack rule undocumented | findings D-1 · t1_f1 · t1_f1_env_vs_treatment_2026-11-03.csv | Line chart: new per pack by calendar third, 3 lines (early, veterans, late dot) |
| P4 | Extra stickers come from new kingdom and tournaments, not from purchases | Gap +16: kingdom 33%, tournament 22%, progress bar 13%, Trail 12%, direct purchase 2% | Days 0–6, first album | Same pattern in non-payers with 5–7 active days | Indirect purchase fuel not traceable | findings D-2 · t1_f2 · t1_f2_gap_by_source_2026-11-03.csv | Waterfall of the gap by source |
| P5 | A small rapid group holds most of the money | Rapid (4+ sets in week 1): late 46,270 (20%) = 84% of late cohort revenue; early 13,081 (3%) = 37% | Week 1 types; revenue entry→close | Types mutually exclusive; concentration checked | Shares driven by few spenders | findings 0-C · t1_e1 · t1_e1_eligible_core_2026-11-03.csv | Stacked bar: players % vs revenue % by type |
| P6 | Many fast progressors never pay; those who pay start at once | Late rapid: 45% no payment in week 1; new payers: 54% buy in album 1, 3% in the week after close, 41% none by close + 28 days; payers' first purchase median day 0 | Entry → close + 28 days | Post-close windows on albums 57–63 only | Descriptive, not causal | findings D-3, 0-D · t1_f3, t1_e3 · t1_f3_purchase_timing_2026-11-03.csv | Timeline bar: share making first purchase before first set / to close / after close / never |
| P7 | Faster progress did not bring more play or spending at equal time | Days 6 / 13 / 29: active 54/41/25% vs 52/39/26%; revenue $19.75 vs $18.76 and payers 28% vs 28% by day 29 | Days since entry; game level | All eligible entrants, follow-up flagged | Day 29 missing for album 65 late entrants | findings 0-E · t1_e4 · t1_e4_milestones_2026-11-03.csv | Two lines (late, early) of active share and cumulative revenue by day |
| P8 | Decision: do not extend faster progression to all first-album players without a test | Test: first-third entrants, days 0–6 packs at last-third new-sticker rate; primary = active days 14–27; guardrails revenue days 0–29 / 30–59 | — | Based on P3–P7 | Observational evidence only | findings D-4 | Single recommendation slide with the test design |

## Do NOT use (superseded or corrected)
| Statement / number | Why | Replaced by |
|---|---|---|
| Any "first 7 days" numbers from findings Part I (J2/J3/J4), e.g. "rapid = 16% of late joiners", L14 pack tables | Mixed first- and second-album days for entrants with < 7 days left (C-007) | Part 0 / D sections |
| "Progress is bought" | Only 7–8% of rapid payers' new stickers came directly from purchases; 26–45% of rapid players paid nothing in week 1 (C-008) | P4, P6 |
| "Keep the catch-up" / "late entrants get a catch-up mechanic" | Most of the extra comes from end-of-album pack content for everyone; rule undocumented | P3 |
| "Late joiners retain better in the next album" | Elapsed-time artefact (F5) | P7 |
| Entry dates from `album_pop` / `t1_s2_base.sql` | Start date overwritten to close day for 25–31% of rows in 63/65 (C-005) | Entry from `user_daily_album` |
| Entrants with 0–6 days left as part of the core | Out of the core population (D-009) | Part I kept as history only |
