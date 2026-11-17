"""Morpho markets whose collateral is one of the comparables or the issuer's DeFi tokens.

Writes data/raw/morpho_markets_comparables.json (Morpho API; field names confirmed by introspection).
"""
import time

from common import http_json, save

API = "https://api.morpho.org/graphql"
TOKENS = {
    "EUTBL": "0xa0769f7A8fC65e47dE93797b4e21C073c117Fc80",
    "USCC": "0x14d60E7FDC0D71d8611742720E4C50E7a974020c",
    "USDO": "0x8238884Ec9668Ef77B90C6dfF4D1a9F4F4823BFe",
    "cUSDO": "0xaD55aebc9b8c03FC43cd9f62260391c13c23e7c0",
    "TBILL": "0xdd50C053C096CB04A3e3362E2b622529EC5f2e8a",
}
QUERY = """
query($addrs: [String!]) { markets(first: 50, where: {collateralAssetAddress_in: $addrs}) { items {
  marketId lltv listed chain { id network }
  collateralAsset { symbol address decimals }  loanAsset { symbol address }
  oracle { address type data { __typename ... on MorphoChainlinkOracleV2Data {
      baseFeedOne { address } baseFeedTwo { address } quoteFeedOne { address } quoteFeedTwo { address }
      baseOracleVault { address } scaleFactor } } }
  state { supplyAssetsUsd borrowAssetsUsd collateralAssetsUsd liquidityAssetsUsd utilization price }
  supplyingVaults { address name }
  supplyingVaultV2s { address name }
} } }
"""


def main():
    out = http_json(API, {"query": QUERY, "variables": {"addrs": list(TOKENS.values())}})
    if "errors" in out:
        raise RuntimeError(out["errors"])
    save("morpho_markets_comparables.json", {"fetched_at_unix": int(time.time()), "tokens": TOKENS,
                                              "markets": out["data"]["markets"]["items"]})


if __name__ == "__main__":
    main()
