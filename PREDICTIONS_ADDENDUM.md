# PREDICTIONS_ADDENDUM

Written 16 Nov 2026 after Gate 1 approval, before reading the EUTBL and USCC transfer rules or any
Morpho market data for them. `PREDICTIONS.md` is unchanged. Scoring is added after measurement.

## Comparables: EUTBL and USCC (found as collateral in the top-50 Morpho vaults)

Scope per comparable: transfer rule (docs + verified contract), whether Morpho Blue is allowed to
hold the token and how, Morpho market oracle type, LLTV, supplied amount. Time box: half a day
each; if exceeded, the comparable is dropped and the memo says so.

| # | Quantity | Prediction | Confidence |
|---|---|---|---|
| A1 | EUTBL transfers are permissioned (allowlist check in the token contract) | Yes | 90% |
| A2 | Morpho Blue core is allowed to hold EUTBL | Yes, directly on the allowlist | 60% |
| A3 | EUTBL Morpho market oracle is a fixed-formula adapter on the issuer's NAV feed, not a DEX price | Yes | 70% |
| A4 | EUTBL market LLTV | 86% or 91.5% | 55% |
| A5 | USCC transfers are permissioned (allowlist check in the token contract) | Yes | 90% |
| A6 | Morpho Blue core is allowed to hold USCC | Yes, directly on the allowlist | 55% |
| A7 | USCC Morpho market oracle is a NAV-based adapter | Yes | 65% |
| A8 | USCC market LLTV | 77% to 86% | 55% |
| A9 | Supplied amount in each comparable market | $0.5M to $50M | 55% |

If A2 or A6 is "no", the token reaches Morpho by another route (a wrapper token, or a separate
allowlisted holder); that route is recorded as measured.

## Issuer's own token route: USDO and cUSDO

Measured facts only: markets, oracle, supplied amount, transfer rule, and how the route differs
from TBILL. No prediction on why supply is near zero.

| # | Quantity | Prediction | Confidence |
|---|---|---|---|
| U1 | USDO and cUSDO transfers need no KYC check on the receiver (unlike TBILL) | USDO: no check at transfer; cUSDO: no check | 55% |
| U2 | The USDO and cUSDO Morpho markets use an oracle on the issuer's own price or rate feed | Yes | 60% |

## Test conditions set before the data pull

- Read-only. P14 (a $1M redemption clears instantly) is tested only with `eth_call`. No signing, no
  sending, no wallet or key. If simulation from a whitelisted address is not possible, P14 is
  marked untestable.
- Individual holders are reported in aggregate only (counts, concentration shares). No addresses.
  Public protocol and issuer contracts are named with addresses.
- Admin powers are written as: function name, role that holds it, live role-holder type
  (multisig threshold or single key). No adjectives.
- NAV (what the oracle posts) and exit price (what a redeemer or seller can get) stay separate
  everywhere.

## Post-measurement notes (added after the data pull; predictions above are unchanged)

- USCC is described by its issuer as a crypto carry fund (basis strategies plus U.S. Treasuries), not a T-bill fund. It is used here as a comparable for the transfer rule only.
- A9 was scored per token: EUTBL's largest market meets the range; USCC's largest market does not.
- TBILL is also issued on BNB Chain, Arbitrum and the XRP Ledger. The issuer's deployment list in the docs copy shows the first two; I did not read it for other chains before writing the predictions or the first memo. P3 and P4 are scored on the Ethereum token (the subject of the memo); the all-chain supply is reported next to them in `SCORECARD.md`. An independent review on 17 November 2026 caught this.
