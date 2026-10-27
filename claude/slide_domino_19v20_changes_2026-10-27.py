"""dxchg_slide: what changed in the album design between Domino 19 and 20 (Domino deck, after t5ad_slide).
Sources: domino-dx-map-2026-10-25.md (gate, events), domino-dx-t4-2026-10-25.md (puzzle Jokers), domino-dx-last3-sources-2026-10-26.md (last 3 stickers).
Usage: python3 claude/slide_domino_19v20_changes_2026-10-27.py <insertion_index>"""
import json, sys, importlib.util
spec = importlib.util.spec_from_file_location('ch', __file__.replace('slide_domino_19v20_changes_2026-10-27.py', 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
WHITE, GOLD, GREY, DGREY, ORANGE, PANEL, OUTL, BLUE = ch.WHITE, ch.GOLD, ch.GREY, ch.DGREY, ch.ORANGE, ch.PANEL, ch.OUTL, ch.BLUE
ROWS = [('End gate, Easy', '5 stickers: 2 Royals + 3 Goldens', '3 stickers: 2 Royals + 1 Golden'),
        ('End gate, Hard', '3 stickers', '3 stickers (same)'),
        ('Free Joker route', 'No Joker Puzzle; late events (close−6 to close−1)', 'Joker Puzzle from close−14 + SummerFever (2 Jokers, last 4 days)'),
        ("Finishers' last 3 stickers", '71% free event Jokers · 21% paid', '81% free event Jokers · 6% paid'),
        ('Easy payers finished (gate 5 → 3)', '4%  ·  87% far a day before close', '8%  ·  57% far'),
        ('Hard payers finished (gate unchanged)', '22%  ·  47% far a day before close', '32%  ·  26% far')]
def build(idx):
    S = ch.Slide('dxchg_slide', idx)
    S.frame('What Changed at the End of the Album: Domino 19 vs 20',
            'Design facts from the data · results = standard-population payers · far = 4+ stickers missing',
            'Hard improved strongly too, with the same gate, so the smaller gate alone does not explain album 20; the free Joker route two weeks before close fits both.',
            msg_spans=[('Hard improved strongly too, with the same gate', GOLD)])
    x0, w0, w1, y, rh = 0.5, 2.5, 3.1, 1.05, 0.5
    S.text(x0 + w0 + 0.1, y, w1, 0.3, 'Album 19', 13, GREY, bold=True)
    S.text(x0 + w0 + w1 + 0.2, y, w1, 0.3, 'Album 20', 13, ORANGE, bold=True)
    for i, (lab, a, b) in enumerate(ROWS):
        yy = y + 0.38 + i * (rh + 0.06)
        res = i >= len(ROWS) - 2
        S.rect(x0, yy, w0 + 2 * w1 + 0.3, rh, '#262626' if not res else '#2e2b26', None, tag='b')
        S.text(x0 + 0.1, yy, w0, rh, lab, 11, WHITE, bold=True, valign='MIDDLE')
        S.text(x0 + w0 + 0.1, yy, w1, rh, a, 10, GREY, valign='MIDDLE')
        S.text(x0 + w0 + w1 + 0.2, yy, w1, rh, b, 10, GOLD if res or i in (0, 2) else WHITE, bold=res or i in (0, 2), valign='MIDDLE')
    return S
if __name__ == '__main__':
    S = build(int(sys.argv[1]))
    def rnd(o):
        if isinstance(o, float): return round(o, 3)
        if isinstance(o, dict): return {k: rnd(v) for k, v in o.items() if not (k in ('shearX', 'shearY') and v == 0)}
        if isinstance(o, list): return [rnd(v) for v in o]
        return o
    print(json.dumps(rnd(S.R), separators=(',', ':'), ensure_ascii=False))
