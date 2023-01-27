



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




library SafeDecimalMath {

    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {

        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function roundDownDecimal(uint x, uint d) internal pure returns (uint) {

        return x.div(10**d).mul(10**d);
    }

    function roundUpDecimal(uint x, uint d) internal pure returns (uint) {

        uint _decimal = 10**d;

        if (x % _decimal > 0) {
            x = x.add(10**d);
        }

        return x.div(_decimal).mul(_decimal);
    }
}


contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}




contract State is Owned {

    address public associatedContract;

    constructor(address _associatedContract) internal {
        require(owner != address(0), "Owner must be set");

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    function setAssociatedContract(address _associatedContract) external onlyOwner {

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    modifier onlyAssociatedContract {

        require(msg.sender == associatedContract, "Only the associated contract can perform this action");
        _;
    }


    event AssociatedContractUpdated(address associatedContract);
}


interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint);


    function balanceOf(address owner) external view returns (uint);


    function allowance(address owner, address spender) external view returns (uint);


    function transfer(address to, uint value) external returns (bool);


    function approve(address spender, uint value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


contract StakingState is Owned, State {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    struct TargetToken {
        address tokenAddress;
        uint8 decimals;
        bool activated;
    }

    mapping(bytes32 => TargetToken) public targetTokens;

    mapping(bytes32 => mapping(address => uint)) public stakedAmountOf;

    mapping(bytes32 => uint) public totalStakedAmount;

    mapping(bytes32 => uint) public totalStakerCount;

    bytes32[] public tokenList;

    constructor(address _owner, address _associatedContract) public Owned(_owner) State(_associatedContract) {}


    function tokenInstance(bytes32 _currencyKey) internal view returns (IERC20) {

        require(targetTokens[_currencyKey].tokenAddress != address(0), "Target address is empty");

        return IERC20(targetTokens[_currencyKey].tokenAddress);
    }

    function tokenAddress(bytes32 _currencyKey) external view returns (address) {

        return targetTokens[_currencyKey].tokenAddress;
    }

    function tokenDecimals(bytes32 _currencyKey) external view returns (uint8) {

        return targetTokens[_currencyKey].decimals;
    }

    function tokenActivated(bytes32 _currencyKey) external view returns (bool) {

        return targetTokens[_currencyKey].activated;
    }

    function getTokenCurrencyKeys() external view returns (bytes32[] memory) {

        return tokenList;
    }


    function setTargetToken(
        bytes32 _currencyKey,
        address _tokenAddress,
        uint8 _decimals
    ) external onlyOwner {

        require(_tokenAddress != address(0), "Address cannot be empty");
        require(targetTokens[_currencyKey].tokenAddress == address(0), "Token is already registered");

        if (targetTokens[_currencyKey].tokenAddress == address(0)) {
            tokenList.push(_currencyKey);
        }

        targetTokens[_currencyKey] = TargetToken(_tokenAddress, _decimals, true);
    }

    function setTokenActivation(bytes32 _currencyKey, bool _activate) external onlyOwner {

        _requireTokenRegistered(_currencyKey);

        targetTokens[_currencyKey].activated = _activate;
    }

    function stake(
        bytes32 _currencyKey,
        address _account,
        uint _amount
    ) external onlyAssociatedContract {

        _requireTokenRegistered(_currencyKey);
        require(targetTokens[_currencyKey].activated, "Target token is not activated");

        if (stakedAmountOf[_currencyKey][_account] <= 0 && _amount > 0) {
            _incrementTotalStaker(_currencyKey);
        }

        stakedAmountOf[_currencyKey][_account] = stakedAmountOf[_currencyKey][_account].add(_amount);
        totalStakedAmount[_currencyKey] = totalStakedAmount[_currencyKey].add(_amount);

        emit Staking(_currencyKey, _account, _amount);
    }

    function unstake(
        bytes32 _currencyKey,
        address _account,
        uint _amount
    ) external onlyAssociatedContract {

        require(stakedAmountOf[_currencyKey][_account] >= _amount, "Account doesn't have enough staked amount");
        require(totalStakedAmount[_currencyKey] >= _amount, "Not enough staked amount to withdraw");

        if (stakedAmountOf[_currencyKey][_account].sub(_amount) == 0) {
            _decrementTotalStaker(_currencyKey);
        }

        stakedAmountOf[_currencyKey][_account] = stakedAmountOf[_currencyKey][_account].sub(_amount);
        totalStakedAmount[_currencyKey] = totalStakedAmount[_currencyKey].sub(_amount);

        emit Unstaking(_currencyKey, _account, _amount);
    }

    function refund(
        bytes32 _currencyKey,
        address _account,
        uint _amount
    ) external onlyAssociatedContract returns (bool) {

        uint decimalDiff = targetTokens[_currencyKey].decimals < 18 ? 18 - targetTokens[_currencyKey].decimals : 0;

        return tokenInstance(_currencyKey).transfer(_account, _amount.div(10**decimalDiff));
    }


    function _requireTokenRegistered(bytes32 _currencyKey) internal view {

        require(targetTokens[_currencyKey].tokenAddress != address(0), "Target token is not registered");
    }

    function _incrementTotalStaker(bytes32 _currencyKey) internal {

        totalStakerCount[_currencyKey] = totalStakerCount[_currencyKey].add(1);
    }

    function _decrementTotalStaker(bytes32 _currencyKey) internal {

        totalStakerCount[_currencyKey] = totalStakerCount[_currencyKey].sub(1);
    }


    event Staking(bytes32 currencyKey, address account, uint amount);
    event Unstaking(bytes32 currencyKey, address account, uint amount);
}