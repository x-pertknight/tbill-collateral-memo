# PREDICTIONS: OpenEden TBILL (Ethereum) as Morpho collateral

Written 16 Nov 2026 after reading the docs and contract source, before any liquidity, holder,
supply or price measurement. Scoring (hit / miss / partial, with the measured value) is added
after the data pull, including the misses. Confidence is my own probability that the value falls
inside the range.

| # | Quantity (how it will be measured) | Prediction | Confidence |
|---|---|---|---|
| P1 | Morpho Blue core contract is KYC-whitelisted in the TBILL KYC manager (`isKyc`) | No (false) | 85% |
| P2 | Number of non-issuer contract addresses that are KYC-whitelisted and hold TBILL (aggregate count) | 0 to 6 | 70% |
| P3 | TBILL (Ethereum) total supply today | 25M to 150M tokens (point guess ~70M) | 60% |
| P4 | Supply change over the last 90 days | between −30% and +40% | 70% |
| P5 | Holders with balance above 0 (count) | 15 to 150 | 65% |
| P6 | Share of supply held by the 5 largest holders (aggregate; contracts and treasury included) | 60% to 95% | 70% |
| P7 | NAV per token (oracle answer / 1e8) | 1.10 to 1.20 | 75% |
| P8 | Oracle update cadence over the last 365 days (distinct days with a new posted price; longest gap) | Oracle posts a new value on 230 to 270 distinct days; longest gap between updates 3 to 5 days | 70% |
| P9 | Largest single-day NAV step in the last 365 days | under +0.03%, and no negative step | 80% |
| P10 | Annualised NAV growth over the last 90 days | 3.0% to 4.4% | 70% |
| P11 | A DEX pool with TBILL and at least $50k TVL exists on Ethereum | No | 80% |
| P12 | Instant-redeem path (`redemptionContract` set and not paused) is live | Yes | 65% |
| P13 | USDC liquidity in the redemption path today (via `checkLiquidity()`) | $0.5M to $15M | 55% |
| P14 | Redemption of $1M of TBILL clears instantly (single call simulated, no state change) | Yes if P12 holds | 55% |
| P15 | Redemption queue length at measurement time | 0 to 5 pending requests | 70% |
| P16 | Fee manager: redemption transaction fee | 5 bps (0.05%) exactly | 75% |
| P17 | Proxy admin / owner is a multisig contract, not an EOA | Multisig with threshold 2 to 4 of 3 to 7 signers | 65% |
| P18 | Maintainer role is held by a single address | Yes | 60% |
| P19 | Verdict reached by the memo | Reject as drafted (no whitelist path for Morpho and liquidators), or approve with limits only on the condition that the issuer whitelists the Morpho contracts | Reject or conditional: 85%; unconditional approve: under 5% |
| P20 | If limits are proposed: LLTV | 77% to 91.5% (Morpho-enabled steps; most likely 86%) | 60% |
| P21 | If limits are proposed: supply cap | $1M to $10M, set below the measured instant-redemption capacity | 55% |

## Kill condition (checked at end of day 1, after the first data pull)

Stop the study and report, with no memo, if either holds:

1. **Step 0 failure** (already checked: **not triggered**). Every tokenized T-bill in scope is already held by the large Morpho vaults. TBILL is absent, so this does not apply.
2. **No liquidity to measure.** Neither of these is true: (a) a DEX pool with TBILL has at least $50k TVL; (b) the issuer's redemption path (`redemptionContract`) can be read and holds at least $100k of USDC or has a visible queue. If both are false, the asset has no on-chain exit liquidity I can measure, and the result is "killed: nothing to measure".

Not a kill: Morpho Blue being absent from the whitelist (P1). That is a finding and leads to a reject or conditional verdict.

## Failure modes I am guarding against (from the brief)

- Misreading redemption terms: the docs say queue, the code also has an instant path. I will read live state, not trust either.
- Measuring liquidity in a thin or unusual window: take samples on weekdays and across a weekend, and record the window.
- Treating NAV as a market price: the oracle posts NAV once a day. Any price comparison uses a separate exit-price measure (redemption quote or pool price), and NAV is never called a market price.

## Method (for review at Gate 1)

Order of data: Morpho API, then DefiLlama API, then public RPC with the verified ABIs, then issuer documents. No Dune.
All numbers come from one script, `build_all.py` (to be written), that reads saved raw JSON in `data/`.
Nothing is committed, pushed or published without approval.
