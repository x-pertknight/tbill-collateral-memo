"""Pull TBILL event history (logs only) and save it with individual addresses replaced by ids.

Writes data/raw/: tbill_transfers.json, tbill_queue_events.json, tbill_oracle_updates.json,
block_times.json.
"""
import subprocess

from common import RPC_URL_STATE, Pseudonymizer, block_timestamps, get_logs, rpc, save

T = "0xdd50C053C096CB04A3e3362E2b622529EC5f2e8a"
ORACLE = "0xCe9a6626Eb99eaeA829D7fA613d5D0A2eaE45F40"
START = 18_376_020          # proxy deployment block (Sourcify)
TRANSFER = "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"


def topic(signature):
    out = subprocess.run(["cast", "sig-event", signature], capture_output=True, text=True, check=True)
    return out.stdout.strip()


def words(data):
    """Split ABI-encoded event data into 32-byte hex words."""
    raw = data[2:]
    return [raw[i:i + 64] for i in range(0, len(raw), 64)]


def addr(topic_hex):
    return "0x" + topic_hex[-40:]


def signed(word):
    v = int(word, 16)
    return v - 2 ** 256 if v >= 2 ** 255 else v


def current_holders(raw_logs, pseudo):
    """Replay transfers to balances; flag each holder as contract or key. Output uses ids only."""
    bal = {}
    for l in raw_logs:
        v = int(l["data"], 16)
        bal[addr(l["topics"][1])] = bal.get(addr(l["topics"][1]), 0) - v
        bal[addr(l["topics"][2])] = bal.get(addr(l["topics"][2]), 0) + v
    out = []
    for a, b in bal.items():
        if b > 0:
            code = rpc("eth_getCode", [a, "latest"], RPC_URL_STATE)
            out.append({"holder": pseudo(a), "balance": b, "is_contract": code != "0x"})
    return out


def main():
    head = int(rpc("eth_blockNumber", [], RPC_URL_STATE), 16)
    pseudo = Pseudonymizer()
    raw_logs = get_logs(T, [TRANSFER], START, head)
    transfers = [{"block": int(l["blockNumber"], 16), "log_index": int(l["logIndex"], 16),
                  "from": pseudo(addr(l["topics"][1])), "to": pseudo(addr(l["topics"][2])),
                  "value": int(l["data"], 16)} for l in raw_logs]
    save("tbill_holders_now.json", {"head_block": head, "rows": current_holders(raw_logs, pseudo)})
    sig_add = topic("AddToWithdrawalQueue(address,address,uint256,bytes32)")
    sig_proc = topic("ProcessWithdraw(address,address,uint256,uint256,uint256,uint256,uint256,int256,uint256,bytes32,address)")
    sig_cancel = topic("ProcessRedeemCancel(address,address,uint256,bytes32)")
    queue = []
    for kind, sig in (("added", sig_add), ("processed", sig_proc), ("cancelled", sig_cancel)):
        for l in get_logs(T, [sig], START, head):
            w = words(l["data"])
            ident = w[3] if kind in ("added", "cancelled") else w[9]
            shares = int(w[2], 16) if kind == "added" else (int(w[3], 16) if kind == "processed" else int(w[2], 16))
            queue.append({"kind": kind, "block": int(l["blockNumber"], 16), "id": "0x" + ident,
                          "sender": pseudo("0x" + w[0][-40:]), "receiver": pseudo("0x" + w[1][-40:]),
                          "shares": shares, "assets": int(w[2], 16) if kind == "processed" else None})
    sig_price = topic("UpdatePrice(uint256,uint256)")
    oracle = [{"block": int(l["blockNumber"], 16), "old": int(l["data"][2:66], 16),
               "new": int(l["data"][66:130], 16)} for l in get_logs(ORACLE, [sig_price], START, head)]
    blocks = [r["block"] for r in transfers + queue + oracle]
    times = block_timestamps(blocks + [head])
    save("tbill_transfers.json", {"head_block": head, "rows": transfers})
    save("tbill_queue_events.json", {"rows": queue})
    save("tbill_oracle_updates.json", {"rows": oracle})
    save("block_times.json", {str(k): v for k, v in times.items()})
    print("transfers", len(transfers), "queue events", len(queue), "oracle updates", len(oracle))


if __name__ == "__main__":
    main()
