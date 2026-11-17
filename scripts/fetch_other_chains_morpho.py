"""Morpho markets with TBILL as collateral on any chain, and the BNB KYC manager's view of Morpho Blue (BNB).
Read-only. Writes data/raw/other_chains_morpho.json."""
from common import cast_call, first_word, http_json, save

TBILL = {"Ethereum": "0xdd50C053C096CB04A3e3362E2b622529EC5f2e8a", "BNB Chain": "0x5b4681F0d7A01B817675F25892D3Ad73572FD1D9",
         "Arbitrum": "0xF84D28A8D28292842dD73D1c5F99476A80b6666A"}
BNB_KYC = "0xd9cf8C5bB16422d992595f3e3342De25fE7F5cf9"
MORPHO_BNB = "0x01b0Bd309AA75547f7a37Ad7B1219A898E67a83a"   # Morpho Blue on BNB Chain (public protocol contract)
QUERY = "query($a:[String!]){markets(first:50,where:{collateralAssetAddress_in:$a}){items{marketId chain{id}}}}"


def main():
    out = {"markets_with_tbill_collateral": {}}
    for chain, addr in TBILL.items():
        res = http_json("https://api.morpho.org/graphql", {"query": QUERY, "variables": {"a": [addr]}})
        out["markets_with_tbill_collateral"][chain] = len(res["data"]["markets"]["items"])
    rpc = "https://bsc-rpc.publicnode.com"
    out["bnb_morpho_blue"] = {"isKyc": first_word(cast_call(BNB_KYC, "isKyc(address)(bool)", MORPHO_BNB, rpc_url=rpc)),
                              "isBanned": first_word(cast_call(BNB_KYC, "isBanned(address)(bool)", MORPHO_BNB, rpc_url=rpc))}
    save("other_chains_morpho.json", out)


if __name__ == "__main__":
    main()
