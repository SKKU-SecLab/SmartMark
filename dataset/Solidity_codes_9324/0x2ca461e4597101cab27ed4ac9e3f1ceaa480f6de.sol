

pragma solidity ^0.4.24;



contract Arbitrator {


    enum DisputeStatus {Waiting, Appealable, Solved}

    modifier requireArbitrationFee(bytes _extraData) {

        require(msg.value >= arbitrationCost(_extraData), "Not enough ETH to cover arbitration costs.");
        _;
    }
    modifier requireAppealFee(uint _disputeID, bytes _extraData) {

        require(msg.value >= appealCost(_disputeID, _extraData), "Not enough ETH to cover appeal costs.");
        _;
    }

    event DisputeCreation(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    event AppealPossible(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    event AppealDecision(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    function createDispute(uint _choices, bytes _extraData) public requireArbitrationFee(_extraData) payable returns(uint disputeID) {}


    function arbitrationCost(bytes _extraData) public view returns(uint fee);


    function appeal(uint _disputeID, bytes _extraData) public requireAppealFee(_disputeID,_extraData) payable {

        emit AppealDecision(_disputeID, IArbitrable(msg.sender));
    }

    function appealCost(uint _disputeID, bytes _extraData) public view returns(uint fee);


    function appealPeriod(uint _disputeID) public view returns(uint start, uint end) {}


    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status);


    function currentRuling(uint _disputeID) public view returns(uint ruling);

}


interface IArbitrable {

    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);

    event Dispute(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID, uint _evidenceGroupID);

    event Evidence(Arbitrator indexed _arbitrator, uint indexed _evidenceGroupID, address indexed _party, string _evidence);

    event Ruling(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    function rule(uint _disputeID, uint _ruling) external;

}


contract MultipleArbitrableTransactionWithFee is IArbitrable {



    uint8 constant AMOUNT_OF_CHOICES = 2;
    uint8 constant SENDER_WINS = 1;
    uint8 constant RECEIVER_WINS = 2;

    enum Party {Sender, Receiver}
    enum Status {NoDispute, WaitingSender, WaitingReceiver, DisputeCreated, Resolved}

    struct Transaction {
        address sender;
        address receiver;
        uint amount;
        uint timeoutPayment; // Time in seconds after which the transaction can be automatically executed if not disputed.
        uint disputeId; // If dispute exists, the ID of the dispute.
        uint senderFee; // Total arbitration fees paid by the sender.
        uint receiverFee; // Total arbitration fees paid by the receiver.
        uint lastInteraction; // Last interaction for the dispute procedure.
        Status status;
    }

    address public feeRecipient; // Address which receives a share of receiver payment.
    uint public feeRecipientBasisPoint; // The share of fee to be received by the feeRecipient, down to 2 decimal places as 550 = 5.5%.
    Transaction[] public transactions;
    bytes public arbitratorExtraData; // Extra data to set up the arbitration.
    Arbitrator public arbitrator; // Address of the arbitrator contract.
    uint public feeTimeout; // Time in seconds a party can take to pay arbitration fees before being considered unresponding and lose the dispute.


    mapping (uint => uint) public disputeIDtoTransactionID; // One-to-one relationship between the dispute and the transaction.


    event Payment(uint indexed _transactionID, uint _amount, address _party);

    event FeeRecipientPayment(uint indexed _transactionID, uint _amount);

    event FeeRecipientChanged(address indexed _oldFeeRecipient, address indexed _newFeeRecipient);

    event HasToPayFee(uint indexed _transactionID, Party _party);

    event Ruling(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    event TransactionCreated(uint _transactionID, address indexed _sender, address indexed _receiver, uint _amount);


    constructor (
        Arbitrator _arbitrator,
        bytes _arbitratorExtraData,
        address _feeRecipient,
        uint _feeRecipientBasisPoint,
        uint _feeTimeout
    ) public {
        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
        feeRecipient = _feeRecipient;
        feeRecipientBasisPoint = _feeRecipientBasisPoint;
        feeTimeout = _feeTimeout;
    }

    function createTransaction(
        uint _timeoutPayment,
        address _receiver,
        string _metaEvidence
    ) public payable returns (uint transactionID) {

        transactions.push(Transaction({
            sender: msg.sender,
            receiver: _receiver,
            amount: msg.value,
            timeoutPayment: _timeoutPayment,
            disputeId: 0,
            senderFee: 0,
            receiverFee: 0,
            lastInteraction: now,
            status: Status.NoDispute
        }));
        emit MetaEvidence(transactions.length - 1, _metaEvidence);
        emit TransactionCreated(transactions.length - 1, msg.sender, _receiver, msg.value);

        return transactions.length - 1;
    }

    function calculateFeeRecipientAmount(uint _amount) internal view returns(uint feeAmount){

        feeAmount = (_amount * feeRecipientBasisPoint) / 10000;
    }

    function changeFeeRecipient(address _newFeeRecipient) public {

        require(msg.sender == feeRecipient, "The caller must be the current Fee Recipient");
        feeRecipient = _newFeeRecipient;

        emit FeeRecipientChanged(msg.sender, _newFeeRecipient);
    }

    function pay(uint _transactionID, uint _amount) public {

        Transaction storage transaction = transactions[_transactionID];
        require(transaction.sender == msg.sender, "The caller must be the sender.");
        require(transaction.status == Status.NoDispute, "The transaction shouldn't be disputed.");
        require(_amount <= transaction.amount, "The amount paid has to be less than or equal to the transaction.");

        transaction.amount -= _amount;

        uint feeAmount = calculateFeeRecipientAmount(_amount);
        feeRecipient.send(feeAmount);
        transaction.receiver.send(_amount - feeAmount);

        emit Payment(_transactionID, _amount, msg.sender);
        emit FeeRecipientPayment(_transactionID, feeAmount);
    }

    function reimburse(uint _transactionID, uint _amountReimbursed) public {

        Transaction storage transaction = transactions[_transactionID];
        require(transaction.receiver == msg.sender, "The caller must be the receiver.");
        require(transaction.status == Status.NoDispute, "The transaction shouldn't be disputed.");
        require(_amountReimbursed <= transaction.amount, "The amount reimbursed has to be less or equal than the transaction.");

        transaction.sender.transfer(_amountReimbursed);
        transaction.amount -= _amountReimbursed;
        emit Payment(_transactionID, _amountReimbursed, msg.sender);
    }

    function executeTransaction(uint _transactionID) public {

        Transaction storage transaction = transactions[_transactionID];
        require(now - transaction.lastInteraction >= transaction.timeoutPayment, "The timeout has not passed yet.");
        require(transaction.status == Status.NoDispute, "The transaction shouldn't be disputed.");

        uint amount = transaction.amount;
        transaction.amount = 0;
        uint feeAmount = calculateFeeRecipientAmount(amount);
        feeRecipient.send(feeAmount);
        transaction.receiver.send(amount - feeAmount);

        emit FeeRecipientPayment(_transactionID, feeAmount);

        transaction.status = Status.Resolved;
    }

    function timeOutBySender(uint _transactionID) public {

        Transaction storage transaction = transactions[_transactionID];
        require(transaction.status == Status.WaitingReceiver, "The transaction is not waiting on the receiver.");
        require(now - transaction.lastInteraction >= feeTimeout, "Timeout time has not passed yet.");        

        if (transaction.receiverFee != 0) {
            transaction.receiver.send(transaction.receiverFee);
            transaction.receiverFee = 0;
        }
        executeRuling(_transactionID, SENDER_WINS);
    }

    function timeOutByReceiver(uint _transactionID) public {

        Transaction storage transaction = transactions[_transactionID];
        require(transaction.status == Status.WaitingSender, "The transaction is not waiting on the sender.");
        require(now - transaction.lastInteraction >= feeTimeout, "Timeout time has not passed yet.");

        if (transaction.senderFee != 0) {
            transaction.sender.send(transaction.senderFee);
            transaction.senderFee = 0;
        }
        executeRuling(_transactionID, RECEIVER_WINS);
    }

    function payArbitrationFeeBySender(uint _transactionID) public payable {

        Transaction storage transaction = transactions[_transactionID];
        uint arbitrationCost = arbitrator.arbitrationCost(arbitratorExtraData);

        require(transaction.status < Status.DisputeCreated, "Dispute has already been created or because the transaction has been executed.");
        require(msg.sender == transaction.sender, "The caller must be the sender.");

        transaction.senderFee += msg.value;
        require(transaction.senderFee >= arbitrationCost, "The sender fee must cover arbitration costs.");

        transaction.lastInteraction = now;

        if (transaction.receiverFee < arbitrationCost) {
            transaction.status = Status.WaitingReceiver;
            emit HasToPayFee(_transactionID, Party.Receiver);
        } else { // The receiver has also paid the fee. We create the dispute.
            raiseDispute(_transactionID, arbitrationCost);
        }
    }

    function payArbitrationFeeByReceiver(uint _transactionID) public payable {

        Transaction storage transaction = transactions[_transactionID];
        uint arbitrationCost = arbitrator.arbitrationCost(arbitratorExtraData);

        require(transaction.status < Status.DisputeCreated, "Dispute has already been created or because the transaction has been executed.");
        require(msg.sender == transaction.receiver, "The caller must be the receiver.");

        transaction.receiverFee += msg.value;
        require(transaction.receiverFee >= arbitrationCost, "The receiver fee must cover arbitration costs.");

        transaction.lastInteraction = now;
        if (transaction.senderFee < arbitrationCost) {
            transaction.status = Status.WaitingSender;
            emit HasToPayFee(_transactionID, Party.Sender);
        } else { // The sender has also paid the fee. We create the dispute.
            raiseDispute(_transactionID, arbitrationCost);
        }
    }

    function raiseDispute(uint _transactionID, uint _arbitrationCost) internal {

        Transaction storage transaction = transactions[_transactionID];
        transaction.status = Status.DisputeCreated;
        transaction.disputeId = arbitrator.createDispute.value(_arbitrationCost)(AMOUNT_OF_CHOICES, arbitratorExtraData);
        disputeIDtoTransactionID[transaction.disputeId] = _transactionID;
        emit Dispute(arbitrator, transaction.disputeId, _transactionID, _transactionID);

        if (transaction.senderFee > _arbitrationCost) {
            uint extraFeeSender = transaction.senderFee - _arbitrationCost;
            transaction.senderFee = _arbitrationCost;
            transaction.sender.send(extraFeeSender);
        }

        if (transaction.receiverFee > _arbitrationCost) {
            uint extraFeeReceiver = transaction.receiverFee - _arbitrationCost;
            transaction.receiverFee = _arbitrationCost;
            transaction.receiver.send(extraFeeReceiver);
        }
    }

    function submitEvidence(uint _transactionID, string _evidence) public {

        Transaction storage transaction = transactions[_transactionID];
        require(
            msg.sender == transaction.sender || msg.sender == transaction.receiver,
            "The caller must be the sender or the receiver."
        );
        require(
            transaction.status < Status.Resolved,
            "Must not send evidence if the dispute is resolved."
        );

        emit Evidence(arbitrator, _transactionID, msg.sender, _evidence);
    }

    function appeal(uint _transactionID) public payable {

        Transaction storage transaction = transactions[_transactionID];

        arbitrator.appeal.value(msg.value)(transaction.disputeId, arbitratorExtraData);
    }

    function rule(uint _disputeID, uint _ruling) public {

        uint transactionID = disputeIDtoTransactionID[_disputeID];
        Transaction storage transaction = transactions[transactionID];
        require(msg.sender == address(arbitrator), "The caller must be the arbitrator.");
        require(transaction.status == Status.DisputeCreated, "The dispute has already been resolved.");

        emit Ruling(Arbitrator(msg.sender), _disputeID, _ruling);

        executeRuling(transactionID, _ruling);
    }

    function executeRuling(uint _transactionID, uint _ruling) internal {

        Transaction storage transaction = transactions[_transactionID];
        require(_ruling <= AMOUNT_OF_CHOICES, "Invalid ruling.");

        uint amount = transaction.amount;
        uint senderArbitrationFee = transaction.senderFee;
        uint receiverArbitrationFee = transaction.receiverFee;

        transaction.amount = 0;
        transaction.senderFee = 0;
        transaction.receiverFee = 0;

        uint feeAmount;

        if (_ruling == SENDER_WINS) {
            transaction.sender.send(senderArbitrationFee + amount);
        } else if (_ruling == RECEIVER_WINS) {
            feeAmount = calculateFeeRecipientAmount(amount);

            feeRecipient.send(feeAmount);
            transaction.receiver.send(receiverArbitrationFee + amount - feeAmount);

            emit FeeRecipientPayment(_transactionID, feeAmount);
        } else {
            uint split_arbitration = senderArbitrationFee / 2;
            uint split_amount = amount / 2;
            feeAmount = calculateFeeRecipientAmount(split_amount);

            transaction.sender.send(split_arbitration + split_amount);
            feeRecipient.send(feeAmount);
            transaction.receiver.send(split_arbitration + split_amount - feeAmount);

            emit FeeRecipientPayment(_transactionID, feeAmount);
        }

        transaction.status = Status.Resolved;
    }


    function getCountTransactions() public view returns (uint countTransactions) {

        return transactions.length;
    }

    function getTransactionIDsByAddress(address _address) public view returns (uint[] transactionIDs) {

        uint count = 0;
        for (uint i = 0; i < transactions.length; i++) {
            if (transactions[i].sender == _address || transactions[i].receiver == _address)
                count++;
        }

        transactionIDs = new uint[](count);

        count = 0;

        for (uint j = 0; j < transactions.length; j++) {
            if (transactions[j].sender == _address || transactions[j].receiver == _address)
                transactionIDs[count++] = j;
        }
    }
}