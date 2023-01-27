
pragma solidity ^0.5.16;

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

interface IDfFinanceOpen {


    function deal(
        address _walletOwner,
        uint _coef,
        uint _profitPercent,
        bytes calldata _data,
        uint _usdcToBuyEth,
        uint _ethType
    ) external payable
    returns(address dfWallet);


    function dfFinanceClose() external view returns(address dfFinanceClose);


}

interface IDfFinanceClose {


    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint8 _profitPercent, uint8 _fee
    ) external;


    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint256 _priceEth, uint8 _profitPercent, uint8 _fee
    ) external;


    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint256 _priceEth, uint8 _profitPercent, uint8 _fee, uint256 _extraCoef
    ) external;


    function setupStrategy(
        address _owner, address _dfWallet, uint8 _profitPercent, uint8 _fee
    ) external;


    function getStrategy(
        address _dfWallet
    ) external view
    returns(
        address strategyOwner,
        uint deposit,
        uint extraCoef,
        uint entryEthPrice,
        uint profitPercent,
        uint fee,
        uint ethForRedeem,
        uint usdToWithdraw,
        bool onlyProfitInUsd);


    function migrateStrategies(address[] calldata _dfWallets) external;


    function collectAndCloseByUser(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bool _onlyProfitInUsd,
        bytes calldata _exData
    ) external payable;


    function exitAfterLiquidation(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bytes calldata _exData
    ) external payable;


    function depositEth(address _dfWallet) external payable;


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

interface IERC20Burnable {


    function burn(uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;


}

interface IDfProfitToken {


    function initialize(
        string calldata _tokenName,
        string calldata _tokenSymbol,
        address _issuer,
        uint256 _supply
    ) external payable;


}


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


contract CloneFactory {


    function createClone(address target) internal returns (address result) {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }

    function isClone(address target, address query) internal view returns (bool result) {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(clone, 0xa), targetBytes)
            mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
            eq(mload(clone), mload(other)),
            eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
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

contract DfTokenizedStrategy is
    Initializable,
    DSMath,
    OwnableUpgradable,
    CloneFactory
{

    using UniversalERC20 for IToken;

    struct TokenizedStrategy {
        uint80 initialEth;                  // in eth – max more 1.2 mln eth
        uint80 entryEthPrice;               // in usd – max more 1.2 mln USD for 1 eth
        uint8 profitPercent;                // min profit percent
        bool onlyWithProfit;                // strategy can be closed only with profitPercent profit
        bool transferDepositToOwner;        // deposit will be transferred to the owner after closing the strategy
        StrategyClosingType closingType;    // strategy closing type
        bool isStrategyClosed;              // strategy is closed
    }

    enum StrategyClosingType {
        ANY_TYPE,
        ETH,
        USDC,
        ETH_USDC
    }

    address public constant DF_FINANCE_OPEN = address(0xBA3EEeb0cf1584eE565F34fCaBa74d3e73268c0b);      // TODO: DfFinanceOpenCompound address

    address public constant sourceTokenAddress = address(0xaD35DA115Fbd6bB7437222779c4ccBb7411812c1);   // TODO: DfProfitToken address

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    address public profitToken;
    address public dfFinanceClose;

    uint256 public ethInDeposit;

    TokenizedStrategy public strategy;


    event ProfitTokenCreated(
        address indexed profitToken
    );

    event DepositWithdrawn(
        address indexed user,
        uint ethToWithdraw,
        uint usdToWithdraw
    );

    event ProfitWithdrawn(
        address indexed user,
        uint ethToWithdraw,
        uint usdToWithdraw
    );


    modifier onlyDfClose {

        require(msg.sender == dfFinanceClose, "Permission denied");
        _;
    }

    modifier afterStrategyClosed {

        require(strategy.isStrategyClosed, "Strategy is not closed");
        _;
    }


    function initialize(
        string memory _tokenName,
        string memory _tokenSymbol,
        address payable _owner,
        address _issuer,
        bool _onlyWithProfit,
        bool _transferDepositToOwner,
        uint[5] memory _params,     // extraCoef [0], profitPercent [1], usdcToBuyEth [2], ethType [3], closingType [4]
        bytes memory _exchangeData
    ) public payable initializer {

        OwnableUpgradable.initialize(_owner);  // Set owner state

        require(_params[1] > 0, "Profit percent can not be zero");

        uint curDeposit = address(this).balance;

        uint extraEth = mul(curDeposit, sub(_params[0], 100)) / 100;
        uint curEthPrice = wdiv(_params[2] * 1e12, extraEth);

        IDfFinanceOpen(DF_FINANCE_OPEN)
            .deal
            .value(curDeposit)
            (
                address(this),
                _params[0],     // extraCoef
                _params[1],     // profitPercent
                _exchangeData,      // 1inch exchange data
                _params[2],     // usdcToBuyEth
                _params[3]      // ethType
            );

        ethInDeposit = curDeposit;
        strategy = TokenizedStrategy({
            initialEth: uint80(curDeposit),
            entryEthPrice: uint80(curEthPrice),
            profitPercent: uint8(_params[1]),
            onlyWithProfit: _onlyWithProfit,
            transferDepositToOwner: _transferDepositToOwner,
            closingType: StrategyClosingType(_params[4]),
            isStrategyClosed: false
        });
        dfFinanceClose = IDfFinanceOpen(DF_FINANCE_OPEN).dfFinanceClose();

        profitToken = _createToken(_tokenName, _tokenSymbol, _issuer, _params[1], curEthPrice, curDeposit);
    }


    function calculateProfit(address _userAddr) public view returns(
        uint ethToWithdraw,
        uint usdToWithdraw
    ) {

        if (!strategy.isStrategyClosed) {
            return (0, 0);
        }

        uint ethBalance = IToken(ETH_ADDRESS).universalBalanceOf(address(this));
        uint usdBalance = IToken(USDC_ADDRESS).universalBalanceOf(address(this));

        uint tokenTotalSupply = IERC20(profitToken).totalSupply();

        if (ethBalance == 0 && usdBalance == 0 || tokenTotalSupply == 0) {
            return (0, 0);
        }

        uint userTokenBalance = IERC20(profitToken).balanceOf(_userAddr);
        uint userShare = wdiv(userTokenBalance, tokenTotalSupply);

        ethToWithdraw = wmul(ethBalance, userShare);
        usdToWithdraw = wmul(usdBalance * 1e12, userShare) / 1e12;
    }


    function withdrawProfit() public afterStrategyClosed {

        _withdrawProfitHelper(msg.sender);
    }

    function withdrawProfit(address[] memory _accounts) public afterStrategyClosed {

        for (uint i = 0; i < _accounts.length; i++) {
           _withdrawProfitHelper(_accounts[i]);
        }
    }


    function collectAndCloseByUser(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bool _onlyProfitInUsd,
        bytes memory _exData
    ) public payable onlyOwner {


        IDfFinanceClose(dfFinanceClose)
            .collectAndCloseByUser
            .value(msg.value)
            (
                _dfWallet,
                _ethForRedeem,
                _minAmountUsd,
                _onlyProfitInUsd,
                _exData
            );

    }

    function depositEth(address _dfWallet) public payable onlyOwner {

        (address strategyOwner,,,,,,,,) = IDfFinanceClose(dfFinanceClose).getStrategy(_dfWallet);
        require(address(this) == strategyOwner, "Incorrect dfWallet address");

        uint ethAmount = msg.value;

        IDfFinanceClose(dfFinanceClose)
            .depositEth
            .value(ethAmount)
            (
                _dfWallet
            );

        ethInDeposit = add(ethInDeposit, ethAmount);
    }

    function migrateStrategies(address[] memory _dfWallets) public onlyOwner {

        IDfFinanceClose(dfFinanceClose).migrateStrategies(_dfWallets);
    }

    function exitAfterLiquidation(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bytes memory _exData
    ) public payable onlyOwner {


        IDfFinanceClose(dfFinanceClose)
            .exitAfterLiquidation
            .value(msg.value)
            (
                _dfWallet,
                _ethForRedeem,
                _minAmountUsd,
                _exData
            );

    }

    function externalCall(address payable _to, bytes memory _data) public payable onlyOwner {

        uint ethAmount = msg.value;
        bytes32 response;

        assembly {
            let succeeded := call(sub(gas, 5000), _to, ethAmount, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)
            switch iszero(succeeded)
            case 1 {
                revert(0, 0)
            }
        }
    }


    function __callback(
        bool _isStrategyClosed,
        uint _closingType
    ) external
        onlyDfClose
    returns(
            bool success
    ) {

        if (strategy.closingType != StrategyClosingType.ANY_TYPE ||
            strategy.closingType != StrategyClosingType(_closingType)
        ) {
            return false;
        }

        if (_isStrategyClosed) {
            if (strategy.onlyWithProfit && !_isProfitable()) {
                return false;
            }

            strategy.isStrategyClosed = true;

            if (strategy.transferDepositToOwner) {
                _withdrawDeposit();
            }
        }

        return true;
    }


    function _isProfitable() internal view returns(bool) {


        (uint ethDeposit, uint usdDeposit, ) = _calculateWithdrawalOnDeposit();

        uint ethBalance = sub(IToken(ETH_ADDRESS).universalBalanceOf(address(this)), ethDeposit);
        uint usdBalance = sub(IToken(USDC_ADDRESS).universalBalanceOf(address(this)), usdDeposit);

        uint targetProfitEth = wmul(strategy.initialEth, WAD * strategy.profitPercent / 100);
        uint targetProfitUsd = IERC20(profitToken).totalSupply() / 1e12;  // 1 profit token == 1 USD

        if (ethBalance >= targetProfitEth || usdBalance >= targetProfitUsd) {
            return true;
        }

        return false;
    }

    function _calculateWithdrawalOnDeposit() internal view returns(
        uint ethToWithdraw,
        uint usdToWithdraw,
        uint depositEth     // rest deposit in eth after this withdrawal
    ) {

        depositEth = ethInDeposit;
        if (depositEth == 0) {
            return (0, 0, 0);
        }

        uint ethBalance = IToken(ETH_ADDRESS).universalBalanceOf(address(this));
        uint usdBalance = IToken(USDC_ADDRESS).universalBalanceOf(address(this));

        if (ethBalance >= depositEth) {
            ethToWithdraw = depositEth;
        } else if (ethBalance > 0) {
            ethToWithdraw = ethBalance;
        }

        if (ethToWithdraw > 0) {
            depositEth = sub(depositEth, ethToWithdraw);
        }

        if (depositEth > 0) {
            uint ethPrice = strategy.entryEthPrice;
            uint depositUsd = wmul(depositEth, ethPrice) / 1e12;  // rest deposit in USDC

            if (usdBalance >= depositUsd) {
                usdToWithdraw = depositUsd;
            } else if (usdBalance > 0) {
                usdToWithdraw = usdBalance;
            }

            if (usdToWithdraw > 0) {
                depositUsd = sub(depositUsd, usdToWithdraw);
                depositEth = wdiv(depositUsd * 1e12, ethPrice);
            }
        }
    }


    function _createToken(
        string memory _tokenName,
        string memory _tokenSymbol,
        address _issuer,
        uint _profitPercent,
        uint _curEthPrice,
        uint _curDeposit
    ) internal returns (
        address tokenAddr
    ) {

        uint tokensPerEth = wmul(mul(_profitPercent, WAD) / 100, _curEthPrice);  // number of tokens for profit distribution per 1 eth

        tokenAddr = createClone(sourceTokenAddress);
        IDfProfitToken(tokenAddr)
            .initialize
            (
                _tokenName,
                _tokenSymbol,
                _issuer,
                wmul(_curDeposit, tokensPerEth)     // total supply
            );

        emit ProfitTokenCreated(tokenAddr);
    }

    function _withdrawDeposit() internal {

        (uint ethToWithdraw, uint usdToWithdraw, uint restDepositEth) = _calculateWithdrawalOnDeposit();

        ethInDeposit = restDepositEth;

        address userAddr = owner;
        _withdrawHelper(userAddr, ethToWithdraw, usdToWithdraw);

        emit DepositWithdrawn(userAddr, ethToWithdraw, usdToWithdraw);
    }

    function _withdrawProfitHelper(address _userAddr) internal {

        uint tokenBalance = IERC20(profitToken).balanceOf(_userAddr);

        if (tokenBalance == 0) {
            return;  // User has no tokens to burn
        }

        (uint ethToWithdraw, uint usdToWithdraw) = calculateProfit(_userAddr);

        _burnTokensHelper(_userAddr, tokenBalance);

        _withdrawHelper(_userAddr, ethToWithdraw, usdToWithdraw);

        emit ProfitWithdrawn(_userAddr, ethToWithdraw, usdToWithdraw);
    }

    function _burnTokensHelper(address _userAddr, uint _amountToBurn) internal {

        IERC20Burnable(profitToken).burnFrom(_userAddr, _amountToBurn);
    }

    function _withdrawHelper(
        address _user, uint _ethToWithdraw, uint _usdToWithdraw
    ) internal {

        if (_ethToWithdraw > 0) {
            IToken(ETH_ADDRESS).universalTransfer(_user, _ethToWithdraw, true);
        }

        if (_usdToWithdraw > 0) {
            IToken(USDC_ADDRESS).universalTransfer(_user, _usdToWithdraw);
        }
    }

    function() external payable {}

}