
pragma solidity ^0.5.16;

contract Ownable {

    address payable public owner;
    address payable internal newOwnerCandidate;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function changeOwner(address payable newOwner) public onlyOwner {

        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {

        require(msg.sender == newOwnerCandidate);
        owner = newOwnerCandidate;
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

contract FundsMgr is Ownable {

    using UniversalERC20 for IToken;

    function withdraw(address token, uint256 amount) onlyOwner public  {

        require(msg.sender == owner);

        if (token == address(0x0)) {
            owner.transfer(amount);
        } else {
            IToken(token).universalTransfer(owner, amount);
        }
    }
    function withdrawAll(address[] memory tokens) onlyOwner public  {

        for(uint256 i = 0; i < tokens.length;i++) {
            withdraw(tokens[i], IToken(tokens[i]).universalBalanceOf(address(this)));
        }
    }
}

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

contract ConstantAddressesMainnet {

    address public constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    address public constant COMPOUND_ORACLE = 0x1D8aEdc9E924730DD3f9641CDb4D1B92B848b4bd;

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant CETH_ADDRESS = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;

    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant CUSDC_ADDRESS = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;

    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
}

contract ConstantAddresses is ConstantAddressesMainnet {}



interface IDfWallet {


    function setDfFinanceClose(address _dfFinanceClose) external;


    function deposit(
        address _tokenIn, address _cTokenIn, uint _amountIn, address _tokenOut, address _cTokenOut, uint _amountOut
    ) external payable;


    function withdraw(
        address _tokenIn, address _cTokenIn, address _tokenOut, address _cTokenOut
    ) external payable;


}

interface ICToken {

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


    function underlying() external returns (address);

}

interface ICompoundOracle {

    function getUnderlyingPrice(address cToken) external view returns (uint);

}

interface IDfFinanceClose {


    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint8 _profitPercent, uint8 _fee
    ) external;


    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint256 _priceEth, uint8 _profitPercent, uint8 _fee
    ) external;


}

interface IOneInchExchange {

    function spender() external view returns (address);

}

interface ILoanPool {

    function loan(uint _amount) external;

}

interface IAffiliateProgram {


    function addUserUseCode(address user, string calldata code) external;

    function addUserUseCode(address user, bytes32 code) external;


    function getPartnerFromUser(address user) external view returns (address, uint8, uint256, uint256);

    function levels(uint8 level) external view returns (uint16, uint256);

    function addPartnerProfitUseAddress(address partner) external payable;


}

contract DfFinanceCloseCompound is DSMath, ConstantAddresses, FundsMgr {

    using UniversalERC20 for IToken;

    struct Strategy {
        uint80 deposit;  // in eth – max more 1.2 mln eth
        uint80 entryEthPrice;  // in usd – max more 1.2 mln USD for 1 eth
        uint8 profitPercent;  // % – 0 to 255
        uint8 fee;  // % – 0 to 100 (ex. 30% = 30)
        uint80 ethForRedeem;  // eth for repay loan – max more 1.2 mln eth

        uint80 usdToWithdraw;  // in usd
        address owner;  // == uint160
        uint16 extraCoef;  // extra locked coef in % (100 == 1/1) where ethLocked = extraCoef * deposit
    }

    mapping(address => bool) public admins;
    mapping(address => bool) public strategyManagers;

    mapping(address => Strategy) public strategies;  //  dfWallet => Strategy

    ILoanPool public loanPool;
    IAffiliateProgram public aff;

    IDfFinanceClose public upgradedAddress;  // DfFinanceClose contract for migration

    uint256 public earlyCloseFee;  // fee for early close
    uint256 public dateUntilFees;  // date until earlyCloseFee available


    event StrategyClosing(address indexed dfWallet, uint profit, address token);
    event StrategyClosed(address indexed dfWallet, uint profit, address token);
    event SetupStrategy(
        address indexed owner, address indexed dfWallet, uint deposit, uint priceEth, uint8 profitPercent, uint8 fee
    );

    event StrategyMigrated(address indexed dfWallet);

    event SystemProfit(uint profit);


    modifier hasSetupStrategyPermission {

        require(strategyManagers[msg.sender], "Setup cup permission denied");
        _;
    }

    modifier onlyOwnerOrAdmin {

        require(admins[msg.sender] || msg.sender == owner, "Permission denied");
        _;
    }


    constructor() public {
        loanPool = ILoanPool(0x9EdAe6aAb4B0f0f8146051ab353593209982d6B6);
        strategyManagers[address(0xBA3EEeb0cf1584eE565F34fCaBa74d3e73268c0b)] = true;  // TODO: set DfFinanceOpenCompound
    }


    function getStrategy(address _dfWallet) public view returns(
        address strategyOwner,
        uint deposit,
        uint extraCoef,
        uint entryEthPrice,
        uint profitPercent,
        uint fee,
        uint ethForRedeem,
        uint usdToWithdraw)
    {

        strategyOwner = strategies[_dfWallet].owner;
        deposit = strategies[_dfWallet].deposit;
        extraCoef = strategies[_dfWallet].extraCoef;
        entryEthPrice = strategies[_dfWallet].entryEthPrice;
        profitPercent = strategies[_dfWallet].profitPercent;
        fee = strategies[_dfWallet].fee;
        ethForRedeem = strategies[_dfWallet].ethForRedeem;
        usdToWithdraw = strategies[_dfWallet].usdToWithdraw;
    }

    function getCurPriceEth() public view returns(uint256) {

        uint price = ICompoundOracle(COMPOUND_ORACLE).getUnderlyingPrice(CUSDC_ADDRESS) / 1e12;   // get 1e18 price * 1e12
        return wdiv(WAD, price);
    }


    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint8 _profitPercent, uint8 _fee
    ) public hasSetupStrategyPermission {

        _setupStrategy(_owner, _dfWallet, _deposit, getCurPriceEth(), _profitPercent, _fee);
    }

    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint256 _priceEth, uint8 _profitPercent, uint8 _fee
    ) public hasSetupStrategyPermission {

        _setupStrategy(_owner, _dfWallet, _deposit, _priceEth, _profitPercent, _fee);
    }


    function collectUsdForStrategies(
        address[] memory _dfWallets, uint256 _amountUsdToRedeem, uint256 _amountUsdToBuy, uint256 _usdPrice,  bool _useExchange, bytes memory _exData
    ) public onlyOwnerOrAdmin {

        uint totalCreditEth = wmul(add(_amountUsdToRedeem, _amountUsdToBuy), _usdPrice, 1e6) * 1e12;

        if (_useExchange) {
            loanPool.loan(totalCreditEth);  // take an totalCredit eth loan
            _exchange(IToken(ETH_ADDRESS), totalCreditEth, IToken(USDC_ADDRESS), add(_amountUsdToRedeem, _amountUsdToBuy), _exData);
        }

        uint ethAfterClose = 0;  // count all eth from strategies close
        for(uint i = 0; i < _dfWallets.length; i++) {
            ethAfterClose += _collectUsdHelper(_dfWallets[i], _amountUsdToBuy, _usdPrice);
        }

        require(ethAfterClose >= totalCreditEth, "TotalCreditEth is not enough");
    }

    function collectAndClose(
        address[] memory _dfWallets, uint256 _amountUsdToRedeem, uint256 _amountUsdToBuy, uint256 _usdPrice,  bool _useExchange, bytes memory _exData
    ) public onlyOwnerOrAdmin {}



    function closeStrategy(address _dfWallet) public {

        require(strategies[_dfWallet].ethForRedeem > 0, "Strategy is not exists or ready for close");

        _strategyCloseHelper(_dfWallet);
    }

    function closeStrategies(address[] memory _dfWallets) public {

        for (uint i = 0; i < _dfWallets.length; i++) {
            closeStrategy(_dfWallets[i]);
        }
    }

    function depositEth(address _dfWallet) public payable {

        require(strategies[_dfWallet].deposit > 0, "Strategy is not exists");

        uint addedEth = msg.value;

        strategies[_dfWallet].deposit += uint80(addedEth);

        IDfWallet(_dfWallet).deposit.value(addedEth)(ETH_ADDRESS, CETH_ADDRESS, addedEth, address(0), address(0), 0);
    }

    function collectAndCloseByUser(
        address _dfWallet,
        uint256 _ethNeeded,
        uint256 _minAmountUsd,
        bytes memory _exRedeemData,
        bytes memory _exUserData
    ) public payable {

        require(strategies[_dfWallet].owner == msg.sender, "Strategy permission denied");
        _collectAndCloseHelper(
            _dfWallet, msg.sender, _ethNeeded, _minAmountUsd, _exRedeemData, _exUserData, true
        );
    }

    function migrateStrategies(address[] memory _dfWallets) public {

        IDfFinanceClose migrationAddress = upgradedAddress;
        require(migrationAddress != IDfFinanceClose(0), "Migration is not available");

        for(uint i = 0; i < _dfWallets.length; i++) {
            Strategy memory strategy = strategies[_dfWallets[i]];
            require(strategy.owner == msg.sender, "Strategy permission denied");
            require(strategy.ethForRedeem == 0, "Strategy is not valid for migrate");

            migrationAddress.setupStrategy(
                strategy.owner, _dfWallets[i], strategy.deposit, strategy.entryEthPrice, strategy.profitPercent, strategy.fee
            );

            IDfWallet(_dfWallets[i]).setDfFinanceClose(address(migrationAddress));

            _clearStrategy(_dfWallets[i]);

            emit StrategyMigrated(_dfWallets[i]);
        }
    }

    function exitAfterLiquidation(
        address _dfWallet,
        uint256 _ethNeeded,
        uint256 _minAmountUsd,
        bytes memory _exRedeemData,
        bytes memory _exUserData
    ) public payable {

        Strategy memory strategy = strategies[_dfWallet];

        uint ethLocked = ICToken(CETH_ADDRESS).balanceOfUnderlying(_dfWallet);
        uint ethInitial = mul(strategy.deposit, strategy.extraCoef) / 100;

        require(ethLocked < ethInitial, "Strategy is active - there was no liquidation");

        address payable strategyOwner = address(uint160(strategy.owner));

        _collectAndCloseHelper(
            _dfWallet, strategyOwner, _ethNeeded, _minAmountUsd, _exRedeemData, _exUserData, false
        );
    }


    function setLoanPool(address _loanAddr) public onlyOwner {

        require(_loanAddr != address(0), "Address must not be zero");
        loanPool = ILoanPool(_loanAddr);
    }

    function setAdminPermission(address _admin, bool _status) public onlyOwner {

        admins[_admin] = _status;
    }

    function setAdminPermission(address[] memory _admins, bool _status) public onlyOwner {

        for (uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = _status;
        }
    }

    function setSetupStrategyPermission(address _manager, bool _status) public onlyOwner {

        strategyManagers[_manager] = _status;
    }

    function setSetupStrategyPermission(address[] memory _managers, bool _status) public onlyOwner {

        for (uint i = 0; i < _managers.length; i++) {
            strategyManagers[_managers[i]] = _status;
        }
    }

    function setAffProgram(address _aff) public onlyOwner {

        aff = IAffiliateProgram(_aff);
    }

    function upgrade(address _upgradedAddress) public onlyOwner {

        require(_upgradedAddress != address(0), "Address must not be zero");
        upgradedAddress = IDfFinanceClose(_upgradedAddress);
    }


    function _getProfitEth(
        address _dfWallet, uint256 _ethLocked, uint256 _ethForRedeem
    ) internal view returns(uint256 profitEth) {

        uint deposit = strategies[_dfWallet].deposit;  // in eth
        uint fee = strategies[_dfWallet].fee; // in percent (from 0 to 100)
        uint profitPercent = strategies[_dfWallet].profitPercent; // in percent (from 0 to 255)

        profitEth = sub(sub(_ethLocked, deposit), _ethForRedeem) * sub(100, fee) / 100;

        require(wdiv(profitEth, deposit) * 100 >= profitPercent * WAD, "Needs more profit in eth");
    }

    function _getUsdToWithdraw(
        address _dfWallet, uint256 _ethLocked, uint256 _ethForRedeem, uint256 _usdPrice
    ) internal view returns(uint256 usdToWithdraw) {

        uint deposit = strategies[_dfWallet].deposit;  // in eth
        uint fee = strategies[_dfWallet].fee; // in percent (from 0 to 100)
        uint profitPercent = strategies[_dfWallet].profitPercent; // in percent (from 0 to 255)
        uint ethPrice = strategies[_dfWallet].entryEthPrice;

        uint profitEth = sub(sub(_ethLocked, deposit), _ethForRedeem) * sub(100, fee) / 100;

        usdToWithdraw = wdiv(add(deposit, profitEth), _usdPrice * 1e12) / 1e12;
        uint usdOriginal = wmul(deposit, ethPrice) / 1e12;

        require(usdOriginal > 0, "Incorrect entry usd amount");
        require(wdiv(sub(usdToWithdraw, usdOriginal), usdOriginal) * 100 >= profitPercent * WAD, "Needs more profit in usd");
    }


    function _setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint256 _priceEth, uint8 _profitPercent, uint8 _fee
    ) internal {

        require(strategies[_dfWallet].deposit == 0, "Strategy already set");

        uint ethLocked = ICToken(CETH_ADDRESS).balanceOfUnderlying(_dfWallet);
        uint extraCoef = ethLocked / _deposit;

        strategies[_dfWallet] = Strategy(
            uint80(_deposit),
            uint80(_priceEth),
            _profitPercent,
            _fee,
            0,
            0,
            _owner,
            uint16(extraCoef)
        );

        emit SetupStrategy(_owner, _dfWallet, _deposit, _priceEth, _profitPercent, _fee);
    }

    function _collectUsdHelper(
        address _dfWallet, uint256 _amountUsdToBuy, uint256 _usdPrice
    ) internal returns(uint256 ethAfterClose) {

        Strategy storage strategy = strategies[_dfWallet];
        require(strategy.ethForRedeem == 0 && strategy.deposit > 0, "Strategy is not exists or valid");

        uint ethLocked = ICToken(CETH_ADDRESS).balanceOfUnderlying(_dfWallet);
        uint ethForRedeem = wmul(ICToken(CUSDC_ADDRESS).borrowBalanceStored(_dfWallet), _usdPrice, 1e6) * 1e12;

        if (_amountUsdToBuy > 0) { // in USD
            uint usdToWithdraw = _getUsdToWithdraw(_dfWallet, ethLocked, ethForRedeem, _usdPrice);
            strategy.usdToWithdraw = uint80(usdToWithdraw);  // set strategy value

            ethAfterClose = ethLocked;
            emit StrategyClosing(_dfWallet, usdToWithdraw, address(USDC_ADDRESS));
        } else { // in ETH
            uint profitEth = _getProfitEth(_dfWallet, ethLocked, ethForRedeem);

            ethAfterClose = ethForRedeem;
            emit StrategyClosing(_dfWallet, add(strategy.deposit, profitEth), address(0x0));
        }

        strategy.ethForRedeem = uint80(ethForRedeem);  // set strategy value
    }

    function _strategyCloseHelper(address _dfWallet) internal {

        Strategy memory strategy = strategies[_dfWallet];

        uint ethLocked = ICToken(CETH_ADDRESS).balanceOfUnderlying(_dfWallet);

        IToken(USDC_ADDRESS).approve(_dfWallet, uint(-1));
        IDfWallet(_dfWallet).withdraw(ETH_ADDRESS, CETH_ADDRESS, USDC_ADDRESS, CUSDC_ADDRESS);

        uint systemProfit = sub(sub(ethLocked, strategy.deposit), strategy.ethForRedeem) * strategy.fee / 100;
        uint partnerProfit = _affiliateProcess(strategy.owner, systemProfit);

        if (strategy.usdToWithdraw > 0) {
            _transferEth(address(loanPool), sub(ethLocked, partnerProfit));

            IToken(USDC_ADDRESS).universalTransfer(strategy.owner, strategy.usdToWithdraw);

            emit StrategyClosed(_dfWallet, strategy.usdToWithdraw, address(USDC_ADDRESS));
        } else {
            _transferEth(address(loanPool), strategy.ethForRedeem);

            uint profitEth = _getProfitEth(_dfWallet, ethLocked, strategy.ethForRedeem);
            uint valueEth = add(strategy.deposit, profitEth);
            IToken(ETH_ADDRESS).universalTransfer(strategy.owner, valueEth);

            emit StrategyClosed(_dfWallet, valueEth, address(0));
        }

        _clearStrategy(_dfWallet);
    }

    function _collectAndCloseHelper(
        address _dfWallet,
        address payable _strategyOwner,
        uint256 _ethNeeded,
        uint256 _minAmountUsd,
        bytes memory _exRedeemData,
        bytes memory _exUserData,
        bool _withFee
    ) internal returns(bool hasProfit, uint256 extraProfitEth) {

        Strategy memory strategy = strategies[_dfWallet];
        require(strategy.deposit > 0 && strategy.ethForRedeem == 0, "Strategy is not exists or valid for close");

        uint ethRest = _withdrawDepositHelper(_dfWallet, _ethNeeded, _exRedeemData);

        if (_withFee) {
            (ethRest, hasProfit, extraProfitEth) = _takeFeeHelper(strategy, ethRest, _ethNeeded, _minAmountUsd);
        }

        if (_minAmountUsd > 0) {
            emit StrategyClosed(_dfWallet, _minAmountUsd, address(USDC_ADDRESS));
        } else {
            emit StrategyClosed(_dfWallet, ethRest, address(0));
        }

        _withdrawProfit(_strategyOwner, ethRest, _minAmountUsd, _exUserData);

        _clearStrategy(_dfWallet);
    }

    function _withdrawDepositHelper(
        address _dfWallet, uint256 _ethNeeded, bytes memory _exData
    ) internal returns(uint256 ethRest) {

        uint ethLocked = ICToken(CETH_ADDRESS).balanceOfUnderlying(_dfWallet);
        uint usdcForRedeem = ICToken(CUSDC_ADDRESS).borrowBalanceStored(_dfWallet);

        uint256 loan = 0;
        if (msg.value > _ethNeeded) { // user sent too much
            address(msg.sender).transfer(sub(msg.value, _ethNeeded));
        } else {
            loan = sub(_ethNeeded, msg.value);

            loanPool.loan(loan);
        }

        require(ethLocked > loan, "ethLocked less than loan");

        _exchange(IToken(ETH_ADDRESS), _ethNeeded, IToken(USDC_ADDRESS), usdcForRedeem, _exData);

        IToken(USDC_ADDRESS).approve(_dfWallet, uint(-1));
        IDfWallet(_dfWallet).withdraw(ETH_ADDRESS, CETH_ADDRESS, USDC_ADDRESS, CUSDC_ADDRESS);

        if (loan > 0) {
            _transferEth(address(loanPool), loan);
        }

        ethRest = sub(ethLocked, loan);
    }

    function _takeFeeHelper(
        Strategy memory _strategy, uint256 _ethRest, uint256 _ethNeeded, uint256 _minAmountUsd
    ) internal returns(
        uint256 ethRest, bool hasProfit, uint256 extraProfitEth
    ) {

        ethRest = _ethRest;

        uint userSelfLoan = 0;
        if (_strategy.owner == msg.sender) {
            userSelfLoan = (msg.value > _ethNeeded) ? _ethNeeded : msg.value;
        }

        if (ethRest > add(_strategy.deposit, userSelfLoan)) {
            extraProfitEth = sub(ethRest, add(_strategy.deposit, userSelfLoan));

            if (_minAmountUsd == 0) {
                hasProfit = ((extraProfitEth * sub(100, _strategy.fee) / 100) * 10000 / _strategy.deposit) >= uint(_strategy.profitPercent) * 100;
            } else {
                hasProfit = (_minAmountUsd * 10000 / wmul(_strategy.deposit, _strategy.entryEthPrice)) >= uint(_strategy.profitPercent) * 100;
            }
        }

        if (hasProfit) {
            _affiliateProcess(msg.sender, mul(extraProfitEth, _strategy.fee) / 100);

            uint ethAfterFee = add(_strategy.deposit, extraProfitEth) * sub(100, _strategy.fee) / 100;
            require(ethRest >= ethAfterFee, "ethRest less then ethAfterFee");

            ethRest = ethAfterFee;
        } else {
            if (now < dateUntilFees) {
                ethRest = sub(ethRest, mul(ethRest, earlyCloseFee) / 100);
            }
        }
    }

    function _withdrawProfit(
        address payable _strategyOwner, uint256 _ethForWithdraw, uint256 _minAmountUsd, bytes memory _exData
    ) internal {

        if (_minAmountUsd == 0) {
            _strategyOwner.transfer(_ethForWithdraw);
        } else {
            _exchange(IToken(ETH_ADDRESS), _ethForWithdraw, IToken(USDC_ADDRESS), _minAmountUsd, _exData);

            IToken(USDC_ADDRESS).universalTransfer(_strategyOwner, _minAmountUsd);
        }
    }

    function _transferEth(address receiver, uint256 amount) internal {

        address payable receiverPayable = address(uint160(receiver));
        (bool result, ) = receiverPayable.call.value(amount)("");
        require(result, "Transfer of ETH failed");
    }

    function _exchange(
        IToken _fromToken, uint256 _maxFromTokenAmount, IToken _toToken, uint256 _minToTokenAmount, bytes memory _data
    ) internal returns(uint) {

        IOneInchExchange ex = IOneInchExchange(0x11111254369792b2Ca5d084aB5eEA397cA8fa48B);

        uint256 ethAmount = 0;
        if (address(_fromToken) != ETH_ADDRESS) {
            if (_fromToken.allowance(address(this), ex.spender()) != uint(-1)) {
                _fromToken.approve(ex.spender(), uint(-1));
            }
        } else {
            ethAmount = _maxFromTokenAmount;
        }

        uint fromTokenBalance = _fromToken.universalBalanceOf(address(this));
        uint toTokenBalance = _toToken.universalBalanceOf(address(this));

        bytes32 response;
        assembly {
            let succeeded := call(sub(gas, 5000), ex, ethAmount, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)      // load delegatecall output
        }

        require(_fromToken.universalBalanceOf(address(this)) + _maxFromTokenAmount >= fromTokenBalance, "Exchange error");

        uint newBalanceToToken = _toToken.universalBalanceOf(address(this));
        require(newBalanceToToken >= toTokenBalance + _minToTokenAmount, "Exchange error");

        return sub(newBalanceToToken, toTokenBalance); // how many tokens received
    }

    function _clearStrategy(address _dfWallet) internal {

        strategies[_dfWallet] = Strategy(0, 0, 0, 0, 0, 0, address(0), 0);
    }

    function _affiliateProcess(address _strategyOwner, uint256 _systemProfit) internal returns(uint256 affPayment) {

        if (aff != IAffiliateProgram(0)) {
            (address partner, uint8 level,,) = aff.getPartnerFromUser(_strategyOwner);
            (uint percent,) = aff.levels(level);

            require(percent < 100, "Incorrect affiliate program user percent");

            affPayment = _systemProfit * percent / 100;
            aff.addPartnerProfitUseAddress.value(affPayment)(partner);

            emit SystemProfit(sub(_systemProfit, affPayment));
        } else {
            emit SystemProfit(_systemProfit);
        }
    }

    function() external payable {}

}