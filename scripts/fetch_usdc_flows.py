"""USDC transfers INTO the TBILL vault: who funds it, and when (senders named if issuer contracts, else ids).

Writes data/raw/vault_usdc_inflows.json.
"""
from common import RPC_URL_STATE, Pseudonymizer, block_timestamps, get_logs, rpc, save
from fetch_events import START, T, addr, TRANSFER

USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"


def main():
    head = int(rpc("eth_blockNumber", [], RPC_URL_STATE), 16)
    vault_topic = "0x" + "0" * 24 + T[2:].lower()
    logs = get_logs(USDC, [TRANSFER, None, vault_topic], START, head)
    pseudo = Pseudonymizer()
    rows = [{"block": int(l["blockNumber"], 16), "from": pseudo(addr(l["topics"][1])), "value": int(l["data"], 16)} for l in logs]
    times = block_timestamps([r["block"] for r in rows])
    save("vault_usdc_inflows.json", {"head_block": head, "block_times": {str(k): v for k, v in times.items()}, "rows": rows})
    print(len(rows), "inflows")


if __name__ == "__main__":
    main()
