"""Generator for x3 small-multiple slides (one panel per game) in Eden's deck style."""
GAMES = [
    ("dice", "Dice", "#6FA3FF", "project/ds/superplay/assets/games/dice-dreams-logo.png", "Dice Dreams logo"),
    ("domino", "Domino", "#F5A04A", "project/ds/superplay/assets/games/domino-dreams-logo.png", "Domino Dreams logo"),
    ("disney", "Disney", "#3CC8B4", "project/ds/superplay/assets/games/disney-solitaire-logo.png", "Disney Solitaire logo"),
]
FOOTER = '<svg aria-label="Footer line" width="1920" height="120" viewBox="0 0 1920 120" style="position:absolute;left:0px;top:960px;width:1920px;height:120px"><polygon points="980,120 1920,30 1920,120" fill="#1A1A1A"/><line x1="980" y1="120" x2="1920" y2="30" stroke="#4A4A4A" stroke-width="2"/></svg>'
PX = [128, 704, 1280]   # panel left
PW, PT, PH = 512, 296, 600  # panel width, top, height
# plot area inside panel (panel-relative)
L, R, T, B = 72, 24, 110, 520  # left pad, right pad, plot top y, plot bottom y


def p(left, top, width, text, size=22, color="#C8C8C0", align="center", weight=400):
    return (f'<p style="position:absolute;left:{round(left)}px;top:{round(top)}px;width:{round(width)}px;'
            f'font-size:{size}px;font-weight:{weight};color:{color};text-align:{align}">{text}</p>')


def head(sid, title_html, sub, tag, pad_gap=20):
    return (f'<section id="{sid}" data-transition="fade" style="background:#212121;color:#F5F5F0;font-family:\'Oswald\', sans-serif;'
            f'padding:110px 128px 160px;display:flex;flex-direction:column;gap:{pad_gap}px">\n{FOOTER}\n'
            f'<h2 style="font-size:60px;font-weight:400;line-height:1.1">{title_html}</h2>\n'
            f'<p style="font-size:28px;color:#C8C8C0">{sub}</p>\n')


def tail(tag, aside):
    return (f'<p style="position:absolute;left:64px;bottom:40px;width:200px;font-size:24px;color:#C8C8C0;border:1px solid #6A6A6A;background:#2A2A2A;padding:4px 16px">{tag}</p>\n'
            f'<p style="position:absolute;right:64px;bottom:40px;width:320px;text-align:right;font-size:24px;color:#9E9E9E">SuperPlay 2026</p>\n'
            f'<aside>{aside}</aside>\n</section>\n')


def panel_frame(i, note=None):
    g = GAMES[i]
    x = PX[i]
    out = [f'<div style="position:absolute;left:{x}px;top:{PT}px;width:{PW}px;height:{PH}px;background:#262626;border:1px solid #3A3A3A;border-radius:20px"></div>',
           f'<img src="{g[3]}" alt="{g[4]}" style="position:absolute;left:{x+24}px;top:{PT+18}px;width:170px;height:60px;object-fit:contain">']
    if note:
        out.append(p(x + 200, PT + 30, PW - 224, note, 22, "#C8C8C0", "right"))
    return out


def line_panels(sid, title, sub, tag, aside, series, xs, xlabels, ymin, ymax, yticks, fmt, shade_from=None,
                end_label=True, compare=True, notes=None, footer_line=None, extra_lines=None):
    """series: dict game_key -> list of y (same length as xs). xs in data units (0..100)."""
    out = [head(sid, title, sub, tag)]
    x0, x1 = xs[0], xs[-1]
    for i, g in enumerate(GAMES):
        px = PX[i]
        out += panel_frame(i, notes[i] if notes else None)
        pw = PW - L - R
        def X(v): return L + (v - x0) / (x1 - x0) * pw
        def Y(v): return B - (v - ymin) / (ymax - ymin) * (B - T)
        svg = [f'<svg aria-label="{g[1]} chart" width="{PW}" height="{PH}" viewBox="0 0 {PW} {PH}" style="position:absolute;left:{px}px;top:{PT}px;width:{PW}px;height:{PH}px">']
        if shade_from is not None:
            svg.append(f'<rect x="{X(shade_from):.0f}" y="{T}" width="{X(x1)-X(shade_from):.0f}" height="{B-T}" fill="#FFDF85" opacity="0.07"/>')
        for t in yticks:
            svg.append(f'<line x1="{L}" y1="{Y(t):.0f}" x2="{PW-R}" y2="{Y(t):.0f}" stroke="#333333" stroke-width="1"/>')
        svg.append(f'<line x1="{L}" y1="{B}" x2="{PW-R}" y2="{B}" stroke="#6A6A6A" stroke-width="2"/>')
        if compare:
            for j, h in enumerate(GAMES):
                if j == i:
                    continue
                pts = " ".join(f"{X(a):.0f},{Y(b):.0f}" for a, b in zip(xs, series[h[0]]))
                svg.append(f'<polyline points="{pts}" fill="none" stroke="#5A5A5A" stroke-width="2" stroke-dasharray="6 6"/>')
        if extra_lines:
            for ys, col, dash in extra_lines.get(g[0], []):
                pts = " ".join(f"{X(a):.0f},{Y(b):.0f}" for a, b in zip(xs, ys))
                svg.append(f'<polyline points="{pts}" fill="none" stroke="{col}" stroke-width="2"{" stroke-dasharray=\"6 6\"" if dash else ""}/>')
        ys = series[g[0]]
        pts = " ".join(f"{X(a):.0f},{Y(b):.0f}" for a, b in zip(xs, ys))
        svg.append(f'<polyline points="{pts}" fill="none" stroke="{g[2]}" stroke-width="5"/>')
        svg.append(f'<circle cx="{X(xs[-1]):.0f}" cy="{Y(ys[-1]):.0f}" r="8" fill="{g[2]}"/>')
        svg.append('</svg>')
        out.append("".join(svg))
        for t in yticks:
            out.append(p(px + 4, PT + Y(t) - 15, L - 12, fmt(t), 20, "#9E9E9E", "right"))
        for v, lab in xlabels:
            out.append(p(px + X(v) - 40, PT + B + 10, 80, lab, 20, "#9E9E9E"))
        if end_label:
            out.append(p(px + X(xs[-1]) - 110, PT + Y(ys[-1]) - 46, 120, fmt(ys[-1]), 30, "#F5F5F0", "right", 500))
    if footer_line:
        out.append(p(128, 912, 1664, footer_line, 26, "#C8C8C0", "left", 300))
    out.append(tail(tag, aside))
    return "\n".join(out)


def bar_panels(sid, title, sub, tag, aside, data, ymin, ymax, yticks, fmt, notes=None, footer_line=None,
               highlight=None, label_size=18, cat_size=18, legend=None):
    """data: game_key -> list of (category_label, value[, value2]) ; if value2 present -> paired bars (grey value, color value2)."""
    out = [head(sid, title, sub, tag)]
    if legend:
        out.append(legend)
    for i, g in enumerate(GAMES):
        px = PX[i]
        out += panel_frame(i, notes[i] if notes else None)
        rows = data[g[0]]
        pw = PW - L - R
        n = len(rows)
        slot = pw / n
        def Y(v): return B - (v - ymin) / (ymax - ymin) * (B - T)
        svg = [f'<svg aria-label="{g[1]} chart" width="{PW}" height="{PH}" viewBox="0 0 {PW} {PH}" style="position:absolute;left:{px}px;top:{PT}px;width:{PW}px;height:{PH}px">']
        for t in yticks:
            svg.append(f'<line x1="{L}" y1="{Y(t):.0f}" x2="{PW-R}" y2="{Y(t):.0f}" stroke="#333333" stroke-width="1"/>')
        zero = Y(max(ymin, 0))
        labels = []
        for k, r in enumerate(rows):
            cx = L + slot * (k + 0.5)
            pair = len(r) > 2
            vals = [(r[1], "#7A7A7A"), (r[2], g[2])] if pair else [(r[1], g[2])]
            bw = min(slot * (0.36 if pair else 0.62), 40 if pair else 34)
            for m, (v, col) in enumerate(vals):
                bx = cx - (bw + 2) + m * (bw + 4) if pair else cx - bw / 2
                yv = Y(v)
                top, h = (yv, zero - yv) if v >= 0 else (zero, yv - zero)
                hl = highlight and highlight(g[0], k, r)
                stroke = ' stroke="#FF0B47" stroke-width="3"' if hl else ''
                svg.append(f'<rect x="{bx:.0f}" y="{top:.0f}" width="{bw:.0f}" height="{max(h,2):.0f}" rx="3" fill="{col}"{stroke}/>')
                lx = bx + bw / 2
                ly = (yv - 28) if v >= 0 else (yv + 4)
                labels.append(p(px + lx - 24, PT + ly, 48, fmt(v), label_size, "#FF0B47" if hl else "#F5F5F0"))
            labels.append(p(px + cx - slot / 2 - 6, PT + B + 10, slot + 12, r[0], cat_size, "#9E9E9E"))
        svg.append(f'<line x1="{L}" y1="{zero:.0f}" x2="{PW-R}" y2="{zero:.0f}" stroke="#6A6A6A" stroke-width="2"/>')
        svg.append('</svg>')
        out.append("".join(svg))
        out += labels
    if footer_line:
        out.append(p(128, 912, 1664, footer_line, 26, "#C8C8C0", "left", 300))
    out.append(tail(tag, aside))
    return "\n".join(out)


def pending_panels(sid, title, sub, tag, aside, msg, ready=None):
    """ready: dict game_index -> html list to render instead of a pending note."""
    out = [head(sid, title, sub, tag)]
    for i, g in enumerate(GAMES):
        if ready and i in ready:
            out += ready[i]
            continue
        out += panel_frame(i)
        out.append(p(PX[i] + 40, PT + 250, PW - 80, msg, 28, "#9E9E9E"))
    out.append(tail(tag, aside))
    return "\n".join(out)
