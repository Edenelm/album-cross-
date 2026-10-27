"""Domino FU slide (Eden 2026-10-27): Easy payers who reached FU (141+ of 144) in album 20, % who finished, by spend level.
Source: claude/domino-easy-gate-stuck-2026-10-27.md (branch claude/domino-chapter-continuation-d98b34) | SQL: claude/domino_easy_gate_stuck_2026-10-27.sql
Usage: python3 slide_domino_fu_2026-10-27.py [insertion_index] -> prints update_presentation requests (JSON). Style helpers from slide_domino_chapter_2026-10-26.py."""
import json, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib.util
spec = importlib.util.spec_from_file_location('ch', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
Slide, WHITE, GOLD, GREY, DGREY, BG = ch.Slide, ch.WHITE, ch.GOLD, ch.GREY, ch.DGREY, ch.BG

# level, % of FU reachers who finished, left at FU (players), % of Easy payers, % of album revenue
ROWS = [('≤ $2 a day', 14, 23162, '22%', '8%'), ('$2–5 a day', 17, 8194, '8%', '10%'),
        ('$5–20 a day', 27, 3276, '3%', '10%'), ('> $20 a day', 58, 99, '0.1%', '1%')]

def fu(idx):
    S = Slide('dxfu_slide', idx)
    S.text(0.5, 0.12, 9.0, 0.5, 'Easy Payers Who Reached FU: % Who Finished, by Spend Level', 22, WHITE, spans=[('% Who Finished', GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, 'Domino album 20 · Easy paying players · % of payers and of album revenue = of all 106,762 standard-population payers · reached FU = 141+ of 144 stickers · finished = 144 by the end of the close day · level = $ per album day before the last quarter', 10, GREY)
    S.panel(0.5, 1.1, 5.9, 3.45, '% of payers who reached FU and finished')
    base, scale, bw = 3.35, 0.03, 0.7
    for i, (lab, p, n, sp, sr) in enumerate(ROWS):
        x = 0.9 + i * 1.4
        col = GOLD if lab in ('$2–5 a day', '$5–20 a day') else GREY
        h = p * scale
        S.rect(x, base - h, bw, h, col)
        S.text(x - 0.2, base - h - 0.28, bw + 0.4, 0.26, f'{p}%', 12, WHITE, bold=True, align='CENTER')
        S.text(x - 0.3, base + 0.04, bw + 0.6, 0.22, lab, 9, WHITE, bold=True, align='CENTER')
        S.text(x - 0.3, base + 0.26, bw + 0.6, 0.6, f'left at FU: {n:,}\n{sp} of payers\n{sr} of album rev', 8, GREY, align='CENTER')
    S.panel(6.6, 1.1, 2.9, 3.45)
    S.text(6.75, 1.25, 2.6, 0.3, 'Reached FU, did not finish', 11, WHITE, bold=True)
    S.text(6.75, 1.6, 2.6, 0.5, '29%', 30, WHITE, bold=True)
    S.text(6.75, 2.15, 2.6, 0.5, 'of album revenue\n36,348 Easy payers · 34% of payers', 9, GREY)
    S.text(6.75, 2.85, 2.6, 0.5, '20%', 30, GOLD, bold=True)
    S.text(6.75, 3.4, 2.6, 0.7, 'of album revenue from $2–20 a day\n11,470 payers · 11% of payers', 9, GREY)
    S.text(0.5, 4.72, 8.6, 0.5, 'Most Easy payers who reach FU stop there, even at $5–20 a day. Those left at FU bring 29% of album revenue, and $2–20 a day payers 20% of it.',
           11, WHITE, spans=[('29% of album revenue', GOLD), ('$2–20 a day payers 20%', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

NOTES = ('Easy paying players in Domino album 20, standard population (not first album, login ratio ≥ 0.5 on the last row, row on close−1). '
 'Reached FU = first day with 141+ of 144 stickers: everything except the end-locked stickers. Base for revenue share = album revenue of all standard-population payers (≈ $12.8M, 106,762 payers).\n'
 'Of 43,711 Easy payers who reached FU, 7,363 finished (17%). By level: ≤$2 14%, $2–5 17%, $5–20 27%, >$20 58%.\n'
 'Most of those left at FU reached it between close−6 and close−2 (78–89%), so time was not the barrier for most.\n'
 'Fact: by players most are ≤$2 a day; by money most is $2–20 a day. Interpretation: looks like a price / difficulty barrier on the last step, not only weak players. Correlation only; the puzzle tier step could not be checked (table empty for album 20).\n'
 'Meaning: TEST an FU offer for $2–20 a day payers who reached FU by close−2; main metric = revenue per assigned player to close and the week after. Revenue share is context, not money to be won.\n'
 'Source: claude/domino-easy-gate-stuck-2026-10-27.md | SQL: claude/domino_easy_gate_stuck_2026-10-27.sql | Script: claude/slide_domino_fu_2026-10-27.py')

if __name__ == '__main__':
    idx = int(sys.argv[1]) if len(sys.argv) > 1 else 114
    print(json.dumps(fu(idx).R, separators=(',', ':')))
