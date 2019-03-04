# Electronic funds transfer (EFT) smart contract for Ethereum
This a proof-of-concept of an electronic funds transfer (EFT) smart contract for the [Ethereum](https://github.com/ethereum/wiki/wiki) blockchain written in [Solidity](https://solidity.readthedocs.io/en/latest/index.html), Ethereum's smart contract language. This was created as part of our CIBC ReHacktor hackathon project in 2015. The smart contract was designed and written by myself, with contributions from A. Kozyrev to introduce a correlation ID. The hackathon idea of an EFT smart contract is credited to A. Kozyrev.

## Background

When a client pays a bill or sends money from one bank to another, it takes 2-5 days to process. This is because money is not sent in real-time, but transactions relative to another financial institution (FI) are summed and processed as a batch at the end of the day. A EFT smart contract solves this problem by sharing a ledger between all concerned FIs--a consortium blockchain. Any FI that is part of the consortium and enters into the smart contract sends the EFT transaction on the shared ledger in real-time and does not require a third party to clear and settle the inter-bank transactions.

## Smart Contract in Solidity

The smart contract was *not* designed to use Ethereum's cryptocurrency (ETH), or to link Canadian Dollars (CAD) to ETH. We make use of only the shared ledger that records the inter-bank transactions and the ability of FIs to consent in a smart contract to a deposit or withdrawal on behalf of the customer's bank account to the other FI's customer's bank account. Here is an example use case.

### 1. Request transfer

Bank A executes `requestTransfer` with a chosen `correlationId`, `fromAccount` = 12345 (bank account number at Bank A), `address` = <blockchain address of Bank B>, `toAccount` = 98765 (bank account number at Bank B), `amount` = 1000 (CAD), and `transactionType` = `Deposit`. The function generates a `transferID` by hashing the combination of the blockchain address of Bank A, the blockchain address of Bank B, bank account 12345 at Bank A, bank account 98765 at Bank B, the amount, the timestamp of the blockchain transaction, and the correlationId.
```
  bytes32 transferId = sha256(msg.sender, to, fromAccount, toAccount, amount, now, correlationId);
```
Hashing is used to simulate a universally-unique identifier (UUID). The transferId (key) and Transfer object (value) are initialized on the mapping (hash table) `transfers`. Here is the `Transfer` structure: 
  
```
  struct Transfer {
        address from;
        address to;
        uint fromAccount;
        uint toAccount;
        uint amount;
        TransactionType txnType;
        State state;
        uint timestamp;
    }
```
The values are populated and the transfer's `State` is set to `Initiated`. A `TransferRequested` event is recorded on the blockchain with Bank A's blockchain address, Bank B's blockchain address, the correlation ID, and the transfer ID.

### 2. Get details of transfer request

Bank B can call getters like `getFromAccount(bytes32 transferId) returns (uint)` and `getAmount(bytes32 transferId) returns (uint)` to get details of the transfer request. The smart contract's getters allow only the sender and receiver to access these confidential details by checking that the blockchain address of the entity requesting the details corresponds to the sender or receiver's blockchain address for the transfer request.

### 3. Confirm transfer

Bank B executes `confirmTransfer` with the `transferId`. The function checks that the blockchain address matches the intended receiver, and changes the `Transfer`'s state to `Confirmed`. A `TransferConfirmed` event is posted on the blockchain, notifying the sender.
