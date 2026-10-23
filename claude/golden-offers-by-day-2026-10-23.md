# Which Golden offers ran on each of the last 10 days (2026-10-23)

**Question (Eden):** on which of the last 10 days could players buy a Golden at all? A day with bought-Golden purchases = an offer was live that day.
**SQL:** end of `claude/golden_purchase_revenue_2026-10-22.sql` (Dice in full; Domino / Disney same logic, offer = mtx campaign name). Albums Dice 63, Domino 19, Disney 14 (same as slide 30). Players who got a bought new Golden, by offer and day; offers with 100+ buyer-days.
**Limit:** an offer is only visible if someone got a new Golden from it; an offer that was live but gave no new Golden does not show.

## Answer: every day, in all three games
| Game | Days with Golden buyers | Always-on channel | Rotating offers |
|---|---|---|---|
| Dice 63 | 10 / 10 | Pricing_Specific (pick a sticker) every day: 4,951–9,924 buyers; G2G 135–1,414; C3P / C4P small | — |
| Domino 19 | 10 / 10 | none large ("source: purchase" 33–296 a day) | 1–3 day offers, a new one every 1–2 days: 8BoxBees d−10..−8 (3,418 peak), 6BoxRainbow d−8..−7, Puzzle Rolling Offer d−5..−3, 8boxJollyGems d−4..−2 (4,467 peak), Scroll&Roll, 1PO / 1+N packs; Golden-named: 1poGolden d−7 (133), 1PoGoldenCard d−1 (340) |
| Disney 14 | 10 / 10 | endofsceneoffer1po every day, falling 3,353 → 750 | 1–2 day offers: 1POTriple-Anniversary d−9..−8 (8,288 peak), 1+12BlackFriday d−10..−9, 1+9Anniversary d−4..−3, 1+12Cinderella d−3..−2; Golden-named: 1+3GoldenDeal d−8..−7, 1+3GoldenOffer d−3..−2 |

## Reading
- **Fact:** a Golden could be bought on every one of the 10 days in all three games.
- **Fact:** Dice has one steady channel (specific-sticker purchase) that sells Goldens every day; Domino and Disney sell Goldens mostly through offers that change every 1–3 days.
- **Fact:** the daily peaks on slide 30 line up with the big offers: Domino d−3 = 8boxJollyGems, Disney d−9 = 1POTriple-Anniversary, Disney d−6 low = no big offer that day.
- **Interpretation:** in Domino and Disney the share buying a Golden on a day depends mostly on which offer is live, not only on demand.
