
pragma solidity 0.5.16;

library ExtendedMath {

    function pow2(uint256 a) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * a;
        require(c / a == a, "ExtendedMath: squaring overflow");
        return c;
    }

    function sqrt(uint y) internal pure returns (uint z) {

        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
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


contract Sacrifice {

    constructor(address payable _recipient) public payable {
        selfdestruct(_recipient);
    }
}



interface IERC20Mintable {

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function mint(address _to, uint256 _value) external returns (bool);

    function balanceOf(address _account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

}







contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}






contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}







interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





contract ReentrancyGuard is Initializable {

    uint256 private _guardCounter;

    function initialize() public initializer {

        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

    uint256[50] private ______gap;
}








library Sigmoid {

    using SafeMath for uint256;
    using ExtendedMath for uint256;

    uint256 public constant PARAM_UPDATE_DELAY = 7 days;

    struct Params {
        uint256 a;
        int256 b;
        uint256 c;
    }

    struct State {
        Params oldParams;
        Params newParams;
        uint256 timestamp;
    }

    function setParameters(State storage self, uint256 _a, int256 _b, uint256 _c) internal {

        require(_c != 0, "should be greater than 0"); // prevent division by zero
        uint256 currentTimestamp = _now();
        if (self.timestamp == 0) {
            self.oldParams = Params(_a, _b, _c);
        } else if (currentTimestamp > self.timestamp.add(PARAM_UPDATE_DELAY)) {
            self.oldParams = self.newParams;
        }
        self.newParams = Params(_a, _b, _c);
        self.timestamp = currentTimestamp;
    }

    function getParameters(State storage self) internal view returns (uint256, int256, uint256) {

        bool isUpdated = _now() > self.timestamp.add(PARAM_UPDATE_DELAY);
        return isUpdated ?
            (self.newParams.a, self.newParams.b, self.newParams.c) :
            (self.oldParams.a, self.oldParams.b, self.oldParams.c);
    }

    function calculate(State storage self, int256 _x) internal view returns (uint256) {

        (uint256 a, int256 b, uint256 c) = getParameters(self);
        int256 k = _x - b;
        if (k < 0) return 0;
        uint256 uk = uint256(k);
        return a.mul(uk).div(uk.pow2().add(c).sqrt());
    }

    function _now() internal view returns (uint256) {

        return now; // solium-disable-line security/no-block-members
    }
}


contract EasyStaking is Ownable, ReentrancyGuard {

    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Sigmoid for Sigmoid.State;

    event Deposited(
        address indexed sender,
        uint256 indexed id,
        uint256 amount,
        uint256 balance,
        uint256 accruedEmission,
        uint256 prevDepositDuration
    );

    event WithdrawalRequested(address indexed sender, uint256 indexed id);

    event Withdrawn(
        address indexed sender,
        uint256 indexed id,
        uint256 amount,
        uint256 fee,
        uint256 balance,
        uint256 accruedEmission,
        uint256 lastDepositDuration
    );

    event FeeSet(uint256 value, address sender);

    event WithdrawalLockDurationSet(uint256 value, address sender);

    event WithdrawalUnlockDurationSet(uint256 value, address sender);

    event TotalSupplyFactorSet(uint256 value, address sender);

    event SigmoidParametersSet(uint256 a, int256 b, uint256 c, address sender);

    event LiquidityProvidersRewardAddressSet(address value, address sender);

    uint256 private constant YEAR = 365 days;
    uint256 public constant MAX_EMISSION_RATE = 150 finney; // 15%, 0.15 ether
    uint256 public constant PARAM_UPDATE_DELAY = 7 days;

    IERC20Mintable public token;

    struct UintParam {
        uint256 oldValue;
        uint256 newValue;
        uint256 timestamp;
    }

    struct AddressParam {
        address oldValue;
        address newValue;
        uint256 timestamp;
    }

    AddressParam public liquidityProvidersRewardAddressParam;
    UintParam public feeParam;
    UintParam public withdrawalLockDurationParam;
    UintParam public withdrawalUnlockDurationParam;
    UintParam public totalSupplyFactorParam;

    mapping (address => mapping (uint256 => uint256)) public balances;
    mapping (address => mapping (uint256 => uint256)) public depositDates;
    mapping (address => mapping (uint256 => uint256)) public withdrawalRequestsDates;
    mapping (address => uint256) public lastDepositIds;
    uint256 public totalStaked;

    bool private locked;
    Sigmoid.State private sigmoid;

    function initialize(
        address _owner,
        address _tokenAddress,
        address _liquidityProvidersRewardAddress,
        uint256 _fee,
        uint256 _withdrawalLockDuration,
        uint256 _withdrawalUnlockDuration,
        uint256 _totalSupplyFactor,
        uint256 _sigmoidParamA,
        int256 _sigmoidParamB,
        uint256 _sigmoidParamC
    ) external initializer {

        require(_owner != address(0), "zero address");
        require(_tokenAddress.isContract(), "not a contract address");
        Ownable.initialize(msg.sender);
        ReentrancyGuard.initialize();
        token = IERC20Mintable(_tokenAddress);
        setFee(_fee);
        setWithdrawalLockDuration(_withdrawalLockDuration);
        setWithdrawalUnlockDuration(_withdrawalUnlockDuration);
        setTotalSupplyFactor(_totalSupplyFactor);
        setSigmoidParameters(_sigmoidParamA, _sigmoidParamB, _sigmoidParamC);
        setLiquidityProvidersRewardAddress(_liquidityProvidersRewardAddress);
        Ownable.transferOwnership(_owner);
    }

    function deposit(uint256 _amount) external {

        deposit(++lastDepositIds[msg.sender], _amount);
    }

    function deposit(uint256 _depositId, uint256 _amount) public {

        require(_depositId > 0 && _depositId <= lastDepositIds[msg.sender], "wrong deposit id");
        _deposit(msg.sender, _depositId, _amount);
        _setLocked(true);
        require(token.transferFrom(msg.sender, address(this), _amount), "transfer failed");
        _setLocked(false);
    }

    function onTokenTransfer(address _sender, uint256 _amount, bytes calldata) external returns (bool) {

        require(msg.sender == address(token), "only token contract is allowed");
        if (!locked) {
            _deposit(_sender, ++lastDepositIds[_sender], _amount);
        }
        return true;
    }

    function makeForcedWithdrawal(uint256 _depositId, uint256 _amount) external {

        _withdraw(msg.sender, _depositId, _amount, true);
    }

    function requestWithdrawal(uint256 _depositId) external {

        require(_depositId > 0 && _depositId <= lastDepositIds[msg.sender], "wrong deposit id");
        withdrawalRequestsDates[msg.sender][_depositId] = _now();
        emit WithdrawalRequested(msg.sender, _depositId);
    }

    function makeRequestedWithdrawal(uint256 _depositId, uint256 _amount) external {

        uint256 requestDate = withdrawalRequestsDates[msg.sender][_depositId];
        require(requestDate > 0, "withdrawal wasn't requested");
        uint256 timestamp = _now();
        uint256 lockEnd = requestDate.add(withdrawalLockDuration());
        require(timestamp >= lockEnd, "too early");
        require(timestamp < lockEnd.add(withdrawalUnlockDuration()), "too late");
        withdrawalRequestsDates[msg.sender][_depositId] = 0;
        _withdraw(msg.sender, _depositId, _amount, false);
    }

    function claimTokens(address _token, address payable _to, uint256 _amount) external onlyOwner {

        require(_to != address(0) && _to != address(this), "not a valid recipient");
        require(_amount > 0, "amount should be greater than 0");
        if (_token == address(0)) {
            if (!_to.send(_amount)) { // solium-disable-line security/no-send
                (new Sacrifice).value(_amount)(_to);
            }
        } else if (_token == address(token)) {
            uint256 availableAmount = token.balanceOf(address(this)).sub(totalStaked);
            require(availableAmount >= _amount, "insufficient funds");
            require(token.transfer(_to, _amount), "transfer failed");
        } else {
            IERC20 customToken = IERC20(_token);
            customToken.safeTransfer(_to, _amount);
        }
    }

    function setFee(uint256 _value) public onlyOwner {

        require(_value <= 1 ether, "should be less than or equal to 1 ether");
        _updateUintParam(feeParam, _value);
        emit FeeSet(_value, msg.sender);
    }

    function setWithdrawalLockDuration(uint256 _value) public onlyOwner {

        require(_value <= 30 days, "shouldn't be greater than 30 days");
        _updateUintParam(withdrawalLockDurationParam, _value);
        emit WithdrawalLockDurationSet(_value, msg.sender);
    }

    function setWithdrawalUnlockDuration(uint256 _value) public onlyOwner {

        require(_value >= 1 hours, "shouldn't be less than 1 hour");
        _updateUintParam(withdrawalUnlockDurationParam, _value);
        emit WithdrawalUnlockDurationSet(_value, msg.sender);
    }

    function setTotalSupplyFactor(uint256 _value) public onlyOwner {

        require(_value <= 1 ether, "should be less than or equal to 1 ether");
        _updateUintParam(totalSupplyFactorParam, _value);
        emit TotalSupplyFactorSet(_value, msg.sender);
    }

    function setSigmoidParameters(uint256 _a, int256 _b, uint256 _c) public onlyOwner {

        require(_a <= MAX_EMISSION_RATE.div(2), "should be less than or equal to a half of the maximum emission rate");
        sigmoid.setParameters(_a, _b, _c);
        emit SigmoidParametersSet(_a, _b, _c, msg.sender);
    }

    function setLiquidityProvidersRewardAddress(address _address) public onlyOwner {

        require(_address != address(0), "zero address");
        require(_address != address(this), "wrong address");
        AddressParam memory param = liquidityProvidersRewardAddressParam;
        if (param.timestamp == 0) {
            param.oldValue = _address;
        } else if (_paramUpdateDelayElapsed(param.timestamp)) {
            param.oldValue = param.newValue;
        }
        param.newValue = _address;
        param.timestamp = _now();
        liquidityProvidersRewardAddressParam = param;
        emit LiquidityProvidersRewardAddressSet(_address, msg.sender);
    }

    function fee() public view returns (uint256) {

        return _getUintParamValue(feeParam);
    }

    function withdrawalLockDuration() public view returns (uint256) {

        return _getUintParamValue(withdrawalLockDurationParam);
    }

    function withdrawalUnlockDuration() public view returns (uint256) {

        return _getUintParamValue(withdrawalUnlockDurationParam);
    }

    function totalSupplyFactor() public view returns (uint256) {

        return _getUintParamValue(totalSupplyFactorParam);
    }

    function liquidityProvidersRewardAddress() public view returns (address) {

        AddressParam memory param = liquidityProvidersRewardAddressParam;
        return _paramUpdateDelayElapsed(param.timestamp) ? param.newValue : param.oldValue;
    }

    function getSupplyBasedEmissionRate() public view returns (uint256) {

        uint256 totalSupply = token.totalSupply();
        uint256 factor = totalSupplyFactor();
        if (factor == 0) return 0;
        uint256 target = totalSupply.mul(factor).div(1 ether);
        uint256 maxSupplyBasedEmissionRate = MAX_EMISSION_RATE.div(2); // 7.5%
        if (totalStaked >= target) {
            return maxSupplyBasedEmissionRate;
        }
        return maxSupplyBasedEmissionRate.mul(totalStaked).div(target);
    }

    function getAccruedEmission(
        uint256 _depositDate,
        uint256 _amount
    ) public view returns (uint256 total, uint256 userShare, uint256 timePassed) {

        if (_amount == 0 || _depositDate == 0) return (0, 0, 0);
        timePassed = _now().sub(_depositDate);
        if (timePassed == 0) return (0, 0, 0);
        uint256 userEmissionRate = sigmoid.calculate(int256(timePassed));
        userEmissionRate = userEmissionRate.add(getSupplyBasedEmissionRate());
        if (userEmissionRate == 0) return (0, 0, timePassed);
        assert(userEmissionRate <= MAX_EMISSION_RATE);
        total = _amount.mul(MAX_EMISSION_RATE).mul(timePassed).div(YEAR * 1 ether);
        userShare = _amount.mul(userEmissionRate).mul(timePassed).div(YEAR * 1 ether);
    }

    function getSigmoidParameters() public view returns (uint256 a, int256 b, uint256 c) {

        return sigmoid.getParameters();
    }

    function _deposit(address _sender, uint256 _id, uint256 _amount) internal nonReentrant {

        require(_amount > 0, "deposit amount should be more than 0");
        (uint256 sigmoidParamA,,) = getSigmoidParameters();
        if (sigmoidParamA == 0 && totalSupplyFactor() == 0) revert("emission stopped");
        (uint256 userShare, uint256 timePassed) = _mint(_sender, _id, 0);
        uint256 newBalance = balances[_sender][_id].add(_amount);
        balances[_sender][_id] = newBalance;
        totalStaked = totalStaked.add(_amount);
        depositDates[_sender][_id] = _now();
        emit Deposited(_sender, _id, _amount, newBalance, userShare, timePassed);
    }

    function _withdraw(address _sender, uint256 _id, uint256 _amount, bool _forced) internal nonReentrant {

        require(_id > 0 && _id <= lastDepositIds[_sender], "wrong deposit id");
        require(balances[_sender][_id] > 0 && balances[_sender][_id] >= _amount, "insufficient funds");
        (uint256 accruedEmission, uint256 timePassed) = _mint(_sender, _id, _amount);
        uint256 amount = _amount == 0 ? balances[_sender][_id] : _amount.add(accruedEmission);
        balances[_sender][_id] = balances[_sender][_id].sub(amount);
        totalStaked = totalStaked.sub(amount);
        if (balances[_sender][_id] == 0) {
            depositDates[_sender][_id] = 0;
        }
        uint256 feeValue = 0;
        if (_forced) {
            feeValue = amount.mul(fee()).div(1 ether);
            amount = amount.sub(feeValue);
            require(token.transfer(liquidityProvidersRewardAddress(), feeValue), "transfer failed");
        }
        require(token.transfer(_sender, amount), "transfer failed");
        emit Withdrawn(_sender, _id, amount, feeValue, balances[_sender][_id], accruedEmission, timePassed);
    }

    function _mint(address _user, uint256 _id, uint256 _amount) internal returns (uint256, uint256) {

        uint256 currentBalance = balances[_user][_id];
        uint256 amount = _amount == 0 ? currentBalance : _amount;
        (uint256 total, uint256 userShare, uint256 timePassed) = getAccruedEmission(depositDates[_user][_id], amount);
        if (total > 0) {
            require(token.mint(address(this), total), "minting failed");
            balances[_user][_id] = currentBalance.add(userShare);
            totalStaked = totalStaked.add(userShare);
            require(token.transfer(liquidityProvidersRewardAddress(), total.sub(userShare)), "transfer failed");
        }
        return (userShare, timePassed);
    }

    function _updateUintParam(UintParam storage _param, uint256 _newValue) internal {

        if (_param.timestamp == 0) {
            _param.oldValue = _newValue;
        } else if (_paramUpdateDelayElapsed(_param.timestamp)) {
            _param.oldValue = _param.newValue;
        }
        _param.newValue = _newValue;
        _param.timestamp = _now();
    }

    function _getUintParamValue(UintParam memory _param) internal view returns (uint256) {

        return _paramUpdateDelayElapsed(_param.timestamp) ? _param.newValue : _param.oldValue;
    }

    function _paramUpdateDelayElapsed(uint256 _paramTimestamp) internal view returns (bool) {

        return _now() > _paramTimestamp.add(PARAM_UPDATE_DELAY);
    }

    function _setLocked(bool _locked) internal {

        locked = _locked;
    }

    function _now() internal view returns (uint256) {

        return now; // solium-disable-line security/no-block-members
    }
}