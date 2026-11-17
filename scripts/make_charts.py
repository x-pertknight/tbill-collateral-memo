"""Three charts for the article, made from the saved data (offline). Writes charts/*.png.

Needs matplotlib (not used by build_all.py). Run after build_all.py: python3 scripts/make_charts.py
"""
import json
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.dates as mdates
import matplotlib.ticker
import matplotlib.pyplot as plt

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_all import NY, ROOT, business_days, load  # noqa: E402

OUT = ROOT / "charts"
BLUE, ORANGE, GREY = "#2b6cb0", "#d9822b", "#777777"
plt.rcParams.update({"font.size": 14, "axes.titlesize": 15, "axes.titleweight": "bold", "axes.spines.top": False,
                     "axes.spines.right": False, "figure.dpi": 150, "axes.titlelocation": "left"})
UTC = timezone.utc


def eth_series(times, days):
    """Ethereum supply in millions of tokens at 00:00 UTC on each day, from mint and burn transfers."""
    ev = sorted((times[str(r["block"])], r["value"] if r["from"] == "zero address" else -r["value"])
                for r in load("tbill_transfers.json")["rows"] if r["from"] == "zero address" or r["to"] == "zero address")
    out, i, run = [], 0, 0
    for d in days:
        ts = d.timestamp()
        while i < len(ev) and ev[i][0] <= ts:
            run += ev[i][1]
            i += 1
        out.append(run / 1e12)
    return out


def chart_supply(times):
    bnb = {r["ts"]: r["supply_tokens"] / 1e6 for r in load("other_chains.json")["bnb_daily_supply"]}
    start = datetime(2025, 8, 1, tzinfo=UTC)
    days = [start + timedelta(days=i) for i in range(int((datetime(2026, 11, 17, tzinfo=UTC) - start).days) + 1)]
    eth = eth_series(times, days)
    first_bnb = min(bnb)
    bnb_s = [bnb.get(int(d.timestamp()), None) for d in days]
    last = 0.0
    for i, v in enumerate(bnb_s):                 # BNB is zero before the first read and held between reads
        last = v if v is not None else last
        bnb_s[i] = last if d_ok(days[i], first_bnb) else 0.0
    total = [a + b for a, b in zip(eth, bnb_s)]
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(days, total, color="black", lw=2.2)
    ax.plot(days, eth, color=BLUE, lw=2)
    ax.plot(days, bnb_s, color=ORANGE, lw=2)
    peak = max(eth)
    ax.axhline(peak, color=GREY, ls=":", lw=1.3)
    ax.text(days[0], peak + 4, f"Ethereum peak, {peak:.1f}M", color=GREY, fontsize=12)
    ax.text(days[-1], total[-1] + 9, "Ethereum + BNB Chain", ha="right", va="bottom", fontweight="bold")
    ax.text(days[-1], eth[-1] + 14, "Ethereum", color=BLUE, ha="right", va="center")
    ax.text(days[-1], bnb_s[-1] - 28, "BNB Chain", color=ORANGE, ha="right", va="top", fontsize=12)
    ax.set_title("Supply on Ethereum and BNB Chain together is above\nEthereum's old peak", loc="left")
    ax.set_ylim(0, total[-1] + 35)
    ax.set_ylabel("TBILL tokens (millions)")
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%b %y"))
    ax.set_xlim(days[0], days[-1] + timedelta(days=14))
    ax.xaxis.set_major_locator(mdates.MonthLocator(bymonth=[8, 11, 2, 5]))
    ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig(OUT / "chart1_supply.png")
    plt.close(fig)


def d_ok(day, first_ts):
    return day.timestamp() >= first_ts


def chart_waits(times):
    rows = load("tbill_queue_events.json")["rows"]
    by = {}
    for r in rows:
        by.setdefault(r["id"], {})[r["kind"]] = r
    pts = []
    for v in by.values():
        if "added" in v and "processed" in v:
            t0, t1 = times[str(v["added"]["block"])], times[str(v["processed"]["block"])]
            if datetime.fromtimestamp(t0, UTC).strftime("%Y-%m-%d") >= "2024-12-01":
                pts.append((datetime.fromtimestamp(t0, NY).weekday(), (t1 - t0) / 3600, business_days(t0, t1)))
    fig, ax = plt.subplots(figsize=(8, 5))
    import random
    random.seed(1)
    for wd, h, bd in pts:
        ax.scatter(wd + random.uniform(-0.28, 0.28), h, s=22, color=BLUE if bd <= 1 else ORANGE, alpha=0.6, lw=0)
    ax.set_xticks(range(7), ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
    ax.set_ylabel("Hours from request to settlement")
    ax.set_xlabel("Day the request was made (New York time)")
    ax.set_title("All 200 requests settled by the next US business day;\nthe longest waits began Thursday to Saturday", loc="left")
    ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig(OUT / "chart2_waits.png")
    plt.close(fig)


def chart_comparables():
    res = json.loads((ROOT / "data" / "results.json").read_text())
    c, u = res["comp"], res["derived"]["usdo"]
    names = ["EUTBL, largest market", "USCC, largest market", "USDO and cUSDO, all 3 markets", "TBILL, any chain"]
    vals = [c["eutbl_main"]["supply_usd"], c["uscc_max_supply_usd"], u["supply_usd"], 0]
    fig, ax = plt.subplots(figsize=(8, 3.9))
    ys = list(range(len(names)))[::-1]
    for y, v in zip(ys, vals):
        ax.barh(y, max(v, 0.003), color=BLUE if v else GREY, height=0.55)
        ax.text(max(v, 0.003) * 1.5, y, f"${v:,.2f}" if v < 100 else f"${v:,.0f}", va="center")
    ax.set_xscale("log")
    ax.set_xlim(0.003, 3e10)
    ax.set_yticks(ys, names)
    ax.set_xlabel("US dollars supplied to Morpho markets (log scale)")
    fig.suptitle("Comparable tokens have Morpho markets, mostly small;\nTBILL has none", x=0.02, ha="left", fontsize=15, fontweight="bold")
    ax.set_xticks([0.01, 1, 100, 1e4, 1e6], ["0.01", "1", "100", "10k", "1M"])
    ax.xaxis.set_minor_locator(matplotlib.ticker.NullLocator())
    ax.grid(axis="x", alpha=0.25)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig(OUT / "chart3_comparables.png")
    plt.close(fig)


def chart_summary(times):
    """Portrait phone-feed image 1080 x 1350: supply panel, the rule as three boxes, redemption figures."""
    res = json.loads((ROOT / "data" / "results.json").read_text())
    INK, RED = "#1c1c1c", "#b83232"
    fig = plt.figure(figsize=(10.8, 13.5), dpi=100)
    fig.patch.set_facecolor("white")
    fig.text(0.05, 0.965, "TBILL supply grew across chains.\nMorpho is not on its approved list.", fontsize=35, fontweight="bold",
             va="top", color=INK, linespacing=1.15)
    fig.text(0.05, 0.862, f"OpenEden TBILL as collateral on Morpho. Data as of {datetime.fromisoformat(res['as_of']).strftime('%-d %B %Y')}.",
             fontsize=19, color="#555555", va="top")
    # panel 1: supply
    bnb = {r["ts"]: r["supply_tokens"] / 1e6 for r in load("other_chains.json")["bnb_daily_supply"]}
    start = datetime(2025, 8, 1, tzinfo=UTC)
    days = [start + timedelta(days=i) for i in range(int((datetime(2026, 11, 17, tzinfo=UTC) - start).days) + 1)]
    eth = eth_series(times, days)
    first, last, bnb_s = min(bnb), 0.0, []
    for d in days:
        last = bnb.get(int(d.timestamp()), last)
        bnb_s.append(last if d.timestamp() >= first else 0.0)
    total = [a + b for a, b in zip(eth, bnb_s)]
    fig.text(0.05, 0.808, "Supply, millions of tokens", fontsize=22, fontweight="bold", color=INK)
    fig.text(0.05, 0.778, "Ethereum", fontsize=20, color=BLUE, fontweight="bold")
    fig.text(0.22, 0.778, "BNB Chain", fontsize=20, color=ORANGE, fontweight="bold")
    fig.text(0.40, 0.778, "Ethereum + BNB Chain", fontsize=20, color=INK, fontweight="bold")
    ax = fig.add_axes([0.1, 0.565, 0.82, 0.2])
    ax.plot(days, total, color=INK, lw=4)
    ax.plot(days, eth, color=BLUE, lw=4)
    ax.plot(days, bnb_s, color=ORANGE, lw=4)
    ax.set_ylim(-4, 250)
    ax.set_xlim(days[0], days[-1] + timedelta(days=5))
    ax.set_yticks([0, 100, 200], ["0", "100", "200"])
    ax.set_xticks([days[0], datetime(2026, 5, 1, tzinfo=UTC), days[-1]], ["Aug 2025", "May 2026", "Nov 2026"])
    ax.tick_params(labelsize=17, length=0)
    ax.tick_params(axis="x", pad=14)
    ax.tick_params(axis="y", pad=8)
    for sp in ("left", "bottom"):
        ax.spines[sp].set_visible(False)
    # panel 2: the rule
    fig.text(0.05, 0.488, "The token only moves between approved addresses", fontsize=22, fontweight="bold", color=INK)
    ax2 = fig.add_axes([0.05, 0.29, 0.9, 0.18])
    ax2.axis("off")
    ax2.set_xlim(0, 3.1)
    ax2.set_ylim(0, 1)
    boxes = [("Borrower", "would need to\nbe approved", "?", "#777777"),
             ("Morpho's\nlending contract", "not on the list", "\u2717", RED),
             ("Whoever takes\nover a bad loan", f"none of {res['liq']['top_tested']} tested\nis on the list", "\u2717", RED)]
    for i, (name, note, mark, col) in enumerate(boxes):
        x = i * 1.05
        ax2.add_patch(plt.Rectangle((x, 0.22), 0.95, 0.78, fill=False, ec=col, lw=3))
        ax2.text(x + 0.475, 0.80, name, ha="center", va="center", fontsize=17, fontweight="bold", color=INK)
        ax2.text(x + 0.475, 0.50, mark, ha="center", va="center", fontsize=34, color=col, fontweight="bold")
        ax2.text(x + 0.475, 0.07, note, ha="center", va="center", fontsize=16, color=col)
        if i < 2:
            ax2.annotate("", xy=(x + 1.05, 0.6), xytext=(x + 0.95, 0.6), arrowprops=dict(arrowstyle="->", color="#777777", lw=2))
    # panel 3: redemptions
    fig.text(0.05, 0.235, "Redemptions", fontsize=22, fontweight="bold", color=INK)
    q = res["queue"]
    fig.text(0.05, 0.190, f"{q['paired_requests']} of {q['paired_requests']}", fontsize=64, fontweight="bold", color=BLUE, va="center")
    fig.text(0.05, 0.128, "matched requests settled\nby the next US business day", fontsize=19, color=INK, va="center", linespacing=1.2)
    fig.text(0.56, 0.190, "under 1 in 10", fontsize=38, fontweight="bold", color=ORANGE, va="center")
    fig.text(0.56, 0.128, "requests since December\n2024 are not in that record:\ncancelled or no matched payout", fontsize=19, color=INK, va="center", linespacing=1.2)
    fig.text(0.05, 0.045, "Marco Amendola \u00b7 data and code: github.com/x-pertknight/tbill-collateral-memo", fontsize=16.5, color="#555555")
    fig.savefig(OUT / "summary.png", dpi=100, facecolor="white")
    plt.close(fig)


def main():
    OUT.mkdir(exist_ok=True)
    times = load("block_times.json")
    chart_supply(times)
    chart_waits(times)
    chart_comparables()
    print("wrote", ", ".join(sorted(p.name for p in OUT.glob("*.png"))))


if __name__ == "__main__":
    main()
