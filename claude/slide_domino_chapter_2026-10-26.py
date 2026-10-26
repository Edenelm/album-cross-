"""Domino chapter (Eden 2026-10-26): 4 slides in the Domino Google Slides deck (1bVGI1Sb49fJ-a4Cp8AHs5hTOYjrTuQlJbW9vStaJr1o),
same style as dxend_slide (dark #212121, Oswald, gold #FFDF85, orange bars #F5A14D, panels #2B2B2B / outline #444444, footer SuperPlay 2026).
Sources: claude/domino-dx-easy-end-decomp-2026-10-26.md, domino-dx-last3-sources-2026-10-26.md, domino-dx-t1-t2-2026-10-25.md, topic5-end-lift-2026-10-24.md.
Usage: python3 slide_domino_chapter_2026-10-26.py <dxw|dxsrc|dxfar|dxrec> [insertion_index] -> prints update_presentation requests (JSON)."""
import json, sys
E = 914400
WHITE, GOLD, GREY, DGREY, ORANGE, RED, PANEL, OUTL, BG = '#f5f5f5', '#ffdf85', '#bdbdbd', '#9e9e9e', '#f5a14d', '#ff0b47', '#2b2b2b', '#444444', '#212121'
BLUE, MID = '#4285f4', '#757575'

def rgb(h):
    h = h.lstrip('#'); return {'red': int(h[0:2], 16) / 255, 'green': int(h[2:4], 16) / 255, 'blue': int(h[4:6], 16) / 255}
def tf(x, y): return {'scaleX': 1, 'scaleY': 1, 'shearX': 0, 'shearY': 0, 'translateX': int(x * E), 'translateY': int(y * E), 'unit': 'EMU'}
def size(w, h): return {'width': {'magnitude': int(w * E), 'unit': 'EMU'}, 'height': {'magnitude': int(h * E), 'unit': 'EMU'}}

class Slide:
    def __init__(self, sid, idx):
        self.s, self.n, self.R = sid, 0, []
        self.R.append({'createSlide': {'objectId': sid, 'insertionIndex': idx, 'slideLayoutReference': {'layoutId': 'p12'}}})
        self.R.append({'updatePageProperties': {'objectId': sid, 'pageProperties': {'pageBackgroundFill': {'solidFill': {'color': {'rgbColor': rgb(BG)}}}}, 'fields': 'pageBackgroundFill'}})
    def oid(self, tag):
        self.n += 1; return f'{self.s}_{tag}{self.n}'
    def rect(self, x, y, w, h, fill, outline=None, tag='r'):
        o = self.oid(tag)
        props = {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': rgb(fill)}}}}
        fields = 'shapeBackgroundFill'
        if outline:
            props['outline'] = {'outlineFill': {'solidFill': {'color': {'rgbColor': rgb(outline)}}}, 'weight': {'magnitude': 1, 'unit': 'PT'}}; fields += ',outline'
        else:
            props['outline'] = {'propertyState': 'NOT_RENDERED'}; fields += ',outline'
        self.R.append({'createShape': {'objectId': o, 'shapeType': 'RECTANGLE', 'elementProperties': {'pageObjectId': self.s, 'size': size(w, h), 'transform': tf(x, y)}}})
        self.R.append({'updateShapeProperties': {'objectId': o, 'shapeProperties': props, 'fields': fields}})
        return o
    def text(self, x, y, w, h, t, sz=10, color=WHITE, bold=False, align='START', spans=(), valign='TOP', tag='t'):
        """spans = [(substring, color, bold?)] styled inside the text."""
        o = self.oid(tag)
        self.R.append({'createShape': {'objectId': o, 'shapeType': 'TEXT_BOX', 'elementProperties': {'pageObjectId': self.s, 'size': size(w, h), 'transform': tf(x, y)}}})
        if valign != 'TOP': self.R.append({'updateShapeProperties': {'objectId': o, 'shapeProperties': {'contentAlignment': valign}, 'fields': 'contentAlignment'}})
        self.R.append({'insertText': {'objectId': o, 'text': t}})
        self.R.append({'updateTextStyle': {'objectId': o, 'textRange': {'type': 'ALL'}, 'style': {'fontFamily': 'Oswald', 'fontSize': {'magnitude': sz, 'unit': 'PT'}, 'bold': bold, 'foregroundColor': {'opaqueColor': {'rgbColor': rgb(color)}}}, 'fields': 'fontFamily,fontSize,bold,foregroundColor'}})
        if align != 'START': self.R.append({'updateParagraphStyle': {'objectId': o, 'textRange': {'type': 'ALL'}, 'style': {'alignment': align}, 'fields': 'alignment'}})
        for sub, c, *b in spans:
            i = t.index(sub)
            st = {'foregroundColor': {'opaqueColor': {'rgbColor': rgb(c)}}}; f = 'foregroundColor'
            if b and b[0]: st['bold'] = True; f += ',bold'
            self.R.append({'updateTextStyle': {'objectId': o, 'textRange': {'type': 'FIXED_RANGE', 'startIndex': i, 'endIndex': i + len(sub)}, 'style': st, 'fields': f}})
        return o
    def frame(self, title, sub, msg, msg_spans=()):
        self.text(0.5, 0.12, 9.0, 0.5, title, 22, WHITE, spans=[(s, GOLD) for s in title.split('|')[1:2]] if '|' in title else ())
        self.text(0.5, 0.63, 9.0, 0.28, sub, 10, GREY)
        self.text(0.5, 4.72, 8.6, 0.5, msg, 11, WHITE, spans=msg_spans)
        self.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    def panel(self, x, y, w, h, head=None):
        self.rect(x, y, w, h, PANEL, OUTL, tag='p')
        if head: self.text(x + 0.15, y + 0.05, w - 0.3, 0.3, head, 12, WHITE, bold=True)
    def notes(self, text):
        self.notes_text = text

def title_spans(t, gold):
    return [(gold, GOLD)]

# ---------------- slide 1: which end worked better ----------------
def dxw(idx):
    S = Slide('dxw_slide', idx)
    t = 'Which End Worked Better? Easy ARPDAU in the Final 4 Days, Albums 17–20'
    S.text(0.5, 0.12, 9.0, 0.5, t, 22, WHITE, spans=[('Which End Worked Better?', GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, 'Domino · Easy players, standard population (not first album, logged in on over half of the album days) · ARPDAU = revenue ÷ active player days · grey = rest of the album, orange = last 4 full days', 10, GREY)
    S.panel(0.5, 1.1, 6.1, 3.35, 'ARPDAU, rest of the album → last 4 days')
    alb = [('Album 17', '4 end stickers,\nopen routes', 1.161, 1.293, '+11%'), ('Album 18', 'gate: 2 stickers', 1.183, 1.616, '+37%'),
           ('Album 19', 'gate: 5 stickers', 1.02, 1.193, '+17%'), ('Album 20', 'gate: 3 stickers', 1.082, 1.355, '+25%')]
    base, scale, bw = 3.5, 1.15, 0.36
    for i, (name, gate, r, l, lift) in enumerate(alb):
        x = 0.85 + i * 1.45
        hr, hl = r * scale, l * scale
        S.rect(x, base - hr, bw, hr, GREY)
        S.rect(x + bw + 0.08, base - hl, bw, hl, ORANGE)
        S.text(x - 0.12, base - hr - 0.24, bw + 0.24, 0.22, f'${r:.2f}', 8, GREY, align='CENTER')
        S.text(x + bw + 0.08 - 0.12, base - hl - 0.24, bw + 0.24, 0.22, f'${l:.2f}', 8, WHITE, align='CENTER')
        S.text(x + bw + 0.08 - 0.2, base - hl - 0.5, bw + 0.4, 0.26, lift, 13, GOLD if lift in ('+37%', '+25%') else WHITE, bold=True, align='CENTER')
        S.text(x - 0.25, base + 0.05, 1.3, 0.5, f'{name}\n{gate}', 9, GREY, align='CENTER')
    S.text(0.65, 4.1, 5.8, 0.3, 'Paying share of active player days, rest → last 4 days:  17: 10.6% → 10.3%   ·   18: 10.5% → 13.0%   ·   19: 10.0% → 10.5%   ·   20: 10.2% → 11.0%', 8, GREY)
    S.panel(6.8, 1.1, 2.7, 3.35, 'What rose at the end')
    S.text(6.95, 1.45, 2.4, 2.9,
           'Album 18 (+37%): the share of paying players rose most (+24%); purchases per payer +5%, $ per purchase +6%.\n\n'
           'Album 20 (+25%): $ per purchase +13% and paying share +8%. The extra dollars came from Joker and album offers sold only in the final days.\n\n'
           'Albums 17 and 19: smaller rises, mostly $ per purchase.\n\n'
           'Easy players: 439,885 / 388,716 / 341,237 / 308,158 (albums 17–20) · Easy = 90–92% of payers and 40–43% of game revenue (albums 19–20).',
           9, GREY, spans=[('Album 18 (+37%)', WHITE, True), ('Album 20 (+25%)', WHITE, True), ('Albums 17 and 19', WHITE, True)])
    S.text(0.5, 4.72, 8.6, 0.5, 'Albums 18 and 20, with a 2–3 sticker gate, ended strongest: +37% and +25%. The whole end structure worked better; which part caused it is not isolated (end offers and calendar changed too). Keep album 20\'s end as the standard.',
           11, WHITE, spans=[('+37% and +25%', GOLD), ('Keep album 20\'s end as the standard.', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

# ---------------- slide 2: last 3 stickers sources ----------------
CATS = [('Joker won in a free event / mini-game', ORANGE), ('Joker from a paid offer', GOLD), ('Sticker from an event / mini-game', GREY), ('Sticker from a paid offer', MID), ('Market / duplicates', BLUE), ('Other', OUTL)]
def dxsrc(idx, data, fin, easy, gate):
    """data[album] = list of 6 percentages (sum ~100)."""
    S = Slide('dxsrc_slide', idx)
    S.text(0.5, 0.12, 9.0, 0.5, 'How Finishers Got Their Last 3 Stickers, Albums 17–20', 22, WHITE, spans=[('Last 3 Stickers', GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, 'Domino · finishers only (144 stickers by the end of the close day; album 18: 168), standard population, Easy + Hard · each finisher\'s 3 last-collected stickers (3 per finisher) · source = first collection of that sticker', 10, GREY)
    S.panel(0.5, 1.1, 9.0, 3.35, 'Source of the last 3 stickers, % of those stickers')
    x0, wtot, y, hb = 2.0, 6.3, 1.55, 0.42
    for i, a in enumerate((17, 18, 19, 20)):
        yy = y + i * 0.62
        S.text(0.65, yy - 0.02, 1.3, 0.46, f'Album {a}\n{fin[a]:,} finishers', 9, WHITE, bold=False, spans=[(f'Album {a}', WHITE, True)])
        xx = x0
        for (lab, col), v in zip(CATS, data[a]):
            w = wtot * v / 100
            if w > 0.005:
                S.rect(xx, yy, w, hb, col)
                if v >= 7: S.text(xx, yy + 0.1, w, 0.25, f'{v:.0f}%', 9, BG if col in (GOLD, GREY, ORANGE) else WHITE, bold=True, align='CENTER')
            xx += w
        S.text(x0 + wtot + 0.08, yy + 0.02, 1.0, 0.42, f'{gate[a]}% are\ngate stickers', 8, GREY)
    # legend
    lx = 0.65
    for lab, col in CATS:
        S.rect(lx, 4.1, 0.14, 0.14, col); S.text(lx + 0.18, 4.05, 1.5, 0.25, lab, 8, GREY); lx += 1.45 if len(lab) < 24 else 1.9
    S.text(0.5, 4.72, 8.6, 0.5, 'In album 20, 81% of finishers\' last stickers came through Jokers won in free end events (Joker Puzzle from close−14, Movie Twister at close−4); paid Joker offers gave 6%. Album 19 leaned on later events and paid Jokers; album 17 on events, offers and the Market. Keep album 20\'s free Joker route.',
           11, WHITE, spans=[('81%', GOLD), ('Keep album 20\'s free Joker route.', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

# ---------------- slide 3: far Easy payers ----------------
def dxfar(idx):
    S = Slide('dxfar_slide', idx)
    S.text(0.5, 0.12, 9.0, 0.5, 'Most Easy Payers Are Still Far 4 Days Before Close: Album 20', 22, WHITE, spans=[('Still Far', GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, 'Domino album 20 · Easy paying players, standard population (97,937) · status at close−4 · revenue share = share of game purchase revenue during the album ($16,269,671)', 10, GREY)
    S.panel(0.5, 1.1, 5.3, 3.35, 'Easy payers by stickers missing at close−4')
    grp = [('Done', 1, 2, GREY), ('1–3', 20, 18, GREY), ('4–5', 23, 12, RED), ('6–10', 32, 8, RED), ('11+', 25, 4, RED)]
    base, scale, bw = 3.35, 0.05, 0.55
    for i, (g, p, r, col) in enumerate(grp):
        x = 0.85 + i * 0.95
        h = p * scale
        S.rect(x, base - h, bw, h, col)
        S.text(x - 0.15, base - h - 0.26, bw + 0.3, 0.24, f'{p}%', 10, WHITE, bold=True, align='CENTER')
        S.text(x - 0.2, base + 0.05, bw + 0.4, 0.5, f'{g} missing\n{r}% of game rev', 8, GREY, align='CENTER')
    S.rect(0.7, 3.98, 4.9, 0.4, BG)
    S.text(0.75, 4.0, 4.8, 0.36, '4+ missing: 77,816 payers · 79% of Easy payers · 24% of game revenue', 10, RED, bold=True, align='CENTER')
    S.panel(6.0, 1.1, 3.5, 3.35, 'Who they are (4–10 missing)')
    S.text(6.15, 1.45, 3.2, 2.95,
           'Active: 82–90% logged in on 80%+ of the album days.\n\n'
           'What they miss at close−4: 2.4 Royals + 2.1 Goldens (4–5 missing); 3.7 Royals + 3.6 Goldens (6–10). Beyond the 3 gate stickers that is 1–2 Royals and 1–3 Goldens already released.\n\n'
           'New rares in the last third (days 16–5): 9.2 and 8.8 per player, vs 9.4 for players within 3. They are not catching up.\n\n'
           '11+ missing is a different group: 45% active 80%+, 6.7 commons missing.',
           9, GREY, spans=[('Active:', WHITE, True), ('What they miss at close−4:', WHITE, True), ('New rares in the last third', WHITE, True)])
    S.text(0.5, 4.72, 8.6, 0.5, 'They play almost every day and still end far, missing released Royals and Goldens. Bringing them closer before the final days is the opportunity: 24% of game revenue sits here.',
           11, WHITE, spans=[('24% of game revenue', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

# ---------------- slide 4: recommendations ----------------
def dxrec(idx):
    S = Slide('dxrec_slide', idx)
    S.text(0.5, 0.12, 9.0, 0.5, 'What to Do in Domino: Keep One Thing, Test One Thing', 22, WHITE, spans=[('Keep One Thing, Test One Thing', GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, 'Two actions for the Domino team · sizes from album 20, Easy paying players, standard population · revenue share = share of game revenue during the album', 10, GREY)
    S.panel(0.5, 1.1, 4.4, 3.5)
    S.text(0.65, 1.15, 4.1, 0.3, 'KEEP · album 20\'s end route', 12, GOLD, bold=True)
    S.text(0.65, 1.5, 4.1, 3.0,
           'Who: Easy payers (97,937 · 92% of payers · 43% of game revenue).\n\n'
           'What: a 3-sticker gate for Easy (same as Hard) plus a free Joker path that opens two weeks before close (Joker Puzzle, close−14 to close−5) and a Joker event at close−4 (Movie Twister). Album 19 had a 5-sticker Easy gate and no early Joker path.\n\n'
           'Result alongside it, 19 → 20: payers within 3 at close−4 5% → 23% (31% → 55% of revenue); Easy end ARPDAU +17% → +25%; 81% of finishers\' last stickers came via event Jokers.\n\n'
           'Watch: revenue within 3 at close−4 ≥ 55%; Easy end ARPDAU lift ≥ +25%.',
           9, GREY, spans=[('Who:', WHITE, True), ('What:', WHITE, True), ('Result alongside it, 19 → 20:', WHITE, True), ('Watch:', WHITE, True)])
    S.panel(5.1, 1.1, 4.4, 3.5)
    S.text(5.25, 1.15, 4.1, 0.3, 'TEST · earlier supply of released rares to far Easy payers', 12, ORANGE, bold=True)
    S.text(5.25, 1.5, 4.1, 3.0,
           'Who: Easy payers 6–12 missing one week before close (59,648 · 61% of Easy payers · 26% of game revenue). Entry point close−14 to close−7: management choice.\n\n'
           'Change: from close−14, a steady source of Royals and Goldens that are already released (event reward or specific-sticker offer) for this group, so they reach ≤3 before the final days. Control = today\'s flow. End offers identical in both arms.\n\n'
           'Success: share of the group at ≤3 missing by close−4 (today 31% for 6–8, 10% for 9–12); revenue per assigned player close−14 to close−1 and the week after.\n\n'
           'Guardrails: Hard and over-$20 revenue; non-payer finish rate.',
           9, GREY, spans=[('Who:', WHITE, True), ('Change:', WHITE, True), ('Success:', WHITE, True), ('Guardrails:', WHITE, True)])
    S.text(0.5, 4.72, 8.6, 0.5, 'Keep the end that worked (album 20), and test the lever for the 79% who end far: earlier supply of released rares, measured on revenue per player.',
           11, WHITE, spans=[('Keep the end that worked (album 20)', GOLD), ('test the lever for the 79% who end far', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

if __name__ == '__main__':
    which = sys.argv[1]; idx = int(sys.argv[2]) if len(sys.argv) > 2 else 106
    if which == 'dxw': S = dxw(idx)
    elif which == 'dxfar': S = dxfar(idx)
    elif which == 'dxrec': S = dxrec(idx)
    elif which == 'dxsrc':
        d = json.load(open(sys.argv[3])); S = dxsrc(idx, {int(k): v for k, v in d['data'].items()}, {int(k): v for k, v in d['fin'].items()}, {int(k): v for k, v in d['easy'].items()}, {int(k): v for k, v in d['gate'].items()})
    print(json.dumps(S.R, separators=(',', ':')))
