"""Part 1 deck: new recommendation slide after p24fix (Eden 2026-10-24) — Disney Joker from 7 days out, sale vs event reward.
Evidence: claude/closing-week-pct-payers-2026-10-24.md, claude/domino-movie-twister-purchases-2026-10-24.md."""
import json
E = 914400
S = 'p24rec'
W = {'red': 0.961, 'green': 0.961, 'blue': 0.941}; L = {'red': 0.784, 'green': 0.784, 'blue': 0.753}; G = {'red': 0.62, 'green': 0.62, 'blue': 0.62}
GOLD = {'red': 1, 'green': 0.875, 'blue': 0.522}; RED = {'red': 1, 'green': 0.043, 'blue': 0.278}
CARD = {'red': 0.169, 'green': 0.169, 'blue': 0.169}; EDGE = {'red': 0.267, 'green': 0.267, 'blue': 0.267}
DIS = {'red': 0.235, 'green': 0.784, 'blue': 0.706}; DOM = {'red': 0.961, 'green': 0.627, 'blue': 0.29}

def box(oid, x, y, w, h, kind='TEXT_BOX'):
    return [{'createShape': {'objectId': oid, 'shapeType': kind, 'elementProperties': {'pageObjectId': S,
        'size': {'width': {'magnitude': int(w * E), 'unit': 'EMU'}, 'height': {'magnitude': int(h * E), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x * E), 'translateY': int(y * E), 'unit': 'EMU'}}}}]
def tb(oid, x, y, w, h, t, size, c, bold=False, align=None):
    R = box(oid, x, y, w, h) + [{'insertText': {'objectId': oid, 'text': t}},
        {'updateTextStyle': {'objectId': oid, 'textRange': {'type': 'ALL'}, 'style': {'fontFamily': 'Oswald', 'bold': bold, 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'foregroundColor': {'opaqueColor': {'rgbColor': c}}}, 'fields': 'fontFamily,bold,fontSize,foregroundColor'}}]
    if align: R += [{'updateParagraphStyle': {'objectId': oid, 'textRange': {'type': 'ALL'}, 'style': {'alignment': align}, 'fields': 'alignment'}}]
    return R
def card(oid, x, y, w, h, edge=EDGE):
    return box(oid, x, y, w, h, 'ROUND_RECTANGLE') + [{'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': CARD}}},
        'outline': {'outlineFill': {'solidFill': {'color': {'rgbColor': edge}}}, 'weight': {'magnitude': 1, 'unit': 'PT'}}}, 'fields': 'shapeBackgroundFill.solidFill.color,outline.outlineFill.solidFill.color,outline.weight'}}]

def build(idx):
    R = [{'createSlide': {'objectId': S, 'insertionIndex': idx, 'slideLayoutReference': {'predefinedLayout': 'BLANK'}}},
         {'updatePageProperties': {'objectId': S, 'pageProperties': {'pageBackgroundFill': {'solidFill': {'color': {'rgbColor': {'red': 0.129, 'green': 0.129, 'blue': 0.129}}}}}, 'fields': 'pageBackgroundFill'}}]
    R += tb(f'{S}_ti', 0.89, 0.76, 11.6, 0.6, 'Test: Disney Joker Earlier, Sold vs Won in an Event', 30, W)
    R += tb(f'{S}_su', 0.89, 1.36, 11.6, 0.35, 'Disney payers, random split at album start · Control = today', 14, L)
    cards = [('c', 0.89, 'Control', G, 'TODAY', 'Joker sold only in the last 3 days', '0.1%', 'of payers a day get a Joker before that', RED),
             ('a', 4.72, 'Test A · Sale', GOLD, 'TEST 1', 'Joker offer from 7 days before close', '7 days', 'on sale, instead of 3', GOLD),
             ('b', 8.55, 'Test B · Event', GOLD, 'NEW', 'Joker as an event prize, 4–3 days before close', 'Event', 'like Domino 20\'s Movie Twister', GOLD)]
    for k, x, head, hc, tag, line, big, small, bc in cards:
        R += card(f'{S}_{k}_card', x, 1.95, 3.9, 2.55)
        R += tb(f'{S}_{k}_h', x + 0.25, 2.08, 2.6, 0.45, head, 20, hc, True)
        R += tb(f'{S}_{k}_tag', x + 2.6, 2.13, 1.05, 0.35, tag, 10, G, True, 'END')
        R += tb(f'{S}_{k}_l', x + 0.25, 2.62, 3.4, 0.7, line, 14, W)
        R += tb(f'{S}_{k}_big', x + 0.25, 3.35, 3.4, 0.6, big, 30, bc, True)
        R += tb(f'{S}_{k}_sm', x + 0.25, 3.95, 3.4, 0.4, small, 12, L)
    # evidence strip
    R += card(f'{S}_ev_card', 0.89, 4.72, 11.56, 0.95, DOM)
    R += tb(f'{S}_ev_big', 1.1, 4.82, 1.6, 0.75, '×1.8', 34, DOM, True)
    R += tb(f'{S}_ev_t', 2.75, 4.88, 9.5, 0.7, 'Why B: in Domino 20, payers who got the event Joker spent 1.8× their own habit in those 2 days; half paid above their comfort zone (18% of payers, 31% of album revenue).', 13, W)
    R += tb(f'{S}_ms', 0.89, 5.82, 11.6, 0.35, 'Measure: finish rate · revenue per payer in the last 7 days · spend in the first week of the next album', 13, L)
    R += tb(f'{S}_ch', 0.45, 6.92, 1.26, 0.27, 'Chapter 4', 12, L)
    R += tb(f'{S}_ft', 10.6, 6.99, 2.3, 0.26, 'SuperPlay 2026', 12, G)
    return R

if __name__ == '__main__':
    import sys
    print(json.dumps(build(int(sys.argv[1])), ensure_ascii=False, separators=(',', ':')))
