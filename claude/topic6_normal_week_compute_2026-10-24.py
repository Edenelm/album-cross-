"""Normal-week check (Eden 2026-10-24). From results/topic6_normal_week_check_2026-10-24.csv (sums per game x album x level x status):
mid = mid7 / 7 / pace_a (album days 21-27, no close), after = after7 / 7 / pace_a (week after close). Group sums; simple average over 3 albums."""
import csv, collections
r = list(csv.DictReader(open('results/topic6_normal_week_check_2026-10-24.csv')))
LV = ['t1_le2', 't2_2_5', 't3_5_20', 't4_gt20']
for st in ['a_finished', 'b_1_2']:
    print('==', st)
    for g in ['Dice', 'Domino', 'Disney']:
        al = sorted({x['a'] for x in r if x['game'] == g}, key=int)
        row = []
        for lv in LV:
            m, a = [], []
            for x in al:
                q = [y for y in r if y['game'] == g and y['a'] == x and y['l'] == lv and y['s'] == st][0]
                p = float(q['pace_a']) * 7
                m.append(100 * float(q['mid7']) / p); a.append(100 * float(q['after7']) / p)
            row.append(f"{lv}: mid {[round(v) for v in m]} avg {round(sum(m)/3)} | after {[round(v) for v in a]} avg {round(sum(a)/3)}")
        print(g); [print('   ', z) for z in row]
