# 2026-10-28 (Eden): "New Goldens by Source, per Day, Last 10 Days: Domino 19 vs 20" in the style of slide 55 (stacked 100% bars).
# Data: query in claude/domino-19v20-golden-sources-by-day-2026-10-28.md (category mix). Frame copied from gw_slide.
import json, sys
NEW, P = 'gsrc_slide', 'gsrc_'
CATS = [('kiosk', 'GoldenKiosk (pick)', {'red': 1, 'green': 0.875, 'blue': 0.522}),
        ('coloring', 'Album ColoringBook', {'red': 1, 'green': 0.54, 'blue': 0.40}),
        ('events', 'Events, Trail and gameplay', {'red': 0.45, 'green': 0.45, 'blue': 0.45}),
        ('paid', 'Paid offers', {'red': 0.80, 'green': 0.25, 'blue': 0.10})]
D0 = {19: [(0,0,73,13,11,3),(0,0,76,12,9,3),(0,0,75,16,7,2),(0,0,88,5,6,2),(0,0,83,6,9,2),(0,0,84,4,10,2),(0,0,82,0,14,4),(0,0,54,17,24,5),(0,0,39,28,30,3),(0,0,51,11,37,2)],
     20: [(0,0,65,14,16,6),(0,0,65,18,13,4),(0,0,53,29,15,3),(18,0,55,9,15,2),(24,18,33,14,9,2),(11,36,25,18,9,2),(0,36,43,6,13,2),(0,13,65,6,13,3),(0,0,79,5,12,3),(0,0,75,12,11,2)]}
D = {a: [(r[0], r[1], r[2] + r[3] + r[4], r[5]) for r in v] for a, v in D0.items()}
WHITE = {'red': 1, 'green': 1, 'blue': 1}; GREY = {'red': 0.62, 'green': 0.62, 'blue': 0.62}; DARK = {'red': 0.13, 'green': 0.13, 'blue': 0.13}
drop = ['SLIDES_API316253210_0', 'SLIDES_API316253210_3', 'SLIDES_API316253210_4', 'gw_f5', 'gw_f6', 'gw_f7', 'gw_f11', 'gw_f12', 'gw_f13', 'gw_shade',
        'gw_pt19', 'gw_pt20', 'gw_pk19', 'gw_pk20', 'gw_e19', 'gw_e20', 'gw_xcap'] + [f'gw_n{i}' for i in range(1, 19)] + [f'gw_x{i}' for i in range(10)]
mp = {'gw_slide': NEW, **{o: P + 'd' + str(i) for i, o in enumerate(drop)}}
R = [{'duplicateObject': {'objectId': 'gw_slide', 'objectIds': mp}}]
R += [{'deleteObject': {'objectId': mp[o]}} for o in drop]
def rep(a, b): R.append({'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [NEW]}})
rep('per Day, Any Source, Last 10 Days: Domino 19 vs 20', 'by Source, per Day, Last 10 Days: Domino 19 vs 20')
rep('Players Who Got a ', 'Where ')
rep('New Golden ', 'New Goldens ')
rep('by Source, per Day', 'Came From, per Day')
rep('All active players · Golden that day from any source: events, gameplay, Kiosk or purchase', 'All players · first copy of each Golden · share of the day’s new Goldens by source')
rep('Album 20’s Golden wave came later, 4–6 days before close; album 19’s peaked a week out',
    'Album 20 added a Kiosk and a ColoringBook 7–3 days before close; in album 19 events faded in the last 3 days. Paid offers: 2–6% in both.')
def shape(o, kind, x, y, w, h, fill=None, line=None, a=1.0):
    R.append({'createShape': {'objectId': P + o, 'shapeType': kind, 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': int(w), 'unit': 'EMU'}, 'height': {'magnitude': int(h), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}}})
    sp, f = {}, []
    if fill: sp['shapeBackgroundFill'] = {'solidFill': {'color': {'rgbColor': fill}, 'alpha': a}}; f.append('shapeBackgroundFill')
    else: sp['shapeBackgroundFill'] = {'propertyState': 'NOT_RENDERED'}; f.append('shapeBackgroundFill')
    if line: sp['outline'] = {'outlineFill': {'solidFill': {'color': {'rgbColor': line}}}, 'weight': {'magnitude': 1, 'unit': 'PT'}}; f.append('outline')
    else: sp['outline'] = {'propertyState': 'NOT_RENDERED'}; f.append('outline')
    R.append({'updateShapeProperties': {'objectId': P + o, 'shapeProperties': sp, 'fields': ','.join(f)}})
def text(o, x, y, w, t, col, size=8, bold=False, align='START', h=200000):
    R.append({'createShape': {'objectId': P + o, 'shapeType': 'TEXT_BOX', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': int(w), 'unit': 'EMU'}, 'height': {'magnitude': h, 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}}})
    R.append({'insertText': {'objectId': P + o, 'text': t}})
    R.append({'updateTextStyle': {'objectId': P + o, 'style': {'fontFamily': 'Oswald', 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'bold': bold,
        'foregroundColor': {'opaqueColor': {'rgbColor': col}}}, 'fields': 'fontFamily,fontSize,bold,foregroundColor'}})
    R.append({'updateParagraphStyle': {'objectId': P + o, 'style': {'alignment': align}, 'fields': 'alignment'}})
# legend
lx = 480000
for c, lab, col in CATS:
    shape('lg_' + c, 'RECTANGLE', lx, 1080000, 90000, 90000, col)
    text('lt_' + c, lx + 110000, 1020000, 1300000, lab, GREY, 7)
    lx += 1900000
# panels
PX = {19: 450000, 20: 4700000}; PW, PY, PH = 4000000, 1300000, 3020000
BX0, BW, RY0, RH = 650000, 3150000, 1720000, 255000
for a in (19, 20):
    px = PX[a]
    shape(f'card{a}', 'ROUND_RECTANGLE', px, PY + 30000, PW, PH, None, WHITE)
    text(f'pt{a}', px + 150000, PY + 110000, 3000000, f'Domino {a} · new Goldens by source', WHITE, 10, True)
    text(f'dl{a}', px + 30000, RY0 + 15000, 420000, '\n'.join(f'd−{10 - j}' for j in range(10)), GREY, 8, h=RH * 10)
    R.append({'updateParagraphStyle': {'objectId': P + f'dl{a}', 'style': {'lineSpacing': 209, 'spaceAbove': {'magnitude': 0, 'unit': 'PT'}, 'spaceBelow': {'magnitude': 0, 'unit': 'PT'}}, 'fields': 'lineSpacing,spaceAbove,spaceBelow'}})
    for j, row in enumerate(D[a]):
        y = RY0 + j * RH
        x = px + BX0
        for (c, lab, col), v in zip(CATS, row):
            if v <= 0: continue
            w = BW * v / 100
            shape(f'b{a}_{j}_{c}', 'RECTANGLE', x, y + 25000, w, RH - 55000, col)
            if v >= 10 and c in ('kiosk', 'coloring'): text(f'v{a}_{j}_{c}', x, y + 20000, w, f'{v}%', DARK if c in ('kiosk', 'coloring', 'trail', 'events') else WHITE, 7, True, 'CENTER')
            x += w
json.dump(R, open(sys.argv[1], 'w'), separators=(',', ':'), ensure_ascii=False)
print(len(R))
