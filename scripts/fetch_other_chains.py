"""TBILL on other chains (read-only eth_call / eth_getLogs). Writes data/raw/other_chains.json.

Found in the issuer's own deployment list (sources/docs): BNB Chain and Arbitrum vaults.
Reads daily 00:00 UTC total supply on BNB Chain, today's supply on Arbitrum, role-holder types
on BNB, and the BNB mint/burn events on every day where the supply moved by more than 1M tokens (found by bisecting supply reads).
The XRP Ledger supply is not read here (no RPC call); it is quoted from rwa.xyz in the memo's limits.
"""
import json
import time
from datetime import datetime, timezone

from common import RAW, Pseudonymizer, cast_call, first_word, rpc, save

BNB_RPC = "https://56.rpc.thirdweb.com"   # serves old state; publicnode prunes older than ~2M blocks
ARB_RPC = "https://arbitrum-one-rpc.publicnode.com"
BNB = "0x5b4681F0d7A01B817675F25892D3Ad73572FD1D9"
ARB = "0xF84D28A8D28292842dD73D1c5F99476A80b6666A"
BNB_KYC = "0xd9cf8C5bB16422d992595f3e3342De25fE7F5cf9"
TRANSFER = "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
ZERO = "0x" + "0" * 64
FIRST_DAY = datetime(2026, 5, 18, tzinfo=timezone.utc).timestamp()   # BNB supply is 0 before this (checked at block 99.0M)


def block_ts(b):
    return int(rpc("eth_getBlockByNumber", [hex(b), False], BNB_RPC)["timestamp"], 16)


def block_at(ts, guess, spb=0.45):
    """Latest block with timestamp <= ts. Secant steps from a guess, then a short walk."""
    b = guess
    for _ in range(8):
        d = ts - block_ts(b)
        if abs(d) < 3:
            break
        b += int(d / spb)
    while block_ts(b) > ts:
        b -= 1
    return b


def supply_at(block):
    out = rpc("eth_call", [{"to": BNB, "data": "0x18160ddd"}, hex(block)], BNB_RPC)
    return int(out, 16) / 1e18


def daily_supply(head, head_ts):
    rows, guess, ts = [], head, int(FIRST_DAY)
    days = []
    while ts <= head_ts:
        days.append(ts)
        ts += 86400
    for t in reversed(days):                       # walk back from head so each guess is close
        guess = block_at(t, guess - int((head_ts - t) / 0.45) if not rows else guess - 192000)
        rows.append({"ts": t, "block": guess, "supply_tokens": supply_at(guess)})
        print("day", t, guess, flush=True)
    return sorted(rows, key=lambda r: r["ts"])


def jump_windows(lo, hi, size=500, min_move=1e6):
    """Blocks (as [lo, hi] windows of <= `size`) where supply moves by more than min_move: bisect on totalSupply reads."""
    a, b = supply_at(lo), supply_at(hi)
    if abs(b - a) <= min_move:
        return []
    if hi - lo <= size:
        return [(lo, hi)]
    mid = (lo + hi) // 2
    return jump_windows(lo, mid, size, min_move) + jump_windows(mid, hi, size, min_move)


def events(lo, hi, pseudo):
    """Mint and burn logs (Transfer from or to zero) inside the windows where supply moved."""
    out = []
    for w_lo, w_hi in jump_windows(lo, hi):
        for topics in ([TRANSFER, ZERO], [TRANSFER, None, ZERO]):
            for lg in rpc("eth_getLogs", [{"address": BNB, "topics": topics, "fromBlock": hex(w_lo), "toBlock": hex(w_hi)}], BNB_RPC):
                out.append({"block": int(lg["blockNumber"], 16), "kind": "mint" if topics[1] else "burn",
                            "counterparty": pseudo("0x" + lg["topics"][2 if topics[1] else 1][-40:]),
                            "tokens": int(lg["data"], 16) / 1e18, "ts": block_ts(int(lg["blockNumber"], 16))})
    return sorted(out, key=lambda r: r["block"])


def role_type(addr, url):
    code = rpc("eth_getCode", [addr, "latest"], url)
    if len(code) <= 2:
        return {"type": "single key (no contract code)"}
    thr = first_word(cast_call(addr, "getThreshold()(uint256)", rpc_url=url))
    if thr is None:
        return {"type": "other contract"}
    owners = cast_call(addr, "getOwners()(address[])", rpc_url=url)
    return {"type": "Safe multisig", "threshold": int(thr), "signers": len(owners[0].strip("[]").split(","))}


def main():
    pseudo = Pseudonymizer()
    head = int(rpc("eth_blockNumber", [], BNB_RPC), 16)
    head_ts = block_ts(head)
    old = RAW / "other_chains.json"                 # reuse the daily series if already fetched (about 15 minutes to rebuild)
    series = json.loads(old.read_text())["bnb_daily_supply"] if old.exists() else daily_supply(head, head_ts)
    big = [(a, b) for a, b in zip(series, series[1:]) if abs(b["supply_tokens"] - a["supply_tokens"]) > 1e6]
    evs = []
    for a, b in big:
        evs += events(a["block"] + 1, b["block"], pseudo)
    owner = first_word(cast_call(BNB, "owner()(address)", rpc_url=BNB_RPC))
    maint = first_word(cast_call(BNB, "maintainer()(address)", rpc_url=BNB_RPC))
    save("other_chains.json", {
        "fetched_at_unix": int(time.time()), "bnb_head_block": head, "bnb_head_ts": head_ts,
        "bnb_contract": BNB, "bnb_kyc_manager": BNB_KYC, "bnb_decimals": 18,
        "bnb_daily_supply": series, "bnb_mint_burn_events_on_move_days": evs,
        "bnb_roles": {"owner": role_type(owner, BNB_RPC), "maintainer": role_type(maint, BNB_RPC)},
        "arbitrum_contract": ARB,
        "arbitrum_supply_tokens": int(first_word(cast_call(ARB, "totalSupply()(uint256)", rpc_url=ARB_RPC))) / 1e6,
        "xrpl_supply_tokens_rwa_xyz_2026_11_17": 18899569.91})


if __name__ == "__main__":
    main()
