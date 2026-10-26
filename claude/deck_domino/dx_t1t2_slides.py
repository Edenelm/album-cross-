"""Build 4 Domino-diagnosis slides (topics 2 and 1) for the Google Slides Domino deck, 2026-10-25.
Style copied from existing slides (tx_rv, d20r1_slide): bg #212121, Oswald, title 24pt #F5F5F5, gold #FFDF85 key words,
red #FF0B47 problems, Domino orange #F5A04A, cards #2B2B2B with 1pt outline, footer 'SuperPlay 2026' 8pt #9E9E9E.
Usage: python3 dx_t1t2_slides.py <revisionId> <insertionIndex>  -> prints the update_presentation JSON body."""
import json, sys

EMU = 914400
def hexc(h):
    h = h.lstrip('#'); return {"red": round(int(h[0:2],16)/255,3), "green": round(int(h[2:4],16)/255,3), "blue": round(int(h[4:6],16)/255,3)}
BG, TXT, GREY, FOOT, GOLD, RED, ORANGE, CARD, LINE = '#212121','#F5F5F5','#BDBDBD','#9E9E9E','#FFDF85','#FF0B47','#F5A04A','#2B2B2B','#444444'

R = []
def slide(sid, idx):
    R.append({"createSlide": {"objectId": sid, "insertionIndex": idx, "slideLayoutReference": {"predefinedLayout": "BLANK"}}})
    R.append({"updatePageProperties": {"objectId": sid, "pageProperties": {"pageBackgroundFill": {"solidFill": {"color": {"rgbColor": hexc(BG)}}}}, "fields": "pageBackgroundFill.solidFill.color"}})

def shape(sid, oid, kind, x, y, w, h, fill=None, outline=None, weight=1):
    R.append({"createShape": {"objectId": oid, "shapeType": kind, "elementProperties": {"pageObjectId": sid,
        "size": {"width": {"magnitude": int(w*EMU), "unit": "EMU"}, "height": {"magnitude": int(h*EMU), "unit": "EMU"}},
        "transform": {"scaleX": 1, "scaleY": 1, "translateX": int(x*EMU), "translateY": int(y*EMU), "unit": "EMU"}}}})
    if kind == "TEXT_BOX" and not fill and not outline: return
    props, fields = {}, []
    if fill: props["shapeBackgroundFill"] = {"solidFill": {"color": {"rgbColor": hexc(fill)}}}; fields.append("shapeBackgroundFill.solidFill.color")
    else: props["shapeBackgroundFill"] = {"propertyState": "NOT_RENDERED"}; fields.append("shapeBackgroundFill.propertyState")
    if outline: props["outline"] = {"outlineFill": {"solidFill": {"color": {"rgbColor": hexc(outline)}}}, "weight": {"magnitude": weight, "unit": "PT"}}; fields += ["outline.outlineFill.solidFill.color", "outline.weight"]
    else: props["outline"] = {"propertyState": "NOT_RENDERED"}; fields.append("outline.propertyState")
    R.append({"updateShapeProperties": {"objectId": oid, "shapeProperties": props, "fields": ",".join(fields)}})

def text(sid, oid, x, y, w, h, runs, size=11, color=TXT, bold=False, align="START", kind="TEXT_BOX", fill=None, outline=None, valign=None):
    """runs: str or list of (text, color or None, bold or None)."""
    shape(sid, oid, kind, x, y, w, h, fill, outline)
    if isinstance(runs, str): runs = [(runs, None, None)]
    full = "".join(r[0] for r in runs)
    R.append({"insertText": {"objectId": oid, "text": full, "insertionIndex": 0}})
    R.append({"updateTextStyle": {"objectId": oid, "textRange": {"type": "ALL"}, "style": {"fontFamily": "Oswald", "fontSize": {"magnitude": size, "unit": "PT"},
        "bold": bold, "foregroundColor": {"opaqueColor": {"rgbColor": hexc(color)}}}, "fields": "fontFamily,fontSize,bold,foregroundColor"}})
    i = 0
    for t, c, b in runs:
        n = len(t.encode('utf-16-le')) // 2
        st, f = {}, []
        if c: st["foregroundColor"] = {"opaqueColor": {"rgbColor": hexc(c)}}; f.append("foregroundColor")
        if b is not None: st["bold"] = b; f.append("bold")
        if f and n: R.append({"updateTextStyle": {"objectId": oid, "textRange": {"type": "FIXED_RANGE", "startIndex": i, "endIndex": i+n}, "style": st, "fields": ",".join(f)}})
        i += n
    if align != "START": R.append({"updateParagraphStyle": {"objectId": oid, "textRange": {"type": "ALL"}, "style": {"alignment": align}, "fields": "alignment"}})
    if valign: R.append({"updateShapeProperties": {"objectId": oid, "shapeProperties": {"contentAlignment": valign}, "fields": "contentAlignment"}})

def frame(sid, title_runs, sub, msg_runs):
    text(sid, sid+"_ti", 0.5, 0.25, 9.0, 0.5, title_runs, size=22)
    text(sid, sid+"_su", 0.5, 0.72, 9.0, 0.28, sub, size=10, color=GREY)
    text(sid, sid+"_ms", 0.5, 4.72, 7.2, 0.5, msg_runs, size=11)
    text(sid, sid+"_ft", 7.78, 5.25, 1.72, 0.25, "SuperPlay 2026", size=8, color=FOOT)

rev, idx = sys.argv[1], int(sys.argv[2])

# ---------- Slide 1: gate structure ----------
s = "dxgate_slide"; slide(s, idx)
frame(s, [("End Gate by Segment: ", None, None), ("Album 19 vs Album 20", GOLD, None)],
      "Domino · set stickers that players got almost only by Joker (85–100% of holders) · from sticker data, not config",
      [("Album 20 used ", None, None), ("one 3-sticker gate for Easy and Hard", GOLD, None), (". In album 19 Easy needed 5, Hard 3.", None, None)])
panels = [(0.5, "Album 19", [
            ("Easy", "107,532 payers (90%) · 40% of game revenue", ["R","R","G","G","G*"]),
            ("Hard", "11,423 payers (10%) · 37% of game revenue", ["R","R","G"])]),
          (5.1, "Album 20", [
            ("Easy", "97,697 payers (92%) · 43% of game revenue", ["R","R","G"]),
            ("Hard", "8,823 payers (8%) · 36% of game revenue", ["R","R","G"])])]
for pi, (px, name, rows) in enumerate(panels):
    shape(s, f"{s}_p{pi}", "RECTANGLE", px, 1.15, 4.4, 3.3, fill=CARD, outline=LINE)
    text(s, f"{s}_h{pi}", px+0.2, 1.22, 4.0, 0.4, name, size=16, bold=True)
    for ri, (seg, pop, sq) in enumerate(rows):
        y = 1.75 + ri*1.3
        text(s, f"{s}_s{pi}{ri}", px+0.2, y, 1.0, 0.35, seg, size=14, bold=True)
        text(s, f"{s}_n{pi}{ri}", px+0.2, y+0.85, 4.0, 0.3, pop, size=9, color=GREY)
        for k, lab in enumerate(sq):
            late = lab.endswith("*")
            text(s, f"{s}_q{pi}{ri}{k}", px+1.2+k*0.6, y, 0.5, 0.5, lab.rstrip("*"), size=14, bold=True,
                 color=(ORANGE if late else BG), align="CENTER", kind="RECTANGLE",
                 fill=(None if late else ORANGE), outline=(ORANGE if late else None), valign="MIDDLE")
        cap = "4 Joker-only + 1 released 4 days before close" if len(sq) == 5 else "3 Joker-only stickers"
        text(s, f"{s}_c{pi}{ri}", px+1.2, y+0.52, 3.1, 0.3, cap, size=10, color=TXT)
text(s, s+"_lg", 0.5, 4.48, 9.0, 0.25, [("R = Royal · G = Golden · filled = Joker only · ", None, None), ("outline = released 4 days before close", ORANGE, None)], size=9, color=GREY)

# ---------- Slide 2: finish rate by distance, same spend level ----------
s = "dxdist_slide"; slide(s, idx+1)
frame(s, [("Finish Rate by Stickers Missing 4 Days Before Close, ", None, None), ("Same Spend Level", GOLD, None)],
      "Domino album 20 · standard-population payers · spend level = own $ a day up to 4 days before close · finish = 144 by end of close day",
      [("At the same spend level, ", None, None), ("3 missing finishes like 4–5", GOLD, None), (" (1–3 points apart). The jump is at 1–2, after a first gate Joker.", None, None)])
groups = [("Easy · up to $2 a day", "54,659 payers · 10% of game revenue", [26, 9, 6, 4]),
          ("Easy · $5–20 a day", "5,377 payers · 13% of game revenue", [45, 17, 15, 11]),
          ("Hard · over $20 a day", "1,266 payers · 14% of game revenue", [70, 46, 45, 18])]
labels = ["1–2", "3", "4–5", "6–10"]
base_y, max_h, gw = 3.95, 2.3, 2.9
for gi, (gname, gpop, vals) in enumerate(groups):
    gx = 0.6 + gi*3.0
    text(s, f"{s}_g{gi}", gx, 1.1, gw, 0.3, gname, size=12, bold=True, align="CENTER")
    for bi, v in enumerate(vals):
        bx = gx + 0.18 + bi*0.67; bh = max_h * v / 70
        hl = labels[bi] in ("3", "4–5")
        shape(s, f"{s}_b{gi}{bi}", "RECTANGLE", bx, base_y-bh, 0.5, bh, fill=(GOLD if hl else ORANGE))
        text(s, f"{s}_v{gi}{bi}", bx-0.15, base_y-bh-0.28, 0.8, 0.26, f"{v}%", size=11, bold=True, align="CENTER")
        text(s, f"{s}_x{gi}{bi}", bx-0.15, base_y+0.03, 0.8, 0.24, labels[bi], size=10, color=GREY, align="CENTER")
    text(s, f"{s}_p{gi}", gx, base_y+0.3, gw, 0.25, gpop, size=9, color=GREY, align="CENTER")
text(s, s+"_ax", 0.5, 4.48, 9.0, 0.22, "Bars = % who finished · labels under bars = stickers missing 4 days before close (3 = only the 3 Joker-only gate stickers)", size=9, color=GREY)

# ---------- Slide 3: mix vs behaviour ----------
s = "dxmix_slide"; slide(s, idx+2)
frame(s, [("Revenue per Player, Album 19 vs 20: ", None, None), ("Same Players vs Player Mix", GOLD, None)],
      "Domino · standard population, all players (352,951 → 317,155) · spend level = $ a day in the previous album · revenue = album start to close−1",
      [("Inside each spend level revenue per player rose ", None, None), ("5–11%", GOLD, None), ("; fewer high spenders took back 2%. Against album 18 the per-day gain is about 5%.", None, None)])
# left: waterfall
shape(s, s+"_lp", "RECTANGLE", 0.5, 1.1, 4.3, 3.35, fill=CARD, outline=LINE)
text(s, s+"_lh", 0.65, 1.15, 4.0, 0.3, "Revenue per player", size=12, bold=True)
wf = [("Album 19", 38.40, 0, 38.40, GREY), ("Same levels", 2.95, 38.40, 41.35, GOLD), ("Mix", -0.84, 40.51, 41.35, RED), ("Album 20", 40.44, 0, 40.44, ORANGE)]
lo, hi, bot, top = 36.0, 42.0, 4.0, 1.75
def yv(v): return bot - (v-lo)/(hi-lo)*(bot-top)
for i, (lab, val, a, b, col) in enumerate(wf):
    x = 0.75 + i*1.0
    y0, y1 = (yv(max(a,lo)), yv(b)) if a else (yv(lo), yv(val))
    if lab == "Mix": y1, y0 = yv(41.35), yv(40.51)
    shape(s, f"{s}_w{i}", "RECTANGLE", x, min(y0,y1), 0.6, abs(y0-y1), fill=col)
    vt = f"${val:,.2f}" if lab in ("Album 19","Album 20") else (f"+${val:.2f}" if val > 0 else f"−${-val:.2f}")
    text(s, f"{s}_wv{i}", x-0.2, min(y0,y1)-0.27, 1.0, 0.25, vt, size=10, bold=True, align="CENTER")
    text(s, f"{s}_wl{i}", x-0.2, 4.03, 1.0, 0.25, lab, size=9, color=GREY, align="CENTER")
text(s, s+"_ax", 0.65, 1.42, 4.0, 0.22, "axis starts at $36 · rest of the gap = interaction (−$0.08)", size=8, color=GREY)
# right: per level
shape(s, s+"_rp", "RECTANGLE", 5.0, 1.1, 4.5, 3.35, fill=CARD, outline=LINE)
text(s, s+"_rh", 5.15, 1.15, 4.2, 0.3, "Change inside each level, album 19 → 20", size=12, bold=True)
levels = [("$0 in previous album", "208,240 · 66% of players · 4% of revenue", -3),
          ("up to $2 a day", "78,007 · 25% · 23%", 11), ("$2–5 a day", "15,521 · 5% · 19%", 10),
          ("$5–20 a day", "10,485 · 3% · 32%", 9), ("over $20 a day", "1,909 · 0.6% · 20%", 5)]
for i, (lab, pop, pct) in enumerate(levels):
    y = 1.55 + i*0.56
    text(s, f"{s}_ll{i}", 5.15, y, 1.9, 0.28, lab, size=10, bold=True)
    text(s, f"{s}_lp{i}", 5.15, y+0.24, 2.2, 0.24, pop, size=8, color=GREY)
    bw = abs(pct) / 12 * 1.5
    shape(s, f"{s}_lb{i}", "RECTANGLE", 7.35, y+0.06, max(bw, 0.05), 0.3, fill=(RED if pct < 0 else ORANGE))
    text(s, f"{s}_lv{i}", 7.35+max(bw,0.05)+0.05, y+0.04, 0.7, 0.3, f"{'+' if pct>0 else '−'}{abs(pct)}%", size=10, bold=True)

# ---------- Slide 4: test ----------
s = "dxtest_slide"; slide(s, idx+3)
text(s, s+"_ti", 0.5, 0.3, 9.0, 0.5, [("Test", RED, None), (": Earlier First Gate Joker for Easy Players", None, None)], size=22)
text(s, s+"_ft", 7.78, 5.25, 1.72, 0.25, "SuperPlay 2026", size=8, color=FOOT)
text(s, s+"_wl", 0.5, 0.9, 1.0, 0.25, "WHO", size=9, bold=True, color=GREY)
text(s, s+"_wb", 0.5, 1.1, 9.0, 0.45, "Easy payers 3–5 stickers short a week before close. Size at 4 days before close, album 20: 36,734 payers (38% of Easy payers), 24% of game revenue.", size=11)
cards = [("Control", GREY, "Today: gate Jokers come from the Joker Puzzle, offers and late events; most arrive in the last 4 days."),
         ("A · Free Joker", GOLD, "One Joker for a gate sticker 7 days before close (timing = management choice)."),
         ("B · 1-Joker offer", GOLD, "A discounted single-Joker offer 7 days before close (price = management choice).")]
for i, (h, hc, b) in enumerate(cards):
    x = 0.5 + i*3.05
    shape(s, f"{s}_c{i}", "RECTANGLE", x, 1.7, 2.85, 1.6, fill=CARD, outline=(LINE if i == 0 else TXT))
    text(s, f"{s}_ch{i}", x+0.12, 1.78, 2.6, 0.38, h, size=16, bold=True, color=hc)
    text(s, f"{s}_cb{i}", x+0.12, 2.2, 2.6, 1.05, b, size=10.5)
text(s, s+"_ml", 0.5, 3.45, 1.2, 0.25, "MEASURE", size=9, bold=True, color=GREY)
text(s, s+"_mb", 0.5, 3.65, 9.0, 0.5, "Main: revenue per assigned player, last 7 days + week after close · Secondary: finish rate · Guardrails: Hard and over-$20 revenue, finishers who never paid", size=11)
text(s, s+"_ms", 0.5, 4.45, 7.2, 0.6, [("Hypothesis, not a decision: ", GOLD, None), ("at the gate, finish rate was the same with a 5- or 3-sticker gate; players who already had a first gate Joker finished 2–3× more often.", None, None)], size=11)

print(json.dumps(separators=(",",":"), obj={"presentationId": "1bVGI1Sb49fJ-a4Cp8AHs5hTOYjrTuQlJbW9vStaJr1o", "requests": R, "writeControl": {"requiredRevisionId": rev}}))
