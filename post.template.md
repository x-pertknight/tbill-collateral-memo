What it would take for OpenEden's TBILL to become collateral on Morpho. The token moves only between addresses the issuer approves, and Morpho's contract is not on that list yet.

What the token is

TBILL is a token backed by short-dated US Treasury bills. Redemptions go through a queue worked in order.

The rule that decides it

Morpho's lending contract holds every borrower's collateral, and whoever steps in when a loan goes bad receives it. Both must be on the issuer's approved list. On {{as_of|date}} the lending contract is not on it, and neither is any of the {{liq.top_tested_word}} busiest such parties tested.

What the record shows

Across Ethereum and BNB Chain, supply grew from about {{chains.two_chain_first_m|.0f}} million tokens in {{chains.two_chain_first_date|month_year}} to about {{chains.two_chain_now_m|.0f}} million now. On Ethereum alone it is about {{supply.fall_vs_peak_pct|.0f}}% below its {{supply.peak_date|month}} peak. More than half of that fall matches a same-size mint on BNB Chain. Of the redemption requests since {{queue.paired_from|month}}, {{queue.paired_requests}} could be matched to payouts, and all settled by the next US business day, as the issuer's documents say is typical.

The conditions

The issuer's list would have to include Morpho's lending contract and at least {{liq.min_listed_word}} independent parties who take over bad loans. That is necessary and not sufficient. The issuer can also remove an address later, so a lender should size each loan for that risk.

Limits

Fewer than one in ten requests since {{queue.paired_from|month}} are missing from that record: they were cancelled or have no matched payout, and the data does not show why. It does not show how much the vault could pay at once. No sign of demand to borrow against the token was found, and the issuer was not asked about the burn or the BNB Chain mints.
