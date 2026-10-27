"""dxchg_slide v2 (Slide rules): visual instead of table. Bars = payers who finished, album 19 vs 20, Easy and Hard; right = 3 design-change tiles.
Rebuilds the content of dxchg_slide in place (deletes the v1 table elements created on 2026-10-27).
Sources: claude/domino-19v20-by-segment-2026-10-27.md, domino-dx-map-2026-10-25.md, domino-dx-t4-2026-10-25.md, domino-dx-last3-sources-2026-10-26.md"""
import json, importlib.util
spec = importlib.util.spec_from_file_location('ch', __file__.replace('slide_domino_19v20_changes_v2_2026-10-27.py', 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
WHITE, GOLD, GREY, DGREY, ORANGE, PANEL, OUTL = ch.WHITE, ch.GOLD, ch.GREY, ch.DGREY, ch.ORANGE, ch.PANEL, ch.OUTL
S = ch.Slide.__new__(ch.Slide); S.s, S.n, S.R = 'dxchg_slide', 100, []
old = [f'dxchg_slide_t{i}' for i in (1, 2, 3, *range(5, 31)) if i not in (7, 11, 15, 19, 23, 27)] + [f'dxchg_slide_b{i}' for i in (7, 11, 15, 19, 23, 27)]
S.R += [{'deleteObject': {'objectId': o}} for o in old]
S.text(0.5, 0.12, 9.0, 0.5, 'Payers Who Finished, Domino 19 vs 20: Easy (Gate 5 → 3) and Hard (Gate 3 → 3)', 22, WHITE)
S.text(0.5, 0.63, 9.0, 0.28, 'Standard-population payers · finished = 144 stickers by the end of the close day · gate = stickers only a Joker can unlock at the end', 10, GREY)
S.panel(0.5, 1.05, 5.4, 3.35)
YB, H, VMAX = 3.6, 2.1, 35.0
for gx, seg, a, b, gate, share in ((1.0, 'Easy', 4, 8, 'gate 5 → 3', '92% of payers · 55% of album revenue'),
                                    (3.5, 'Hard', 22, 32, 'gate 3 → 3 (unchanged)', '8% of payers · 45% of album revenue')):
    for j, (v, col, lab) in enumerate(((a, '#8a8a8a', 'Album 19'), (b, GOLD, 'Album 20'))):
        x = gx + j * 0.95; h = H * v / VMAX
        S.rect(x, YB - h, 0.75, h, col)
        S.text(x - 0.1, YB - h - 0.32, 0.95, 0.3, f'{v}%', 13, WHITE, bold=True, align='CENTER')
        S.text(x - 0.1, YB + 0.03, 0.95, 0.22, lab, 8, GREY, align='CENTER')
    S.text(gx - 0.2, YB + 0.25, 2.1, 0.25, f'{seg} · {gate}', 11, WHITE, bold=True, align='CENTER')
    S.text(gx - 0.2, YB + 0.5, 2.1, 0.22, share, 8, DGREY, align='CENTER')
PX, PW = 6.1, 3.4
for i, (big, small) in enumerate((('Gate 5 → 3', 'Easy only; Hard kept 3 stickers'),
                                  ('Joker Puzzle from close−14', 'new in 20; the Joker sits in a very hard last tier, players paid to finish it'),
                                  ('71% → 81%', "finishers' last 3 stickers via Jokers from end events"))):
    y = 1.05 + i * 1.15
    S.panel(PX, y, PW, 1.0)
    S.text(PX + 0.15, y + 0.08, PW - 0.3, 0.4, big, 15, GOLD if i == 1 else WHITE, bold=True)
    S.text(PX + 0.15, y + 0.5, PW - 0.3, 0.45, small, 9, GREY)
S.text(0.5, 4.6, 9.0, 0.45, 'Hard improved strongly too, with the same gate, so the smaller gate alone does not explain album 20; the Joker Puzzle route from close−14 changed for both.', 11, WHITE,
       spans=[('Hard improved strongly too, with the same gate', GOLD)])
def rnd(o):
    if isinstance(o, float): return round(o, 3)
    if isinstance(o, dict): return {k: rnd(v) for k, v in o.items() if not (k in ('shearX', 'shearY') and v == 0)}
    if isinstance(o, list): return [rnd(v) for v in o]
    return o
print(json.dumps(rnd(S.R), separators=(',', ':'), ensure_ascii=False))
