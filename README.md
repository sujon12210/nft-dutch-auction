# NFT Dutch Auction

An expert-level, secure sales engine designed to conduct non-fungible token (NFT) initial offerings using a public linear-descending Dutch auction. The contract dynamically computes asset prices based on the elapsed time since the auction started, matching pricing structures directly with real market demand while protecting systems from gas war exhaustion.

## Features
- **Linear Price Decay:** Automatically scales down pricing over a fixed timeframe toward a defined floor target.
- **Refund-On-Purchase Flow:** Safely handles over-funding scenarios inside public transactions by returning surplus native balances instantly.
- **Immutable State Configuration:** Restricts dynamic variables to minimize runtime storage slots and reduce gas overhead.

## Getting Started

1. Install project packages:
   ```bash
   npm install
