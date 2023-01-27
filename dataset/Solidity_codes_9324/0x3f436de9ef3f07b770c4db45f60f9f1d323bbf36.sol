
pragma solidity ^0.7.3;

interface IATokenV1 {

    function UINT_MAX_VALUE() external view returns (uint256);


    function allowInterestRedirectionTo(address _to) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function balanceOf(address _user) external view returns (uint256);


    function burnOnLiquidation(address _account, uint256 _value) external;


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function getInterestRedirectionAddress(address _user) external view returns (address);


    function getRedirectedBalance(address _user) external view returns (uint256);


    function getUserIndex(address _user) external view returns (uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function isTransferAllowed(address _user, uint256 _amount) external view returns (bool);


    function mintOnDeposit(address _account, uint256 _amount) external;


    function name() external view returns (string memory);


    function principalBalanceOf(address _user) external view returns (uint256);


    function redeem(uint256 _amount) external;


    function redirectInterestStream(address _to) external;


    function redirectInterestStreamOf(address _from, address _to) external;


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function transferOnLiquidation(
        address _from,
        address _to,
        uint256 _value
    ) external;


    function underlyingAssetAddress() external view returns (address);

}

pragma solidity ^0.7.3;

interface ICToken {

    function _acceptAdmin() external returns (uint256);


    function _addReserves(uint256 addAmount) external returns (uint256);


    function _reduceReserves(uint256 reduceAmount) external returns (uint256);


    function _setComptroller(address newComptroller) external returns (uint256);


    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) external;


    function _setInterestRateModel(address newInterestRateModel) external returns (uint256);


    function _setPendingAdmin(address newPendingAdmin) external returns (uint256);


    function _setReserveFactor(uint256 newReserveFactorMantissa) external returns (uint256);


    function accrualBlockNumber() external view returns (uint256);


    function accrueInterest() external returns (uint256);


    function admin() external view returns (address);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address owner) external view returns (uint256);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function borrow(uint256 borrowAmount) external returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function borrowBalanceStored(address account) external view returns (uint256);


    function borrowIndex() external view returns (uint256);


    function borrowRatePerBlock() external view returns (uint256);


    function comptroller() external view returns (address);


    function decimals() external view returns (uint8);


    function delegateToImplementation(bytes memory data) external returns (bytes memory);


    function delegateToViewImplementation(bytes memory data) external view returns (bytes memory);


    function exchangeRateCurrent() external returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function getCash() external view returns (uint256);


    function implementation() external view returns (address);


    function interestRateModel() external view returns (address);


    function isCToken() external view returns (bool);


    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external returns (uint256);


    function mint(uint256 mintAmount) external returns (uint256);


    function name() external view returns (string memory);


    function pendingAdmin() external view returns (address);


    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


    function repayBorrow(uint256 repayAmount) external returns (uint256);


    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);


    function reserveFactorMantissa() external view returns (uint256);


    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);


    function supplyRatePerBlock() external view returns (uint256);


    function symbol() external view returns (string memory);


    function totalBorrows() external view returns (uint256);


    function totalBorrowsCurrent() external returns (uint256);


    function totalReserves() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function transfer(address dst, uint256 amount) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);


    function underlying() external view returns (address);

}

pragma solidity ^0.7.3;

interface IComptroller {

    function _addCompMarkets(address[] memory cTokens) external;


    function _become(address unitroller) external;


    function _borrowGuardianPaused() external view returns (bool);


    function _dropCompMarket(address cToken) external;


    function _grantComp(address recipient, uint256 amount) external;


    function _mintGuardianPaused() external view returns (bool);


    function _setBorrowCapGuardian(address newBorrowCapGuardian) external;


    function _setBorrowPaused(address cToken, bool state) external returns (bool);


    function _setCloseFactor(uint256 newCloseFactorMantissa) external returns (uint256);


    function _setCollateralFactor(address cToken, uint256 newCollateralFactorMantissa) external returns (uint256);


    function _setCompRate(uint256 compRate_) external;


    function _setContributorCompSpeed(address contributor, uint256 compSpeed) external;


    function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa) external returns (uint256);


    function _setMarketBorrowCaps(address[] memory cTokens, uint256[] memory newBorrowCaps) external;


    function _setMintPaused(address cToken, bool state) external returns (bool);


    function _setPauseGuardian(address newPauseGuardian) external returns (uint256);


    function _setPriceOracle(address newOracle) external returns (uint256);


    function _setSeizePaused(bool state) external returns (bool);


    function _setTransferPaused(bool state) external returns (bool);


    function _supportMarket(address cToken) external returns (uint256);


    function accountAssets(address, uint256) external view returns (address);


    function admin() external view returns (address);


    function allMarkets(uint256) external view returns (address);


    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);


    function borrowCapGuardian() external view returns (address);


    function borrowCaps(address) external view returns (uint256);


    function borrowGuardianPaused(address) external view returns (bool);


    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;


    function checkMembership(address account, address cToken) external view returns (bool);


    function claimComp(address holder, address[] memory cTokens) external;


    function claimComp(
        address[] memory holders,
        address[] memory cTokens,
        bool borrowers,
        bool suppliers
    ) external;


    function claimComp(address holder) external;


    function closeFactorMantissa() external view returns (uint256);


    function compAccrued(address) external view returns (uint256);


    function compBorrowState(address) external view returns (uint224 index, uint32);


    function compBorrowerIndex(address, address) external view returns (uint256);


    function compClaimThreshold() external view returns (uint256);


    function compContributorSpeeds(address) external view returns (uint256);


    function compInitialIndex() external view returns (uint224);


    function compRate() external view returns (uint256);


    function compSpeeds(address) external view returns (uint256);


    function compSupplierIndex(address, address) external view returns (uint256);


    function compSupplyState(address) external view returns (uint224 index, uint32);


    function comptrollerImplementation() external view returns (address);


    function enterMarkets(address[] memory cTokens) external returns (uint256[] memory);


    function exitMarket(address cTokenAddress) external returns (uint256);


    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function getAllMarkets() external view returns (address[] memory);


    function getAssetsIn(address account) external view returns (address[] memory);


    function getBlockNumber() external view returns (uint256);


    function getCompAddress() external view returns (address);


    function getHypotheticalAccountLiquidity(
        address account,
        address cTokenModify,
        uint256 redeemTokens,
        uint256 borrowAmount
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function isComptroller() external view returns (bool);


    function lastContributorBlock(address) external view returns (uint256);


    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 actualRepayAmount,
        uint256 seizeTokens
    ) external;


    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256, uint256);


    function liquidationIncentiveMantissa() external view returns (uint256);


    function markets(address)
        external
        view
        returns (
            bool isListed,
            uint256 collateralFactorMantissa,
            bool isComped
        );


    function maxAssets() external view returns (uint256);


    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);


    function mintGuardianPaused(address) external view returns (bool);


    function mintVerify(
        address cToken,
        address minter,
        uint256 actualMintAmount,
        uint256 mintTokens
    ) external;


    function oracle() external view returns (address);


    function pauseGuardian() external view returns (address);


    function pendingAdmin() external view returns (address);


    function pendingComptrollerImplementation() external view returns (address);


    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);


    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;


    function refreshCompSpeeds() external;


    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 actualRepayAmount,
        uint256 borrowerIndex
    ) external;


    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);


    function seizeGuardianPaused() external view returns (bool);


    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;


    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);


    function transferGuardianPaused() external view returns (bool);


    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;


    function updateContributorRewards(address contributor) external;

}

pragma solidity ^0.7.3;

interface ILendingPoolV1 {

    function LENDINGPOOL_REVISION() external view returns (uint256);


    function UINT_MAX_VALUE() external view returns (uint256);


    function addressesProvider() external view returns (address);


    function borrow(
        address _reserve,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode
    ) external;


    function core() external view returns (address);


    function dataProvider() external view returns (address);


    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable;


    function flashLoan(
        address _receiver,
        address _reserve,
        uint256 _amount,
        bytes memory _params
    ) external;


    function getReserveConfigurationData(address _reserve)
        external
        view
        returns (
            uint256 ltv,
            uint256 liquidationThreshold,
            uint256 liquidationBonus,
            address interestRateStrategyAddress,
            bool usageAsCollateralEnabled,
            bool borrowingEnabled,
            bool stableBorrowRateEnabled,
            bool isActive
        );


    function getReserveData(address _reserve)
        external
        view
        returns (
            uint256 totalLiquidity,
            uint256 availableLiquidity,
            uint256 totalBorrowsStable,
            uint256 totalBorrowsVariable,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 utilizationRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            address aTokenAddress,
            uint40 lastUpdateTimestamp
        );


    function getReserves() external view returns (address[] memory);


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


    function initialize(address _addressesProvider) external;


    function liquidationCall(
        address _collateral,
        address _reserve,
        address _user,
        uint256 _purchaseAmount,
        bool _receiveAToken
    ) external payable;


    function parametersProvider() external view returns (address);


    function rebalanceStableBorrowRate(address _reserve, address _user) external;


    function redeemUnderlying(
        address _reserve,
        address _user,
        uint256 _amount,
        uint256 _aTokenBalanceAfterRedeem
    ) external;


    function repay(
        address _reserve,
        uint256 _amount,
        address _onBehalfOf
    ) external payable;


    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral) external;


    function swapBorrowRateMode(address _reserve) external;

}

pragma solidity ^0.7.3;

interface ISushiBar {

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function enter(uint256 _amount) external;


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function leave(uint256 _share) external;


    function name() external view returns (string memory);


    function sushi() external view returns (address);


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

pragma solidity ^0.7.3;



interface IBDPI {

    function transfer(address dst, uint256 amount) external returns (bool);

    
    function totalSupply() external view returns (uint256);


    function mint(uint256) external;


    function getOne() external view returns (address[] memory, uint256[] memory);


    function getAssetsAndBalances() external view returns (address[] memory, uint256[] memory);

}

contract Helpers {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant LENDING_POOL_V1 = 0x398eC7346DcD622eDc5ae82352F02bE94C62d119;
    address constant LENDING_POOL_CORE_V1 = 0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3;

    address constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    address constant SUSHISWAP_ROUTER = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address constant UNIV2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address constant CUNI = 0x35A18000230DA775CAc24873d00Ff85BccdeD550;
    address constant CCOMP = 0x70e36f6BF80a52b3B46b3aF8e106CC0ed743E8e4;

    address constant XSUSHI = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272;

    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address constant DPI = 0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b;

    address constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address constant COMP = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address constant YFI = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
    address constant SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address constant MKR = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address constant REN = 0x408e41876cCCDC0F92210600ef50372656052a38;
    address constant KNC = 0xdd974D5C2e2928deA5F71b9825b8b646686BD200;
    address constant LRC = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;
    address constant BAL = 0xba100000625a3754423978a60c9317c58a424e3D;
    address constant AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
    address constant MTA = 0xa3BeD4E1c75D00fa6f4E5E6922DB7261B5E9AcD2;
    address constant SUSHI = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;


    function enterMarkets(address[] memory _markets) public {

        IComptroller(COMPTROLLER).enterMarkets(_markets);
    }


    function _toDerivative(address _underlying, address _derivative) internal {

        if (_underlying == _derivative) {
            return;
        }

        if (_derivative == CUNI || _derivative == CCOMP) {
            _toCToken(_underlying);
        } else if (_derivative == XSUSHI) {
            _toXSushi();
        } else {
            _toATokenV1(_underlying);
        }
    }

    function _toCToken(address _token) internal {

        require(_token == UNI || _token == COMP, "!valid-to-ctoken");

        address _ctoken = _getTokenToCToken(_token);
        uint256 balance = IERC20(_token).balanceOf(address(this));

        require(balance > 0, "!token-bal");

        IERC20(_token).safeApprove(_ctoken, 0);
        IERC20(_token).safeApprove(_ctoken, balance);
        require(ICToken(_ctoken).mint(balance) == 0, "!ctoken-mint");
    }

    function _toATokenV1(address _token) internal {

        require(_token != UNI && _token != COMP, "no-uni-or-comp");

        uint256 balance = IERC20(_token).balanceOf(address(this));

        require(balance > 0, "!token-bal");

        IERC20(_token).safeApprove(LENDING_POOL_CORE_V1, 0);
        IERC20(_token).safeApprove(LENDING_POOL_CORE_V1, balance);
        ILendingPoolV1(LENDING_POOL_V1).deposit(_token, balance, 0);
    }

    function _getTokenToCToken(address _token) internal pure returns (address) {

        if (_token == UNI) {
            return CUNI;
        }
        if (_token == COMP) {
            return CCOMP;
        }
        revert("!supported-token-to-ctoken");
    }

    function _toXSushi() internal {

        uint256 balance = IERC20(SUSHI).balanceOf(address(this));
        require(balance > 0, "!sushi-bal");

        IERC20(SUSHI).safeApprove(XSUSHI, 0);
        IERC20(SUSHI).safeApprove(XSUSHI, balance);
        ISushiBar(XSUSHI).enter(balance);
    }
}

pragma solidity ^0.7.3;

interface ICompoundLens {

    function getCompBalanceMetadataExt(
        address comp,
        address comptroller,
        address account
    )
        external
        returns (
            uint256 balance,
            uint256 votes,
            address delegate,
            uint256 allocated
        );

}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);


    function feeToSetter() external view returns (address);


    function migrator() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;


    function setFeeToSetter(address) external;


    function setMigrator(address) external;

}

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to) external returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function skim(address to) external;


    function sync() external;


    function initialize(address, address) external;

}

interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

pragma solidity ^0.7.3;

interface IBasicIssuanceModule {

    function controller() external view returns (address);


    function getRequiredComponentUnitsForIssue(address _setToken, uint256 _quantity)
        external
        view
        returns (address[] memory, uint256[] memory);


    function initialize(address _setToken, address _preIssueHook) external;


    function issue(
        address _setToken,
        uint256 _quantity,
        address _to
    ) external;


    function managerIssuanceHook(address) external view returns (address);


    function redeem(
        address _setToken,
        uint256 _quantity,
        address _to
    ) external;


    function removeModule() external;

}

pragma solidity ^0.7.3;

interface IOneInch {

    function FLAG_DISABLE_AAVE() external view returns (uint256);


    function FLAG_DISABLE_BANCOR() external view returns (uint256);


    function FLAG_DISABLE_BDAI() external view returns (uint256);


    function FLAG_DISABLE_CHAI() external view returns (uint256);


    function FLAG_DISABLE_COMPOUND() external view returns (uint256);


    function FLAG_DISABLE_CURVE_BINANCE() external view returns (uint256);


    function FLAG_DISABLE_CURVE_COMPOUND() external view returns (uint256);


    function FLAG_DISABLE_CURVE_SYNTHETIX() external view returns (uint256);


    function FLAG_DISABLE_CURVE_USDT() external view returns (uint256);


    function FLAG_DISABLE_CURVE_Y() external view returns (uint256);


    function FLAG_DISABLE_FULCRUM() external view returns (uint256);


    function FLAG_DISABLE_IEARN() external view returns (uint256);


    function FLAG_DISABLE_KYBER() external view returns (uint256);


    function FLAG_DISABLE_OASIS() external view returns (uint256);


    function FLAG_DISABLE_SMART_TOKEN() external view returns (uint256);


    function FLAG_DISABLE_UNISWAP() external view returns (uint256);


    function FLAG_DISABLE_WETH() external view returns (uint256);


    function FLAG_ENABLE_KYBER_BANCOR_RESERVE() external view returns (uint256);


    function FLAG_ENABLE_KYBER_OASIS_RESERVE() external view returns (uint256);


    function FLAG_ENABLE_KYBER_UNISWAP_RESERVE() external view returns (uint256);


    function FLAG_ENABLE_MULTI_PATH_DAI() external view returns (uint256);


    function FLAG_ENABLE_MULTI_PATH_ETH() external view returns (uint256);


    function FLAG_ENABLE_MULTI_PATH_USDC() external view returns (uint256);


    function FLAG_ENABLE_UNISWAP_COMPOUND() external view returns (uint256);


    function claimAsset(address asset, uint256 amount) external;


    function getExpectedReturn(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 parts,
        uint256 featureFlags
    ) external view returns (uint256 returnAmount, uint256[] memory distribution);


    function isOwner() external view returns (bool);


    function oneSplitImpl() external view returns (address);


    function owner() external view returns (address);


    function renounceOwnership() external;


    function setNewImpl(address impl) external;


    function swap(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 featureFlags
    ) external payable;


    function transferOwnership(address newOwner) external;

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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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

pragma solidity ^0.7.3;




contract SocialWeaverV1 is ReentrancyGuard, Helpers {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IOneInch public constant OneInch = IOneInch(0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E);
    IBDPI public constant BDPI = IBDPI(0x0309c98B1bffA350bcb3F9fB9780970CA32a5060);

    IBasicIssuanceModule public constant DPI_ISSUER = IBasicIssuanceModule(0xd8EF3cACe8b4907117a45B0b125c68560532F94D);

    address public governance;


    uint256 public weaveIdETH = 0;

    mapping(address => mapping(uint256 => uint256)) public depositsETH;

    mapping(address => mapping(uint256 => bool)) public basketsClaimedETH;

    mapping(uint256 => uint256) public totalDepositedETH;

    mapping(uint256 => uint256) public basketsMintedETH;

    uint256 public weaveIdDPI = 0;

    mapping(address => mapping(uint256 => uint256)) public depositsDPI;

    mapping(address => mapping(uint256 => bool)) public basketsClaimedDPI;

    mapping(uint256 => uint256) public totalDepositedDPI;

    mapping(uint256 => uint256) public basketsMintedDPI;

    mapping(address => bool) public approvedWeavers;


    constructor(address _governance) {
        governance = _governance;

        address[] memory markets = new address[](2);
        markets[0] = CUNI;
        markets[0] = CCOMP;
        enterMarkets(markets);
    }

    modifier onlyGov() {
        require(msg.sender == governance, "!governance");
        _;
    }

    modifier onlyWeavers {
        require(msg.sender == governance || approvedWeavers[msg.sender], "!weaver");
        _;
    }

    receive() external payable {}


    function approveWeaver(address _weaver) public onlyGov {
        approvedWeavers[_weaver] = true;
    }

    function revokeWeaver(address _weaver) public onlyGov {
        approvedWeavers[_weaver] = false;
    }

    function setGov(address _governance) public onlyGov {
        governance = _governance;
    }

    function recoverERC20(address _token) public onlyGov {
        require(address(_token) != address(BDPI), "!dpi");
        require(address(_token) != address(DPI), "!dpi");
        IERC20(_token).safeTransfer(governance, IERC20(_token).balanceOf(address(this)));
    }

    function weaveWithDPI(
        address[] memory derivatives,
        address[] memory underlyings,
        uint256 minMintAmount,
        uint256 deadline
    ) public onlyWeavers {
        require(block.timestamp <= deadline, "expired");
        uint256 bdpiToMint = _burnDPIAndGetMintableBDPI(derivatives, underlyings);
        require(bdpiToMint >= minMintAmount, "!mint-min-amount");

        basketsMintedDPI[weaveIdDPI] = bdpiToMint;

        BDPI.mint(bdpiToMint);

        weaveIdDPI++;
    }

    function weaveWithETH(
        address[] memory derivatives,
        address[] memory underlyings,
        uint256 minMintAmount,
        uint256 deadline
    ) public onlyWeavers {
        require(block.timestamp <= deadline, "expired");

        (uint256 retAmount, uint256[] memory distribution) =
            OneInch.getExpectedReturn(address(0), DPI, address(this).balance, 2, 0);
        OneInch.swap{ value: address(this).balance }(
            address(0),
            DPI,
            address(this).balance,
            retAmount,
            distribution,
            0
        );
        uint256 bdpiToMint = _burnDPIAndGetMintableBDPI(derivatives, underlyings);
        require(bdpiToMint >= minMintAmount, "!mint-min-amount");

        basketsMintedETH[weaveIdETH] = bdpiToMint;

        BDPI.mint(bdpiToMint);

        weaveIdETH++;
    }



    function depositDPI(uint256 _amount) public nonReentrant {
        require(_amount > 1e8, "!dust-dpi");
        IERC20(DPI).safeTransferFrom(msg.sender, address(this), _amount);

        depositsDPI[msg.sender][weaveIdDPI] = depositsDPI[msg.sender][weaveIdDPI].add(_amount);
        totalDepositedDPI[weaveIdDPI] = totalDepositedDPI[weaveIdDPI].add(_amount);
    }

    function withdrawDPI(uint256 _amount) public nonReentrant {
        depositsDPI[msg.sender][weaveIdDPI] = depositsDPI[msg.sender][weaveIdDPI].sub(_amount);
        totalDepositedDPI[weaveIdDPI] = totalDepositedDPI[weaveIdDPI].sub(_amount);

        IERC20(DPI).safeTransfer(msg.sender, _amount);
    }

    function withdrawBasketDPI(uint256 _weaveId) public nonReentrant {
        require(_weaveId < weaveIdDPI, "!weaved");
        require(!basketsClaimedDPI[msg.sender][_weaveId], "already-claimed");
        uint256 userDeposited = depositsDPI[msg.sender][_weaveId];
        require(userDeposited > 0, "!deposit");

        uint256 ratio = userDeposited.mul(1e18).div(totalDepositedDPI[_weaveId]);
        uint256 userBasketAmount = basketsMintedDPI[_weaveId].mul(ratio).div(1e18);
        basketsClaimedDPI[msg.sender][_weaveId] = true;

        IERC20(address(BDPI)).safeTransfer(msg.sender, userBasketAmount);
    }

    function withdrawBasketDPIMany(uint256[] memory _weaveIds) public {
        for (uint256 i = 0; i < _weaveIds.length; i++) {
            withdrawBasketDPI(_weaveIds[i]);
        }
    }


    function depositETH() public payable nonReentrant {
        require(msg.value > 1e8, "!dust-eth");

        depositsETH[msg.sender][weaveIdETH] = depositsETH[msg.sender][weaveIdETH].add(msg.value);
        totalDepositedETH[weaveIdETH] = totalDepositedETH[weaveIdETH].add(msg.value);
    }

    function withdrawETH(uint256 _amount) public nonReentrant {
        depositsETH[msg.sender][weaveIdETH] = depositsETH[msg.sender][weaveIdETH].sub(_amount);
        totalDepositedETH[weaveIdETH] = totalDepositedETH[weaveIdETH].sub(_amount);

        (bool s, ) = msg.sender.call{ value: _amount }("");
        require(s, "!transfer-eth");
    }

    function withdrawBasketETH(uint256 _weaveId) public nonReentrant {
        require(_weaveId < weaveIdETH, "!weaved");
        require(!basketsClaimedETH[msg.sender][_weaveId], "already-claimed");
        uint256 userDeposited = depositsETH[msg.sender][_weaveId];
        require(userDeposited > 0, "!deposit");

        uint256 ratio = userDeposited.mul(1e18).div(totalDepositedETH[_weaveId]);
        uint256 userBasketAmount = basketsMintedETH[_weaveId].mul(ratio).div(1e18);
        basketsClaimedETH[msg.sender][_weaveId] = true;

        IERC20(address(BDPI)).safeTransfer(msg.sender, userBasketAmount);
    }

    function withdrawBasketETHMany(uint256[] memory _weaveIds) public {
        for (uint256 i = 0; i < _weaveIds.length; i++) {
            withdrawBasketETH(_weaveIds[i]);
        }
    }


    function _getRouterAddressForToken(address _token) internal pure returns (address) {

        if (_token == KNC || _token == LRC || _token == BAL || _token == MTA) {
            return UNIV2_ROUTER;
        }

        return SUSHISWAP_ROUTER;
    }

    function _burnDPIAndGetMintableBDPI(address[] memory derivatives, address[] memory underlyings)
        internal
        returns (uint256)
    {
        uint256 dpiBal = IERC20(DPI).balanceOf(address(this));
        IERC20(DPI).approve(address(DPI_ISSUER), dpiBal);
        DPI_ISSUER.redeem(address(DPI), dpiBal, address(this));

        (, uint256[] memory tokenAmountsInBasket) = BDPI.getAssetsAndBalances();
        uint256 basketTotalSupply = BDPI.totalSupply();
        uint256 bdpiToMint;
        for (uint256 i = 0; i < derivatives.length; i++) {
            _toDerivative(underlyings[i], derivatives[i]);

            bdpiToMint = _approveDerivativeAndGetMintAmount(
                derivatives[i],
                basketTotalSupply,
                tokenAmountsInBasket[i],
                bdpiToMint
            );
        }

        return bdpiToMint;
    }

    function _approveDerivativeAndGetMintAmount(
        address derivative,
        uint256 basketTotalSupply,
        uint256 tokenAmountInBasket,
        uint256 curMintAmount
    ) internal returns (uint256) {
        uint256 derivativeBal = IERC20(derivative).balanceOf(address(this));

        IERC20(derivative).safeApprove(address(BDPI), 0);
        IERC20(derivative).safeApprove(address(BDPI), derivativeBal);

        if (curMintAmount == 0) {
            return basketTotalSupply.mul(derivativeBal).div(tokenAmountInBasket);
        }

        uint256 temp = basketTotalSupply.mul(derivativeBal).div(tokenAmountInBasket);
        if (temp < curMintAmount) {
            return temp;
        }

        return curMintAmount;
    }
}
