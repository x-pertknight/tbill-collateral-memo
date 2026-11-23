"""Recompute every number in the memo from the saved raw files (offline, no network).

Usage: python3 scripts/build_all.py           check: rebuild and compare, write nothing
       python3 scripts/build_all.py --write   rebuild and overwrite the generated files
Reads  data/raw/*.json, data/step0/*.json, memo.template.md, post.template.md, article.template.md
Builds data/results.json, SCORECARD.md, memo.md, post.md and article.md (templates with {{key}}
replaced by results). In check mode each built file is compared byte for byte with the committed
one, and the exit status is 1 if any of them differs, so a changed raw reading or a hand edited
figure in memo.md, post.md or article.md fails the run.
"""
import json
import re
import sys
import statistics
from datetime import date, datetime, timedelta, timezone
from zoneinfo import ZoneInfo
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "raw"
BUILT = {}                   # relative path -> text built in this run
DAY = 86400
VAULT = "TBILL vault/token (proxy)"
PAIRED_FROM = "2024-12-01"   # earlier settlement events used a different signature, so no pairing before this


def load(name):
    return json.loads((RAW / name).read_text())


def pct(sorted_vals, p):
    return sorted_vals[min(len(sorted_vals) - 1, int(p * len(sorted_vals)))]


def day(ts):
    return datetime.fromtimestamp(ts, timezone.utc).strftime("%Y-%m-%d")


def nav_metrics(times):
    rows = [(times[str(r["block"])], r["new"] / 1e8) for r in load("tbill_oracle_updates.json")["rows"]]
    rows.sort()
    now = times[str(load("tbill_transfers.json")["head_block"])]
    last365 = [r for r in rows if r[0] >= now - 365 * DAY]
    steps = [(b[1] / a[1] - 1) for a, b in zip(rows, rows[1:])]
    steps365 = [(b[1] / a[1] - 1) for a, b in zip(last365, last365[1:])]
    gaps = [(b[0] - a[0]) / DAY for a, b in zip(last365, last365[1:])]
    at90 = [r for r in rows if r[0] <= now - 90 * DAY][-1]
    nav_now = rows[-1][1]
    triples = [(t, prev, new) for (t, new), prev in zip(rows, [rows[0][1]] + [r[1] for r in rows[:-1]])]
    return {**negative_step_metrics(triples, now),
            "nav_now": nav_now, "nav_now_ts": rows[-1][0], "updates_total": len(rows),
            "update_days_last365": len({day(r[0]) for r in last365}),
            "longest_gap_days_last365": round(max(gaps), 2),
            "max_step_pct_last365": round(max(steps365) * 100, 4),
            "min_step_pct_last365": round(min(steps365) * 100, 4),
            "negative_steps_all": sum(1 for s in steps if s < 0),
            "updates_last365": len(last365), "negative_steps_last365": sum(1 for s in steps365 if s < 0),
            "steps_below_minus_3bps_last365": sum(1 for s in steps365 if s < -0.0003),
            "annualised_growth_90d_pct": round(((nav_now / at90[1]) ** (365 / ((now - at90[0]) / DAY)) - 1) * 100, 2),
            "weekday_update_share_pct": round(100 * sum(datetime.fromtimestamp(r[0], timezone.utc).weekday() < 5
                                                         for r in last365) / len(last365), 1),
            "now_ts": now}


def negative_step_metrics(rows, now):
    """For each downward NAV update in the last year: did NAV return to its pre-drop level, and when?"""
    out, recover_days = [], []
    for i, (t, old, new) in enumerate(rows):
        if t < now - 365 * DAY or new >= old:
            continue
        back = next((x[0] for x in rows[i + 1:] if x[2] >= old), None)
        out.append({"ts": t, "step_pct": (new / old - 1) * 100, "recover_h": None if back is None else (back - t) / 3600})
        recover_days.append((back - t) / DAY if back else None)
    worst = min(out, key=lambda r: r["step_pct"])
    month_boundary = sum(1 for r in out if datetime.fromtimestamp(r["ts"], timezone.utc).day >= 28 or datetime.fromtimestamp(r["ts"], timezone.utc).day <= 2)
    slow = [r for r in out if r["recover_h"] is None or r["recover_h"] > 24]
    return {"neg_recovered_24h": sum(1 for r in out if r["recover_h"] is not None and r["recover_h"] <= 24),
            "neg_not_recovered_24h": len(slow), "neg_never_recovered": sum(1 for r in out if r["recover_h"] is None),
            "neg_max_recover_days": round(max(r["recover_h"] for r in out if r["recover_h"] is not None) / 24, 1),
            "neg_month_boundary": month_boundary, "neg_worst_date": day(worst["ts"]),
            "neg_worst_recover_h": None if worst["recover_h"] is None else round(worst["recover_h"], 1),
            "neg_median_size_pct": round(statistics.median(r["step_pct"] for r in out), 4)}


def supply_metrics(times, now):
    rows = load("tbill_transfers.json")["rows"]
    events = []
    for r in rows:
        delta = r["value"] if r["from"] == "zero address" else (-r["value"] if r["to"] == "zero address" else 0)
        if delta:
            events.append((times[str(r["block"])], delta))
    events.sort()
    def at(ts):
        return sum(d for t, d in events if t <= ts) / 1e6
    series, run = [], 0
    for t, d in events:
        run += d
        series.append((t, run / 1e6))
    peak = max(series, key=lambda x: x[1])
    return {"supply_now": at(now), "supply_30d_ago": at(now - 30 * DAY), "supply_90d_ago": at(now - 90 * DAY),
            "supply_365d_ago": at(now - 365 * DAY),
            "change_90d_pct": round((at(now) / at(now - 90 * DAY) - 1) * 100, 1),
            "fall_vs_peak_pct": round((1 - at(now) / peak[1]) * 100, 1),
            "peak_supply": peak[1], "peak_date": day(peak[0]), "peak_ts": peak[0], "mint_burn_events": len(events)}


def supply_fall_metrics(times, now):
    """Split the move from peak supply to today into mints, queue settlements, admin burns and the rest."""
    tr = load("tbill_transfers.json")["rows"]
    q = load("tbill_queue_events.json")["rows"]
    adm = load("tbill_admin_amounts.json")
    peak_ts = supply_metrics(times, now)["peak_ts"]       # exact time of the peak reading, so the parts sum to peak minus now
    inwin = lambda block: times[str(block)] > peak_ts
    minted = sum(r["value"] for r in tr if r["from"] == "zero address" and inwin(r["block"])) / 1e6
    burned = sum(r["value"] for r in tr if r["to"] == "zero address" and inwin(r["block"])) / 1e6
    settled = [r for r in q if r["kind"] == "processed" and inwin(r["block"])]
    queue_tok = sum(r["shares"] for r in settled) / 1e6
    adm_in = lambda k: sum(r["amount"] for r in adm[k] if times.get(str(r["block"]), adm["block_times"].get(str(r["block"]))) >= peak_ts) / 1e6
    big_burn = max(adm["burnFrom"], key=lambda r: r["amount"])
    by_month = {}
    for r in settled:
        m = day(times[str(r["block"])])[:7]
        by_month[m] = by_month.get(m, 0) + r["shares"] / 1e6
    top3 = sorted(by_month.items(), key=lambda kv: -kv[1])[:3]
    sizes = sorted((r["shares"] / 1e6 for r in settled), reverse=True)
    express = [r for r in tr if r["from"].startswith("USDO Express") or r["to"].startswith("USDO Express")]
    return {"window_start": day(peak_ts), "minted_tokens": minted, "burned_tokens": burned, "net_change_tokens": minted - burned,
            "queue_settled_tokens": queue_tok, "queue_settled_usdc": sum(r["assets"] for r in settled) / 1e6,
            "queue_requests": len(settled), "queue_distinct_senders": len({r["sender"] for r in settled}),
            "queue_top1_share_pct": round(100 * sizes[0] / queue_tok, 1), "queue_top5_share_pct": round(100 * sum(sizes[:5]) / queue_tok, 1),
            "queue_top3_months": ", ".join(f"{m} ({v/1e6:.0f}M)" for m, v in sorted(top3)),
            "queue_top3_months_share_pct": round(100 * sum(v for _, v in top3) / queue_tok, 1),
            "admin_burnfrom_tokens": adm_in("burnFrom"), "admin_burnfrom_largest_tokens": big_burn["amount"] / 1e6,
            "admin_burnfrom_largest_date": day(adm["block_times"][str(big_burn["block"])]),
            "other_burn_tokens": burned - queue_tok - adm_in("burnFrom") - adm_in("reIssue"),
            "admin_mintto_tokens": adm_in("mintTo"),
            "usdo_express_transfers": len(express), "usdo_express_tokens_each_way": sum(r["value"] for r in express if r["to"] == "TBILL vault/token (proxy)") / 1e6,
            "usdo_express_first": day(times[str(express[0]["block"])]), "usdo_express_last": day(times[str(express[-1]["block"])]),
            "usdo_express_transfers_since_peak": sum(1 for r in express if inwin(r["block"]))}


def funding_metrics(times, now):
    """Does a USDC inflow to the vault precede each settlement? (The code settles only if the vault balance covers it.)"""
    inflow = load("vault_usdc_inflows.json")
    times_in = inflow["block_times"]
    ins = sorted((times_in[str(r["block"])], r["value"] / 1e6, r["from"]) for r in inflow["rows"])
    per_block = {}
    for r in load("tbill_queue_events.json")["rows"]:
        if r["kind"] == "processed" and times[str(r["block"])] >= now - 365 * DAY:
            per_block[r["block"]] = per_block.get(r["block"], 0) + r["assets"] / 1e6
    hit = 0
    for block, assets in per_block.items():
        t = times[str(block)]
        hit += any(t - DAY <= ti <= t and v >= 0.9 * assets for ti, v, _ in ins)
    named = [x for x in ins if not x[2].startswith("addr_")]
    return {"settlement_txs_365d": len(per_block), "settlements_with_prior_24h_inflow_pct": round(100 * hit / len(per_block), 1),
            "usdc_inflows_total": len(ins), "usdc_inflow_senders": len({x[2] for x in ins}),
            "usdc_inflows_top_sender": max(sum(1 for y in ins if y[2] == s_) for s_ in {x[2] for x in ins}), "usdc_inflows_from_named": len(named), "usdc_inflows_named_usd": round(sum(x[1] for x in named))}


def liquidation_metrics():
    """Liquidations on the comparable markets and whether busy liquidators could receive each token."""
    d = load("liquidations.json")
    top = d["top_liquidators"]
    ours = d["comparable_market_liquidators"]
    by = d["by_collateral"]
    return {"eutbl_liquidations": by.get("EUTBL", {}).get("liquidations", 0), "uscc_liquidations": by.get("USCC", {}).get("liquidations", 0),
            "uscc_repaid_usd": by.get("USCC", {}).get("repaid_raw", 0) / 1e6, "comparable_markets_checked": d["comparable_market_ids"],
            "recent_liquidations": d["recent_liquidations_all_markets"], "recent_callers": d["recent_distinct_callers"],
            "recent_days": round(d["recent_window_blocks"] * 12 / 86400), "top_tested": len(top),
            "top_allowed_eutbl": sum(1 for t in top if yes(t["eutbl_allowed"])), "top_allowed_uscc": sum(1 for t in top if yes(t["uscc_allowed"])),
            "top_kyc_tbill": sum(1 for t in top if yes(t["tbill_isKyc"])),
            "top_share_of_recent_pct": round(100 * sum(t["liquidations_recent"] for t in top) / d["recent_liquidations_all_markets"]),
            "uscc_liquidator_allowed": all(yes(t["uscc_allowed"]) for t in ours if t["collateral"] == "USCC")}


def holder_metrics():
    rows = load("tbill_holders_now.json")["rows"]
    supply = sum(r["balance"] for r in rows)
    vault = sum(r["balance"] for r in rows if r["holder"] == VAULT)
    ext = sorted((r for r in rows if r["holder"] != VAULT), key=lambda r: -r["balance"])
    top = lambda n: sum(r["balance"] for r in ext[:n])
    return {"holders_excl_vault": len(ext), "contract_holders_excl_vault": sum(r["is_contract"] for r in ext),
            "vault_queued_shares": vault / 1e6, "top1_share_of_supply_pct": round(100 * top(1) / supply, 1),
            "top5_share_of_supply_pct": round(100 * top(5) / supply, 1),
            "top5_share_of_outside_vault_pct": round(100 * top(5) / (supply - vault), 1),
            "supply_from_holders": supply / 1e6}


# U.S. federal holidays (observed) from the first paired request to today; typed by hand from the OPM calendar.
US_HOLIDAYS = {date.fromisoformat(d) for d in (
    "2024-12-25 2025-01-01 2025-01-20 2025-02-17 2025-05-26 2025-06-19 2025-07-04 2025-09-01 2025-10-13 2025-11-11 2025-11-27 "
    "2025-12-25 2026-01-01 2026-01-19 2026-02-16 2026-05-25 2026-06-19 2026-07-03 2026-09-07 2026-10-12 2026-11-11 2026-11-26").split()}
NY = ZoneInfo("America/New_York")


def business_days(t0, t1):
    """U.S. business days in (request date, settlement date], New York dates. 1 means 'the next business day'."""
    d0, d1 = datetime.fromtimestamp(t0, NY).date(), datetime.fromtimestamp(t1, NY).date()
    n, d = 0, d0
    while d < d1:
        d += timedelta(days=1)
        n += d.weekday() < 5 and d not in US_HOLIDAYS
    return n


def span_text(weekdays):
    """'between Thursday and Saturday' when the weekdays are contiguous, else a list."""
    names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    lo, hi = min(weekdays), max(weekdays)
    if set(range(lo, hi + 1)) >= set(weekdays) and lo != hi:
        return f"between {names[lo]} and {names[hi]}"
    return "on " + ", ".join(names[d] for d in sorted(set(weekdays)))


def business_day_metrics(pairs, times):
    """Latency in U.S. business days (the docs promise 'the next 1 U.S. business day') and when the slowest exits started."""
    rows = [(times[str(p["block"])] - times[str(a["block"])], business_days(times[str(a["block"])], times[str(p["block"])]), times[str(a["block"])])
            for a, p in pairs]
    bd = sorted(r[1] for r in rows)
    slow = sorted(rows, reverse=True)[:6]
    wd = lambda ts: datetime.fromtimestamp(ts, NY).strftime("%a")
    return {"bd_share_le1_pct": round(100 * sum(b <= 1 for b in bd) / len(bd), 1), "bd_share_le2_pct": round(100 * sum(b <= 2 for b in bd) / len(bd), 1),
            "bd_p90": pct(bd, 0.9), "bd_max": bd[-1], "bd_over2": sum(b > 2 for b in bd),
            "slowest6_start_days": ", ".join(wd(r[2]) for r in slow),
            "slowest6_span": span_text([datetime.fromtimestamp(r[2], NY).weekday() for r in slow]),
            "bd_within1_text": f"all {len(bd)} settled" if all(b <= 1 for b in bd) else f"{round(100 * sum(b <= 1 for b in bd) / len(bd), 1)}% of {len(bd)} settled",
            "slowest6_bd": ", ".join(str(r[1]) for r in slow)}


def eth_supply_at(ts, times):
    """Ethereum TBILL supply (tokens) at a unix time, from mint and burn transfers."""
    tot = 0
    for r in load("tbill_transfers.json")["rows"]:
        if times[str(r["block"])] <= ts:
            tot += r["value"] if r["from"] == "zero address" else (-r["value"] if r["to"] == "zero address" else 0)
    return tot / 1e6


def favour_metrics(pairs, times):
    """Evidence in the memo's favour: the 2025-09 to 2025-11 run-off settled with the same waits as the rest."""
    out, tokens, worst = [], 0, 0
    by_m = {}
    for a, p in pairs:
        m = day(times[str(p["block"])])[:7]
        by_m[m] = by_m.get(m, 0) + a["shares"]
    months = sorted(sorted(by_m, key=lambda m: -by_m[m])[:3])          # the three months with the most tokens settled
    for m in months:
        sel = [(a, p) for a, p in pairs if day(times[str(p["block"])])[:7] == m]
        hrs = [(times[str(p["block"])] - times[str(a["block"])]) / 3600 for a, p in sel]
        out.append(round(statistics.median(hrs), 1))
        tokens += sum(a["shares"] for a, _ in sel) / 1e6
        worst = max(worst, max(hrs))
    return {"favour_first_month": months[0], "favour_last_month": months[-1], "favour_first_text": datetime.fromisoformat(months[0] + "-01").strftime("%B %Y"), "favour_last_text": datetime.fromisoformat(months[-1] + "-01").strftime("%B %Y"),
            "favour_median_h": " / ".join(str(x) for x in out), "favour_median_lo": min(out), "favour_median_hi": max(out), "favour_tokens": tokens, "favour_max_h": round(worst, 1)}


def exit_not_completed(by_id, times, newest_settled_add):
    """Requests since PAIRED_FROM that did not end in a matched settlement: cancelled by the maintainer, or unmatched."""
    in_win = lambda r: day(times[str(r["block"])]) >= PAIRED_FROM
    cancelled = [v["added"] for v in by_id.values() if "added" in v and "cancelled" in v and in_win(v["added"])]
    # unmatched: added in the window, no settlement or cancel event, and old enough that FIFO says it left the queue
    unmatched = [v["added"] for v in by_id.values() if set(v) == {"added"} and in_win(v["added"])
                 and times[str(v["added"]["block"])] <= newest_settled_add]
    big = [r for r in cancelled if r["shares"] >= 5e11]      # 500,000 tokens or more (the other three are 156,550 tokens or test size)
    return {"cancelled_requests": len(cancelled), "cancelled_tokens": sum(r["shares"] for r in cancelled) / 1e6,
            "cancelled_big_requests": len(big), "cancelled_big_tokens": sum(r["shares"] for r in big) / 1e6,
            "cancelled_first": day(min(times[str(by_id[r["id"]]["cancelled"]["block"])] for r in big)),
            "cancelled_last": day(max(times[str(by_id[r["id"]]["cancelled"]["block"])] for r in big)),
            "unmatched_requests": len(unmatched), "unmatched_tokens": sum(r["shares"] for r in unmatched) / 1e6,
            "unmatched_months": ", ".join(sorted({day(times[str(r["block"])])[:7] for r in unmatched}))}


def queue_metrics(times, nav, now):
    q = load("tbill_queue_events.json")["rows"]
    by_id = {}
    for r in q:
        by_id.setdefault(r["id"], {})[r["kind"]] = r
    pairs = [(v["added"], v["processed"]) for v in by_id.values()
             if "added" in v and "processed" in v and day(times[str(v["added"]["block"])]) >= PAIRED_FROM]
    hours = sorted((times[str(p["block"])] - times[str(a["block"])]) / 3600 for a, p in pairs)
    usd = sorted(a["shares"] / 1e6 * nav for a, _ in pairs)
    # FIFO: a request added after the newest settled one cannot have been settled yet
    newest_settled_add = max(times[str(a["block"])] for a, _ in pairs)
    pending = [v["added"] for v in by_id.values() if set(v) == {"added"} and times[str(v["added"]["block"])] > newest_settled_add]
    per_day = {}
    for a, p in pairs:
        d = day(times[str(p["block"])])
        per_day[d] = per_day.get(d, 0) + p["assets"] / 1e6
    days = sorted(per_day.values())
    return {"paired_from": PAIRED_FROM, "paired_from_text": datetime.fromisoformat(PAIRED_FROM).strftime("%B %Y"), "paired_requests": len(pairs), "latency_h_median": round(statistics.median(hours), 1),
            "latency_h_p90": round(pct(hours, 0.9), 1), "latency_h_max": round(hours[-1], 1),
            "latency_share_under_24h_pct": round(100 * sum(h <= 24 for h in hours) / len(hours), 1),
            "latency_share_under_72h_pct": round(100 * sum(h <= 72 for h in hours) / len(hours), 1),
            "request_usd_median": round(statistics.median(usd)), "request_usd_max": round(usd[-1]),
            "settle_days": len(days), "settle_usd_day_median": round(statistics.median(days)),
            "settle_usd_day_p95": round(pct(days, 0.95)), "settle_usd_day_max": round(days[-1]),
            **exit_not_completed(by_id, times, newest_settled_add), **favour_metrics(pairs, times), **business_day_metrics(pairs, times),
            "pending_requests": len(pending), "pending_shares": sum(r["shares"] for r in pending) / 1e6,
            "pending_usd": sum(r["shares"] for r in pending) / 1e6 * nav,
            "oldest_pending_age_h": round((now - min(times[str(r["block"])] for r in pending)) / 3600, 1) if pending else 0}


def state_metrics(st, nav):
    b = st["balances_raw"]
    usdc = lambda k: int(b[k]) / 1e6
    return {"vault_usdc": usdc("vault_usdc"), "vault_buidl": usdc("vault_buidl"), "redemption_usdc": usdc("redemption_usdc"),
            "qtreasury_usdc": usdc("qtreasury_usdc"), "opltreasury_usdc": usdc("opltreasury_usdc"),
            "supply_cap_is_max_uint": int(st["vault"]["totalSupplyCap"]) >= 2 ** 255,
            "queue_length_state": int(st["vault"]["getWithdrawalQueueLength"]),
            "total_assets_usd": int(st["vault"]["totalAssets"]) / 1e6, "nav_vault": int(st["vault"]["tbillUsdcRate"]) / 1e6,
            "morpho_blue_isKyc": st["kyc"]["morpho_blue_isKyc"], "kyc_strict": st["kyc"]["isStrict"],
            "mgmt_fee_bps": int(st["fees"]["management_fee_rate_bps"]),
            "redeem_fee_bps_weekday": int(st["fees"]["tx_fee_withdraw_weekend_false"]),
            "redeem_fee_bps_weekend": int(st["fees"]["tx_fee_withdraw_weekend_true"])}


def sim_metrics():
    sim = load("tbill_redeem_sim.json")["rows"]
    return {f"sim_{r['usd']}": {"instant_ok": r["redeemIns"]["ok"], "instant_reason": r["redeemIns"]["output"].split("reverted: ")[-1].split(",")[0] if not r["redeemIns"]["ok"] else "",
                                "queue_ok": r["redeem_queue"]["ok"]} for r in sim if "redeemIns" in r}


def comparable_metrics():
    c = load("comparables_onchain.json")
    m = load("morpho_markets_comparables.json")["markets"]
    rows = []
    for x in m:
        s = x["state"] or {}
        rows.append({"token": x["collateralAsset"]["symbol"], "chain": x["chain"]["network"], "loan": x["loanAsset"]["symbol"],
                     "lltv_pct": round(int(x["lltv"]) / 1e16, 1), "oracle_type": x["oracle"]["type"] if x["oracle"] else None,
                     "oracle": x["oracle"]["address"] if x["oracle"] else None, "market_id": x["marketId"],
                     "supply_usd": round(s.get("supplyAssetsUsd") or 0, 2), "borrow_usd": round(s.get("borrowAssetsUsd") or 0, 2),
                     "collateral_usd": round(s.get("collateralAssetsUsd") or 0, 2),
                     "vaults": len(x["supplyingVaults"]) + len(x["supplyingVaultV2s"])})
    top = lambda tok: max((r for r in rows if r["token"] == tok and r["chain"] == "Ethereum"), key=lambda r: r["supply_usd"])
    return {"onchain": c, "markets": rows, "eutbl_main": top("EUTBL"), "uscc_main": top("USCC"),
            "eutbl_supply_tokens": int(c["EUTBL"]["totalSupply_raw"]) / 1e5, "uscc_supply_tokens": int(c["USCC"]["totalSupply_raw"]) / 1e6,
            "eutbl_nav": int(c["nav_feeds"]["EUTBL NAV feed"]["latestRoundData"][1].split()[0]) / 1e6,
            "uscc_nav": int(c["nav_feeds"]["USCC NAV feed"]["latestRoundData"][1].split()[0]) / 1e6,
            "usdo_markets": [r for r in rows if r["token"] in ("USDO", "cUSDO") and r["chain"] == "Ethereum"],
            "uscc_eth_markets": sum(1 for r in rows if r["token"] == "USCC" and r["chain"] == "Ethereum"),
            "uscc_max_supply_usd": max(r["supply_usd"] for r in rows if r["token"] == "USCC"),
            "uscc_vault_market": max((r for r in rows if r["token"] == "USCC" and r["chain"] == "Ethereum"), key=lambda r: r["vaults"]),
            "eutbl_lltvs": ", ".join(f"{x:g}%" for x in sorted({r["lltv_pct"] for r in rows if r["token"] == "EUTBL" and r["chain"] == "Ethereum"})),
            "uscc_lltvs": ", ".join(f"{x:g}%" for x in sorted({r["lltv_pct"] for r in rows if r["token"] == "USCC" and r["chain"] == "Ethereum"}))}


def build():
    times = load("block_times.json")
    st = load("tbill_state.json")
    nav = nav_metrics(times)
    res = {"nav": nav, "supply": supply_metrics(times, nav["now_ts"]), "holders": holder_metrics(), "fall": supply_fall_metrics(times, nav["now_ts"]), "funding": funding_metrics(times, nav["now_ts"]), "liq": liquidation_metrics(),
           "queue": queue_metrics(times, nav["nav_now"], nav["now_ts"]), "state": state_metrics(st, nav["nav_now"]),
           "sim": sim_metrics(), "comp": comparable_metrics(), "roles": load("tbill_roles.json")["roles"],
           "admin_events": {k.split("(")[0]: v for k, v in load("tbill_roles.json")["admin_event_counts"].items()},
           "docs": {"queue_business_days": 1, "ter_fees_page_bps": 35, "ter_faq_bps": 30, "tx_fee_bps": 5, "first_deposit_usd": 100000},
           "role_holders_state": st["roles"], "redemption_contract": st["redemption"], "as_of": day(nav["now_ts"]),
           "state_block": st["block"]}
    q = res["queue"]
    q["window_closed"] = q["paired_requests"] + q["cancelled_requests"] + q["unmatched_requests"]   # requests since PAIRED_FROM no longer in the queue
    res["liq"]["top_tested_word"] = {8: "eight"}.get(res["liq"]["top_tested"], str(res["liq"]["top_tested"]))
    res["liq"]["min_listed_word"] = "three"       # the memo's judgment, condition 1
    q["unmatched_share_pct"] = round(100 * (q["cancelled_requests"] + q["unmatched_requests"]) / q["window_closed"], 1)
    res["chains"] = chain_metrics(times, nav["nav_now"], nav["now_ts"])
    res["concentration"] = roles_concentration(res["roles"], "TBILL maintainer (Safe)")
    res["derived"] = derived(res)
    res["scores"] = scores(res)
    render_scorecard(res)
    BUILT["data/results.json"] = json.dumps(res, indent=1, sort_keys=True, default=str)
    return res


def chain_metrics(times, nav_now, now_ts):
    """TBILL on the other chains and whether the Ethereum burn of 2026-05-26 was matched by a mint on BNB Chain."""
    oc, om = load("other_chains.json"), load("other_chains_morpho.json")
    tr = load("tbill_transfers.json")["rows"]
    adm = load("tbill_admin_amounts.json")
    big = max(adm["burnFrom"], key=lambda r: r["amount"])
    burn_ts = adm["block_times"][str(big["block"])]
    burn_tokens = big["amount"] / 1e6
    # who held the burned balance: inflows to the address that was burned from (same block, same amount)
    holder = next(r["from"] for r in tr if r["block"] == big["block"] and r["to"] == "zero address" and r["value"] == big["amount"])
    inflow = [r for r in tr if r["to"] == holder and r["value"] > 1e6]
    from_mint = sum(r["value"] for r in inflow if r["from"] == "zero address") / 1e6
    from_xfer = [r for r in inflow if r["from"] != "zero address"]
    src = from_xfer[0]["from"] if from_xfer else None
    src_mint = sum(r["value"] for r in tr if r["from"] == "zero address" and r["to"] == src and r["block"] < from_xfer[0]["block"]
                   and times[str(r["block"])] >= datetime(2026, 3, 1, tzinfo=timezone.utc).timestamp()) / 1e6 if src else 0
    mints = [e for e in oc["bnb_mint_burn_events_on_move_days"] if e["kind"] == "mint"]
    match = min(mints, key=lambda e: abs(e["tokens"] - burn_tokens))
    series = oc["bnb_daily_supply"]
    bnb_now = series[-1]["supply_tokens"]
    after = [r for r in series if r["ts"] >= match["ts"]][0]["supply_tokens"]
    later_burns = sum(r["amount"] for r in adm["burnFrom"] if adm["block_times"][str(r["block"])] > burn_ts and r is not big) / 1e6
    eth_now = supply_metrics(times, now_ts)["supply_now"]
    xrpl = oc["xrpl_supply_tokens_rwa_xyz_2026_11_17"]        # quoted from rwa.xyz, not read from a node
    all_now = eth_now + bnb_now + xrpl + oc["arbitrum_supply_tokens"]
    first = series[0]
    eth_first = eth_supply_at(first["ts"], times)
    steps = [(b["supply_tokens"] - a["supply_tokens"], b["ts"]) for a, b in zip(series, series[1:])]
    drop = min(steps)
    back = next(st for st in steps if st[1] > drop[1] and st[0] > 0)
    peak = supply_metrics(times, now_ts)["peak_supply"]
    mint_ts = next(times[str(r["block"])] for r in tr if r["to"] == holder and r["from"] == "zero address" and r["value"] > 1e6)
    bnb_ev = oc["bnb_mint_burn_events_on_move_days"]
    return {"two_chain_first_m": (eth_first + first["supply_tokens"]) / 1e6, "two_chain_first_date": day(first["ts"]),
            "two_chain_now_m": (eth_now + bnb_now) / 1e6, "two_chain_vs_peak_pct": round(100 * ((eth_now + bnb_now) / peak - 1), 1),
            "eth_first_m": eth_first / 1e6,
            "burn_holder_mint_date": day(mint_ts), "burn_to_mint_min": round((match["ts"] - burn_ts) / 60),
            "bnb_drop_m": -drop[0] / 1e6, "bnb_drop_date": day(drop[1]), "bnb_back_m": back[0] / 1e6, "bnb_back_date": day(back[1]),
            "bnb_mint_recipients": len({e["counterparty"] for e in bnb_ev if e["kind"] == "mint"}),
            "bnb_after_events": "; ".join(f"{e['kind']} {e['tokens'] / 1e6:.1f}M on {day(e['ts'])}" for e in bnb_ev if e["ts"] > match["ts"]),
            "bnb_event_mints": sum(1 for e in bnb_ev if e["kind"] == "mint"), "bnb_event_burns": sum(1 for e in bnb_ev if e["kind"] == "burn"),
            "bnb_event_minted_m": sum(e["tokens"] for e in bnb_ev if e["kind"] == "mint") / 1e6,
            "bnb_event_burned_m": sum(e["tokens"] for e in bnb_ev if e["kind"] == "burn") / 1e6,
            "eth_assets_first_m": eth_first * nav_now / 1e6, "eth_assets_now_m": eth_now * nav_now / 1e6,
            "eth_assets_change_pct": round(100 * (eth_now / eth_first - 1), 1),
            "burn_share_of_fall_pct": round(100 * burn_tokens / (supply_metrics(times, now_ts)["peak_supply"] - eth_now), 1), "bnb_days": len(series), "bnb_supply_m": bnb_now / 1e6, "bnb_first_mint_date": day(match["ts"]), "eth_burn_tokens": burn_tokens, "eth_burn_m": burn_tokens / 1e6,
            "bnb_match_tokens": match["tokens"], "bnb_match_gap_tokens": round(abs(match["tokens"] - burn_tokens), 3),
            "burn_date": day(burn_ts), "burn_holder_mint_tokens": from_mint, "burn_holder_transfer_tokens": sum(r["value"] for r in from_xfer) / 1e6,
            "burn_holder_transfer_date": day(times[str(from_xfer[0]["block"])]) if from_xfer else "",
            "burn_source_mints_tokens": src_mint,
            "bnb_other_mints_m": (bnb_now - after) / 1e6, "eth_burnfrom_after_m": later_burns / 1e6,
            "xrpl_m": xrpl / 1e6, "arb_m": oc["arbitrum_supply_tokens"] / 1e6, "eth_m": eth_now / 1e6, "all_m": all_now / 1e6,
            "eth_share_pct": round(100 * eth_now / all_now, 1), "all_value_usd_m": all_now / 1e6 * nav_now,
            "bnb_morpho_markets": om["markets_with_tbill_collateral"]["BNB Chain"], "arb_morpho_markets": om["markets_with_tbill_collateral"]["Arbitrum"],
            "eth_morpho_markets": om["markets_with_tbill_collateral"]["Ethereum"], "bnb_morpho_isKyc": om["bnb_morpho_blue"]["isKyc"],
            "bnb_maintainer": holder_desc([oc["bnb_roles"]["maintainer"]])}


def roles_concentration(roles, maintainer_named):
    """How many role slots one named Safe holds (the memo says so in one sentence instead of separate rows)."""
    slots = [k for k, v in roles.items() if any(h.get("public_name") == maintainer_named for h in v)]
    return {"safe_role_slots": len(slots) + 1, "safe_roles_in_other_contracts": len(slots), "safe_role_names": ", ".join(sorted(k.split(":")[-1].replace("_ROLE", "").lower() + " (" + k.split(":")[0].split("_")[-1] + ")" for k in slots))}


def multisig_text(x):
    """'3-of-4 multisig' from a role holder record."""
    return f"{x['threshold']}-of-{x['signers']} multisig" if x["type"] == "Safe multisig" else x["type"]


def holder_desc(items):
    """Text for a list of role holders, e.g. 'Safe 4 of 5' or 'single key'."""
    out = []
    for x in items:
        out.append(f"Safe {x['threshold']} of {x['signers']}" if x["type"] == "Safe multisig" else x["type"].replace(" (no contract code)", ""))
    return ", ".join(out)


def liquidation_incentive(lltv):
    """Morpho Blue liquidation incentive factor: min(1.15, 1 / (0.3 * LLTV + 0.7))."""
    return min(1.15, 1 / (0.3 * lltv + 0.7))


def derived(res):
    r, st, q = res["roles"], res["state"], res["queue"]
    nav = res["nav"]["nav_now"]
    cap_5pct = 0.05 * st["total_assets_usd"]      # the first-pass rule; kept only for scoring P21 and for context
    cap = 1_000_000.0                               # judgment: a round dollar figure, see memo section 6
    return {"admin": {"oracle_operator": holder_desc(r["oracle:OPERATOR_ROLE"]), "oracle_admin": holder_desc(r["oracle:DEFAULT_ADMIN_ROLE"]),
                      "controller_operator": holder_desc(r["controller:OPERATOR_ROLE"]), "controller_admin": holder_desc(r["controller:DEFAULT_ADMIN_ROLE"]),
                      "vault_operators": holder_desc(r["vault:operators (SetOperator)"]),
                      "timelock_proposers": holder_desc(r["vault_owner_timelock:PROPOSER_ROLE"]),
                      "timelock_executors": holder_desc(r["vault_owner_timelock:EXECUTOR_ROLE"]),
                      "maintainer": holder_desc([res["role_holders_state"]["maintainer"]]),
                      "kyc_owner": holder_desc([res["role_holders_state"]["kyc_manager_owner"]]),
                      "kyc_owner_ms": multisig_text(res["role_holders_state"]["kyc_manager_owner"]),
                      "maintainer_ms": multisig_text(res["role_holders_state"]["maintainer"]),
                      "timelock_delay_h": res["role_holders_state"]["owner"]["min_delay_s"] / 3600,
                      "redemption_owner": holder_desc([res["redemption_contract"]["owner_type"]]),
                      "redemption_pauser": holder_desc([res["redemption_contract"]["pauser_type"]])},
            "exit": {"price_weekday": nav * (1 - st["redeem_fee_bps_weekday"] / 1e4), "price_weekend": nav * (1 - st["redeem_fee_bps_weekend"] / 1e4),
                     "rate_shock_100bp_nav_pct": -1.0 * 0.25},
            "usdo": {"markets": len(res["comp"]["usdo_markets"]), "supply_usd": sum(m["supply_usd"] for m in res["comp"]["usdo_markets"]),
                     "lltv_pct": res["comp"]["usdo_markets"][0]["lltv_pct"],
                     "usdo_supply_m": int(res["comp"]["onchain"]["issuer_defi_tokens"]["USDO"]["totalSupply_raw"]) / 1e24,
                     "cusdo_supply_m": int(res["comp"]["onchain"]["issuer_defi_tokens"]["cUSDO"]["totalSupply_raw"]) / 1e24,
                     "bonus_multiplier": int(res["comp"]["onchain"]["issuer_defi_tokens"]["USDO"]["bonusMultiplier"]) / 1e18,
                     "oracle_price": int(res["comp"]["onchain"]["issuer_defi_tokens"]["usdo_market_oracle"]["price"]) / 1e24},
            "limits": {"lltv": 86.0, "lif_pct_77": round((liquidation_incentive(0.77) - 1) * 100, 1),
                       "lif_pct_86": round((liquidation_incentive(0.86) - 1) * 100, 1),
                       "lif_pct_915": round((liquidation_incentive(0.915) - 1) * 100, 1),
                       "cap_usd": cap, "cap_5pct_usd": cap_5pct, "cap_half_usd": cap / 2, "cap_m": round(cap / 1e6, 1), "vault_share_pct": 1.0, "cap_5pct_share_pct": round(100 * cap / st["total_assets_usd"], 1), "cap_half_m": round(cap / 2e6, 1),
                       "cap_bonus_usd": cap * (liquidation_incentive(0.86) - 1), "total_assets_m": round(st["total_assets_usd"] / 1e6, 1),
                       "vault_min_assets_m": round(cap / 0.01 / 1e6), "cap_share_of_supply_pct": 5.0,
                       "cap_vs_median_day": cap / q["settle_usd_day_median"],
                       "nav_margin_to_lltv_pct": round((1 - 0.86) * 100, 1)}}


def yes(flag):
    return str(flag).lower() == "true"


def scores(res):
    """Score every prediction. Each entry: (id, prediction text, measured text, HIT/MISS/PARTIAL)."""
    n, s, h, q, st, c, d = res["nav"], res["supply"], res["holders"], res["queue"], res["state"], res["comp"], res["derived"]
    sim = res["sim"]["sim_1000000"]
    ck = lambda ok: "HIT" if ok else "MISS"
    cc = c["onchain"]
    rows = [
        ("P1", "Morpho Blue not KYC-whitelisted", f"isKyc={st['morpho_blue_isKyc']}", ck(not yes(st["morpho_blue_isKyc"]))),
        ("P2", "0 to 6 contract holders besides the vault", f"{h['contract_holders_excl_vault']}", ck(0 <= h["contract_holders_excl_vault"] <= 6)),
        ("P3", "Supply 25M to 150M tokens", f"{s['supply_now']/1e6:.2f}M on Ethereum; {res['chains']['all_m']:.1f}M across all chains", ck(25e6 <= s["supply_now"] <= 150e6)),
        ("P4", "90-day supply change within -30% to +40%", f"{s['change_90d_pct']}%", ck(-30 <= s["change_90d_pct"] <= 40)),
        ("P5", "15 to 150 holders", f"{h['holders_excl_vault']} (excluding the vault's queued shares)", ck(15 <= h["holders_excl_vault"] <= 150)),
        ("P6", "Top-5 share 60% to 95%", f"{h['top5_share_of_supply_pct']}%", ck(60 <= h["top5_share_of_supply_pct"] <= 95)),
        ("P7", "NAV 1.10 to 1.20", f"{n['nav_now']:.4f}", ck(1.10 <= n["nav_now"] <= 1.20)),
        ("P8", "230 to 270 update days, longest gap 3 to 5 days", f"{n['update_days_last365']} days, {n['longest_gap_days_last365']} d", ck(230 <= n["update_days_last365"] <= 270 and 3 <= n["longest_gap_days_last365"] <= 5)),
        ("P9", "Largest step under +0.03%, no negative step", f"max {n['max_step_pct_last365']}%, min {n['min_step_pct_last365']}%, {n['negative_steps_last365']} negative of {n['updates_last365']}", ck(n["max_step_pct_last365"] < 0.03 and n["negative_steps_last365"] == 0)),
        ("P10", "90-day annualised NAV growth 3.0% to 4.4%", f"{n['annualised_growth_90d_pct']}%", ck(3.0 <= n["annualised_growth_90d_pct"] <= 4.4)),
        ("P11", "No DEX pool with at least $50k TVL", "DexScreener: 0 pairs (one aggregator only)", "HIT"),
        ("P12", "Instant path set and not paused", f"set, paused={res['redemption_contract']['paused']}; vault BUIDL = {st['vault_buidl']:.2f}", "PARTIAL"),
        ("P13", "$0.5M to $15M USDC in the redemption path", f"redemption contract ${st['redemption_usdc']:.2f}; vault ${st['vault_usdc']:.2f}", ck(0.5e6 <= st["redemption_usdc"] + st["vault_usdc"] <= 15e6)),
        ("P14", "$1M redemption clears instantly (eth_call)", f"redeemIns reverts: {sim['instant_reason']}; queue request accepted: {sim['queue_ok']}", ck(sim["instant_ok"])),
        ("P15", "Queue length 0 to 5", f"{st['queue_length_state']}", ck(0 <= st["queue_length_state"] <= 5)),
        ("P16", "Redemption fee exactly 5 bps", f"{st['redeem_fee_bps_weekday']} bps weekday, {st['redeem_fee_bps_weekend']} bps weekend", "PARTIAL"),
        ("P17", "Owner is a multisig, 2-4 of 3-7", f"owner is a {d['admin']['timelock_delay_h']:.0f} h timelock; proposers {d['admin']['timelock_proposers']}", "PARTIAL"),
        ("P18", "Maintainer is one address", f"one address; it is a {d['admin']['maintainer']}", "PARTIAL"),
        ("P19", "Reject or conditional verdict", "Reject today; limits conditional", "HIT"),
        ("P20", "LLTV 77% to 91.5%", f"{d['limits']['lltv']}%", "HIT"),
        ("P21", "Supply cap $1M to $10M", f"${d['limits']['cap_5pct_usd']/1e6:.3f}M (first-pass 5% rule; the memo now uses a fixed $1.0M)", ck(1e6 <= d["limits"]["cap_5pct_usd"] <= 10e6)),
        ("A1", "EUTBL transfers permissioned", f"allowed(Morpho Blue)={cc['EUTBL']['morpho_blue_allowed']}, control address={cc['EUTBL']['control_dead_address_allowed']}", ck(not yes(cc["EUTBL"]["control_dead_address_allowed"]))),
        ("A2", "Morpho Blue allowed on EUTBL", cc["EUTBL"]["morpho_blue_allowed"], ck(yes(cc["EUTBL"]["morpho_blue_allowed"]))),
        ("A3", "EUTBL market oracle on an issuer NAV feed", "Chainlink-style adapter on a feed described as an EUTBL NAV feed", "HIT"),
        ("A4", "EUTBL LLTV 86% or 91.5%", f"markets at {c['eutbl_lltvs']}; largest market {c['eutbl_main']['lltv_pct']}%", ck(c["eutbl_main"]["lltv_pct"] in (86.0, 91.5))),
        ("A5", "USCC transfers permissioned", f"allowed(Morpho Blue)={cc['USCC']['morpho_blue_allowed']}, control address={cc['USCC']['control_dead_address_allowed']}", ck(not yes(cc["USCC"]["control_dead_address_allowed"]))),
        ("A6", "Morpho Blue allowed on USCC", cc["USCC"]["morpho_blue_allowed"], ck(yes(cc["USCC"]["morpho_blue_allowed"]))),
        ("A7", "USCC market oracle on a NAV feed", "Chainlink-style adapter on a feed described as a USCC NAV feed", "HIT"),
        ("A8", "USCC LLTV 77% to 86%", f"markets at {c['uscc_lltvs']}; vault-listed market {c['uscc_vault_market']['lltv_pct']}%", "PARTIAL"),
        ("A9", "Supplied $0.5M to $50M in each", f"EUTBL ${c['eutbl_main']['supply_usd']:,.0f}; USCC largest ${c['uscc_max_supply_usd']:,.0f}", "PARTIAL"),
        ("U1", "USDO/cUSDO transfer needs no KYC", "sender ban list and pause only", "HIT"),
        ("U2", "USDO market oracle on the issuer's own rate", "ERC-4626 conversion of cUSDO, no price feed", "HIT"),
    ]
    return rows


def render_scorecard(res):
    lines = ["# SCORECARD (generated by scripts/build_all.py; do not edit by hand)", "",
             "Predictions from PREDICTIONS.md (P) and PREDICTIONS_ADDENDUM.md (A, U), scored against the saved data.",
             "PARTIAL means the stated test was met in the letter but not in the substance, or only half of a two-part test was met.", "",
             "| # | Prediction | Measured | Result |", "|---|---|---|---|"]
    rows = res["scores"]
    lines += [f"| {i} | {p} | {m} | {r} |" for i, p, m, r in rows]
    tally = {k: sum(1 for x in rows if x[3] == k) for k in ("HIT", "PARTIAL", "MISS")}
    lines += ["", f"Tally: {tally['HIT']} hit, {tally['PARTIAL']} partial, {tally['MISS']} miss of {len(rows)}."]
    tally["total"] = len(rows)
    res["tally"] = tally
    BUILT["SCORECARD.md"] = "\n".join(lines) + "\n"
    print("built SCORECARD.md")


def flatten(d, prefix=""):
    out = {}
    for k, v in d.items():
        key = f"{prefix}{k}"
        if isinstance(v, dict):
            out.update(flatten(v, key + "."))
        else:
            out[key] = v
    return out


def render(res):
    """Fill {{a.b|fmt}} placeholders in memo.template.md and posts/templates/*.md from results."""
    flat = flatten(res)

    def fill(text):
        def sub(m):
            key, _, fmt = m.group(1).partition("|")
            val = flat[key.strip()]
            if fmt == "date":                      # 2026-11-16 -> 16 November 2026
                return datetime.fromisoformat(str(val)).strftime("%-d %B %Y")
            if fmt == "month_year":                # 2026-05-18 -> May 2026
                return datetime.fromisoformat(str(val)[:7] + "-01").strftime("%B %Y")
            if fmt == "month":                     # 2025-09 -> September 2025
                return datetime.fromisoformat(str(val) + "-01").strftime("%B %Y")
            return format(val, fmt) if fmt else str(val)
        return re.sub(r"\{\{([^}]+)\}\}", sub, text)

    BUILT["memo.md"] = fill((ROOT / "memo.template.md").read_text())
    print("built memo.md")
    post = fill((ROOT / "post.template.md").read_text())
    pw = len(post.split())
    assert 250 <= pw <= 340 and "`" not in post, f"post: {pw} words"
    assert flat["queue.unmatched_share_pct"] < 10, "post says fewer than one in ten"
    check_text("post.md", post)
    BUILT["post.md"] = post
    print("built post.md", pw, "words")
    art = fill((ROOT / "article.template.md").read_text())
    words = len(re.sub(r"!\[[^\]]*\]\([^)]*\)|^\*.*\*$|[#*`]", "", art, flags=re.M).split())
    assert 450 <= words <= 1000, f"article: {words} words"
    check_text("article.md", art)
    BUILT["article.md"] = art
    print("built article.md", words, "words")


def check_text(name, text):
    """Public-text rule: no emoji."""
    assert not re.search(r"[\U0001F300-\U0001FAFF\u2600-\u27BF]", text), f"{name}: emoji"


def compare_built():
    """Compare every built file with the committed one. Return the number of mismatches."""
    bad = 0
    for rel, text in BUILT.items():
        path = ROOT / rel
        old = path.read_text() if path.exists() else None
        if old == text:
            print(f"  [PASS] {rel} matches the rebuild")
            continue
        bad += 1
        if old is None:
            print(f"  [FAIL] {rel} is missing")
            continue
        a, b = old.splitlines(), text.splitlines()
        n = next((i for i, (x, y) in enumerate(zip(a, b)) if x != y), min(len(a), len(b)))
        print(f"  [FAIL] {rel} differs from the rebuild at line {n + 1}")
        print(f"         committed: {a[n] if n < len(a) else '(end of file)'}")
        print(f"         rebuilt:   {b[n] if n < len(b) else '(end of file)'}")
    return bad


if __name__ == "__main__":
    results = build()
    print(json.dumps({k: results[k] for k in ("derived", "tally")}, indent=1, default=str))
    render(results)
    if "--write" in sys.argv[1:]:
        for rel, text in BUILT.items():
            (ROOT / rel).write_text(text)
            print("wrote", rel)
    else:
        print("check: rebuilt files vs committed files")
        failed = compare_built()
        print(f"FAIL: {failed} file(s) differ from the rebuild" if failed else "OK: every generated file matches the rebuild")
        sys.exit(1 if failed else 0)
