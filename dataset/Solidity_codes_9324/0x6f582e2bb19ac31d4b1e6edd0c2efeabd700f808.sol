

pragma solidity ^0.5.11;


contract IManager {

    event SetController(address controller);
    event ParameterUpdate(string param);

    function setController(address _controller) external;

}


pragma solidity ^0.5.11;


contract Ownable {

    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


pragma solidity ^0.5.11;



contract Pausable is Ownable {

    event Pause();
    event Unpause();

    bool public paused = false;


    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused() {

        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {

        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {

        paused = false;
        emit Unpause();
    }
}


pragma solidity ^0.5.11;



contract IController is Pausable {

    event SetContractInfo(bytes32 id, address contractAddress, bytes20 gitCommitHash);

    function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external;

    function updateController(bytes32 _id, address _controller) external;

    function getContract(bytes32 _id) public view returns (address);

}


pragma solidity ^0.5.11;




contract Manager is IManager {

    IController public controller;

    modifier onlyController() {

        require(msg.sender == address(controller), "caller must be Controller");
        _;
    }

    modifier onlyControllerOwner() {

        require(msg.sender == controller.owner(), "caller must be Controller owner");
        _;
    }

    modifier whenSystemNotPaused() {

        require(!controller.paused(), "system is paused");
        _;
    }

    modifier whenSystemPaused() {

        require(controller.paused(), "system is not paused");
        _;
    }

    constructor(address _controller) public {
        controller = IController(_controller);
    }

    function setController(address _controller) external onlyController {

        controller = IController(_controller);

        emit SetController(_controller);
    }
}


pragma solidity ^0.5.11;



contract ManagerProxyTarget is Manager {

    bytes32 public targetContractId;
}


pragma solidity ^0.5.11;


contract IBondingManager {

    event TranscoderUpdate(address indexed transcoder, uint256 rewardCut, uint256 feeShare);
    event TranscoderActivated(address indexed transcoder, uint256 activationRound);
    event TranscoderDeactivated(address indexed transcoder, uint256 deactivationRound);
    event TranscoderSlashed(address indexed transcoder, address finder, uint256 penalty, uint256 finderReward);
    event Reward(address indexed transcoder, uint256 amount);
    event Bond(address indexed newDelegate, address indexed oldDelegate, address indexed delegator, uint256 additionalAmount, uint256 bondedAmount);
    event Unbond(address indexed delegate, address indexed delegator, uint256 unbondingLockId, uint256 amount, uint256 withdrawRound);
    event Rebond(address indexed delegate, address indexed delegator, uint256 unbondingLockId, uint256 amount);
    event WithdrawStake(address indexed delegator, uint256 unbondingLockId, uint256 amount, uint256 withdrawRound);
    event WithdrawFees(address indexed delegator);
    event EarningsClaimed(address indexed delegate, address indexed delegator, uint256 rewards, uint256 fees, uint256 startRound, uint256 endRound);


    function updateTranscoderWithFees(address _transcoder, uint256 _fees, uint256 _round) external;

    function slashTranscoder(address _transcoder, address _finder, uint256 _slashAmount, uint256 _finderFee) external;

    function setCurrentRoundTotalActiveStake() external;


    function getTranscoderPoolSize() public view returns (uint256);

    function transcoderTotalStake(address _transcoder) public view returns (uint256);

    function isActiveTranscoder(address _transcoder) public view returns (bool);

    function getTotalBonded() public view returns (uint256);

}


pragma solidity ^0.5.11;



contract IMinter {

    event SetCurrentRewardTokens(uint256 currentMintableTokens, uint256 currentInflation);

    function createReward(uint256 _fracNum, uint256 _fracDenom) external returns (uint256);

    function trustedTransferTokens(address _to, uint256 _amount) external;

    function trustedBurnTokens(uint256 _amount) external;

    function trustedWithdrawETH(address payable _to, uint256 _amount) external;

    function depositETH() external payable returns (bool);

    function setCurrentRewardTokens() external;


    function getController() public view returns (IController);

}


pragma solidity ^0.5.11;


contract IRoundsManager {

    event NewRound(uint256 indexed round, bytes32 blockHash);


    function initializeRound() external;


    function blockNum() public view returns (uint256);

    function blockHash(uint256 _block) public view returns (bytes32);

    function blockHashForRound(uint256 _round) public view returns (bytes32);

    function currentRound() public view returns (uint256);

    function currentRoundStartBlock() public view returns (uint256);

    function currentRoundInitialized() public view returns (bool);

    function currentRoundLocked() public view returns (bool);

}


pragma solidity ^0.5.11;





contract MContractRegistry {

    modifier whenSystemNotPaused() {

        _;
    }

    modifier currentRoundInitialized() {

        _;
    }

    function bondingManager() internal view returns (IBondingManager);


    function minter() internal view returns (IMinter);


    function roundsManager() internal view returns (IRoundsManager);

}


pragma solidity ^0.5.11;




contract MixinContractRegistry is MContractRegistry, ManagerProxyTarget {

    modifier currentRoundInitialized() {

        require(roundsManager().currentRoundInitialized(), "current round is not initialized");
        _;
    }

    constructor(address _controller)
        internal
        Manager(_controller)
    {}

    function bondingManager() internal view returns (IBondingManager) {

        return IBondingManager(controller.getContract(keccak256("BondingManager")));
    }

    function minter() internal view returns (IMinter) {

        return IMinter(controller.getContract(keccak256("Minter")));
    }

    function roundsManager() internal view returns (IRoundsManager) {

        return IRoundsManager(controller.getContract(keccak256("RoundsManager")));
    }
}


pragma solidity ^0.5.11;


contract MReserve {

    struct ReserveInfo {
        uint256 fundsRemaining;        // Funds remaining in reserve
        uint256 claimedInCurrentRound; // Funds claimed from reserve in current round
    }

    event ReserveFunded(address indexed reserveHolder, uint256 amount);
    event ReserveClaimed(address indexed reserveHolder, address claimant, uint256 amount);

    function getReserveInfo(address _reserveHolder) public view returns (ReserveInfo memory info);


    function claimedReserve(address _reserveHolder, address _claimant) public view returns (uint256);


    function addReserve(address _reserveHolder, uint256 _amount) internal;


    function clearReserve(address _reserveHolder) internal;


    function claimFromReserve(
        address _reserveHolder,
        address _claimant,
        uint256 _amount
    )
        internal
        returns (uint256);


    function remainingReserve(address _reserveHolder) internal view returns (uint256);

}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.11;





contract MixinReserve is MContractRegistry, MReserve {

    using SafeMath for uint256;

    struct Reserve {
        uint256 funds;                                                        // Amount of funds in the reserve
        mapping (uint256 => uint256) claimedForRound;                         // Mapping of round => total amount claimed
        mapping (uint256 => mapping (address => uint256)) claimedByAddress;   // Mapping of round => claimant address => amount claimed
    }

    mapping (address => Reserve) internal reserves;

    function getReserveInfo(address _reserveHolder) public view returns (ReserveInfo memory info) {

        info.fundsRemaining = remainingReserve(_reserveHolder);
        info.claimedInCurrentRound = reserves[_reserveHolder].claimedForRound[roundsManager().currentRound()];
    }

    function claimableReserve(address _reserveHolder, address _claimant) public view returns (uint256) {

        Reserve storage reserve = reserves[_reserveHolder];

        uint256 currentRound = roundsManager().currentRound();

        if (!bondingManager().isActiveTranscoder(_claimant)) {
            return 0;
        }

        uint256 poolSize = bondingManager().getTranscoderPoolSize();
        if (poolSize == 0) {
            return 0;
        }

        uint256 totalClaimable = reserve.funds.add(reserve.claimedForRound[currentRound]);
        return totalClaimable.div(poolSize).sub(reserve.claimedByAddress[currentRound][_claimant]);
    }

    function claimedReserve(address _reserveHolder, address _claimant) public view returns (uint256) {

        Reserve storage reserve = reserves[_reserveHolder];
        uint256 currentRound = roundsManager().currentRound();
        return reserve.claimedByAddress[currentRound][_claimant];
    }

    function addReserve(address _reserveHolder, uint256 _amount) internal {

        reserves[_reserveHolder].funds = reserves[_reserveHolder].funds.add(_amount);

        emit ReserveFunded(_reserveHolder, _amount);
    }

    function clearReserve(address _reserveHolder) internal {

        delete reserves[_reserveHolder];
    }

    function claimFromReserve(
        address _reserveHolder,
        address _claimant,
        uint256 _amount
    )
        internal
        returns (uint256)
    {

        uint256 claimableFunds = claimableReserve(_reserveHolder, _claimant);
        uint256 claimAmount = _amount > claimableFunds ? claimableFunds : _amount;

        if (claimAmount > 0) {
            uint256 currentRound = roundsManager().currentRound();
            Reserve storage reserve = reserves[_reserveHolder];
            reserve.claimedForRound[currentRound] = reserve.claimedForRound[currentRound].add(claimAmount);
            reserve.claimedByAddress[currentRound][_claimant] = reserve.claimedByAddress[currentRound][_claimant].add(claimAmount);
            reserve.funds = reserve.funds.sub(claimAmount);

            emit ReserveClaimed(_reserveHolder, _claimant, claimAmount);
        }

        return claimAmount;
    }

    function remainingReserve(address _reserveHolder) internal view returns (uint256) {

        return reserves[_reserveHolder].funds;
    }
}


pragma solidity ^0.5.11;


contract MTicketProcessor {

    function processFunding(uint256 _amount) internal;


    function withdrawTransfer(address payable _sender, uint256 _amount) internal;


    function winningTicketTransfer(address _recipient, uint256 _amount, bytes memory _auxData) internal;


    function requireValidTicketAuxData(bytes memory _auxData) internal view;

}


pragma solidity ^0.5.11;


contract MTicketBrokerCore {

    struct Ticket {
        address recipient;          // Address of ticket recipient
        address sender;             // Address of ticket sender
        uint256 faceValue;          // Face value of ticket paid to recipient if ticket wins
        uint256 winProb;            // Probability ticket will win represented as winProb / (2^256 - 1)
        uint256 senderNonce;        // Sender's monotonically increasing counter for each ticket
        bytes32 recipientRandHash;  // keccak256 hash commitment to recipient's random value
        bytes auxData;              // Auxilary data included in ticket used for additional validation
    }

    event DepositFunded(address indexed sender, uint256 amount);
    event WinningTicketRedeemed(
        address indexed sender,
        address indexed recipient,
        uint256 faceValue,
        uint256 winProb,
        uint256 senderNonce,
        uint256 recipientRand,
        bytes auxData
    );
    event WinningTicketTransfer(address indexed sender, address indexed recipient, uint256 amount);
    event Unlock(address indexed sender, uint256 startRound, uint256 endRound);
    event UnlockCancelled(address indexed sender);
    event Withdrawal(address indexed sender, uint256 deposit, uint256 reserve);
}


pragma solidity ^0.5.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


pragma solidity ^0.5.11;








contract MixinTicketBrokerCore is MContractRegistry, MReserve, MTicketProcessor, MTicketBrokerCore {

    using SafeMath for uint256;

    struct Sender {
        uint256 deposit;        // Amount of funds deposited
        uint256 withdrawRound;  // Round that sender can withdraw deposit & reserve
    }

    mapping (address => Sender) internal senders;

    uint256 public unlockPeriod;

    mapping (bytes32 => bool) public usedTickets;

    modifier checkDepositReserveETHValueSplit(uint256 _depositAmount, uint256 _reserveAmount) {

        require(
            msg.value == _depositAmount.add(_reserveAmount),
            "msg.value does not equal sum of deposit amount and reserve amount"
        );

        _;
    }

    modifier processDeposit(address _sender, uint256 _amount) {

        Sender storage sender = senders[_sender];
        sender.deposit = sender.deposit.add(_amount);
        if (_isUnlockInProgress(sender)) {
            _cancelUnlock(sender, _sender);
        }

        _;

        emit DepositFunded(_sender, _amount);
    }

    modifier processReserve(address _sender, uint256 _amount) {

        Sender storage sender = senders[_sender];
        addReserve(_sender, _amount);
        if (_isUnlockInProgress(sender)) {
            _cancelUnlock(sender, _sender);
        }

        _;
    }

    function fundDeposit()
        external
        payable
        whenSystemNotPaused
        processDeposit(msg.sender, msg.value)
    {

        processFunding(msg.value);
    }

    function fundReserve()
        external
        payable
        whenSystemNotPaused
        processReserve(msg.sender, msg.value)
    {

        processFunding(msg.value);
    }

    function fundDepositAndReserve(
        uint256 _depositAmount,
        uint256 _reserveAmount
    )
        external
        payable
        whenSystemNotPaused
        checkDepositReserveETHValueSplit(_depositAmount, _reserveAmount)
        processDeposit(msg.sender, _depositAmount)
        processReserve(msg.sender, _reserveAmount)
    {

        processFunding(msg.value);
    }

    function redeemWinningTicket(
        Ticket memory _ticket,
        bytes memory _sig,
        uint256 _recipientRand
    )
        public
        whenSystemNotPaused
        currentRoundInitialized
    {

        bytes32 ticketHash = getTicketHash(_ticket);

        requireValidWinningTicket(_ticket, ticketHash, _sig, _recipientRand);

        Sender storage sender = senders[_ticket.sender];

        require(
            isLocked(sender),
            "sender is unlocked"
        );
        require(
            sender.deposit > 0 || remainingReserve(_ticket.sender) > 0,
            "sender deposit and reserve are zero"
        );

        usedTickets[ticketHash] = true;

        uint256 amountToTransfer = 0;

        if (_ticket.faceValue > sender.deposit) {

            amountToTransfer = sender.deposit.add(claimFromReserve(
                _ticket.sender,
                _ticket.recipient,
                _ticket.faceValue.sub(sender.deposit)
            ));

            sender.deposit = 0;
        } else {

            amountToTransfer = _ticket.faceValue;
            sender.deposit = sender.deposit.sub(_ticket.faceValue);
        }

        if (amountToTransfer > 0) {
            winningTicketTransfer(_ticket.recipient, amountToTransfer, _ticket.auxData);

            emit WinningTicketTransfer(_ticket.sender, _ticket.recipient, amountToTransfer);
        }

        emit WinningTicketRedeemed(
            _ticket.sender,
            _ticket.recipient,
            _ticket.faceValue,
            _ticket.winProb,
            _ticket.senderNonce,
            _recipientRand,
            _ticket.auxData
        );
    }

    function unlock() public whenSystemNotPaused {

        Sender storage sender = senders[msg.sender];

        require(
            sender.deposit > 0 || remainingReserve(msg.sender) > 0,
            "sender deposit and reserve are zero"
        );
        require(!_isUnlockInProgress(sender), "unlock already initiated");

        uint256 currentRound = roundsManager().currentRound();
        sender.withdrawRound = currentRound.add(unlockPeriod);

        emit Unlock(msg.sender, currentRound, sender.withdrawRound);
    }

    function cancelUnlock() public whenSystemNotPaused {

        Sender storage sender = senders[msg.sender];

        _cancelUnlock(sender, msg.sender);
    }

    function withdraw() public whenSystemNotPaused {

        Sender storage sender = senders[msg.sender];

        uint256 deposit = sender.deposit;
        uint256 reserve = remainingReserve(msg.sender);

        require(
            deposit > 0 || reserve > 0,
            "sender deposit and reserve are zero"
        );
        require(
            _isUnlockInProgress(sender),
            "no unlock request in progress"
        );
        require(
            !isLocked(sender),
            "account is locked"
        );

        sender.deposit = 0;
        clearReserve(msg.sender);

        withdrawTransfer(msg.sender, deposit.add(reserve));

        emit Withdrawal(msg.sender, deposit, reserve);
    }

    function isUnlockInProgress(address _sender) public view returns (bool) {

        Sender memory sender = senders[_sender];
        return _isUnlockInProgress(sender);
    }

    function getSenderInfo(address _sender)
        public
        view
        returns (Sender memory sender, ReserveInfo memory reserve)
    {

        sender = senders[_sender];
        reserve = getReserveInfo(_sender);
    }

    function getTicketHash(Ticket memory _ticket) public pure returns (bytes32) {

        return keccak256(
            abi.encodePacked(
                _ticket.recipient,
                _ticket.sender,
                _ticket.faceValue,
                _ticket.winProb,
                _ticket.senderNonce,
                _ticket.recipientRandHash,
                _ticket.auxData
            )
        );
    }

    function _cancelUnlock(Sender storage _sender, address _senderAddress) internal {

        require(_isUnlockInProgress(_sender), "no unlock request in progress");

        _sender.withdrawRound = 0;

        emit UnlockCancelled(_senderAddress);
    }

    function requireValidWinningTicket(
        Ticket memory _ticket,
        bytes32 _ticketHash,
        bytes memory _sig,
        uint256 _recipientRand
    )
        internal
        view
    {

        require(_ticket.recipient != address(0), "ticket recipient is null address");
        require(_ticket.sender != address(0), "ticket sender is null address");

        requireValidTicketAuxData(_ticket.auxData);

        require(
            keccak256(abi.encodePacked(_recipientRand)) == _ticket.recipientRandHash,
            "recipientRand does not match recipientRandHash"
        );

        require(!usedTickets[_ticketHash], "ticket is used");

        require(
            isValidTicketSig(_ticket.sender, _sig, _ticketHash),
            "invalid signature over ticket hash"
        );

        require(
            isWinningTicket(_sig, _recipientRand, _ticket.winProb),
            "ticket did not win"
        );
    }

    function isLocked(Sender memory _sender) internal view returns (bool) {

        return _sender.withdrawRound == 0 || roundsManager().currentRound() < _sender.withdrawRound;
    }

    function isValidTicketSig(
        address _sender,
        bytes memory _sig,
        bytes32 _ticketHash
    )
        internal
        pure
        returns (bool)
    {

        address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(_ticketHash), _sig);
        return signer != address(0) && _sender == signer;
    }

    function isWinningTicket(bytes memory _sig, uint256 _recipientRand, uint256 _winProb) internal pure returns (bool) {

        return uint256(keccak256(abi.encodePacked(_sig, _recipientRand))) < _winProb;
    }

    function _isUnlockInProgress(Sender memory _sender) internal pure returns (bool) {

        return _sender.withdrawRound > 0;
    }
}


pragma solidity ^0.5.11;





contract MixinTicketProcessor is MContractRegistry, MTicketProcessor {

    using SafeMath for uint256;

    uint256 public ticketValidityPeriod;

    function processFunding(uint256 _amount) internal {

        minter().depositETH.value(_amount)();
    }

    function withdrawTransfer(address payable _sender, uint256 _amount) internal {

        minter().trustedWithdrawETH(_sender, _amount);
    }

    function winningTicketTransfer(address _recipient, uint256 _amount, bytes memory _auxData) internal {

        (uint256 creationRound,) = getCreationRoundAndBlockHash(_auxData);

        bondingManager().updateTranscoderWithFees(
            _recipient,
            _amount,
            creationRound
        );
    }

    function requireValidTicketAuxData(bytes memory _auxData) internal view {

        (uint256 creationRound, bytes32 creationRoundBlockHash) = getCreationRoundAndBlockHash(_auxData);
        bytes32 blockHash = roundsManager().blockHashForRound(creationRound);

        require(
            blockHash != bytes32(0),
            "ticket creationRound does not have a block hash"
        );
        require(
            creationRoundBlockHash == blockHash,
            "ticket creationRoundBlockHash invalid for creationRound"
        );

        uint256 currRound = roundsManager().currentRound();

        require(
            creationRound.add(ticketValidityPeriod) > currRound,
            "ticket is expired"
        );
    }

    function getCreationRoundAndBlockHash(bytes memory _auxData)
        internal
        pure
        returns (
            uint256 creationRound,
            bytes32 creationRoundBlockHash
        )
    {

        require(
            _auxData.length == 64,
            "invalid length for ticket auxData: must be 64 bytes"
        );

        assembly {
            creationRound := mload(add(_auxData, 32))
            creationRoundBlockHash := mload(add(_auxData, 64))
        }
    }
}


pragma solidity ^0.5.11;




contract MixinWrappers is MContractRegistry, MTicketBrokerCore {


    function batchRedeemWinningTickets(
        Ticket[] memory _tickets,
        bytes[] memory _sigs,
        uint256[] memory _recipientRands
    )
        public
        whenSystemNotPaused
        currentRoundInitialized
    {

        for (uint256 i = 0; i < _tickets.length; i++) {
            redeemWinningTicketNoRevert(
                _tickets[i],
                _sigs[i],
                _recipientRands[i]
            );
        }
    }

    function redeemWinningTicketNoRevert(
        Ticket memory _ticket,
        bytes memory _sig,
        uint256 _recipientRand
    )
        internal
        returns (bool success)
    {

        bytes memory redeemWinningTicketCalldata = abi.encodeWithSignature(
            "redeemWinningTicket((address,address,uint256,uint256,uint256,bytes32,bytes),bytes,uint256)",
            _ticket,
            _sig,
            _recipientRand
        );

        (success,) = address(this).call(redeemWinningTicketCalldata);
    }
}


pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;







contract TicketBroker is
    MixinContractRegistry,
    MixinReserve,
    MixinTicketBrokerCore,
    MixinTicketProcessor,
    MixinWrappers
{

    constructor(
        address _controller
    )
        public
        MixinContractRegistry(_controller)
        MixinReserve()
        MixinTicketBrokerCore()
        MixinTicketProcessor()
    {}

    function setUnlockPeriod(uint256 _unlockPeriod) external onlyControllerOwner {

        unlockPeriod = _unlockPeriod;
    }

    function setTicketValidityPeriod(uint256 _ticketValidityPeriod) external onlyControllerOwner {

        require(_ticketValidityPeriod > 0, "ticketValidityPeriod must be greater than 0");

        ticketValidityPeriod = _ticketValidityPeriod;
    }
}