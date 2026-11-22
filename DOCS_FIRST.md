# DOCS_FIRST: OpenEden TBILL as Morpho collateral

Written 16 Nov 2026, before any measurement of liquidity, holders or prices.
Evidence files are in `sources/` (issuer docs snapshot, verified contract source) and
`data/step0/` (the Morpho API pull used to choose the asset).

## 1. Asset choice (Step 0)

**Chosen asset: OpenEden TBILL on Ethereum**, token `0xdd50C053C096CB04A3e3362E2b622529EC5f2e8a`
(6 decimals, EIP-1967 proxy, implementation `OpenEdenVaultV5` at `0xc4545Bf8...c048`, source
verified on Sourcify).

How the lookup was done (Morpho API `https://api.morpho.org/graphql`, schema checked by
introspection; field names confirmed):
- Top 25 V1 vaults by `totalAssetsUsd` (listed): collateral taken from `state.allocation[].market.collateralAsset`.
- Top 25 V2 vaults by `totalAssetsUsd`: collateral taken from `caps` entries of type
  `CollateralCapData` / `MarketV1CapData`.
- Direct check of all Morpho markets for the TBILL, USDO and cUSDO addresses.

Result:
- **No OpenEden collateral appears in any of the 50 vaults.** TBILL (Ethereum) has **no Morpho market at all**.
- USDO and cUSDO each have one or two markets, with about $0 supplied, and none of the 50 vaults lists them.
  USDO is a yield-bearing stablecoin with a bonus multiplier, not a T-bill share, so it answers a different question.
- Tokenized treasury-type collateral that does appear in the top 50 (so excluded from the choice): EUTBL, USCC
  (and PRIME, mF-ONE, FLHYon, PST under other mandates). Not seen in the top 50: BUIDL, USTB, BENJI, USYC, OUSG, JTRSY.
  Those were not checked further because TBILL, the first candidate considered, is absent.
- Limits of this check: it covers 50 vaults, not every vault; a V2 vault that reaches a market only through a V1-vault adapter would show no collateral cap. The raw JSON is in `data/step0/`.

## 2. Documented (source in brackets; `docs` = `sources/docs/openeden_tbill_docs_2026-11-16.md`)

| Topic | What the issuer says | Source |
|---|---|---|
| Structure | TBILL is an ERC-20 claim on a BVI-regulated professional fund; assets are T-bills (manager BNY Investments Singapore, custody BNY) plus some USD; admin Protege; WAM under 3 months | docs: Introduction |
| Who may hold | Only wallets that passed KYC/KYB and were whitelisted; investors must be Professional (BVI) or US Accredited | docs: Investor Onboarding |
| Transfers | "May only transfer to other whitelisted Investors" | docs: FAQ |
| Mint | USDC deposit; first deposit at least 100,000 USDC, then 1 USDC; price from the TBILL oracle | docs: Subscriptions |
| Redeem | Request goes into a FIFO queue, "typically processed on the next 1 U.S. business day"; minimum 1 USDC; price and fee are set when the request is processed, not when it is made | docs: Redemptions |
| Fees | Total expense ratio 0.35% a year, accrued daily (the FAQ says 30 bps); 5 bps transaction fee (Fees page: subscription and redemption; FAQ: redemptions) | docs: Fees, FAQ |
| Price | NAV per token = (totalAssets − feeClaimable) / supply; USDC treated as exactly $1; "price guard" halts the vault on unexpected deviation | docs: Token Price, On-chain Governance |
| Oracle | Off-chain price feed posts NAV to an on-chain oracle once a day | docs: Token Price |
| Admin controls | Multisig including the fund administrator; 24 h timelock on treasury-address changes; role-based governance | docs: On-chain Governance (I) |
| Audits | Verichains (Mar 2023), Hacken (Oct 2023); EY process audit | docs: Risks, Trust |
| Addresses (Ethereum v2) | Vault `0xdd50...2e8a`, price oracle `0xCe9a...5F40`, KYC manager `0x51Be...D947` | docs: Smart Contract Addresses |

## 3. Documented in code (read from verified source, not yet checked against live state)

From `OpenEdenVaultV5Impl.sol`, `TBillPriceOracle.sol`, `KycManager.sol` in `sources/contracts/`:

1. **Every transfer needs KYC on both sides.** `_beforeTokenTransfer` calls `_validateKyc(from, to)`, which requires `isKyc` and not `isBanned` for both. Mints, burns and transfers out of the vault itself skip the check. Implication: Morpho Blue, any Morpho oracle-adapter or vault-adapter holder, and every liquidator would each need to be whitelisted by the KYC manager owner. This is the central question of the study.
2. **KYC manager is `Ownable`** and can grant, revoke and ban addresses in bulk. A ban or revoke on the Morpho Blue address would freeze the collateral held there.
3. **Vault code has an instant redeem path (`redeemIns`)** that pulls USDC from a pluggable `redemptionContract` (`checkLiquidity()`, `checkPaused()`, `redeem()`). The docs describe only the queue. Which path is live, and how much USDC the redemption contract holds, must be measured.
4. **Pause:** a `controller` can pause deposit and withdraw (`requireNotPausedDeposit/Withdraw`). Transfers are not gated by the controller in this code, only by KYC.
5. **Maintainer powers:** `burnFrom` (any wallet, no approval), `mintTo`, `reIssue` (move shares between wallets), `setTotalSupplyCap`, `setRedemption`, `cancel` queued redemptions. Owner can upgrade the implementation (UUPS `_authorizeUpgrade`) and swap the KYC manager, fee manager, price feed and controller.
6. **Oracle design:** Chainlink-style `latestRoundData()` but not Chainlink. An operator or admin posts the price; a posted price must be within `maxPriceDeviation` of the stored `closeNavPrice`, and the admin can reset `closeNavPrice` with no check. The vault treats the answer as NAV in 8 decimals and reverts if it is below 1.0 or older than 7 days. **The feed reports NAV, not a market price.**
7. **Price floor:** `tbillUsdcRate()` reverts if the oracle price is below `1e8` (1.0). If NAV ever printed under par, deposits and redemptions through the vault would revert.
8. **Supply cap:** `totalSupplyCap` is enforced on mint and deposit.

## 4. Conflicts inside the documentation (to resolve by measurement)

- Queue versus instant redemption (docs: queue, code: both, third-party aggregators: instant with 0.05% fee). Treated as unresolved.
- Expense ratio 0.35% (Fees page) versus 30 bps (FAQ).
- Transaction fee on subscription and redemption (Fees page) versus redemption only (FAQ).
- Docs name a 100,000 USDC first deposit; the code reads `firstDepositAmt` from storage, so the live value must be read.

## 5. Must be measured (nothing below has been looked at yet)

1. Is Morpho Blue (`0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb`) or any other relevant contract KYC-whitelisted? Which contracts are?
2. Live owner, maintainer, proxy admin, controller and multisig thresholds; pause state; `redemptionContract` address and its USDC balance and pause flag.
3. Total supply history and the supply cap; holder concentration (aggregate only).
4. NAV history from oracle events: update cadence, weekend and holiday flats, largest gap, largest step.
5. Any secondary market (DEX pool) for TBILL on Ethereum, and slippage at several trade sizes; deviation from NAV if a market exists.
6. Redemption throughput at several sizes: instant-path capacity, and queue size and age.
7. Live fee values from the fee manager.

## 6. What this means for the design of the measurements

- Because transfers are whitelist-gated, a normal AMM pool may not exist; liquidity for TBILL is probably the issuer's redemption path, not a DEX. The liquidity test therefore has two parts: DEX pools if any, and the redemption contract.
- The oracle reports NAV. A Morpho oracle built on it would price the collateral at redemption value even when the exit is slow; the memo must treat NAV and exit price as different things.

## 7. Tone note

Findings describe the token's contract rules. Nothing here ranks or criticises any curator or issuer.
