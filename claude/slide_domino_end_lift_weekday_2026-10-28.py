# 2026-10-28 (Eden): Domino 17-20 end lift vs a normal weekday (ARPDAU index), our design. New slide dlw_slide, copy of m19_slide frame,
# placed after Eden's slide "daily rev vs normal weekday". Data: claude/domino_end_arpdau_weekday_17_20_2026-10-28.sql.
import json, sys
NEW, P, SRC = 'dlw_slide', 'dlw_', 'm19_slide'
S = {17: [1.016,1.078,1.072,1.154,1.106,0.956,1.030,1.034,0.998,0.940,1.094,0.985,1.036,1.031],
     18: [1.011,0.962,0.962,1.007,1.093,1.080,1.015,1.062,1.097,1.422,1.251,1.210,1.098,1.242],
     19: [1.033,0.987,1.054,1.059,1.034,1.034,1.050,0.998,0.914,0.990,1.023,1.045,1.035,1.074],
     20: [0.991,1.010,1.144,1.184,1.106,1.153,1.138,1.031,0.995,0.994,1.079,1.080,1.125,1.138]}
GOLD = {'red': 1, 'green': 0.875, 'blue': 0.522}; GOLDL = {'red': 0.80, 'green': 0.70, 'blue': 0.45}
RED = {'red': 1, 'green': 0.043, 'blue': 0.278}; REDL = {'red': 0.75, 'green': 0.38, 'blue': 0.45}
STY = {20: (GOLD, 2.75), 18: (GOLDL, 1.75), 19: (RED, 2.75), 17: (REDL, 1.75)}
X0, XW, YB, YT, VB, VT = 1300000, 6300000, 3799840, 1841500, 0.90, 1.50
X = lambda i: X0 + i * XW / 13
Y = lambda v: YB - (v - VB) / (VT - VB) * (YB - YT)
mp = {SRC: NEW, **{f'm19_{k}': P + k for k in ['SLIDES_API976784972_144', 'SLIDES_API976784972_151', 'a144_2022', 'a144_2007', 'a144_2008',
      'SLIDES_API976784972_152', 'SLIDES_API976784972_153', 'SLIDES_API976784972_154', 'SLIDES_API976784972_155', 'a144_2029',
      'a144_dom_grid0', 'a144_dom_grid1', 'a144_dom_grid2', 'l19', 'l20', 'dx'] + [f'L{i}' for i in range(1, 31)]}}
R = [{'duplicateObject': {'objectId': SRC, 'objectIds': mp}}, {'updateSlidesPosition': {'slideObjectIds': [NEW], 'insertionIndex': int(sys.argv[1])}}]
R += [{'deleteObject': {'objectId': P + k}} for k in ['l19', 'l20', 'dx', 'SLIDES_API976784972_155'] + [f'L{i}' for i in range(1, 31)]]
def tr(o, sx, sy, x, y, mode='ABSOLUTE'):
    R.append({'updatePageElementTransform': {'objectId': P + o, 'applyMode': mode, 'transform': {'scaleX': sx, 'scaleY': sy, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}})
tr('SLIDES_API976784972_144', 2.75, 0.8988, 600000, 1412075)                  # card
tr('SLIDES_API976784972_151', 73.6023, 46.2753, 712000, 1495425)              # logo
tr('a144_2022', 0.9, 0.0553, 5600000, 1552575)                                # top-right label
for k, y in (('a144_dom_grid0', YT), ('a144_dom_grid1', (YT + YB) / 2), ('a144_dom_grid2', YB)):
    tr(k, XW / 3000000, 1, X0, y)
for k, y in (('SLIDES_API976784972_154', YT), ('SLIDES_API976784972_153', (YT + YB) / 2), ('SLIDES_API976784972_152', YB)):
    tr(k, 0.0953, 0.0508, X0 - 330000, y - 70000)
tr('a144_2029', 2.6, 0.0775, 650000, 4300000)
k = [0]
def line(x1, y1, x2, y2, col, w, dash=None):
    k[0] += 1; o = f'{P}n{k[0]}'
    R.append({'createLine': {'objectId': o, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': max(int(x2 - x1), 1), 'unit': 'EMU'}, 'height': {'magnitude': max(int(abs(y2 - y1)), 1), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': -1 if y2 < y1 else 1, 'translateX': int(x1), 'translateY': int(y1), 'unit': 'EMU'}}}})
    lp = {'lineFill': {'solidFill': {'color': {'rgbColor': col}}}, 'weight': {'magnitude': w, 'unit': 'PT'}}
    if dash: lp['dashStyle'] = dash
    R.append({'updateLineProperties': {'objectId': o, 'lineProperties': lp, 'fields': 'lineFill,weight' + (',dashStyle' if dash else '')}})
def rect(o, x, y, w, h, col, a):
    R.append({'createShape': {'objectId': P + o, 'shapeType': 'RECTANGLE', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': int(w), 'unit': 'EMU'}, 'height': {'magnitude': int(h), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}}})
    R.append({'updateShapeProperties': {'objectId': P + o, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': col}, 'alpha': a}},
        'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill,outline'}})
def text(o, x, y, w, t, col, size=9, bold=False, align='START'):
    R.append({'createShape': {'objectId': P + o, 'shapeType': 'TEXT_BOX', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': int(w), 'unit': 'EMU'}, 'height': {'magnitude': 220000, 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}}})
    R.append({'insertText': {'objectId': P + o, 'text': t}})
    R.append({'updateTextStyle': {'objectId': P + o, 'style': {'fontFamily': 'Oswald', 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'bold': bold,
        'foregroundColor': {'opaqueColor': {'rgbColor': col}}}, 'fields': 'fontFamily,fontSize,bold,foregroundColor'}})
    R.append({'updateParagraphStyle': {'objectId': P + o, 'style': {'alignment': align}, 'fields': 'alignment'}})
GREY = {'red': 0.62, 'green': 0.62, 'blue': 0.62}
rect('shade', X(9.5), YT, X(13) - X(9.5) + 60000, YB - YT, GOLD, 0.10)
line(X0, Y(1.0), X0 + XW, Y(1.0), GREY, 1, 'DASH')
text('norm', X0 + 20000, Y(1.0) + 10000, 1300000, 'normal weekday', GREY, 8)
for i, d in enumerate([14, 10, 7, 4, 1]):
    j = 14 - d
    text(f'x{i}', X(j) - 150000, YB + 30000, 300000, str(d), GREY, 8, align='CENTER')
text('xcap', X(13) - 1150000, YB + 200000, 1300000, 'days before close', GREY, 8, align='END')
for a in (17, 19, 18, 20):
    col, w = STY[a]; v = S[a]
    for i in range(13): line(X(i), Y(v[i]), X(i + 1), Y(v[i + 1]), col, w)
lift = {a: round(100 * (sum(S[a][10:]) / 4 - 1)) for a in S}
off = {20: -60000, 18: -60000, 19: 40000, 17: 120000}
ends = sorted(S, key=lambda a: -S[a][13]); yprev = None
for a in ends:
    col, w = STY[a]; y = Y(S[a][13]) - 100000
    if yprev is not None and y < yprev + 170000: y = yprev + 170000
    yprev = y
    text(f'e{a}', X(13) + 60000, y, 1100000, f'Album {a}: +{lift[a]}%', col, 9, bold=a in (19, 20))
text('shlab', X(9.5) + 20000, YT + 20000, 1500000, 'Last 4 days', GOLD, 8, True)
def rep(a, b): R.append({'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [NEW]}})
rep('Stickers Still Missing, Album 19 vs Album 20 (Day 20 to Close)', 'Revenue per Active Payer vs a Normal Weekday, Last 14 Days: Domino 17–20')
rep('Median paying player (paid on any album day), all players', 'Standard-population payers · each day ÷ the same weekday’s average up to 8 days before close · close day left out')
rep('Stickers missing of 144', 'Lift in the last 4 days')
rep('60', '+50%'); rep('30', '+20%')
R.append({'deleteText': {'objectId': P + 'SLIDES_API976784972_152', 'textRange': {'type': 'ALL'}}})
R.append({'insertText': {'objectId': P + 'SLIDES_API976784972_152', 'text': '−10%'}})
rep('Album 19 slowed after day 33 (day 38: 16 missing vs 10)', 'Albums 18 and 20 lift at the end; 17 and 19 barely move')
json.dump(R, open(sys.argv[2], 'w'), separators=(',', ':'), ensure_ascii=False)
print(len(R), lift)
