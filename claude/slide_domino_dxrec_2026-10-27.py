"""dxrec rebuild (Eden 2026-10-27): KEEP album 20's end supply (GoldenKiosk + Joker route) + TEST 1 FU offer ($2-20/day) + TEST 2 earlier rares (6-12 missing).
Replaces the elements of dxrec_slide in place (same slide id). Sources: domino-goldenkiosk-std-2026-10-27, domino-easy-gate-stuck-2026-10-27,
domino-chapter-album-rev-base-2026-10-27, domino-end-rares-jokers-19v20-2026-10-27. Usage: python3 slide_domino_dxrec_2026-10-27.py -> JSON requests."""
import json, os, importlib.util
spec = importlib.util.spec_from_file_location('ch', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
WHITE, GOLD, GREY, DGREY, ORANGE = ch.WHITE, ch.GOLD, ch.GREY, ch.DGREY, ch.ORANGE

class Upd(ch.Slide):
    def __init__(self, sid, old):
        self.s, self.n, self.R = sid, 0, [{'deleteObject': {'objectId': o}} for o in old]
    def oid(self, tag):
        self.n += 1; return f'{self.s}_v2{tag}{self.n}'

OLD = ['dxrec_slide_t1', 'dxrec_slide_t2', 'dxrec_slide_p3', 'dxrec_slide_t4', 'dxrec_slide_t5', 'dxrec_slide_p6', 'dxrec_slide_t7', 'dxrec_slide_t8', 'dxrec_slide_t9', 'dxrec_slide_t10']

def card(S, x, head, col, body):
    S.panel(x, 1.1, 2.9, 3.5)
    S.text(x + 0.12, 1.15, 2.66, 0.55, head, 11, col, bold=True)
    S.text(x + 0.12, 1.75, 2.66, 2.8, body, 10, GREY, spans=[(w, WHITE, True) for w in ('Who:', 'What:', 'Change:', 'Watch:', 'Measure:') if w in body])

def build():
    S = Upd('dxrec_slide', OLD)
    S.text(0.5, 0.12, 9.0, 0.5, 'What to Do in Domino: Keep One Thing, Test Two', 22, WHITE, spans=[('Keep One Thing, Test Two', GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, 'Domino · sizes from album 20, standard-population payers (106,762) · % of payers and % of album revenue of all of them', 10, GREY)
    card(S, 0.5, 'KEEP · album 20\'s end supply', GOLD,
         'Who: all payers · Easy 92% of payers, 55% of album revenue · Hard 8%, 45%\n\n'
         'What: Golden / Royal pick (GoldenKiosk) at close−7; Joker Puzzle from close−14; Joker events peak at close−3\n\n'
         'Watch: % of album revenue within 3 at close−4 (album 20: 55%)')
    card(S, 3.55, 'TEST 1 · offer at FU for $2–20 a day payers', ORANGE,
         'Who: Easy payers $2–20 a day who reached FU and did not finish · 11,470 · 11% of payers · 20% of album revenue\n\n'
         'Change: a priced offer for the last locked stickers, from the day they reach FU\n\n'
         'Measure: revenue per assigned player, to close and the week after')
    card(S, 6.6, 'TEST 2 · earlier rares for far Easy payers', ORANGE,
         'Who: Easy payers 6–12 missing at close−7 · 59,776 · 56% of payers · 33% of album revenue\n\n'
         'Change: steady supply of released Royals + Goldens from close−14\n\n'
         'Measure: revenue per assigned player, to close and the week after')
    S.text(0.5, 4.72, 8.6, 0.5, 'Keep album 20\'s late Golden pick and Joker route. Test first where the money is stuck: an offer at FU for $2–20 a day payers, then earlier rares for the far.',
           11, WHITE, spans=[('Keep album 20\'s late Golden pick and Joker route.', GOLD), ('an offer at FU for $2–20 a day payers', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

if __name__ == '__main__':
    print(json.dumps(build().R, ensure_ascii=False, separators=(',', ':')))
