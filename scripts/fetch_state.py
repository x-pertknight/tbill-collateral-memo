"""Snapshot of TBILL's live configuration and balances (eth_call only). Writes data/raw/tbill_state.json."""
import time

from common import cast_call, first_word, rpc, save, RPC_URL_STATE

T = "0xdd50C053C096CB04A3e3362E2b622529EC5f2e8a"
USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
BUIDL = "0x7712c34205737192402172409a8F7ccef8aA2AEc"
MORPHO_BLUE = "0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb"
ORACLE = "0xCe9a6626Eb99eaeA829D7fA613d5D0A2eaE45F40"
KYC = "0x51Be497AcEd1a2C19f6151064301e356B020D947"
FEE = "0x99C913B3cBDdCFC7eD49Ff19B00704286a4B3b6B"
CTRL = "0x377de6729507Bb0E56E0AAC666bd8522E4A3fe41"
REDEMPTION = "0x31D3F59Ad4aAC0eeE2247c65EBE8Bf6E9E470a53"


def call(addr, sig, *args):
    return first_word(cast_call(addr, sig, *args))


def vault_getters():
    names = ["totalSupply()(uint256)", "totalSupplyCap()(uint256)", "totalAssets()(uint256)",
             "tbillUsdcRate()(uint256)", "owner()(address)", "maintainer()(address)",
             "controller()(address)", "kycManager()(address)", "tbillUsdPriceFeed()(address)",
             "redemptionContract()(address)", "feeManager()(address)", "treasury()(address)",
             "qTreasury()(address)", "oplTreasury()(address)", "getWithdrawalQueueLength()(uint256)",
             "decimals()(uint8)"]
    return {n.split("(")[0]: call(T, n) for n in names}


def holder_type(addr):
    """Classify a role holder: Safe (threshold/owners), timelock (min delay), other contract, or EOA."""
    size = int(call_raw_codesize(addr))
    info = {"code_bytes": size}
    if size == 0:
        info["type"] = "single key (no contract code)"
        return info
    thr = call(addr, "getThreshold()(uint256)")
    if thr is not None:
        owners = cast_call(addr, "getOwners()(address[])")
        info.update(type="Safe multisig", threshold=int(thr),
                    signers=len(owners[0].strip("[]").split(",")))
        return info
    delay = call(addr, "getMinDelay()(uint256)")
    info.update(type="timelock" if delay else "other contract", min_delay_s=int(delay) if delay else None)
    return info


def call_raw_codesize(addr):
    code = rpc("eth_getCode", [addr, "latest"], RPC_URL_STATE)
    return (len(code) - 2) // 2


def main():
    st = {"fetched_at_unix": int(time.time()), "block": int(rpc("eth_blockNumber", [], RPC_URL_STATE), 16)}
    st["vault"] = vault_getters()
    st["roles"] = {r: holder_type(st["vault"][r]) for r in ("owner", "maintainer", "qTreasury")}
    st["roles"]["kyc_manager_owner"] = holder_type(call(KYC, "owner()(address)"))
    st["roles"]["fee_manager_owner"] = holder_type(call(FEE, "owner()(address)"))
    st["kyc"] = {"morpho_blue_isKyc": call(KYC, "isKyc(address)(bool)", MORPHO_BLUE),
                 "morpho_blue_isBanned": call(KYC, "isBanned(address)(bool)", MORPHO_BLUE),
                 "isStrict": call(KYC, "isStrict()(bool)")}
    st["controller"] = {"pausedDeposit": call(CTRL, "pausedDeposit()(bool)"),
                        "pausedWithdraw": call(CTRL, "pausedWithdraw()(bool)")}
    st["fees"] = {"management_fee_rate_bps": call(FEE, "getManagementFeeRate()(uint256)"),
                  "first_deposit_usdc_raw": call(FEE, "getFirstDeposit()(uint256)"),
                  "min_max_withdraw_raw": cast_call(FEE, "getMinMaxWithdraw()(uint256,uint256)")}
    for kind, nm in ((0, "deposit"), (1, "withdraw")):
        for wk in ("false", "true"):
            st["fees"][f"tx_fee_{nm}_weekend_{wk}"] = call(FEE, "getTxFeePct(uint8,bool)(uint256)", kind, wk)
    st["oracle"] = {"decimals": call(ORACLE, "decimals()(uint8)"),
                    "latestRound": call(ORACLE, "latestRound()(uint80)"),
                    "latestRoundData": cast_call(ORACLE, "latestRoundData()(uint80,uint256,uint256,uint256,uint80)"),
                    "closeNavPrice": call(ORACLE, "closeNavPrice()(uint256)"),
                    "maxPriceDeviation": call(ORACLE, "maxPriceDeviation()(uint256)")}
    st["redemption"] = {k: call(REDEMPTION, s) for k, s in
                        {"asset": "asset()(address)", "liquidity": "liquidity()(address)",
                         "settlement": "settlement()(address)", "paused": "paused()(bool)",
                         "owner": "owner()(address)", "pauser": "pauser()(address)"}.items()}
    st["redemption"]["owner_type"] = holder_type(st["redemption"]["owner"])
    st["redemption"]["pauser_type"] = holder_type(st["redemption"]["pauser"])
    # single-key holders are reported by type only, never by address
    del st["redemption"]["owner"], st["redemption"]["pauser"]
    bal = lambda tok, who: call(tok, "balanceOf(address)(uint256)", who)
    st["balances_raw"] = {"vault_usdc": bal(USDC, T), "vault_buidl": bal(BUIDL, T),
                          "redemption_usdc": bal(USDC, REDEMPTION),
                          "qtreasury_usdc": bal(USDC, st["vault"]["qTreasury"]),
                          "opltreasury_usdc": bal(USDC, st["vault"]["oplTreasury"]),
                          "treasury_usdc": bal(USDC, st["vault"]["treasury"])}
    save("tbill_state.json", st)


if __name__ == "__main__":
    main()
