# 2026-10-28 (Eden): line slide, % of active players who got a new Golden (any source) per day, last 10 days, Domino 19 vs 20.
# Data: claude/domino-19v20-golden-sources-by-day-2026-10-28.md. Frame copied from dlw_slide; placed after dxgold_slide.
import json, sys
NEW, P = 'gw_slide', 'gw_'
S = {19: [27.1, 31.3, 39.4, 47.6, 34.1, 32.3, 27.6, 27.1, 27.0, 27.5], 20: [17.7, 20.3, 22.1, 21.5, 33.7, 41.6, 44.1, 34.5, 28.3, 30.5]}
COL = {19: {'red': 1, 'green': 0.043, 'blue': 0.278}, 20: {'red': 1, 'green': 0.875, 'blue': 0.522}}
GREY = {'red': 0.62, 'green': 0.62, 'blue': 0.62}
X0, XW, YB, YT, VB, VT = 1300000, 6300000, 3799840, 1841500, 10, 50
X = lambda i: X0 + i * XW / 9
Y = lambda v: YB - (v - VB) / (VT - VB) * (YB - YT)
frame = {f'SLIDES_API1265877891_{i}': f'{P}f{i}' for i in (5, 6, 7, 11, 12, 13)}
old = [f'dlw_n{i}' for i in range(1, 54)] + ['dlw_shlab', 'dlw_shade', 'dlw_xcap'] + [f'dlw_x{i}' for i in range(5)] + [f'dlw_e{a}' for a in (17, 18, 19, 20)]
mp = {'dlw_slide': NEW, **frame, **{o: P + o[4:] for o in old}}
R = [{'duplicateObject': {'objectId': 'dlw_slide', 'objectIds': mp}}]
R += [{'deleteObject': {'objectId': mp[o]}} for o in old]
def rep(a, b): R.append({'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [NEW]}})
rep('Revenue per Active Payer vs a Normal Weekday, Last 14 Days: Domino 17–20', 'Players Who Got a New Golden per Day, Any Source, Last 10 Days: Domino 19 vs 20')
rep('Standard-population payers · each day ÷ the same weekday’s average up to 8 days before close · close day left out',
    'All active players · first copy of a Golden that day from any source: events, gameplay, Kiosk or purchase')
rep('Lift in the last 4 days', 'Last 4 days: 34% vs 27% a day')
rep('+50%', '50%'); rep('+20%', '30%'); rep('−10%', '10%')
rep('Albums 18 and 20 lift at the end; 17 and 19 barely move', 'Album 20’s Golden wave came later, 4–6 days before close; album 19’s peaked a week out')
k = [0]
def line(x1, y1, x2, y2, col, w, dash=None):
    k[0] += 1; o = f'{P}n{k[0]}'
    R.append({'createLine': {'objectId': o, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': max(int(x2 - x1), 1), 'unit': 'EMU'}, 'height': {'magnitude': max(int(abs(y2 - y1)), 1), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': -1 if y2 < y1 else 1, 'translateX': int(x1), 'translateY': int(y1), 'unit': 'EMU'}}}})
    lp = {'lineFill': {'solidFill': {'color': {'rgbColor': col}}}, 'weight': {'magnitude': w, 'unit': 'PT'}}
    if dash: lp['dashStyle'] = dash
    R.append({'updateLineProperties': {'objectId': o, 'lineProperties': lp, 'fields': 'lineFill,weight' + (',dashStyle' if dash else '')}})
def shape(o, kind, x, y, w, h, col, a=1.0):
    R.append({'createShape': {'objectId': P + o, 'shapeType': kind, 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': int(w), 'unit': 'EMU'}, 'height': {'magnitude': int(h), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}}})
    R.append({'updateShapeProperties': {'objectId': P + o, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': col}, 'alpha': a}},
        'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill,outline'}})
def text(o, x, y, w, t, col, size=9, bold=False, align='CENTER'):
    R.append({'createShape': {'objectId': P + o, 'shapeType': 'TEXT_BOX', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': int(w), 'unit': 'EMU'}, 'height': {'magnitude': 230000, 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}}})
    R.append({'insertText': {'objectId': P + o, 'text': t}})
    R.append({'updateTextStyle': {'objectId': P + o, 'style': {'fontFamily': 'Oswald', 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'bold': bold,
        'foregroundColor': {'opaqueColor': {'rgbColor': col}}}, 'fields': 'fontFamily,fontSize,bold,foregroundColor'}})
    R.append({'updateParagraphStyle': {'objectId': P + o, 'style': {'alignment': align}, 'fields': 'alignment'}})
shape('shade', 'RECTANGLE', X(5.5), YT, X(9) - X(5.5) + 60000, YB - YT, COL[20], 0.10)
for a, w in ((19, 2.75), (20, 2.75)):
    for i in range(9): line(X(i), Y(S[a][i]), X(i + 1), Y(S[a][i + 1]), COL[a], w)
for a, i, lab in ((19, 3, '48% · 7 days out'), (20, 6, '44% · 4 days out')):
    shape(f'pt{a}', 'ELLIPSE', X(i) - 40000, Y(S[a][i]) - 40000, 80000, 80000, COL[a])
    text(f'pk{a}', X(i) - 600000, Y(S[a][i]) - 260000, 1200000, lab, COL[a], 9, True)
text('e20', X(9) + 60000, Y(S[20][9]) - 200000, 1000000, 'Album 20', COL[20], 9, True, 'START')
text('e19', X(9) + 60000, Y(S[19][9]) - 20000, 1000000, 'Album 19', COL[19], 9, True, 'START')
for j, d in enumerate(range(10, 0, -1)):
    text(f'x{j}', X(j) - 150000, YB + 30000, 300000, str(d), GREY, 8)
text('xcap', X(4) - 650000, YB + 190000, 1300000, 'days before close', GREY, 8)
json.dump(R, open(sys.argv[1], 'w'), separators=(',', ':'), ensure_ascii=False)
print(len(R))
