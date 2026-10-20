# Where players stand 4 days before close — revenue 4+ stickers away (run 2026-10-18, Eden approved)

Population: standard (not first album, login ratio 0.5+ on the last row before close, exclusions, Domino cheaters out, close day excluded). Albums Dice 61/63, Domino 19/20, Disney 14/15.
Revenue = album-table spend from album start to close−4. Stickers = max unique stickers on rows up to close−4. Far = 4+ missing of 144; near = 3 or fewer.
Group = spend so far ÷ days so far at close−4 (0 / ≤2 / 2–5 / 5–20 / >20 $ a day). Scans: Dice 5.5 GB, Domino 10.2 GB, Disney 20.5 GB. SQL: claude/stand_close4_queries.sql.

## Share of revenue that is far (4+ away) at close−4
| | Album A | Album B | Average |
|---|---|---|---|
| Dice | 61: 62.4% | 63: 47.1% | 55% |
| Domino | 19: 69.2% | 20: 45.4% | 57% |
| Disney | 14: 55.9% | 15: 56.7% | 56% |
Payers far: Dice 84% / 70%, Domino 95% / 77%, Disney 84% / 88%.

## By group (average of 2 albums): % of the group's revenue that is far (group's share of revenue)
| Group | Dice | Domino | Disney |
|---|---|---|---|
| ≤$2 | 79% (15%) | 87% (16%) | 91% (15%) |
| $2–5 | 67% (19%) | 75% (19%) | 77% (18%) |
| $5–20 | 55% (37%) | 56% (37%) | 54% (39%) |
| $20+ | 35% (29%) | 30% (28%) | 27% (28%) |
- The $5–20 group carries the most far revenue: ~20% of all revenue in each game.
- Consistent with far-revenue slide (24–43% still far AT close): some far players at close−4 get near by the end.
- Current revenue, not potential.

## Same cut at 3 days before close (Eden asked, 2026-10-18) — SQL: claude/stand_close3_queries.sql
| | Album A | Album B | Average | ≤$2 | $2–5 | $5–20 | $20+ |
|---|---|---|---|---|---|---|---|
| Dice | 61: 52.4% | 63: 29.6% | **41%** | 64% | 51% | 40% | 23% |
| Domino | 19: 62.6% | 20: 31.3% | **47%** | 78% | 63% | 44% | 22% |
| Disney | 14: 52.5% | 15: 52.7% | **53%** | 89% | 74% | 49% | 23% |
Payers far at close−3: Dice 77% / 49%, Domino 92% / 65%, Disney 82% / 86%.
- From close−4 to close−3, far revenue drops 14 points in Dice, 10 in Domino, 3 in Disney — consistent with Disney's closing window opening only 2–3 days before close.
- The studios' goal is defined at close−4; the deck chapter now shows close−3 (Eden's request). Goal definition itself not changed.

## Raw rows close−4 (players, revenue, players near, revenue near)
Dice 61: ≤2 121,329 / $2.24M / 12,183 / $0.31M; 2–5 28,304 / $2.88M / 6,897 / $0.72M; 5–20 19,365 / $5.74M / 6,704 / $2.09M; >20 3,485 / $4.51M / 1,836 / $2.66M; 0 288,417.
Dice 63: ≤2 126,143 / $2.81M / 28,940 / $0.80M; 2–5 28,744 / $3.56M / 11,738 / $1.48M; 5–20 19,601 / $7.08M / 10,317 / $3.86M; >20 3,533 / $5.45M / 2,422 / $3.86M; 0 267,931.
Domino 19: ≤2 88,014 / $2.10M / 511 / $0.02M; 2–5 16,304 / $2.37M / 902 / $0.15M; 5–20 10,980 / $4.66M / 2,806 / $1.41M; >20 2,016 / $3.52M / 1,218 / $2.31M; 0 235,637.
Domino 20: ≤2 77,153 / $1.93M / 10,678 / $0.49M; 2–5 15,345 / $2.25M / 6,684 / $0.99M; 5–20 10,548 / $4.47M / 5,882 / $2.59M; >20 1,895 / $3.28M / 1,354 / $2.43M; 0 212,214.
Disney 14: ≤2 260,539 / $5.78M / 23,523 / $0.71M; 2–5 56,101 / $6.98M / 13,845 / $1.79M; 5–20 40,647 / $14.76M / 17,508 / $6.82M; >20 7,342 / $10.20M / 4,991 / $7.31M; 0 837,150.
Disney 15: ≤2 228,230 / $5.06M / 8,868 / $0.33M; 2–5 49,457 / $6.15M / 9,530 / $1.26M; 5–20 35,882 / $13.02M / 15,176 / $5.95M; >20 6,642 / $9.77M / 4,570 / $7.19M; 0 766,202.

## Raw rows close−3
Dice 61: ≤2 122,272 / $2.33M / 19,437 / $0.50M; 2–5 28,438 / $2.99M / 9,652 / $1.03M; 5–20 19,398 / $5.93M / 8,767 / $2.81M; >20 3,485 / $4.67M / 2,244 / $3.24M.
Dice 63: ≤2 126,662 / $2.89M / 55,658 / $1.46M; 2–5 28,856 / $3.66M / 17,877 / $2.29M; 5–20 19,766 / $7.31M / 14,033 / $5.27M; >20 3,552 / $5.62M / 2,928 / $4.70M.
Domino 19: ≤2 88,476 / $2.15M / 2,334 / $0.09M; 2–5 16,339 / $2.42M / 1,974 / $0.31M; 5–20 11,021 / $4.79M / 3,768 / $1.86M; >20 2,008 / $3.59M / 1,350 / $2.58M.
Domino 20: ≤2 77,533 / $1.97M / 17,814 / $0.77M; 2–5 15,391 / $2.30M / 9,431 / $1.42M; 5–20 10,579 / $4.57M / 7,614 / $3.36M; >20 1,922 / $3.38M / 1,595 / $2.84M.
Disney 14: ≤2 262,271 / $5.94M / 25,553 / $0.80M; 2–5 56,070 / $7.15M / 15,256 / $2.03M; 5–20 40,519 / $15.07M / 19,177 / $7.62M; >20 7,307 / $10.41M / 5,277 / $7.85M.
Disney 15: ≤2 229,890 / $5.18M / 10,769 / $0.41M; 2–5 49,351 / $6.29M / 11,275 / $1.52M; 5–20 35,959 / $13.38M / 17,056 / $6.81M; >20 6,585 / $9.95M / 4,835 / $7.73M.

## Deck
v33: `stand` built at close−4; `disney-finishers` and `half-completions` → 2-album averages; "short" → "missing" on half-completions.
v39: `stand` rebuilt at close−3 (4-day numbers in notes); `snap-ch5` card → ~47%; `q-stand` title → "3 Days Before Close".
