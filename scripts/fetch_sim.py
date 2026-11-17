"""P14: simulate redemptions with eth_call only (no transaction is signed or sent).

The simulated sender is the largest key-controlled TBILL holder, found from Transfer logs. The
address stays in memory and is never written to disk. Output: data/raw/tbill_redeem_sim.json.
"""
import subprocess

from common import RPC_URL_STATE, get_logs, rpc, save
from fetch_events import START, TRANSFER, T, addr

SIZES_USD = [1_000, 10_000, 100_000, 1_000_000]


def largest_key_holder(head):
    bal = {}
    for l in get_logs(T, [TRANSFER], START, head):
        v = int(l["data"], 16)
        bal[addr(l["topics"][1])] = bal.get(addr(l["topics"][1]), 0) - v
        bal[addr(l["topics"][2])] = bal.get(addr(l["topics"][2]), 0) + v
    for a, b in sorted(bal.items(), key=lambda kv: -kv[1]):
        if b > 0 and rpc("eth_getCode", [a, "latest"], RPC_URL_STATE) == "0x":
            return a, b
    raise RuntimeError("no key-controlled holder")


def simulate(sender, fn, shares):
    cmd = ["cast", "call", T, f"{fn}(uint256,address)", str(shares), sender, "--from", sender,
           "--rpc-url", RPC_URL_STATE]
    res = subprocess.run(cmd, capture_output=True, text=True)
    return {"ok": res.returncode == 0, "output": (res.stdout or res.stderr).strip()[:300]}


def main():
    head = int(rpc("eth_blockNumber", [], RPC_URL_STATE), 16)
    sender, balance = largest_key_holder(head)
    nav = int(subprocess.run(["cast", "call", T, "tbillUsdcRate()(uint256)", "--rpc-url", RPC_URL_STATE],
                             capture_output=True, text=True).stdout.split()[0])  # USDC raw per 1e6 shares
    rows = []
    for usd in SIZES_USD:
        shares = usd * 10 ** 6 * 10 ** 6 // nav
        row = {"usd": usd, "shares": shares, "sender_balance_ok": shares <= balance}
        if shares <= balance:
            row["redeemIns"] = simulate(sender, "redeemIns", shares)
            row["redeem_queue"] = simulate(sender, "redeem", shares)
        rows.append(row)
    save("tbill_redeem_sim.json", {"block": head, "nav_raw": nav, "rows": rows})


if __name__ == "__main__":
    main()
