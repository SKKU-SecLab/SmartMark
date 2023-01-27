

pragma solidity >=0.6.0 <0.8.0;

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
}





pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}





pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}





pragma solidity >=0.6.0 <0.8.0;



library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}





pragma solidity ^0.6.0;

library Babylonian {

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}





pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





pragma solidity >=0.6.0 <0.8.0;





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
}





pragma solidity 0.6.12;


contract Operator is Context, Ownable {

    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor() internal {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {

        return _operator;
    }

    modifier onlyOperator() {

        require(_operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {

        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {

        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {

        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}





pragma solidity 0.6.12;

contract ContractGuard {

    mapping(uint256 => mapping(address => bool)) private _status;

    function checkSameOriginReentranted() internal view returns (bool) {

        return _status[block.number][tx.origin];
    }

    function checkSameSenderReentranted() internal view returns (bool) {

        return _status[block.number][msg.sender];
    }

    modifier onlyOneBlock() {

        require(!checkSameOriginReentranted(), "ContractGuard: one block, one function");
        require(!checkSameSenderReentranted(), "ContractGuard: one block, one function");

        _;

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;
    }
}





pragma solidity ^0.6.0;

interface IBasisAsset {

    function mint(address recipient, uint256 amount) external returns (bool);


    function burn(uint256 amount) external;


    function burnFrom(address from, uint256 amount) external;


    function isOperator() external returns (bool);


    function operator() external view returns (address);


    function transferOperator(address newOperator_) external;

}





pragma solidity 0.6.12;

interface IOracle {

    function update() external;


    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut);


    function twap(address _token, uint256 _amountIn) external view returns (uint144 _amountOut);

}





pragma solidity 0.6.12;

interface IBoardroom {

    function balanceOf(address _member) external view returns (uint256);


    function earned(address _member) external view returns (uint256);


    function canWithdraw(address _member) external view returns (bool);


    function canClaimReward(address _member) external view returns (bool);


    function epoch() external view returns (uint256);


    function nextEpochPoint() external view returns (uint256);


    function getGldmPrice() external view returns (uint256);


    function setOperator(address _operator) external;


    function setLockUp(uint256 _withdrawLockupEpochs, uint256 _rewardLockupEpochs) external;


    function stake(uint256 _amount) external;


    function withdraw(uint256 _amount) external;


    function exit() external;


    function claimReward() external;


    function allocateSeigniorage(uint256 _amount) external;


    function governanceRecoverUnsupported(
        address _token,
        uint256 _amount,
        address _to
    ) external;

}





pragma solidity 0.6.12;


contract Treasury is ContractGuard {

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;


    uint256 public constant PERIOD = 6 hours;


    address public operator;

    bool public initialized = false;

    uint256 public startTime;
    uint256 public epoch = 0;
    uint256 public epochSupplyContractionLeft = 0;

    address[] public excludedFromTotalSupply = [
        address(0x32707372b88beF099DD2AE190804e519831eeDf4) // GldmGenesisPool
    ];

    address public gldm;
    address public bgldm;
    address public sgldm;

    address public boardroom;
    address public gldmOracle;

    uint256 public gldmPriceOne;
    uint256 public gldmPriceCeiling;

    uint256 public seigniorageSaved;

    uint256[] public supplyTiers;
    uint256[] public maxExpansionTiers;

    uint256 public maxSupplyExpansionPercent;
    uint256 public bondDepletionFloorPercent;
    uint256 public seigniorageExpansionFloorPercent;
    uint256 public maxSupplyContractionPercent;
    uint256 public maxDebtRatioPercent;

    uint256 public bootstrapEpochs;
    uint256 public bootstrapSupplyExpansionPercent;

    uint256 public previousEpochGldmPrice;
    uint256 public maxDiscountRate; // when purchasing bond
    uint256 public maxPremiumRate; // when redeeming bond
    uint256 public discountPercent;
    uint256 public premiumThreshold;
    uint256 public premiumPercent;
    uint256 public mintingFactorForPayingDebt; // print extra GLDM during debt phase

    address public daoFund;
    uint256 public daoFunsGldmdPercent;

    address public devFund;
    uint256 public devFunsGldmdPercent;


    event Initialized(address indexed executor, uint256 at);
    event BurnedBonds(address indexed from, uint256 bondAmount);
    event RedeemedBonds(address indexed from, uint256 gldmAmount, uint256 bondAmount);
    event BoughtBonds(address indexed from, uint256 gldmAmount, uint256 bondAmount);
    event TreasuryFunded(uint256 timestamp, uint256 seigniorage);
    event BoardroomFunded(uint256 timestamp, uint256 seigniorage);
    event DaoFundFunded(uint256 timestamp, uint256 seigniorage);
    event DevFundFunded(uint256 timestamp, uint256 seigniorage);


    modifier onlyOperator() {

        require(operator == msg.sender, "Treasury: caller is not the operator");
        _;
    }

    modifier checkCondition() {

        require(now >= startTime, "Treasury: not started yet");

        _;
    }

    modifier checkEpoch() {

        require(now >= nextEpochPoint(), "Treasury: not opened yet");

        _;

        epoch = epoch.add(1);
        epochSupplyContractionLeft = (getGldmPrice() > gldmPriceCeiling) ? 0 : getGldmCirculatingSupply().mul(maxSupplyContractionPercent).div(10000);
    }

    modifier checkOperator() {

        require(
            IBasisAsset(gldm).operator() == address(this) &&
                IBasisAsset(bgldm).operator() == address(this) &&
                IBasisAsset(sgldm).operator() == address(this) &&
                Operator(boardroom).operator() == address(this),
            "Treasury: need more permission"
        );

        _;
    }

    modifier notInitialized() {

        require(!initialized, "Treasury: already initialized");

        _;
    }


    function isInitialized() public view returns (bool) {

        return initialized;
    }

    function nextEpochPoint() public view returns (uint256) {

        return startTime.add(epoch.mul(PERIOD));
    }

    function getGldmPrice() public view returns (uint256 gldmPrice) {

        try IOracle(gldmOracle).consult(gldm, 1e18) returns (uint144 price) {
            return uint256(price);
        } catch {
            revert("Treasury: failed to consult GLDM price from the oracle");
        }
    }

    function getGldmUpdatedPrice() public view returns (uint256 _gldmPrice) {

        try IOracle(gldmOracle).twap(gldm, 1e18) returns (uint144 price) {
            return uint256(price);
        } catch {
            revert("Treasury: failed to consult GLDM price from the oracle");
        }
    }

    function getReserve() public view returns (uint256) {

        return seigniorageSaved;
    }

    function getBurnableGldmLeft() public view returns (uint256 _burnableGldmLeft) {

        uint256 _gldmPrice = getGldmPrice();          
        if (_gldmPrice <= gldmPriceOne) {             
            uint256 _gldmSupply = getGldmCirculatingSupply(); 
            uint256 _bondMaxSupply = _gldmSupply.mul(maxDebtRatioPercent).div(10000);
            uint256 _bondSupply = IERC20(bgldm).totalSupply();
            if (_bondMaxSupply > _bondSupply) {
                uint256 _maxMintableBond = _bondMaxSupply.sub(_bondSupply);
                uint256 _maxBurnableGldm = _maxMintableBond.mul(_gldmPrice).div(1e18);
                _burnableGldmLeft = Math.min(epochSupplyContractionLeft, _maxBurnableGldm);
            }
        }
    }

    function getRedeemableBonds() public view returns (uint256 _redeemableBonds) {

        uint256 _gldmPrice = getGldmPrice();
        if (_gldmPrice > gldmPriceCeiling) {
            uint256 _totalGldm = IERC20(gldm).balanceOf(address(this));
            uint256 _rate = getBondPremiumRate();
            if (_rate > 0) {
                _redeemableBonds = _totalGldm.mul(1e18).div(_rate);
            }
        }
    }

    function getBondDiscountRate() public view returns (uint256 _rate) {

        uint256 _gldmPrice = getGldmPrice();
        if (_gldmPrice <= gldmPriceOne) {
            if (discountPercent == 0) {
                _rate = gldmPriceOne;
            } else {
                uint256 _bondAmount = gldmPriceOne.mul(1e18).div(_gldmPrice); // to burn 1 GLDM
                uint256 _discountAmount = _bondAmount.sub(gldmPriceOne).mul(discountPercent).div(10000);
                _rate = gldmPriceOne.add(_discountAmount);
                if (maxDiscountRate > 0 && _rate > maxDiscountRate) {
                    _rate = maxDiscountRate;
                }
            }
        }
    }

    function getBondPremiumRate() public view returns (uint256 _rate) {

        uint256 _gldmPrice = getGldmPrice();
        if (_gldmPrice > gldmPriceCeiling) {
            uint256 _gldmPricePremiumThreshold = gldmPriceOne.mul(premiumThreshold).div(100);
            if (_gldmPrice >= _gldmPricePremiumThreshold) {
                uint256 _premiumAmount = _gldmPrice.sub(gldmPriceOne).mul(premiumPercent).div(10000);
                _rate = gldmPriceOne.add(_premiumAmount);
                if (maxPremiumRate > 0 && _rate > maxPremiumRate) {
                    _rate = maxPremiumRate;
                }
            } else {
                _rate = gldmPriceOne;
            }
        }
    }


    function initialize(
        address _gldm,
        address _bgldm,
        address _gldmshare,
        address _gldmOracle,
        address _boardroom,
        uint256 _startTime
    ) public notInitialized {

        gldm = _gldm;
        bgldm = _bgldm;
        sgldm = _gldmshare;
        gldmOracle = _gldmOracle;
        boardroom = _boardroom;
        startTime = _startTime;

        gldmPriceOne = 10**18; // This is to allow a PEG of 100 GLDM per wBNB
        gldmPriceCeiling = gldmPriceOne.mul(101).div(100);

        supplyTiers = [0 ether, 500000 ether, 1000000 ether, 1500000 ether, 2000000 ether, 5000000 ether, 10000000 ether, 20000000 ether, 50000000 ether];
        maxExpansionTiers = [450, 400, 350, 300, 250, 200, 150, 125, 100];

        maxSupplyExpansionPercent = 400; // Upto 4.0% supply for expansion

        bondDepletionFloorPercent = 10000; // 100% of Bond supply for depletion floor
        seigniorageExpansionFloorPercent = 3500; // At least 35% of expansion reserved for boardroom
        maxSupplyContractionPercent = 300; // Upto 3.0% supply for contraction (to burn GLDM and mint tBOND)
        maxDebtRatioPercent = 4500; // Upto 35% supply of tBOND to purchase

        premiumThreshold = 110;
        premiumPercent = 7000;

        bootstrapEpochs = 0;
        bootstrapSupplyExpansionPercent = 450;

        seigniorageSaved = IERC20(gldm).balanceOf(address(this));

        initialized = true;
        operator = msg.sender;
        emit Initialized(msg.sender, block.number);
    }

    function setOperator(address _operator) external onlyOperator {

        operator = _operator;
    }

    function setBoardroom(address _boardroom) external onlyOperator {

        boardroom = _boardroom;
    }

    function setGldmOracle(address _gldmOracle) external onlyOperator {

        gldmOracle = _gldmOracle;
    }

    function setGldmPriceCeiling(uint256 _gldmPriceCeiling) external onlyOperator {

        require(_gldmPriceCeiling >= gldmPriceOne && _gldmPriceCeiling <= gldmPriceOne.mul(120).div(100), "out of range"); // [$1.0, $1.2]
        gldmPriceCeiling = _gldmPriceCeiling;
    }

    function setMaxSupplyExpansionPercents(uint256 _maxSupplyExpansionPercent) external onlyOperator {

        require(_maxSupplyExpansionPercent >= 10 && _maxSupplyExpansionPercent <= 1000, "_maxSupplyExpansionPercent: out of range"); // [0.1%, 10%]
        maxSupplyExpansionPercent = _maxSupplyExpansionPercent;
    }

    function setSupplyTiersEntry(uint8 _index, uint256 _value) external onlyOperator returns (bool) {

        require(_index >= 0, "Index has to be higher than 0");
        require(_index < 9, "Index has to be lower than count of tiers");
        if (_index > 0) {
            require(_value > supplyTiers[_index - 1]);
        }
        if (_index < 8) {
            require(_value < supplyTiers[_index + 1]);
        }
        supplyTiers[_index] = _value;
        return true;
    }

    function setMaxExpansionTiersEntry(uint8 _index, uint256 _value) external onlyOperator returns (bool) {

        require(_index >= 0, "Index has to be higher than 0");
        require(_index < 9, "Index has to be lower than count of tiers");
        require(_value >= 10 && _value <= 1000, "_value: out of range"); // [0.1%, 10%]
        maxExpansionTiers[_index] = _value;
        return true;
    }

    function setBondDepletionFloorPercent(uint256 _bondDepletionFloorPercent) external onlyOperator {

        require(_bondDepletionFloorPercent >= 500 && _bondDepletionFloorPercent <= 10000, "out of range"); // [5%, 100%]
        bondDepletionFloorPercent = _bondDepletionFloorPercent;
    }

    function setMaxSupplyContractionPercent(uint256 _maxSupplyContractionPercent) external onlyOperator {

        require(_maxSupplyContractionPercent >= 100 && _maxSupplyContractionPercent <= 1500, "out of range"); // [0.1%, 15%]
        maxSupplyContractionPercent = _maxSupplyContractionPercent;
    }

    function setMaxDebtRatioPercent(uint256 _maxDebtRatioPercent) external onlyOperator {

        require(_maxDebtRatioPercent >= 1000 && _maxDebtRatioPercent <= 10000, "out of range"); // [10%, 100%]
        maxDebtRatioPercent = _maxDebtRatioPercent;
    }

    function setBootstrap(uint256 _bootstrapEpochs, uint256 _bootstrapSupplyExpansionPercent) external onlyOperator {

        require(_bootstrapEpochs <= 120, "_bootstrapEpochs: out of range"); // <= 1 month
        require(_bootstrapSupplyExpansionPercent >= 100 && _bootstrapSupplyExpansionPercent <= 1000, "_bootstrapSupplyExpansionPercent: out of range"); // [1%, 10%]
        bootstrapEpochs = _bootstrapEpochs;
        bootstrapSupplyExpansionPercent = _bootstrapSupplyExpansionPercent;
    }

    function setExtraFunds(
        address _daoFund,
        uint256 _daoFunsGldmdPercent,
        address _devFund,
        uint256 _devFunsGldmdPercent
    ) external onlyOperator {

        require(_daoFund != address(0), "zero");
        require(_daoFunsGldmdPercent <= 3000, "out of range"); // <= 30%
        require(_devFund != address(0), "zero");
        require(_devFunsGldmdPercent <= 1000, "out of range"); // <= 10%
        daoFund = _daoFund;
        daoFunsGldmdPercent = _daoFunsGldmdPercent;
        devFund = _devFund;
        devFunsGldmdPercent = _devFunsGldmdPercent;
    }

    function setMaxDiscountRate(uint256 _maxDiscountRate) external onlyOperator {

        maxDiscountRate = _maxDiscountRate;
    }

    function setMaxPremiumRate(uint256 _maxPremiumRate) external onlyOperator {

        maxPremiumRate = _maxPremiumRate;
    }

    function setDiscountPercent(uint256 _discountPercent) external onlyOperator {

        require(_discountPercent <= 20000, "_discountPercent is over 200%");
        discountPercent = _discountPercent;
    }

    function setPremiumThreshold(uint256 _premiumThreshold) external onlyOperator {

        require(_premiumThreshold >= gldmPriceCeiling, "_premiumThreshold exceeds gldmPriceCeiling");
        require(_premiumThreshold <= 150, "_premiumThreshold is higher than 1.5");
        premiumThreshold = _premiumThreshold;
    }

    function setPremiumPercent(uint256 _premiumPercent) external onlyOperator {

        require(_premiumPercent <= 20000, "_premiumPercent is over 200%");
        premiumPercent = _premiumPercent;
    }

    function setMintingFactorForPayingDebt(uint256 _mintingFactorForPayingDebt) external onlyOperator {

        require(_mintingFactorForPayingDebt >= 10000 && _mintingFactorForPayingDebt <= 20000, "_mintingFactorForPayingDebt: out of range"); // [100%, 200%]
        mintingFactorForPayingDebt = _mintingFactorForPayingDebt;
    }


    function _updateGldmPrice() internal {

        try IOracle(gldmOracle).update() {} catch {}
    }

    function getGldmCirculatingSupply() public view returns (uint256) {

        IERC20 gldmErc20 = IERC20(gldm);
        uint256 totalSupply = gldmErc20.totalSupply();
        uint256 balanceExcluded = 0;
        for (uint8 entryId = 0; entryId < excludedFromTotalSupply.length; ++entryId) {
            balanceExcluded = balanceExcluded.add(gldmErc20.balanceOf(excludedFromTotalSupply[entryId]));
        }
        return totalSupply.sub(balanceExcluded);
    }

    function buyBonds(uint256 _gldmAmount, uint256 targetPrice) external onlyOneBlock checkCondition checkOperator {

        require(_gldmAmount > 0, "Treasury: cannot purchase bonds with zero amount");

        uint256 gldmPrice = getGldmPrice();
        require(gldmPrice == targetPrice, "Treasury: GLDM price moved");
        require(
            gldmPrice < gldmPriceOne, // price < $1
            "Treasury: gldmPrice not eligible for bond purchase"
        );

        require(_gldmAmount <= epochSupplyContractionLeft, "Treasury: not enough bond left to purchase");

        uint256 _rate = getBondDiscountRate();
        require(_rate > 0, "Treasury: invalid bond rate");

        uint256 _bondAmount = _gldmAmount.mul(_rate).div(1e18);
        uint256 gldmSupply = getGldmCirculatingSupply();
        uint256 newBondSupply = IERC20(bgldm).totalSupply().add(_bondAmount);
        require(newBondSupply <= gldmSupply.mul(maxDebtRatioPercent).div(10000), "over max debt ratio");

        IBasisAsset(gldm).burnFrom(msg.sender, _gldmAmount);
        IBasisAsset(bgldm).mint(msg.sender, _bondAmount);

        epochSupplyContractionLeft = epochSupplyContractionLeft.sub(_gldmAmount);
        _updateGldmPrice();

        emit BoughtBonds(msg.sender, _gldmAmount, _bondAmount);
    }

    function redeemBonds(uint256 _bondAmount, uint256 targetPrice) external onlyOneBlock checkCondition checkOperator {

        require(_bondAmount > 0, "Treasury: cannot redeem bonds with zero amount");

        uint256 gldmPrice = getGldmPrice();
        require(gldmPrice == targetPrice, "Treasury: GLDM price moved");
        require(
            gldmPrice > gldmPriceCeiling, // price > $1.01
            "Treasury: gldmPrice not eligible for bond purchase"
        );

        uint256 _rate = getBondPremiumRate();
        require(_rate > 0, "Treasury: invalid bond rate");

        uint256 _gldmAmount = _bondAmount.mul(_rate).div(1e18);
        require(IERC20(gldm).balanceOf(address(this)) >= _gldmAmount, "Treasury: treasury has no more budget");

        seigniorageSaved = seigniorageSaved.sub(Math.min(seigniorageSaved, _gldmAmount));

        IBasisAsset(bgldm).burnFrom(msg.sender, _bondAmount);
        IERC20(gldm).safeTransfer(msg.sender, _gldmAmount);

        _updateGldmPrice();

        emit RedeemedBonds(msg.sender, _gldmAmount, _bondAmount);
    }

    function _sendToBoardroom(uint256 _amount) internal {

        IBasisAsset(gldm).mint(address(this), _amount);

        uint256 _daoFunsGldmdAmount = 0;
        if (daoFunsGldmdPercent > 0) {
            _daoFunsGldmdAmount = _amount.mul(daoFunsGldmdPercent).div(10000);
            IERC20(gldm).transfer(daoFund, _daoFunsGldmdAmount);
            emit DaoFundFunded(now, _daoFunsGldmdAmount);
        }

        uint256 _devFunsGldmdAmount = 0;
        if (devFunsGldmdPercent > 0) {
            _devFunsGldmdAmount = _amount.mul(devFunsGldmdPercent).div(10000);
            IERC20(gldm).transfer(devFund, _devFunsGldmdAmount);
            emit DevFundFunded(now, _devFunsGldmdAmount);
        }

        _amount = _amount.sub(_daoFunsGldmdAmount).sub(_devFunsGldmdAmount);

        IERC20(gldm).safeApprove(boardroom, 0);
        IERC20(gldm).safeApprove(boardroom, _amount);
        IBoardroom(boardroom).allocateSeigniorage(_amount);
        emit BoardroomFunded(now, _amount);
    }

    function _calculateMaxSupplyExpansionPercent(uint256 _gldmSupply) internal returns (uint256) {

        for (uint8 tierId = 8; tierId >= 0; --tierId) {
            if (_gldmSupply >= supplyTiers[tierId]) {
                maxSupplyExpansionPercent = maxExpansionTiers[tierId];
                break;
            }
        }
        return maxSupplyExpansionPercent;
    }

    function allocateSeigniorage() external onlyOneBlock checkCondition checkEpoch checkOperator {

        _updateGldmPrice();
        previousEpochGldmPrice = getGldmPrice();
        uint256 gldmSupply = getGldmCirculatingSupply().sub(seigniorageSaved);
        if (epoch < bootstrapEpochs) {
            _sendToBoardroom(gldmSupply.mul(bootstrapSupplyExpansionPercent).div(10000));
        } else {
            if (previousEpochGldmPrice > gldmPriceCeiling) {
                uint256 bondSupply = IERC20(bgldm).totalSupply();
                uint256 _percentage = previousEpochGldmPrice.sub(gldmPriceOne);
                uint256 _savedForBond;
                uint256 _savedForBoardroom;
                uint256 _mse = _calculateMaxSupplyExpansionPercent(gldmSupply).mul(1e14);
                if (_percentage > _mse) {
                    _percentage = _mse;
                }
                if (seigniorageSaved >= bondSupply.mul(bondDepletionFloorPercent).div(10000)) {
                    _savedForBoardroom = gldmSupply.mul(_percentage).div(1e18);
                } else {
                    uint256 _seigniorage = gldmSupply.mul(_percentage).div(1e18);
                    _savedForBoardroom = _seigniorage.mul(seigniorageExpansionFloorPercent).div(10000);
                    _savedForBond = _seigniorage.sub(_savedForBoardroom);
                    if (mintingFactorForPayingDebt > 0) {
                        _savedForBond = _savedForBond.mul(mintingFactorForPayingDebt).div(10000);
                    }
                }
                if (_savedForBoardroom > 0) {
                    _sendToBoardroom(_savedForBoardroom);
                }
                if (_savedForBond > 0) {
                    seigniorageSaved = seigniorageSaved.add(_savedForBond);
                    IBasisAsset(gldm).mint(address(this), _savedForBond);
                    emit TreasuryFunded(now, _savedForBond);
                }
            }
        }
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {

        require(address(_token) != address(gldm), "gldm");
        require(address(_token) != address(bgldm), "bond");
        require(address(_token) != address(sgldm), "share");
        _token.safeTransfer(_to, _amount);
    }

    function boardroomSetOperator(address _operator) external onlyOperator {

        IBoardroom(boardroom).setOperator(_operator);
    }

    function boardroomSetLockUp(uint256 _withdrawLockupEpochs, uint256 _rewardLockupEpochs) external onlyOperator {

        IBoardroom(boardroom).setLockUp(_withdrawLockupEpochs, _rewardLockupEpochs);
    }

    function boardroomAllocateSeigniorage(uint256 amount) external onlyOperator {

        IBoardroom(boardroom).allocateSeigniorage(amount);
    }

    function boardroomGovernanceRecoverUnsupported(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {

        IBoardroom(boardroom).governanceRecoverUnsupported(_token, _amount, _to);
    }
}