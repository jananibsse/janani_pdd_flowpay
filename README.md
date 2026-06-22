# FlowPay

FlowPay is a comprehensive digital wallet and payment application designed to make financial transactions seamless, secure, and instant. This document outlines the core transactional flows of the application.

## How FlowPay Receives Money

FlowPay acts as a digital intermediary for your funds. The app receives money through several channels:

1.  **Bank Account Linking:** Users can link their personal bank accounts (via secure API integrations like Plaid or direct bank transfers) to pull funds directly into their FlowPay ecosystem.
2.  **Card Deposits:** Users can add funds using debit or credit cards. The payment gateway processes the transaction and credits the user's FlowPay wallet.
3.  **Peer-to-Peer (P2P) Transfers:** Users can receive money instantly from other FlowPay users. When a sender initiates a transfer, the app updates the internal ledger, immediately reflecting the new balance in the receiver's wallet.
4.  **Direct Deposits:** Users can set up FlowPay to receive direct deposits from employers or other institutions using their provided FlowPay routing and account numbers.

## How FlowPay Transacts Money

When transacting within the FlowPay network or externally, the app ensures secure and swift processing:

*   **Internal Ledger:** For P2P transfers (FlowPay user to FlowPay user), transactions are processed on our internal ledger. This means funds don't actually move between traditional banks immediately; instead, user balances are instantly updated in our database, allowing for zero-delay transfers.
*   **Payment Gateways & Networks:** When making purchases (e.g., using a FlowPay virtual/physical card or paying a merchant), the app routes the transaction through standard payment networks (Visa/Mastercard) or directly to the merchant's payment processor.
*   **Security & Verification:** Every transaction requires authentication (PIN, biometric, or password) and passes through automated fraud-detection algorithms before authorization.

## Transferring Funds

Moving money between your FlowPay Wallet and your traditional Bank Account is simple and secure.

### Bank Account to Wallet (Adding Funds)

To top up your FlowPay wallet from your bank account:

1.  Open the FlowPay app and navigate to the **"Add Money"** or **"Deposit"** section.
2.  Select your previously linked bank account as the funding source.
3.  Enter the amount you wish to transfer.
4.  Confirm the transaction.
    *   *Note: Standard ACH transfers typically take 1-3 business days to clear, while instant transfers (via supported debit cards) reflect immediately, sometimes incurring a small fee.*

### Wallet to Bank Account (Withdrawing Funds)

To move money from your FlowPay wallet back to your personal bank account:

1.  Open the FlowPay app and tap on **"Transfer"** or **"Withdraw"**.
2.  Select **"Transfer to Bank"**.
3.  Choose the destination bank account.
4.  Enter the withdrawal amount.
5.  Select the transfer speed:
    *   **Standard Transfer:** Free, usually takes 1-3 business days (ACH).
    *   **Instant Transfer:** Funds arrive in minutes (requires an eligible linked debit card) for a small percentage fee.
6.  Review the details and confirm the transfer. The app deducts the funds from your wallet ledger and initiates the bank payout via our payment processor.
