


pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


pragma solidity ^0.8.0;



interface CapitalPausable {

    function pauseCapital() external;


    function unpauseCapital() external;

}

contract Timelock {

    using SafeMath for uint256;

    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint256 indexed newDelay);
    event CancelTransaction(
        bytes32 indexed txHash,
        address indexed target,
        string signature,
        bytes data,
        uint256 eta
    );
    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        string signature,
        bytes data,
        uint256 eta
    );
    event QueueTransaction(
        bytes32 indexed txHash,
        address indexed target,
        string signature,
        bytes data,
        uint256 eta
    );

    uint256 public constant GRACE_PERIOD = 3 days;
    uint256 public constant MINIMUM_DELAY = 1 minutes;
    uint256 public constant MAXIMUM_DELAY = 2 days;

    address public admin;
    address public pendingAdmin;
    uint256 public delay;

    mapping(bytes32 => bool) public queuedTransactions;

    modifier onlyAdmin() {

        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    constructor(address admin_, uint256 delay_) {
        require(
            delay_ >= MINIMUM_DELAY,
            "Timelock::constructor: Delay must exceed minimum delay."
        );
        require(
            delay_ <= MAXIMUM_DELAY,
            "Timelock::setDelay: Delay must not exceed maximum delay."
        );

        admin = admin_;
        delay = delay_;
    }

    function setDelay(uint256 delay_) public {

        require(
            msg.sender == address(this),
            "Timelock::setDelay: Call must come from Timelock."
        );
        require(
            delay_ >= MINIMUM_DELAY,
            "Timelock::setDelay: Delay must exceed minimum delay."
        );
        require(
            delay_ <= MAXIMUM_DELAY,
            "Timelock::setDelay: Delay must not exceed maximum delay."
        );
        delay = delay_;

        emit NewDelay(delay);
    }

    function acceptAdmin() public {

        require(
            msg.sender == pendingAdmin,
            "Timelock::acceptAdmin: Call must come from pendingAdmin."
        );
        admin = msg.sender;
        pendingAdmin = address(0);

        emit NewAdmin(admin);
    }

    function setPendingAdmin(address pendingAdmin_) public onlyAdmin {

        pendingAdmin = pendingAdmin_;

        emit NewPendingAdmin(pendingAdmin);
    }

    function queueTransaction(
        address target,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) internal returns (bytes32) {

        require(
            msg.sender == admin,
            "Timelock::queueTransaction: Call must come from admin."
        );
        require(
            eta >= getBlockTimestamp().add(delay),
            "Timelock::queueTransaction: Estimated execution block must satisfy delay."
        );

        bytes32 txHash = keccak256(
            abi.encode(target, signature, keccak256(data), eta)
        );
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(
        address target,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) internal {

        require(
            msg.sender == admin,
            "Timelock::cancelTransaction: Call must come from admin."
        );

        bytes32 txHash = keccak256(
            abi.encode(target, signature, keccak256(data), eta)
        );
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, signature, data, eta);
    }

    function _getRevertMsg(bytes memory _returnData)
        internal
        pure
        returns (string memory)
    {

        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }

    function executeTransaction(
        address target,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) internal returns (bytes memory) {

        require(
            msg.sender == admin,
            "Timelock::executeTransaction: Call must come from admin."
        );

        bytes32 txHash = keccak256(
            abi.encode(target, signature, keccak256(data), eta)
        );
        require(
            queuedTransactions[txHash],
            "Timelock::executeTransaction: Transaction hasn't been queued."
        );
        require(
            getBlockTimestamp() >= eta,
            "Timelock::executeTransaction: Transaction hasn't surpassed time lock."
        );
        require(
            getBlockTimestamp() <= eta.add(GRACE_PERIOD),
            "Timelock::executeTransaction: Transaction is stale."
        );

        queuedTransactions[txHash] = false;

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(
                bytes4(keccak256(bytes(signature))),
                data
            );
        }

        (bool success, bytes memory returnData) = target.call(callData);

        if (!success) {
            revert(_getRevertMsg(returnData));
        }

        emit ExecuteTransaction(txHash, target, signature, data, eta);

        return returnData;
    }

    function getBlockTimestamp() internal view returns (uint256) {

        return block.timestamp;
    }

    function pauseCapital(address target) external {

        require(
            msg.sender == admin,
            "Timelock::pauseCapital: Call must come from admin."
        );
        CapitalPausable(target).pauseCapital();
    }

    function unpauseCapital(address target) external {

        require(
            msg.sender == admin,
            "Timelock::unpauseCapital: Call must come from admin."
        );
        CapitalPausable(target).unpauseCapital();
    }
}


pragma solidity ^0.8.0;


contract Governor is Timelock {

    uint256 public proposalCount;

    struct Proposal {
        uint256 id;
        address proposer;
        uint256 eta;
        address[] targets;
        string[] signatures;
        bytes[] calldatas;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(
        uint256 id,
        address proposer,
        address[] targets,
        string[] signatures,
        bytes[] calldatas,
        string description
    );

    event ProposalQueued(uint256 id, uint256 eta);

    event ProposalExecuted(uint256 id);

    event ProposalCancelled(uint256 id);

    uint256 public constant MAX_OPERATIONS = 32;

    enum ProposalState {
        Pending,
        Queued,
        Expired,
        Executed
    }

    constructor(address admin_, uint256 delay_) Timelock(admin_, delay_) {}

    function propose(
        address[] memory targets,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public returns (uint256) {

        require(
            targets.length == signatures.length &&
                targets.length == calldatas.length,
            "Governor::propose: proposal function information arity mismatch"
        );
        require(targets.length != 0, "Governor::propose: must provide actions");
        require(
            targets.length <= MAX_OPERATIONS,
            "Governor::propose: too many actions"
        );

        proposalCount++;
        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            eta: 0,
            targets: targets,
            signatures: signatures,
            calldatas: calldatas,
            executed: false
        });

        proposals[newProposal.id] = newProposal;

        emit ProposalCreated(
            newProposal.id,
            msg.sender,
            targets,
            signatures,
            calldatas,
            description
        );
        return newProposal.id;
    }

    function queue(uint256 proposalId) public onlyAdmin {

        require(
            state(proposalId) == ProposalState.Pending,
            "Governor::queue: proposal can only be queued if it is pending"
        );
        Proposal storage proposal = proposals[proposalId];
        proposal.eta = block.timestamp + delay;

        for (uint256 i = 0; i < proposal.targets.length; i++) {
            _queueOrRevert(
                proposal.targets[i],
                proposal.signatures[i],
                proposal.calldatas[i],
                proposal.eta
            );
        }

        emit ProposalQueued(proposal.id, proposal.eta);
    }

    function state(uint256 proposalId) public view returns (ProposalState) {

        require(
            proposalCount >= proposalId && proposalId > 0,
            "Governor::state: invalid proposal id"
        );
        Proposal storage proposal = proposals[proposalId];
        if (proposal.executed) {
            return ProposalState.Executed;
        } else if (proposal.eta == 0) {
            return ProposalState.Pending;
        } else if (block.timestamp >= proposal.eta + GRACE_PERIOD) {
            return ProposalState.Expired;
        } else {
            return ProposalState.Queued;
        }
    }

    function _queueOrRevert(
        address target,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) internal {

        require(
            !queuedTransactions[
                keccak256(abi.encode(target, signature, keccak256(data), eta))
            ],
            "Governor::_queueOrRevert: proposal action already queued at eta"
        );
        require(
            queuedTransactions[queueTransaction(target, signature, data, eta)],
            "Governor::_queueOrRevert: failed to queue transaction"
        );
    }

    function execute(uint256 proposalId) public {

        require(
            state(proposalId) == ProposalState.Queued,
            "Governor::execute: proposal can only be executed if it is queued"
        );
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        for (uint256 i = 0; i < proposal.targets.length; i++) {
            executeTransaction(
                proposal.targets[i],
                proposal.signatures[i],
                proposal.calldatas[i],
                proposal.eta
            );
        }
        emit ProposalExecuted(proposalId);
    }

    function cancel(uint256 proposalId) public onlyAdmin {

        ProposalState proposalState = state(proposalId);

        require(
            proposalState == ProposalState.Queued ||
                proposalState == ProposalState.Pending,
            "Governor::execute: proposal can only be cancelled if it is queued or pending"
        );
        Proposal storage proposal = proposals[proposalId];
        proposal.eta = 1; // To mark the proposal as `Expired`
        for (uint256 i = 0; i < proposal.targets.length; i++) {
            cancelTransaction(
                proposal.targets[i],
                proposal.signatures[i],
                proposal.calldatas[i],
                proposal.eta
            );
        }
        emit ProposalCancelled(proposalId);
    }

    function getActions(uint256 proposalId)
        public
        view
        returns (
            address[] memory targets,
            string[] memory signatures,
            bytes[] memory calldatas
        )
    {

        Proposal storage p = proposals[proposalId];
        return (p.targets, p.signatures, p.calldatas);
    }
}