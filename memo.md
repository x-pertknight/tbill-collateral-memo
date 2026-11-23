# Would OpenEden TBILL pass as collateral in a Morpho market?

**Decision memo.** Author: Marco Amendola. Data as of 2026-11-16 (Ethereum block 26429959). Not investment advice.
**Scope:** OpenEden TBILL on Ethereum (`0xdd50C053C096CB04A3e3362E2b622529EC5f2e8a`) against Morpho Blue; the issuer's BNB Chain and Arbitrum deployments are read for supply only. Sources: Morpho API (top 25 V1 and top 25 V2 vaults by TVL, plus a market search by collateral address), public RPC (eth_call and logs), verified contract source, issuer documentation. It describes contract rules and measured behaviour and ranks no curator or issuer.

## 1. Bottom line
**Reject today (supply cap $0). A capped approval is possible only if the issuer's KYC manager lists Morpho Blue and at least three liquidator contracts run by unrelated operators, and only as a pilot the vault accepts losing in full.** The decisive variable is that list: `isKyc(Morpho Blue)` returns **false**. The issuer can later withdraw the listing, one key posts the NAV that sets the liquidation trigger, and the maintainer can move any balance, so the amount at risk is everything lent, not a share of the token. If listed: LLTV 86.0% (picked from Morpho's allowed steps, not derived) and a supply cap of $1.0M, a judgment bounded by a 1% vault-exposure rule.

## 2. Thesis and mechanism
The question "is a 3-month T-bill token safe collateral?" is the wrong one. Price risk is small: in the last year NAV moved at most 0.0795% up and -0.0726% down in one update, and a 100 bp rate shock on under three months' average maturity is about -0.25% (assumption from the issuer's stated maturity). The right question is whether Morpho Blue can **hold, seize and sell** the token, and keep doing so. The transfer hook requires sender and receiver to be KYC-approved and not banned, so liquidation works only while Morpho Blue and the liquidator are both listed. **Falsifier:** if `isKyc` is true for Morpho Blue and three independent liquidators, the first step fails; revocation (G5) is a separate risk that the listing does not remove.

## 3. Evidence
**E1. Contract rules** (`sources/contracts`, `tbill_state.json`). `_beforeTokenTransfer` calls `_validateKyc(from, to)`. Morpho Blue is not approved. The vault's supply cap is at least 2^255, so it limits nothing.

**E2. Across chains supply rose; on Ethereum alone it fell 90.4%.** Ethereum plus BNB Chain held 69.1M tokens on 2026-05-18 and hold 235.1M now, 31.8% above Ethereum's own peak of 178,379,893 (2025-08-22). The XRP Ledger holds 18.9M (quoted from rwa.xyz, history not read) and Arbitrum 0; all chains hold 254.0M tokens, $296M at NAV, and Ethereum is 6.8%. On Ethereum, supply went from the peak to 17,167,607: 295,747,270 tokens left through the redemption queue ($333,566,265 paid per settlement events) and 92,212,070 through `burnFrom`, against 226,747,069 minted: net -161,212,286, equal to the peak minus today's supply. The largest `burnFrom`, 87,625,894 tokens on 2026-05-26, equals a BNB Chain mint to six decimals 9 minutes later, so I read it as a cross-chain move (inference); it is 54.4% of the net fall. The burned address had received 43,703,161 tokens by mint on 2026-05-20 and 43,922,762 by transfer on 2026-04-10. After that match BNB supply rose by a net 130.3M. I read BNB mint and burn logs on every day supply moved by more than 1M tokens: mint 43.2M on 2026-06-09; burn 26.1M on 2026-07-17; mint 26.1M on 2026-07-20; mint 43.5M on 2026-07-21; mint 43.2M on 2026-09-17. All 5 mints went to 1 address; I did not identify who funded them or whether they are new subscriptions. **Not shown:** why holders redeemed, and what holders did with the USDC they received. No Morpho market uses TBILL as collateral on any of the three chains, and Morpho Blue on BNB Chain is not listed either.

**E3. Exit history** (`tbill_queue_events.json`, 200 requests settled since 2024-12-01). Redemption is a queue an operator processes: median 15.8 h, p90 26.6 h, max 86.2 h from request to settlement; 88.5% within 24 h. The docs say: "Redemptions are typically processed on the next 1 U.S. business day." In New York business days (federal holidays excluded), 100.0% settled within 1 (maximum 1). The six slowest started on Fri, Fri, Thu, Sat, Fri, Fri, so the tail is consistent with the docs. **Cancelled and unmatched:** `cancel` takes requests from the front of the queue and returns the shares to the sender (vault source, line 278). It was applied to 6 requests (9,246,579 tokens), 3 of 500,000 tokens or more (9,090,018 tokens, 2025-04-06 to 2025-06-25); the reason is not shown, so I do not count them as failed exits. 12 requests from 2024-12 (12,879,023 tokens) have no matched settlement (not in the queue today; cause not verified). **In favour:** from 2025-09 to 2025-11, 196,447,613 tokens settled at monthly median waits (by month of settlement) of 16.0 / 15.8 / 10.6 h (max 71.9 h). Median settled value per day: $700,073. The vault holds $0.69 USDC and the redemption contract $0.00; 3 requests ($351,271) are pending. The code settles only if the vault's USDC covers the request, and 100.0% of 120 settlements in the last year followed a USDC inflow of at least 90% of their size within 24 h. **Inference:** the vault is topped up before settlement by senders I cannot identify: the 441 inflows come from 14 addresses, 304 from one of them and 24 from a named issuer address, so the waits show how the vault was funded in the past, not how much it can pay. The instant path `redeemIns` reverted in `eth_call` at $1k to $1M with "Not asset holder" (the redemption contract's `onlyAssetHolder` check); the vault's BUIDL balance read is 0.

**E4. NAV** (`tbill_oracle_updates.json`). NAV 1.1635; 310 updates on 253 days in the last year; 90-day annualised growth 3.52%. 16 of those updates were downward (median -0.0039%), 143 of 1228 over the full history; of the last year's, 11 returned to the prior level within 24 h and 5 took longer, the worst (-0.0726% on 2026-09-09) 211.5 h. **The cause is unexplained**: the oracle logs no reason. NAV is the issuer's accounting value; the exit price is separate: NAV at processing minus the fee (5 bps weekday, 10 bps weekend), about 1.1629 USDC per token on a weekday. No DEX pool exists (DexScreener: zero pairs).

**E5. Comparables: they show holding and borrowing; liquidation is thin, and demand is small.** EUTBL and USCC also restrict transfers, and Morpho Blue is allowed on both. EUTBL's largest Ethereum market (EURCV loan, LLTV 96.5%) has $2,897,429 supplied and $2,608,556 borrowed; USCC (a crypto carry fund, a comparable for the transfer rule only) has 6 Ethereum markets and the largest holds $20. Across 11 comparable markets there have been **0 EUTBL liquidations and 1 USCC liquidation ($19 repaid)**. Of the 8 busiest Morpho liquidators (35% of 655 liquidations by 175 callers in 97 days), 0 can receive EUTBL, 0 USCC and 0 TBILL. I found no evidence of demand to borrow against TBILL.

**E6. Issuer's DeFi-facing tokens (measured).** USDO (12.57M) and cUSDO (9.60M) block only banned senders and a pause. 3 Ethereum markets hold $0.01 supplied; minting USDO needs KYC and a $100,000 first purchase (issuer docs).

## 4. Admin powers (rule, role, live holder)
**One Safe (4 of 5) holds 6 of the role slots below: maintainer, timelock proposer, executor and canceller, oracle admin and controller admin.** The 24 h timelock is not a separate check on it.

| Rule (function) | Role | Live holder |
|---|---|---|
| Replace implementation (`_authorizeUpgrade`) | vault owner | 24 h timelock; proposers Safe 4 of 5, Safe 3 of 5; executor Safe 4 of 5 |
| Burn from any wallet, mint, move shares (`burnFrom`, `mintTo`, `reIssue`), cancel queued requests (`cancel`) | maintainer | Safe 4 of 5; used 11, 12, 15, 6 times |
| Grant, revoke, ban (`grantKycInBulk`, `revokeKycInBulk`, `bannedInBulk`) | KYC manager owner | Safe 3 of 4 |
| Post NAV (`updatePrice`); reset reference NAV unchecked (`updateCloseNavPriceManually`) | oracle operator; oracle admin | operator single key; admin Safe 4 of 5 |
| Pause deposits or withdrawals (`pauseAll`, `pauseWithdraw`) | controller operator or admin | operator single key; admin Safe 4 of 5 |
| Process queue, move funds (`processWithdrawalQueue`, `offRamp`) | vault operators | single key, single key |

`burnFrom` needs no approval, so a balance held by Morpho Blue is within its reach. If the KYC manager owner revokes or bans Morpho Blue, `withdrawCollateral` and `liquidate` revert: both send the collateral token out of Morpho Blue (`Morpho.sol` lines 341 and 410, saved in `sources/contracts`). Repayment still works; collateral stays locked and interest keeps accruing.

## 5. Case against, and what would change the verdict
**Strongest case against rejecting:** NAV is stable, run-off redemptions settled on normal waits, and the issuer can whitelist protocols (EUTBL and USCC show it done), so "reject" may mean "not yet asked". **Cost of the fix:** a whitelist closes open liquidation, so the 4.4% incentive is not competed for and the issuer controls who may liquidate. Three unrelated operators is a **judgment call**, and "unrelated" cannot be checked on chain. **Stress case, withdrawals paused during a liquidation:** at the cap a liquidator repaying $1.0M seizes about $1.0M plus a $43,841 bonus in tokens it cannot redeem while one key holds `pauseWithdraw`, with no DEX pool. Unpaused waits reached 86.2 h; a pause has no bound. The 14.0% NAV margin does not cover that: the loss is the exit, not the price.

**Three conditions that change the verdict**
1. **Listing:** Morpho Blue and at least 3 independent liquidator contracts return `isKyc = true` (reject to capped approval).
2. **Redemption liquidity:** an `eth_call` of `redeemIns` at the cap succeeds, or p90 queue latency stays at or under 48 h for 90 days (now 26.6 h). If neither holds the cap halves to $0.5M.
3. **Revocation exposure (replaces the maintainer-power condition):** the vault treats the whole cap as a loss it accepts, so exposure to this market is at most 1% of vault assets (a vault of at least $100M for a $1.0M cap). Anyone can read the triggers that set the cap to $0 for new supply: `isKyc` or `isBanned` changing for Morpho Blue or a listed liquidator, `pausedWithdraw()` true, or the NAV feed older than 5 days. They protect new money, not positions already open. I dropped the 24 h timelock and a written commitment as limits: the signers that would be limited control both.

## 6. Decision rules
- Supply cap $1.0M and at most 1% of vault assets. **Both are judgment, not derived;** the loss they allow is the full amount lent. I dropped a cap of 5% of the Ethereum token's assets: that base moves with bridging (it changed by -75.1%, from $80.4M on 2026-05-18 to $20.0M now, at today's NAV). The measured anchor: $1.0M is 1.4 times the median settled day. Today it is also 5.0% of the Ethereum token's assets.
- LLTV 86.0%, chosen from Morpho's allowed steps; nothing in the data picks it over 91.5%. Incentive 4.4% (Morpho formula), against 2.6% at 91.5% and 7.4% at 77%. The NAV margin is 14.0%.
- Oracle: Chainlink-style adapter on the TBILL feed, which one operator key posts, so the issuer sets the liquidation trigger. Pause the market if the feed is older than 5 days (longest observed gap 4.0 days; the vault reverts at 7).

## 7. Gate (answers from the evidence above)
| # | Question | Answer | Effect |
|---|---|---|---|
| G1 | Is Morpho Blue approved by the KYC manager? | No | **Blocks** |
| G2 | Are three independent liquidator contracts approved? | No: no TBILL market exists on any chain, so listed liquidators cannot be tested; the 8 busiest Morpho liquidators tested are not approved | **Blocks** |
| G3 | Can a rule burn or move a protocol balance without the holder's approval? | Yes (`burnFrom`, `reIssue`; used 11 and 15 times) | Flag: cap is a full loss |
| G4 | Can one key pause withdrawals? | Yes (controller operator, single key) | Flag: stress case in section 5 |
| G5 | Can the KYC manager owner revoke or ban Morpho Blue at any time? | Yes (Safe 3 of 4); collateral withdrawal and liquidation then revert | Flag: amount at risk is the full amount lent; condition 3 |
| G6 | Is p90 exit latency 48 h or less, and is the funder of redemptions known? | Latency yes (26.6 h, p90); funder no; 12 unmatched requests; 6 cancels, reasons not shown | Flag |
| G7 | Does on-chain USDC cover the pending queue? | No ($0.69 vs $351,271) | Flag |
| G8 | Does one key post the price that sets liquidation? | Yes (oracle operator, single key) | Flag: 5-day feed rule |

## 8. Verdict and sizing
**Reject (G1, G2).** If both clear: **approve with limits as a pilot**, supply cap about $1.0M. The size is tied to the downside: in a freeze, burn, revocation or paused exit the loss is the full amount lent, so the cap is what the vault accepts losing outright (at most 1% of its assets), while the 14.0% NAV margin covers only price risk. Limits per flag: G3, G5 the full-loss cap and condition 3; G4, G8 the 5-day feed rule; G6, G7 condition 2.

## 9. Honest limits
- **Small, concentrated token on Ethereum:** 11 Ethereum holders besides the vault's queued shares; top 1 holds 54.8% and top 5 92.8%, so an Ethereum market would have one or two borrowers.
- **Other chains:** BNB supply is read at 00:00 UTC for 184 days and logs on days it moved by over 1M tokens; the XRP Ledger is quoted from rwa.xyz; the issuer was not asked about the burn or the BNB mints. Business-day counts use a hand-typed federal holiday list.
- **Simulation and tail:** one holder wallet, one block; latency covers 200 pairs and is one operator's behaviour. Liquidation evidence is one USCC liquidation and none on EUTBL.
- **Not answered:** a lender's legal claim on a fund domiciled in the British Virgin Islands, and recovery after a ban.
- **Coverage:** 50 vaults plus a market search; DEX absence rests on one aggregator; the KYC manager's strict flag (true) is not read by the vault code; comparables' admin powers were not assessed. Scorecard labels P11, P19, P20, A3, A7, U1, U2 are set by reading.
- **Proxy that could break the conclusion:** the NAV series assumes honest posting; the only guard is a deviation check against a reference value an admin can reset.
- **Scorecard:** 19 hit, 6 partial, 7 miss of 32 (`SCORECARD.md`).

## 10. Reproducibility
`python3 scripts/build_all.py` recomputes every number offline from `data/raw/*.json` (all but `defillama_tbill_tvl.json` and `dexscreener_tbill_eth.json`, which it does not read), rebuilds `data/results.json`, `SCORECARD.md`, `memo.md`, `article.md` and `post.md`, compares each byte for byte with the committed file and exits 1 on any difference; it writes them only with `--write`. Fetch scripts (Foundry `cast`, network): `scripts/fetch_*.py`, including `fetch_other_chains.py` for BNB Chain and Arbitrum. Individual addresses are replaced by ids before saving; public protocol and issuer contracts keep theirs. Every call is read-only (`eth_call`, `eth_getLogs`).
