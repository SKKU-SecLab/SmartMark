
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
pragma experimental ABIEncoderV2;

interface IRewards {
	function reward(address account, uint256 positionUnits) external;
	function claimReward(uint256[] memory openPositionDays) external;

	function setRewarder(address newRewarder) external;
	function setDailyReward(uint256 newDailyReward) external;
}// GPL-3.0
pragma solidity ^0.6.2;

interface ICVIOracle {
    function getCVIRoundData(uint80 roundId) external view returns (uint16 cviValue, uint256 cviTimestamp);
    function getCVILatestRoundData() external view returns (uint16 cviValue, uint80 cviRoundId);
}// GPL-3.0
pragma solidity ^0.6.2;

interface IFeesCalculator {

    struct CVIValue {
        uint256 period;
        uint16 cviValue;
    }

    function updateTurbulenceIndicatorPercent(uint256[] calldata periods) external returns (uint16);

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

    function calculateBuyingPremiumFee(uint256 tokenAmount, uint256 collateralRatio) external view returns (uint256 buyingPremiumFee);
    function calculateSingleUnitFundingFee(CVIValue[] calldata cviValues) external pure returns (uint256 fundingFee);
    function calculateClosePositionFeePercent(uint256 creationTimestamp) external view returns (uint16);
    function calculateWithdrawFeePercent(uint256 lastDepositTimestamp) external view returns (uint16);

    function depositFeePercent() external returns (uint16);
    function withdrawFeePercent() external returns (uint16);
    function openPositionFeePercent() external returns (uint16);
    function closePositionFeePercent() external returns (uint16);
    function buyingPremiumFeeMaxPercent() external returns (uint16);
}// GPL-3.0
pragma solidity ^0.6.2;


interface IFeesModel {
    function updateSnapshots() external returns (uint256);

    function setCVIOracle(ICVIOracle newOracle) external;
    function setFeesCalculator(IFeesCalculator newCalculator) external;
    function setLatestOracleRoundId(uint80 newOracleRoundId) external;
    function setMaxOracleValuesUsed(uint80 newMaxOracleValuesUsed) external;

    function calculateFundingFees(uint256 startTime, uint256 positionUnitsAmount) external view returns (uint256);
    function calculateFundingFees(uint256 startTime, uint256 endTime, uint256 positionUnitsAmount) external view returns (uint256);
    function calculateFundingFeesAddendum(uint256 positionUnitsAmount) external view returns (uint256);
}// GPL-3.0
pragma solidity ^0.6.2;


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
}// GPL-3.0
pragma solidity ^0.6.2;


interface IPlatform {

    event Deposit(address indexed account, uint256 tokenAmount, uint256 lpTokensAmount, uint256 feeAmount);
    event Withdraw(address indexed account, uint256 tokenAmount, uint256 lpTokensAmount, uint256 feeAmount);
    event OpenPosition(address indexed account, uint256 tokenAmount, uint256 feeAmount, uint256 positionUnitsAmount, uint256 cviValue);
    event ClosePosition(address indexed account, uint256 tokenAmount, uint256 feeAmount, uint256 positionUnitsAmount, uint256 cviValue);
    event LiquidatePosition(address indexed positionAddress, uint256 currentPositionBalance, bool isBalancePositive, uint256 positionUnitsAmount);

    function deposit(uint256 tokenAmount, uint256 minLPTokenAmount) external returns (uint256 lpTokenAmount);
    function withdraw(uint256 tokenAmount, uint256 maxLPTokenBurnAmount) external returns (uint256 burntAmount, uint256 withdrawnAmount);
    function withdrawLPTokens(uint256 lpTokenAmount) external returns (uint256 burntAmount, uint256 withdrawnAmount);

    function openPosition(uint256 tokenAmount, uint16 maxCVI) external returns (uint256 positionUnitsAmount);
    function closePosition(uint256 positionUnitsAmount, uint16 minCVI) external returns (uint256 tokenAmount);

    function liquidatePositions(address[] calldata positionOwners) external returns (uint256 finderFeeAmount);

    function setRevertLockedTransfers(bool revertLockedTransfers) external;

    function setFeesCollector(IFeesCollector newCollector) external;
    function setFeesCalculator(IFeesCalculator newCalculator) external;
    function setFeesModel(IFeesModel newModel) external;
    function setCVIOracle(ICVIOracle newOracle) external;
    function setRewards(IRewards newRewards) external;
    function setLiquidation(ILiquidation newLiquidation) external;

    function setLPLockupPeriod(uint256 newLPLockupPeriod) external;
    function setBuyersLockupPeriod(uint256 newBuyersLockupPeriod) external;

    function setEmergencyWithdrawAllowed(bool newEmergencyWithdrawAllowed) external;

    function getToken() external view returns (IERC20);

    function calculatePositionBalance(address positionAddress) external view returns (uint256 currentPositionBalance, bool isPositive, uint256 positionUnitsAmount);
    function calculatePositionPendingFees(address _positionAddress) external view returns (uint256 pendingFees);

    function totalBalance() external view returns (uint256 balance);
    function totalBalanceWithAddendum() external view returns (uint256 balance);

    function getLiquidableAddresses() external view returns (address[] memory);
}// GPL-3.0
pragma solidity 0.6.12;



contract Platform is IPlatform, Ownable, ERC20 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct Position {
        uint256 positionUnitsAmount;
        uint256 creationTimestamp;
        uint256 pendingFees; // Funding fees calculated for earlier positions before merge (if occured)
        uint256 positionAddressesIndex;    
    }  

    uint256 public constant MAX_FEE_PERCENTAGE = 10000;
    uint256 public constant MAX_PERCENTAGE = 1000000;

    uint256 public constant PRECISION_DECIMALS = 1e10;

    uint256 public constant MAX_CVI_VALUE = 20000;

    uint256 public immutable initialTokenToLPTokenRate;

    IERC20 private token;
    ICVIOracle private cviOracle;
    IRewards private rewards;
    ILiquidation private liquidation;
    IFeesModel private feesModel;
    IFeesCalculator private feesCalculator;
    IFeesCollector private feesCollector;

    uint256 public lpsLockupPeriod = 3 days;
    uint256 public buyersLockupPeriod = 24 hours;

    uint256 public totalPositionUnitsAmount;
    uint256 public totalFundingFeesAmount;

    bool public emergencyWithdrawAllowed = false;

    mapping(address => uint256) public lastDepositTimestamp;
    mapping(address => Position) public positions;

    mapping(address => bool) public revertLockedTransfered;

    address[] private holdersAddresses;

    constructor(IERC20 _token, string memory _lpTokenName, string memory _lpTokenSymbolName, uint256 _initialTokenToLPTokenRate,
        IFeesModel _feesModel,
        IFeesCalculator _feesCalculator,
        ICVIOracle _cviOracle,
        ILiquidation _liquidation) public ERC20(_lpTokenName, _lpTokenSymbolName) {

        token = _token;
        initialTokenToLPTokenRate = _initialTokenToLPTokenRate;
        feesModel = _feesModel;
        feesCalculator = _feesCalculator;
        cviOracle = _cviOracle;
        liquidation = _liquidation;
    }

    function deposit(uint256 _tokenAmount, uint256 _minLPTokenAmount) external override returns (uint256 lpTokenAmount) {
        lpTokenAmount = _deposit(_tokenAmount, _minLPTokenAmount, true);
    }    

    function withdraw(uint256 _tokenAmount, uint256 _maxLPTokenBurnAmount) external override returns (uint256 burntAmount, uint256 withdrawnAmount) {
        (burntAmount, withdrawnAmount) = _withdraw(_tokenAmount, false, _maxLPTokenBurnAmount, true);
    }

    function withdrawLPTokens(uint256 _lpTokensAmount) external override returns (uint256 burntAmount, uint256 withdrawnAmount) {
        require(_lpTokensAmount > 0, "Amount must be positive");
        (burntAmount, withdrawnAmount) = _withdraw(0, true, _lpTokensAmount, true);
    }

    function openPosition(uint256 _tokenAmount, uint16 _maxCVI) external override returns (uint256 positionUnitsAmount) {
        positionUnitsAmount = _openPosition(_tokenAmount, _maxCVI, true);
    }

    function closePosition(uint256 _positionUnitsAmount, uint16 _minCVI) external override returns (uint256 tokenAmount) {
        tokenAmount = _closePosition(_positionUnitsAmount, _minCVI, true);
    }

    function liquidatePositions(address[] calldata _positionOwners) external override returns (uint256 finderFeeAmount) {
        finderFeeAmount = _liquidatePositions(_positionOwners);
    }

    function setCVIOracle(ICVIOracle _newOracle) external override onlyOwner {
        cviOracle = _newOracle;
    }

    function setRewards(IRewards _newRewards) external override onlyOwner {
        rewards = _newRewards;
    }

    function setLiquidation(ILiquidation _newLiquidation) external override onlyOwner {
        liquidation = _newLiquidation;
    }

    function setFeesCollector(IFeesCollector _newCollector) external override onlyOwner {
        feesCollector = _newCollector;
        if (address(_newCollector) != address(0)) {
            token.safeApprove(address(feesCollector), uint256(-1));
        }
    }

    function setFeesModel(IFeesModel _newModel) external override onlyOwner {
        feesModel = _newModel;
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

    function setFeesCalculator(IFeesCalculator _newCalculator) external override onlyOwner {
        feesCalculator = _newCalculator;
    }

    function setEmergencyWithdrawAllowed(bool _newEmergencyWithdrawAllowed) external override onlyOwner {
        emergencyWithdrawAllowed = _newEmergencyWithdrawAllowed;
    }

    function getToken() external view override returns (IERC20) {
        return token;
    }

    function calculatePositionBalance(address _positionAddress) public view override returns (uint256 currentPositionBalance, bool isPositive, uint256 positionUnitsAmount) {
        positionUnitsAmount = positions[_positionAddress].positionUnitsAmount;
        require(positionUnitsAmount > 0, "No position for given address");
        (currentPositionBalance, isPositive) = _calculatePositionBalance(_positionAddress);
    }

    function calculatePositionPendingFees(address _positionAddress) public view override returns (uint256 pendingFees) {
        Position memory position = positions[_positionAddress];
        pendingFees = position.pendingFees.add(feesModel.calculateFundingFees(position.creationTimestamp, position.positionUnitsAmount))
        .add(feesModel.calculateFundingFeesAddendum(position.positionUnitsAmount));
    }

    function totalBalance() public view override returns (uint256 balance) {
        (uint16 cviValue,) = cviOracle.getCVILatestRoundData();
        return token.balanceOf(address(this)).sub(totalPositionUnitsAmount.mul(cviValue).div(MAX_CVI_VALUE)).add(totalFundingFeesAmount);
    }

    function totalBalanceWithAddendum() public view override returns (uint256 balance) {
        return totalBalance().add(feesModel.calculateFundingFeesAddendum(totalPositionUnitsAmount));
    }

    function getLiquidableAddresses() external view override returns (address[] memory) {
        address[] memory addressesToLiquidate = new address[](holdersAddresses.length);

        uint256 liquidationAddressesAmount = 0;
        for (uint256 i = 0; i < holdersAddresses.length; i++) {
            (uint256 currentPositionBalance, bool isBalancePositive) = _calculatePositionBalance(holdersAddresses[i]);

            if (liquidation.isLiquidationCandidate(currentPositionBalance, isBalancePositive, positions[holdersAddresses[i]].positionUnitsAmount)) {
                addressesToLiquidate[liquidationAddressesAmount] = holdersAddresses[i];
                liquidationAddressesAmount = liquidationAddressesAmount.add(1);
            }
        }

        address[] memory addressesToActuallyLiquidate = new address[](liquidationAddressesAmount);
        for (uint256 i = 0; i < liquidationAddressesAmount; i++) {
            addressesToActuallyLiquidate[i] = addressesToLiquidate[i];
        }

        return addressesToActuallyLiquidate;
    }

    function _deposit(uint256 _tokenAmount, uint256 _minLPTokenAmount, bool _transferTokens) internal returns (uint256 lpTokenAmount) {
        require(_tokenAmount > 0, "Tokens amount must be positive");
        lastDepositTimestamp[msg.sender] = block.timestamp;

        updateSnapshots();

        uint256 depositFee = _tokenAmount.mul(uint256(feesCalculator.depositFeePercent())).div(MAX_FEE_PERCENTAGE);

        uint256 tokenAmountToDeposit = _tokenAmount.sub(depositFee);
        uint256 supply = totalSupply();
        uint256 balance = totalBalance();
    
        if (supply > 0 && balance > 0) {
                lpTokenAmount = tokenAmountToDeposit.mul(supply).div(balance);
        } else {
                lpTokenAmount = tokenAmountToDeposit.mul(initialTokenToLPTokenRate);
        }

        emit Deposit(msg.sender, _tokenAmount, lpTokenAmount, depositFee);

        require(lpTokenAmount >= _minLPTokenAmount, "Too few LP tokens");
        require(lpTokenAmount > 0, "Too few tokens");
        _mint(msg.sender, lpTokenAmount);

        if (_transferTokens) {
            token.safeTransferFrom(msg.sender, address(this), _tokenAmount);
        }

        collectProfit(depositFee);
    }

    function _withdraw(uint256 _tokenAmount, bool _shouldBurnMax, uint256 _maxLPTokenBurnAmount, bool _transferTokens) internal returns (uint256 burntAmount, uint256 withdrawnAmount) {
        require(lastDepositTimestamp[msg.sender].add(lpsLockupPeriod) <= block.timestamp, "Funds are locked");

        updateSnapshots();

        if (_shouldBurnMax) {
            burntAmount = _maxLPTokenBurnAmount;
            _tokenAmount = burntAmount.mul(totalBalance()).div(totalSupply());
        } else {
            require(_tokenAmount > 0, "Tokens amount must be positive");

            burntAmount = _tokenAmount.mul(totalSupply()).sub(1).div(totalBalance()).add(1);
            require(burntAmount <= _maxLPTokenBurnAmount, "Too much LP tokens to burn");
        }

        require(burntAmount <= balanceOf(msg.sender), "Not enough LP tokens for account");
        
        uint256 withdrawFee = _tokenAmount.mul(uint256(feesCalculator.withdrawFeePercent())).div(MAX_FEE_PERCENTAGE);
        withdrawnAmount = _tokenAmount.sub(withdrawFee);

        require(emergencyWithdrawAllowed || token.balanceOf(address(this)).sub(totalPositionUnitsAmount) >= withdrawnAmount, "Collateral ratio broken");

        emit Withdraw(msg.sender, _tokenAmount, burntAmount, withdrawFee);
        
        _burn(msg.sender, burntAmount);

        if (_transferTokens) {
            token.safeTransfer(msg.sender, withdrawnAmount);
        }

        collectProfit(withdrawFee);
    }

    function _openPosition(uint256 _tokenAmount, uint16 _maxCVI, bool _transferTokens) internal returns (uint256 positionUnitsAmount) {
        require(_tokenAmount > 0, "Tokens amount must be positive");
        require(_maxCVI > 0 && _maxCVI <= MAX_CVI_VALUE, "Bad max CVI value");

        (uint16 cviValue,) = cviOracle.getCVILatestRoundData();
        require(cviValue <= _maxCVI, "CVI too high");

        updateSnapshots();

        uint256 openPositionFee = _tokenAmount.mul(uint256(feesCalculator.openPositionFeePercent())).div(MAX_FEE_PERCENTAGE);
        uint256 positionUnitsAmountWithoutPremium =  _tokenAmount.sub(openPositionFee).mul(MAX_CVI_VALUE).div(cviValue);
        uint256 minPositionUnitsAmount = positionUnitsAmountWithoutPremium.mul(MAX_FEE_PERCENTAGE.sub(feesCalculator.buyingPremiumFeeMaxPercent())).div(MAX_FEE_PERCENTAGE);

        uint256 collateralRatio = 0;
        if (token.balanceOf(address(this)) > 0) {
            collateralRatio = (totalPositionUnitsAmount.add(minPositionUnitsAmount)).mul(PRECISION_DECIMALS).div(token.balanceOf(address(this)).add(_tokenAmount).sub(openPositionFee));
        }
        uint256 buyingPremiumFee = feesCalculator.calculateBuyingPremiumFee(_tokenAmount, collateralRatio);
        
        uint256 tokenAmountToOpenPosition = _tokenAmount.sub(openPositionFee).sub(buyingPremiumFee);

        positionUnitsAmount = tokenAmountToOpenPosition.mul(MAX_CVI_VALUE).div(cviValue);
        
        totalPositionUnitsAmount = totalPositionUnitsAmount.add(positionUnitsAmount);
        if (positions[msg.sender].positionUnitsAmount > 0) {
            Position storage position = positions[msg.sender];
            position.pendingFees = position.pendingFees.add(feesModel.calculateFundingFees(position.creationTimestamp, 
                block.timestamp, position.positionUnitsAmount));
            position.positionUnitsAmount = position.positionUnitsAmount.add(positionUnitsAmount);
            position.creationTimestamp = block.timestamp;
        } else {
            Position memory newPosition = Position(positionUnitsAmount, block.timestamp, 0, holdersAddresses.length);

            positions[msg.sender] = newPosition;
            holdersAddresses.push(msg.sender);
        }   

        emit OpenPosition(msg.sender, _tokenAmount, openPositionFee.add(buyingPremiumFee), positions[msg.sender].positionUnitsAmount, cviValue);

        if (_transferTokens) {
            token.safeTransferFrom(msg.sender, address(this), _tokenAmount);
        }

        collectProfit(openPositionFee);

        require(totalPositionUnitsAmount <= token.balanceOf(address(this)), "Not enough liquidity");

        if (address(rewards) != address(0)) {
            rewards.reward(msg.sender, positionUnitsAmount);
        }
    }

    function _closePosition(uint256 _positionUnitsAmount, uint16 _minCVI, bool _transferTokens) internal returns (uint256 tokenAmount) {
        require(_positionUnitsAmount > 0, "Position units not positive");
        require(_minCVI > 0 && _minCVI <= MAX_CVI_VALUE, "Bad min CVI value");
        require(positions[msg.sender].positionUnitsAmount >= _positionUnitsAmount, "Not enough opened position units");
        require(block.timestamp.sub(positions[msg.sender].creationTimestamp) >= buyersLockupPeriod, "Position locked");

        (uint16 cviValue,) = cviOracle.getCVILatestRoundData();
        require(cviValue >= _minCVI, "CVI too low");

        updateSnapshots();

        Position storage position = positions[msg.sender];
        uint256 positionBalance = _positionUnitsAmount.mul(cviValue).div(MAX_CVI_VALUE);
        uint256 tokenAmountBeforeFees = positionBalance;
        uint256 fundingFees = feesModel.calculateFundingFees(position.creationTimestamp, block.timestamp, _positionUnitsAmount);
        uint256 realizedPendingFees = position.pendingFees.mul(_positionUnitsAmount).div(position.positionUnitsAmount);

        if (positionBalance <= fundingFees.add(realizedPendingFees)) {
            checkAndLiquidatePosition(msg.sender); // Will always liquidate
            return 0;
        } else {
            positionBalance = positionBalance.sub(fundingFees.add(realizedPendingFees));
        }

        uint256 closePositionFee = positionBalance
            .mul(uint256(feesCalculator.calculateClosePositionFeePercent(position.creationTimestamp)))
            .div(MAX_FEE_PERCENTAGE);

        position.positionUnitsAmount = position.positionUnitsAmount.sub(_positionUnitsAmount);
        totalPositionUnitsAmount = totalPositionUnitsAmount.sub(_positionUnitsAmount);

        if (position.positionUnitsAmount > 0) {
            position.pendingFees = position.pendingFees.sub(realizedPendingFees);
        } else {
            removePosition(msg.sender);
        }

        tokenAmount = positionBalance.sub(closePositionFee);

        emit ClosePosition(msg.sender, tokenAmountBeforeFees, closePositionFee.add(realizedPendingFees).add(fundingFees), positions[msg.sender].positionUnitsAmount, cviValue);

        collectProfit(closePositionFee);
        
        if (_transferTokens) {
            token.safeTransfer(msg.sender, tokenAmount);
        }
    }

    function _liquidatePositions(address[] calldata _positionOwners) internal returns (uint256 finderFeeAmount) {
        updateSnapshots();
        bool liquidationOccured = false;
        for ( uint256 i = 0; i < _positionOwners.length; i++) {
            uint256 positionUnitsAmount = positions[_positionOwners[i]].positionUnitsAmount;
            (bool wasLiquidated, uint256 liquidatedAmount, bool isPositive) = checkAndLiquidatePosition(_positionOwners[i]);

            if (wasLiquidated) {
                liquidationOccured = true;
                finderFeeAmount = finderFeeAmount.add(liquidation.getLiquidationReward(liquidatedAmount, isPositive, positionUnitsAmount));
            }
        }

        require(liquidationOccured, "No reported position was found to be liquidatable");
        token.safeTransfer(msg.sender, finderFeeAmount);
    }

    function _beforeTokenTransfer(address from, address to, uint256) internal override {
        if (lastDepositTimestamp[from].add(lpsLockupPeriod) > block.timestamp && 
            lastDepositTimestamp[from] > lastDepositTimestamp[to]) {
                require(!revertLockedTransfered[to], "Recipient refuses locked tokens");
                lastDepositTimestamp[to] = lastDepositTimestamp[from];
        }
    }

    function updateSnapshots() private {
        uint256 singleUnitFundingFee = feesModel.updateSnapshots();
        totalFundingFeesAmount = totalFundingFeesAmount.add(singleUnitFundingFee.mul(totalPositionUnitsAmount).div(PRECISION_DECIMALS));
    }

    function collectProfit(uint256 amount) private {
        if (address(feesCollector) != address(0)) {
            feesCollector.sendProfit(amount, token);
        }
    }

    function checkAndLiquidatePosition(address _positionAddress) private returns (bool wasLiquidated, uint256 liquidatedAmount, bool isPositive) {
        (uint256 currentPositionBalance, bool isBalancePositive) = _calculatePositionBalance(_positionAddress);
        isPositive = isBalancePositive;
        liquidatedAmount = currentPositionBalance;

        if (liquidation.isLiquidationCandidate(currentPositionBalance, isBalancePositive, positions[_positionAddress].positionUnitsAmount)) {
            liquidatePosition(_positionAddress, currentPositionBalance, isBalancePositive);
            wasLiquidated = true;
        }
    }

    function liquidatePosition(address _positionAddress, uint256 liquidatedAmount, bool isPositive) private {
        Position memory position = positions[_positionAddress];
        totalPositionUnitsAmount = totalPositionUnitsAmount.sub(position.positionUnitsAmount);
        totalFundingFeesAmount = totalFundingFeesAmount.sub(position.pendingFees);
        removePosition(_positionAddress);
        emit LiquidatePosition(_positionAddress, liquidatedAmount, isPositive, position.positionUnitsAmount);
    }

    function removePosition(address _positionAddress) private {
        uint256 positionIndex = positions[_positionAddress].positionAddressesIndex;
        if (holdersAddresses.length > 1) {
            holdersAddresses[positionIndex] = holdersAddresses[holdersAddresses.length.sub(1)];
            positions[holdersAddresses[positionIndex]].positionAddressesIndex = positionIndex;
        }
        holdersAddresses.pop();
        delete positions[_positionAddress];
    }

    function _calculatePositionBalance(address _positionAddress) private view returns (uint256 currentPositionBalance, bool isPositive) {
        Position memory position = positions[_positionAddress];

        (uint16 cviValue,) = cviOracle.getCVILatestRoundData();

        uint256 pendingFeesAmount = position.pendingFees.add(feesModel.calculateFundingFees(position.creationTimestamp, position.positionUnitsAmount))
        .add(feesModel.calculateFundingFeesAddendum(position.positionUnitsAmount));
        
        uint256 positionBalanceWithoutFees = position.positionUnitsAmount.mul(cviValue).div(MAX_CVI_VALUE);

        if (positionBalanceWithoutFees >= pendingFeesAmount) {
            currentPositionBalance = positionBalanceWithoutFees.sub(pendingFeesAmount);
            isPositive = true;
        } else {
            currentPositionBalance = pendingFeesAmount.sub(positionBalanceWithoutFees);
        }
    }
}