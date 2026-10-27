"""ehline_slide: line chart in the style of "% of the album's Rares Collected, by % of Album Time" (cross-game slide), for Domino Easy vs Hard, album 20.
Source: claude/domino-easy-hard-splits-2026-10-26.md §1b | SQL: claude/domino_royals_by_time_easy_hard_2026-10-27.sql
Usage: python3 claude/slide_domino_royals_line_2026-10-27.py <insertion_index>"""
import json, sys, importlib.util
spec = importlib.util.spec_from_file_location('ch', __file__.replace('slide_domino_royals_line_2026-10-27.py', 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
E, rgb = ch.E, ch.rgb
EASY, HARD, GOLD, WHITE, GREY, DGREY = ch.ORANGE, '#6c9eff', ch.GOLD, ch.WHITE, ch.GREY, ch.DGREY
# album 20, average paying player, % of the album's 9 Royals held at 0..100% of album time
D = {'Easy': [0, 3.6, 7.4, 11.5, 13.7, 26.3, 33.5, 42.5, 51.4, 57.0, 65.6],
     'Hard': [0, 4.6, 11.6, 20.1, 23.3, 37.9, 47.1, 56.2, 64.8, 69.7, 81.0]}
X0, X1, YB, YT, VMAX = 0.75, 5.5, 4.0, 1.35, 90.0
def px(t): return X0 + (X1 - X0) * t / 100
def py(v): return YB - (YB - YT) * v / VMAX

def line(S, x1, y1, x2, y2, color, w=2.0, dash=None):
    o = S.oid('l'); dx, dy = x2 - x1, y2 - y1
    up = dy < 0
    tr = {'scaleX': 1, 'scaleY': -1 if up else 1, 'translateX': int(x1 * E), 'translateY': int(y1 * E), 'unit': 'EMU'}
    S.R.append({'createLine': {'objectId': o, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': S.s,
        'size': ch.size(max(dx, 0.001), max(abs(dy), 0.001)), 'transform': tr}}})
    lp = {'lineFill': {'solidFill': {'color': {'rgbColor': rgb(color)}}}, 'weight': {'magnitude': w, 'unit': 'PT'}}
    f = 'lineFill,weight'
    if dash: lp['dashStyle'] = dash; f += ',dashStyle'
    S.R.append({'updateLineProperties': {'objectId': o, 'lineProperties': lp, 'fields': f}})

def dot(S, x, y, r, color):
    o = S.oid('d')
    S.R.append({'createShape': {'objectId': o, 'shapeType': 'ELLIPSE', 'elementProperties': {'pageObjectId': S.s, 'size': ch.size(2 * r, 2 * r), 'transform': ch.tf(x - r, y - r)}}})
    S.R.append({'updateShapeProperties': {'objectId': o, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': rgb(color)}}}, 'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill,outline'}})

def build(idx):
    S = ch.Slide('ehline_slide', idx)
    S.text(0.5, 0.25, 9.0, 0.55, "% of the Album's Royals Collected, by % of Album Time: Domino Easy vs Hard", 22, WHITE,
           spans=[("Album's Royals Collected", GOLD), ('Album Time', GOLD)])
    S.text(0.5, 0.78, 9.0, 0.3, 'Average paying player · album 20 · standard-population payers', 10, GREY)
    S.rect(px(90), YT - 0.15, px(100) - px(90), YB - YT + 0.15, '#2e2b26', tag='sh')
    for v in (0, 20, 40, 60, 80):
        line(S, X0, py(v), X1, py(v), '#333333', 0.75)
        S.text(0.2, py(v) - 0.11, 0.5, 0.22, f'{v}%', 8, DGREY, align='END')
    for t, lab in ((0, 'Start'), (25, '25%'), (50, '50%'), (75, '75%'), (100, 'Close')):
        S.text(px(t) - 0.35, YB + 0.05, 0.7, 0.22, lab, 8, DGREY, align='CENTER')
    for seg, col in (('Easy', EASY), ('Hard', HARD)):
        v = D[seg]
        for i in range(10):
            line(S, px(i * 10), py(v[i]), px(i * 10 + 10), py(v[i + 1]), col, 2.25)
        dot(S, px(100), py(v[10]), 0.07, col)
        S.text(px(100) + 0.1, py(v[10]) - 0.12, 1.0, 0.25, f'{seg} {round(v[10])}%', 10, col)
    # right panels
    PX, PW = 6.85, 2.75
    S.panel(PX, 1.3, PW, 0.85)
    S.text(PX + 0.15, 1.36, PW - 0.3, 0.3, 'Gap at 90% of album time', 12, WHITE)
    S.text(PX + 0.15, 1.7, PW - 0.3, 0.3, '18 · 15 · 13 pts  (albums 17 · 19 · 20)', 10, GOLD)
    S.panel(PX, 2.3, PW, 0.85)
    S.text(PX + 0.15, 2.36, PW - 0.3, 0.3, 'Added in the last 10%', 12, WHITE)
    S.text(PX + 0.15, 2.7, PW - 0.3, 0.3, 'Easy +4 · +5 · +9  |  Hard +4 · +8 · +11', 10, WHITE,
           spans=[('Easy +4 · +5 · +9', EASY), ('Hard +4 · +8 · +11', HARD)])
    S.panel(PX, 3.3, PW, 0.85)
    S.text(PX + 0.15, 3.36, PW - 0.3, 0.3, 'Who they are (album 20)', 12, WHITE)
    S.text(PX + 0.15, 3.7, PW - 0.3, 0.3, 'Easy 92% of payers · 55% of revenue\nHard 8% · 45%', 9, WHITE,
           spans=[('Easy', EASY), ('Hard', HARD)])
    S.text(0.5, 4.55, 9.0, 0.5, 'Hard players pull ahead from the first weeks and stay ahead; the last 10% adds more for Hard (+11 vs +9 pts in album 20).', 11, WHITE,
           spans=[('pull ahead from the first weeks', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

if __name__ == '__main__':
    S = build(int(sys.argv[1]))
    def rnd(o):
        if isinstance(o, float): return round(o, 3)
        if isinstance(o, dict): return {k: rnd(v) for k, v in o.items()}
        if isinstance(o, list): return [rnd(v) for v in o]
        return o
    print(json.dumps(rnd(S.R), separators=(',', ':'), ensure_ascii=False))
