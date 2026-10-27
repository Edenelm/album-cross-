"""Eden 2026-10-27: transition slide (dxtrans_slide) + Domino 19 vs 20 version of slide 51 'Day of the Last New Rare' (dxlast_slide).
Data: claude/far-rare-gate-gap-2026-10-23.md (far middle payers P50-95, 4+ missing at close-1, last new Royal rev-weighted 10.6 / 11.7 days)
+ base: standard-population payers 119,201 / $13,554,420 (19), 106,762 / $12,824,543 (20) (query in domino-end-rares-jokers-19v20 addendum).
Usage: python3 slide_domino_far_last_royal_2026-10-27.py <trans|last> <idx> -> JSON requests."""
import json, sys, os, importlib.util
spec = importlib.util.spec_from_file_location('ch', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
WHITE, GOLD, GREY, DGREY, RED, MID = ch.WHITE, ch.GOLD, ch.GREY, ch.DGREY, ch.RED, ch.MID
DARKRED = '#4a2027'

def trans(idx):
    S = ch.Slide('dxtrans_slide', idx)
    S.text(0.8, 1.55, 8.4, 0.7, 'The wave helped most payers.', 36, WHITE, bold=True)
    S.text(0.8, 2.3, 8.4, 0.7, 'Those who stayed far got nothing from it.', 36, RED, bold=True)
    S.text(0.8, 3.2, 8.4, 0.4, 'Their last new Royal still comes 11 days before close, in both albums.', 16, GREY)
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

def last(idx):
    S = ch.Slide('dxlast_slide', idx)
    S.text(0.5, 0.12, 9.0, 0.5, 'Day of the Last New Royal, Middle Payers Who End Far: Domino 19 vs 20', 20, WHITE, spans=[('Last New Royal', GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, 'Middle payers = P50–95 of spend at 75% of the album · end far = 4+ stickers missing the day before close · standard population · day = revenue-weighted average', 10, GREY)
    x0, W = 1.5, 5.4
    X = lambda d: x0 + (14 - d) / 14 * W
    rows = [('Album 19', 10.6, '38,622 payers', '32% of payers · 31% of album revenue'),
            ('Album 20', 11.7, '15,370 payers', '14% of payers · 12% of album revenue')]
    for i, (alb, day, n, share) in enumerate(rows):
        y = 1.4 + i * 1.35
        S.text(0.5, y + 0.12, 1.0, 0.3, alb, 13, WHITE, bold=True)
        S.rect(X(14), y + 0.1, X(day) - X(14), 0.4, MID)
        S.text(X(14) + 0.08, y + 0.17, 1.4, 0.26, 'new Royals', 10, WHITE)
        S.rect(X(day), y, X(0) - X(day), 0.6, DARKRED)
        S.text(X(day), y + 0.15, X(0) - X(day), 0.3, f'nothing new for {day:.0f} days', 12, RED, bold=True, align='CENTER')
        S.text(7.15, y + 0.02, 2.4, 0.3, n, 12, WHITE, bold=True)
        S.text(7.15, y + 0.3, 2.4, 0.3, share, 9, GREY)
    for d in (14, 10, 7, 4, 1):
        S.text(X(d) - 0.2, 4.05, 0.4, 0.2, str(d), 9, GREY, align='CENTER')
    S.text(X(14), 4.25, X(0) - X(14), 0.2, 'days before close', 9, DGREY, align='CENTER')
    S.text(0.5, 4.72, 8.6, 0.5, 'Payers who end far get their last new Royal about 11 days before close in both albums; album 20 just left fewer of them far (14% of payers vs 32%).',
           11, WHITE, spans=[('about 11 days before close in both albums', RED), ('14% of payers vs 32%', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

if __name__ == '__main__':
    S = trans(int(sys.argv[2])) if sys.argv[1] == 'trans' else last(int(sys.argv[2]))
    print(json.dumps(S.R, ensure_ascii=False, separators=(',', ':')))
