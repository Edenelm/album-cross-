"""Two visual Domino 19 vs 20 slides (Eden 2026-10-27): one chart each, album 19 grey vs album 20 gold, message carried by the picture.
 gold: dxgold_slide  - % of missing Goldens filled per day, last 10 days (source: domino-end-rares-jokers-19v20 addendum, domino_golden_fill_rate_19v20_2026-10-27.sql)
 joker: dxjk_slide v2 - % of payers who got a Joker sticker from gameplay per day, last 7 days, with 'days left after the peak' (domino_end_rares_jokers_19v20_2026-10-27.sql)
Usage: python3 slide_domino_end_wave_2026-10-27.py gold <idx> | joker <old_ids_json> -> JSON requests."""
import json, sys, os, importlib.util
spec = importlib.util.spec_from_file_location('ch', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
E, WHITE, GOLD, GREY, DGREY, OUTL, MID = ch.E, ch.WHITE, ch.GOLD, ch.GREY, ch.DGREY, ch.OUTL, ch.MID
SHADE = '#2f2c22'

class Upd(ch.Slide):
    def __init__(self, sid, old):
        self.s, self.n, self.R = sid, 0, [{'deleteObject': {'objectId': o}} for o in old]
    def oid(self, tag):
        self.n += 1; return f'{self.s}_v2{tag}{self.n}'

def line(S, x1, y1, x2, y2, col, w):
    o = S.oid('l'); up = y2 < y1
    S.R.append({'createLine': {'objectId': o, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': S.s,
        'size': {'width': {'magnitude': max(int((x2 - x1) * E), 1), 'unit': 'EMU'}, 'height': {'magnitude': max(int(abs(y2 - y1) * E), 1), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': -1 if up else 1, 'shearX': 0, 'shearY': 0, 'translateX': int(x1 * E), 'translateY': int(min(y1, y2) * E) if not up else int(y1 * E), 'unit': 'EMU'}}}})
    S.R.append({'updateLineProperties': {'objectId': o, 'lineProperties': {'lineFill': {'solidFill': {'color': {'rgbColor': ch.rgb(col)}}},
        'weight': {'magnitude': w, 'unit': 'PT'}}, 'fields': 'lineFill,weight'}})

def dot(S, x, y, col, r=0.06):
    o = S.oid('d')
    S.R.append({'createShape': {'objectId': o, 'shapeType': 'ELLIPSE', 'elementProperties': {'pageObjectId': S.s, 'size': ch.size(2 * r, 2 * r), 'transform': ch.tf(x - r, y - r)}}})
    S.R.append({'updateShapeProperties': {'objectId': o, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': ch.rgb(col)}}}, 'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill,outline'}})

def chart(S, days, series, vmax, ticks, px, py, pw, ph, shade=None):
    """series = [(values, colour, width)]; shade = (i_from, i_to) index range to shade."""
    n = len(days); X = lambda i: px + i * pw / (n - 1); Y = lambda v: py + ph - ph * v / vmax
    if shade:
        S.rect(X(shade[0]) - 0.15, py - 0.05, X(shade[1]) - X(shade[0]) + 0.3, ph + 0.05, SHADE)
    for v in ticks:
        line(S, px, Y(v), px + pw, Y(v), OUTL, 0.5)
        S.text(px - 0.55, Y(v) - 0.11, 0.45, 0.22, f'{v}%', 9, DGREY, align='END')
    for vals, col, w in series:
        for i in range(n - 1): line(S, X(i), Y(vals[i]), X(i + 1), Y(vals[i + 1]), col, w)
    for i, d in enumerate(days): S.text(X(i) - 0.2, py + ph + 0.05, 0.4, 0.2, str(d), 9, GREY, align='CENTER')
    S.text(px, py + ph + 0.25, pw, 0.2, 'days before close', 9, DGREY, align='CENTER')
    return X, Y

def gold(idx):
    S = ch.Slide('dxgold_slide', idx)
    days = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    a19 = [5.9, 8.2, 11.8, 12.7, 8.2, 7.1, 6.4, 8.9, 9.6, 9.7]
    a20 = [3.0, 3.5, 3.6, 3.2, 8.2, 15.8, 20.6, 16.9, 13.0, 13.5]
    S.text(0.5, 0.12, 9.0, 0.5, '% of Missing Goldens Collected per Day, Last 10 Days: Domino 19 vs 20', 20, WHITE, spans=[('Domino 19 vs 20', GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, 'Standard-population payers active that day (album 19: 119,201 payers, album 20: 106,762) · of the Goldens each payer still missed, % collected that day', 10, GREY)
    X, Y = chart(S, days, [(a19, MID, 2.5), (a20, GOLD, 3.5)], 24, (0, 12, 24), 1.1, 1.3, 5.2, 2.75, shade=(5, 9))
    S.text(X(5) - 0.1, 1.08, X(9) - X(5) + 0.4, 0.22, 'last 5 days', 9, GOLD, align='CENTER')
    S.text(X(9) + 0.12, Y(13.5) - 0.12, 0.8, 0.25, 'album 20', 10, GOLD, bold=True)
    S.text(X(9) + 0.12, Y(9.7) - 0.05, 0.8, 0.25, 'album 19', 10, GREY, bold=True)
    # right: what is left at close-1
    S.panel(7.15, 1.1, 2.35, 3.45)
    S.text(7.3, 1.2, 2.1, 0.5, 'Goldens still missing\nthe day before close', 11, WHITE, bold=True)
    S.text(7.3, 1.85, 2.1, 0.6, '4.3', 34, MID, bold=True)
    S.text(7.3, 2.5, 2.1, 0.25, 'album 19', 10, GREY)
    S.text(7.3, 2.95, 2.1, 0.6, '2.6', 34, GOLD, bold=True)
    S.text(7.3, 3.6, 2.1, 0.25, 'album 20', 10, GOLD)
    S.text(0.5, 4.72, 8.6, 0.5, 'In the last 5 days album 20 filled twice the share of missing Goldens a day (13–21% vs 6–10%), so payers reached the end with fewer Goldens missing.',
           11, WHITE, spans=[('twice the share of missing Goldens a day', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

def joker(old):
    S = Upd('dxjk_slide', old)
    days = [7, 6, 5, 4, 3, 2, 1]
    a19 = [3.6, 2.2, 1.5, 1.5, 3.7, 7.3, 11.6]
    a20 = [1.4, 1.3, 2.4, 5.8, 11.3, 6.9, 4.0]
    S.text(0.5, 0.12, 9.0, 0.5, '% of Payers Who Got a Joker from Gameplay per Day: Domino 19 vs 20', 20, WHITE, spans=[('Domino 19 vs 20', GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, 'Standard-population payers (album 19: 119,201, album 20: 106,762) · new sticker through a Joker from gameplay (events, puzzles, Market) · bought Jokers: 0–1% a day in both', 10, GREY)
    X, Y = chart(S, days, [(a19, MID, 2.5), (a20, GOLD, 3.5)], 12, (0, 6, 12), 1.1, 1.45, 7.4, 2.6)
    dot(S, X(4), Y(11.3), GOLD, 0.08); dot(S, X(6), Y(11.6), MID, 0.08)
    S.text(X(4) - 1.0, Y(11.3) - 0.42, 2.0, 0.3, 'album 20 peak · 3 days left', 11, GOLD, bold=True, align='CENTER')
    S.text(X(6) - 2.3, Y(11.6) - 0.42, 2.5, 0.3, 'album 19 peak · 1 day left', 11, GREY, bold=True, align='END')
    S.text(0.5, 4.72, 8.6, 0.5, 'Album 20 gave the Jokers 2 days earlier: players had 3 days left to use them and buy the rest; in album 19 only 1.',
           11, WHITE, spans=[('2 days earlier', GOLD), ('3 days left', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

if __name__ == '__main__':
    S = gold(int(sys.argv[2])) if sys.argv[1] == 'gold' else joker(json.loads(sys.argv[2]))
    print(json.dumps(S.R, ensure_ascii=False, separators=(',', ':')))
