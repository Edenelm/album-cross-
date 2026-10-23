# Does a free Royal make a far payer pay to finish? (Disney, 2026-10-23)

Eden's question: "If a player who did not pay in the last week gets more Royals, will she pay to finish?"
Short answer: **no evidence in the data.** A free Royal goes with more progress, but not with non-payers starting to pay. Only a controlled test can answer it, and it must measure spend.

SQL: `claude/royal_then_pay_check_2026-10-23.sql` (solitaire-dreams-411507, `bi_prod.user_daily_album` + `bi_entity_prod.dim_user_album_stickers`).

## Definitions
- Albums: Disney 14 and 15.
- Population: standard population; middle payers (P50–95 of spend so far at 75% of the album); 4+ stickers missing 14 days before close; active on 5+ of days 14–8 before close.
- Split: got at least 1 new Royal from a free source (not `purchase` / `purchase_gift`) in days 14–8 before close, yes / no.
- Windows: "before" = days 14–8 before close; "after" = days 7–1 before close. Spend = album-table daily spend (gross $).
- Near at close = 1–3 missing on the last row before close; done = 0 missing on that row.
- "Started paying after" = of the players who paid $0 before, the share who paid > $0 after.

## Results
| Album | Group | Players | Paid before / after | $ before / after | Near at close | Done by close | Started paying after |
|---|---|---|---|---|---|---|---|
| 14 | no free Royal | 102,616 | 67% / 64% | $17.65 / $18.88 | 26% | 5% | 42% |
| 14 | free Royal | 37,018 | 88% / 70% | $37.94 / $25.91 | 36% | 7% | 40% |
| 15 | no free Royal | 40,922 | 60% / 58% | $12.98 / $15.51 | 12% | 4% | 41% |
| 15 | free Royal | 83,447 | 80% / 69% | $31.62 / $24.35 | 31% | 7% | 47% |

## Reading
- **Fact:** players who got a free Royal end closer (near 31–36% vs 12–26%; done 7% vs 4–5%).
- **Fact:** they paid more before (88% / 80% paid), and their spend drops in the last week ($38 → $26, $32 → $24). Spend of players with no free Royal rises a little.
- **Fact:** of those who did not pay before, the share who paid after is about the same in both groups (40–47% vs 41–42%). Base: 12–20% of the free-Royal group did not pay before (about 4,400 and 16,700 players).
- **Interpretation:** the free-Royal group is more engaged to begin with (they paid more), so the progress gap is not proof that the Royal caused it.
- **Hypothesis:** a steady Royal source in the last 14 days raises progress; it is not known whether it raises spend or replaces it. Test it (slide "Test Idea: A Steady Royal Source in Disney's Last 14 Days"), with spend in the last 7 days as a main measure.

Recommendation: **test**, do not adopt yet.
