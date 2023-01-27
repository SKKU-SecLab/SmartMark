

pragma solidity >=0.4.24 <0.7.0;


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


pragma solidity ^0.5.16;



contract OwnableUpgradable is Initializable {

    address payable public owner;
    address payable internal newOwnerCandidate;


    modifier onlyOwner {

        require(msg.sender == owner, "Permission denied");
        _;
    }



    function initialize() public initializer {

        owner = msg.sender;
    }

    function initialize(address payable newOwner) public initializer {

        owner = newOwner;
    }


    function changeOwner(address payable newOwner) public onlyOwner {

        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {

        require(msg.sender == newOwnerCandidate, "Permission denied");
        owner = newOwnerCandidate;
    }


    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
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


pragma solidity ^0.5.16;

interface IToken {

    function decimals() external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function approve(address spender, uint value) external;

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function deposit() external payable;

    function withdraw(uint amount) external;

}


pragma solidity ^0.5.16;





library SafeERC20 {


    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IToken token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IToken token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IToken token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IToken token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IToken token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IToken token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.16;




library UniversalERC20 {


    using SafeMath for uint256;
    using SafeERC20 for IToken;

    IToken private constant ZERO_ADDRESS = IToken(0x0000000000000000000000000000000000000000);
    IToken private constant ETH_ADDRESS = IToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(IToken token, address to, uint256 amount) internal {

        universalTransfer(token, to, amount, false);
    }

    function universalTransfer(IToken token, address to, uint256 amount, bool mayFail) internal returns(bool) {

        if (amount == 0) {
            return true;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            if (mayFail) {
                return address(uint160(to)).send(amount);
            } else {
                address(uint160(to)).transfer(amount);
                return true;
            }
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    function universalApprove(IToken token, address to, uint256 amount) internal {

        if (token != ZERO_ADDRESS && token != ETH_ADDRESS) {
            token.safeApprove(to, amount);
        }
    }

    function universalTransferFrom(IToken token, address from, address to, uint256 amount) internal {

        if (amount == 0) {
            return;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            require(from == msg.sender && msg.value >= amount, "msg.value is zero");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(uint256(msg.value).sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalBalanceOf(IToken token, address who) internal view returns (uint256) {

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
}


pragma solidity ^0.5.16;




contract FundsMgrUpgradable is Initializable, OwnableUpgradable {

    using UniversalERC20 for IToken;

    function initialize() public initializer {

        OwnableUpgradable.initialize();  // Initialize Parent Contract
    }

    function initialize(address payable newOwner) public initializer {

        OwnableUpgradable.initialize(newOwner);  // Initialize Parent Contract
    }


    function withdraw(address token, uint256 amount) public onlyOwner {

        if (token == address(0x0)) {
            owner.transfer(amount);
        } else {
            IToken(token).universalTransfer(owner, amount);
        }
    }

    function withdrawAll(address[] memory tokens) public onlyOwner {

        for(uint256 i = 0; i < tokens.length;i++) {
            withdraw(tokens[i], IToken(tokens[i]).universalBalanceOf(address(this)));
        }
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.16;




contract AdminableUpgradable is Initializable, OwnableUpgradable {

    mapping(address => bool) public admins;


    modifier onlyOwnerOrAdmin {

        require(msg.sender == owner ||
                admins[msg.sender], "Permission denied");
        _;
    }


    function initialize() public initializer {

        OwnableUpgradable.initialize();  // Initialize Parent Contract
    }

    function initialize(address payable newOwner) public initializer {

        OwnableUpgradable.initialize(newOwner);  // Initialize Parent Contract
    }


    function setAdminPermission(address _admin, bool _status) public onlyOwner {

        admins[_admin] = _status;
    }

    function setAdminPermission(address[] memory _admins, bool _status) public onlyOwner {

        for (uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = _status;
        }
    }


    uint256[50] private ______gap;
}


pragma solidity ^0.5.16;


contract ConstantAddresses {

    address public constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    address public constant COMPOUND_ORACLE = 0x1D8aEdc9E924730DD3f9641CDb4D1B92B848b4bd;

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant CETH_ADDRESS = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;

    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant CUSDC_ADDRESS = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;

    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;

    address public constant COMP_ADDRESS = 0xc00e94Cb662C3520282E6f5717214004A7f26888;

    address public constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
}


pragma solidity ^0.5.0;

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y, uint base) internal pure returns (uint z) {

        z = add(mul(x, y), base / 2) / base;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

}


pragma solidity ^0.5.16;

interface IFlashLoanReceiver {


    function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata _params) external;

}


pragma solidity ^0.5.0;


interface ILendingPoolAddressesProvider {


    function getLendingPool() external view returns (address);

    function setLendingPoolImpl(address _pool) external;


    function getLendingPoolCore() external view returns (address payable);

    function setLendingPoolCoreImpl(address _lendingPoolCore) external;


    function getLendingPoolConfigurator() external view returns (address);

    function setLendingPoolConfiguratorImpl(address _configurator) external;


    function getLendingPoolDataProvider() external view returns (address);

    function setLendingPoolDataProviderImpl(address _provider) external;


    function getLendingPoolParametersProvider() external view returns (address);

    function setLendingPoolParametersProviderImpl(address _parametersProvider) external;


    function getTokenDistributor() external view returns (address);

    function setTokenDistributor(address _tokenDistributor) external;



    function getFeeProvider() external view returns (address);

    function setFeeProviderImpl(address _feeProvider) external;


    function getLendingPoolLiquidationManager() external view returns (address);

    function setLendingPoolLiquidationManager(address _manager) external;


    function getLendingPoolManager() external view returns (address);

    function setLendingPoolManager(address _lendingPoolManager) external;


    function getPriceOracle() external view returns (address);

    function setPriceOracle(address _priceOracle) external;


    function getLendingRateOracle() external view returns (address);

    function setLendingRateOracle(address _lendingRateOracle) external;


}


pragma solidity ^0.5.0;


library EthAddressLib {


    function ethAddress() internal pure returns(address) {

        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
}


pragma solidity ^0.5.0;








contract FlashLoanReceiverBase is IFlashLoanReceiver {


    using SafeERC20 for IToken;



    address public constant AAVE_ADDRESSES_PROVIDER = 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5;


    function transferFundsBackToPoolInternal(address _reserve, uint256 _amount) internal {

        address payable core = ILendingPoolAddressesProvider(AAVE_ADDRESSES_PROVIDER).getLendingPoolCore();
        transferInternal(core, _reserve, _amount);
    }

    function transferInternal(address _destination, address _reserve, uint256  _amount) internal {


        if(_reserve == EthAddressLib.ethAddress()) {
            address payable receiverPayable = address(uint160(_destination));

            (bool result, ) = receiverPayable.call.value(_amount)("");

            require(result, "Transfer of ETH failed");
            return;
        }

        IToken(_reserve).safeTransfer(_destination, _amount);
    }

    function getBalanceInternal(address _target, address _reserve) internal view returns(uint256) {

        if(_reserve == EthAddressLib.ethAddress()) {
            return _target.balance;
        }

        return IToken(_reserve).balanceOf(_target);
    }

}


pragma solidity ^0.5.16;


interface IDfWalletFactory {

    function createDfWallet() external returns (address dfWallet);

}


pragma solidity ^0.5.16;


interface ICompoundOracle {

    function getUnderlyingPrice(address cToken) external view returns (uint);

}


pragma solidity ^0.5.16;


contract IComptroller {

    mapping(address => uint) public compAccrued;

    function claimComp(address holder, address[] memory cTokens) public;


    function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);


    function exitMarket(address cToken) external returns (uint256);


    function getAssetsIn(address account) external view returns (address[] memory);


    function getAccountLiquidity(address account) external view returns (uint256, uint256, uint256);


    function markets(address cTokenAddress) external view returns (bool, uint);


    struct CompMarketState {
        uint224 index;

        uint32 block;
    }

    function compSupplyState(address) view public returns(uint224, uint32);


    function compBorrowState(address) view public returns(uint224, uint32);



    mapping(address => mapping(address => uint)) public compSupplierIndex;

    mapping(address => mapping(address => uint)) public compBorrowerIndex;
}


pragma solidity ^0.5.16;


interface IDfWallet {


    function claimComp(address[] calldata cTokens) external;


    function borrow(address _cTokenAddr, uint _amount) external;


    function setDfFinanceClose(address _dfFinanceClose) external;


    function deposit(
        address _tokenIn, address _cTokenIn, uint _amountIn, address _tokenOut, address _cTokenOut, uint _amountOut
    ) external payable;


    function withdraw(
        address _tokenIn, address _cTokenIn, address _tokenOut, address _cTokenOut
    ) external payable;


    function withdraw(
        address _tokenIn, address _cTokenIn, uint256 amountRedeem, address _tokenOut, address _cTokenOut, uint256 amountPayback
    ) external payable returns(uint256);


    function withdrawToken(address _tokenAddr, address to, uint256 amount) external;


}


pragma solidity ^0.5.16;


interface ICToken {

    function borrowIndex() view external returns (uint256);


    function mint(uint256 mintAmount) external returns (uint256);


    function mint() external payable;


    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


    function borrow(uint256 borrowAmount) external returns (uint256);


    function repayBorrow(uint256 repayAmount) external returns (uint256);


    function repayBorrow() external payable;


    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);


    function repayBorrowBehalf(address borrower) external payable;


    function liquidateBorrow(address borrower, uint256 repayAmount, address cTokenCollateral)
        external
        returns (uint256);


    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;


    function exchangeRateCurrent() external returns (uint256);


    function supplyRatePerBlock() external returns (uint256);


    function borrowRatePerBlock() external returns (uint256);


    function totalReserves() external returns (uint256);


    function reserveFactorMantissa() external returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function borrowBalanceStored(address account) external view returns (uint256);


    function totalBorrowsCurrent() external returns (uint256);


    function getCash() external returns (uint256);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function balanceOf(address owner) view external returns (uint256);


    function underlying() external returns (address);

}


pragma solidity ^0.5.16;

interface ILendingPool {

    function addressesProvider () external view returns ( address );
    function deposit ( address _reserve, uint256 _amount, uint16 _referralCode ) external payable;
    function redeemUnderlying ( address _reserve, address _user, uint256 _amount ) external;
    function borrow ( address _reserve, uint256 _amount, uint256 _interestRateMode, uint16 _referralCode ) external;
    function repay ( address _reserve, uint256 _amount, address _onBehalfOf ) external payable;
    function swapBorrowRateMode ( address _reserve ) external;
    function rebalanceFixedBorrowRate ( address _reserve, address _user ) external;
    function setUserUseReserveAsCollateral ( address _reserve, bool _useAsCollateral ) external;
    function liquidationCall ( address _collateral, address _reserve, address _user, uint256 _purchaseAmount, bool _receiveAToken ) external payable;
    function flashLoan ( address _receiver, address _reserve, uint256 _amount, bytes calldata _params ) external;
    function getReserveConfigurationData ( address _reserve ) external view returns ( uint256 ltv, uint256 liquidationThreshold, uint256 liquidationDiscount, address interestRateStrategyAddress, bool usageAsCollateralEnabled, bool borrowingEnabled, bool fixedBorrowRateEnabled, bool isActive );
    function getReserveData ( address _reserve ) external view returns ( uint256 totalLiquidity, uint256 availableLiquidity, uint256 totalBorrowsFixed, uint256 totalBorrowsVariable, uint256 liquidityRate, uint256 variableBorrowRate, uint256 fixedBorrowRate, uint256 averageFixedBorrowRate, uint256 utilizationRate, uint256 liquidityIndex, uint256 variableBorrowIndex, address aTokenAddress, uint40 lastUpdateTimestamp );
    function getUserAccountData ( address _user ) external view returns ( uint256 totalLiquidityETH, uint256 totalCollateralETH, uint256 totalBorrowsETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor );
    function getUserReserveData ( address _reserve, address _user ) external view returns ( uint256 currentATokenBalance, uint256 currentUnderlyingBalance, uint256 currentBorrowBalance, uint256 principalBorrowBalance, uint256 borrowRateMode, uint256 borrowRate, uint256 liquidityRate, uint256 originationFee, uint256 variableBorrowIndex, uint256 lastUpdateTimestamp, bool usageAsCollateralEnabled );
    function getReserves () external view;
}


pragma solidity ^0.5.16;

interface IOneInchExchange {

    function spender() external view returns (address);

}


interface IComptrollerLensInterface {

    function markets(address) external view returns (bool, uint);

    function getAccountLiquidity(address) external view returns (uint, uint, uint);

    function claimComp(address) external;

    function compAccrued(address) external view returns (uint);

}


pragma solidity ^0.5.16;



















contract DfFinanceDeposits is
    Initializable,
    DSMath,
    ConstantAddresses,
    FundsMgrUpgradable,
    AdminableUpgradable,
    FlashLoanReceiverBase
{

    using UniversalERC20 for IToken;
    using SafeMath for uint256;


    struct FeeScheme {
        address[] partners;
        uint32[] percents;
        uint32 fee;
        bool isEnabled;
    }

    struct UserData {
        address owner;
        uint256 deposit; //
        uint64 compClaimed;
        uint64 compClaimedinUSD; // 6 decimals
        uint64 activeFeeScheme; // 0 - fee scheme is disabled
        uint64 gap2;
    }

    enum OP {
        UNKNOWN,
        OPEN,
        CLOSE,
        PARTIALLYCLOSE
    }


    IDfWalletFactory public dfWalletFactory;

    uint256 public fee;

    mapping(address => UserData) public wallets;


    mapping(address => mapping(address => uint256)) private partnerBalances;

    FeeScheme[] private feeSchemes;

    OP private state;


    event DfOpenDeposit(address indexed dfWallet, uint256 amount);
    event DfAddDeposit(address indexed dfWallet, uint256 amount);
    event DfCloseDeposit(address indexed dfWallet, uint256 amount, address token);
    event DfPartiallyCloseDeposit(
        address indexed dfWallet, address indexed tokenReceiver, uint256 amountDAI, uint256 tokensSent,  uint256 deposit
    );

    modifier balanceCheck {

        uint256 startBalance = IToken(DAI_ADDRESS).balanceOf(address(this));
        _;
        require(IToken(DAI_ADDRESS).balanceOf(address(this)) >= startBalance);
    }



    function initialize() public initializer {

        AdminableUpgradable.initialize();  // Initialize Parent Contract

        dfWalletFactory = IDfWalletFactory(0x0b7B605F6e5715933EF83505F1db9F2Df3C52FF4);
    }


    function setDfWalletFactory(address _dfWalletFactory) public onlyOwner {

        require(_dfWalletFactory != address(0), "Address must not be zero");
        dfWalletFactory = IDfWalletFactory(_dfWalletFactory);
    }

    function changeFee(uint256 _fee) public onlyOwner {

        require(_fee < 100);
        fee = _fee;
    }

    function getMaxFeeSchemes() public view returns (uint256) {

        return feeSchemes.length;
    }

    function getFeeScheme(uint256 _index) view public returns (uint32 _fee, address[] memory _partners, uint32[] memory _percents) {

        _fee = feeSchemes[_index].fee;
        _partners = feeSchemes[_index].partners;
        _percents = feeSchemes[_index].percents;
    }

    function addNewFeeScheme(uint32 _fee, address[] memory _partners, uint32[] memory _percents, bool _isEnabled) public onlyOwner {

        feeSchemes.push(FeeScheme(_partners, _percents, _fee, _isEnabled));
    }
    function enabledFeeScheme(uint256 _index, bool _isEnabled) onlyOwner public {

        require(_index < feeSchemes.length);
        feeSchemes[_index].isEnabled = _isEnabled;
    }

    function isClosed(address addrWallet) view external returns(bool) {

        return wallets[addrWallet].deposit == 0 && wallets[addrWallet].owner != address(0x0);
    }

    function claimComps(address dfWallet, uint256 minUsdForComp, bytes memory data) public returns(uint256) {

        require(wallets[dfWallet].owner == msg.sender);

        uint256 compTokenBalance = IToken(COMP_ADDRESS).balanceOf(address(this));
        address[] memory cTokens = new address[](1);
        cTokens[0] = CDAI_ADDRESS;
        IDfWallet(dfWallet).claimComp(cTokens);

        compTokenBalance = sub(IToken(COMP_ADDRESS).balanceOf(address(this)), compTokenBalance);

        if (minUsdForComp > 0) {
            uint256 usdcAmount = exchangeInternal(IToken(COMP_ADDRESS), compTokenBalance, IToken(USDC_ADDRESS), minUsdForComp, data);
            usdcAmount = distFees(USDC_ADDRESS, usdcAmount, dfWallet);

            IToken(USDC_ADDRESS).transfer(msg.sender, usdcAmount);
            wallets[dfWallet].compClaimedinUSD += uint64(usdcAmount); // 6 decemals
            return usdcAmount;
        } else {
            compTokenBalance = distFees(COMP_ADDRESS, compTokenBalance, dfWallet);
            IToken(COMP_ADDRESS).transfer(msg.sender, compTokenBalance);
            wallets[dfWallet].compClaimed += uint64(compTokenBalance / 1e12); // 6 decemals
            return compTokenBalance;
        }
    }

    function distFees(address _token, uint256 _reward, address _dfWallet) internal returns (uint256) {

        uint256 feeReward;
        if (wallets[_dfWallet].activeFeeScheme > 0) {
            uint64 index = wallets[_dfWallet].activeFeeScheme - 1;
            FeeScheme memory scheme = feeSchemes[index];
            if (scheme.isEnabled) {
                feeReward = uint256(scheme.fee) * _reward / 100;
                if (feeReward > 0) {
                    for(uint16 i = 0; i < scheme.partners.length;i++) {
                        partnerBalances[scheme.partners[i]][_token] += feeReward * scheme.percents[i] / 100;
                    }
                }
                return sub(_reward, feeReward);
            }
        }
        feeReward = uint256(fee) * _reward / 100;
        if (feeReward > 0) partnerBalances[owner][_token] += feeReward;

        return sub(_reward, feeReward);
    }

    function withdrawPartnerReward(address _token) public {

        require(msg.sender == tx.origin);
        uint256 reward = partnerBalances[msg.sender][_token];
        require(reward > 0);
        partnerBalances[msg.sender][_token] = 0;
        IToken(_token).universalTransfer(msg.sender, reward);
    }

    function partiallyCloseDepositDAI(address dfWallet, address tokenReceiver, uint256 amountDAI) public {

        require(wallets[dfWallet].owner == msg.sender);
        require(wallets[dfWallet].deposit > amountDAI); // not >= cause it closeDeposit
        require(tokenReceiver != address(0x0));

        uint256 startBalance = IToken(DAI_ADDRESS).balanceOf(address(this));

        uint256 flashLoanAmount = amountDAI.mul(3);

        ILendingPool lendingPool = ILendingPool(ILendingPoolAddressesProvider(AAVE_ADDRESSES_PROVIDER).getLendingPool());
        state = OP.PARTIALLYCLOSE;
        lendingPool.flashLoan(address(this), DAI_ADDRESS, flashLoanAmount, abi.encodePacked(dfWallet));
        state = OP.UNKNOWN;

        uint256 tokensSent = sub(IToken(DAI_ADDRESS).balanceOf(address(this)), startBalance);
        IToken(DAI_ADDRESS).transfer(tokenReceiver, tokensSent);

        wallets[dfWallet].deposit = wallets[dfWallet].deposit.sub(amountDAI);

        emit DfPartiallyCloseDeposit(dfWallet, tokenReceiver, amountDAI, tokensSent,  wallets[dfWallet].deposit);
    }

    function closeDepositUsingAave(address dfWallet, uint256 minUsdForComp, bytes memory data) public {

        require(wallets[dfWallet].owner == msg.sender);
        require(wallets[dfWallet].deposit > 0);

        uint256 startBalance = IToken(DAI_ADDRESS).balanceOf(address(this));

        uint256 flashLoanAmount = ICToken(CDAI_ADDRESS).borrowBalanceCurrent(dfWallet);

        ILendingPool lendingPool = ILendingPool(ILendingPoolAddressesProvider(AAVE_ADDRESSES_PROVIDER).getLendingPool());
        state = OP.CLOSE;
        lendingPool.flashLoan(address(this), DAI_ADDRESS, flashLoanAmount, abi.encodePacked(dfWallet));
        state = OP.UNKNOWN;

        IToken(DAI_ADDRESS).transfer(wallets[dfWallet].owner, sub(IToken(DAI_ADDRESS).balanceOf(address(this)), startBalance));
        wallets[dfWallet].deposit = 0;

        if (minUsdForComp > 0) {
            IDfWallet(dfWallet).withdrawToken(COMP_ADDRESS, address(this), IToken(COMP_ADDRESS).balanceOf(dfWallet));
            uint256 amountUsdc = exchangeInternal(IToken(COMP_ADDRESS), IToken(COMP_ADDRESS).balanceOf(dfWallet), IToken(USDC_ADDRESS), minUsdForComp, data);
            amountUsdc = distFees(USDC_ADDRESS, amountUsdc, dfWallet);
            wallets[dfWallet].compClaimedinUSD += uint64(amountUsdc);
            IToken(USDC_ADDRESS).transfer(msg.sender, amountUsdc);
            emit DfCloseDeposit(dfWallet, amountUsdc, USDC_ADDRESS);
        } else {
            uint256 totalComp = IToken(COMP_ADDRESS).balanceOf(dfWallet);
            IDfWallet(dfWallet).withdrawToken(COMP_ADDRESS, address(this), totalComp);
            if (totalComp > 0) {
                totalComp = distFees(COMP_ADDRESS, totalComp, dfWallet);
                IDfWallet(dfWallet).withdrawToken(COMP_ADDRESS, msg.sender, totalComp);
            }
            emit DfCloseDeposit(dfWallet, totalComp, COMP_ADDRESS);
        }
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {

        assembly {
            addr := mload(add(bys,20))
        }
    }


    function exchangeInternal(
        IToken _fromToken, uint _maxFromTokenAmount, IToken _toToken, uint _minToTokenAmount, bytes memory _data
    ) internal returns(uint) {


        IOneInchExchange ex = IOneInchExchange(0x11111254369792b2Ca5d084aB5eEA397cA8fa48B);

        if (_fromToken.allowance(address(this), address(ex.spender())) != uint256(-1)) {
            _fromToken.approve(address(ex.spender()), uint256(-1));
        }

        uint fromTokenBalance = _fromToken.universalBalanceOf(address(this));
        uint toTokenBalance = _toToken.universalBalanceOf(address(this));

        bytes32 response;
        assembly {
            let succeeded := call(sub(gas, 5000), ex, 0, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)      // load delegatecall output
        }

        require(_fromToken.universalBalanceOf(address(this)) + _maxFromTokenAmount >= fromTokenBalance, "Exchange error 1");

        uint256 newBalanceToToken = _toToken.universalBalanceOf(address(this));
        require(newBalanceToToken >= toTokenBalance + _minToTokenAmount, "Exchange error 2");

        return sub(newBalanceToToken, toTokenBalance); // how many tokens received
    }

    function executeOperation(
        address _reserve,
        uint256 _amountFlashLoan,
        uint256 _fee,
        bytes memory _data
    )
    public
    {

        require(state != OP.UNKNOWN);

        address dfWallet = bytesToAddress(_data);

        require(_amountFlashLoan <= getBalanceInternal(address(this), _reserve), "Invalid balance, was the flashLoan successful?");

        if (IToken(DAI_ADDRESS).allowance(address(this), dfWallet) != uint256(-1)) {
            IToken(DAI_ADDRESS).approve(dfWallet, uint256(-1));
        }

        uint256 totalDebt = add(_amountFlashLoan, _fee);
        if (state == OP.OPEN) {
            uint256 deposit;
            assembly {
                deposit := mload(add(_data,52))
            }

            uint256 totalFunds = _amountFlashLoan + deposit;

            IToken(DAI_ADDRESS).transfer(dfWallet, _amountFlashLoan);

            IDfWallet(dfWallet).deposit(DAI_ADDRESS, CDAI_ADDRESS, totalFunds, DAI_ADDRESS, CDAI_ADDRESS, totalDebt);

            IDfWallet(dfWallet).withdrawToken(DAI_ADDRESS, address(this), totalDebt); // TODO: remove it
        } else if (state == OP.CLOSE) {
            IDfWallet(dfWallet).withdraw(DAI_ADDRESS, CDAI_ADDRESS, uint256(-1), DAI_ADDRESS, CDAI_ADDRESS, uint256(-1));
        } else if (state == OP.PARTIALLYCLOSE) {
            uint256 cDaiToExtract =  _amountFlashLoan.add(_amountFlashLoan.div(3)).mul(1e18).div(ICToken(CDAI_ADDRESS).exchangeRateCurrent());

            uint256 receivedAmount = IDfWallet(dfWallet).withdraw(DAI_ADDRESS, CDAI_ADDRESS, cDaiToExtract, DAI_ADDRESS, CDAI_ADDRESS, _amountFlashLoan);
        }

        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

    function createStrategyDepositMulti(uint256 amountDAI, uint256 flashLoanAmount, uint32 times) balanceCheck public {

        address dfWallet = createStrategyDeposit(amountDAI, flashLoanAmount, address(0x0));
        for(uint32 t = 0; t < times;t++) {
            createStrategyDeposit(amountDAI, flashLoanAmount, dfWallet);
        }
    }

    struct CompBalanceMetadataExt {
        uint balance;
        uint votes;
        address delegate;
        uint allocated;
    }

    function getCompBalanceMetadataExt(address account) external returns (uint256 balance, uint256 allocated)
    {

        IComptrollerLensInterface comptroller = IComptrollerLensInterface(COMPTROLLER);
        IToken comp = IToken(COMP_ADDRESS);
        balance = comp.balanceOf(account);
        comptroller.claimComp(account);
        uint256 newBalance = comp.balanceOf(account);
        uint256 accrued = comptroller.compAccrued(account);
        uint256 total = add(accrued, newBalance);
        allocated = sub(total, balance);
    }

    function createStrategyDepositUsingAave(uint256 amountDAI, uint256 flashLoanAmount, address dfWallet) public returns (address) {


        if (dfWallet == address(0x0)) {
            dfWallet = dfWalletFactory.createDfWallet();
            IToken(DAI_ADDRESS).approve(dfWallet, uint256(-1));
            wallets[dfWallet] = UserData(msg.sender, amountDAI, 0, 0, 0, 0);
            emit DfOpenDeposit(dfWallet, amountDAI);
        } else {
            require(wallets[dfWallet].owner == msg.sender);
            wallets[dfWallet].deposit = add(wallets[dfWallet].deposit, amountDAI);
            emit DfAddDeposit(dfWallet, amountDAI);
        }
        IToken(DAI_ADDRESS).universalTransferFrom(msg.sender, dfWallet, amountDAI);

        ILendingPool lendingPool = ILendingPool(ILendingPoolAddressesProvider(AAVE_ADDRESSES_PROVIDER).getLendingPool());
        state = OP.OPEN;
        lendingPool.flashLoan(address(this), DAI_ADDRESS, flashLoanAmount, abi.encodePacked(dfWallet, amountDAI));
        state = OP.UNKNOWN;

        return dfWallet;
    }



    function createStrategyDeposit(uint256 amountDAI, uint256 flashLoanAmount, address dfWallet) public balanceCheck returns (address) {

        if (dfWallet == address(0x0)) {
            dfWallet = dfWalletFactory.createDfWallet();
            IToken(DAI_ADDRESS).approve(dfWallet, uint256(-1));
            wallets[dfWallet] = UserData(msg.sender, amountDAI, 0, 0, 0, 0);
            emit DfOpenDeposit(dfWallet, amountDAI);
        } else {
            require(wallets[dfWallet].owner == msg.sender);
            wallets[dfWallet].deposit = add(wallets[dfWallet].deposit, amountDAI);
            emit DfAddDeposit(dfWallet, amountDAI);
        }

        IToken(DAI_ADDRESS).universalTransferFrom(msg.sender, address(this), amountDAI);

        uint256 totalFunds = flashLoanAmount + amountDAI;

        IToken(DAI_ADDRESS).transfer(dfWallet, totalFunds);

        IDfWallet(dfWallet).deposit(DAI_ADDRESS, CDAI_ADDRESS, totalFunds, DAI_ADDRESS, CDAI_ADDRESS, flashLoanAmount);

        IDfWallet(dfWallet).withdrawToken(DAI_ADDRESS, address(this), flashLoanAmount);

        return dfWallet;
    }

    function closeDepositDAI(address dfWallet, uint256 minUsdForComp, bytes memory data) public balanceCheck {

        require(wallets[dfWallet].owner == msg.sender);
        require(wallets[dfWallet].deposit > 0);

        uint256 startBalance = IToken(DAI_ADDRESS).balanceOf(address(this));

        if (IToken(DAI_ADDRESS).allowance(address(this), dfWallet) != uint256(-1)) {
            IToken(DAI_ADDRESS).approve(dfWallet, uint256(-1));
        }

        IDfWallet(dfWallet).withdraw(DAI_ADDRESS, CDAI_ADDRESS, DAI_ADDRESS, CDAI_ADDRESS);

        uint256 userBalance = sub(IToken(DAI_ADDRESS).balanceOf(address(this)), startBalance);
        IToken(DAI_ADDRESS).transfer(msg.sender, userBalance); // withdraw original dai amount
        wallets[dfWallet].deposit = 0;

        if (minUsdForComp > 0) {
            IDfWallet(dfWallet).withdrawToken(COMP_ADDRESS, address(this), IToken(COMP_ADDRESS).balanceOf(dfWallet));
            uint256 amountUsdc = exchangeInternal(IToken(COMP_ADDRESS), IToken(COMP_ADDRESS).balanceOf(dfWallet), IToken(USDC_ADDRESS), minUsdForComp, data);
            if (fee > 0) amountUsdc = amountUsdc * sub(100, fee) / 100;
            wallets[dfWallet].compClaimedinUSD += uint64(amountUsdc);
            IToken(USDC_ADDRESS).transfer(msg.sender, amountUsdc);
            emit DfCloseDeposit(dfWallet, amountUsdc, USDC_ADDRESS);
        } else {
            uint256 totalComp = IToken(COMP_ADDRESS).balanceOf(dfWallet);
            if (fee > 0) {
                uint256 feeComp = totalComp * sub(100, fee) / 100;
                IDfWallet(dfWallet).withdrawToken(COMP_ADDRESS, address(this), feeComp);
                totalComp = sub(totalComp, feeComp);
            }
            IDfWallet(dfWallet).withdrawToken(COMP_ADDRESS, msg.sender, totalComp);
            emit DfCloseDeposit(dfWallet, totalComp, COMP_ADDRESS);
        }

    }


    function() external payable {}
}