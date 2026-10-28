# 2026-10-28 (Eden): "two waves" slide: new set stickers per active payer per day, days 20..1 before close, Domino 19 vs 20.
# Data: claude/domino-sources-d20-d11-19v20-2026-10-28.md (+ same query for d-10..-1). Frame copied from gw_slide; placed after gsrc_slide.
import json, sys
NEW, P = 'wv_slide', 'wv_'
S = {19: [1.96,1.86,2.11,1.64,1.21,1.37,1.49,1.09,0.92,1.09,1.07,1.18,1.34,1.31,0.90,0.64,0.51,0.66,0.70,0.69],
     20: [1.71,1.97,1.99,1.96,1.41,2.47,2.40,2.54,1.86,1.12,0.65,0.70,0.69,0.51,0.86,1.19,1.38,1.06,0.72,0.65]}
COL = {19: {'red': 1, 'green': 0.043, 'blue': 0.278}, 20: {'red': 1, 'green': 0.875, 'blue': 0.522}}
GOLD = COL[20]; GREY = {'red': 0.62, 'green': 0.62, 'blue': 0.62}
X0, XW, YB, YT, VB, VT = 1300000, 6300000, 3799840, 1841500, 0, 3
X = lambda i: X0 + i * XW / 19
Y = lambda v: YB - (v - VB) / (VT - VB) * (YB - YT)
drop = ['SLIDES_API316253210_0', 'SLIDES_API316253210_4', 'gw_shade', 'gw_pt19', 'gw_pt20', 'gw_pk19', 'gw_pk20', 'gw_e19', 'gw_e20', 'gw_xcap'] + \
       [f'gw_n{i}' for i in range(1, 19)] + [f'gw_x{i}' for i in range(10)]
keep = {'gw_f5': P + 'y0', 'gw_f6': P + 'y1', 'gw_f7': P + 'y2', 'gw_f11': P + 'g0', 'gw_f12': P + 'g1', 'gw_f13': P + 'g2', 'SLIDES_API316253210_3': P + 'logo'}
mp = {'gw_slide': NEW, **keep, **{o: P + 'd' + str(i) for i, o in enumerate(drop)}}
R = [{'duplicateObject': {'objectId': 'gw_slide', 'objectIds': mp}}]
R += [{'deleteObject': {'objectId': mp[o]}} for o in drop]
def rep(a, b): R.append({'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [NEW]}})
rep('Players Who Got a ', 'New Stickers per Active Payer per Day, Last 20 Days: Domino 19 vs 20')
rep('New Golden ', ''); rep('per Day, Any Source, Last 10 Days: Domino 19 vs 20', '')
rep('All active players · Golden that day from any source: events, gameplay, Kiosk or purchase', 'Standard-population payers · first copy of each set sticker, from any source')
rep('50%', '3'); rep('30%', '1.5'); rep('10%', '0')
rep('Album 20’s Golden wave came later, 4–6 days before close; album 19’s peaked a week out',
    'Album 20 gave two free waves: two weeks before close (+5 stickers per payer) and in the last week (+2)')
k = [0]
def line(x1, y1, x2, y2, col, w):
    k[0] += 1; o = f'{P}n{k[0]}'
    R.append({'createLine': {'objectId': o, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': max(int(x2 - x1), 1), 'unit': 'EMU'}, 'height': {'magnitude': max(int(abs(y2 - y1)), 1), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': -1 if y2 < y1 else 1, 'translateX': int(x1), 'translateY': int(y1), 'unit': 'EMU'}}}})
    R.append({'updateLineProperties': {'objectId': o, 'lineProperties': {'lineFill': {'solidFill': {'color': {'rgbColor': col}}}, 'weight': {'magnitude': w, 'unit': 'PT'}}, 'fields': 'lineFill,weight'}})
def shade(o, i0, i1):
    x = X(i0) - XW / 38; w = X(i1) - X(i0) + XW / 19
    R.append({'createShape': {'objectId': P + o, 'shapeType': 'RECTANGLE', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': int(w), 'unit': 'EMU'}, 'height': {'magnitude': YB - YT, 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x), 'translateY': YT, 'unit': 'EMU'}}}})
    R.append({'updateShapeProperties': {'objectId': P + o, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': GOLD}, 'alpha': 0.12}},
        'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill,outline'}})
def text(o, x, y, w, t, col, size=9, bold=False, align='CENTER'):
    R.append({'createShape': {'objectId': P + o, 'shapeType': 'TEXT_BOX', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': int(w), 'unit': 'EMU'}, 'height': {'magnitude': 230000, 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}}})
    R.append({'insertText': {'objectId': P + o, 'text': t}})
    R.append({'updateTextStyle': {'objectId': P + o, 'style': {'fontFamily': 'Oswald', 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'bold': bold,
        'foregroundColor': {'opaqueColor': {'rgbColor': col}}}, 'fields': 'fontFamily,fontSize,bold,foregroundColor'}})
    R.append({'updateParagraphStyle': {'objectId': P + o, 'style': {'alignment': align}, 'fields': 'alignment'}})
shade('w1', 5, 8); shade('w2', 14, 16)            # d-15..-12 and d-6..-4
for a in (19, 20):
    for i in range(19): line(X(i), Y(S[a][i]), X(i + 1), Y(S[a][i + 1]), COL[a], 2.75)
text('w1t', X(6.5) - 700000, YT + 30000, 1400000, 'Wave 1 · +5 a payer', GOLD, 10, True)
text('w1s', X(6.5) - 800000, YT + 230000, 1600000, 'ColoringBook, Trail, events', GOLD, 8)
text('w2t', X(15) - 700000, YT + 30000, 1400000, 'Wave 2 · +2 a payer', GOLD, 10, True)
text('w2s', X(15) - 800000, YT + 230000, 1600000, 'Kiosk, ColoringBook, Jokers', GOLD, 8)
text('e20', X(19) + 60000, Y(S[20][19]) - 230000, 900000, 'Album 20', GOLD, 9, True, 'START')
text('e19', X(19) + 60000, Y(S[19][19]) + 0, 900000, 'Album 19', COL[19], 9, True, 'START')
for j, d in enumerate((20, 15, 10, 5, 1)):
    text(f'x{j}', X(20 - d) - 150000, YB + 30000, 300000, str(d), GREY, 8)
text('xcap', X(9.5) - 650000, YB + 190000, 1300000, 'days before close', GREY, 8)
json.dump(R, open(sys.argv[1], 'w'), separators=(',', ':'), ensure_ascii=False)
print(len(R))
