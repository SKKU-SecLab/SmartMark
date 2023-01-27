
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


library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


contract SignatureHelper {



    bytes2 constant internal EIP191_HEADER = 0x1901;

    string constant internal EIP712_DOMAIN_NAME = "DF.Help";

    string constant internal EIP712_DOMAIN_VERSION = "1.0";

    bytes32 constant internal EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "uint256 chainId,",
        "address verifyingContract",
        ")"
    ));
}

contract OpenSignatureLogic is SignatureHelper {



    bytes32 constant internal EIP712_DEAL_STRUCT_SCHEMA_HASH = keccak256(abi.encodePacked(
        "DealUsdSignature(",
        "uint256 coefficient,",
        "uint256 profitPercent,",
        "uint256 valueUsdc,",
        "uint256 minEntryEthPrice,",
        "uint256 maxEntryEthPrice,",
        "uint256 expireTime,",
        "uint256 signNonce,",
        ")"
    ));

    bytes32 constant public EIP712_DOMAIN_HASH = keccak256(abi.encode(
        EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
        keccak256(bytes(EIP712_DOMAIN_NAME)),
        keccak256(bytes(EIP712_DOMAIN_VERSION)),
        1,
        address(0xBA3EEeb0cf1584eE565F34fCaBa74d3e73268c0b)  // TODO: set deployed contract
    ));





    function _getDealHash(
        uint[7] memory _params
    )
        internal
        pure
        returns(bytes32)
    {

        bytes32 structHash = keccak256(abi.encodePacked(
            EIP712_DEAL_STRUCT_SCHEMA_HASH,
            _params[0],  // coefficient
            _params[1],  // profitPercent
            _params[2],  // valueUsdc
            _params[3],  // minEntryEthPrice
            _params[4],  // maxEntryEthPrice
            _params[5],  // expireTime
            _params[6]   // signNonce
        ));

        return keccak256(abi.encodePacked(
            EIP191_HEADER,
            EIP712_DOMAIN_HASH,
            structHash
        ));
    }
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

contract FundsMgrUpgradable is Initializable, OwnableUpgradable {

    using UniversalERC20 for IToken;

    function initialize() public initializer {

        OwnableUpgradable.initialize();  // Initialize Parent Contract
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

interface IGST2 {

	function freeUpTo(uint256 value) external returns(uint256 freed);

	function freeFromUpTo(address from, uint256 value) external returns(uint256 freed);

    function balanceOf(address account) external view returns (uint256);

}

contract GasTokenSpender {


    address public constant GAS_TOKEN = 0x0000000000b3F879cb30FE243b4Dfee438691c04;


    function gasTokenBalance() public view returns(uint256 amount) {

        amount = IGST2(GAS_TOKEN).balanceOf(address(this));
    }


    function _burnGasToken(uint256 gasSpent) internal returns(bool) {

        uint maxTokens = gasTokenBalance();
        if (maxTokens == 0) {
            return false;
        }

        uint tokensToBurn = (gasSpent + 14154) / 41130;
        if (tokensToBurn > maxTokens) {
            tokensToBurn = maxTokens;
        }

        IGST2(GAS_TOKEN).freeUpTo(tokensToBurn);

        return true;
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



interface IDfWalletFactory {

    function createDfWallet() external returns (address dfWallet);

}

interface ICompoundOracle {

    function getUnderlyingPrice(address cToken) external view returns (uint);

}

interface IComptroller {

    function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);


    function exitMarket(address cToken) external returns (uint256);


    function getAssetsIn(address account) external view returns (address[] memory);


    function getAccountLiquidity(address account) external view returns (uint256, uint256, uint256);


    function markets(address cTokenAddress) external view returns (bool, uint);

}

interface IDfWallet {


    function setDfFinanceClose(address _dfFinanceClose) external;


    function deposit(
        address _tokenIn, address _cTokenIn, uint _amountIn, address _tokenOut, address _cTokenOut, uint _amountOut
    ) external payable;


    function withdraw(
        address _tokenIn, address _cTokenIn, address _tokenOut, address _cTokenOut
    ) external payable;


}

interface IDfProxyBetCompound {

    function insure(address beneficiary, address wallet, uint256 amountUsd) external;

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

interface ILoanPool {

    function loan(uint _amount) external;

}

interface IProxyOneInchExchange {

    function exchange(IToken fromToken, uint256 amountFromToken, bytes calldata _data) external;

}

interface IAffiliateProgram {


    function getProfitPercentByReferral(address referral) external view returns (uint8);


    function addReferral(address referral, bytes32 code, uint256 ethValue) external;

    function distributeProfitByReferral(address referral) external payable;



    function addUserUseCode(address user, string calldata code) external;

    function getPartnerFromUser(address user) external view returns (address, uint8, uint256, uint256);

    function levels(uint8 level) external view returns (uint16, uint256);

    function addPartnerProfitUseAddress(address partner) external payable;


}

contract DfFinanceOpenCompound is
    Initializable,
    DSMath,
    ConstantAddresses,
    OpenSignatureLogic,
    GasTokenSpender,
    FundsMgrUpgradable
{

    using ECDSA for bytes32;

    uint256 public inFee;
    uint256 public currentFeeForBonusEther;

    IDfProxyBetCompound public proxyInsuranceBet;
    uint256 public insuranceCoef;  // in percent

    ILoanPool public loanPool;

    IDfWalletFactory public dfWalletFactory;
    IDfFinanceClose public dfFinanceClose;

    IAffiliateProgram public aff;

    mapping(address => bool) public admins;

    mapping(address => mapping(uint256 => bool)) public signedNonces;


    event AfterExchangeRefund(address indexed user, uint ethToRefund, uint usdToRefund);


    modifier useGasToken {

        uint gasProvided = gasleft();
        _;
        _burnGasToken(sub(gasProvided, gasleft()));
    }

    modifier onlyOwnerOrAdmin {

        require(admins[msg.sender] || msg.sender == owner, "Permission denied");
        _;
    }

    modifier onlyVerified(
        address _walletOwner,
        bytes memory _signature,    // signature is v, r, s for ECDSA
        uint[9] memory _params      // coef [0], profitPercent [1], valueUsdc [2],
    ) {

        require(
            isDealUsdVerified(
                _walletOwner, _signature,
                [_params[0], _params[1], _params[2], _params[3], _params[4], _params[5], _params[6], _params[7]]
            ), "This deal with USD is not verified"
        );

        signedNonces[_walletOwner][_params[7]] = true;
        _;
    }


    function initialize() public initializer {

        FundsMgrUpgradable.initialize();  // Initialize Parent Contract

        inFee = 0;
        currentFeeForBonusEther = 30;

        loanPool = ILoanPool(0x9EdAe6aAb4B0f0f8146051ab353593209982d6B6);
        proxyInsuranceBet = IDfProxyBetCompound(0);
        insuranceCoef = 0;
    }


    function getMaxBorrow(address _cBorrowToken, address _wallet) public view returns (uint) {

        (, uint liquidityInEth, ) = IComptroller(COMPTROLLER).getAccountLiquidity(_wallet);

        if (_cBorrowToken == CETH_ADDRESS) {
            return liquidityInEth;
        }

        uint ethPrice = ICompoundOracle(COMPOUND_ORACLE).getUnderlyingPrice(_cBorrowToken);
        uint liquidityInToken = wdiv(liquidityInEth, ethPrice);

        return sub(liquidityInToken, 100); // cut off 100 wei to handle rounding issues
    }

    function getBorrowUsdcBalance(address _dfWallet) public view returns(uint amount) {

        amount = ICToken(CUSDC_ADDRESS).borrowBalanceStored(_dfWallet);
    }

    function isDealUsdVerified(
        address _addr,
        bytes memory _signature,    // signature is v, r, s for ECDSA
        uint[8] memory _params      // coef [0], profitPercent [1], valueUsdc [2],
    ) public view returns(bool) {

        require(_params[4] <= _params[5], "minEntryEthPrice must be less than or equal to maxEntryEthPrice");

        if (now > _params[6] ||
            signedNonces[_addr][_params[7]]) {
            return false;
        }

        if (_params[3] < _params[4] || _params[3] > _params[5]) {
            return false;
        }

        bytes32 hash = _getDealHash(
            [_params[0], _params[1], _params[2], _params[4], _params[5], _params[6], _params[7]]
        );

        return (
            _addr == hash.recover(_signature)
        );
    }


    function deal(
        address _walletOwner,
        uint _coef,
        uint _profitPercent,
        bytes memory _data,
        uint _usdcToBuyEth,
        uint _ethType
    ) public payable
        useGasToken
    returns(
        address dfWallet
    ) {

        dfWallet = dealInternal(_walletOwner == address(0) ? msg.sender : _walletOwner,
                                    _profitPercent, _coef, msg.value, _data, _usdcToBuyEth, _ethType);
    }

    function dealWithPromo(
        address _walletOwner,
        uint _coef,
        uint _profitPercent,
        bytes memory _data,
        uint _usdcToBuyEth,
        uint _ethType,
        bytes32 _promoCode
    ) public payable
        useGasToken
    returns(
        address dfWallet
    ) {

        uint valueEth = msg.value;

        dfWallet = dealInternal(_walletOwner == address(0) ? msg.sender : _walletOwner,
                                    _profitPercent, _coef, valueEth, _data, _usdcToBuyEth, _ethType);

        aff.addReferral(_walletOwner, _promoCode, valueEth);
    }

    function dealUsd(
        address _walletOwner,
        uint _coef,
        uint _profitPercent,
        uint _valueUsdc,
        uint _entryEthPrice,
        uint _ethType,
        bytes memory _exData  // data for 1inch exchange
    ) public payable
        useGasToken
    returns(
        address dfWallet
    ) {

        dfWallet = dealUsdInternal(
            _walletOwner, _profitPercent, _coef, _valueUsdc, _entryEthPrice, _exData, _ethType
        );
    }

    function dealUsdPromo(
        address _walletOwner,
        uint _coef,
        uint _profitPercent,
        uint _valueUsdc,
        uint _entryEthPrice,
        uint _ethType,
        bytes memory _exData, // data for 1inch exchange
        bytes32 _promoCode
    ) public payable
        useGasToken
    returns(
        address dfWallet
    ) {


        dfWallet = dealUsdInternal(
            _walletOwner, _profitPercent, _coef, _valueUsdc, _entryEthPrice, _exData, _ethType
        );

        uint valueEth = wdiv(_valueUsdc * 1e12, _entryEthPrice);  // valueUsdc in eth

        aff.addReferral(_walletOwner, _promoCode, valueEth);

    }

    function createEmptyStrategy(
        address _walletOwner,
        uint _profitPercent
    ) public returns(
        address dfWallet
    ) {

        dfWallet = createDfWalletInternal();

        dfFinanceClose.setupStrategy(
            _walletOwner, dfWallet, uint8(_profitPercent), uint8(currentFeeForBonusEther)
        );
    }

    function cancelSign(uint _signNonce) public returns(bool) {

        signedNonces[msg.sender][_signNonce] = true;
        return true;
    }


    function dealUsdWithSign(
        address _walletOwner,
        bytes memory _signature,    // signature is v, r, s for ECDSA
        uint[9] memory _params,     // coef [0], profitPercent [1], valueUsdc [2],
        bytes memory _exData        // data for 1inch exchange
    ) public payable
        useGasToken
        onlyOwnerOrAdmin
        onlyVerified(_walletOwner, _signature, _params)
    returns(
        address dfWallet
    ) {

        dfWallet = dealUsdInternal(
            _walletOwner, _params[1], _params[0], _params[2], _params[3], _exData, _params[8]
        );
    }

    function dealUsdPromoWithSign(
        address _walletOwner,
        bytes memory _signature,    // signature is v, r, s for ECDSA
        uint[9] memory _params,     // coef [0], profitPercent [1], valueUsdc [2],
        bytes memory _exData,       // data for 1inch exchange,
        bytes32 _promoCode
    ) public payable
        useGasToken
        onlyOwnerOrAdmin
        onlyVerified(_walletOwner, _signature, _params)
    returns(
        address dfWallet
    ) {


        dfWallet = dealUsdInternal(
            _walletOwner, _params[1], _params[0], _params[2], _params[3], _exData, _params[8]
        );

        uint valueEth = wdiv(_params[2] * 1e12, _params[3]);  // valueUsdc in eth

        aff.addReferral(_walletOwner, _promoCode, valueEth);
    }


    function setAdminPermission(address _admin, bool _status) public onlyOwner {

        admins[_admin] = _status;
    }

    function setAdminPermission(address[] memory _admins, bool _status) public onlyOwner {

        for (uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = _status;
        }
    }

    function setLoanPool(address _loanAddr) public onlyOwner {

        require(_loanAddr != address(0), "Address must not be zero");
        loanPool = ILoanPool(_loanAddr);
    }

    function setDfWalletFactory(address _dfWalletFactory) public onlyOwner {

        require(_dfWalletFactory != address(0), "Address must not be zero");
        dfWalletFactory = IDfWalletFactory(_dfWalletFactory);
    }

    function setDfFinanceClose(address _dfFinanceClose) public onlyOwner {

        require(_dfFinanceClose != address(0), "Address must not be zero");
        dfFinanceClose = IDfFinanceClose(_dfFinanceClose);
    }

    function setDfProxyBetAddress(IDfProxyBetCompound _proxyBet, uint256 _insuranceCoef) public onlyOwner {

        require(address(_proxyBet) != address(0) && _insuranceCoef > 0 ||
                address(_proxyBet) == address(0) && _insuranceCoef == 0, "Incorrect proxy address or insurance coefficient");

        proxyInsuranceBet = _proxyBet;
        insuranceCoef = _insuranceCoef;  // in percent (5 == 5%)

        IToken(USDC_ADDRESS).approve(address(_proxyBet), uint(-1));
    }

    function setFees(uint _inFee, uint _currentFeeForBonusEther) public onlyOwner {

        require(_inFee <= 5 && _currentFeeForBonusEther < 100, "Invalid fees");
        inFee = _inFee;
        currentFeeForBonusEther = _currentFeeForBonusEther;
    }

    function setAffProgram(address _aff) public onlyOwner {

        aff = IAffiliateProgram(_aff);
    }


    function dealInternal(
        address _walletOwner,
        uint _profitPercent,
        uint _coef,
        uint _valueEth,
        bytes memory _data,
        uint _usdcToBuyEth,
        uint _ethType
    ) internal returns(address dfWallet) {

        require(_coef >= 150 && _coef <= 300, "Invalid coefficient");

        uint extraEth = _valueEth * (_coef - 100) / 100;

        loanPool.loan(extraEth);

        uint usdcForExtract = _usdcToBuyEth * (100 + inFee + insuranceCoef) / 100;
        dfWallet = depositInternal(add(_valueEth, extraEth), usdcForExtract);

        if (address(proxyInsuranceBet) != address(0)) {
            proxyInsuranceBet.insure(_walletOwner, dfWallet, _usdcToBuyEth * insuranceCoef / 100);
        }

        exchangeInternal(
            IToken(USDC_ADDRESS),
            _usdcToBuyEth,
            _ethType == 0 ? IToken(WETH_ADDRESS) : IToken(ETH_ADDRESS),
            extraEth,
            _data
        );

        if (_ethType == 0) {
            IToken(WETH_ADDRESS).withdraw(IToken(WETH_ADDRESS).balanceOf(address(this)));
        }

        dfFinanceClose.setupStrategy(
            _walletOwner, dfWallet, _valueEth, wdiv(_usdcToBuyEth * 1e12, extraEth), uint8(_profitPercent), uint8(currentFeeForBonusEther)
        );

        paybackLoanInternal(_walletOwner, extraEth);
    }

    function dealUsdInternal(
        address _walletOwner,
        uint _profitPercent,
        uint _coef,
        uint _valueUsdc,
        uint _entryEthPrice,
        bytes memory _data,
        uint _ethType
    ) internal returns(address dfWallet) {

        require(_walletOwner != address(0), "Address must not be zero");
        require(_coef >= 150 && _coef <= 300, "Invalid coefficient");

        IToken(USDC_ADDRESS).universalTransferFrom(_walletOwner, address(this), _valueUsdc);

        uint extraUsdc = _valueUsdc * (_coef - 100) / 100;
        uint totalUsdcForLoanEth = add(_valueUsdc, extraUsdc);

        uint totalLoanEth = wdiv(totalUsdcForLoanEth * 1e12, _entryEthPrice);
        loanPool.loan(totalLoanEth);

        dfWallet = depositInternal(totalLoanEth, extraUsdc * (100 + inFee + insuranceCoef) / 100);

        if (address(proxyInsuranceBet) != address(0)) {
            proxyInsuranceBet.insure(_walletOwner, dfWallet, extraUsdc * insuranceCoef / 100);
        }

        exchangeInternal(
            IToken(USDC_ADDRESS),
            totalUsdcForLoanEth,
            _ethType == 0 ? IToken(WETH_ADDRESS) : IToken(ETH_ADDRESS),
            totalLoanEth,
            _data
        );

        if (_ethType == 0) {
            IToken(WETH_ADDRESS).withdraw(IToken(WETH_ADDRESS).balanceOf(address(this)));
        }

        dfFinanceClose.setupStrategy(
            _walletOwner, dfWallet, wdiv(_valueUsdc * 1e12, _entryEthPrice), _entryEthPrice, uint8(_profitPercent), uint8(currentFeeForBonusEther)
        );

        paybackLoanInternal(_walletOwner, totalLoanEth);
    }

    function paybackLoanInternal(
        address _userAddr, uint256 _loanEth
    ) internal {


        uint ethForPayback = sub(address(this).balance, _loanEth);
        uint usdForPayback = IToken(USDC_ADDRESS).balanceOf(address(this));

        if (ethForPayback > tx.gasprice * 21000 * 2) {
            IToken(ETH_ADDRESS).universalTransfer(_userAddr, ethForPayback);
        } else {
            ethForPayback = 0;
        }

        if (usdForPayback > 0.5e6) {
            IToken(USDC_ADDRESS).universalTransfer(_userAddr, usdForPayback);
        } else {
            usdForPayback = 0;
        }

        transferEthInternal(address(loanPool), _loanEth);

        emit AfterExchangeRefund(_userAddr, ethForPayback, usdForPayback);
    }

    function depositInternal(
        uint256 ethToDeposit, uint256 usdcForExtract
    ) internal returns(address dfWallet) {

        dfWallet = createDfWalletInternal();

        IDfWallet(dfWallet).deposit.value(ethToDeposit)(
            ETH_ADDRESS, CETH_ADDRESS, ethToDeposit, USDC_ADDRESS, CUSDC_ADDRESS, usdcForExtract
        );

        uint maxBorrowUsdc = getMaxBorrow(CUSDC_ADDRESS, dfWallet);
        require(maxBorrowUsdc > 0 && (maxBorrowUsdc * 100 / (maxBorrowUsdc + usdcForExtract) >= 15), "Needs more eth in collateral");
    }

    function createDfWalletInternal() internal returns(address dfWallet) {

        dfWallet = dfWalletFactory.createDfWallet();

        IDfWallet(dfWallet).setDfFinanceClose(address(dfFinanceClose));
    }

    function exchangeInternal(
        IToken _fromToken, uint _maxFromTokenAmount, IToken _toToken, uint _minToTokenAmount, bytes memory _data
    ) internal returns(uint) {

        IProxyOneInchExchange proxyEx = IProxyOneInchExchange(0x3fF9Cc22ef2bF6de5Fd2E78f511EDdF0813f6B36);

        if (_fromToken.allowance(address(this), address(proxyEx)) != uint256(-1)) {
            _fromToken.approve(address(proxyEx), uint256(-1));
        }

        uint fromTokenBalance = _fromToken.universalBalanceOf(address(this));
        uint toTokenBalance = _toToken.universalBalanceOf(address(this));

        proxyEx.exchange(_fromToken, _maxFromTokenAmount, _data);

        require(_fromToken.universalBalanceOf(address(this)) + _maxFromTokenAmount >= fromTokenBalance, "Exchange error");

        uint newBalanceToToken = _toToken.universalBalanceOf(address(this));
        require(newBalanceToToken >= toTokenBalance + _minToTokenAmount, "Exchange error");

        return sub(newBalanceToToken, toTokenBalance); // how many tokens received
    }

    function transferEthInternal(address _receiver, uint _amount) internal {

        address payable receiverPayable = address(uint160(_receiver));
        (bool result, ) = receiverPayable.call.value(_amount)("");
        require(result, "Transfer of ETH failed");
    }

    function() external payable {}

}