"""Helpers for Eden's deck style (dark, Oswald, game colors)."""
DICE, DOMINO, DISNEY = "#6FA3FF", "#F5A04A", "#3CC8B4"
GOLD, RED, GREEN, GREY = "#FFDF85", "#FF0B47", "#57BB8A", "#C8C8C0"
GAMES = [("dice", "Dice", DICE, "project/ds/superplay/assets/games/dice-dreams-logo.png", "Dice Dreams logo"),
         ("domino", "Domino", DOMINO, "project/ds/superplay/assets/games/domino-dreams-logo.png", "Domino Dreams logo"),
         ("disney", "Disney", DISNEY, "project/ds/superplay/assets/games/disney-solitaire-logo.png", "Disney Solitaire logo")]
RIBBON = "/_blob/3b61c245dd774c3b4b68b089d3c30e0a"
STICKER = "/_blob/7ee22b859cea5f6c1ba3dbb5c0d90792"
FOOTER = ('<svg aria-label="Footer line" width="1920" height="120" viewBox="0 0 1920 120" style="position:absolute;left:0px;top:960px;width:1920px;height:120px">'
          '<polygon points="980,120 1920,30 1920,120" fill="#1A1A1A"/><line x1="980" y1="120" x2="1920" y2="30" stroke="#4A4A4A" stroke-width="2"/></svg>')


def g(text, color=GOLD):
    return f'<span style="color:{color}">{text}</span>'


def tagbar(tag):
    t = (f'<p style="position:absolute;left:64px;bottom:40px;width:200px;font-size:24px;color:#C8C8C0;border:1px solid #6A6A6A;background:#2A2A2A;padding:4px 16px">{tag}</p>\n') if tag else ''
    return t + '<p style="position:absolute;right:64px;bottom:40px;width:320px;text-align:right;font-size:24px;color:#9E9E9E">SuperPlay 2026</p>\n'


def section(sid, title, sub, body, tag, aside, gap=28, pad="110px 128px 160px"):
    out = [f'<section id="{sid}" data-transition="fade" style="background:#212121;color:#F5F5F0;font-family:\'Oswald\', sans-serif;padding:{pad};display:flex;flex-direction:column;gap:{gap}px">',
           FOOTER,
           f'<h2 style="font-size:64px;font-weight:400;line-height:1.1">{title}</h2>']
    if sub:
        out.append(f'<p style="font-size:28px;color:#C8C8C0">{sub}</p>')
    out.append(body)
    out.append(tagbar(tag))
    out.append(f'<aside>{aside}</aside>\n</section>\n')
    return "\n".join(out)


def question(sid, chapter, title_html, sofar, sub, tag, aside):
    so = (f'<p style="font-size:30px;font-weight:300;color:#9E9E9E;padding:0px 0px 0px 190px;width:1300px"><span style="color:{GOLD}">So far:</span> {sofar}</p>') if sofar else ''
    return (f'<section id="{sid}" data-transition="fade" style="background:radial-gradient(ellipse at 75% 55%, #2E2A20 0%, #212121 55%);color:#F5F5F0;font-family:\'Oswald\', sans-serif;padding:128px 128px 160px;display:flex;flex-direction:column;justify-content:center;gap:32px">\n'
            f'{FOOTER}\n'
            f'<p style="font-size:32px;font-weight:400;letter-spacing:2px;text-transform:uppercase;color:#9E9E9E;padding:0px 0px 0px 190px">{chapter}</p>\n'
            f'<div style="display:flex;flex-direction:row;align-items:center;gap:40px">\n'
            f'<img src="{RIBBON}" alt="" style="width:150px;height:150px;object-fit:contain;transform:rotate(-90deg)">\n'
            f'<h1 style="font-size:92px;font-weight:400;line-height:1.15">{title_html}</h1>\n</div>\n'
            f'<p style="font-size:36px;font-weight:300;color:#C8C8C0;padding:0px 0px 0px 190px;width:1300px">{sub}</p>\n'
            f'{so}\n{tagbar(tag)}<aside>{aside}</aside>\n</section>\n')


def p(left, top, width, text, size=24, color="#C8C8C0", align="left", weight=400, extra=""):
    return (f'<p style="position:absolute;left:{round(left)}px;top:{round(top)}px;width:{round(width)}px;font-size:{size}px;'
            f'font-weight:{weight};color:{color};text-align:{align}{extra}">{text}</p>')


def card(title, text, accent=None, big=None, big_color=GOLD, width=None, title_color="#F5F5F0"):
    w = f"width:{width}px;" if width else "flex:1;"
    border = f"border-left:8px solid {accent};" if accent else ""
    parts = [f'<div style="{w}display:flex;flex-direction:column;gap:12px;background:#2A2A2A;border-radius:18px;padding:28px;{border}">']
    if big:
        parts.append(f'<p style="font-size:84px;font-weight:500;line-height:1;color:{big_color}">{big}</p>')
    if title:
        parts.append(f'<p style="font-size:34px;font-weight:500;color:{title_color}">{title}</p>')
    if text:
        parts.append(f'<p style="font-size:30px;font-weight:300;line-height:1.35;color:#E0E0D8">{text}</p>')
    parts.append('</div>')
    return "".join(parts)


def row(*items, gap=28, extra=""):
    return f'<div style="display:flex;flex-direction:row;gap:{gap}px;{extra}">' + "".join(items) + '</div>'


def table(header, rows, widths, size=28, hl=None):
    """hl: dict (r,c) -> (bg, fg)."""
    th = "".join(f'<th style="width:{w}%;text-align:{"left" if i == 0 else "center"};color:#FFFFFF;font-weight:500">{h}</th>' for i, (h, w) in enumerate(zip(header, widths)))
    out = [f'<table style="font-family:\'Oswald\', sans-serif;font-size:{size}px;color:#F5F5F0;border:1px solid #4A4A4A;padding:12px 18px">',
           f'<tr style="background:#4285F4">{th}</tr>']
    for r, cells in enumerate(rows):
        tds = []
        for c, v in enumerate(cells):
            st = "text-align:left" if c == 0 else "text-align:center"
            if hl and (r, c) in hl:
                bg, fg = hl[(r, c)]
                st += f";background:{bg};color:{fg}"
            tds.append(f'<td style="{st}">{v}</td>')
        out.append('<tr style="background:#1A1A1A">' + "".join(tds) + '</tr>')
    out.append('</table>')
    return "".join(out)


def line_chart(left, top, w, h, series, x0, x1, y0, y1, xticks, yticks, yfmt, shade=None, dim_before=None,
               end_labels=True, label_fmt=None, start_zero=True):
    """series: list of (name, color, xs, ys). Returns html (svg + labels). Plot area = whole box minus margins."""
    L, R, T, B = 80, 120, 20, h - 50
    def X(v): return L + (v - x0) / (x1 - x0) * (w - L - R)
    def Y(v): return B - (v - y0) / (y1 - y0) * (B - T)
    svg = [f'<svg aria-label="chart" width="{w}" height="{h}" viewBox="0 0 {w} {h}" style="position:absolute;left:{left}px;top:{top}px;width:{w}px;height:{h}px">']
    if shade is not None:
        svg.append(f'<rect x="{X(shade):.0f}" y="{T}" width="{X(x1)-X(shade):.0f}" height="{B-T}" fill="#FFDF85" opacity="0.08"/>')
    for t in yticks:
        svg.append(f'<line x1="{L}" y1="{Y(t):.0f}" x2="{w-R}" y2="{Y(t):.0f}" stroke="#333333" stroke-width="1"/>')
    svg.append(f'<line x1="{L}" y1="{B}" x2="{w-R}" y2="{B}" stroke="#6A6A6A" stroke-width="2"/>')
    labels = []
    for name, col, xs, ys in series:
        pts = list(zip(xs, ys))
        if dim_before is not None:
            a = [(x, y) for x, y in pts if x <= dim_before]
            b = [(x, y) for x, y in pts if x >= dim_before]
            svg.append(f'<polyline points="{" ".join(f"{X(x):.0f},{Y(y):.0f}" for x, y in a)}" fill="none" stroke="{col}" stroke-width="3" opacity="0.25"/>')
            svg.append(f'<polyline points="{" ".join(f"{X(x):.0f},{Y(y):.0f}" for x, y in b)}" fill="none" stroke="{col}" stroke-width="7"/>')
        else:
            svg.append(f'<polyline points="{" ".join(f"{X(x):.0f},{Y(y):.0f}" for x, y in pts)}" fill="none" stroke="{col}" stroke-width="5"/>')
            for x, y in pts[1:]:
                svg.append(f'<circle cx="{X(x):.0f}" cy="{Y(y):.0f}" r="5" fill="{col}"/>')
        svg.append(f'<circle cx="{X(xs[-1]):.0f}" cy="{Y(ys[-1]):.0f}" r="9" fill="{col}"/>')
        if end_labels:
            lab = (label_fmt or yfmt)(ys[-1])
            labels.append((Y(ys[-1]), f"{name} {lab}", col))
    svg.append('</svg>')
    out = ["".join(svg)]
    # end labels, de-overlapped
    labels.sort()
    last = -99
    for y, text, col in labels:
        y = max(y, last + 36)
        last = y
        out.append(p(left + X(x1) + 14, top + y - 20, R + 40, text, 26, col, "left", 500))
    for t in yticks:
        out.append(p(left, top + Y(t) - 16, L - 12, yfmt(t), 22, "#9E9E9E", "right"))
    for v, lab in xticks:
        out.append(p(left + X(v) - 60, top + B + 10, 120, lab, 22, "#9E9E9E", "center"))
    return "\n".join(out)


def hbars(left, top, width, rows, vmax, bar_h=40, gap=18, label_w=230, fmt=lambda v: f"{v:g}%", target=None, target_label=None, size=26, inside=False):
    """rows: (label, value, color[, value_color]). Horizontal bars, absolute positioned."""
    out = []
    span = width - label_w - 140
    y = top
    for r in rows:
        lab, v, col = r[0], r[1], r[2]
        vc = r[3] if len(r) > 3 else "#F5F5F0"
        bw = max(4, v / vmax * span)
        out.append(p(left, y + bar_h / 2 - size * 0.75, label_w - 16, lab, size, "#F5F5F0", "right", 500))
        out.append(f'<div style="position:absolute;left:{left+label_w}px;top:{y}px;width:{bw:.0f}px;height:{bar_h}px;background:{col};border-radius:4px"></div>')
        if inside:
            out.append(p(left + label_w + 8, y + bar_h / 2 - size * 0.75, bw - 20, fmt(v), size, "#212121", "right", 500))
        else:
            out.append(p(left + label_w + bw + 12, y + bar_h / 2 - size * 0.75, 130, fmt(v), size, vc, "left", 500))
        y += bar_h + gap
    if target is not None:
        tx = left + label_w + target / vmax * span
        out.append(f'<div style="position:absolute;left:{tx:.0f}px;top:{top-14}px;width:3px;height:{y-top+4}px;background:{GOLD}"></div>')
        if target_label:
            out.append(p(tx - 100, top - 52, 200, target_label, 22, GOLD, "center", 500))
    return "\n".join(out), y


def vbars_panels(sid_rows, ymax, fmt, top=300, height=560, cat_size=22, val_size=28, ref=None, ref_label=None, colors_override=None):
    """sid_rows: dict game_key -> list of (label, value[, color]). Three panels with logos."""
    PX = [128, 704, 1280]
    PW = 512
    out = []
    for i, gm in enumerate(GAMES):
        x = PX[i]
        out.append(f'<div style="position:absolute;left:{x}px;top:{top}px;width:{PW}px;height:{height}px;background:#262626;border:1px solid #3A3A3A;border-radius:20px"></div>')
        out.append(f'<img src="{gm[3]}" alt="{gm[4]}" style="position:absolute;left:{x+24}px;top:{top+18}px;width:170px;height:60px;object-fit:contain">')
        rows = sid_rows[gm[0]]
        n = len(rows)
        base = top + height - 70
        ptop = top + 130
        slot = (PW - 60) / n
        if ref is not None:
            ry = base - ref / ymax * (base - ptop)
            out.append(f'<div style="position:absolute;left:{x+30}px;top:{ry:.0f}px;width:{PW-60}px;height:2px;background:{GOLD};opacity:0.8"></div>')
            if ref_label:
                out.append(p(x + PW - 200, ry - 32, 180, ref_label, 20, GOLD, "right"))
        for k, r in enumerate(rows):
            lab, v = r[0], r[1]
            col = r[2] if len(r) > 2 else gm[2]
            cx = x + 30 + slot * (k + 0.5)
            bw = min(slot * 0.6, 110)
            bh = max(3, v / ymax * (base - ptop))
            out.append(f'<div style="position:absolute;left:{cx-bw/2:.0f}px;top:{base-bh:.0f}px;width:{bw:.0f}px;height:{bh:.0f}px;background:{col};border-radius:4px 4px 0px 0px"></div>')
            out.append(p(cx - 70, base - bh - val_size - 14, 140, fmt(v), val_size, "#F5F5F0", "center", 500))
            out.append(p(cx - slot / 2, base + 10, slot, lab, cat_size, "#C8C8C0", "center"))
        out.append(f'<div style="position:absolute;left:{x+30}px;top:{base}px;width:{PW-60}px;height:2px;background:#6A6A6A"></div>')
    return "\n".join(out)


def centered(html, gap=32):
    return f'<div style="flex:1;display:flex;flex-direction:column;justify-content:center;gap:{gap}px">{html}</div>'
