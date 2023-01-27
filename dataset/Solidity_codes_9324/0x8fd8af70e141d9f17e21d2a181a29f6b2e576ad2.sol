


pragma solidity ^0.6.2;

interface ISynthetix {

    function exchange(
        bytes32 sourceCurrencyKey,
        uint256 sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint256 amountReceived);


    function exchangeWithTracking(
        bytes32 sourceCurrencyKey,
        uint256 sourceAmount,
        bytes32 destinationCurrencyKey,
        address originator,
        bytes32 trackingCode
    ) external returns (uint256 amountReceived);


    function synths(bytes32 key)
        external
        view
        returns (address synthTokenAddress);


    function settle(bytes32 currencyKey)
        external
        returns (
            uint256 reclaimed,
            uint256 refunded,
            uint256 numEntriesSettled
        );

}


pragma solidity ^0.6.2;

interface ISynth {

    function proxy() external view returns (address);


    function transferAndSettle(address to, uint256 value)
        external
        returns (bool);


    function transferFromAndSettle(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}


pragma solidity ^0.6.2;

interface IAddressResolver {

    function getAddress(bytes32 name) external view returns (address);

}


pragma solidity ^0.6.2;

interface IExchanger {


    function settle(address from, bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );


    function maxSecsLeftInWaitingPeriod(address account, bytes32 currencyKey) external view returns (uint);


    function settlementOwing(address account, bytes32 currencyKey)
        external
        view
        returns (
            uint reclaimAmount,
            uint rebateAmount,
            uint numEntries
        );


}


pragma solidity ^0.6.2;

interface IExchangeRates {

    function effectiveValue(
        bytes32 sourceCurrencyKey,
        uint256 sourceAmount,
        bytes32 destinationCurrencyKey
    ) external view returns (uint256);


    function rateForCurrency(bytes32 currencyKey)
        external
        view
        returns (uint256);

}


pragma solidity ^0.6.2;

interface IDHedge {


    function totalSupply() external view returns (uint256);

    function getSupportedAssets() external view returns (bytes32[] memory);

    function assetValue(bytes32 key) external view returns (uint256);

    function getAssetProxy(bytes32 key) external view returns (address);

    function setLastDeposit(address investor) external;

    function tokenPriceAtLastFeeMint() external view returns (uint256);

    function availableManagerFee() external view returns (uint256);

}



pragma solidity ^0.6.2;

interface IPoolDirectory {

    function isPool(address pool) external view returns (bool);

}



pragma solidity ^0.6.2;

interface IHasFeeInfo {

    function getPoolManagerFee(address pool) external view returns (uint256, uint256);

    function setPoolManagerFeeNumerator(address pool, uint256 numerator) external;


    function getMaximumManagerFeeNumeratorChange() external view returns (uint256);

    function getManagerFeeNumeratorChangeDelay() external view returns (uint256);

   
    function getExitFee() external view returns (uint256, uint256);

    function getExitFeeCooldown() external view returns (uint256);


    function getTrackingCode() external view returns (bytes32);

}


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
}


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
}


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.6.0;


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



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

    uint256[49] private __gap;
}


pragma solidity ^0.6.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
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
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


pragma solidity ^0.6.2;














contract DHPTSwap is Initializable, OwnableUpgradeSafe {

    using SafeMath for uint256;

    IAddressResolver public addressResolver;
    address public factory;
    address public oracle;

    bool public enableBuy;
    bool public enableSell;
    bool public enableOracleBuy;
    bool public enableOracleSell;
    
    uint8 public oracleBlockBias;

    mapping(address => uint256) public dhptWhitelist;

    bytes32 private constant _EXCHANGE_RATES_KEY = "ExchangeRates";
    bytes32 private constant _EXCHANGER_KEY = "Exchanger";
    bytes32 private constant _SYNTHETIX_KEY = "Synthetix";
    bytes32 private constant _SUSD_KEY = "sUSD";
    address public dao;
    mapping(bytes32 => bool) public dhptFromEnabled;
    mapping(address => uint8) public stableCoins;

    event SellDHPT(
        address fundAddress,
        address investor,
        uint256 susdAmount,
        uint256 dhptAmount,
        uint256 tokenPrice,
        uint256 time,
        bool oracleSwap
    );

    event BuyDHPT(
        address fundAddress,
        address investor,
        uint256 susdAmount,
        uint256 dhptAmount,
        uint256 tokenPrice,
        uint256 time,
        bool oracleSwap
    );

    event SwapDHPT(
        address fundAddressA,
        uint256 tokenPriceA,
        uint256 amountA,
        address fundAddressB,
        uint256 tokenPriceB,
        uint256 amountB,
        address investor,
        uint256 time,
        bool oracleSwap
    );

    function initialize(IAddressResolver _addressResolver, address _factory, address _oracle) public initializer {

        OwnableUpgradeSafe.__Ownable_init();

        enableBuy = true;
        enableSell = true;
        enableOracleBuy = false;
        enableOracleSell = false;

        addressResolver = _addressResolver;
        factory = _factory;
        oracle = _oracle;
        oracleBlockBias = 25;
    }

    function setStableCoin(address stableCoin, uint8 tokenPrecision) public onlyOwner {

        stableCoins[stableCoin] = tokenPrecision;
    }


    function sellDHPT(address poolAddress, uint256 dhptAmount, address stableCoin) public {

        uint8 stableCoinPrecision = stableCoins[stableCoin];
        require(stableCoinPrecision > 0, "selected stable coin is disabled");

        require(enableSell, "sell disabled");
        require(_canSellDhpt(poolAddress, dhptAmount), "unable to sell tokens");
        require(dhptAmount > 10000, "amount too small");
       
        uint256 poolPrice = tokenPriceWithSettle(poolAddress);
        require(poolPrice > 0, "poolPrice is not valid value");

        require(
            IERC20(poolAddress).transferFrom(
                msg.sender,
                address(this),
                dhptAmount
            ),
            "token transfer failed"
        );

        uint256 stableCoinAmount = dhptAmount.mul(poolPrice).div(10**uint(stableCoinPrecision));

        require(
            IERC20(stableCoin).transfer(
                msg.sender, stableCoinAmount
            ),
            "stable coin transfer failed"
        );
        
        emit SellDHPT(
            poolAddress,
            msg.sender,
            stableCoinAmount,
            dhptAmount,
            poolPrice,
            block.timestamp,
            false
        );
    }

    function buyDHPT(address poolAddress, address stableCoin, uint256 stableCoinAmount) public {

        uint8 stableCoinPrecision = stableCoins[stableCoin];
        require(stableCoinPrecision > 0, "selected stable coin is disabled");
        
        require(enableBuy, "buy disabled");
        require(dhptWhitelist[poolAddress] > 0, "pool not whitelisted");
        require(stableCoinAmount > 10000, "amount too small");

        uint256 poolPrice = tokenPriceWithSettle(poolAddress);
        uint256 dhptAmount = stableCoinAmount.mul(10**uint(stableCoinPrecision)).div(poolPrice);
        IDHedge(poolAddress).setLastDeposit(msg.sender);
        
        require(
            IERC20(stableCoin).transferFrom(
                msg.sender,
                address(this),
                stableCoinAmount
            ),
            "stable coin transfer failed"
        );
      
        require(
            IERC20(poolAddress).transfer(msg.sender, dhptAmount),
            "pool-token transfer failed"
        );

        emit BuyDHPT(
            poolAddress,
            msg.sender,
            stableCoinAmount,
            dhptAmount,
            poolPrice,
            block.timestamp,
            false
        );
    }
    
    function swapDHPT(address poolAddressA, uint256 poolAmountA, address poolAddressB) public {

       require(enableBuy, "buy disabled");
       require(enableSell, "sell disabled");
       require(dhptWhitelist[poolAddressA] > 0, "from-token not whitelisted");
       require(poolAmountA > 10000, "amount too small");
       require(dhptWhitelist[poolAddressB] > 0, "to-token not whitelisted");

       uint256 poolPriceA = tokenPriceWithSettle(poolAddressA);
       uint256 sUsdAmount = poolAmountA.mul(poolPriceA).div(10**18);

       uint256 poolPriceB = tokenPriceWithSettle(poolAddressB);
       uint256 poolAmountB = sUsdAmount.mul(10**18).div(poolPriceB);
       IDHedge(poolAddressB).setLastDeposit(msg.sender);

        require(
            IERC20(poolAddressA).transferFrom(
                msg.sender,
                address(this),
                poolAmountA
            ),
            "from-token transfer failed"
        );
      
        require(
            IERC20(poolAddressB).transfer(msg.sender, poolAmountB),
            "to-token transfer failed"
        );

        emit SwapDHPT(
            poolAddressA,
            poolPriceA,
            poolAmountA,
            poolAddressB,
            poolPriceB,
            poolAmountB,
            msg.sender,
            block.timestamp,
            false
        );
    }
    

    
    function oracleBuyDHPT(address poolAddress, address stableCoin, uint256 stableCoinAmount, uint256 blockNumber, uint256 poolPrice, bytes memory signature)
       public
    {

        _requireOracle(enableOracleBuy, stableCoinAmount, blockNumber);
        uint8 stableCoinPrecision = stableCoins[stableCoin];
        require(stableCoinPrecision > 0, "selected stable coin is disabled");
        
        require(dhptWhitelist[poolAddress] > 0, "pool not whitelisted");
        require(_isOracleSigValid(msg.sender, blockNumber, poolAddress, poolPrice, stableCoinAmount, signature), "signature invalid");
        uint256 dhptAmount = stableCoinAmount.mul(10**uint(stableCoinPrecision)).div(poolPrice);

        IDHedge(poolAddress).setLastDeposit(msg.sender);
        
        require(
            IERC20(stableCoin).transferFrom(
                msg.sender,
                address(this),
                stableCoinAmount
            ),
            "stable coin transfer failed"
        );

        require(
            IERC20(poolAddress).transfer(msg.sender, dhptAmount),
            "token transfer failed"
        );

        emit BuyDHPT(
            poolAddress,
            msg.sender,
            stableCoinAmount,
            dhptAmount,
            poolPrice,
            block.timestamp,
            true
        );
        
    }
    
    function oracleSellDHPT(address poolAddress, address stableCoin, uint256 dhptAmount, uint256 blockNumber, uint256 poolPrice, bytes memory signature)
       public
    {

        _requireOracle(enableOracleSell, dhptAmount, blockNumber);
        uint8 stableCoinPrecision = stableCoins[stableCoin];
        require(stableCoinPrecision > 0, "selected stable coin is disabled");        
        require(_canSellDhpt(poolAddress, dhptAmount), "unable to sell tokens");
       
        uint256 stableCoinAmount = dhptAmount.mul(poolPrice).div(10**uint(stableCoinPrecision));
        require(_isOracleSigValid(msg.sender, blockNumber, poolAddress, poolPrice, stableCoinAmount, signature), "signature invalid");
        
        require(
            IERC20(poolAddress).transferFrom(
                msg.sender,
                address(this),
                dhptAmount
            ),
            "token transfer failed"
        );

       
        require(
            IERC20(stableCoin).transfer(
                msg.sender, stableCoinAmount
            ),
            "stable coin transfer failed"
        );

        emit SellDHPT(
            poolAddress,
            msg.sender,
            stableCoinAmount,
            dhptAmount,
            poolPrice,
            block.timestamp,
            true
        );
    }

    function oracleBuyDHPTFrom(address poolAddress, address fromAddress, uint256 susdAmount, uint256 blockNumber, uint256 poolPrice, bytes memory signature) 
        public
    {

        _requireOracle(enableOracleBuy, susdAmount, blockNumber);
        require(_isOracleSigValid(msg.sender, blockNumber, poolAddress, poolPrice, susdAmount, signature), "signature invalid");
        require(dhptWhitelist[poolAddress] > 0, "pool not whitelisted");

        uint256 dhptAmount = susdAmount.mul(10**18).div(poolPrice);
        require(_dhptFromEnabled(poolAddress, fromAddress), "source liquidity disabled");
        IDHedge(poolAddress).setLastDeposit(msg.sender);

        require(
            IERC20(_getAssetProxy(_SUSD_KEY)).transferFrom(
                msg.sender,
                fromAddress,
                susdAmount
            ),
            "susd transfer failed"
        );

        require(
            IERC20(poolAddress).transferFrom(
                fromAddress,
                msg.sender,
                dhptAmount
            ),
            "token transfer failed"
        );

        emit BuyDHPT(
            poolAddress,
            msg.sender,
            susdAmount,
            dhptAmount,
            poolPrice,
            block.timestamp,
            true
        );
    }

    function oracleSwapDHPT(address poolAddressA, uint256 poolAmountA, uint256 poolPriceA, address poolAddressB,
                             uint256 poolPriceB, uint256 blockNumber, bytes memory signature)
        public
    {

        _requireOracle(enableOracleBuy && enableOracleSell, poolAmountA, blockNumber);
        require(_canSellDhpt(poolAddressA, poolAmountA), "unable to sell tokens");
        require(dhptWhitelist[poolAddressB] > 0, "pool not whitelisted");

       require(_isOracleSwapSigValid(msg.sender, blockNumber, poolAddressA, poolPriceA, poolAmountA, poolAddressB, poolPriceB, signature), "signature invalid");

        require(
            IERC20(poolAddressA).transferFrom(
                msg.sender,
                address(this),
                poolAmountA
            ),
            "from-token transfer failed"
        );

        uint256 poolAmountB = (poolAmountA.mul(poolPriceA)).div(poolPriceB);

        require(
            IERC20(poolAddressB).transfer(msg.sender, poolAmountB),
            "to-token transfer failed"
        );

        emit SwapDHPT(
            poolAddressA,
            poolPriceA,
            poolAmountA,
            poolAddressB,
            poolPriceB,
            poolAmountB,
            msg.sender,
            block.timestamp,
            true
        );
    }

    function _requireOracle(bool enableOracle, uint256 amount, uint256 blockNumber)
        internal
        view
    {

        require(blockNumber.add(oracleBlockBias) > block.number, "transaction timed out");
        require(enableOracle, "oracle disabled");
        require(amount > 10000, "amount too small");
        require(blockNumber <= block.number, "invalid block number");
    }
    
    function _isOracleSigValid(address sender, uint256 blockNumber, address poolAddress, uint256 poolPrice, uint256 amount, bytes memory signature)
        internal
        view
        returns (bool)
    {

        bytes32 hash = keccak256(abi.encodePacked(sender, blockNumber, poolAddress, poolPrice, amount));
        bytes32 ethHash = ECDSA.toEthSignedMessageHash(hash);
        
        if (ECDSA.recover(ethHash, signature) == oracle) {
            return true;
        } else {
            return false;
        }
    }

    function _isOracleSwapSigValid(address sender, uint256 blockNumber, address poolAddressA, uint256 poolPriceA, uint256 poolAmountA, address poolAddressB, uint256 poolPriceB, bytes memory signature)
        internal
        view
        returns (bool)
    {

        bytes32 hash = keccak256(abi.encodePacked(sender, blockNumber, poolAddressA, poolPriceA, poolAmountA, poolAddressB, poolPriceB ));
        bytes32 ethHash = ECDSA.toEthSignedMessageHash(hash);
        
        if (ECDSA.recover(ethHash, signature) == oracle) {
            return true;
        } else {
            return false;
        }
    }

    function dhptFromLiquidity(address poolAddress, address fromAddress)
    public
    view
    returns (uint256)
    {

        if (_dhptFromEnabled(poolAddress, fromAddress)) {
            return IERC20(poolAddress).allowance(fromAddress, address(this));
        } else {
            return 0;
        }
    }

    function enableLiquidity(address[] memory poolAddresses, bool[] memory enabled)
        public
    {

        require(poolAddresses.length == enabled.length, "invalid input lengths");

        for (uint256 i = 0; i < poolAddresses.length; i++) {
            bytes32 hash = keccak256(abi.encodePacked(poolAddresses[i], msg.sender));
            dhptFromEnabled[hash] = enabled[i];
        }
    }

    function _dhptFromEnabled(address poolAddress, address fromAddress)
        internal
        view
        returns (bool)
    {

        bytes32 hash = keccak256(abi.encodePacked(poolAddress, fromAddress));
        return dhptFromEnabled[hash];
    }



    function whitelistDhpt(address[] memory addresses, uint256[] memory amounts)
        public
        onlyOwner
    {

        require(addresses.length == amounts.length, "invalid input lengths");

        for (uint256 i = 0; i < addresses.length; i++) {
            require(IPoolDirectory(factory).isPool(addresses[i]), "not a pool");

            dhptWhitelist[addresses[i]] = amounts[i];
        }
    }

    function setAddressResolver(IAddressResolver _addressResolver)
        public
        onlyOwner
    {

        addressResolver = _addressResolver;
    }
    
    function setFactory(address _factory)
        public
        onlyOwner
    {

        factory = _factory;
    }

    function setDao(address _dao)
        public
        onlyOwner
    {

        dao = _dao;
    }
    
    function setOracle(address _oracle)
        public
        onlyOwner
    {

        oracle = _oracle;
    }
    
    function setOracleBlockBias(uint8 _oracleBlockBias)
        public
        onlyOwner
    {

        oracleBlockBias = _oracleBlockBias;
    }

    function withdrawToken(address tokenAddress, uint256 amount)
        public
        onlyDao
    {

        require(
            IERC20(tokenAddress).transfer(
                dao,
                amount
            ),
            "token transfer failed"
        );
    }

    function withdrawTokenTo(address tokenAddress, uint256 amount, address toAddress)
        public
        onlyDao
    {

        require(
            IERC20(tokenAddress).transfer(
                toAddress,
                amount
                ),
            "token transfer failed"
            );
    }

    function enableBuySell(bool _enableBuy, bool _enableSell, bool _enableOracleBuy, bool _enableOracleSell)
        public
        onlyOwner
    {

        enableBuy = _enableBuy;
        enableSell = _enableSell;
        enableOracleBuy = _enableOracleBuy;
        enableOracleSell = _enableOracleSell;
    }
    


    function _canSellDhpt(address poolAddress, uint256 dhptAmount)
        internal
        view
        returns (bool)
    {

        uint256 dhptBalance = tokenBalanceOf(poolAddress);
        if (dhptWhitelist[poolAddress] >= dhptBalance.add(dhptAmount)) {
            return true;
        } else {
            return false;
        }
    }

    function tokenBalanceOf(address tokenAddress)
        public
        view
        returns (uint256)
    {

        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function _availDhptToSell(address poolAddress)
        internal
        view
        returns (uint256)
    {

        uint256 dhptBalance = tokenBalanceOf(poolAddress);
        return dhptWhitelist[poolAddress].sub(dhptBalance);
    }

    function maxDhptToSell(address poolAddress) public view returns (uint256) {

        uint256 availDhpt = _availDhptToSell(poolAddress);
        uint256 susdBalance = IERC20(_getAssetProxy(_SUSD_KEY)).balanceOf(
            address(this)
        );
        uint256 poolPrice = tokenPriceWithSettle(poolAddress);
        require(poolPrice > 0, "invalid pool price");
        uint256 susdForDhpt = susdBalance.mul(10**18).div(poolPrice);

        if (susdForDhpt > availDhpt) {
            return availDhpt;
        } else {
            return susdForDhpt;
        }
    }

    function maxSusdToSell(address poolAddress) public view returns (uint256) {

        uint256 dhptBalance = IERC20(poolAddress).balanceOf(address(this));
        uint256 poolPrice = tokenPriceWithSettle(poolAddress);
        require(poolPrice > 0, "invalid pool price");
        uint256 dhptForSusd = dhptBalance.mul(poolPrice).div(10**18);

        return dhptForSusd;
    }

    function tokenPriceWithSettle(address poolAddress)
        public
        view
        returns (uint256)
    {

        IDHedge dhpool = IDHedge(poolAddress);
        IExchanger ex = IExchanger(addressResolver.getAddress(_EXCHANGER_KEY));

        uint256 totalValue = 0;
        bytes32[] memory supportedAssets = dhpool.getSupportedAssets();
        uint256 totalSupply = dhpool.totalSupply();

        require(totalSupply > 0, "pool is empty");

        for (uint256 i = 0; i < supportedAssets.length; i++) {
            uint256 assetTotal = IERC20(_getAssetProxy(supportedAssets[i]))
                .balanceOf(poolAddress);

            if (assetTotal > 0) {
                uint256 waitingPeriod = ex.maxSecsLeftInWaitingPeriod(
                    poolAddress,
                    supportedAssets[i]
                );
                require(waitingPeriod == 0, "wait for settlement");

                (
                    uint256 reclaimAmount,
                    uint256 rebateAmount,
                ) = ex.settlementOwing(poolAddress, supportedAssets[i]);

                if (rebateAmount > 0) {
                    assetTotal = assetTotal.add(rebateAmount);
                }
                if (reclaimAmount > 0) {
                    assetTotal = assetTotal.sub(reclaimAmount);
                }

                IExchangeRates exchangeRates = IExchangeRates(
                    addressResolver.getAddress(_EXCHANGE_RATES_KEY)
                );
                totalValue = totalValue.add(
                    exchangeRates
                        .rateForCurrency(supportedAssets[i])
                        .mul(assetTotal)
                        .div(10**18)
                );
            }
        }
        uint256 lastFeeMintPrice = dhpool.tokenPriceAtLastFeeMint();
        uint256 tokenPrice = totalValue.mul(10**18).div(totalSupply);

        if (lastFeeMintPrice.add(1000) < tokenPrice) {
            return tokenPrice.mul(totalSupply).div(_getTotalSupplyPostMint(poolAddress, tokenPrice, lastFeeMintPrice, totalSupply));
        } else {
            return tokenPrice;
        }
    }
    
    function getLastFeeMintPrice(address poolAddress) public view returns (uint256) {

        IDHedge dhpool = IDHedge(poolAddress);
        return dhpool.tokenPriceAtLastFeeMint();
    }

    function _getTotalSupplyPostMint(address poolAddress, uint256 tokenPrice, uint256 lastFeeMintPrice, uint256 totalSupply) internal view returns (uint256) {

        uint256 managerFeeNumerator;
        uint256 managerFeeDenominator;
        (managerFeeNumerator, managerFeeDenominator) = IHasFeeInfo(factory).getPoolManagerFee(poolAddress);
        uint256 priceFraction = tokenPrice.sub(lastFeeMintPrice).mul(managerFeeNumerator).div(managerFeeDenominator);
        return priceFraction.mul(totalSupply).div(tokenPrice).add(totalSupply);
    }

    function _getAssetProxy(bytes32 key) internal view returns (address) {

        address synth = ISynthetix(addressResolver.getAddress(_SYNTHETIX_KEY))
            .synths(key);
        require(synth != address(0), "invalid key");
        address proxy = ISynth(synth).proxy();
        require(proxy != address(0), "invalid proxy");
        return proxy;
    }

    modifier onlyDao() {

        require(msg.sender == dao, "only dao");
        _;
    }

}