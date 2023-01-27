

pragma solidity ^0.5.9;


interface IERC20Token {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address _owner) external view returns (uint256);


    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);


    function approve(address _spender, uint256 _value) external returns (bool);

}


pragma solidity ^0.5.9;

contract AuctionRegisteryContracts {

    bytes32 internal constant MAIN_TOKEN = "MAIN_TOKEN";
    bytes32 internal constant ETN_TOKEN = "ETN_TOKEN";
    bytes32 internal constant STOCK_TOKEN = "STOCK_TOKEN";
    bytes32 internal constant WHITE_LIST = "WHITE_LIST";
    bytes32 internal constant AUCTION = "AUCTION";
    bytes32 internal constant AUCTION_PROTECTION = "AUCTION_PROTECTION";
    bytes32 internal constant LIQUIDITY = "LIQUIDITY";
    bytes32 internal constant CURRENCY = "CURRENCY";
    bytes32 internal constant VAULT = "VAULT";
    bytes32 internal constant CONTRIBUTION_TRIGGER = "CONTRIBUTION_TRIGGER";
    bytes32 internal constant COMPANY_FUND_WALLET = "COMPANY_FUND_WALLET";
    bytes32 internal constant SMART_SWAP = "SMART_SWAP";
    bytes32 internal constant SMART_SWAP_P2P = "SMART_SWAP_P2P";
    bytes32 internal constant ESCROW = "ESCROW";
}

interface IAuctionRegistery {

    function getAddressOf(bytes32 _contractName)
        external
        view
        returns (address payable);

}


pragma solidity ^0.5.9;



contract LiquidityStorage {

    bytes32 internal constant BANCOR_FORMULA = "BancorFormula";
    bytes32 internal constant BANCOR_NETWORK = "BancorNetwork";
    uint256 public constant BIG_NOMINATOR = 10**24;
    uint256 public constant DECIMAL_NOMINATOR = 10**18;
    uint256 public constant PRICE_NOMINATOR = 10**9;

    address public converter;

    address public bancorNetwork;

    address public baseToken; // basetoken

    address public mainToken; // maintoken

    address public relayToken; // relayToken

    address public etherToken; // etherToken

    address public ethRelayToken; // ether to baseToken RelayToken

    IAuctionRegistery public contractsRegistry;

    address payable public whiteListAddress;
    address payable public vaultAddress;
    address payable public auctionAddress;
    address payable public triggerAddress;
    address payable public currencyPricesAddress;
    address payable public escrowAddress;

    address[] public ethToMainToken;
    address[] public baseTokenToMainToken;
    address[] public mainTokenTobaseToken;
    address[] public ethToBaseToken;
    address[] public baseTokenToEth;

    IERC20Token[] public relayPath;

    uint256[] public returnAmountRelay;

    uint256 public sideReseverRatio;

    uint256 public tagAlongRatio;

    uint256 public appreciationLimit;

    uint256 public appreciationLimitWithDecimal;

    uint256 public reductionStartDay;

    uint256 public baseTokenVolatiltyRatio;

    uint256 public virtualReserverDivisor;

    uint256 public previousMainReserveContribution;

    uint256 public todayMainReserveContribution;

    uint256 public tokenAuctionEndPrice;

    uint256 public lastReserveBalance;

    uint256 public baseLinePrice;

    uint256 public maxIteration;

    bool public isAppreciationLimitReached;

    uint256 public relayPercent;

    mapping(address => uint256) public lastReedeemDay;

    event Contribution(address _token, uint256 _amount, uint256 returnAmount);
    event RecoverPrice(uint256 _oldPrice, uint256 _newPrice);
    event Redemption(address _token, uint256 _amount, uint256 returnAmount);
    event FundDeposited(address _token, address indexed _from, uint256 _amount);
}


pragma solidity ^0.5.9;

contract SafeMath {

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function safeExponent(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 result;
        assembly {
            result := exp(a, b)
        }
        return result;
    }

    function nthRoot(
        uint256 _a,
        uint256 _n,
        uint256 _dp,
        uint256 _maxIts
    ) internal pure returns (uint256) {

        assert(_n > 1);

        uint256 one = 10**(1 + _dp);
        uint256 a0 = one**_n * _a;

        uint256 xNew = one;
        uint256 x;

        uint256 iter = 0;
        while (xNew != x && iter < _maxIts) {
            x = xNew;
            uint256 t0 = x**(_n - 1);
            if (x * t0 > a0) {
                xNew = x - (x - a0 / t0) / _n;
            } else {
                xNew = x + (a0 / t0 - x) / _n;
            }
            ++iter;
        }

        return (xNew + 5) / 10;
    }
}


pragma solidity ^0.5.9;

contract Constant {

    string constant ERR_CONTRACT_SELF_ADDRESS = "ERR_CONTRACT_SELF_ADDRESS";

    string constant ERR_ZERO_ADDRESS = "ERR_ZERO_ADDRESS";

    string constant ERR_NOT_OWN_ADDRESS = "ERR_NOT_OWN_ADDRESS";

    string constant ERR_VALUE_IS_ZERO = "ERR_VALUE_IS_ZERO";

    string constant ERR_SAME_ADDRESS = "ERR_SAME_ADDRESS";

    string constant ERR_AUTHORIZED_ADDRESS_ONLY = "ERR_AUTHORIZED_ADDRESS_ONLY";

    modifier notOwnAddress(address _which) {

        require(msg.sender != _which, ERR_NOT_OWN_ADDRESS);
        _;
    }

    modifier notZeroAddress(address _which) {

        require(_which != address(0), ERR_ZERO_ADDRESS);
        _;
    }

    modifier notThisAddress(address _which) {

        require(_which != address(this), ERR_CONTRACT_SELF_ADDRESS);
        _;
    }

    modifier notZeroValue(uint256 _value) {

        require(_value > 0, ERR_VALUE_IS_ZERO);
        _;
    }
}


pragma solidity ^0.5.9;



contract ProxyOwnable is Constant {

    
    address public primaryOwner;

    address public authorityAddress;

    address public newAuthorityAddress;

    address public systemAddress;
    
    bool public isOwnerInitialize = false;

    event OwnershipTransferred(
        string ownerType,
        address indexed previousOwner,
        address indexed newOwner
    );
    
    event AuthorityAddressChnageCall(
        address indexed previousOwner,
        address indexed newOwner
    );


    function initializeOwner(
        address _primaryOwner,
        address _systemAddress,
        address _authorityAddress
    ) internal notZeroAddress(_primaryOwner) notZeroAddress(_systemAddress) notZeroAddress(_authorityAddress) {

        
        require(!isOwnerInitialize,"ERR_OWNER_INTIALIZED_ALREADY");
        
        require(_primaryOwner != _systemAddress, ERR_SAME_ADDRESS);
        
        require(_systemAddress != _authorityAddress, ERR_SAME_ADDRESS);
        
        require(_primaryOwner != _authorityAddress, ERR_SAME_ADDRESS);
        
        primaryOwner = _primaryOwner;
        systemAddress = _systemAddress;
        authorityAddress = _authorityAddress;
        isOwnerInitialize = true;
    }

    modifier onlyOwner() {

        require(msg.sender == primaryOwner, ERR_AUTHORIZED_ADDRESS_ONLY);
        _;
    }

    modifier onlySystem() {

        require(msg.sender == systemAddress, ERR_AUTHORIZED_ADDRESS_ONLY);
        _;
    }

    modifier onlyOneOfOnwer() {

        require(
            msg.sender == primaryOwner || msg.sender == systemAddress,
            ERR_AUTHORIZED_ADDRESS_ONLY
        );
        _;
    }

    modifier onlyAuthorized() {

        require(msg.sender == authorityAddress, ERR_AUTHORIZED_ADDRESS_ONLY);
        _;
    }

    function changePrimaryOwner()
        public
        onlyOwner()
        returns (bool)
    {

        emit OwnershipTransferred("PRIMARY_OWNER", primaryOwner, authorityAddress);
        primaryOwner = authorityAddress;
        return true;
    }

    function changeSystemAddress(address _which)
        public
        onlyAuthorized()
        notThisAddress(_which)
        notZeroAddress(_which)
        returns (bool)
    {

        require(
            _which != systemAddress &&
                _which != authorityAddress &&
                _which != primaryOwner,
            ERR_SAME_ADDRESS
        );
        emit OwnershipTransferred("SYSTEM_ADDRESS", systemAddress, _which);
        systemAddress = _which;
        return true;
    }

    function changeAuthorityAddress(address _which)
        public
        onlyAuthorized()
        notZeroAddress(_which)
        returns (bool)
    {

        require(
            _which != systemAddress &&
                _which != authorityAddress,
            ERR_SAME_ADDRESS
        );
        newAuthorityAddress = _which;
        return true;
    }

    function acceptAuthorityAddress() public returns (bool) {

        require(msg.sender == newAuthorityAddress, ERR_AUTHORIZED_ADDRESS_ONLY);
        emit OwnershipTransferred(
            "AUTHORITY_ADDRESS",
            authorityAddress,
            newAuthorityAddress
        );
        authorityAddress = newAuthorityAddress;
        newAuthorityAddress = address(0);
        return true;
    }
}


pragma solidity ^0.5.9;


contract TokenTransfer {

    function ensureTransferFrom(
        IERC20Token _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal {

        if (_from == address(this))
            require(_token.transfer(_to, _amount), "ERR_TOKEN_TRANSFER_FAIL");
        else
            require(
                _token.transferFrom(_from, _to, _amount),
                "ERR_TOKEN_TRANSFER_FAIL"
            );
    }

    function approveTransferFrom(
        IERC20Token _token,
        address _spender,
        uint256 _amount
    ) internal {

        require(_token.approve(_spender, _amount), "ERR_TOKEN_APPROVAL_FAIL");
    }
}


pragma solidity ^0.5.9;

interface IRegistry {

    event ProxyCreated(address proxy);

    event VersionAdded(uint256 version, address implementation);

    function addVersion(uint256  version, address implementation)
        external;


    function getVersion(uint256 version)
        external
        view
        returns (address);

}


pragma solidity ^0.5.9;

contract Proxy {

    function implementation() public view returns (address);


    
    function() external payable {
        address _impl = implementation();
        require(_impl != address(0),"ERR_IMPLEMENTEION_ZERO");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }  
    }
    
    
    
    
}


pragma solidity ^0.5.9;



contract UpgradeabilityStorage is Proxy {

    IRegistry public registry;

    address internal _implementation;

    function implementation() public view returns (address) {

        return _implementation;
    }
}


pragma solidity ^0.5.9;



contract Upgradeable is UpgradeabilityStorage {

    function initialize() public view {

        require(msg.sender == address(registry),"ERR_ONLY_REGISTRERY_CAN_CALL");
    }
}


pragma solidity ^0.5.9;


interface IContributionTrigger {

    function depositeToken(
        IERC20Token _token,
        address _from,
        uint256 _amount
    ) external returns (bool);


    function contributeTowardLiquidity(uint256 _amount)
        external
        returns (uint256);


    function transferTokenLiquidity(
        IERC20Token _token,
        address _reciver,
        uint256 _amount
    ) external returns (bool);

}


pragma solidity ^0.5.9;

interface ICurrencyPrices {

    function getCurrencyPrice(address _which) external view returns (uint256);

}


pragma solidity ^0.5.9;

interface IAuction {

    
    function dayWiseMarketPrice(uint256 dayId) external view returns(uint256);

    
    function dayWiseContribution(uint256 dayId) external view returns(uint256);

    
    function auctionDay() external returns(uint256);

        
}


pragma solidity ^0.5.9;


interface ITokenVault {

    function depositeToken(
        IERC20Token _token,
        address _from,
        uint256 _amount
    ) external returns (bool);


    function directTransfer(
        address _token,
        address _to,
        uint256 amount
    ) external returns (bool);


    function transferEther(address payable _to, uint256 amount)
        external
        returns (bool);

}


pragma solidity ^0.5.9;

interface IWhiteList {

    function address_belongs(address _who) external view returns (address);


    function isWhiteListed(address _who) external view returns (bool);


    function isAllowedInAuction(address _which) external view returns (bool);


    function isAddressByPassed(address _which) external view returns (bool);


    function isExchangeAddress(address _which) external view returns (bool);


    function main_isTransferAllowed(
        address _msgSender,
        address _from,
        address _to
    ) external view returns (bool);


    function etn_isTransferAllowed(
        address _msgSender,
        address _from,
        address _to
    ) external view returns (bool);


    function stock_isTransferAllowed(
        address _msgSender,
        address _from,
        address _to
    ) external view returns (bool);


    function addWalletBehalfExchange(address _mainWallet, address _subWallet)
        external
        returns (bool);


    function main_isReceiveAllowed(address user) external view returns (bool);


    function etn_isReceiveAllowed(address user) external view returns (bool);


    function stock_isReceiveAllowed(address user) external view returns (bool);

}


pragma solidity ^0.5.9;












interface LiquidityInitializeInterface {

    function initialize(
        address _converter,
        address _baseToken,
        address _mainToken,
        address _relayToken,
        address _etherToken,
        address _ethRelayToken,
        address _primaryOwner,
        address _systemAddress,
        address _authorityAddress,
        address _registryaddress,
        uint256 _baseLinePrice
    ) external;

}

interface IBancorNetwork {

    function etherTokens(address _address) external view returns (bool);


    function rateByPath(address[] calldata _path, uint256 _amount)
        external
        view
        returns (uint256);


    function convertByPath(
        address[] calldata _path,
        uint256 _amount,
        uint256 _minReturn,
        address payable _beneficiary,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) external payable returns (uint256);

}

interface IContractRegistry {

    function addressOf(bytes32 _contractName) external view returns (address);


    function getAddress(bytes32 _contractName) external view returns (address);

}

interface IEtherToken {

    function deposit() external payable;


    function withdraw(uint256 _amount) external;


    function withdrawTo(address _to, uint256 _amount) external;

}

interface IBancorConverter {

    function registry() external view returns (address);


    function reserves(address _address)
        external
        view
        returns (
            uint256,
            uint32,
            bool,
            bool,
            bool
        );


    function removeLiquidity(
        uint256 _amount,
        IERC20Token[] calldata _reserveTokens,
        uint256[] calldata _reserveMinReturnAmounts
    ) external;

}

contract BancorConverterLiquidity is ProxyOwnable, SafeMath, LiquidityStorage {

    function updateConverter(address _converter)
        public
        onlyOwner()
        returns (bool)
    {

        converter = _converter;
        return true;
    }

    function addressOf(bytes32 _contractName) internal view returns (address) {

        address _registry = IBancorConverter(converter).registry();
        IContractRegistry registry = IContractRegistry(_registry);
        return registry.addressOf(_contractName);
    }

    function getTokensReserveRatio()
        internal
        view
        returns (uint256 _baseTokenRatio, uint256 _mainTokenRatio)
    {

        uint256 a;
        bool c;
        bool d;
        bool e;
        (a, _baseTokenRatio, c, d, e) = IBancorConverter(converter).reserves(
            address(baseToken)
        );
        (a, _mainTokenRatio, c, d, e) = IBancorConverter(converter).reserves(
            address(mainToken)
        );
        return (_baseTokenRatio, _mainTokenRatio);
    }

    function etherTokens(address _address) internal view returns (bool) {

        IBancorNetwork network = IBancorNetwork(bancorNetwork);
        return network.etherTokens(_address);
    }

    function getReturnByPath(address[] memory _path, uint256 _amount)
        internal
        view
        returns (uint256)
    {

        IBancorNetwork network = IBancorNetwork(bancorNetwork);
        return network.rateByPath(_path, _amount);
    }
}

contract RegisteryLiquidity is
    BancorConverterLiquidity,
    AuctionRegisteryContracts
{

    function updateRegistery(address _address)
        external
        onlyAuthorized()
        notZeroAddress(_address)
        returns (bool)
    {

        contractsRegistry = IAuctionRegistery(_address);
        _updateAddresses();
        return true;
    }

    function getAddressOf(bytes32 _contractName)
        internal
        view
        returns (address payable)
    {

        return contractsRegistry.getAddressOf(_contractName);
    }


    function _updateAddresses() internal {

        whiteListAddress = getAddressOf(WHITE_LIST);
        currencyPricesAddress = getAddressOf(CURRENCY);
        vaultAddress = getAddressOf(VAULT);
        triggerAddress = getAddressOf(CONTRIBUTION_TRIGGER);
        auctionAddress = getAddressOf(AUCTION);
        escrowAddress = getAddressOf(ESCROW);

        bancorNetwork = addressOf(BANCOR_NETWORK);
    }

    function updateAddresses() external returns (bool) {

        _updateAddresses();
        return true;
    }
}

contract LiquidityUtils is RegisteryLiquidity {

    modifier allowedAddressOnly(address _which) {

        require(_which == auctionAddress, ERR_AUTHORIZED_ADDRESS_ONLY);
        _;
    }

    function _updateTokenPath() internal returns (bool) {

        ethToMainToken = [
            etherToken,
            ethRelayToken,
            baseToken,
            relayToken,
            mainToken
        ];
        baseTokenToMainToken = [baseToken, relayToken, mainToken];
        mainTokenTobaseToken = [mainToken, relayToken, baseToken];
        ethToBaseToken = [etherToken, ethRelayToken, baseToken];
        baseTokenToEth = [baseToken, ethRelayToken, etherToken];
        relayPath = [IERC20Token(mainToken), IERC20Token(baseToken)];
        returnAmountRelay = [1, 1];
        return true;
    }

    function updateTokenPath() external returns (bool) {

        return _updateTokenPath();
    }

    function setSideReseverRatio(uint256 _sideReseverRatio)
        public
        onlyOwner()
        returns (bool)
    {

        require(_sideReseverRatio < 100, "ERR_RATIO_CANT_BE_GREATER_THAN_100");
        sideReseverRatio = _sideReseverRatio;
        return true;
    }

    function setTagAlongRatio(uint256 _tagAlongRatio)
        public
        onlyOwner()
        returns (bool)
    {

        tagAlongRatio = _tagAlongRatio;
        return true;
    }

    function setAppreciationLimit(uint256 _limit)
        public
        onlyOwner()
        returns (bool)
    {

        appreciationLimit = _limit;
        appreciationLimitWithDecimal = safeMul(_limit, DECIMAL_NOMINATOR);
        return true;
    }

    function setBaseTokenVolatiltyRatio(uint256 _baseTokenVolatiltyRatio)
        public
        onlyOwner()
        returns (bool)
    {

        baseTokenVolatiltyRatio = _baseTokenVolatiltyRatio;
        return true;
    }

    function setReductionStartDay(uint256 _reductionStartDay)
        public
        onlyOwner()
        returns (bool)
    {

        reductionStartDay = _reductionStartDay;
        return true;
    }

    function setRelayPercent(uint256 _relayPercent)
        public
        onlyOwner()
        returns (bool)
    {

        require(_relayPercent < 99);
        relayPercent = _relayPercent;
        return true;
    }
}

contract LiquidityFormula is LiquidityUtils {

    function _getCurrentMarketPrice() internal view returns (uint256) {

        uint256 _mainTokenBalance = IERC20Token(mainToken).balanceOf(converter);

        (
            uint256 _baseTokenRatio,
            uint256 _mainTokenRatio
        ) = getTokensReserveRatio();

        uint256 ratio = safeDiv(
            safeMul(
                safeMul(lastReserveBalance, _mainTokenRatio),
                BIG_NOMINATOR
            ),
            safeMul(_mainTokenBalance, _baseTokenRatio)
        );

        return safeDiv(safeMul(ratio, baseLinePrice), BIG_NOMINATOR);
    }

    function calculateLiquidityMainReserve(
        uint256 yesterdayPrice,
        uint256 dayBeforyesterdayPrice,
        uint256 yesterDaycontibution,
        uint256 yesterdayMainReserv
    ) internal pure returns (uint256) {


        uint256 _tempContrbution = safeDiv(
            safeMul(yesterDaycontibution, PRICE_NOMINATOR),
            yesterdayMainReserv
        );

        uint256 _tempRatio = safeDiv(
            safeMul(yesterdayPrice, PRICE_NOMINATOR),
            dayBeforyesterdayPrice
        );

        _tempRatio = safeMul(_tempContrbution, _tempRatio);

        if (_tempRatio > DECIMAL_NOMINATOR) {
            return _tempRatio;
        } else {
            return 0;
        }
    }
}

contract Liquidity is
    Upgradeable,
    LiquidityFormula,
    TokenTransfer,
    LiquidityInitializeInterface
{

    function initialize(
        address _converter,
        address _baseToken,
        address _mainToken,
        address _relayToken,
        address _etherToken,
        address _ethRelayToken,
        address _primaryOwner,
        address _systemAddress,
        address _authorityAddress,
        address _registryaddress,
        uint256 _baseLinePrice
    ) public {

        super.initialize();
        initializeOwner(_primaryOwner, _systemAddress, _authorityAddress);

        converter = _converter;
        baseLinePrice = _baseLinePrice;
        sideReseverRatio = 70;
        appreciationLimit = 120;
        tagAlongRatio = 100;
        reductionStartDay = 21;
        maxIteration = 35;
        relayPercent = 10;
        appreciationLimitWithDecimal = safeMul(120, DECIMAL_NOMINATOR);
        baseTokenVolatiltyRatio = 5 * PRICE_NOMINATOR;

        baseToken = _baseToken;
        mainToken = _mainToken;
        relayToken = _relayToken;
        etherToken = _etherToken;
        ethRelayToken = _ethRelayToken;

        contractsRegistry = IAuctionRegistery(_registryaddress);
        lastReserveBalance = IERC20Token(baseToken).balanceOf(converter);
        tokenAuctionEndPrice = _getCurrentMarketPrice();
        _updateAddresses();
        _updateTokenPath();
    }

    function _contributeWithEther(uint256 value) internal returns (uint256) {

        uint256 lastBalance = IERC20Token(baseToken).balanceOf(converter);

        if (lastBalance != lastReserveBalance) {
            _recoverPriceDueToManipulation();
        }

        uint256 returnAmount = IBancorNetwork(bancorNetwork)
            .convertByPath
            .value(value)(
            ethToMainToken,
            value,
            1,
            vaultAddress,
            address(0),
            0
        );

        todayMainReserveContribution = safeAdd(
            todayMainReserveContribution,
            value
        );

        emit Contribution(address(0), value, returnAmount);
        lastReserveBalance = IERC20Token(baseToken).balanceOf(converter);
        checkAppeciationLimit();
        return returnAmount;
    }

    function _convertBaseTokenToEth() internal {

        uint256 _baseTokenBalance = IERC20Token(baseToken).balanceOf(
            address(this)
        );

        if (_baseTokenBalance > 0) {
            if (etherTokens(baseToken)) {
                IEtherToken(baseToken).withdraw(_baseTokenBalance);
            } else {
                approveTransferFrom(
                    IERC20Token(baseToken),
                    bancorNetwork,
                    _baseTokenBalance
                );
                IBancorNetwork(bancorNetwork).convertByPath.value(0)(
                    baseTokenToEth,
                    _baseTokenBalance,
                    1,
                    address(0),
                    address(0),
                    0
                );
            }
        }
    }

    function _convertWithToken(uint256 value, address[] memory _path)
        internal
        returns (bool)
    {

        approveTransferFrom(IERC20Token(_path[0]), bancorNetwork, value);

        address payable sentBackAddress;

        if (_path[safeSub(_path.length, 1)] == mainToken) {
            sentBackAddress = vaultAddress;
        }
        IBancorNetwork(bancorNetwork).convertByPath.value(0)(
            _path,
            value,
            1,
            sentBackAddress,
            address(0),
            0
        );

        _convertBaseTokenToEth();
        lastReserveBalance = IERC20Token(baseToken).balanceOf(converter);
        return true;
    }

    function checkAppeciationLimit() internal returns (bool) {

        uint256 tokenCurrentPrice = _getCurrentMarketPrice();

        uint256 _appreciationReached = safeDiv(
            safeMul(tokenCurrentPrice, safeMul(100, DECIMAL_NOMINATOR)),
            tokenAuctionEndPrice
        );

        if (_appreciationReached > appreciationLimitWithDecimal) {
            isAppreciationLimitReached = true;
            _priceRecoveryWithConvertMainToken(_appreciationReached);
        }
        return true;
    }

    function contributeTowardMainReserve()
        external
        allowedAddressOnly(msg.sender)
        returns (uint256)
    {

        if (address(this).balance < previousMainReserveContribution) {
            while (previousMainReserveContribution >= address(this).balance) {
                _liquadate(safeMul(relayPercent, PRICE_NOMINATOR));
                _convertBaseTokenToEth();
                if (address(this).balance >= previousMainReserveContribution) {
                    break;
                }
            }
        }
        _contributeWithEther(previousMainReserveContribution);
        return previousMainReserveContribution;
    }

    function contributeWithEther()
        public
        payable
        allowedAddressOnly(msg.sender)
        returns (uint256)
    {

        uint256 _amount = msg.value;

        uint256 sideReseverAmount = safeDiv(
            safeMul(_amount, sideReseverRatio),
            100
        );

        uint256 mainReserverAmount = safeSub(_amount, sideReseverAmount);
        if (virtualReserverDivisor > 0)
            mainReserverAmount = safeDiv(
                safeMul(mainReserverAmount, DECIMAL_NOMINATOR),
                virtualReserverDivisor
            );

        if (isAppreciationLimitReached) {
            return _getCurrentMarketPrice();
        }

        uint256 tagAlongAmount = safeDiv(
            safeMul(mainReserverAmount, tagAlongRatio),
            100
        );

        if (tagAlongAmount > address(this).balance)
            mainReserverAmount = safeAdd(
                mainReserverAmount,
                address(this).balance
            );
        else mainReserverAmount = safeAdd(mainReserverAmount, tagAlongAmount);

        _contributeWithEther(mainReserverAmount);
        return _getCurrentMarketPrice();
    }

    function _recoverReserve(bool isMainToken, uint256 _liquadateRatio)
        internal
    {

        (uint256 returnBase, uint256 returnMain) = _liquadate(_liquadateRatio);

        if (isMainToken) {
            ITokenVault(vaultAddress).directTransfer(
                mainToken,
                converter,
                returnMain
            );
        } else {
            ensureTransferFrom(
                IERC20Token(baseToken),
                address(this),
                converter,
                returnBase
            );
        }

        lastReserveBalance = IERC20Token(baseToken).balanceOf(converter);
    }

    function recoverPriceVolatility() external returns (bool) {

        _recoverPriceDueToManipulation();

        uint256 baseTokenPrice = ICurrencyPrices(currencyPricesAddress)
            .getCurrencyPrice(address(baseToken));

        uint256 volatilty;

        bool isMainToken;

        if (baseTokenPrice > baseLinePrice) {
            volatilty = safeDiv(
                safeMul(
                    safeSub(baseTokenPrice, baseLinePrice),
                    safeMul(100, PRICE_NOMINATOR)
                ),
                baseTokenPrice
            );
            isMainToken = true;
        } else if (baseLinePrice > baseTokenPrice) {
            volatilty = safeDiv(
                safeMul(
                    safeSub(baseLinePrice, baseTokenPrice),
                    safeMul(100, PRICE_NOMINATOR)
                ),
                baseLinePrice
            );
            isMainToken = false;
        }

        if (volatilty >= baseTokenVolatiltyRatio) {
            _recoverReserve(isMainToken, volatilty);
        }
        baseLinePrice = baseTokenPrice;
        return true;
    }

    function _recoverPriceDueToManipulation() internal returns (bool) {

        uint256 volatilty;

        uint256 _baseTokenBalance = IERC20Token(baseToken).balanceOf(converter);
        bool isMainToken;

        if (_baseTokenBalance > lastReserveBalance) {
            volatilty = safeDiv(
                safeMul(
                    safeSub(_baseTokenBalance, lastReserveBalance),
                    safeMul(100, PRICE_NOMINATOR)
                ),
                _baseTokenBalance
            );

            isMainToken = true;
            _recoverReserve(isMainToken, volatilty);
        }
        return true;
    }

    function recoverPriceDueToManipulation() external returns (bool) {

        return _recoverPriceDueToManipulation();
    }

    function _priceRecoveryWithConvertMainToken(uint256 _percent)
        internal
        returns (bool)
    {

        uint256 tempX = safeDiv(_percent, appreciationLimit);
        uint256 root = nthRoot(tempX, 2, 0, maxIteration);
        uint256 _tempValue = safeSub(root, PRICE_NOMINATOR);
        uint256 _supply = IERC20Token(mainToken).balanceOf(converter);

        uint256 _reverseBalance = safeDiv(
            safeMul(_supply, _tempValue),
            PRICE_NOMINATOR
        );

        uint256 vaultBalance = IERC20Token(mainToken).balanceOf(vaultAddress);

        if (vaultBalance >= _reverseBalance) {
            ITokenVault(vaultAddress).directTransfer(
                address(mainToken),
                address(this),
                _reverseBalance
            );
            return _convertWithToken(_reverseBalance, mainTokenTobaseToken);
        } else {
            uint256 converterBalance = IERC20Token(mainToken).balanceOf(
                converter
            );

            uint256 _tempRelayPercent = relayPercent;

            if (converterBalance > _reverseBalance)
                _tempRelayPercent = safeDiv(
                    safeMul(
                        safeSub(converterBalance, _reverseBalance),
                        safeMul(100, PRICE_NOMINATOR)
                    ),
                    _reverseBalance
                );
            _liquadate(safeMul(_tempRelayPercent, PRICE_NOMINATOR));
            return _priceRecoveryWithConvertMainToken(_percent);
        }
    }
    

    function _recoverAfterRedemption(uint256 _amount) internal returns (bool) {

        uint256 totalEthAmount = getReturnByPath(ethToBaseToken, _amount);

        if (address(this).balance >= totalEthAmount) {
            IBancorNetwork(bancorNetwork).convertByPath.value(totalEthAmount)(
                ethToBaseToken,
                totalEthAmount,
                1,
                address(0),
                address(0),
                0
            );

            return _convertWithToken(_amount, baseTokenToMainToken);
        } else {
            uint256 converterBalance = IERC20Token(baseToken).balanceOf(
                converter
            );

            uint256 _tempRelayPercent;
            
            if (converterBalance > _amount) {
                _tempRelayPercent = safeDiv(
                    safeMul(safeMul(_amount, PRICE_NOMINATOR), 100),
                    converterBalance
                );
            } else {
                 _tempRelayPercent = safeDiv(
                    safeMul(safeMul(_amount, PRICE_NOMINATOR), 100),
                    safeAdd(converterBalance,_amount)
                );
            }

            _liquadate(_tempRelayPercent);

            _amount = safeSub(
                _amount,
                safeDiv(safeMul(_amount, _tempRelayPercent),safeMul(100,PRICE_NOMINATOR))
            );

            return _convertWithToken(_amount, baseTokenToMainToken);
        }
    }

    function redemptionFromEscrow(
        address[] memory _path,
        uint256 _amount,
        address payable _reciver
    ) public returns (bool) {

        require(msg.sender == escrowAddress, ERR_AUTHORIZED_ADDRESS_ONLY);
        return _redemption(_path, _amount, msg.sender, _reciver);
    }

    function redemption(address[] memory _path, uint256 _amount)
        public
        returns (bool)
    {

        return _redemption(_path, _amount, msg.sender, msg.sender);
    }

    function _redemption(
        address[] memory _path,
        uint256 _amount,
        address payable _caller,
        address payable _reciver
    ) internal returns (bool) {

        require(_path[0] == mainToken, "ERR_MAIN_TOKEN");

        address primaryWallet = IWhiteList(whiteListAddress).address_belongs(
            _reciver
        );

        uint256 auctionDay = IAuction(auctionAddress).auctionDay();

        require(primaryWallet != address(0), "ERR_WHITELIST");

        require(
            auctionDay > lastReedeemDay[primaryWallet],
            "ERR_WALLET_ALREADY_REDEEM"
        );

        uint256 _beforeBalance = IERC20Token(baseToken).balanceOf(converter);

        if (_beforeBalance != lastReserveBalance) {
            _recoverPriceDueToManipulation();
        }

        ensureTransferFrom(
            IERC20Token(mainToken),
            _caller,
            address(this),
            _amount
        );

        approveTransferFrom(IERC20Token(mainToken), bancorNetwork, _amount);

        uint256 returnAmount = IBancorNetwork(bancorNetwork)
            .convertByPath
            .value(0)(_path, _amount, 1, _reciver, address(0), 0);

        lastReedeemDay[primaryWallet] = auctionDay;

        uint256 _afterBalance = IERC20Token(baseToken).balanceOf(converter);

        emit Redemption(
            address(_path[safeSub(_path.length, 1)]),
            _amount,
            returnAmount
        );

        if (_beforeBalance > _afterBalance) {
            _recoverAfterRedemption(safeSub(_beforeBalance, _afterBalance));
        }

        return true;
    }

    function auctionEnded()
        external
        allowedAddressOnly(msg.sender)
        returns (bool)
    {

        uint256 _baseTokenBalance = IERC20Token(baseToken).balanceOf(converter);

        uint256 yesterdayMainReserv = safeDiv(
            safeMul(_baseTokenBalance, baseLinePrice),
            safeExponent(10, IERC20Token(baseToken).decimals())
        );

        IAuction auction = IAuction(auctionAddress);

        uint256 auctionDay = auction.auctionDay();

        if (auctionDay > reductionStartDay) {
            uint256 _yesterdayPrice = auction.dayWiseMarketPrice(
                safeSub(auctionDay, 1)
            );

            uint256 _dayBeforePrice = auction.dayWiseMarketPrice(
                safeSub(auctionDay, 2)
            );

            uint256 _yesterdayContribution = auction.dayWiseContribution(
                safeSub(auctionDay, 1)
            );

            virtualReserverDivisor = calculateLiquidityMainReserve(
                _yesterdayPrice,
                _dayBeforePrice,
                _yesterdayContribution,
                yesterdayMainReserv
            );
        }
        previousMainReserveContribution = todayMainReserveContribution;
        todayMainReserveContribution = 0;
        tokenAuctionEndPrice = _getCurrentMarketPrice();
        isAppreciationLimitReached = false;
        return true;
    }

    function _liquadate(uint256 _relayPercent)
        internal
        returns (uint256, uint256)
    {

        uint256 _mainTokenBalance = IERC20Token(mainToken).balanceOf(
            address(this)
        );

        uint256 _baseTokenBalance = IERC20Token(baseToken).balanceOf(
            address(this)
        );

        uint256 sellRelay = safeDiv(
            safeMul(
                IERC20Token(relayToken).balanceOf(triggerAddress),
                _relayPercent
            ),
            safeMul(100, PRICE_NOMINATOR)
        );

        require(sellRelay > 0, "ERR_RELAY_ZERO");

        IContributionTrigger(triggerAddress).transferTokenLiquidity(
            IERC20Token(relayToken),
            address(this),
            sellRelay
        );

        IBancorConverter(converter).removeLiquidity(
            sellRelay,
            relayPath,
            returnAmountRelay
        );

        _mainTokenBalance = safeSub(
            IERC20Token(mainToken).balanceOf(address(this)),
            _mainTokenBalance
        );

        _baseTokenBalance = safeSub(
            IERC20Token(baseToken).balanceOf(address(this)),
            _baseTokenBalance
        );

        ensureTransferFrom(
            IERC20Token(mainToken),
            address(this),
            vaultAddress,
            _mainTokenBalance
        );

        if (etherTokens(baseToken)) {
            IEtherToken(baseToken).withdraw(_baseTokenBalance);
        }
        return (_baseTokenBalance, _mainTokenBalance);
    }

    function returnFundToTagAlong(IERC20Token _token, uint256 _value)
        external
        onlyOwner()
        returns (bool)
    {

        if (address(_token) == address(0)) {
            triggerAddress.transfer(_value);
        } else {
            ensureTransferFrom(_token, address(this), triggerAddress, _value);
        }
        return true;
    }

    function takeFundFromTagAlong(IERC20Token _token, uint256 _value)
        external
        onlyOwner()
        returns (bool)
    {

        if (address(_token) == address(0))
            IContributionTrigger(triggerAddress).contributeTowardLiquidity(
                _value
            );
        else
            IContributionTrigger(triggerAddress).transferTokenLiquidity(
                _token,
                address(this),
                _value
            );
        return true;
    }

    function getCurrencyPrice() public view returns (uint256) {

        return _getCurrentMarketPrice();
    }

    function sendMainTokenToVault() external returns (bool) {

        uint256 mainTokenBalance = IERC20Token(mainToken).balanceOf(
            address(this)
        );
        ensureTransferFrom(
            IERC20Token(mainToken),
            address(this),
            vaultAddress,
            mainTokenBalance
        );
        return true;
    }

    function convertBaseTokenToEth() external returns (bool) {

        _convertBaseTokenToEth();
        return true;
    }

    function() external payable {}
}