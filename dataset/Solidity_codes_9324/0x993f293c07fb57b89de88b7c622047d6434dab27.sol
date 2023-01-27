pragma solidity 0.6.6;


interface IBurnGasHelper {

    function getAmountGasTokensToBurn(uint256 gasTotalConsumption)
        external
        view
        returns (uint256 numGas, address gasToken);

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
}pragma solidity 0.6.6;



interface IERC20Ext is IERC20 {

    function decimals() external view returns (uint8 digits);

}pragma solidity 0.6.6;



contract Utils {

    IERC20Ext internal constant ETH_TOKEN_ADDRESS = IERC20Ext(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    IERC20Ext internal constant USDT_TOKEN_ADDRESS = IERC20Ext(
        0xdAC17F958D2ee523a2206206994597C13D831ec7
    );
    IERC20Ext internal constant DAI_TOKEN_ADDRESS = IERC20Ext(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    IERC20Ext internal constant USDC_TOKEN_ADDRESS = IERC20Ext(
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    );
    IERC20Ext internal constant WBTC_TOKEN_ADDRESS = IERC20Ext(
        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
    );
    IERC20Ext internal constant KNC_TOKEN_ADDRESS = IERC20Ext(
        0xdd974D5C2e2928deA5F71b9825b8b646686BD200
    );
    uint256 public constant BPS = 10000; // Basic Price Steps. 1 step = 0.01%
    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens
    uint256 internal constant MAX_RATE = (PRECISION * 10**7); // up to 10M tokens per eth
    uint256 internal constant MAX_DECIMALS = 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 internal constant MAX_ALLOWANCE = uint256(-1); // token.approve inifinite

    mapping(IERC20Ext => uint256) internal decimals;

    function getSetDecimals(IERC20Ext token) internal returns (uint256 tokenDecimals) {

        tokenDecimals = getDecimalsConstant(token);
        if (tokenDecimals > 0) return tokenDecimals;

        tokenDecimals = decimals[token];
        if (tokenDecimals == 0) {
            tokenDecimals = token.decimals();
            decimals[token] = tokenDecimals;
        }
    }

    function getBalance(IERC20Ext token, address user) internal view returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) {
            return user.balance;
        } else {
            return token.balanceOf(user);
        }
    }

    function getDecimals(IERC20Ext token) internal view returns (uint256 tokenDecimals) {

        tokenDecimals = getDecimalsConstant(token);
        if (tokenDecimals > 0) return tokenDecimals;

        tokenDecimals = decimals[token];
        return (tokenDecimals > 0) ? tokenDecimals : token.decimals();
    }

    function calcDestAmount(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 rate
    ) internal view returns (uint256) {

        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 destAmount,
        uint256 rate
    ) internal view returns (uint256) {

        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcDstQty(
        uint256 srcQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {

        require(srcQty <= MAX_QTY, "srcQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(
        uint256 dstQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {

        require(dstQty <= MAX_QTY, "dstQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        uint256 numerator;
        uint256 denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {

        require(srcAmount <= MAX_QTY, "srcAmount > MAX_QTY");
        require(destAmount <= MAX_QTY, "destAmount > MAX_QTY");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return ((destAmount * PRECISION) / ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return ((destAmount * PRECISION * (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    function getDecimalsConstant(IERC20Ext token) internal pure returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) {
            return ETH_DECIMALS;
        } else if (token == USDT_TOKEN_ADDRESS) {
            return 6;
        } else if (token == DAI_TOKEN_ADDRESS) {
            return 18;
        } else if (token == USDC_TOKEN_ADDRESS) {
            return 6;
        } else if (token == WBTC_TOKEN_ADDRESS) {
            return 8;
        } else if (token == KNC_TOKEN_ADDRESS) {
            return 18;
        } else {
            return 0;
        }
    }

    function minOf(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? y : x;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

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
}pragma solidity 0.6.6;

contract PermissionGroups {

    uint256 internal constant MAX_GROUP_SIZE = 50;

    address public admin;
    address public pendingAdmin;
    mapping(address => bool) internal operators;
    mapping(address => bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;

    event AdminClaimed(address newAdmin, address previousAdmin);

    event TransferAdminPending(address pendingAdmin);

    event OperatorAdded(address newOperator, bool isAdd);

    event AlerterAdded(address newAlerter, bool isAdd);

    constructor(address _admin) public {
        require(_admin != address(0), "admin 0");
        admin = _admin;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "only admin");
        _;
    }

    modifier onlyOperator() {

        require(operators[msg.sender], "only operator");
        _;
    }

    modifier onlyAlerter() {

        require(alerters[msg.sender], "only alerter");
        _;
    }

    function getOperators() external view returns (address[] memory) {

        return operatorsGroup;
    }

    function getAlerters() external view returns (address[] memory) {

        return alertersGroup;
    }

    function transferAdmin(address newAdmin) public onlyAdmin {

        require(newAdmin != address(0), "new admin 0");
        emit TransferAdminPending(newAdmin);
        pendingAdmin = newAdmin;
    }

    function transferAdminQuickly(address newAdmin) public onlyAdmin {

        require(newAdmin != address(0), "admin 0");
        emit TransferAdminPending(newAdmin);
        emit AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    function claimAdmin() public {

        require(pendingAdmin == msg.sender, "not pending");
        emit AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    function addAlerter(address newAlerter) public onlyAdmin {

        require(!alerters[newAlerter], "alerter exists"); // prevent duplicates.
        require(alertersGroup.length < MAX_GROUP_SIZE, "max alerters");

        emit AlerterAdded(newAlerter, true);
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    function removeAlerter(address alerter) public onlyAdmin {

        require(alerters[alerter], "not alerter");
        alerters[alerter] = false;

        for (uint256 i = 0; i < alertersGroup.length; ++i) {
            if (alertersGroup[i] == alerter) {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.pop();
                emit AlerterAdded(alerter, false);
                break;
            }
        }
    }

    function addOperator(address newOperator) public onlyAdmin {

        require(!operators[newOperator], "operator exists"); // prevent duplicates.
        require(operatorsGroup.length < MAX_GROUP_SIZE, "max operators");

        emit OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function removeOperator(address operator) public onlyAdmin {

        require(operators[operator], "not operator");
        operators[operator] = false;

        for (uint256 i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.pop();
                emit OperatorAdded(operator, false);
                break;
            }
        }
    }
}pragma solidity 0.6.6;


contract Withdrawable is PermissionGroups {

    using SafeERC20 for IERC20Ext;

    event TokenWithdraw(IERC20Ext token, uint256 amount, address sendTo);
    event EtherWithdraw(uint256 amount, address sendTo);

    constructor(address _admin) public PermissionGroups(_admin) {}

    function withdrawToken(
        IERC20Ext token,
        uint256 amount,
        address sendTo
    ) external onlyAdmin {

        token.safeTransfer(sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }

    function withdrawEther(uint256 amount, address payable sendTo) external onlyAdmin {

        (bool success, ) = sendTo.call{value: amount}("");
        require(success, "withdraw failed");
        emit EtherWithdraw(amount, sendTo);
    }
}pragma solidity 0.6.6;



contract BurnGasHelper is IBurnGasHelper, Utils, Withdrawable {



    address public gasTokenAddr;

    constructor(
        address _admin,
        address _gasToken
    ) public Withdrawable(_admin) {
        gasTokenAddr = _gasToken;
    }

    function updateGasToken(address _gasToken) external onlyAdmin {

        gasTokenAddr = _gasToken;
    }

    function getAmountGasTokensToBurn(
        uint256 gasTotalConsumption
    ) external override view returns(uint numGas, address gasToken) {


        gasToken = gasTokenAddr;
        uint256 gas = gasleft();
        uint256 safeNumTokens = 0;
        if (gas >= 27710) {
            safeNumTokens = (gas - 27710) / 7020; // (1148 + 5722 + 150);
        }

        uint256 gasSpent = 21000 + 16 * gasTotalConsumption;
        numGas = (gasSpent + 14154) / 41947;

        numGas = minOf(safeNumTokens, numGas);
    }
}pragma solidity 0.6.6;


interface ILendingPoolV1{

    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external payable;

    function core() external view returns (address);

    function getReserves() external view returns (address[] memory);

    function getReserveConfigurationData(address _reserve)
        external
        view
        returns (
            uint256 ltv,
            uint256 liquidationThreshold,
            uint256 liquidationBonus,
            address rateStrategyAddress,
            bool usageAsCollateralEnabled,
            bool borrowingEnabled,
            bool stableBorrowRateEnabled,
            bool isActive
        );

    function getUserAccountData(address _user)
        external
        view
        returns (
            uint256 totalLiquidityETH,
            uint256 totalCollateralETH,
            uint256 totalBorrowsETH,
            uint256 totalFeesETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );


    function getUserReserveData(address _reserve, address _user)
        external
        view
        returns (
            uint256 currentATokenBalance,
            uint256 currentBorrowBalance,
            uint256 principalBorrowBalance,
            uint256 borrowRateMode,
            uint256 borrowRate,
            uint256 liquidityRate,
            uint256 originationFee,
            uint256 variableBorrowIndex,
            uint256 lastUpdateTimestamp,
            bool usageAsCollateralEnabled
        );

}pragma solidity 0.6.6;

library DataTypes {

  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address interestRateStrategyAddress;
    uint8 id;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}
}// agpl-3.0
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

interface IProtocolDataProvider {

  struct TokenData {
    string symbol;
    address tokenAddress;
  }

  function getAllReservesTokens() external view returns (TokenData[] memory);

  function getAllATokens() external view returns (TokenData[] memory);

  function getReserveConfigurationData(address asset)
    external view returns(
        uint256 decimals,
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus,
        uint256 reserveFactor,
        bool usageAsCollateralEnabled,
        bool borrowingEnabled,
        bool stableBorrowRateEnabled,
        bool isActive,
        bool isFrozen
    );

  function getReserveData(address asset)
    external view returns (
        uint256 availableLiquidity,
        uint256 totalStableDebt,
        uint256 totalVariableDebt,
        uint256 liquidityRate,
        uint256 variableBorrowRate,
        uint256 stableBorrowRate,
        uint256 averageStableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex,
        uint40 lastUpdateTimestamp
    );

  function getUserReserveData(address asset, address user)
    external view returns (
        uint256 currentATokenBalance,
        uint256 currentStableDebt,
        uint256 currentVariableDebt,
        uint256 principalStableDebt,
        uint256 scaledVariableDebt,
        uint256 stableBorrowRate,
        uint256 liquidityRate,
        uint40 stableRateLastUpdated,
        bool usageAsCollateralEnabled
    );

  function getReserveTokensAddresses(address asset)
    external view returns (
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress
    );

  function calculateUserGlobalData(address _user)
    external
    view
    returns (
        uint256 totalLiquidityBalanceETH,
        uint256 totalCollateralBalanceETH,
        uint256 totalBorrowBalanceETH,
        uint256 totalFeesETH,
        uint256 currentLtv,
        uint256 currentLiquidationThreshold,
        uint256 healthFactor,
        bool healthFactorBelowThreshold
    );

}pragma solidity 0.6.6;


interface ILendingPoolV2 {

  function getConfiguration(address asset)
    external
    view
    returns (DataTypes.ReserveConfigurationMap memory);


  function getReserveData(address asset)
    external
    view
    returns (DataTypes.ReserveData memory);


  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );


  function getUserConfiguration(address user)
    external
    view
    returns (DataTypes.UserConfigurationMap memory);


  function getReservesList() external view returns (address[] memory);

  function getAddressesProvider() external view returns (IProtocolDataProvider);

}pragma solidity 0.6.6;


interface IFetchAaveDataWrapper {

    struct ReserveConfigData {
        uint256 ltv;
        uint256 liquidationThreshold;
        uint256 liquidationBonus;
        bool usageAsCollateralEnabled;
        bool borrowingEnabled;
        bool stableBorrowRateEnabled;
        bool isActive;
        address aTokenAddress;
    }

    struct ReserveData {
        uint256 availableLiquidity;
        uint256 totalBorrowsStable;
        uint256 totalBorrowsVariable;
        uint256 liquidityRate;
        uint256 variableBorrowRate;
        uint256 stableBorrowRate;
        uint256 averageStableBorrowRate;
        uint256 totalLiquidity;
        uint256 utilizationRate;
    }

    struct UserAccountData {
        uint256 totalLiquidityETH; // only v1
        uint256 totalCollateralETH;
        uint256 totalBorrowsETH;
        uint256 totalFeesETH; // only v1
        uint256 availableBorrowsETH;
        uint256 currentLiquidationThreshold;
        uint256 ltv;
        uint256 healthFactor;
    }

    struct UserReserveData {
        uint256 currentATokenBalance;
        uint256 liquidityRate;
        uint256 poolShareInPrecision;
        bool usageAsCollateralEnabled;
        uint256 currentBorrowBalance;
        uint256 principalBorrowBalance;
        uint256 borrowRateMode;
        uint256 borrowRate;
        uint256 originationFee;
        uint256 currentStableDebt;
        uint256 currentVariableDebt;
        uint256 principalStableDebt;
        uint256 scaledVariableDebt;
        uint256 stableBorrowRate;
    }

    function getReserves(address pool, bool isV1) external view returns (address[] memory);

    function getReservesConfigurationData(address pool, bool isV1, address[] calldata _reserves)
        external
        view
        returns (
            ReserveConfigData[] memory configsData
        );


    function getReservesData(address pool, bool isV1, address[] calldata _reserves)
        external
        view
        returns (
            ReserveData[] memory reservesData
        );


    function getUserAccountsData(address pool, bool isV1, address[] calldata _users)
        external
        view
        returns (
            UserAccountData[] memory accountsData
        );


    function getUserReservesData(address pool, bool isV1, address[] calldata _reserves, address _user)
        external
        view
        returns (
            UserReserveData[] memory userReservesData
        );


    function getUsersReserveData(address pool, bool isV1, address _reserve, address[] calldata _users)
        external
        view
        returns (
            UserReserveData[] memory userReservesData
        );

}pragma solidity 0.6.6;


interface ILendingPoolCore {

    function getReserveATokenAddress(address _reserve) external view returns (address);

    function getReserveTotalLiquidity(address _reserve) external view returns (uint256);

    function getReserveAvailableLiquidity(address _reserve) external view returns (uint256);

    function getReserveCurrentLiquidityRate(address _reserve) external view returns (uint256);

    function getReserveUtilizationRate(address _reserve) external view returns (uint256);


    function getReserveTotalBorrowsStable(address _reserve) external view returns (uint256);

    function getReserveTotalBorrowsVariable(address _reserve) external view returns (uint256);

    function getReserveCurrentVariableBorrowRate(address _reserve) external view returns (uint256);

    function getReserveCurrentStableBorrowRate(address _reserve) external view returns (uint256);

    function getReserveCurrentAverageStableBorrowRate(address _reserve) external view returns (uint256);

}pragma solidity 0.6.6;



contract FetchAaveDataWrapper is Withdrawable, IFetchAaveDataWrapper {

    uint256 internal constant PRECISION = 10**18;
    uint256 internal constant RATE_PRECISION = 10**27;

    constructor(address _admin) public Withdrawable(_admin) {}

    function getReserves(address pool, bool isV1)
        external
        view
        override
        returns (address[] memory reserves)
    {

        if (isV1) {
            return ILendingPoolV1(pool).getReserves();
        }
        return ILendingPoolV2(pool).getReservesList();
    }

    function getReservesConfigurationData(
        address pool,
        bool isV1,
        address[] calldata _reserves
    ) external view override returns (ReserveConfigData[] memory configsData) {

        configsData = new ReserveConfigData[](_reserves.length);
        for (uint256 i = 0; i < _reserves.length; i++) {
            if (isV1) {
                (
                    configsData[i].ltv,
                    configsData[i].liquidationThreshold,
                    configsData[i].liquidationBonus, // rate strategy address
                    ,
                    configsData[i].usageAsCollateralEnabled,
                    configsData[i].borrowingEnabled,
                    configsData[i].stableBorrowRateEnabled,
                    configsData[i].isActive
                ) = ILendingPoolV1(pool).getReserveConfigurationData(_reserves[i]);
                configsData[i].aTokenAddress = ILendingPoolCore(ILendingPoolV1(pool).core())
                    .getReserveATokenAddress(_reserves[i]);
            } else {
                IProtocolDataProvider provider = IProtocolDataProvider(pool);
                (
                    ,
                    configsData[i].ltv,
                    configsData[i].liquidationThreshold,
                    configsData[i].liquidationBonus, // reserve factor
                    ,
                    configsData[i].usageAsCollateralEnabled,
                    configsData[i].borrowingEnabled,
                    configsData[i].stableBorrowRateEnabled,
                    configsData[i].isActive,

                ) = provider.getReserveConfigurationData(_reserves[i]);
                (configsData[i].aTokenAddress, , ) = provider.getReserveTokensAddresses(
                    _reserves[i]
                );
            }
        }
    }

    function getReservesData(
        address pool,
        bool isV1,
        address[] calldata _reserves
    ) external view override returns (ReserveData[] memory reservesData) {

        reservesData = new ReserveData[](_reserves.length);
        if (isV1) {
            ILendingPoolCore core = ILendingPoolCore(ILendingPoolV1(pool).core());
            for (uint256 i = 0; i < _reserves.length; i++) {
                reservesData[i].totalLiquidity = core.getReserveTotalLiquidity(_reserves[i]);
                reservesData[i].availableLiquidity = core.getReserveAvailableLiquidity(
                    _reserves[i]
                );
                reservesData[i].utilizationRate = core.getReserveUtilizationRate(_reserves[i]);
                reservesData[i].liquidityRate = core.getReserveCurrentLiquidityRate(_reserves[i]);

                reservesData[i].totalBorrowsStable = core.getReserveTotalBorrowsStable(
                    _reserves[i]
                );
                reservesData[i].totalBorrowsVariable = core.getReserveTotalBorrowsVariable(
                    _reserves[i]
                );

                reservesData[i].variableBorrowRate = core.getReserveCurrentVariableBorrowRate(
                    _reserves[i]
                );
                reservesData[i].stableBorrowRate = core.getReserveCurrentStableBorrowRate(
                    _reserves[i]
                );
                reservesData[i].averageStableBorrowRate = core
                    .getReserveCurrentAverageStableBorrowRate(_reserves[i]);
            }
        } else {
            IProtocolDataProvider provider = IProtocolDataProvider(pool);
            for (uint256 i = 0; i < _reserves.length; i++) {
                (
                    reservesData[i].availableLiquidity,
                    reservesData[i].totalBorrowsStable,
                    reservesData[i].totalBorrowsVariable,
                    reservesData[i].liquidityRate,
                    reservesData[i].variableBorrowRate,
                    reservesData[i].stableBorrowRate,
                    reservesData[i].averageStableBorrowRate,
                    ,
                    ,

                ) = provider.getReserveData(_reserves[i]);
                (address aTokenAddress, , ) = provider.getReserveTokensAddresses(_reserves[i]);
                reservesData[i].availableLiquidity = IERC20Ext(_reserves[i]).balanceOf(
                    aTokenAddress
                );

                reservesData[i].totalLiquidity =
                    reservesData[i].availableLiquidity +
                    reservesData[i].totalBorrowsStable +
                    reservesData[i].totalBorrowsVariable;
                if (reservesData[i].totalLiquidity > 0) {
                    reservesData[i].utilizationRate =
                        RATE_PRECISION -
                        (reservesData[i].availableLiquidity * RATE_PRECISION) /
                        reservesData[i].totalLiquidity;
                }
            }
        }
    }

    function getUserAccountsData(
        address pool,
        bool isV1,
        address[] calldata _users
    ) external view override returns (UserAccountData[] memory accountsData) {

        accountsData = new UserAccountData[](_users.length);

        for (uint256 i = 0; i < _users.length; i++) {
            accountsData[i] = getSingleUserAccountData(pool, isV1, _users[i]);
        }
    }

    function getUserReservesData(
        address pool,
        bool isV1,
        address[] calldata _reserves,
        address _user
    ) external view override returns (UserReserveData[] memory userReservesData) {

        userReservesData = new UserReserveData[](_reserves.length);
        for (uint256 i = 0; i < _reserves.length; i++) {
            if (isV1) {
                userReservesData[i] = getSingleUserReserveDataV1(
                    ILendingPoolV1(pool),
                    _reserves[i],
                    _user
                );
            } else {
                userReservesData[i] = getSingleUserReserveDataV2(
                    IProtocolDataProvider(pool),
                    _reserves[i],
                    _user
                );
            }
        }
    }

    function getUsersReserveData(
        address pool,
        bool isV1,
        address _reserve,
        address[] calldata _users
    ) external view override returns (UserReserveData[] memory userReservesData) {

        userReservesData = new UserReserveData[](_users.length);
        for (uint256 i = 0; i < _users.length; i++) {
            if (isV1) {
                userReservesData[i] = getSingleUserReserveDataV1(
                    ILendingPoolV1(pool),
                    _reserve,
                    _users[i]
                );
            } else {
                userReservesData[i] = getSingleUserReserveDataV2(
                    IProtocolDataProvider(pool),
                    _reserve,
                    _users[i]
                );
            }
        }
    }

    function getSingleUserReserveDataV1(
        ILendingPoolV1 pool,
        address _reserve,
        address _user
    ) public view returns (UserReserveData memory data) {

        (
            data.currentATokenBalance,
            data.currentBorrowBalance,
            data.principalBorrowBalance,
            data.borrowRateMode,
            data.borrowRate,
            data.liquidityRate,
            data.originationFee,
            ,
            ,
            data.usageAsCollateralEnabled
        ) = pool.getUserReserveData(_reserve, _user);
        IERC20Ext aToken =
            IERC20Ext(ILendingPoolCore(pool.core()).getReserveATokenAddress(_reserve));
        uint256 totalSupply = aToken.totalSupply();
        if (totalSupply > 0) {
            data.poolShareInPrecision = aToken.balanceOf(_user) * RATE_PRECISION / totalSupply;
        }
    }

    function getSingleUserReserveDataV2(
        IProtocolDataProvider provider,
        address _reserve,
        address _user
    ) public view returns (UserReserveData memory data) {

        {
            (
                data.currentATokenBalance,
                data.currentStableDebt,
                data.currentVariableDebt,
                data.principalStableDebt,
                data.scaledVariableDebt,
                data.stableBorrowRate,
                data.liquidityRate,
                ,
                data.usageAsCollateralEnabled
            ) = provider.getUserReserveData(_reserve, _user);
        }
        {
            (address aTokenAddress, , ) = provider.getReserveTokensAddresses(_reserve);
            uint256 totalSupply = IERC20Ext(aTokenAddress).totalSupply();
            if (totalSupply > 0) {
                data.poolShareInPrecision =
                    IERC20Ext(aTokenAddress).balanceOf(_user) * RATE_PRECISION /
                    totalSupply;
            }
        }
    }

    function getSingleUserAccountData(
        address pool,
        bool isV1,
        address _user
    ) public view returns (UserAccountData memory data) {

        if (isV1) {
            (
                data.totalLiquidityETH,
                data.totalCollateralETH,
                data.totalBorrowsETH,
                data.totalFeesETH,
                data.availableBorrowsETH,
                data.currentLiquidationThreshold,
                data.ltv,
                data.healthFactor
            ) = ILendingPoolV1(pool).getUserAccountData(_user);
            return data;
        }
        (
            data.totalCollateralETH,
            data.totalBorrowsETH,
            data.availableBorrowsETH,
            data.currentLiquidationThreshold,
            data.ltv,
            data.healthFactor
        ) = ILendingPoolV2(pool).getUserAccountData(_user);
    }
}pragma solidity 0.6.6;



interface IKyberProxy {


    function tradeWithHintAndFee(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external payable returns (uint256 destAmount);


    function getExpectedRateAfterFee(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external view returns (uint256 expectedRate);

}pragma solidity 0.6.6;

interface IGasToken {

    function mint(uint256 value) external;

    function freeUpTo(uint256 value) external returns (uint256 freed);


    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);


    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool success);

    function transferFrom(address from, address to, uint256 value) external returns (bool success);

    function approve(address spender, uint256 value) external returns (bool success);

}pragma solidity 0.6.6;



interface IAaveLendingPoolV2 {

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;


    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);


    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;


    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);


    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;


    function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);

}pragma solidity 0.6.6;


interface IAaveLendingPoolV1 {

    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable;


    function borrow(
        address _reserve,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode
    ) external;


    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral) external;


    function repay(
        address _reserve,
        uint256 _amount,
        address payable _onBehalfOf
    ) external payable;


    function core() external view returns (address);


    function getUserReserveData(address _reserve, address _user)
        external
        view
        returns (
            uint256 currentATokenBalance,
            uint256 currentBorrowBalance,
            uint256 principalBorrowBalance,
            uint256 borrowRateMode,
            uint256 borrowRate,
            uint256 liquidityRate,
            uint256 originationFee,
            uint256 variableBorrowIndex,
            uint256 lastUpdateTimestamp,
            bool usageAsCollateralEnabled
        );

}

interface IAToken {

    function redeem(uint256 _amount) external;

}pragma solidity 0.6.6;



interface IWeth is IERC20Ext {

    function deposit() external payable;

    function withdraw(uint256 wad) external;

}pragma solidity 0.6.6;


interface ICompErc20 {

    function mint(uint mintAmount) external returns (uint);

    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function borrow(uint borrowAmount) external returns (uint);

    function repayBorrow(uint repayAmount) external returns (uint);

    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);


    function transfer(address dst, uint amount) external returns (bool);

    function transferFrom(address src, address dst, uint amount) external returns (bool);

    function approve(address spender, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function balanceOfUnderlying(address owner) external returns (uint);

    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);

    function totalBorrowsCurrent() external returns (uint);

    function borrowBalanceCurrent(address account) external returns (uint);

    function borrowBalanceStored(address account) external view returns (uint);

    function exchangeRateCurrent() external returns (uint);

    function exchangeRateStored() external view returns (uint);

    function underlying() external view returns (address);

}

interface ICompEth {

    function mint() external payable;

    function repayBorrowBehalf(address borrower) external payable;

    function repayBorrow() external payable;

}pragma solidity 0.6.6;



interface ISmartWalletLending {


    event ClaimedComp(
        address[] holders,
        ICompErc20[] cTokens,
        bool borrowers,
        bool suppliers
    );

    enum LendingPlatform { AAVE_V1, AAVE_V2, COMPOUND }

    struct UserReserveData {
        uint256 currentATokenBalance;
        uint256 liquidityRate;
        uint256 poolShareInPrecision;
        bool usageAsCollateralEnabled;
        uint256 currentBorrowBalance;
        uint256 principalBorrowBalance;
        uint256 borrowRateMode;
        uint256 borrowRate;
        uint256 originationFee;
        uint256 currentStableDebt;
        uint256 currentVariableDebt;
        uint256 principalStableDebt;
        uint256 scaledVariableDebt;
        uint256 stableBorrowRate;
    }

    function updateAaveLendingPoolData(
        IAaveLendingPoolV2 poolV2,
        IProtocolDataProvider provider,
        IAaveLendingPoolV1 poolV1,
        address lendingPoolCoreV1,
        uint16 referalCode,
        IWeth weth,
        IERC20Ext[] calldata tokens
    ) external;


    function updateCompoundData(
        address _comptroller,
        address _cEth,
        address[] calldata _cTokens
    ) external;


    function depositTo(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount
    ) external;


    function borrowFrom(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 borrowAmount,
        uint256 interestRateMode
    ) external;


    function withdrawFrom(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn
    ) external returns (uint256 returnedAmount);


    function repayBorrowTo(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount,
        uint256 payAmount,
        uint256 rateMode // only for aave v2
    ) external;

    
    function claimComp(
        address[] calldata holders,
        ICompErc20[] calldata cTokens,
        bool borrowers,
        bool suppliers
    ) external;


    function storeAndRetrieveUserDebtCurrent(
        LendingPlatform platform,
        address _reserve,
        address _user
    ) external returns (uint256 debt);


    function getLendingToken(LendingPlatform platform, IERC20Ext token) external view returns(address);


    function getUserDebtStored(LendingPlatform platform, address reserve, address user)
        external
        view
        returns (uint256 debt);

}// MIT

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
}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}pragma solidity 0.6.6;



contract SmartWalletSwapStorage is Utils, Withdrawable, ReentrancyGuard {


    uint256 constant internal MAX_AMOUNT = uint256(-1);

    mapping (address => mapping(IERC20Ext => uint256)) public platformWalletFees;
    IKyberProxy public kyberProxy;
    mapping(IUniswapV2Router02 => bool) public isRouterSupported;

    IBurnGasHelper public burnGasHelper;
    mapping (address => bool) public supportedPlatformWallets;

    struct TradeInput {
        uint256 srcAmount;
        uint256 minData; // min rate if Kyber, min return if Uni-pools
        address payable recipient;
        uint256 platformFeeBps;
        address payable platformWallet;
        bytes hint;
    }

    ISmartWalletLending public lendingImpl;

    bytes32 internal constant IMPLEMENTATION = 0x6a7efb0627ddb0e69b773958c7c9c3c9c3dc049819cdf56a8ee84c3074b2a5d7;

    constructor(address _admin) public Withdrawable(_admin) {}
}pragma solidity 0.6.6;



contract SmartWalletSwapProxy is SmartWalletSwapStorage {

    using Address for address;

    event ImplementationUpdated(address indexed implementation);

    constructor(
        address _admin,
        address _implementation,
        IKyberProxy _proxy,
        IUniswapV2Router02[] memory _routers
    ) public SmartWalletSwapStorage(_admin) {
        _setImplementation(_implementation);
        kyberProxy = _proxy;
        for (uint256 i = 0; i < _routers.length; i++) {
            isRouterSupported[_routers[i]] = true;
        }
    }

    function updateNewImplementation(address _implementation) external onlyAdmin {

        _setImplementation(_implementation);
        emit ImplementationUpdated(_implementation);
    }

    receive() external payable {}

    fallback() external payable {
        (bool success, ) = implementation().delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())
            switch success
                case 0 {
                    revert(free_mem_ptr, returndatasize())
                }
                default {
                    return(free_mem_ptr, returndatasize())
                }
        }
    }

    function implementation() public view returns (address impl) {

        bytes32 slot = IMPLEMENTATION;
        assembly {
            impl := sload(slot)
        }
    }

    function _setImplementation(address _implementation) internal {

        require(_implementation.isContract(), "non-contract address");

        bytes32 slot = IMPLEMENTATION;
        assembly {
            sstore(slot, _implementation)
        }
    }
}pragma solidity 0.6.6;



interface IComptroller {

    function getAllMarkets() external view returns (ICompErc20[] memory);

    function getCompAddress() external view returns (address);

    function claimComp(
        address[] calldata holders,
        ICompErc20[] calldata cTokens,
        bool borrowers,
        bool suppliers
    ) external;

    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);

}pragma solidity 0.6.6;



contract SmartWalletLending is ISmartWalletLending, Utils, Withdrawable {

    using SafeERC20 for IERC20Ext;
    using SafeMath for uint256;

    struct AaveLendingPoolData {
        IAaveLendingPoolV2 lendingPoolV2;
        IProtocolDataProvider provider;
        mapping(IERC20Ext => address) aTokensV2;
        IWeth weth;
        IAaveLendingPoolV1 lendingPoolV1;
        mapping(IERC20Ext => address) aTokensV1;
        address lendingPoolCoreV1;
        uint16 referalCode;
    }

    AaveLendingPoolData public aaveLendingPool;

    struct CompoundData {
        address comptroller;
        mapping(IERC20Ext => address) cTokens;
    }

    CompoundData public compoundData;

    address public swapImplementation;

    event UpdatedSwapImplementation(address indexed _oldSwapImpl, address indexed _newSwapImpl);
    event UpdatedAaveLendingPool(
        IAaveLendingPoolV2 poolV2,
        IProtocolDataProvider provider,
        IAaveLendingPoolV1 poolV1,
        address lendingPoolCoreV1,
        uint16 referalCode,
        IWeth weth,
        IERC20Ext[] tokens,
        address[] aTokensV1,
        address[] aTokensV2
    );
    event UpdatedCompoudData(
        address comptroller,
        address cEth,
        address[] cTokens,
        IERC20Ext[] underlyingTokens
    );

    modifier onlySwapImpl() {

        require(msg.sender == swapImplementation, "only swap impl");
        _;
    }

    constructor(address _admin) public Withdrawable(_admin) {}

    receive() external payable {}

    function updateSwapImplementation(address _swapImpl) external onlyAdmin {

        require(_swapImpl != address(0), "invalid swap impl");
        emit UpdatedSwapImplementation(swapImplementation, _swapImpl);
        swapImplementation = _swapImpl;
    }

    function updateAaveLendingPoolData(
        IAaveLendingPoolV2 poolV2,
        IProtocolDataProvider provider,
        IAaveLendingPoolV1 poolV1,
        address lendingPoolCoreV1,
        uint16 referalCode,
        IWeth weth,
        IERC20Ext[] calldata tokens
    ) external override onlyAdmin {

        require(weth != IWeth(0), "invalid weth");
        aaveLendingPool.lendingPoolV2 = poolV2;
        aaveLendingPool.provider = provider;
        aaveLendingPool.lendingPoolV1 = poolV1;
        aaveLendingPool.lendingPoolCoreV1 = lendingPoolCoreV1;
        aaveLendingPool.referalCode = referalCode;
        aaveLendingPool.weth = weth;

        address[] memory aTokensV1 = new address[](tokens.length);
        address[] memory aTokensV2 = new address[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            if (poolV1 != IAaveLendingPoolV1(0)) {
                try
                    ILendingPoolCore(poolV1.core()).getReserveATokenAddress(address(tokens[i]))
                returns (address aToken) {
                    aTokensV1[i] = aToken;
                } catch {}
                aaveLendingPool.aTokensV1[tokens[i]] = aTokensV1[i];
            }
            if (poolV2 != IAaveLendingPoolV2(0)) {
                address token =
                    tokens[i] == ETH_TOKEN_ADDRESS ? address(weth) : address(tokens[i]);
                try poolV2.getReserveData(token) returns (DataTypes.ReserveData memory data) {
                    aTokensV2[i] = data.aTokenAddress;
                } catch {}
                aaveLendingPool.aTokensV2[tokens[i]] = aTokensV2[i];
            }
        }

        if (lendingPoolCoreV1 != address(0)) {
            for (uint256 j = 0; j < aTokensV1.length; j++) {
                safeApproveAllowance(lendingPoolCoreV1, tokens[j]);
            }
        }
        if (poolV2 != IAaveLendingPoolV2(0)) {
            for (uint256 j = 0; j < aTokensV1.length; j++) {
                safeApproveAllowance(address(poolV2), tokens[j]);
            }
        }

        emit UpdatedAaveLendingPool(
            poolV2,
            provider,
            poolV1,
            lendingPoolCoreV1,
            referalCode,
            weth,
            tokens,
            aTokensV1,
            aTokensV2
        );
    }

    function updateCompoundData(
        address _comptroller,
        address _cEth,
        address[] calldata _cTokens
    ) external override onlyAdmin {
        require(_comptroller != address(0), "invalid _comptroller");
        require(_cEth != address(0), "invalid cEth");

        compoundData.comptroller = _comptroller;
        compoundData.cTokens[ETH_TOKEN_ADDRESS] = _cEth;

        IERC20Ext[] memory tokens;
        if (_cTokens.length > 0) {
            tokens = new IERC20Ext[](_cTokens.length);
            for (uint256 i = 0; i < _cTokens.length; i++) {
                require(_cTokens[i] != address(0), "invalid cToken");
                tokens[i] = IERC20Ext(ICompErc20(_cTokens[i]).underlying());
                require(tokens[i] != IERC20Ext(0), "invalid underlying token");
                compoundData.cTokens[tokens[i]] = _cTokens[i];

                safeApproveAllowance(_cTokens[i], tokens[i]);
            }
            emit UpdatedCompoudData(_comptroller, _cEth, _cTokens, tokens);
        } else {
            ICompErc20[] memory markets = IComptroller(_comptroller).getAllMarkets();
            tokens = new IERC20Ext[](markets.length);
            address[] memory cTokens = new address[](markets.length);
            for (uint256 i = 0; i < markets.length; i++) {
                if (address(markets[i]) == _cEth) {
                    tokens[i] = ETH_TOKEN_ADDRESS;
                    cTokens[i] = _cEth;
                    continue;
                }
                require(markets[i] != ICompErc20(0), "invalid cToken");
                tokens[i] = IERC20Ext(markets[i].underlying());
                require(tokens[i] != IERC20Ext(0), "invalid underlying token");
                cTokens[i] = address(markets[i]);
                compoundData.cTokens[tokens[i]] = cTokens[i];

                safeApproveAllowance(_cTokens[i], tokens[i]);
            }
            emit UpdatedCompoudData(_comptroller, _cEth, cTokens, tokens);
        }
    }

    function depositTo(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount
    ) external override onlySwapImpl {
        require(getBalance(token, address(this)) >= amount, "low balance");
        if (platform == LendingPlatform.AAVE_V1) {
            IAaveLendingPoolV1 poolV1 = aaveLendingPool.lendingPoolV1;
            IERC20Ext aToken = IERC20Ext(aaveLendingPool.aTokensV1[token]);
            require(aToken != IERC20Ext(0), "aToken not found");

            uint256 aTokenBalanceBefore = aToken.balanceOf(address(this));
            poolV1.deposit{value: token == ETH_TOKEN_ADDRESS ? amount : 0}(
                address(token),
                amount,
                aaveLendingPool.referalCode
            );
            uint256 aTokenBalanceAfter = aToken.balanceOf(address(this));
            aToken.safeTransfer(onBehalfOf, aTokenBalanceAfter.sub(aTokenBalanceBefore));
        } else if (platform == LendingPlatform.AAVE_V2) {
            if (token == ETH_TOKEN_ADDRESS) {
                IWeth weth = aaveLendingPool.weth;
                IAaveLendingPoolV2 pool = aaveLendingPool.lendingPoolV2;
                weth.deposit{value: amount}();
                pool.deposit(address(weth), amount, onBehalfOf, aaveLendingPool.referalCode);
            } else {
                IAaveLendingPoolV2 pool = aaveLendingPool.lendingPoolV2;
                pool.deposit(address(token), amount, onBehalfOf, aaveLendingPool.referalCode);
            }
        } else {
            address cToken = compoundData.cTokens[token];
            require(cToken != address(0), "token is not supported by Compound");
            uint256 cTokenBalanceBefore = IERC20Ext(cToken).balanceOf(address(this));
            if (token == ETH_TOKEN_ADDRESS) {
                ICompEth(cToken).mint{value: amount}();
            } else {
                require(ICompErc20(cToken).mint(amount) == 0, "can not mint cToken");
            }
            uint256 cTokenBalanceAfter = IERC20Ext(cToken).balanceOf(address(this));
            IERC20Ext(cToken).safeTransfer(
                onBehalfOf,
                cTokenBalanceAfter.sub(cTokenBalanceBefore)
            );
        }
    }

    function borrowFrom(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 borrowAmount,
        uint256 interestRateMode
    ) external override onlySwapImpl {
        require(platform != LendingPlatform.AAVE_V1, "Aave V1 not supported");

        if (platform == LendingPlatform.AAVE_V2) {
            IAaveLendingPoolV2 poolV2 = aaveLendingPool.lendingPoolV2;
            poolV2.borrow(
                address(token),
                borrowAmount,
                interestRateMode,
                aaveLendingPool.referalCode,
                onBehalfOf
            );
        }
    }

    function withdrawFrom(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn
    ) external override onlySwapImpl returns (uint256 returnedAmount) {
        address lendingToken = getLendingToken(platform, token);

        uint256 tokenBalanceBefore;
        uint256 tokenBalanceAfter;
        if (platform == LendingPlatform.AAVE_V1) {
            tokenBalanceBefore = getBalance(token, address(this));
            IAToken(lendingToken).redeem(amount);
            tokenBalanceAfter = getBalance(token, address(this));
            returnedAmount = tokenBalanceAfter.sub(tokenBalanceBefore);
            require(returnedAmount >= minReturn, "low returned amount");
            transferToken(onBehalfOf, token, returnedAmount);
        } else if (platform == LendingPlatform.AAVE_V2) {
            if (token == ETH_TOKEN_ADDRESS) {
                address weth = address(aaveLendingPool.weth);
                tokenBalanceBefore = IERC20Ext(weth).balanceOf(address(this));
                returnedAmount = aaveLendingPool.lendingPoolV2.withdraw(
                    weth,
                    amount,
                    address(this)
                );
                tokenBalanceAfter = IERC20Ext(weth).balanceOf(address(this));
                require(
                    tokenBalanceAfter.sub(tokenBalanceBefore) >= returnedAmount,
                    "invalid return"
                );
                require(returnedAmount >= minReturn, "low returned amount");
                IWeth(weth).withdraw(returnedAmount);
                (bool success, ) = onBehalfOf.call{value: returnedAmount}("");
                require(success, "transfer eth to sender failed");
            } else {
                tokenBalanceBefore = getBalance(token, onBehalfOf);
                returnedAmount = aaveLendingPool.lendingPoolV2.withdraw(
                    address(token),
                    amount,
                    onBehalfOf
                );
                tokenBalanceAfter = getBalance(token, onBehalfOf);
                require(
                    tokenBalanceAfter.sub(tokenBalanceBefore) >= returnedAmount,
                    "invalid return"
                );
                require(returnedAmount >= minReturn, "low returned amount");
            }
        } else {
            tokenBalanceBefore = getBalance(token, address(this));
            require(ICompErc20(lendingToken).redeem(amount) == 0, "unable to redeem");
            tokenBalanceAfter = getBalance(token, address(this));
            returnedAmount = tokenBalanceAfter.sub(tokenBalanceBefore);
            require(returnedAmount >= minReturn, "low returned amount");
            transferToken(onBehalfOf, token, returnedAmount);
        }
    }

    function repayBorrowTo(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount,
        uint256 payAmount,
        uint256 rateMode // only for aave v2
    ) external override onlySwapImpl {
        require(amount >= payAmount, "invalid pay amount");
        require(getBalance(token, address(this)) >= amount, "bad token balance");

        if (amount > payAmount) {
            transferToken(payable(onBehalfOf), token, amount - payAmount);
        }
        if (platform == LendingPlatform.AAVE_V1) {
            IAaveLendingPoolV1 poolV1 = aaveLendingPool.lendingPoolV1;

            poolV1.repay{value: token == ETH_TOKEN_ADDRESS ? payAmount : 0}(
                address(token),
                payAmount,
                onBehalfOf
            );
        } else if (platform == LendingPlatform.AAVE_V2) {
            IAaveLendingPoolV2 poolV2 = aaveLendingPool.lendingPoolV2;
            if (token == ETH_TOKEN_ADDRESS) {
                IWeth weth = aaveLendingPool.weth;
                weth.deposit{value: payAmount}();
                require(
                    poolV2.repay(address(weth), payAmount, rateMode, onBehalfOf) == payAmount,
                    "wrong paid amount"
                );
            } else {
                require(
                    poolV2.repay(address(token), payAmount, rateMode, onBehalfOf) == payAmount,
                    "wrong paid amount"
                );
            }
        } else {
            address cToken = compoundData.cTokens[token];
            require(cToken != address(0), "token is not supported by Compound");
            if (token == ETH_TOKEN_ADDRESS) {
                ICompEth(cToken).repayBorrowBehalf{value: payAmount}(onBehalfOf);
            } else {
                require(
                    ICompErc20(cToken).repayBorrowBehalf(onBehalfOf, payAmount) == 0,
                    "compound repay error"
                );
            }
        }
    }

    function claimComp(
        address[] calldata holders,
        ICompErc20[] calldata cTokens,
        bool borrowers,
        bool suppliers
    ) external override onlySwapImpl {
        require(holders.length > 0, "no holders");
        IComptroller comptroller = IComptroller(compoundData.comptroller);
        if (cTokens.length == 0) {
            ICompErc20[] memory markets = comptroller.getAllMarkets();
            comptroller.claimComp(holders, markets, borrowers, suppliers);
        } else {
            comptroller.claimComp(holders, cTokens, borrowers, suppliers);
        }
        emit ClaimedComp(holders, cTokens, borrowers, suppliers);
    }

    function getLendingToken(LendingPlatform platform, IERC20Ext token)
        public
        view
        override
        returns (address)
    {
        if (platform == LendingPlatform.AAVE_V1) {
            return aaveLendingPool.aTokensV1[token];
        } else if (platform == LendingPlatform.AAVE_V2) {
            return aaveLendingPool.aTokensV2[token];
        }
        return compoundData.cTokens[token];
    }

    function storeAndRetrieveUserDebtCurrent(
        LendingPlatform platform,
        address _reserve,
        address _user
    ) external override returns (uint256 debt) {
        if (platform == LendingPlatform.AAVE_V1 || platform == LendingPlatform.AAVE_V2) {
            debt = getUserDebtStored(platform, _reserve, _user);
            return debt;
        }
        ICompErc20 cToken = ICompErc20(compoundData.cTokens[IERC20Ext(_reserve)]);
        debt = cToken.borrowBalanceCurrent(_user);
    }

    function getUserDebtStored(
        LendingPlatform platform,
        address _reserve,
        address _user
    ) public view override returns (uint256 debt) {
        if (platform == LendingPlatform.AAVE_V1) {
            uint256 originationFee;
            IAaveLendingPoolV1 pool = aaveLendingPool.lendingPoolV1;
            (, debt, , , , , originationFee, , , ) = pool.getUserReserveData(_reserve, _user);
            debt = debt.add(originationFee);
        } else if (platform == LendingPlatform.AAVE_V2) {
            IProtocolDataProvider provider = aaveLendingPool.provider;
            (, uint256 stableDebt, uint256 variableDebt, , , , , , ) =
                provider.getUserReserveData(_reserve, _user);
            debt = stableDebt > 0 ? stableDebt : variableDebt;
        } else {
            ICompErc20 cToken = ICompErc20(compoundData.cTokens[IERC20Ext(_reserve)]);
            debt = cToken.borrowBalanceStored(_user);
        }
    }

    function safeApproveAllowance(address spender, IERC20Ext token) internal {
        if (token != ETH_TOKEN_ADDRESS && token.allowance(address(this), spender) == 0) {
            token.safeApprove(spender, MAX_ALLOWANCE);
        }
    }

    function transferToken(
        address payable recipient,
        IERC20Ext token,
        uint256 amount
    ) internal {
        if (token == ETH_TOKEN_ADDRESS) {
            (bool success, ) = recipient.call{value: amount}("");
            require(success, "failed to transfer eth");
        } else {
            token.safeTransfer(recipient, amount);
        }
    }
}pragma solidity 0.6.6;



interface ISmartWalletSwapImplementation {
    event KyberTrade(
        address indexed trader,
        IERC20Ext indexed src,
        IERC20Ext indexed dest,
        uint256 srcAmount,
        uint256 destAmount,
        address recipient,
        uint256 platformFeeBps,
        address platformWallet,
        bytes hint,
        bool useGasToken,
        uint numGasBurns
    );

    event UniswapTrade(
        address indexed trader,
        address indexed router,
        address[] tradePath,
        uint256 srcAmount,
        uint256 destAmount,
        address recipient,
        uint256 platformFeeBps,
        address platformWallet,
        bool feeInSrc,
        bool useGasToken,
        uint256 numGasBurns
    );

    event KyberTradeAndDeposit(
        address indexed trader,
        ISmartWalletLending.LendingPlatform indexed platform,
        IERC20Ext src,
        IERC20Ext indexed dest,
        uint256 srcAmount,
        uint256 destAmount,
        uint256 platformFeeBps,
        address platformWallet,
        bytes hint,
        bool useGasToken,
        uint numGasBurns
    );

    event UniswapTradeAndDeposit(
        address indexed trader,
        ISmartWalletLending.LendingPlatform indexed platform,
        IUniswapV2Router02 indexed router,
        address[] tradePath,
        uint256 srcAmount,
        uint256 destAmount,
        uint256 platformFeeBps,
        address platformWallet,
        bool useGasToken,
        uint256 numGasBurns
    );

    event BorrowFromLending(
        ISmartWalletLending.LendingPlatform indexed platform,
        IERC20Ext token,
        uint256 amountBorrowed,
        uint256 interestRateMode,
        bool useGasToken,
        uint256 numGasBurns
    );

    event WithdrawFromLending(
        ISmartWalletLending.LendingPlatform indexed platform,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn,
        uint256 actualReturnAmount,
        bool useGasToken,
        uint256 numGasBurns
    );

    event KyberTradeAndRepay(
        address indexed trader,
        ISmartWalletLending.LendingPlatform indexed platform,
        IERC20Ext src,
        IERC20Ext indexed dest,
        uint256 srcAmount,
        uint256 destAmount,
        uint256 payAmount,
        uint256 feeAndRateMode,
        address platformWallet,
        bytes hint,
        bool useGasToken,
        uint numGasBurns
    );

    event UniswapTradeAndRepay(
        address indexed trader,
        ISmartWalletLending.LendingPlatform indexed platform,
        IUniswapV2Router02 indexed router,
        address[] tradePath,
        uint256 srcAmount,
        uint256 destAmount,
        uint256 payAmount,
        uint256 feeAndRateMode,
        address platformWallet,
        bool useGasToken,
        uint256 numGasBurns
    );

    function getExpectedReturnKyber(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external view returns (
        uint256 destAmount,
        uint256 expectedRate
    );

    function getExpectedReturnUniswap(
        IUniswapV2Router02 router,
        uint256 srcAmount,
        address[] calldata tradePath,
        uint256 platformFeeBps
    ) external view returns (
        uint256 destAmount,
        uint256 expectedRate
    );

    function swapKyber(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 minConversionRate,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function swapUniswap(
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] calldata tradePath,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bool feeInSrc,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function swapKyberAndDeposit(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 minConversionRate,
        uint256 platformFeeBps,
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function swapUniswapAndDeposit(
        ISmartWalletLending.LendingPlatform platform,
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] calldata tradePath,
        uint256 platformFeeBps,
        address payable platformWallet,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function withdrawFromLendingPlatform(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn,
        bool useGasToken
    ) external returns (uint256 returnedAmount);

    function swapKyberAndRepay(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 payAmount,
        uint256 feeAndRateMode, // in case aave v2, fee: feeAndRateMode % BPS, rateMode: feeAndRateMode / BPS
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function swapUniswapAndRepay(
        ISmartWalletLending.LendingPlatform platform,
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 payAmount,
        address[] calldata tradePath,
        uint256 feeAndRateMode, // in case aave v2, fee: feeAndRateMode % BPS, rateMode: feeAndRateMode / BPS
        address payable platformWallet,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function claimComp(
        address[] calldata holders,
        ICompErc20[] calldata cTokens,
        bool borrowers,
        bool suppliers,
        bool useGasToken
    ) external;

    function claimPlatformFees(
        address[] calldata platformWallets,
        IERC20Ext[] calldata tokens
    ) external;
}pragma solidity 0.6.6;



contract SmartWalletSwapImplementation is SmartWalletSwapStorage, ISmartWalletSwapImplementation {
    using SafeERC20 for IERC20Ext;
    using SafeMath for uint256;

    event UpdatedSupportedPlatformWallets(address[] wallets, bool isSupported);
    event UpdatedBurnGasHelper(IBurnGasHelper indexed gasHelper);
    event UpdatedLendingImplementation(ISmartWalletLending impl);
    event ApprovedAllowances(IERC20Ext[] tokens, address[] spenders, bool isReset);
    event ClaimedPlatformFees(address[] wallets, IERC20Ext[] tokens, address claimer);

    constructor(address _admin) public SmartWalletSwapStorage(_admin) {}

    receive() external payable {}

    function updateBurnGasHelper(IBurnGasHelper _burnGasHelper) external onlyAdmin {
        if (burnGasHelper != _burnGasHelper) {
            burnGasHelper = _burnGasHelper;
            emit UpdatedBurnGasHelper(_burnGasHelper);
        }
    }

    function updateLendingImplementation(ISmartWalletLending newImpl) external onlyAdmin {
        require(newImpl != ISmartWalletLending(0), "invalid lending impl");
        lendingImpl = newImpl;
        emit UpdatedLendingImplementation(newImpl);
    }

    function updateSupportedPlatformWallets(address[] calldata wallets, bool isSupported)
        external
        onlyAdmin
    {
        for (uint256 i = 0; i < wallets.length; i++) {
            supportedPlatformWallets[wallets[i]] = isSupported;
        }
        emit UpdatedSupportedPlatformWallets(wallets, isSupported);
    }

    function claimPlatformFees(address[] calldata platformWallets, IERC20Ext[] calldata tokens)
        external
        override
        nonReentrant
    {
        for (uint256 i = 0; i < platformWallets.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 fee = platformWalletFees[platformWallets[i]][tokens[j]];
                if (fee > 1) {
                    platformWalletFees[platformWallets[i]][tokens[j]] = 1;
                    transferToken(payable(platformWallets[i]), tokens[j], fee - 1);
                }
            }
        }
        emit ClaimedPlatformFees(platformWallets, tokens, msg.sender);
    }

    function approveAllowances(
        IERC20Ext[] calldata tokens,
        address[] calldata spenders,
        bool isReset
    ) external onlyAdmin {
        uint256 allowance = isReset ? 0 : MAX_ALLOWANCE;
        for (uint256 i = 0; i < tokens.length; i++) {
            for (uint256 j = 0; j < spenders.length; j++) {
                tokens[i].safeApprove(spenders[j], allowance);
            }
            getSetDecimals(tokens[i]);
        }

        emit ApprovedAllowances(tokens, spenders, isReset);
    }


    function swapKyber(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 minConversionRate,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        uint256 gasBefore = useGasToken ? gasleft() : 0;
        destAmount = doKyberTrade(
            src,
            dest,
            srcAmount,
            minConversionRate,
            recipient,
            platformFeeBps,
            platformWallet,
            hint
        );
        uint256 numGasBurns = 0;
        if (useGasToken) {
            numGasBurns = burnGasTokensAfter(gasBefore);
        }
        emit KyberTrade(
            msg.sender,
            src,
            dest,
            srcAmount,
            destAmount,
            recipient,
            platformFeeBps,
            platformWallet,
            hint,
            useGasToken,
            numGasBurns
        );
    }

    function swapUniswap(
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] calldata tradePath,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bool feeInSrc,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        uint256 numGasBurns;
        {
            uint256 gasBefore = useGasToken ? gasleft() : 0;
            destAmount = swapUniswapInternal(
                router,
                srcAmount,
                minDestAmount,
                tradePath,
                recipient,
                platformFeeBps,
                platformWallet,
                feeInSrc
            );
            if (useGasToken) {
                numGasBurns = burnGasTokensAfter(gasBefore);
            }
        }

        emit UniswapTrade(
            msg.sender,
            address(router),
            tradePath,
            srcAmount,
            destAmount,
            recipient,
            platformFeeBps,
            platformWallet,
            feeInSrc,
            useGasToken,
            numGasBurns
        );
    }


    function swapKyberAndDeposit(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 minConversionRate,
        uint256 platformFeeBps,
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        require(lendingImpl != ISmartWalletLending(0));
        uint256 gasBefore = useGasToken ? gasleft() : 0;
        if (src == dest) {
            destAmount = safeForwardTokenAndCollectFee(
                src,
                msg.sender,
                payable(address(lendingImpl)),
                srcAmount,
                platformFeeBps,
                platformWallet
            );
        } else {
            destAmount = doKyberTrade(
                src,
                dest,
                srcAmount,
                minConversionRate,
                payable(address(lendingImpl)),
                platformFeeBps,
                platformWallet,
                hint
            );
        }

        lendingImpl.depositTo(platform, msg.sender, dest, destAmount);

        uint256 numGasBurns = 0;
        if (useGasToken) {
            numGasBurns = burnGasTokensAfter(gasBefore);
        }

        emit KyberTradeAndDeposit(
            msg.sender,
            platform,
            src,
            dest,
            srcAmount,
            destAmount,
            platformFeeBps,
            platformWallet,
            hint,
            useGasToken,
            numGasBurns
        );
    }

    function swapUniswapAndDeposit(
        ISmartWalletLending.LendingPlatform platform,
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] calldata tradePath,
        uint256 platformFeeBps,
        address payable platformWallet,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        require(lendingImpl != ISmartWalletLending(0));
        uint256 gasBefore = useGasToken ? gasleft() : 0;
        {
            IERC20Ext dest = IERC20Ext(tradePath[tradePath.length - 1]);
            if (tradePath.length == 1) {
                destAmount = safeForwardTokenAndCollectFee(
                    dest,
                    msg.sender,
                    payable(address(lendingImpl)),
                    srcAmount,
                    platformFeeBps,
                    platformWallet
                );
            } else {
                destAmount = swapUniswapInternal(
                    router,
                    srcAmount,
                    minDestAmount,
                    tradePath,
                    payable(address(lendingImpl)),
                    platformFeeBps,
                    platformWallet,
                    false
                );
            }

            lendingImpl.depositTo(platform, msg.sender, dest, destAmount);
        }

        uint256 numGasBurns = 0;
        if (useGasToken) {
            numGasBurns = burnGasTokensAfter(gasBefore);
        }

        emit UniswapTradeAndDeposit(
            msg.sender,
            platform,
            router,
            tradePath,
            srcAmount,
            destAmount,
            platformFeeBps,
            platformWallet,
            useGasToken,
            numGasBurns
        );
    }

    function withdrawFromLendingPlatform(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn,
        bool useGasToken
    ) external override nonReentrant returns (uint256 returnedAmount) {
        require(lendingImpl != ISmartWalletLending(0));
        uint256 gasBefore = useGasToken ? gasleft() : 0;
        IERC20Ext lendingToken = IERC20Ext(lendingImpl.getLendingToken(platform, token));
        require(lendingToken != IERC20Ext(0), "unsupported token");
        uint256 tokenBalanceBefore = lendingToken.balanceOf(address(lendingImpl));
        lendingToken.safeTransferFrom(msg.sender, address(lendingImpl), amount);
        uint256 tokenBalanceAfter = lendingToken.balanceOf(address(lendingImpl));

        returnedAmount = lendingImpl.withdrawFrom(
            platform,
            msg.sender,
            token,
            tokenBalanceAfter.sub(tokenBalanceBefore),
            minReturn
        );

        uint256 numGasBurns;
        if (useGasToken) {
            numGasBurns = burnGasTokensAfter(gasBefore);
        }
        emit WithdrawFromLending(
            platform,
            token,
            amount,
            minReturn,
            returnedAmount,
            useGasToken,
            numGasBurns
        );
    }

    function swapKyberAndRepay(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 payAmount,
        uint256 feeAndRateMode,
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        uint256 numGasBurns;
        {
            require(lendingImpl != ISmartWalletLending(0));
            uint256 gasBefore = useGasToken ? gasleft() : 0;

            {
                payAmount = checkUserDebt(platform, address(dest), payAmount);
                if (src == dest) {
                    if (src == ETH_TOKEN_ADDRESS) {
                        require(msg.value == srcAmount, "invalid msg value");
                        transferToken(payable(address(lendingImpl)), src, srcAmount);
                    } else {
                        destAmount = srcAmount > payAmount ? payAmount : srcAmount;
                        src.safeTransferFrom(msg.sender, address(lendingImpl), destAmount);
                    }
                } else {
                    payAmount = checkUserDebt(platform, address(dest), payAmount);

                    uint256 minRate =
                        calcRateFromQty(srcAmount, payAmount, src.decimals(), dest.decimals());

                    destAmount = doKyberTrade(
                        src,
                        dest,
                        srcAmount,
                        minRate,
                        payable(address(lendingImpl)),
                        feeAndRateMode % BPS,
                        platformWallet,
                        hint
                    );
                }
            }

            lendingImpl.repayBorrowTo(
                platform,
                msg.sender,
                dest,
                destAmount,
                payAmount,
                feeAndRateMode / BPS
            );

            if (useGasToken) {
                numGasBurns = burnGasTokensAfter(gasBefore);
            }
        }

        emit KyberTradeAndRepay(
            msg.sender,
            platform,
            src,
            dest,
            srcAmount,
            destAmount,
            payAmount,
            feeAndRateMode,
            platformWallet,
            hint,
            useGasToken,
            numGasBurns
        );
    }

    function swapUniswapAndRepay(
        ISmartWalletLending.LendingPlatform platform,
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 payAmount,
        address[] calldata tradePath,
        uint256 feeAndRateMode,
        address payable platformWallet,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        uint256 numGasBurns;
        {
            require(lendingImpl != ISmartWalletLending(0));
            uint256 gasBefore = useGasToken ? gasleft() : 0;
            IERC20Ext dest = IERC20Ext(tradePath[tradePath.length - 1]);

            payAmount = checkUserDebt(platform, address(dest), payAmount);
            if (tradePath.length == 1) {
                if (dest == ETH_TOKEN_ADDRESS) {
                    require(msg.value == srcAmount, "invalid msg value");
                    transferToken(payable(address(lendingImpl)), dest, srcAmount);
                } else {
                    destAmount = srcAmount > payAmount ? payAmount : srcAmount;
                    dest.safeTransferFrom(msg.sender, address(lendingImpl), destAmount);
                }
            } else {
                destAmount = swapUniswapInternal(
                    router,
                    srcAmount,
                    payAmount,
                    tradePath,
                    payable(address(lendingImpl)),
                    feeAndRateMode % BPS,
                    platformWallet,
                    false
                );
            }

            lendingImpl.repayBorrowTo(
                platform,
                msg.sender,
                dest,
                destAmount,
                payAmount,
                feeAndRateMode / BPS
            );

            if (useGasToken) {
                numGasBurns = burnGasTokensAfter(gasBefore);
            }
        }

        emit UniswapTradeAndRepay(
            msg.sender,
            platform,
            router,
            tradePath,
            srcAmount,
            destAmount,
            payAmount,
            feeAndRateMode,
            platformWallet,
            useGasToken,
            numGasBurns
        );
    }

    function claimComp(
        address[] calldata holders,
        ICompErc20[] calldata cTokens,
        bool borrowers,
        bool suppliers,
        bool useGasToken
    ) external override nonReentrant {
        uint256 gasBefore = useGasToken ? gasleft() : 0;
        lendingImpl.claimComp(holders, cTokens, borrowers, suppliers);
        if (useGasToken) {
            burnGasTokensAfter(gasBefore);
        }
    }

    function getExpectedReturnKyber(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 platformFee,
        bytes calldata hint
    ) external view override returns (uint256 destAmount, uint256 expectedRate) {
        try kyberProxy.getExpectedRateAfterFee(src, dest, srcAmount, platformFee, hint) returns (
            uint256 rate
        ) {
            expectedRate = rate;
        } catch {
            expectedRate = 0;
        }
        destAmount = calcDestAmount(src, dest, srcAmount, expectedRate);
    }

    function getExpectedReturnUniswap(
        IUniswapV2Router02 router,
        uint256 srcAmount,
        address[] calldata tradePath,
        uint256 platformFee
    ) external view override returns (uint256 destAmount, uint256 expectedRate) {
        if (platformFee >= BPS) return (0, 0); // platform fee is too high
        if (!isRouterSupported[router]) return (0, 0); // router is not supported
        uint256 srcAmountAfterFee = (srcAmount * (BPS - platformFee)) / BPS;
        if (srcAmountAfterFee == 0) return (0, 0);
        try router.getAmountsOut(srcAmountAfterFee, tradePath) returns (uint256[] memory amounts) {
            destAmount = amounts[tradePath.length - 1];
        } catch {
            destAmount = 0;
        }
        expectedRate = calcRateFromQty(
            srcAmountAfterFee,
            destAmount,
            getDecimals(IERC20Ext(tradePath[0])),
            getDecimals(IERC20Ext(tradePath[tradePath.length - 1]))
        );
    }

    function checkUserDebt(
        ISmartWalletLending.LendingPlatform platform,
        address token,
        uint256 amount
    ) internal returns (uint256) {
        uint256 debt = lendingImpl.storeAndRetrieveUserDebtCurrent(platform, token, msg.sender);

        if (debt >= amount) {
            return amount;
        }

        return debt;
    }

    function doKyberTrade(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 minConversionRate,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bytes memory hint
    ) internal virtual returns (uint256 destAmount) {
        uint256 actualSrcAmount =
            validateAndPrepareSourceAmount(address(kyberProxy), src, srcAmount, platformWallet);
        uint256 callValue = src == ETH_TOKEN_ADDRESS ? actualSrcAmount : 0;
        destAmount = kyberProxy.tradeWithHintAndFee{value: callValue}(
            src,
            actualSrcAmount,
            dest,
            recipient,
            MAX_AMOUNT,
            minConversionRate,
            platformWallet,
            platformFeeBps,
            hint
        );
    }

    function swapUniswapInternal(
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] memory tradePath,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bool feeInSrc
    ) internal returns (uint256 destAmount) {
        TradeInput memory input =
            TradeInput({
                srcAmount: srcAmount,
                minData: minDestAmount,
                recipient: recipient,
                platformFeeBps: platformFeeBps,
                platformWallet: platformWallet,
                hint: ""
            });

        require(isRouterSupported[router], "unsupported router");
        require(platformFeeBps < BPS, "high platform fee");

        IERC20Ext src = IERC20Ext(tradePath[0]);

        input.srcAmount = validateAndPrepareSourceAmount(
            address(router),
            src,
            srcAmount,
            platformWallet
        );

        destAmount = doUniswapTrade(router, src, tradePath, input, feeInSrc);
    }

    function doUniswapTrade(
        IUniswapV2Router02 router,
        IERC20Ext src,
        address[] memory tradePath,
        TradeInput memory input,
        bool feeInSrc
    ) internal virtual returns (uint256 destAmount) {
        uint256 tradeLen = tradePath.length;
        IERC20Ext actualDest = IERC20Ext(tradePath[tradeLen - 1]);
        {
            if (tradePath[0] == address(ETH_TOKEN_ADDRESS)) {
                tradePath[0] = router.WETH();
            }
            if (tradePath[tradeLen - 1] == address(ETH_TOKEN_ADDRESS)) {
                tradePath[tradeLen - 1] = router.WETH();
            }
        }

        uint256 srcAmountFee;
        uint256 srcAmountAfterFee;
        uint256 destBalanceBefore;
        address recipient;

        if (feeInSrc) {
            srcAmountFee = input.srcAmount.mul(input.platformFeeBps).div(BPS);
            srcAmountAfterFee = input.srcAmount.sub(srcAmountFee);
            recipient = input.recipient;
        } else {
            srcAmountAfterFee = input.srcAmount;
            destBalanceBefore = getBalance(actualDest, address(this));
            recipient = address(this);
        }

        uint256[] memory amounts;
        if (src == ETH_TOKEN_ADDRESS) {
            amounts = router.swapExactETHForTokens{value: srcAmountAfterFee}(
                input.minData,
                tradePath,
                recipient,
                MAX_AMOUNT
            );
        } else {
            if (actualDest == ETH_TOKEN_ADDRESS) {
                amounts = router.swapExactTokensForETH(
                    srcAmountAfterFee,
                    input.minData,
                    tradePath,
                    recipient,
                    MAX_AMOUNT
                );
            } else {
                amounts = router.swapExactTokensForTokens(
                    srcAmountAfterFee,
                    input.minData,
                    tradePath,
                    recipient,
                    MAX_AMOUNT
                );
            }
        }

        if (!feeInSrc) {
            uint256 destBalanceAfter = getBalance(actualDest, address(this));
            destAmount = destBalanceAfter.sub(destBalanceBefore);
            uint256 destAmountFee = destAmount.mul(input.platformFeeBps).div(BPS);
            addFeeToPlatform(input.platformWallet, actualDest, destAmountFee);
            destAmount = destAmount.sub(destAmountFee);
            transferToken(input.recipient, actualDest, destAmount);
        } else {
            destAmount = amounts[amounts.length - 1];
            addFeeToPlatform(input.platformWallet, src, srcAmountFee);
        }
    }

    function validateAndPrepareSourceAmount(
        address protocol,
        IERC20Ext src,
        uint256 srcAmount,
        address platformWallet
    ) internal virtual returns (uint256 actualSrcAmount) {
        require(supportedPlatformWallets[platformWallet], "unsupported platform wallet");
        if (src == ETH_TOKEN_ADDRESS) {
            require(msg.value == srcAmount, "wrong msg value");
            actualSrcAmount = srcAmount;
        } else {
            require(msg.value == 0, "bad msg value");
            uint256 balanceBefore = src.balanceOf(address(this));
            src.safeTransferFrom(msg.sender, address(this), srcAmount);
            uint256 balanceAfter = src.balanceOf(address(this));
            actualSrcAmount = balanceAfter.sub(balanceBefore);
            require(actualSrcAmount > 0, "invalid src amount");

            safeApproveAllowance(protocol, src);
        }
    }

    function burnGasTokensAfter(uint256 gasBefore) internal virtual returns (uint256 numGasBurns) {
        if (burnGasHelper == IBurnGasHelper(0)) return 0;
        IGasToken gasToken;
        uint256 gasAfter = gasleft();

        try
            burnGasHelper.getAmountGasTokensToBurn(gasBefore.sub(gasAfter).add(msg.data.length))
        returns (uint256 _gasBurns, address _gasToken) {
            numGasBurns = _gasBurns;
            gasToken = IGasToken(_gasToken);
        } catch {
            numGasBurns = 0;
        }

        if (numGasBurns > 0 && gasToken != IGasToken(0)) {
            numGasBurns = gasToken.freeFromUpTo(msg.sender, numGasBurns);
        }
    }

    function safeForwardTokenAndCollectFee(
        IERC20Ext token,
        address from,
        address payable to,
        uint256 amount,
        uint256 platformFeeBps,
        address payable platformWallet
    ) internal returns (uint256 destAmount) {
        require(platformFeeBps < BPS, "high platform fee");
        require(supportedPlatformWallets[platformWallet], "unsupported platform wallet");
        uint256 feeAmount = (amount * platformFeeBps) / BPS;
        destAmount = amount - feeAmount;
        if (token == ETH_TOKEN_ADDRESS) {
            require(msg.value >= amount);
            (bool success, ) = to.call{value: destAmount}("");
            require(success, "transfer eth failed");
        } else {
            uint256 balanceBefore = token.balanceOf(to);
            token.safeTransferFrom(from, to, amount);
            uint256 balanceAfter = token.balanceOf(to);
            destAmount = balanceAfter.sub(balanceBefore);
        }
        addFeeToPlatform(platformWallet, token, feeAmount);
    }

    function addFeeToPlatform(
        address wallet,
        IERC20Ext token,
        uint256 amount
    ) internal {
        if (amount > 0) {
            platformWalletFees[wallet][token] = platformWalletFees[wallet][token].add(amount);
        }
    }

    function transferToken(
        address payable recipient,
        IERC20Ext token,
        uint256 amount
    ) internal {
        if (amount == 0) return;
        if (token == ETH_TOKEN_ADDRESS) {
            (bool success, ) = recipient.call{value: amount}("");
            require(success, "failed to transfer eth");
        } else {
            token.safeTransfer(recipient, amount);
        }
    }

    function safeApproveAllowance(address spender, IERC20Ext token) internal {
        if (token.allowance(address(this), spender) == 0) {
            getSetDecimals(token);
            token.safeApprove(spender, MAX_ALLOWANCE);
        }
    }
}