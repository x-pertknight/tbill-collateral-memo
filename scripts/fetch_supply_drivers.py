"""Amounts and dates of the vault's admin burn/mint/re-issue events (no addresses saved).

Used to split supply changes into: queue settlements, admin burns, admin re-issues, other burns.
Writes data/raw/tbill_admin_amounts.json.
"""
from common import RPC_URL_STATE, block_timestamps, get_logs, rpc, save
from fetch_events import START, T, topic

EVENTS = {"burnFrom": "BurnFrom(address,uint256)", "mintTo": "MintTo(address,uint256)",
          "reIssue": "ReIssue(address,address,uint256)"}


def main():
    head = int(rpc("eth_blockNumber", [], RPC_URL_STATE), 16)
    out = {}
    for name, sig in EVENTS.items():
        # the amount is the only non-indexed field, so it is the first (and only) data word
        out[name] = [{"block": int(l["blockNumber"], 16), "amount": int(l["data"][2:66], 16)}
                     for l in get_logs(T, [topic(sig)], START, head)]
    blocks = [r["block"] for rows in out.values() for r in rows]
    out["block_times"] = {str(k): v for k, v in block_timestamps(blocks).items()}
    save("tbill_admin_amounts.json", out)
    print({k: len(v) for k, v in out.items() if k != "block_times"})


if __name__ == "__main__":
    main()
