


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

interface IRelayHub {


    function stake(address relayaddr, uint256 unstakeDelay) external payable;


    event Staked(address indexed relay, uint256 stake, uint256 unstakeDelay);

    function registerRelay(uint256 transactionFee, string calldata url) external;


    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    function removeRelayByOwner(address relay) external;


    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    function unstake(address relay) external;


    event Unstaked(address indexed relay, uint256 stake);

    enum RelayState {
        Unknown, // The relay is unknown to the system: it has never been staked for
        Staked, // The relay has been staked for, but it is not yet active
        Registered, // The relay has registered itself, and is active (can relay calls)
        Removed    // The relay has been removed by its owner and can no longer relay calls. It must wait for its unstakeDelay to elapse before it can unstake
    }

    function getRelay(address relay) external view returns (uint256 totalStake, uint256 unstakeDelay, uint256 unstakeTime, address payable owner, RelayState state);



    function depositFor(address target) external payable;


    event Deposited(address indexed recipient, address indexed from, uint256 amount);

    function balanceOf(address target) external view returns (uint256);


    function withdraw(uint256 amount, address payable dest) external;


    event Withdrawn(address indexed account, address indexed dest, uint256 amount);


    function canRelay(
        address relay,
        address from,
        address to,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata signature,
        bytes calldata approvalData
    ) external view returns (uint256 status, bytes memory recipientContext);


    enum PreconditionCheck {
        OK,                         // All checks passed, the call can be relayed
        WrongSignature,             // The transaction to relay is not signed by requested sender
        WrongNonce,                 // The provided nonce has already been used by the sender
        AcceptRelayedCallReverted,  // The recipient rejected this call via acceptRelayedCall
        InvalidRecipientStatusCode  // The recipient returned an invalid (reserved) status code
    }

    function relayCall(
        address from,
        address to,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata signature,
        bytes calldata approvalData
    ) external;


    event CanRelayFailed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 reason);

    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, RelayCallStatus status, uint256 charge);

    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful - never included in the event
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    function requiredGas(uint256 relayedCallStipend) external view returns (uint256);


    function maxPossibleCharge(uint256 relayedCallStipend, uint256 gasPrice, uint256 transactionFee) external view returns (uint256);



    function penalizeRepeatedNonce(bytes calldata unsignedTx1, bytes calldata signature1, bytes calldata unsignedTx2, bytes calldata signature2) external;


    function penalizeIllegalTransaction(bytes calldata unsignedTx, bytes calldata signature) external;


    event Penalized(address indexed relay, address sender, uint256 amount);

    function getNonce(address from) external view returns (uint256);

}



pragma solidity ^0.5.0;

interface IRelayRecipient {

    function getHubAddr() external view returns (address);


    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    )
        external
        view
        returns (uint256, bytes memory);


    function preRelayedCall(bytes calldata context) external returns (bytes32);


    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external;

}


pragma solidity ^0.5.0;




contract GSNRecipient is IRelayRecipient, Context {

    address private _relayHub = 0xD216153c06E857cD7f72665E0aF1d7D82172F494;

    uint256 constant private RELAYED_CALL_ACCEPTED = 0;
    uint256 constant private RELAYED_CALL_REJECTED = 11;

    uint256 constant internal POST_RELAYED_CALL_MAX_GAS = 100000;

    event RelayHubChanged(address indexed oldRelayHub, address indexed newRelayHub);

    function getHubAddr() public view returns (address) {

        return _relayHub;
    }

    function _upgradeRelayHub(address newRelayHub) internal {

        address currentRelayHub = _relayHub;
        require(newRelayHub != address(0), "GSNRecipient: new RelayHub is the zero address");
        require(newRelayHub != currentRelayHub, "GSNRecipient: new RelayHub is the current one");

        emit RelayHubChanged(currentRelayHub, newRelayHub);

        _relayHub = newRelayHub;
    }

    function relayHubVersion() public view returns (string memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return "1.0.0";
    }

    function _withdrawDeposits(uint256 amount, address payable payee) internal {

        IRelayHub(_relayHub).withdraw(amount, payee);
    }


    function _msgSender() internal view returns (address payable) {

        if (msg.sender != _relayHub) {
            return msg.sender;
        } else {
            return _getRelayedCallSender();
        }
    }

    function _msgData() internal view returns (bytes memory) {

        if (msg.sender != _relayHub) {
            return msg.data;
        } else {
            return _getRelayedCallData();
        }
    }


    function preRelayedCall(bytes calldata context) external returns (bytes32) {

        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        return _preRelayedCall(context);
    }

    function _preRelayedCall(bytes memory context) internal returns (bytes32);


    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external {

        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        _postRelayedCall(context, success, actualCharge, preRetVal);
    }

    function _postRelayedCall(bytes memory context, bool success, uint256 actualCharge, bytes32 preRetVal) internal;


    function _approveRelayedCall() internal pure returns (uint256, bytes memory) {

        return _approveRelayedCall("");
    }

    function _approveRelayedCall(bytes memory context) internal pure returns (uint256, bytes memory) {

        return (RELAYED_CALL_ACCEPTED, context);
    }

    function _rejectRelayedCall(uint256 errorCode) internal pure returns (uint256, bytes memory) {

        return (RELAYED_CALL_REJECTED + errorCode, "");
    }

    function _computeCharge(uint256 gas, uint256 gasPrice, uint256 serviceFee) internal pure returns (uint256) {

        return (gas * gasPrice * (100 + serviceFee)) / 100;
    }

    function _getRelayedCallSender() private pure returns (address payable result) {



        bytes memory array = msg.data;
        uint256 index = msg.data.length;

        assembly {
            result := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function _getRelayedCallData() private pure returns (bytes memory) {


        uint256 actualDataLength = msg.data.length - 20;
        bytes memory actualData = new bytes(actualDataLength);

        for (uint256 i = 0; i < actualDataLength; ++i) {
            actualData[i] = msg.data[i];
        }

        return actualData;
    }
}


pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;


library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

}

interface IShifter {

    function shiftIn(bytes32 _pHash, uint256 _amount, bytes32 _nHash, bytes calldata _sig) external returns (uint256);

    function shiftOut(bytes calldata _to, uint256 _amount) external returns (uint256);

}

interface ShifterRegistry {

    function getShifterBySymbol(string calldata _tokenSymbol) external view returns (IShifter);

    function getShifterByToken(address  _tokenAddress) external view returns (IShifter);

    function getTokenBySymbol(string calldata _tokenSymbol) external view returns (IERC20);

}

contract Vesting is GSNRecipient {

    using SafeMath for uint256;

    ShifterRegistry public registry;
    address owner;

    uint256 private constant SECONDS_PER_MONTH = 365 days / 12;
    uint256 private constant SECONDS_PER_MINUTE = 1 minutes;

    struct VestingSchedule {
        uint256 id;
        
        bytes beneficiary;
        
        uint256 startTime;

        uint16 duration;

        uint256 amount;

        uint256 minutesClaimed;

        uint256 amountClaimed;
    }
    
    uint256 public latestScheduleId;

    mapping (uint256 => VestingSchedule) public schedules;

    constructor(ShifterRegistry _registry, address _owner) public {
        registry = _registry;
        latestScheduleId = 0;
        owner = _owner;
    }
    
    function acceptRelayedCall(
        address,
        address,
        bytes calldata,
        uint256,
        uint256,
        uint256,
        uint256,
        bytes calldata,
        uint256
    ) external view returns (uint256, bytes memory) {

        return _approveRelayedCall();
    }
    
    function _preRelayedCall(bytes memory context) internal returns (bytes32) {

    }
    
    function _postRelayedCall(bytes memory context, bool, uint256 actualCharge, bytes32) internal {

    }

    function addVestingSchedule(
        bytes calldata _beneficiary,
        uint256        _startTime,
        uint16         _duration,
        uint256        _amount,
        bytes32        _nHash,
        bytes calldata _sig
    ) external {

        require(_amount > 0, "amount must be greater than 0");
        require(_duration > 0, "duration must be at least 1 month");

        bytes32 pHash = keccak256(abi.encode(_beneficiary, _startTime, _duration));
        uint256 finalAmount = registry.getShifterBySymbol("zBTC").shiftIn(pHash, _amount, _nHash, _sig);
        
        require(finalAmount > 0, "bitcoin shifted must be greater than 0");
        
        uint256 newId = latestScheduleId + 1;

        VestingSchedule memory schedule = VestingSchedule({
            id: newId,
            beneficiary: _beneficiary,
            startTime: _startTime == 0 ? now : _startTime,
            duration: _duration,
            amount: finalAmount,
            minutesClaimed: 0,
            amountClaimed: 0
        });

        schedules[newId] = schedule;
        latestScheduleId = newId;
    }

    function claim(uint256 _id) external {

        VestingSchedule storage schedule = schedules[_id];
        bytes storage _to = schedule.beneficiary;
        
        uint256 minutesClaimable;
        uint256 amountClaimable;
        (minutesClaimable, amountClaimable) = calculateClaimable(_id);
        require(amountClaimable > 0, "no amount claimable");
        
        uint256 minutesClaimedAfter = schedule.minutesClaimed.add(minutesClaimable);
        uint256 amountClaimedAfter = schedule.amountClaimed.add(amountClaimable);
        uint256 amountLeftAfter = schedule.amount.sub(amountClaimedAfter);

        require((amountLeftAfter > 10000 || amountLeftAfter == 0), "remainder after claim is less than minmum amount");

        schedule.minutesClaimed = minutesClaimedAfter;
        schedule.amountClaimed = amountClaimedAfter;

        registry.getShifterBySymbol("zBTC").shiftOut(_to, amountClaimable);
    }

    function calculateClaimable(uint256 _id) public view returns (uint256, uint256) {

        VestingSchedule storage schedule = schedules[_id];

        if (schedule.amount == 0 || now < schedule.startTime) {
            return (0, 0);
        }

        uint256 elapsedTime = now.sub(schedule.startTime);
        uint256 elapsedMinutes = elapsedTime.div(SECONDS_PER_MINUTE);

        uint256 minutesClaimable = Math.min(schedule.duration, elapsedMinutes).sub(schedule.minutesClaimed);
        uint256 amountClaimable = schedule.amount.mul(minutesClaimable).div(schedule.duration);

        return (minutesClaimable, amountClaimable);
    }
    
    function getSchedules() public view returns (VestingSchedule[] memory) {

        VestingSchedule[] memory data = new VestingSchedule[](latestScheduleId);

        uint256 n = 1;

        while (n < (latestScheduleId + 1)) {
            data[n-1] = schedules[n];
            n += 1;
        }
        return data;
    }
    
    function() external payable {
    }
}