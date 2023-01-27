
pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// GPL-3.0
pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;


interface IFeesCollector {

    function sendProfit(uint256 amount, IERC20 token) external;

}// GPL-3.0
pragma solidity ^0.6.2;

interface ILiquidation {	

	function setMinLiquidationThreshold(uint16 newMinThreshold) external;

    function setMinLiquidationReward(uint16 newMaxRewardAmount) external;

    function setMaxLiquidationReward(uint16 newMaxRewardAmount) external;


	function isLiquidationCandidate(uint256 positionBalance, bool isPositive, uint256 positionUnitsAmount) external view returns (bool);


	function getLiquidationReward(uint256 positionBalance, bool isPositive, uint256 positionUnitsAmount) external view returns (uint256 finderFeeAmount);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath16 {

    function add(uint16 a, uint16 b) internal pure returns (uint16) {

        uint16 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint16 a, uint16 b) internal pure returns (uint16) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {

        require(b <= a, errorMessage);
        uint16 c = a - b;

        return c;
    }

    function mul(uint16 a, uint16 b) internal pure returns (uint16) {

        if (a == 0) {
            return 0;
        }

        uint16 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint16 a, uint16 b) internal pure returns (uint16) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {

        require(b > 0, errorMessage);
        uint16 c = a / b;

        return c;
    }

    function mod(uint16 a, uint16 b) internal pure returns (uint16) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// GPL-3.0
pragma solidity ^0.6.2;

interface IETHPlatform {

    function depositETH(uint256 minLPTokenAmount) external payable returns (uint256 lpTokenAmount);

    function openPositionETH(uint16 maxCVI, uint168 maxBuyingPremiumFeePercentage, uint8 leverage) external payable returns (uint256 positionUnitsAmount);

}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

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
}// MIT

pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}// MIT

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.6.0;


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
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

library SafeMath168 {
    function add(uint168 a, uint168 b) internal pure returns (uint168) {
        uint168 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint168 a, uint168 b) internal pure returns (uint168) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint168 a, uint168 b, string memory errorMessage) internal pure returns (uint168) {
        require(b <= a, errorMessage);
        uint168 c = a - b;

        return c;
    }

    function mul(uint168 a, uint168 b) internal pure returns (uint168) {
        if (a == 0) {
            return 0;
        }

        uint168 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint168 a, uint168 b) internal pure returns (uint168) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint168 a, uint168 b, string memory errorMessage) internal pure returns (uint168) {
        require(b > 0, errorMessage);
        uint168 c = a / b;

        return c;
    }

    function mod(uint168 a, uint168 b) internal pure returns (uint168) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint168 a, uint168 b, string memory errorMessage) internal pure returns (uint168) {
        require(b != 0, errorMessage);
        return a % b;
    }
}// GPL-3.0
pragma solidity ^0.6.2;

interface ICVIOracleV3 {
    function getCVIRoundData(uint80 roundId) external view returns (uint16 cviValue, uint256 cviTimestamp);
    function getCVILatestRoundData() external view returns (uint16 cviValue, uint80 cviRoundId, uint256 cviTimestamp);
}// GPL-3.0
pragma solidity ^0.6.2;

interface IFeesCalculatorV3 {

    struct CVIValue {
        uint256 period;
        uint16 cviValue;
    }

    function updateTurbulenceIndicatorPercent(uint256 totalTime, uint256 newRounds) external returns (uint16);

    function setTurbulenceUpdator(address newUpdator) external;

    function setDepositFee(uint16 newDepositFeePercentage) external;
    function setWithdrawFee(uint16 newWithdrawFeePercentage) external;
    function setOpenPositionFee(uint16 newOpenPositionFeePercentage) external;
    function setClosePositionFee(uint16 newClosePositionFeePercentage) external;
    function setClosePositionMaxFee(uint16 newClosePositionMaxFeePercentage) external;
    function setClosePositionFeeDecay(uint256 newClosePositionFeeDecayPeriod) external;
    
    function setOracleHeartbeatPeriod(uint256 newOracleHeartbeatPeriod) external;
    function setBuyingPremiumFeeMax(uint16 newBuyingPremiumFeeMaxPercentage) external;
    function setBuyingPremiumThreshold(uint16 newBuyingPremiumThreshold) external;
    function setTurbulenceStep(uint16 newTurbulenceStepPercentage) external;
    function setTurbulenceFeeMinPercentThreshold(uint16 _newTurbulenceFeeMinPercentThreshold) external;

    function calculateTurbulenceIndicatorPercent(uint256 totalHeartbeats, uint256 newRounds) external view returns (uint16);

    function calculateBuyingPremiumFee(uint168 tokenAmount, uint8 _leverage, uint256 collateralRatio) external view returns (uint168 buyingPremiumFee, uint16 combinedPremiumFeePercentage);
    function calculateBuyingPremiumFeeWithTurbulence(uint168 _tokenAmount, uint8 _leverage, uint256 _collateralRatio, uint16 _turbulenceIndicatorPercent) external view returns (uint168 buyingPremiumFee, uint16 combinedPremiumFeePercentage);
    
    function calculateSingleUnitFundingFee(CVIValue[] calldata cviValues) external pure returns (uint256 fundingFee);
    function calculateClosePositionFeePercent(uint256 creationTimestamp) external view returns (uint16);
    function calculateWithdrawFeePercent(uint256 lastDepositTimestamp) external view returns (uint16);

    function depositFeePercent() external view returns (uint16);
    function withdrawFeePercent() external view returns (uint16);
    function openPositionFeePercent() external view returns (uint16);
    function closePositionFeePercent() external view returns (uint16);
    function buyingPremiumFeeMaxPercent() external view returns (uint16);

    function openPositionFees() external view returns (uint16 openPositionFeePercentResult, uint16 buyingPremiumFeeMaxPercentResult);

    function turbulenceIndicatorPercent() external view returns (uint16);
}// GPL-3.0
pragma solidity ^0.6.2;


interface IPositionRewardsV2 {
	event Claimed(address indexed account, uint256 rewardAmount);

	function reward(address account, uint256 positionUnits, uint8 leverage) external;
	function claimReward() external;
	function calculatePositionReward(uint256 positionUnits, uint256 positionTimestamp) external view returns (uint256 rewardAmount);

	function setRewarder(address newRewarder) external;
	function setMaxDailyReward(uint256 newMaxDailyReward) external;	
	function setRewardCalculationParameters(uint256 newMaxSingleReward, uint256 rewardMaxLinearPositionUnits, uint256 rewardMaxLinearGOVI) external;
	function setRewardFactor(uint256 newRewardFactor) external;
	function setMaxClaimPeriod(uint256 newMaxClaimPeriod) external;
  	function setMaxRewardTime(uint256 newMaxRewardTime) external;
  	function setMaxRewardTimePercentageGain(uint256 _newMaxRewardTimePercentageGain) external;
	function setPlatform(PlatformV2 newPlatform) external;
}// GPL-3.0
pragma solidity ^0.6.2;


interface IPlatformV2 {

    struct Position {
        uint168 positionUnitsAmount;
        uint8 leverage;
        uint16 openCVIValue;
        uint32 creationTimestamp;
        uint32 originalCreationTimestamp;
    }

    event Deposit(address indexed account, uint256 tokenAmount, uint256 lpTokensAmount, uint256 feeAmount);
    event Withdraw(address indexed account, uint256 tokenAmount, uint256 lpTokensAmount, uint256 feeAmount);
    event OpenPosition(address indexed account, uint256 tokenAmount, uint8 leverage, uint256 feeAmount, uint256 positionUnitsAmount, uint256 cviValue);
    event ClosePosition(address indexed account, uint256 tokenAmount, uint256 feeAmount, uint256 positionUnitsAmount, uint8 leverage, uint256 cviValue);
    event LiquidatePosition(address indexed positionAddress, uint256 currentPositionBalance, bool isBalancePositive, uint256 positionUnitsAmount);

    function deposit(uint256 tokenAmount, uint256 minLPTokenAmount) external returns (uint256 lpTokenAmount);
    function withdraw(uint256 tokenAmount, uint256 maxLPTokenBurnAmount) external returns (uint256 burntAmount, uint256 withdrawnAmount);
    function withdrawLPTokens(uint256 lpTokenAmount) external returns (uint256 burntAmount, uint256 withdrawnAmount);

    function openPosition(uint168 tokenAmount, uint16 maxCVI, uint168 maxBuyingPremiumFeePercentage, uint8 leverage) external returns (uint168 positionUnitsAmount);
    function closePosition(uint168 positionUnitsAmount, uint16 minCVI) external returns (uint256 tokenAmount);

    function liquidatePositions(address[] calldata positionOwners) external returns (uint256 finderFeeAmount);
    function getLiquidableAddresses(address[] calldata positionOwners) external view returns (address[] memory);

    function setRevertLockedTransfers(bool revertLockedTransfers) external;

    function setFeesCollector(IFeesCollector newCollector) external;
    function setFeesCalculator(IFeesCalculatorV3 newCalculator) external;
    function setCVIOracle(ICVIOracleV3 newOracle) external;
    function setRewards(IPositionRewardsV2 newRewards) external;
    function setLiquidation(ILiquidation newLiquidation) external;

    function setLatestOracleRoundId(uint80 newOracleRoundId) external;

    function setLPLockupPeriod(uint256 newLPLockupPeriod) external;
    function setBuyersLockupPeriod(uint256 newBuyersLockupPeriod) external;

    function setEmergencyWithdrawAllowed(bool newEmergencyWithdrawAllowed) external;
    function setStakingContractAddress(address newStakingContractAddress) external;

    function setCanPurgeSnapshots(bool newCanPurgeSnapshots) external;

    function setMaxAllowedLeverage(uint8 newMaxAllowedLeverage) external;

    function getToken() external view returns (IERC20);

    function calculatePositionBalance(address positionAddress) external view returns (uint256 currentPositionBalance, bool isPositive, uint168 positionUnitsAmount, uint8 leverage, uint256 fundingFees, uint256 marginDebt);
    function calculatePositionPendingFees(address positionAddress, uint168 positionUnitsAmount) external view returns (uint256 pendingFees);

    function totalBalance() external view returns (uint256 balance);
    function totalBalanceWithAddendum() external view returns (uint256 balance);

    function calculateLatestTurbulenceIndicatorPercent() external view returns (uint16);

    function positions(address positionAddress) external view returns (uint168 positionUnitsAmount, uint8 leverage, uint16 openCVIValue, uint32 creationTimestamp, uint32 originalCreationTimestamp);
}// GPL-3.0
pragma solidity 0.6.12;



contract PlatformV2 is IPlatformV2, Ownable, ERC20 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath168 for uint168;

    uint168 public constant MAX_FEE_PERCENTAGE = 10000;
    uint256 public constant PRECISION_DECIMALS = 1e10;
    uint256 public constant MAX_CVI_VALUE = 20000;

    uint256 public immutable initialTokenToLPTokenRate;

    IERC20 private token;
    ICVIOracleV3 private cviOracle;
    ILiquidation private liquidation;
    IFeesCalculatorV3 private feesCalculator;
    IFeesCollector internal feesCollector;
    IPositionRewardsV2 private rewards;

    uint256 public lpsLockupPeriod = 3 days;
    uint256 public buyersLockupPeriod = 6 hours;

    uint256 public totalPositionUnitsAmount;
    uint256 public totalFundingFeesAmount;
    uint256 public totalLeveragedTokensAmount;

    uint80 public latestOracleRoundId;
    uint32 public latestSnapshotTimestamp;
    bool private canPurgeLatestSnapshot = false;
    bool public emergencyWithdrawAllowed = false;
    bool private purgeSnapshots = true;

    uint8 public maxAllowedLeverage = 1;

    address private stakingContractAddress = address(0);
    
    mapping(uint256 => uint256) public cviSnapshots;

    mapping(address => uint256) public lastDepositTimestamp;
    mapping(address => Position) public override positions;

    mapping(address => bool) public revertLockedTransfered;

    constructor(IERC20 _token, string memory _lpTokenName, string memory _lpTokenSymbolName, uint256 _initialTokenToLPTokenRate,
        IFeesCalculatorV3 _feesCalculator,
        ICVIOracleV3 _cviOracle,
        ILiquidation _liquidation) public ERC20(_lpTokenName, _lpTokenSymbolName) {

        token = _token;
        initialTokenToLPTokenRate = _initialTokenToLPTokenRate;
        feesCalculator = _feesCalculator;
        cviOracle = _cviOracle;
        liquidation = _liquidation;
    }

    function deposit(uint256 _tokenAmount, uint256 _minLPTokenAmount) external virtual override returns (uint256 lpTokenAmount) {
        _deposit(_tokenAmount, _minLPTokenAmount);
    }

    function withdraw(uint256 _tokenAmount, uint256 _maxLPTokenBurnAmount) external override returns (uint256 burntAmount, uint256 withdrawnAmount) {
        (burntAmount, withdrawnAmount) = _withdraw(_tokenAmount, false, _maxLPTokenBurnAmount);
    }

    function withdrawLPTokens(uint256 _lpTokensAmount) external override returns (uint256 burntAmount, uint256 withdrawnAmount) {
        require(_lpTokensAmount > 0, "Amount must be positive");
        (burntAmount, withdrawnAmount) = _withdraw(0, true, _lpTokensAmount);
    }

    struct OpenPositionLocals {
        uint256 balance;
        uint256 collateralRatio;
        uint256 marginDebt;
        uint256 positionBalance;
        uint256 latestSnapshot;
        uint256 openPositionFee;
        uint256 minPositionUnitsAmount;
        uint168 buyingPremiumFee;
        uint168 buyingPremiumFeePercentage;
        uint168 tokenAmountToOpenPosition;
        uint256 maxPositionUnitsAmount;
        uint16 cviValue;
    }

    function openPosition(uint168 _tokenAmount, uint16 _maxCVI, uint168 _maxBuyingPremiumFeePercentage, uint8 _leverage) external override virtual returns (uint168 positionUnitsAmount) {
        _openPosition(_tokenAmount, _maxCVI, _maxBuyingPremiumFeePercentage, _leverage);
    }

    function closePosition(uint168 _positionUnitsAmount, uint16 _minCVI) external override returns (uint256 tokenAmount) {
        require(_positionUnitsAmount > 0, "Position units not positive");
        require(_minCVI > 0 && _minCVI <= MAX_CVI_VALUE, "Bad min CVI value");

        Position storage position = positions[msg.sender];

        require(position.positionUnitsAmount >= _positionUnitsAmount, "Not enough opened position units");
        require(block.timestamp.sub(position.creationTimestamp) >= buyersLockupPeriod, "Position locked");

        (uint16 cviValue, uint256 latestSnapshot) = updateSnapshots(true);
        require(cviValue >= _minCVI, "CVI too low");

        (uint256 positionBalance, uint256 fundingFees, uint256 marginDebt, bool wasLiquidated) = _closePosition(position, _positionUnitsAmount, latestSnapshot, cviValue);

        if (wasLiquidated) {
            return 0;
        }

        (uint256 newTotalPositionUnitsAmount, uint256 newTotalFundingFeesAmount) = subtractTotalPositionUnits(_positionUnitsAmount, fundingFees);
        totalPositionUnitsAmount = newTotalPositionUnitsAmount;
        totalFundingFeesAmount = newTotalFundingFeesAmount;
        position.positionUnitsAmount = position.positionUnitsAmount.sub(_positionUnitsAmount);

        uint256 closePositionFee = positionBalance
            .mul(uint256(feesCalculator.calculateClosePositionFeePercent(position.creationTimestamp)))
            .div(MAX_FEE_PERCENTAGE);

        emit ClosePosition(msg.sender, positionBalance.add(fundingFees), closePositionFee.add(fundingFees), position.positionUnitsAmount, position.leverage, cviValue);

        if (position.positionUnitsAmount == 0) {
            delete positions[msg.sender];
        }

        totalLeveragedTokensAmount = totalLeveragedTokensAmount.sub(positionBalance).sub(marginDebt);
        tokenAmount = positionBalance.sub(closePositionFee);

        collectProfit(closePositionFee);
        transferTokens(tokenAmount);
    }

    function _closePosition(Position storage _position, uint256 _positionUnitsAmount, uint256 _latestSnapshot, uint16 _cviValue) private returns (uint256 positionBalance, uint256 fundingFees, uint256 marginDebt, bool wasLiquidated) {
        fundingFees = _calculateFundingFees(cviSnapshots[_position.creationTimestamp], _latestSnapshot, _positionUnitsAmount);
        
        (uint256 currentPositionBalance, bool isPositive, uint256 __marginDebt) = __calculatePositionBalance(_positionUnitsAmount, _position.leverage, _cviValue, _position.openCVIValue, fundingFees);
        
        if (!isPositive) {
            checkAndLiquidatePosition(msg.sender, false); // Will always liquidate
            wasLiquidated = true;
            fundingFees = 0;
        } else {
            positionBalance = currentPositionBalance;
            marginDebt = __marginDebt;
        }
    }

    function liquidatePositions(address[] calldata _positionOwners) external override returns (uint256 finderFeeAmount) {
        updateSnapshots(true);
        bool liquidationOccured = false;
        for ( uint256 i = 0; i < _positionOwners.length; i++) {
            uint256 positionUnitsAmount = positions[_positionOwners[i]].positionUnitsAmount;

            if (positionUnitsAmount > 0) {
                (bool wasLiquidated, uint256 liquidatedAmount, bool isPositive) = checkAndLiquidatePosition(_positionOwners[i], false);

                if (wasLiquidated) {
                    liquidationOccured = true;
                    finderFeeAmount = finderFeeAmount.add(liquidation.getLiquidationReward(liquidatedAmount, isPositive, positionUnitsAmount));
                }
            }
        }

        require(liquidationOccured, "No liquidatable position");
        
        transferTokens(finderFeeAmount);
        totalLeveragedTokensAmount = totalLeveragedTokensAmount.sub(finderFeeAmount);
    }

    function setFeesCollector(IFeesCollector _newCollector) external override onlyOwner {
        if (address(feesCollector) != address(0) && address(token) != address(0)) {
            token.safeApprove(address(feesCollector), uint256(-1));
        }

        feesCollector = _newCollector;

        if (address(_newCollector) != address(0) && address(token) != address(0)) {
            token.safeApprove(address(feesCollector), uint256(-1));
        }
    }

    function setFeesCalculator(IFeesCalculatorV3 _newCalculator) external override onlyOwner {
        feesCalculator = _newCalculator;
    }

    function setCVIOracle(ICVIOracleV3 _newOracle) external override onlyOwner {
        cviOracle = _newOracle;
    }

    function setRewards(IPositionRewardsV2 _newRewards) external override onlyOwner {
        rewards = _newRewards;
    }

    function setLiquidation(ILiquidation _newLiquidation) external override onlyOwner {
        liquidation = _newLiquidation;
    }

    function setLatestOracleRoundId(uint80 _newOracleRoundId) external override onlyOwner {
        latestOracleRoundId = _newOracleRoundId;
    }
    
    function setLPLockupPeriod(uint256 _newLPLockupPeriod) external override onlyOwner {
        require(_newLPLockupPeriod <= 2 weeks, "Lockup too long");
        lpsLockupPeriod = _newLPLockupPeriod;
    }

    function setBuyersLockupPeriod(uint256 _newBuyersLockupPeriod) external override onlyOwner {
        require(_newBuyersLockupPeriod <= 1 weeks, "Lockup too long");
        buyersLockupPeriod = _newBuyersLockupPeriod;
    }

    function setRevertLockedTransfers(bool _revertLockedTransfers) external override {
        revertLockedTransfered[msg.sender] = _revertLockedTransfers;   
    }

    function setEmergencyWithdrawAllowed(bool _newEmergencyWithdrawAllowed) external override onlyOwner {
        emergencyWithdrawAllowed = _newEmergencyWithdrawAllowed;
    }

    function setStakingContractAddress(address _newStakingContractAddress) external override onlyOwner {
        stakingContractAddress = _newStakingContractAddress;
    }

    function setCanPurgeSnapshots(bool _newCanPurgeSnapshots) external override onlyOwner {
        purgeSnapshots = _newCanPurgeSnapshots;
    }

    function setMaxAllowedLeverage(uint8 _newMaxAllowedLeverage) external override onlyOwner {
        maxAllowedLeverage = _newMaxAllowedLeverage;
    }

    function getToken() external view override returns (IERC20) {
        return token;
    }

    function calculatePositionBalance(address _positionAddress) external view override returns (uint256 currentPositionBalance, bool isPositive, uint168 positionUnitsAmount, uint8 leverage, uint256 fundingFees, uint256 marginDebt) {
        positionUnitsAmount = positions[_positionAddress].positionUnitsAmount;
        leverage = positions[_positionAddress].leverage;
        require(positionUnitsAmount > 0, "No position for given address");
        (currentPositionBalance, isPositive, fundingFees, marginDebt) = _calculatePositionBalance(_positionAddress, true);
    }

    function calculatePositionPendingFees(address _positionAddress, uint168 _positionUnitsAmount) external view override returns (uint256 pendingFees) {
        Position memory position = positions[_positionAddress];
        pendingFees = _calculateFundingFees(cviSnapshots[position.creationTimestamp], 
            cviSnapshots[latestSnapshotTimestamp], _positionUnitsAmount).add(
                calculateLatestFundingFees(latestSnapshotTimestamp, _positionUnitsAmount));
    }

    function totalBalance() public view override returns (uint256 balance) {
        (uint16 cviValue,,) = cviOracle.getCVILatestRoundData();
        return _totalBalance(cviValue);
    }

    function totalBalanceWithAddendum() external view override returns (uint256 balance) {
        return totalBalance().add(calculateLatestFundingFees(latestSnapshotTimestamp, totalPositionUnitsAmount));
    }

    function calculateLatestTurbulenceIndicatorPercent() external view override returns (uint16) {
        SnapshotUpdate memory updateData = _updateSnapshots(latestSnapshotTimestamp);
        if (updateData.updatedTurbulenceData) {
            return feesCalculator.calculateTurbulenceIndicatorPercent(updateData.totalTime, updateData.totalRounds);
        } else {
            return feesCalculator.turbulenceIndicatorPercent();
        }
    }

    function getLiquidableAddresses(address[] calldata _positionOwners) external view override returns (address[] memory) {
        address[] memory addressesToLiquidate = new address[](_positionOwners.length);

        uint256 liquidationAddressesAmount = 0;
        for (uint256 i = 0; i < _positionOwners.length; i++) {
            (uint256 currentPositionBalance, bool isBalancePositive,, ) = _calculatePositionBalance(_positionOwners[i], true);

            if (liquidation.isLiquidationCandidate(currentPositionBalance, isBalancePositive, positions[_positionOwners[i]].positionUnitsAmount)) {
                addressesToLiquidate[liquidationAddressesAmount] = _positionOwners[i];
                liquidationAddressesAmount = liquidationAddressesAmount.add(1);
            }
        }

        address[] memory addressesToActuallyLiquidate = new address[](liquidationAddressesAmount);
        for (uint256 i = 0; i < liquidationAddressesAmount; i++) {
            addressesToActuallyLiquidate[i] = addressesToLiquidate[i];
        }

        return addressesToActuallyLiquidate;
    }

    function collectTokens(uint256 _tokenAmount) internal virtual {
        token.safeTransferFrom(msg.sender, address(this), _tokenAmount);
    }

    function _deposit(uint256 _tokenAmount, uint256 _minLPTokenAmount) internal returns (uint256 lpTokenAmount) {
        require(_tokenAmount > 0, "Tokens amount must be positive");
        lastDepositTimestamp[msg.sender] = block.timestamp;

        (uint16 cviValue,) = updateSnapshots(true);

        uint256 depositFee = _tokenAmount.mul(uint256(feesCalculator.depositFeePercent())) / MAX_FEE_PERCENTAGE;

        uint256 tokenAmountToDeposit = _tokenAmount.sub(depositFee);
        uint256 supply = totalSupply();
        uint256 balance = _totalBalance(cviValue);
    
        if (supply > 0 && balance > 0) {
            lpTokenAmount = tokenAmountToDeposit.mul(supply) / balance;
        } else {
            lpTokenAmount = tokenAmountToDeposit.mul(initialTokenToLPTokenRate);
        }

        emit Deposit(msg.sender, _tokenAmount, lpTokenAmount, depositFee);

        require(lpTokenAmount >= _minLPTokenAmount, "Too few LP tokens");
        require(lpTokenAmount > 0, "Too few tokens");
        _mint(msg.sender, lpTokenAmount);

        collectTokens(_tokenAmount);
        totalLeveragedTokensAmount = totalLeveragedTokensAmount.add(tokenAmountToDeposit);

        collectProfit(depositFee);
    }

    function _withdraw(uint256 _tokenAmount, bool _shouldBurnMax, uint256 _maxLPTokenBurnAmount) internal returns (uint256 burntAmount, uint256 withdrawnAmount) {
        require(lastDepositTimestamp[msg.sender].add(lpsLockupPeriod) <= block.timestamp, "Funds are locked");

        (uint16 cviValue,) = updateSnapshots(true);

        if (_shouldBurnMax) {
            burntAmount = _maxLPTokenBurnAmount;
            _tokenAmount = burntAmount.mul(_totalBalance(cviValue)).div(totalSupply());
        } else {
            require(_tokenAmount > 0, "Tokens amount must be positive");

            burntAmount = _tokenAmount.mul(totalSupply()).sub(1).div(_totalBalance(cviValue)).add(1);
            require(burntAmount <= _maxLPTokenBurnAmount, "Too much LP tokens to burn");
        }

        require(burntAmount <= balanceOf(msg.sender), "Not enough LP tokens for account");
        
        uint256 withdrawFee = _tokenAmount.mul(uint256(feesCalculator.withdrawFeePercent())) / MAX_FEE_PERCENTAGE;
        withdrawnAmount = _tokenAmount.sub(withdrawFee);

        require(emergencyWithdrawAllowed || getTokenBalance().sub(totalPositionUnitsAmount) >= _tokenAmount, "Collateral ratio broken");

        emit Withdraw(msg.sender, _tokenAmount, burntAmount, withdrawFee);
        
        _burn(msg.sender, burntAmount);

        collectProfit(withdrawFee);
        transferTokens(withdrawnAmount);
        totalLeveragedTokensAmount = totalLeveragedTokensAmount.sub(_tokenAmount);
    }

    function _openPosition(uint168 _tokenAmount, uint16 _maxCVI, uint168 _maxBuyingPremiumFeePercentage, uint8 _leverage) internal returns (uint168 positionUnitsAmount) {
        require(_leverage > 0, "Leverage must be positive");
        require(_leverage <= maxAllowedLeverage, "Leverage excceeds max allowed");
        require(_tokenAmount > 0, "Tokens amount must be positive");
        require(_maxCVI > 0 && _maxCVI <= MAX_CVI_VALUE, "Bad max CVI value");

        OpenPositionLocals memory locals;

        (locals.cviValue, locals.latestSnapshot) = updateSnapshots(false);
        require(locals.cviValue <= _maxCVI, "CVI too high");

        (uint16 openPositionFeePercent, uint16 buyingPremiumFeeMaxPercent) = feesCalculator.openPositionFees();

        locals.openPositionFee = uint256(_tokenAmount).mul(_leverage).mul(openPositionFeePercent) / MAX_FEE_PERCENTAGE;
        locals.maxPositionUnitsAmount = uint256(_tokenAmount).sub(locals.openPositionFee).mul(_leverage).mul(MAX_CVI_VALUE) / locals.cviValue;
        locals.minPositionUnitsAmount = locals.maxPositionUnitsAmount.
            mul(MAX_FEE_PERCENTAGE.sub(buyingPremiumFeeMaxPercent)) / MAX_FEE_PERCENTAGE;

        locals.balance = getTokenBalance(_tokenAmount);

        locals.collateralRatio = 0;
        if (locals.balance > 0) {
            locals.collateralRatio = (totalPositionUnitsAmount.add(locals.minPositionUnitsAmount)).mul(PRECISION_DECIMALS).
                div((locals.balance.add(uint256(_tokenAmount) - locals.openPositionFee)));
        }
        (locals.buyingPremiumFee, locals.buyingPremiumFeePercentage) = feesCalculator.calculateBuyingPremiumFee(_tokenAmount, _leverage, locals.collateralRatio);

        require(locals.buyingPremiumFeePercentage <= _maxBuyingPremiumFeePercentage, "Premium fee too high");
        
        require(locals.openPositionFee < _tokenAmount, "Open fee too big");
        locals.tokenAmountToOpenPosition = (_tokenAmount - uint168(locals.openPositionFee)).sub(locals.buyingPremiumFee).mul(_leverage);
        
        Position storage position = positions[msg.sender];

        if (position.positionUnitsAmount > 0) {
            (positionUnitsAmount, locals.marginDebt, locals.positionBalance) = _mergePosition(position, locals.latestSnapshot, locals.cviValue, locals.tokenAmountToOpenPosition, _leverage);
            uint256 addedTotalLeveragedTokensAmount = totalLeveragedTokensAmount.add(uint256(_tokenAmount).add(locals.positionBalance).mul(_leverage) - locals.openPositionFee);
            totalLeveragedTokensAmount = addedTotalLeveragedTokensAmount.sub(locals.marginDebt).sub(locals.positionBalance);
        } else {
            uint256 __positionUnitsAmount = uint256(locals.tokenAmountToOpenPosition).mul(MAX_CVI_VALUE) / locals.cviValue;
            positionUnitsAmount = uint168(__positionUnitsAmount);
            require(positionUnitsAmount == __positionUnitsAmount, "Too much position units");

            Position memory newPosition = Position(positionUnitsAmount, _leverage, locals.cviValue, uint32(block.timestamp), uint32(block.timestamp));

            positions[msg.sender] = newPosition;
            totalPositionUnitsAmount = totalPositionUnitsAmount.add(positionUnitsAmount);

            totalLeveragedTokensAmount = totalLeveragedTokensAmount.add(_tokenAmount * _leverage - locals.openPositionFee);
        }   

        emit OpenPosition(msg.sender, _tokenAmount, _leverage, locals.openPositionFee.add(locals.buyingPremiumFee), positionUnitsAmount, locals.cviValue);

        collectTokens(_tokenAmount);        

        locals.balance = locals.balance.add(_tokenAmount);
        collectProfit(locals.openPositionFee);

        require(totalPositionUnitsAmount <= locals.balance, "Not enough liquidity");

        if (address(rewards) != address(0)) {
            rewards.reward(msg.sender, positionUnitsAmount, _leverage);
        }
    }

    struct MergePositionLocals {
        uint168 oldPositionUnits;
        uint256 newPositionUnits;
        uint256 newTotalPositionUnitsAmount;
        uint256 newTotalFundingFeesAmount;
    }

    function _mergePosition(Position storage _position, uint256 _latestSnapshot, uint16 _cviValue, uint256 _leveragedTokenAmount, uint8 _leverage) private returns (uint168 positionUnitsAmount, uint256 marginDebt, uint256 positionBalance) {
        MergePositionLocals memory locals;

        locals.oldPositionUnits = _position.positionUnitsAmount;
        (uint256 currentPositionBalance, uint256 fundingFees, uint256 __marginDebt, bool wasLiquidated) = _closePosition(_position, locals.oldPositionUnits, _latestSnapshot, _cviValue);
        
        if (wasLiquidated) {
            currentPositionBalance = 0;
            locals.oldPositionUnits = 0;
            __marginDebt = 0;
            locals.oldPositionUnits = 0;
        }

        locals.newPositionUnits = currentPositionBalance.mul(_leverage).add(_leveragedTokenAmount).mul(MAX_CVI_VALUE).div(_cviValue);
        positionUnitsAmount = uint168(locals.newPositionUnits);
        require(positionUnitsAmount == locals.newPositionUnits, "Too much position units");

        _position.creationTimestamp = uint32(block.timestamp);
        _position.positionUnitsAmount = positionUnitsAmount;
        _position.openCVIValue = _cviValue;
        _position.leverage = _leverage;

        (locals.newTotalPositionUnitsAmount, locals.newTotalFundingFeesAmount) = subtractTotalPositionUnits(locals.oldPositionUnits, fundingFees);
        totalFundingFeesAmount = locals.newTotalFundingFeesAmount;
        totalPositionUnitsAmount = locals.newTotalPositionUnitsAmount.add(positionUnitsAmount);
        marginDebt = __marginDebt;
        positionBalance = currentPositionBalance;
    }

    function transferTokens(uint256 _tokenAmount) internal virtual {
        token.safeTransfer(msg.sender, _tokenAmount);
    }

    function _beforeTokenTransfer(address from, address to, uint256) internal override {
        if (lastDepositTimestamp[from].add(lpsLockupPeriod) > block.timestamp && 
            lastDepositTimestamp[from] > lastDepositTimestamp[to] && 
            from != stakingContractAddress && to != stakingContractAddress) {
                require(!revertLockedTransfered[to], "Recipient refuses locked tokens");
                lastDepositTimestamp[to] = lastDepositTimestamp[from];
        }
    }

    function sendProfit(uint256 _amount, IERC20 _token) internal virtual {
        feesCollector.sendProfit(_amount, _token);
    }

    function getTokenBalance() private view returns (uint256) {
        return getTokenBalance(0);
    }

    function getTokenBalance(uint256 _tokenAmount) internal view virtual returns (uint256) {
        return token.balanceOf(address(this));
    }

    struct SnapshotUpdate {
        uint256 latestSnapshot;
        uint256 singleUnitFundingFee;
        uint256 totalTime;
        uint256 totalRounds;
        uint80 newLatestRoundId;
        uint16 cviValue;
        bool updatedSnapshot;
        bool updatedLatestRoundId;
        bool updatedLatestTimestamp;
        bool updatedTurbulenceData;
    }

    function updateSnapshots(bool _canPurgeLatestSnapshot) private returns (uint16 latestCVIValue, uint256 latestSnapshot) {
        uint256 latestTimestamp = latestSnapshotTimestamp;
        SnapshotUpdate memory updateData = _updateSnapshots(latestTimestamp);

        if (updateData.updatedSnapshot) {
            cviSnapshots[block.timestamp] = updateData.latestSnapshot;
            totalFundingFeesAmount = totalFundingFeesAmount.add(updateData.singleUnitFundingFee.mul(totalPositionUnitsAmount) / PRECISION_DECIMALS);
        }

        if (updateData.updatedLatestRoundId) {
            latestOracleRoundId = updateData.newLatestRoundId;
        }

        if (updateData.updatedTurbulenceData) {
            feesCalculator.updateTurbulenceIndicatorPercent(updateData.totalTime, updateData.totalRounds);
        }

        if (updateData.updatedLatestTimestamp) {
            latestSnapshotTimestamp = uint32(block.timestamp);

            if (canPurgeLatestSnapshot && purgeSnapshots) {
                delete cviSnapshots[latestTimestamp];
            }

            canPurgeLatestSnapshot = _canPurgeLatestSnapshot;
        } else if (canPurgeLatestSnapshot) {
            canPurgeLatestSnapshot = _canPurgeLatestSnapshot;
        }

        return (updateData.cviValue, updateData.latestSnapshot);
    }

    function _updateSnapshots(uint256 _latestTimestamp) private view returns (SnapshotUpdate memory snapshotUpdate) {
        (uint16 cviValue, uint80 periodEndRoundId, uint256 periodEndTimestamp) = cviOracle.getCVILatestRoundData();
        snapshotUpdate.cviValue = cviValue;

        snapshotUpdate.latestSnapshot = cviSnapshots[block.timestamp];
        if (snapshotUpdate.latestSnapshot != 0) { // Block was already updated
            snapshotUpdate.singleUnitFundingFee = 0;
            return snapshotUpdate;
        }

        if (latestSnapshotTimestamp == 0) { // For first recorded block
            snapshotUpdate.latestSnapshot = PRECISION_DECIMALS;
            snapshotUpdate.updatedSnapshot = true;
            snapshotUpdate.newLatestRoundId = periodEndRoundId;
            snapshotUpdate.updatedLatestRoundId = true;
            snapshotUpdate.updatedLatestTimestamp = true;
            snapshotUpdate.singleUnitFundingFee = 0;
            return snapshotUpdate;
        }

        uint80 periodStartRoundId = latestOracleRoundId;
        require(periodEndRoundId >= periodStartRoundId, "Bad round id");

        snapshotUpdate.totalRounds = periodEndRoundId - periodStartRoundId;

        uint256 cviValuesNum = snapshotUpdate.totalRounds > 0 ? 2 : 1;
        IFeesCalculatorV3.CVIValue[] memory cviValues = new IFeesCalculatorV3.CVIValue[](cviValuesNum);
        
        if (snapshotUpdate.totalRounds > 0) {
            (uint16 periodStartCVIValue, uint256 periodStartTimestamp) = cviOracle.getCVIRoundData(periodStartRoundId);
            cviValues[0] = IFeesCalculatorV3.CVIValue(periodEndTimestamp.sub(_latestTimestamp), periodStartCVIValue);
            cviValues[1] = IFeesCalculatorV3.CVIValue(block.timestamp.sub(periodEndTimestamp), cviValue);

            snapshotUpdate.newLatestRoundId = periodEndRoundId;
            snapshotUpdate.updatedLatestRoundId = true;

            snapshotUpdate.totalTime = periodEndTimestamp.sub(periodStartTimestamp);
            snapshotUpdate.updatedTurbulenceData = true;
        } else {
            cviValues[0] = IFeesCalculatorV3.CVIValue(block.timestamp.sub(_latestTimestamp), cviValue);
        }

        snapshotUpdate.singleUnitFundingFee = feesCalculator.calculateSingleUnitFundingFee(cviValues);
        snapshotUpdate.latestSnapshot = cviSnapshots[_latestTimestamp].add(snapshotUpdate.singleUnitFundingFee);
        snapshotUpdate.updatedSnapshot = true;
        snapshotUpdate.updatedLatestTimestamp = true;
    }

    function _totalBalance(uint16 _cviValue) private view returns (uint256 balance) {
        return totalLeveragedTokensAmount.add(totalFundingFeesAmount).sub(totalPositionUnitsAmount.mul(_cviValue) / MAX_CVI_VALUE);
    }

    function collectProfit(uint256 amount) private {
        if (amount > 0 && address(feesCollector) != address(0)) {
            sendProfit(amount, token);
        }
    }

    function checkAndLiquidatePosition(address _positionAddress, bool _withAddendum) private returns (bool wasLiquidated, uint256 liquidatedAmount, bool isPositive) {
        (uint256 currentPositionBalance, bool isBalancePositive, uint256 fundingFees, uint256 marginDebt) = _calculatePositionBalance(_positionAddress, _withAddendum);
        isPositive = isBalancePositive;
        liquidatedAmount = currentPositionBalance;

        if (liquidation.isLiquidationCandidate(currentPositionBalance, isBalancePositive, positions[_positionAddress].positionUnitsAmount)) {
            Position memory position = positions[_positionAddress];

            (uint256 newTotalPositionUnitsAmount, uint256 newTotalFundingFeesAmount) = subtractTotalPositionUnits(position.positionUnitsAmount, fundingFees);
            totalPositionUnitsAmount = newTotalPositionUnitsAmount;
            totalFundingFeesAmount = newTotalFundingFeesAmount;
            totalLeveragedTokensAmount = totalLeveragedTokensAmount.sub(marginDebt);

            emit LiquidatePosition(_positionAddress, currentPositionBalance, isBalancePositive, position.positionUnitsAmount);

            delete positions[_positionAddress];
            wasLiquidated = true;
        }
    }

    function subtractTotalPositionUnits(uint168 _positionUnitsAmountToSubtract, uint256 _fundingFeesToSubtract) private view returns (uint256 newTotalPositionUnitsAmount, uint256 newTotalFundingFeesAMount) {
        newTotalPositionUnitsAmount = totalPositionUnitsAmount.sub(_positionUnitsAmountToSubtract);
        newTotalFundingFeesAMount = totalFundingFeesAmount;
        if (newTotalPositionUnitsAmount == 0) {
            newTotalFundingFeesAMount = 0;
        } else {
            newTotalFundingFeesAMount = newTotalFundingFeesAMount.sub(_fundingFeesToSubtract);
        }
    }

    function _calculatePositionBalance(address _positionAddress, bool _withAddendum) private view returns (uint256 currentPositionBalance, bool isPositive, uint256 fundingFees, uint256 marginDebt) {
        Position memory position = positions[_positionAddress];

        (uint16 cviValue,,) = cviOracle.getCVILatestRoundData();

        fundingFees = _calculateFundingFees(cviSnapshots[position.creationTimestamp], cviSnapshots[latestSnapshotTimestamp], position.positionUnitsAmount);
        if (_withAddendum) {
            fundingFees = fundingFees.add(calculateLatestFundingFees(latestSnapshotTimestamp, position.positionUnitsAmount));
        }
        
        (currentPositionBalance, isPositive, marginDebt) = __calculatePositionBalance(position.positionUnitsAmount, position.leverage, cviValue, position.openCVIValue, fundingFees);
    }

    function __calculatePositionBalance(uint256 _positionUnits, uint8 _leverage, uint16 _cviValue, uint16 _openCVIValue, uint256 _fundingFees) private pure returns (uint256 currentPositionBalance, bool isPositive, uint256 marginDebt) {
        uint256 positionBalanceWithoutFees = _positionUnits.mul(_cviValue) / MAX_CVI_VALUE;

        marginDebt = _leverage > 1 ? _positionUnits.mul(_openCVIValue).mul(_leverage - 1) / MAX_CVI_VALUE / _leverage: 0;
        uint256 totalDebt = marginDebt.add(_fundingFees);

        if (positionBalanceWithoutFees >= totalDebt) {
            currentPositionBalance = positionBalanceWithoutFees.sub(totalDebt);
            isPositive = true;
        } else {
            currentPositionBalance = totalDebt.sub(positionBalanceWithoutFees);
        }
    }

    function _calculateFundingFees(uint256 startTimeSnapshot, uint256 endTimeSnapshot, uint256 positionUnitsAmount) private pure returns (uint256) {
        return endTimeSnapshot.sub(startTimeSnapshot).mul(positionUnitsAmount) / PRECISION_DECIMALS;
    }

    function calculateLatestFundingFees(uint256 startTime, uint256 positionUnitsAmount) private view returns (uint256) {
        SnapshotUpdate memory updateData = _updateSnapshots(latestSnapshotTimestamp);
        return _calculateFundingFees(cviSnapshots[startTime], updateData.latestSnapshot, positionUnitsAmount);
    }
}// GPL-3.0
pragma solidity 0.6.12;




contract ETHPlatform is PlatformV2, IETHPlatform {

    constructor(string memory _lpTokenName, string memory _lpTokenSymbolName, uint256 _initialTokenToLPTokenRate,
        IFeesCalculatorV3 _feesCalculator,
        ICVIOracleV3 _cviOracle,
        ILiquidation _liquidation) public PlatformV2(IERC20(address(0)), _lpTokenName, _lpTokenSymbolName, _initialTokenToLPTokenRate, _feesCalculator, _cviOracle, _liquidation) {
    }

    function depositETH(uint256 _minLPTokenAmount) external override payable returns (uint256 lpTokenAmount) {
        lpTokenAmount = _deposit(msg.value, _minLPTokenAmount);
    }

    function openPositionETH(uint16 _maxCVI, uint168 _maxBuyingPremiumFeePercentage, uint8 _leverage) external override payable returns (uint256 positionUnitsAmount) {
        require(uint168(msg.value) == msg.value, "Too much ETH");
        positionUnitsAmount = _openPosition(uint168(msg.value), _maxCVI, _maxBuyingPremiumFeePercentage, _leverage);
    }

    function transferTokens(uint256 _tokenAmount) internal override {
        msg.sender.transfer(_tokenAmount);
    }

    function collectTokens(uint256 _tokenAmount) internal override {
    }

    function getTokenBalance(uint256 _tokenAmount) internal view override returns (uint256) {
        return address(this).balance.sub(_tokenAmount);
    }

    function sendProfit(uint256 _amount, IERC20 _token) internal override {
        payable(address(feesCollector)).transfer(_amount);
    }

    function deposit(uint256 tokenAmount, uint256 minLPTokenAmount) external override returns (uint256 lpTokenAmount) {
        revert("Use depositETH");
    }

    function openPosition(uint168 tokenAmount, uint16 maxCVI, uint168 maxBuyingPremiumFeePercentage, uint8 leverage) external override returns (uint168 positionUnitsAmount) {
        revert("Use openPositionETH");
    }
}