import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from lib import *
rows = {"dice": [("61", 7.5), ("63", 11.3)], "domino": [("17", 6.6), ("19", 5.6)], "disney": [("14", 2.0), ("15", 5.5)]}
body = vbars_panels(rows, 14, lambda v: f"{v:g}%", top=290, height=500, cat_size=26, val_size=36)
for i, txt in enumerate(["2 Supers + 1 Golden · late by design (studio)",
                         "Last release phase · Golden in 17, Royal in 19",
                         "Royal + 2 Goldens · top sticker Royal 131"]):
    body += p([128, 704, 1280][i], 806, 512, txt, 24, "#F5F5F0", "center", 400)
body += p(128, 880, 1664, "→ In every game the top gate sticker reaches only 2–11% of payers before the last 2 days. Disney 14 was the scarcest.", 28, "#C8C8C0", "left", 300)
html = section("gates", f"Few Payers Hold the {g('Last Sticker')} 2 Days Out",
               "Share of payers holding each album's top gate sticker by the end of 2 days before close · same measure in all games",
               body, "Chapter 2",
               "Fact. Same measure for every album: share of all payers in the standard population (not first album, login ratio 0.5+, paid before close) holding the album's top gate sticker by the end of d−2. Gate stickers: Dice 61 S143 / S120 / G142, Dice 63 S132 / S143 / G129; Domino 17 G106 / G104 (+R108, the top sticker here is a Golden), Domino 19 R107 / R108 / G101; Disney 14 R131 / G84 / G130, Disney 15 R131 / G141 / G142. Domino albums are 17/19 because this analysis ran before album 20 closed. Other common facts: near-finishers (1–3 missing at the end) are almost all missing a gate sticker (Domino 97% / 89%, Disney 97% / 86%; Dice 92–95% of payers one sticker from a set are missing a Super). Only the Dice design is confirmed by the studio; for Domino and Disney the late release is seen in the data, the lock is not confirmed. Source: endgame-last-week-2026-10-14 (cross-game table).", gap=20)
open(os.path.join(sys.argv[1], "project/slides/gates.html"), "w").write(html)
