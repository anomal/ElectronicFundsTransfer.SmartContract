# Electronic funds transfer (EFT) smart contract for Ethereum
This a proof-of-concept of an electronic funds transfer (EFT) smart contract for the [Ethereum](https://github.com/ethereum/wiki/wiki) blockchain written in [Solidity](https://solidity.readthedocs.io/en/latest/index.html), Ethereum's smart contract language. This was created as part of our CIBC ReHacktor hackathon project in 2015. The smart contract was designed and written by myself, with contributions from A. Kozyrev to introduce a correlation ID. The hackathon idea of an EFT smart contract is credited to A. Kozyrev.

## Background

When a client pays a bill or sends money from one bank to another, it takes 2-5 days to process. This is because money is not sent in real-time, but transactions relative to another financial institution (FI) are summed and processed as a batch at the end of the day. A EFT smart contract solves this problem by sharing a ledger between all concerned FIs--a consortium blockchain. Any FI that is part of the consortium and enters into the smart contract has the EFT transaction on the shared ledger and does not require a third party to clear and settle the transactions.
