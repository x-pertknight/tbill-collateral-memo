"""Liquidations on the comparable markets, and whether recent liquidators could receive each token.

Source: Morpho Blue `Liquidate` logs (eth_getLogs) + eth_call permission checks.
Liquidator addresses are replaced by ids before saving. Writes data/raw/liquidations.json.
"""
import json
from collections import Counter

from common import RAW, RPC_URL_STATE, Pseudonymizer, cast_call, first_word, get_logs, rpc, save
from fetch_events import addr, topic

MORPHO = "0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb"
FROM_BLOCK = 19_000_000          # before any of the comparable markets existed
RECENT_BLOCKS = 700_000          # about 100 days, used to find active liquidators on any market
EUTBL = "0xa0769f7A8fC65e47dE93797b4e21C073c117Fc80"
EUTBL_AUTH = "0x344278aff344d6fb960705dc18a4912221608472"
USCC = "0x14d60E7FDC0D71d8611742720E4C50E7a974020c"
TBILL_KYC = "0x51Be497AcEd1a2C19f6151064301e356B020D947"
SIG = "Liquidate(bytes32,address,address,uint256,uint256,uint256,uint256,uint256)"


def market_ids():
    rows = json.loads((RAW / "morpho_markets_comparables.json").read_text())["markets"]
    return {m["marketId"]: m["collateralAsset"]["symbol"] for m in rows if m["chain"]["id"] == 1}


def decode(log):
    w = [log["data"][2 + 64 * i: 66 + 64 * i] for i in range(5)]
    return {"market": log["topics"][1], "caller": addr(log["topics"][2]), "block": int(log["blockNumber"], 16),
            "repaid_assets": int(w[0], 16), "seized_assets": int(w[2], 16), "bad_debt_assets": int(w[3], 16)}


def permission(caller):
    """Could this address receive each token? (TBILL: isKyc; EUTBL: canCall transfer; USCC: isAllowed)"""
    code = rpc("eth_getCode", [caller, "latest"], RPC_URL_STATE)
    return {"is_contract": code != "0x",
            "tbill_isKyc": first_word(cast_call(TBILL_KYC, "isKyc(address)(bool)", caller)),
            "eutbl_allowed": first_word(cast_call(EUTBL_AUTH, "canCall(address,address,bytes4)(bool)", caller, EUTBL, "0xa9059cbb")),
            "uscc_allowed": first_word(cast_call(USCC, "isAllowed(address)(bool)", caller))}


def main():
    head = int(rpc("eth_blockNumber", [], RPC_URL_STATE), 16)
    pseudo, ids = Pseudonymizer(), market_ids()
    sig = topic(SIG)
    ours = [decode(l) for l in get_logs(MORPHO, [sig, list(ids)], FROM_BLOCK, head)]
    recent = [decode(l) for l in get_logs(MORPHO, [sig], head - RECENT_BLOCKS, head, step=100_000)]
    counts = Counter(r["caller"] for r in recent)
    top = []
    for caller, n in counts.most_common(8):
        top.append({"liquidator": pseudo(caller), "liquidations_recent": n, **permission(caller)})
    ours_callers = [{"collateral": ids[r["market"]], "liquidator": pseudo(r["caller"]), **permission(r["caller"])} for r in ours]
    by_token = {}
    for r in ours:
        t = by_token.setdefault(ids[r["market"]], {"liquidations": 0, "repaid_raw": 0, "bad_debt_raw": 0})
        t["liquidations"] += 1
        t["repaid_raw"] += r["repaid_assets"]
        t["bad_debt_raw"] += r["bad_debt_assets"]
    save("liquidations.json", {"head_block": head, "comparable_market_ids": len(ids), "by_collateral": by_token,
                               "recent_window_blocks": RECENT_BLOCKS, "recent_liquidations_all_markets": len(recent),
                               "recent_distinct_callers": len(counts), "top_liquidators": top,
                               "comparable_market_liquidators": ours_callers})
    print(by_token, len(recent), len(counts))


if __name__ == "__main__":
    main()
