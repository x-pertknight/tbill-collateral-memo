"""On-chain facts for the comparables (EUTBL, USCC) and the issuer's DeFi tokens (USDO, cUSDO).

eth_call only. Writes data/raw/comparables_onchain.json.
"""
from common import cast_call, first_word, save

MB = "0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb"
DEAD = "0x000000000000000000000000000000000000dEaD"   # control: an address that must not be allowed
TRANSFER_SELECTOR = "0xa9059cbb"
EUTBL = "0xa0769f7A8fC65e47dE93797b4e21C073c117Fc80"
USCC = "0x14d60E7FDC0D71d8611742720E4C50E7a974020c"
USDO = "0x8238884Ec9668Ef77B90C6dfF4D1a9F4F4823BFe"
CUSDO = "0xaD55aebc9b8c03FC43cd9f62260391c13c23e7c0"
FEEDS = {"EUTBL NAV feed": "0xfD628af590c4150A9651C1f4ddD0b4f532B703ae",
         "USCC NAV feed": "0xAfFd8F5578E8590665de561bdE9E7BAdb99300d9"}
USDO_ORACLE = "0x26Be0B9fDAF2855428DEee155b195eE802144ACD"


def one(addr, sig, *args):
    return first_word(cast_call(addr, sig, *args))


def token_basics(addr):
    return {"symbol": one(addr, "symbol()(string)"), "decimals": one(addr, "decimals()(uint8)"),
            "totalSupply_raw": one(addr, "totalSupply()(uint256)"), "paused": one(addr, "paused()(bool)")}


def eutbl():
    out = token_basics(EUTBL)
    auth = one(EUTBL, "authority()(address)")
    out["authority"] = auth
    out["rule"] = "_update requires authority.canCall(account, token, transfer) for sender and receiver"
    out["morpho_blue_allowed"] = one(auth, "canCall(address,address,bytes4)(bool)", MB, EUTBL, TRANSFER_SELECTOR)
    out["control_dead_address_allowed"] = one(auth, "canCall(address,address,bytes4)(bool)", DEAD, EUTBL, TRANSFER_SELECTOR)
    return out


def uscc():
    out = token_basics(USCC)
    out["allowlist"] = one(USCC, "allowlist()(address)")
    out["isPublicInstrument"] = one(USCC, "isPublicInstrument()(bool)")
    out["rule"] = "transfer/transferFrom require isAllowed(sender) and isAllowed(receiver)"
    out["morpho_blue_allowed"] = one(USCC, "isAllowed(address)(bool)", MB)
    out["control_dead_address_allowed"] = one(USCC, "isAllowed(address)(bool)", DEAD)
    return out


def usdo_route():
    out = {"USDO": token_basics(USDO), "cUSDO": token_basics(CUSDO)}
    out["USDO"]["morpho_blue_isBanned"] = one(USDO, "isBanned(address)(bool)", MB)
    out["USDO"]["bonusMultiplier"] = one(USDO, "bonusMultiplier()(uint256)")
    out["rule"] = "transfer reverts only if sender is on the ban list or the contract is paused; no KYC check on either side"
    out["usdo_market_oracle"] = {"address": USDO_ORACLE, "price": one(USDO_ORACLE, "price()(uint256)"),
                                 "BASE_VAULT": one(USDO_ORACLE, "BASE_VAULT()(address)"),
                                 "BASE_FEED_1": one(USDO_ORACLE, "BASE_FEED_1()(address)")}
    return out


def feeds():
    out = {}
    for name, addr in FEEDS.items():
        out[name] = {"description": one(addr, "description()(string)"), "decimals": one(addr, "decimals()(uint8)"),
                     "latestRoundData": cast_call(addr, "latestRoundData()(uint80,int256,uint256,uint256,uint80)")}
    return out


def main():
    save("comparables_onchain.json", {"EUTBL": eutbl(), "USCC": uscc(), "issuer_defi_tokens": usdo_route(),
                                      "nav_feeds": feeds()})


if __name__ == "__main__":
    main()
