import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from lib import *
rows = {"dice": [("61", 52, "#7A7A7A"), ("63", 30)], "domino": [("19", 63, "#7A7A7A"), ("20", 31)], "disney": [("14", 53, "#7A7A7A"), ("15", 53)]}
body = vbars_panels(rows, 80, lambda v: f"{v:g}%", top=300, height=520, cat_size=26, val_size=34)
for i, txt in enumerate(["−23 pts · finish 8.1% → 10.5%", "−31 pts · finish 4.5% → 8.0%", "0 pts · finish 3.8% → 4.1%"]):
    body += p([128, 704, 1280][i], 836, 512, txt, 26, "#F5F5F0", "center", 500)
html = section("album-swings", f"Albums Differ a Lot {g('Within')} Dice and Domino",
               "% of payers' revenue still 4+ stickers away 3 days before close · two albums per game · below: payer finish rate",
               body, "Chapter 2",
               "Fact. Standard population (not first album, login ratio 0.5+, exclusions, close day excluded); revenue = album-table spend from album start to close−3; stickers = unique stickers on that day. Dice 61: 52.4%, 63: 29.6%; Domino 19: 62.6%, 20: 31.3%; Disney 14: 52.5%, 15: 52.7%. Payers at close−3: Dice 173.6K / 178.8K, Domino 117.8K / 105.4K, Disney 366.2K / 321.8K. Same cut at close−4 (the existing studio goal day): Dice 62% / 47%, Domino 69% / 45%, Disney 56% / 57%. Finish rate = payers with 144 unique stickers before close. Also: Domino 19 easy version reached 5% vs 57% for the hard version at $2–5 a day. The cause of each swing is not known (events, release timing, version). Meaning: inside Dice and Domino the album design is a large lever; comparing games needs the same albums. SQL: claude/stand_close3_queries.sql.", gap=20)
open(os.path.join(sys.argv[1], "project/slides/album-swings.html"), "w").write(html)
