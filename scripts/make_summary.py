"""Summary image for the post, charts/summary.png (1080 x 1350, phone feed), in the series design.

Pure SVG rendered by headless Chrome (same method, font and sizes as the Study 4 image). Every figure comes from
data/results.json, rounded as in post.md.   Run: python3 scripts/make_summary.py   (after build_all.py)
"""
import json
import os
import subprocess
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CHROME = os.environ.get("TBILL_CHROME", "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")
INK, SOFT, GRID, GREY_TEXT = "#1c1c1c", "#555555", "#e3e3e3", "#4a535c"
GREY, ORANGE, BLUE = "#9aa3ad", "#d9822b", "#2a6fb0"


def text(x, y, s, size=27, fill=INK, anchor="start", weight="normal"):
    return f'<text x="{x}" y="{y}" font-size="{size}" fill="{fill}" text-anchor="{anchor}" font-weight="{weight}">{s}</text>'


def box(x, y, w, h, name, mark, note, color):
    """One box of the rule picture: name, a mark (cross or question mark) and a one-line note underneath."""
    out = [f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="white" stroke="{color}" stroke-width="5"/>']
    a, b = name
    out += [text(x + w / 2, y + 42, a, 26, INK, "middle", "bold"), text(x + w / 2, y + 74, b, 26, INK, "middle", "bold")]
    cx, cy = x + w / 2, y + 112
    if mark == "x":
        out += [f'<line x1="{cx - 16}" y1="{cy - 16}" x2="{cx + 16}" y2="{cy + 16}" stroke="{color}" stroke-width="8" stroke-linecap="round"/>',
                f'<line x1="{cx - 16}" y1="{cy + 16}" x2="{cx + 16}" y2="{cy - 16}" stroke="{color}" stroke-width="8" stroke-linecap="round"/>']
    else:
        out.append(text(cx, cy + 20, "?", 56, color, "middle", "bold"))
    a, b = note
    out += [text(x + w / 2, y + h + 38, a, 24, color if color != GREY else GREY_TEXT, "middle", "bold"),
            text(x + w / 2, y + h + 68, b, 24, color if color != GREY else GREY_TEXT, "middle", "bold")]
    return out


def build():
    r = json.loads((ROOT / "data" / "results.json").read_text())
    c, q, s, liq = r["chains"], r["queue"], r["supply"], r["liq"]
    as_of = datetime.fromisoformat(r["as_of"]).strftime("%-d %B %Y")
    since = datetime.fromisoformat(q["paired_from"]).strftime("%B %Y")
    w, h, m = 1080, 1350, 60
    p = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" font-family="Helvetica, Arial, sans-serif">',
         f'<rect width="{w}" height="{h}" fill="white"/>',
         text(m, 110, "What TBILL needs to be", 62, INK, weight="bold"), text(m, 182, "collateral on Morpho", 62, INK, weight="bold"),
         text(m, 236, f"OpenEden TBILL, data as of {as_of}", 28, SOFT)]
    # section 1: the rule
    p += [text(m, 320, "The token only moves between", 44, INK, weight="bold"), text(m, 372, "approved addresses", 44, INK, weight="bold")]
    bw, gap, by, bh = 300, 30, 405, 150
    p += box(m, by, bw, bh, ("Borrower", ""), "?", ("would need to", "be approved"), GREY)
    p += box(m + bw + gap, by, bw, bh, ("Morpho’s", "lending contract"), "x", ("not on the", "issuer’s list"), ORANGE)
    p += box(m + 2 * (bw + gap), by, bw, bh, ("Whoever takes", "over a bad loan"), "x", (f"none of {liq['top_tested']} tested", "is on the list"), ORANGE)
    # section 2: supply, as two figures
    p.append(text(m, 700, "Supply grew across chains", 44, INK, weight="bold"))
    p += [text(m, 810, f"{c['two_chain_first_m']:.0f}M → {c['two_chain_now_m']:.0f}M", 76, BLUE, weight="bold"),
          text(m, 858, "Ethereum and BNB Chain together,", 27), text(m, 892, f"{datetime.fromisoformat(c['two_chain_first_date']).strftime('%B %Y')} to now", 27),
          text(m + 500, 810, f"−{s['fall_vs_peak_pct']:.0f}%", 96, ORANGE, weight="bold"),
          text(m + 500, 858, "Ethereum alone, from its", 27), text(m + 500, 892, f"{datetime.fromisoformat(s['peak_date']).strftime('%B %Y')} peak", 27)]
    # section 3: redemptions
    p.append(text(m, 1010, "Redemptions", 44, INK, weight="bold"))
    p += [text(m, 1120, f"{q['paired_requests']} of {q['paired_requests']}", 84, BLUE, weight="bold"),
          text(m, 1168, "matched requests settled by", 27), text(m, 1202, "the next US business day", 27),
          text(m + 500, 1120, "under 1 in 10", 58, ORANGE, weight="bold"),
          text(m + 500, 1168, f"requests since {since} are", 27), text(m + 500, 1202, "not in that record", 27)]
    p.append(f'<line x1="{m}" x2="{w - m}" y1="1262" y2="1262" stroke="{GRID}" stroke-width="2"/>')
    p.append(text(m, 1310, "Marco Amendola · data and code: github.com/x-pertknight/tbill-collateral-memo", 26, SOFT))
    p.append("</svg>")
    return "\n".join(p)


def main():
    out = ROOT / "charts"
    out.mkdir(exist_ok=True)
    svg = out / "summary.svg"
    svg.write_text(build())
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--window-size=1080,1350",
                    f"--screenshot={out / 'summary.png'}", "file://" + str(svg)], check=True, capture_output=True)
    print("wrote", out / "summary.png")


if __name__ == "__main__":
    main()
