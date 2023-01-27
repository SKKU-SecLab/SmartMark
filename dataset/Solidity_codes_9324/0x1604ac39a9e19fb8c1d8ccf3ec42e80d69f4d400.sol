
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
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

pragma solidity ^0.6.0;

interface IHegicETHOptionV888 {

    enum OptionType {Invalid, Put, Call}

    function create(
        uint256 period,
        uint256 amount,
        uint256 strike,
        OptionType optionType
    ) external payable returns (uint256 optionID);


    function exercise(uint256 optionID) external;


    function fees(
        uint256 period,
        uint256 amount,
        uint256 strike,
        uint8 optionType
    )
        external
        view
        returns (
            uint256 total,
            uint256 settlementFee,
            uint256 strikeFee,
            uint256 periodFee
        );


    function impliedVolRate() external view returns (uint256);


    function migrate(uint256 count) external;


    function optionCollateralizationRatio() external view returns (uint256);


    function options(uint256)
        external
        view
        returns (
            uint8 state,
            address holder,
            uint256 strike,
            uint256 amount,
            uint256 lockedAmount,
            uint256 premium,
            uint256 expiration,
            uint8 optionType
        );


    function owner() external view returns (address);


    function pool() external view returns (address);


    function priceProvider() external view returns (address);


    function renounceOwnership() external;


    function setImpliedVolRate(uint256 value) external;


    function setOldHegicETHOptions(address oldAddr) external;


    function setOptionCollaterizationRatio(uint256 value) external;


    function setSettlementFeeRecipient(address recipient) external;


    function settlementFeeRecipient() external view returns (address);


    function stopMigrationProcess() external;


    function transfer(uint256 optionID, address newHolder) external;


    function transferOwnership(address newOwner) external;


    function transferPoolOwnership() external;


    function unlock(uint256 optionID) external;


    function unlockAll(uint256[] calldata optionIDs) external;

}// MIT

pragma solidity ^0.6.0;

interface IHegicETHPoolV888 {

    function INITIAL_RATE() external view returns (uint256);


    function _revertTransfersInLockUpPeriod(address)
        external
        view
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);


    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);


    function lastProvideTimestamp(address) external view returns (uint256);


    function lockedAmount() external view returns (uint256);


    function lockedLiquidity(uint256)
        external
        view
        returns (
            uint256 amount,
            uint256 premium,
            bool locked
        );


    function lockedPremium() external view returns (uint256);


    function lockupPeriod() external view returns (uint256);


    function name() external view returns (string memory);


    function owner() external view returns (address);


    function renounceOwnership() external;


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function transferOwnership(address newOwner) external;


    function setLockupPeriod(uint256 value) external;


    function revertTransfersInLockUpPeriod(bool value) external;


    function provide(uint256 minMint) external returns (uint256 mint);


    function withdraw(uint256 amount, uint256 maxBurn)
        external
        returns (uint256 burn);


    function lock(uint256 id, uint256 amount) external;


    function unlock(uint256 id) external;


    function send(
        uint256 id,
        address to,
        uint256 amount
    ) external;


    function shareOf(address account) external view returns (uint256 share);


    function availableBalance() external view returns (uint256 balance);


    function totalBalance() external view returns (uint256 balance);

}// MIT

pragma solidity ^0.6.0;


contract DeriOneV1HegicV888 is Ownable {

    using SafeMath for uint256;


    IHegicETHOptionV888 private HegicETHOptionV888Instance;
    IHegicETHPoolV888 private HegicETHPoolV888Instance;

    IHegicETHOptionV888.OptionType optionType;

    struct TheCheapestETHPutOptionInHegicV888 {
        uint256 expiry;
        uint256 premiumInWEI;
        uint256 strikeInUSD;
    }

    TheCheapestETHPutOptionInHegicV888 theCheapestETHPutOptionInHegicV888;

    constructor(
        address _hegicETHOptionV888Address,
        address _hegicETHPoolV888Address
    ) public {
        instantiateHegicETHOptionV888(_hegicETHOptionV888Address);
        instantiateHegicETHPoolV888(_hegicETHPoolV888Address);
    }

    function instantiateHegicETHOptionV888(address _hegicETHOptionV888Address)
        public
        onlyOwner
    {

        HegicETHOptionV888Instance = IHegicETHOptionV888(
            _hegicETHOptionV888Address
        );
    }

    function instantiateHegicETHPoolV888(address _hegicETHPoolV888Address)
        public
        onlyOwner
    {

        HegicETHPoolV888Instance = IHegicETHPoolV888(_hegicETHPoolV888Address);
    }

    function hasEnoughETHLiquidityInHegicV888(uint256 _optionSizeInWEI)
        internal
        view
        returns (bool)
    {

        uint256 availableBalance =
            HegicETHPoolV888Instance.totalBalance().mul(8).div(10);
        uint256 amountUtilized =
            HegicETHPoolV888Instance.totalBalance().sub(
                HegicETHPoolV888Instance.availableBalance()
            );

        require(
            availableBalance > amountUtilized,
            "there is not enough available balance"
        );
        uint256 maxOptionSize = availableBalance.sub(amountUtilized);

        if (maxOptionSize > _optionSizeInWEI) {
            return true;
        } else if (maxOptionSize <= _optionSizeInWEI) {
            return false;
        }
    }

    function getTheCheapestETHPutOptionInHegicV888(
        uint256 _minExpiry,
        uint256 _optionSizeInWEI,
        uint256 _minStrikeInUSD
    ) internal {

        optionType = IHegicETHOptionV888.OptionType.Put;
        (uint256 minimumPremiumToPayInWEI, , , ) =
            HegicETHOptionV888Instance.fees(
                _minExpiry,
                _optionSizeInWEI,
                _minStrikeInUSD,
                uint8(optionType)
            );

        theCheapestETHPutOptionInHegicV888 = TheCheapestETHPutOptionInHegicV888(
            _minExpiry,
            minimumPremiumToPayInWEI,
            _minStrikeInUSD
        );
    }
}


pragma solidity ^0.6.0;

interface IOpynExchangeV1 {

    function premiumReceived(
        address oTokenAddress,
        address payoutTokenAddress,
        uint256 oTokensToSell
    ) external view returns (uint256);


    function sellOTokens(
        address receiver,
        address oTokenAddress,
        address payoutTokenAddress,
        uint256 oTokensToSell
    ) external;


    function buyOTokens(
        address receiver,
        address oTokenAddress,
        address paymentTokenAddress,
        uint256 oTokensToBuy
    ) external payable;


    function premiumToPay(
        address oTokenAddress,
        address paymentTokenAddress,
        uint256 oTokensToBuy
    ) external view returns (uint256);


    function UNISWAP_FACTORY() external view returns (address);


    function uniswapBuyOToken(
        address paymentToken,
        address oToken,
        uint256 _amt,
        address _transferTo
    ) external returns (uint256);

}// MIT

pragma solidity ^0.6.0;

interface IOpynOptionsFactoryV1 {

    function tokens(string calldata) external view returns (address);


    function changeAsset(string calldata _asset, address _addr) external;


    function optionsExchange() external view returns (address);


    function renounceOwnership() external;


    function getNumberOfOptionsContracts() external view returns (uint256);


    function owner() external view returns (address);


    function isOwner() external view returns (bool);


    function createOptionsContract(
        string calldata _collateralType,
        int32 _collateralExp,
        string calldata _underlyingType,
        int32 _underlyingExp,
        int32 _oTokenExchangeExp,
        uint256 _strikePrice,
        int32 _strikeExp,
        string calldata _strikeAsset,
        uint256 _expiry,
        uint256 _windowSize
    ) external returns (address);


    function oracleAddress() external view returns (address);


    function addAsset(string calldata _asset, address _addr) external;


    function supportsAsset(string calldata _asset) external view returns (bool);


    function deleteAsset(string calldata _asset) external;


    function optionsContracts(uint256) external view returns (address);


    function transferOwnership(address newOwner) external;

}// MIT

pragma solidity ^0.6.0;

interface IOpynOTokenV1 {

    function addERC20Collateral(address vaultOwner, uint256 amt)
        external
        returns (uint256);


    function getVaultOwners() external view returns (address[] memory);


    function name() external view returns (string memory);


    function approve(address spender, uint256 amount) external returns (bool);


    function hasVault(address owner) external view returns (bool);


    function isExerciseWindow() external view returns (bool);


    function getVault(address vaultOwner)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            bool
        );


    function totalSupply() external view returns (uint256);


    function issueOTokens(uint256 oTokensToIssue, address receiver) external;


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function decimals() external view returns (uint8);


    function addAndSellERC20CollateralOption(
        uint256 amtToCreate,
        uint256 amtCollateral,
        address receiver
    ) external;


    function removeCollateral(uint256 amtToRemove) external;


    function liquidationFactor()
        external
        view
        returns (uint256 value, int32 exponent);


    function createAndSellETHCollateralOption(
        uint256 amtToCreate,
        address receiver
    ) external payable;


    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);


    function optionsExchange() external view returns (address);


    function createERC20CollateralOption(
        uint256 amtToCreate,
        uint256 amtCollateral,
        address receiver
    ) external;


    function exercise(
        uint256 oTokensToExercise,
        address[] calldata vaultsToExerciseFrom
    ) external payable;


    function addERC20CollateralOption(
        uint256 amtToCreate,
        uint256 amtCollateral,
        address receiver
    ) external;


    function maxOTokensIssuable(uint256 collateralAmt)
        external
        view
        returns (uint256);


    function underlying() external view returns (address);


    function underlyingRequiredToExercise(uint256 oTokensToExercise)
        external
        view
        returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function renounceOwnership() external;


    function openVault() external returns (bool);


    function COMPOUND_ORACLE() external view returns (address);


    function liquidationIncentive()
        external
        view
        returns (uint256 value, int32 exponent);


    function owner() external view returns (address);


    function isOwner() external view returns (bool);


    function hasExpired() external view returns (bool);


    function symbol() external view returns (string memory);


    function addETHCollateral(address vaultOwner)
        external
        payable
        returns (uint256);


    function transactionFee()
        external
        view
        returns (uint256 value, int32 exponent);


    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function strike() external view returns (address);


    function underlyingExp() external view returns (int32);


    function collateralExp() external view returns (int32);


    function oTokenExchangeRate()
        external
        view
        returns (uint256 value, int32 exponent);


    function redeemVaultBalance() external;


    function setDetails(string calldata _name, string calldata _symbol) external;


    function addETHCollateralOption(uint256 amtToCreate, address receiver)
        external
        payable;


    function minCollateralizationRatio()
        external
        view
        returns (uint256 value, int32 exponent);


    function liquidate(address vaultOwner, uint256 oTokensToLiquidate) external;


    function strikePrice()
        external
        view
        returns (uint256 value, int32 exponent);


    function createAndSellERC20CollateralOption(
        uint256 amtToCreate,
        uint256 amtCollateral,
        address receiver
    ) external;


    function isUnsafe(address vaultOwner) external view returns (bool);


    function addAndSellETHCollateralOption(
        uint256 amtToCreate,
        address receiver
    ) external payable;


    function collateral() external view returns (address);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function maxOTokensLiquidatable(address vaultOwner)
        external
        view
        returns (uint256);


    function expiry() external view returns (uint256);


    function transferFee(address _address) external;


    function burnOTokens(uint256 amtToBurn) external;


    function createETHCollateralOption(uint256 amtToCreate, address receiver)
        external
        payable;


    function updateParameters(
        uint256 _liquidationIncentive,
        uint256 _liquidationFactor,
        uint256 _transactionFee,
        uint256 _minCollateralizationRatio
    ) external;


    function transferOwnership(address newOwner) external;


    function isETH(address _ierc20) external pure returns (bool);


    function removeUnderlying() external;

}// MIT

pragma solidity ^0.6.0;

interface IUniswapExchangeV1 {

    function tokenAddress() external view returns (address token);


    function factoryAddress() external view returns (address factory);


    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 deadline
    ) external payable returns (uint256);


    function removeLiquidity(
        uint256 amount,
        uint256 min_eth,
        uint256 min_tokens,
        uint256 deadline
    ) external returns (uint256, uint256);


    function getEthToTokenInputPrice(uint256 eth_sold)
        external
        view
        returns (uint256 tokens_bought);


    function getEthToTokenOutputPrice(uint256 tokens_bought)
        external
        view
        returns (uint256 eth_sold);


    function getTokenToEthInputPrice(uint256 tokens_sold)
        external
        view
        returns (uint256 eth_bought);


    function getTokenToEthOutputPrice(uint256 eth_bought)
        external
        view
        returns (uint256 tokens_sold);


    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256 tokens_bought);


    function ethToTokenTransferInput(
        uint256 min_tokens,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256 tokens_bought);


    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline)
        external
        payable
        returns (uint256 eth_sold);


    function ethToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256 eth_sold);


    function tokenToEthSwapInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline
    ) external returns (uint256 eth_bought);


    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient
    ) external returns (uint256 eth_bought);


    function tokenToEthSwapOutput(
        uint256 eth_bought,
        uint256 max_tokens,
        uint256 deadline
    ) external returns (uint256 tokens_sold);


    function tokenToEthTransferOutput(
        uint256 eth_bought,
        uint256 max_tokens,
        uint256 deadline,
        address recipient
    ) external returns (uint256 tokens_sold);


    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address token_addr
    ) external returns (uint256 tokens_bought);


    function tokenToTokenTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256 tokens_bought);


    function tokenToTokenSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address token_addr
    ) external returns (uint256 tokens_sold);


    function tokenToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256 tokens_sold);


    function tokenToExchangeSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address exchange_addr
    ) external returns (uint256 tokens_bought);


    function tokenToExchangeTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address exchange_addr
    ) external returns (uint256 tokens_bought);


    function tokenToExchangeSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address exchange_addr
    ) external returns (uint256 tokens_sold);


    function tokenToExchangeTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_eth_sold,
        uint256 deadline,
        address recipient,
        address exchange_addr
    ) external returns (uint256 tokens_sold);


    function name() external returns (bytes32 out);


    function symbol() external returns (bytes32 out);


    function decimals() external returns (uint256 out);


    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(
        address _from,
        address _to,
        uint256 value
    ) external returns (bool);


    function approve(address _spender, uint256 _value) external returns (bool);


    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);


    function balanceOf(address _owner) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function setup(address token_addr) external;

}// MIT

pragma solidity ^0.6.0;

interface IUniswapFactoryV1 {

    function initializeFactory(address template) external;


    function createExchange(address token) external returns (address out);


    function getExchange(address token) external returns (address out);


    function getToken(address exchange) external returns (address out);


    function getTokenWithId(uint256 token_id) external returns (address out);


    function exchangeTemplate() external returns (address out);


    function tokenCount() external returns (uint256 out);

}// MIT

pragma solidity ^0.6.0;


contract DeriOneV1OpynV1 is Ownable {

    using SafeMath for uint256;


    IOpynExchangeV1 private OpynExchangeV1Instance;
    IOpynOptionsFactoryV1 private OpynOptionsFactoryV1Instance;
    IOpynOTokenV1[] private oTokenV1InstanceList;
    IOpynOTokenV1[] private WETHPutOptionOTokenV1InstanceList;
    IOpynOTokenV1[] private matchedWETHPutOptionOTokenV1InstanceList;
    IUniswapExchangeV1 private UniswapExchangeV1Instance;
    IUniswapFactoryV1 private UniswapFactoryV1Instance;

    address constant USDCTokenAddress =
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETHTokenAddress =
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address[] private oTokenAddressList;
    address[] private unexpiredOTokenAddressList;
    address[] private matchedWETHPutOptionOTokenAddressList;

    struct MatchedWETHPutOptionOTokenV1 {
        address oTokenAddress;
        uint256 expiry;
        uint256 premiumInWEI;
        uint256 strikeInUSD; // scaled by 10 ** 7 for the USDC denominator
    }

    struct TheCheapestWETHPutOptionInOpynV1 {
        address oTokenAddress;
        uint256 expiry;
        uint256 premiumInWEI;
        uint256 strikeInUSD; // scaled by 10 ** 7 for the USDC denominator
    }

    MatchedWETHPutOptionOTokenV1[] matchedWETHPutOptionOTokenListV1;

    TheCheapestWETHPutOptionInOpynV1 theCheapestWETHPutOptionInOpynV1;


    constructor(
        address _opynExchangeV1Address,
        address _opynOptionsFactoryV1Address,
        address _uniswapFactoryV1Address
    ) public {
        instantiateOpynExchangeV1(_opynExchangeV1Address);
        instantiateOpynOptionsFactoryV1(_opynOptionsFactoryV1Address);
        instantiateUniswapFactoryV1(_uniswapFactoryV1Address);
    }

    function instantiateOpynExchangeV1(address _opynExchangeV1Address)
        public
        onlyOwner
    {

        OpynExchangeV1Instance = IOpynExchangeV1(_opynExchangeV1Address);
    }

    function instantiateOpynOptionsFactoryV1(
        address _opynOptionsFactoryV1Address
    ) public onlyOwner {

        OpynOptionsFactoryV1Instance = IOpynOptionsFactoryV1(
            _opynOptionsFactoryV1Address
        );
    }

    function instantiateUniswapFactoryV1(address _uniswapFactoryV1Address)
        public
        onlyOwner
    {

        UniswapFactoryV1Instance = IUniswapFactoryV1(_uniswapFactoryV1Address);
    }

    function _instantiateOpynOTokenV1(address[] memory _opynOTokenV1AddressList)
        private
    {

        for (uint256 i = 0; i < _opynOTokenV1AddressList.length; i++) {
            oTokenV1InstanceList.push(
                IOpynOTokenV1(_opynOTokenV1AddressList[i])
            );
        }
    }

    function _instantiateUniswapExchangeV1(address _uniswapExchangeV1Address)
        private
    {

        UniswapExchangeV1Instance = IUniswapExchangeV1(
            _uniswapExchangeV1Address
        );
    }

    function _getWETHPutOptionsOTokenAddressList() private {

        uint256 theNumberOfOTokenAddresses =
            OpynOptionsFactoryV1Instance.getNumberOfOptionsContracts();
        for (uint256 i = 0; i < theNumberOfOTokenAddresses; i++) {
            oTokenAddressList.push(
                OpynOptionsFactoryV1Instance.optionsContracts(i)
            );
        }
        _instantiateOpynOTokenV1(oTokenAddressList);
        for (uint256 i = 0; i < oTokenV1InstanceList.length; i++) {
            if (
                oTokenV1InstanceList[i].underlying() == WETHTokenAddress &&
                oTokenV1InstanceList[i].strike() == USDCTokenAddress //the asset in which the insurance is calculated
            ) {
                WETHPutOptionOTokenV1InstanceList.push(oTokenV1InstanceList[i]);
                unexpiredOTokenAddressList.push(oTokenAddressList[i]);
            }
        }
    }

    function _calculateStrike(IOpynOTokenV1 _oTokenV1Instance)
        private
        view
        returns (uint256)
    {

        uint256 strike;
        (uint256 value, int32 exponent) = _oTokenV1Instance.strikePrice();
        if (exponent >= 0) {
            strike = value.mul(uint256(10)**uint256(exponent)).mul(10**7);
        } else {
            strike = value.mul(
                uint256(1).mul(10**7).div(10**uint256(0 - exponent))
            );
        }
        return strike;
    }

    function _filterWETHPutOptionsOTokenAddresses(
        uint256 _minStrikeInUSD,
        uint256 _maxStrikeInUSD
    ) private {

        for (uint256 i = 0; i < WETHPutOptionOTokenV1InstanceList.length; i++) {
            uint256 strike =
                _calculateStrike(WETHPutOptionOTokenV1InstanceList[i]);
            strike = strike.mul(10**8);
            if (
                _minStrikeInUSD < strike && strike < _maxStrikeInUSD
            ) {
                matchedWETHPutOptionOTokenV1InstanceList.push(
                    WETHPutOptionOTokenV1InstanceList[i]
                );
                matchedWETHPutOptionOTokenAddressList.push(
                    unexpiredOTokenAddressList[i]
                );
            }
        }
    }

    function _getOpynV1Premium(
        IOpynOTokenV1 _matchedWETHPutOptionOTokenV1Instance,
        address _matchedWETHPutOptionOTokenAddress,
        uint256 _strike,
        uint256 _oTokensToBuy
    ) private view returns (uint256) {

        address oTokenAddress;
        uint256 strikePrice =
            _calculateStrike(_matchedWETHPutOptionOTokenV1Instance);

        if (strikePrice == _strike) {
            oTokenAddress = _matchedWETHPutOptionOTokenAddress;
        }

        uint256 premiumToPayInWEI;
        if (oTokenAddress != address(0)) {
            premiumToPayInWEI = OpynExchangeV1Instance.premiumToPay(
                oTokenAddress,
                address(0), // pay with ETH
                _oTokensToBuy
            );
        } else {
            premiumToPayInWEI = 2**256 - 1;
        }
        return premiumToPayInWEI;
    }

    function _constructMatchedWETHPutOptionOTokenListV1(
        uint256 _optionSizeInWEI
    ) private {

        for (
            uint256 i = 0;
            i < matchedWETHPutOptionOTokenV1InstanceList.length;
            i++
        ) {
            uint256 strikePrice =
                _calculateStrike(matchedWETHPutOptionOTokenV1InstanceList[i]);
            address uniswapExchangeContractAddress =
                UniswapFactoryV1Instance.getExchange(
                    matchedWETHPutOptionOTokenAddressList[i]
                );
            if (uniswapExchangeContractAddress != address(0)) {
                _instantiateUniswapExchangeV1(uniswapExchangeContractAddress);
                uint256 oTokensToBuy =
                    UniswapExchangeV1Instance.getEthToTokenInputPrice(
                        _optionSizeInWEI
                    );
                matchedWETHPutOptionOTokenListV1.push(
                    MatchedWETHPutOptionOTokenV1(
                        matchedWETHPutOptionOTokenAddressList[i],
                        matchedWETHPutOptionOTokenV1InstanceList[i].expiry(),
                        _getOpynV1Premium(
                            matchedWETHPutOptionOTokenV1InstanceList[i],
                            matchedWETHPutOptionOTokenAddressList[i],
                            strikePrice,
                            oTokensToBuy
                        ),
                        strikePrice
                    )
                );
            }
        }
    }

    function hasEnoughOTokenLiquidityInOpynV1(uint256 _optionSizeInWEI)
        internal
        returns (bool)
    {

        address uniswapExchangeContractAddress =
            UniswapFactoryV1Instance.getExchange(
                theCheapestWETHPutOptionInOpynV1.oTokenAddress
            );
        if (uniswapExchangeContractAddress == address(0)) {
            return true;
        }
        IOpynOTokenV1 theCheapestOTokenV1Instance =
            IOpynOTokenV1(theCheapestWETHPutOptionInOpynV1.oTokenAddress);
        uint256 oTokenLiquidity =
            theCheapestOTokenV1Instance.balanceOf(
                uniswapExchangeContractAddress
            );

        uint256 oTokenExchangeRate;
        (uint256 value, int32 exponent) =
            theCheapestOTokenV1Instance.oTokenExchangeRate();
        if (exponent >= 0) {
            oTokenExchangeRate = value.mul(uint256(10)**uint256(exponent)).mul(
                10**9
            );
        } else {
            oTokenExchangeRate = value.mul(
                uint256(1).mul(10**9).div(10**uint256(0 - exponent))
            );
        }
        uint256 optionSizeInOToken = _optionSizeInWEI.div(oTokenExchangeRate);

        oTokenLiquidity = oTokenLiquidity.mul(10**9);

        if (optionSizeInOToken < oTokenLiquidity) {
            return true;
        } else {
            return false;
        }
    }

    function getTheCheapestETHPutOptionInOpynV1(
        uint256 _minStrikeInUSD,
        uint256 _maxStrikeInUSD,
        uint256 _optionSizeInWEI
    ) internal {

        _getWETHPutOptionsOTokenAddressList();
        _filterWETHPutOptionsOTokenAddresses(
            _minStrikeInUSD,
            _maxStrikeInUSD
        );
        _constructMatchedWETHPutOptionOTokenListV1(_optionSizeInWEI);
        if (matchedWETHPutOptionOTokenListV1.length > 0) {
            uint256 minimumPremium =
                matchedWETHPutOptionOTokenListV1[0].premiumInWEI;
            for (
                uint256 i = 0;
                i < matchedWETHPutOptionOTokenListV1.length - 1;
                i++
            ) {
                if (
                    minimumPremium >
                    matchedWETHPutOptionOTokenListV1[i + 1].premiumInWEI
                ) {
                    minimumPremium = matchedWETHPutOptionOTokenListV1[i + 1]
                        .premiumInWEI;
                }
            }

            for (
                uint256 i = 0;
                i < matchedWETHPutOptionOTokenListV1.length;
                i++
            ) {
                if (
                    minimumPremium ==
                    matchedWETHPutOptionOTokenListV1[i].premiumInWEI
                ) {
                    theCheapestWETHPutOptionInOpynV1 = TheCheapestWETHPutOptionInOpynV1(
                        matchedWETHPutOptionOTokenAddressList[i],
                        matchedWETHPutOptionOTokenListV1[i].expiry,
                        minimumPremium,
                        matchedWETHPutOptionOTokenListV1[i].strikeInUSD
                    );
                }
            }
        }
    }
}// MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


contract DeriOneV1Main is DeriOneV1HegicV888, DeriOneV1OpynV1 {

    enum Protocol {HegicV888, OpynV1}
    struct TheCheapestETHPutOption {
        Protocol protocol;
        address oTokenAddress;
        address paymentTokenAddress;
        uint256 expiry;
        uint256 optionSizeInWEI;
        uint256 premiumInWEI;
        uint256 strikeInUSD;
    }

    TheCheapestETHPutOption private _theCheapestETHPutOption;

    event TheCheapestETHPutOptionGot(string protocolName);

    constructor(
        address _hegicETHOptionV888Address,
        address _hegicETHPoolV888Address,
        address _opynExchangeV1Address,
        address _opynOptionsFactoryV1Address,
        address _uniswapFactoryV1Address
    )
        public
        DeriOneV1HegicV888(_hegicETHOptionV888Address, _hegicETHPoolV888Address)
        DeriOneV1OpynV1(
            _opynExchangeV1Address,
            _opynOptionsFactoryV1Address,
            _uniswapFactoryV1Address
        )
    {}

    function theCheapestETHPutOption()
        public
        view
        returns (TheCheapestETHPutOption memory)
    {

        return _theCheapestETHPutOption;
    }

    function getTheCheapestETHPutOption(
        uint256 _minExpiry,
        uint256 _minStrikeInUSD,
        uint256 _maxStrikeInUSD,
        uint256 _optionSizeInWEI
    ) public returns (TheCheapestETHPutOption memory) {

        getTheCheapestETHPutOptionInHegicV888(
            _minExpiry,
            _optionSizeInWEI,
            _minStrikeInUSD
        );
        require(
            hasEnoughETHLiquidityInHegicV888(_optionSizeInWEI) == true,
            "your size is too big for liquidity in the Hegic V888"
        );
        getTheCheapestETHPutOptionInOpynV1(
            _minStrikeInUSD,
            _maxStrikeInUSD,
            _optionSizeInWEI
        );
        require(
            hasEnoughOTokenLiquidityInOpynV1(_optionSizeInWEI) == true,
            "your size is too big for this oToken liquidity in the Opyn V1"
        );
        if (
            theCheapestETHPutOptionInHegicV888.premiumInWEI <
            theCheapestWETHPutOptionInOpynV1.premiumInWEI ||
            matchedWETHPutOptionOTokenListV1.length == 0
        ) {
            _theCheapestETHPutOption = TheCheapestETHPutOption(
                Protocol.HegicV888,
                address(0), // NA
                address(0), // NA
                theCheapestETHPutOptionInHegicV888.expiry,
                _optionSizeInWEI,
                theCheapestETHPutOptionInHegicV888.premiumInWEI,
                theCheapestETHPutOptionInHegicV888.strikeInUSD
            );
            emit TheCheapestETHPutOptionGot("hegic v888");
            return _theCheapestETHPutOption;
        } else if (
            theCheapestETHPutOptionInHegicV888.premiumInWEI >
            theCheapestWETHPutOptionInOpynV1.premiumInWEI &&
            matchedWETHPutOptionOTokenListV1.length > 0
        ) {
            _theCheapestETHPutOption = TheCheapestETHPutOption(
                Protocol.OpynV1,
                theCheapestWETHPutOptionInOpynV1.oTokenAddress,
                address(0), // ETH
                theCheapestWETHPutOptionInOpynV1.expiry,
                _optionSizeInWEI,
                theCheapestWETHPutOptionInOpynV1.premiumInWEI,
                theCheapestWETHPutOptionInOpynV1.strikeInUSD
            );
            emit TheCheapestETHPutOptionGot("opyn v1");
            return _theCheapestETHPutOption;
        } else {
            emit TheCheapestETHPutOptionGot("no matches");
        }
    }
}