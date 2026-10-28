# 2026-10-28 (Eden): Royals slide: new Royals per 100 active payers per day, last 20 days, Domino 19 vs 20. Copy of wv_slide, lines re-shaped.
# Data: claude/domino-royal-sources-19v20-2026-10-28.md.
import json, sys
NEW, P = 'ry_slide', 'ry_'
S = {19: [10.1,6.2,9.7,13.0,8.5,5.9,16.7,16.0,14.4,17.8,33.0,26.1,19.6,27.2,25.4,12.0,6.9,10.7,14.5,20.0],
     20: [8.6,13.2,19.2,22.2,10.5,25.7,36.6,21.7,13.6,10.7,7.8,7.4,10.3,11.3,15.6,13.5,27.5,26.3,17.9,15.4]}
X0, XW, YB, YT, VT = 1300000, 6300000, 3799840, 1841500, 40
X = lambda i: X0 + i * XW / 19
Y = lambda v: YB - v / VT * (YB - YT)
ids = [f'wv_n{i}' for i in range(1, 39)] + ['wv_w1', 'wv_w2', 'wv_w1t', 'wv_w1s', 'wv_w2t', 'wv_w2s', 'wv_e19', 'wv_e20']
mp = {'wv_slide': NEW, **{o: P + o[3:] for o in ids}}
R = [{'duplicateObject': {'objectId': 'wv_slide', 'objectIds': mp}}]
R += [{'deleteObject': {'objectId': P + o}} for o in ('w1', 'w2', 'w1s', 'w2s')]
for a, base in ((19, 0), (20, 19)):
    for i in range(19):
        y1, y2 = Y(S[a][i]), Y(S[a][i + 1])
        R.append({'updatePageElementTransform': {'objectId': f'{P}n{base + i + 1}', 'applyMode': 'ABSOLUTE',
                  'transform': {'scaleX': 1, 'scaleY': -1 if y2 < y1 else 1, 'translateX': int(X(i)), 'translateY': int(y1), 'unit': 'EMU'}}})
def rep(a, b): R.append({'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [NEW]}})
rep('New Stickers per Active Payer per Day, Last 20 Days: Domino 19 vs 20', 'New Royals per 100 Active Payers per Day, Last 20 Days: Domino 19 vs 20')
rep('first copy of each set sticker, from any source', 'first copy of each Royal · Royals come only from gameplay or a Joker')
rep('Album 20 gave two free waves: two weeks before close (+5 stickers per payer) and in the last week (+2)',
    'Same Royal supply in both albums, about one new Royal per payer every 6 days; album 20 only moved it to other days')
rep('Wave 1 · +5 a payer', 'Album 19: 3.1 Royals a payer'); rep('Wave 2 · +2 a payer', 'Album 20: 3.4 Royals a payer')
print(json.dumps(R, separators=(',', ':'), ensure_ascii=False))
