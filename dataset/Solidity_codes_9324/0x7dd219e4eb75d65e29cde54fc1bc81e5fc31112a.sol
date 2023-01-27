
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.6.2;


interface IFei is IERC20 {


    event Minting(
        address indexed _to,
        address indexed _minter,
        uint256 _amount
    );

    event Burning(
        address indexed _to,
        address indexed _burner,
        uint256 _amount
    );

    event IncentiveContractUpdate(
        address indexed _incentivized,
        address indexed _incentiveContract
    );


    function burn(uint256 amount) external;


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;



    function burnFrom(address account, uint256 amount) external;



    function mint(address account, uint256 amount) external;



    function setIncentiveContract(address account, address incentive) external;



    function incentiveContract(address account) external view returns (address);

}pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


interface ITribe is IERC20 {

    function delegate(address delegatee) external;

}

interface ITimelockedDelegator {


    event Delegate(address indexed _delegatee, uint256 _amount);

    event Undelegate(address indexed _delegatee, uint256 _amount);


    function delegate(address delegatee, uint256 amount) external;


    function undelegate(address delegatee) external returns (uint256);



    function delegateContract(address delegatee)
        external
        view
        returns (address);


    function delegateAmount(address delegatee) external view returns (uint256);


    function totalDelegated() external view returns (uint256);


    function tribe() external view returns (ITribe);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}pragma solidity ^0.6.0;


abstract contract Timed {
    using SafeCast for uint256;

    uint256 public startTime;

    uint256 public duration;

    event DurationUpdate(uint256 _duration);

    event TimerReset(uint256 _startTime);

    constructor(uint256 _duration) public {
        _setDuration(_duration);
    }

    modifier duringTime() {
        require(isTimeStarted(), "Timed: time not started");
        require(!isTimeEnded(), "Timed: time ended");
        _;
    }

    modifier afterTime() {
        require(isTimeEnded(), "Timed: time not ended");
        _;
    }

    function isTimeEnded() public view returns (bool) {
        return remainingTime() == 0;
    }

    function remainingTime() public view returns (uint256) {
        return duration - timeSinceStart(); // duration always >= timeSinceStart which is on [0,d]
    }

    function timeSinceStart() public view returns (uint256) {
        if (!isTimeStarted()) {
            return 0; // uninitialized
        }
        uint256 _duration = duration;
        uint256 timePassed = block.timestamp - startTime; // block timestamp always >= startTime
        return timePassed > _duration ? _duration : timePassed;
    }

    function isTimeStarted() public view returns (bool) {
        return startTime != 0;
    }

    function _initTimed() internal {
        startTime = block.timestamp;
        
        emit TimerReset(block.timestamp);
    }

    function _setDuration(uint _duration) internal {
        duration = _duration;
        emit DurationUpdate(_duration);
    }
}pragma solidity ^0.6.2;


interface ILinearTokenTimelock {


    event Release(address indexed _beneficiary, address indexed _recipient, uint256 _amount);
    event BeneficiaryUpdate(address indexed _beneficiary);
    event PendingBeneficiaryUpdate(address indexed _pendingBeneficiary);


    function release(address to, uint amount) external;


    function releaseMax(address to) external;


    function setPendingBeneficiary(address _pendingBeneficiary) external;


    function acceptBeneficiary() external;




    function lockedToken() external view returns (IERC20);


    function beneficiary() external view returns (address);


    function pendingBeneficiary() external view returns (address);


    function initialBalance() external view returns (uint256);


    function availableForRelease() external view returns (uint256);


    function totalToken() external view returns(uint256);


    function alreadyReleasedAmount() external view returns (uint256);

}// MIT

pragma solidity ^0.6.0;

library SafeMathCopy { // To avoid namespace collision between openzeppelin safemath and uniswap safemath

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
}pragma solidity ^0.6.0;



contract LinearTokenTimelock is ILinearTokenTimelock, Timed {

    using SafeMathCopy for uint256;

    IERC20 public override lockedToken;

    address public override beneficiary;

    address public override pendingBeneficiary;

    uint256 public override initialBalance;

    uint256 internal lastBalance;

    constructor(
        address _beneficiary,
        uint256 _duration,
        address _lockedToken
    ) public Timed(_duration) {
        require(_duration != 0, "LinearTokenTimelock: duration is 0");
        require(
            _beneficiary != address(0),
            "LinearTokenTimelock: Beneficiary must not be 0 address"
        );

        beneficiary = _beneficiary;
        _initTimed();

        _setLockedToken(_lockedToken);
    }

    modifier balanceCheck() {

        if (totalToken() > lastBalance) {
            uint256 delta = totalToken().sub(lastBalance);
            initialBalance = initialBalance.add(delta);
        }
        _;
        lastBalance = totalToken();
    }

    modifier onlyBeneficiary() {

        require(
            msg.sender == beneficiary,
            "LinearTokenTimelock: Caller is not a beneficiary"
        );
        _;
    }

    function release(address to, uint256 amount) external override onlyBeneficiary balanceCheck {

        require(amount != 0, "LinearTokenTimelock: no amount desired");

        uint256 available = availableForRelease();
        require(amount <= available, "LinearTokenTimelock: not enough released tokens");

        _release(to, amount);
    }

    function releaseMax(address to) external override onlyBeneficiary balanceCheck {

        _release(to, availableForRelease());
    }

    function totalToken() public view override virtual returns (uint256) {

        return lockedToken.balanceOf(address(this));
    }

    function alreadyReleasedAmount() public view override returns (uint256) {

        return initialBalance.sub(totalToken());
    }

    function availableForRelease() public view override returns (uint256) {

        uint256 elapsed = timeSinceStart();
        uint256 _duration = duration;

        uint256 totalAvailable = initialBalance.mul(elapsed) / _duration;
        uint256 netAvailable = totalAvailable.sub(alreadyReleasedAmount());
        return netAvailable;
    }

    function setPendingBeneficiary(address _pendingBeneficiary)
        public
        override
        onlyBeneficiary
    {

        pendingBeneficiary = _pendingBeneficiary;
        emit PendingBeneficiaryUpdate(_pendingBeneficiary);
    }

    function acceptBeneficiary() public override virtual {

        _setBeneficiary(msg.sender);
    }

    function _setBeneficiary(address newBeneficiary) internal {

        require(
            newBeneficiary == pendingBeneficiary,
            "LinearTokenTimelock: Caller is not pending beneficiary"
        );
        beneficiary = newBeneficiary;
        emit BeneficiaryUpdate(newBeneficiary);
        pendingBeneficiary = address(0);
    }

    function _setLockedToken(address tokenAddress) internal {

        lockedToken = IERC20(tokenAddress);
    }

    function _release(address to, uint256 amount) internal {

        lockedToken.transfer(to, amount);
        emit Release(beneficiary, to, amount);
    }
}pragma solidity ^0.6.0;


contract Delegatee is Ownable {

    ITribe public tribe;

    constructor(address _delegatee, address _tribe) public {
        tribe = ITribe(_tribe);
        tribe.delegate(_delegatee);
    }

    function withdraw() public onlyOwner {

        ITribe _tribe = tribe;
        uint256 balance = _tribe.balanceOf(address(this));
        _tribe.transfer(owner(), balance);
        selfdestruct(payable(owner()));
    }
}

contract TimelockedDelegator is ITimelockedDelegator, LinearTokenTimelock {

    mapping(address => address) public override delegateContract;

    mapping(address => uint256) public override delegateAmount;

    ITribe public override tribe;

    uint256 public override totalDelegated;

    constructor(
        address _tribe,
        address _beneficiary,
        uint256 _duration
    ) public LinearTokenTimelock(_beneficiary, _duration, _tribe) {
        tribe = ITribe(_tribe);
        tribe.delegate(_beneficiary);
    }

    function delegate(address delegatee, uint256 amount)
        public
        override
        onlyBeneficiary
    {

        require(
            amount <= _tribeBalance(),
            "TimelockedDelegator: Not enough Tribe"
        );

        if (delegateContract[delegatee] != address(0)) {
            amount = amount.add(undelegate(delegatee));
        }

        ITribe _tribe = tribe;
        address _delegateContract =
            address(new Delegatee(delegatee, address(_tribe)));
        delegateContract[delegatee] = _delegateContract;

        delegateAmount[delegatee] = amount;
        totalDelegated = totalDelegated.add(amount);

        _tribe.transfer(_delegateContract, amount);

        emit Delegate(delegatee, amount);
    }

    function undelegate(address delegatee)
        public
        override
        onlyBeneficiary
        returns (uint256)
    {

        address _delegateContract = delegateContract[delegatee];
        require(
            _delegateContract != address(0),
            "TimelockedDelegator: Delegate contract nonexistent"
        );

        Delegatee(_delegateContract).withdraw();

        uint256 amount = delegateAmount[delegatee];
        totalDelegated = totalDelegated.sub(amount);

        delegateContract[delegatee] = address(0);
        delegateAmount[delegatee] = 0;

        emit Undelegate(delegatee, amount);

        return amount;
    }

    function totalToken() public view override returns (uint256) {

        return _tribeBalance().add(totalDelegated);
    }

    function acceptBeneficiary() public override {

        _setBeneficiary(msg.sender);
        tribe.delegate(msg.sender);
    }

    function _tribeBalance() internal view returns (uint256) {

        return tribe.balanceOf(address(this));
    }
}