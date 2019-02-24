contract MultiEFT {

    enum State { None, Initiated, Confirmed }

    enum TransactionType { Unknown, Deposit, Withdrawal }

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
    
    // hashtable of transfers
    mapping (bytes32 => Transfer) transfers;

    // events are logging events
    event TransferRequested(address from, address to, bytes32 correlationId, bytes32 transferId);
    event TransferConfirmed(address from, bytes32 transferId);
    event SimpleEvent();


    function sendSimpleEvent () returns (bool) {
        SimpleEvent();
        return true;
    }

    // msg.sender (from FI) requests a transfer
    function requestTransfer(bytes32 correlationId, uint fromAccount, address to, uint toAccount, uint amount, TransactionType transactionType) {
        
	if (transactionType == TransactionType.Unknown) return;

        SimpleEvent();
        
        bytes32 transferId = sha256(msg.sender, to, fromAccount, toAccount, amount, now, correlationId);
        Transfer transfer = transfers[transferId];

        // make sure it's a new transfer (can we check for defined here?)
        if (transfer.state != State.None) return;

        transfer.from           = msg.sender;
        transfer.to             = to;
        transfer.fromAccount    = fromAccount;
        transfer.toAccount      = toAccount;
        transfer.amount         = amount;
        transfer.txnType	= transactionType;
        transfer.state          = State.Initiated;
        transfer.timestamp	= now;

        // Notify the receiver that the transfer is requested
        TransferRequested(msg.sender, to, correlationId, transferId);
    }

    // msg.sender (to FI) confirms a transfer
    function confirmTransfer(bytes32 transferId) returns (bool) {
        Transfer transfer = transfers[transferId];
        if (msg.sender != transfer.to || transfer.state != State.Initiated) return false;
        
        transfer.state = State.Confirmed;

        // notify sender that the transfer is confirmed
        TransferConfirmed(transfer.from, transferId);
        
        return true;
    }

    
    //
    // Getters, only sender, receiver can access
    //
    function getFrom(bytes32 transferId) returns (address) {
        Transfer transfer = transfers[transferId];
        if (msg.sender != transfer.to && msg.sender != transfer.from) return 0x0;
        return transfer.from;
    }
    function getTo(bytes32 transferId) returns (address) {
        Transfer transfer = transfers[transferId];
        if (msg.sender != transfer.to && msg.sender != transfer.from) return 0x0;
        return transfer.to;
    }
    function getFromAccount(bytes32 transferId) returns (uint) {
        Transfer transfer = transfers[transferId];
        if (msg.sender != transfer.to && msg.sender != transfer.from) return 0;
        return transfer.fromAccount;
    }
    function getToAccount(bytes32 transferId) returns (uint) {
        Transfer transfer = transfers[transferId];
        if (msg.sender != transfer.to && msg.sender != transfer.from) return 0;
        return transfer.toAccount;
    }
    function getAmount(bytes32 transferId) returns (uint) {
        Transfer transfer = transfers[transferId];
        if (msg.sender != transfer.to && msg.sender != transfer.from) return 0;
        return transfer.amount;
    }
    function getState(bytes32 transferId) returns (State) {
        Transfer transfer = transfers[transferId];
        if (msg.sender != transfer.to && msg.sender != transfer.from) return State.None;
        return transfer.state;
    }
    function getTransactionType(bytes32 transferId) returns (TransactionType) {
        Transfer transfer = transfers[transferId];
        if (msg.sender != transfer.to && msg.sender != transfer.from) return TransactionType.Unknown;
        return transfer.txnType;
    }
    function getTimestamp(bytes32 transferId) returns (uint) {
        Transfer transfer = transfers[transferId];
        if (msg.sender != transfer.to && msg.sender != transfer.from) return 0;
        return transfer.timestamp;
    }
}
