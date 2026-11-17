"""Shared helpers for the fetch scripts. Read-only: only eth_call, eth_getLogs and block reads.

No transaction is ever signed or sent, and no key or wallet is used anywhere in this repo.
"""
import json
import subprocess
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "raw"
RPC_URL = "https://rpc.mevblocker.io"      # serves old logs; publicnode needs a token for archive reads
RPC_URL_STATE = "https://ethereum-rpc.publicnode.com"  # latest-state reads only
HEADERS = {"content-type": "application/json", "user-agent": "tbill-study/0.1"}

# Public protocol and issuer contracts that may be named in the write-up.
# Anything not listed here is an individual address and is replaced by an id (see pseudo()).
PUBLIC_ADDRESSES = {
    "0xdd50c053c096cb04a3e3362e2b622529ec5f2e8a": "TBILL vault/token (proxy)",
    "0xce9a6626eb99eaea829d7fa613d5d0a2eae45f40": "TBILL price oracle",
    "0x51be497aced1a2c19f6151064301e356b020d947": "TBILL KYC manager",
    "0x377de6729507bb0e56e0aac666bd8522e4a3fe41": "TBILL controller",
    "0x31d3f59ad4aac0eee2247c65ebe8bf6e9e470a53": "TBILL redemption contract (BUIDL to USDC)",
    "0x99c913b3cbddcfc7ed49ff19b00704286a4b3b6b": "TBILL fee manager",
    "0x6e8559afd41f8f9971828aa8b0c25b65ca6a5567": "TBILL vault owner (timelock)",
    "0x8ec4dd2df01c188ac5a5d870029e9cbb820d5844": "TBILL maintainer (Safe)",
    "0x498a47f8041406f48604c9035f17d143c6fd15aa": "TBILL KYC manager owner (Safe)",
    "0x7566a094651cc826d99b57b3046eab156269e94c": "TBILL qTreasury (Safe-like)",
    "0xdf596281875feb7837351c70d11f2338c7e45435": "TBILL treasury",
    "0x26c02c2a483130baf43ae77c859242db39c55bed": "TBILL oplTreasury",
    "0xbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb": "Morpho Blue",
    "0x80e49d1bdce8f80c38e88dd5c4c004ddb9b4e887": "USDO Express (issuer mint/redeem contract)",
    "0x8238884ec9668ef77b90c6dff4d1a9f4f4823bfe": "USDO token",
    "0xad55aebc9b8c03fc43cd9f62260391c13c23e7c0": "cUSDO token",
    "0x0000000000000000000000000000000000000000": "zero address",
}


def http_json(url, body=None, retries=4):
    """POST (or GET) JSON with retry; the free RPCs return transient 503s."""
    data = json.dumps(body).encode() if body is not None else None
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, data, HEADERS)
            return json.load(urllib.request.urlopen(req, timeout=90))
        except (urllib.error.URLError, TimeoutError) as err:
            if attempt == retries - 1:
                raise
            time.sleep(1.5 * (attempt + 1))


def rpc(method, params, url=RPC_URL):
    out = http_json(url, {"jsonrpc": "2.0", "id": 1, "method": method, "params": params})
    if "error" in out:
        if out["error"].get("message", "").startswith("service temporarily"):
            time.sleep(2)
            return rpc(method, params, url)
        raise RuntimeError(f"{method}: {out['error']}")
    return out["result"]


def cast_call(addr, sig, *args, block=None, rpc_url=RPC_URL_STATE, extra=()):
    """eth_call through Foundry's cast. Returns stdout lines, or None if the call reverts."""
    cmd = ["cast", "call", addr, sig, *map(str, args), "--rpc-url", rpc_url, *extra]
    if block is not None:
        cmd += ["--block", str(block)]
    res = subprocess.run(cmd, capture_output=True, text=True)
    return res.stdout.strip().splitlines() if res.returncode == 0 else None


def first_word(lines):
    """First token of the first output line (strips the '[1e6]' hints cast adds)."""
    return lines[0].split()[0] if lines else None


def get_logs(address, topics, start, end, step=4_000_000):
    """eth_getLogs in block chunks so a single request stays under the node's limit."""
    out, lo = [], start
    while lo <= end:
        hi = min(lo + step - 1, end)
        out += rpc("eth_getLogs", [{"address": address, "topics": topics,
                                    "fromBlock": hex(lo), "toBlock": hex(hi)}])
        lo = hi + 1
    return out


def block_timestamps(block_numbers):
    """Map block number -> unix timestamp using JSON-RPC batches of 100."""
    nums, out = sorted(set(block_numbers)), {}
    for i in range(0, len(nums), 100):
        chunk = nums[i:i + 100]
        batch = [{"jsonrpc": "2.0", "id": n, "method": "eth_getBlockByNumber",
                  "params": [hex(n), False]} for n in chunk]
        for item in http_json(RPC_URL, batch):
            out[item["id"]] = int(item["result"]["timestamp"], 16)
    return out


class Pseudonymizer:
    """Replace individual addresses by stable ids (order of first appearance).

    Public protocol and issuer contracts keep their names. This is applied before anything
    is written to data/raw, so the repo never holds individual holder addresses.
    """

    def __init__(self):
        self.ids = {}

    def __call__(self, addr):
        a = addr.lower()
        if a in PUBLIC_ADDRESSES:
            return PUBLIC_ADDRESSES[a]
        if a not in self.ids:
            self.ids[a] = f"addr_{len(self.ids) + 1:04d}"
        return self.ids[a]


def save(name, obj):
    RAW.mkdir(parents=True, exist_ok=True)
    (RAW / name).write_text(json.dumps(obj, indent=1, sort_keys=True))
    print("saved", name)
