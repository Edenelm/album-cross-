"""Build requests for ALBUM END slide t5d_slide: revenue within 3 stickers at close-4 and end lift, previous vs latest album.
# Built 2026-10-24 in three update_presentation calls (the deck revision kept changing, so the last ones went without the revision lock, Eden approved); speaker notes added separately.
Source: claude/topic5-end-lift-2026-10-24.md. Prints the update_presentation requests as JSON."""
import json, sys
E = 914400
S = 't5d_slide'
def rgb(h): h = h.lstrip('#'); return {'red': round(int(h[0:2], 16)/255, 3), 'green': round(int(h[2:4], 16)/255, 3), 'blue': round(int(h[4:6], 16)/255, 3)}
WHITE, GREY, MUTED, GOLD, RED = '#F5F5F5', '#BDBDBD', '#9E9E9E', '#FFDF85', '#FF0B47'
GAME = {'Dice': '#6C9EFF', 'Domino': '#F5A04A', 'Disney': '#3CC8A8'}
PREV = '#5A5A5A'
R = [{'createSlide': {'objectId': S, 'insertionIndex': int(sys.argv[1]), 'slideLayoutReference': {'predefinedLayout': 'BLANK'}}},
     {'updatePageProperties': {'objectId': S, 'pageProperties': {'pageBackgroundFill': {'solidFill': {'color': {'rgbColor': rgb('#212121')}}}}, 'fields': 'pageBackgroundFill'}}]
def box(oid, x, y, w, h, kind='TEXT_BOX', fill=None):
    R.append({'createShape': {'objectId': oid, 'shapeType': kind, 'elementProperties': {'pageObjectId': S,
        'size': {'width': {'magnitude': int(w*E), 'unit': 'EMU'}, 'height': {'magnitude': int(h*E), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x*E), 'translateY': int(y*E), 'unit': 'EMU'}}}})
    if fill:
        R.append({'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': rgb(fill)}}},
            'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill.solidFill.color,outline.propertyState'}})
def text(oid, x, y, w, h, runs, size, align='START', bold=False):
    box(oid, x, y, w, h)
    if isinstance(runs, str): runs = [(runs, WHITE)]
    full = ''.join(t for t, _ in runs)
    R.append({'insertText': {'objectId': oid, 'text': full}})
    R.append({'updateTextStyle': {'objectId': oid, 'textRange': {'type': 'ALL'}, 'style': {'fontFamily': 'Oswald', 'bold': bold,
        'fontSize': {'magnitude': size, 'unit': 'PT'}, 'foregroundColor': {'opaqueColor': {'rgbColor': rgb(runs[0][1])}}},
        'fields': 'fontFamily,bold,fontSize,foregroundColor'}})
    i = len(runs[0][0])
    for t, c in runs[1:]:
        R.append({'updateTextStyle': {'objectId': oid, 'textRange': {'type': 'FIXED_RANGE', 'startIndex': i, 'endIndex': i+len(t)},
            'style': {'foregroundColor': {'opaqueColor': {'rgbColor': rgb(c)}}}, 'fields': 'foregroundColor'}})
        i += len(t)
    if align != 'START':
        R.append({'updateParagraphStyle': {'objectId': oid, 'textRange': {'type': 'ALL'}, 'style': {'alignment': align}, 'fields': 'alignment'}})

text(S+'_ti', 0.61, 0.33, 8.8, 0.45, 'Revenue Within 3 Stickers 4 Days Before Close and End Lift, by Album', 20)
text(S+'_su', 0.61, 0.76, 8.8, 0.25, [("% of payers' revenue (up to close−4) from payers at ≤3 missing on close−4 · end lift = ARPDAU of the last 4 days vs the whole album · paying players", GREY)], 9.5)
BASE, SCALE = 3.95, 3.6   # baseline (in), inches per 100%
box(S+'_base', 0.9, BASE, 8.3, 0.01, 'RECTANGLE', '#666666')
data = [('Dice', '61', 39, 9, '63', 54, 16, 2.0), ('Domino', '19', 31, 13, '20', 55, 17, 5.05), ('Disney', '14', 44, -5, '15', 43, 1, 8.1)]
for g, a0, r0, l0, a1, r1, l1, cx in data:
    gk = g.lower()
    for j, (alb, rev, lift, col) in enumerate([(a0, r0, l0, PREV), (a1, r1, l1, GAME[g])]):
        x = cx - 0.75 + j*0.85
        h = rev/100*SCALE
        box(f'{S}_{gk}{j}_bar', x, BASE-h, 0.65, h, 'RECTANGLE', col)
        text(f'{S}_{gk}{j}_v', x-0.1, BASE-h-0.3, 0.85, 0.28, f'{rev}%', 11, 'CENTER', True)
        text(f'{S}_{gk}{j}_a', x-0.15, BASE+0.05, 0.95, 0.22, f'{g} {alb}', 10, 'CENTER')
        bad = (g == 'Disney') or j == 0
        text(f'{S}_{gk}{j}_l', x-0.15, BASE+0.27, 0.95, 0.24, [(f'end {lift:+d}%'.replace('-', '\u2212'), RED if bad else GOLD)], 10, 'CENTER', True)
text(S+'_ms', 0.61, 4.6, 6.6, 0.55, [('More revenue close at close−4, stronger end: Dice +9% → +16%, Domino +13% → +17%. ', WHITE),
    ('Disney stayed flat (−5% → +1%).', RED), (' Dice 61 and Domino 19 had the gap too.', WHITE)], 11)
text(S+'_ft', 7.78, 5.25, 1.72, 0.2, [('SuperPlay 2026', MUTED)], 8)
print(json.dumps(R, ensure_ascii=False, separators=(',', ':')))
