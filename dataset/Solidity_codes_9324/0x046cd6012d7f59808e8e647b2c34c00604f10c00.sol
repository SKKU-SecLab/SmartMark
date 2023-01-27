pragma solidity 0.6.9;

interface IIdeaTokenExchangeStateTransfer {

    function initializeStateTransfer(address transferManager, address l2InterestManager, address l1Inbox) external;

    function transferStaticVars(uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable returns (uint);

    function transferPlatformVars(uint marketID, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable returns (uint);

    function transferTokenVars(uint marketID, uint[] calldata tokenIDs, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable returns (uint);

    function transferIdeaTokens(uint marketID, uint tokenID, address l2Recipient, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable returns (uint);

    function setTokenTransferEnabled() external;

}

pragma solidity 0.6.9;

contract Ownable {


    address _owner;

    event OwnershipChanged(address oldOwner, address newOwner);

    modifier onlyOwner {

        require(_owner == msg.sender, "only-owner");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {

        setOwnerInternal(newOwner);
    }

    function setOwnerInternal(address newOwner) internal {

        require(newOwner != address(0), "zero-addr");

        address oldOwner = _owner;
        _owner = newOwner;

        emit OwnershipChanged(oldOwner, newOwner);
    }

    function getOwner() external view returns (address) {

        return _owner;
    }
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
}
pragma solidity 0.6.9;


interface IIdeaToken is IERC20 {

    function initialize(string calldata __name, address owner) external;

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

}// MIT
pragma solidity 0.6.9;

interface IIdeaTokenNameVerifier {

    function verifyTokenName(string calldata name) external pure returns (bool);

}// MIT
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;



struct IDPair {
    bool exists;
    uint marketID;
    uint tokenID;
}

struct TokenInfo {
    bool exists;
    uint id;
    string name;
    IIdeaToken ideaToken;
}

struct MarketDetails {
    bool exists;
    uint id;
    string name;

    IIdeaTokenNameVerifier nameVerifier;
    uint numTokens;

    uint baseCost;
    uint priceRise;
    uint hatchTokens;
    uint tradingFeeRate;
    uint platformFeeRate;

    bool allInterestToPlatform;
}

interface IIdeaTokenFactory {

    function addMarket(string calldata marketName, address nameVerifier,
                       uint baseCost, uint priceRise, uint hatchTokens,
                       uint tradingFeeRate, uint platformFeeRate, bool allInterestToPlatform) external;


    function addToken(string calldata tokenName, uint marketID, address lister) external;


    function isValidTokenName(string calldata tokenName, uint marketID) external view returns (bool);

    function getMarketIDByName(string calldata marketName) external view returns (uint);

    function getMarketDetailsByID(uint marketID) external view returns (MarketDetails memory);

    function getMarketDetailsByName(string calldata marketName) external view returns (MarketDetails memory);

    function getMarketDetailsByTokenAddress(address ideaToken) external view returns (MarketDetails memory);

    function getNumMarkets() external view returns (uint);

    function getTokenIDByName(string calldata tokenName, uint marketID) external view returns (uint);

    function getTokenInfo(uint marketID, uint tokenID) external view returns (TokenInfo memory);

    function getTokenIDPair(address token) external view returns (IDPair memory);

    function setTradingFee(uint marketID, uint tradingFeeRate) external;

    function setPlatformFee(uint marketID, uint platformFeeRate) external;

    function setNameVerifier(uint marketID, address nameVerifier) external;

}// MIT
pragma solidity 0.6.9;



struct CostAndPriceAmounts {
    uint total;
    uint raw;
    uint tradingFee;
    uint platformFee;
}

interface IIdeaTokenExchange {

    function sellTokens(address ideaToken, uint amount, uint minPrice, address recipient) external;

    function getPriceForSellingTokens(address ideaToken, uint amount) external view returns (uint);

    function getPricesForSellingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) external pure returns (CostAndPriceAmounts memory);

    function buyTokens(address ideaToken, uint amount, uint fallbackAmount, uint cost, address recipient) external;

    function getCostForBuyingTokens(address ideaToken, uint amount) external view returns (uint);

    function getCostsForBuyingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) external pure returns (CostAndPriceAmounts memory);

    function setTokenOwner(address ideaToken, address owner) external;

    function setPlatformOwner(uint marketID, address owner) external;

    function withdrawTradingFee() external;

    function withdrawTokenInterest(address token) external;

    function withdrawPlatformInterest(uint marketID) external;

    function withdrawPlatformFee(uint marketID) external;

    function getInterestPayable(address token) external view returns (uint);

    function getPlatformInterestPayable(uint marketID) external view returns (uint);

    function getPlatformFeePayable(uint marketID) external view returns (uint);

    function getTradingFeePayable() external view returns (uint);

    function setAuthorizer(address authorizer) external;

    function isTokenFeeDisabled(address ideaToken) external view returns (bool);

    function setTokenFeeKillswitch(address ideaToken, bool set) external;

}// MIT
pragma solidity 0.6.9;

interface IInterestManager {

    function invest(uint amount) external returns (uint);

    function redeem(address recipient, uint amount) external returns (uint);

    function redeemInvestmentToken(address recipient, uint amount) external returns (uint);

    function donateInterest(uint amount) external;

    function redeemDonated(uint amount) external;

    function accrueInterest() external;

    function underlyingToInvestmentToken(uint underlyingAmount) external view returns (uint);

    function investmentTokenToUnderlying(uint investmentTokenAmount) external view returns (uint);

}// MIT

pragma solidity 0.6.9;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "already-initialized");

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
}// MIT

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
pragma solidity 0.6.9;


contract IdeaTokenExchange is IIdeaTokenExchange, Initializable, Ownable {

    using SafeMath for uint256;

    struct ExchangeInfo {
        uint dai;
        uint invested; 
    }

    uint constant FEE_SCALE = 10000;

    address _authorizer;

    uint _tradingFeeInvested; 
    address _tradingFeeRecipient;

    mapping(uint => address) _platformOwner;

    mapping(uint => uint) _platformFeeInvested;
    

    mapping(uint => ExchangeInfo) _platformsExchangeInfo;

    mapping(address => address) _tokenOwner;
    mapping(address => ExchangeInfo) _tokensExchangeInfo;

    IIdeaTokenFactory _ideaTokenFactory;
    IInterestManager _interestManager;
    IERC20 _dai;

    mapping(address => bool) _tokenFeeKillswitch;

    event NewTokenOwner(address ideaToken, address owner);
    event NewPlatformOwner(uint marketID, address owner);

    event InvestedState(uint marketID, address ideaToken, uint dai, uint daiInvested, uint tradingFeeInvested, uint platformFeeInvested, uint volume);
    
    event PlatformInterestRedeemed(uint marketID, uint investmentToken, uint daiRedeemed);
    event TokenInterestRedeemed(address ideaToken, uint investmentToken, uint daiRedeemed);
    event TradingFeeRedeemed(uint daiRedeemed);
    event PlatformFeeRedeemed(uint marketID, uint daiRedeemed);
    
    function initialize(address owner,
                        address authorizer,
                        address tradingFeeRecipient,
                        address interestManager,
                        address dai) external virtual initializer {

        require(authorizer != address(0) &&
                tradingFeeRecipient != address(0) &&
                interestManager != address(0) &&
                dai != address(0),
                "invalid-params");

        setOwnerInternal(owner); // Checks owner to be non-zero
        _authorizer = authorizer;
        _tradingFeeRecipient = tradingFeeRecipient;
        _interestManager = IInterestManager(interestManager);
        _dai = IERC20(dai);
    }

    function sellTokens(address ideaToken, uint amount, uint minPrice, address recipient) external virtual override {


        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByTokenAddress(ideaToken);
        require(marketDetails.exists, "token-not-exist");
        uint marketID = marketDetails.id;

        CostAndPriceAmounts memory amounts = getPricesForSellingTokens(marketDetails, IERC20(ideaToken).totalSupply(), amount, _tokenFeeKillswitch[ideaToken]);

        require(amounts.total >= minPrice, "below-min-price");
        require(IIdeaToken(ideaToken).balanceOf(msg.sender) >= amount, "insufficient-tokens");
        
        IIdeaToken(ideaToken).burn(msg.sender, amount);

        _interestManager.accrueInterest();

        ExchangeInfo storage exchangeInfo;
        if(marketDetails.allInterestToPlatform) {
            exchangeInfo = _platformsExchangeInfo[marketID];
        } else {
            exchangeInfo = _tokensExchangeInfo[ideaToken];
        }

        uint tradingFeeInvested;
        uint platformFeeInvested;
        uint invested;
        uint dai;
        {
        uint totalRedeemed = _interestManager.redeem(address(this), amounts.total);
        uint tradingFeeRedeemed = _interestManager.underlyingToInvestmentToken(amounts.tradingFee);
        uint platformFeeRedeemed = _interestManager.underlyingToInvestmentToken(amounts.platformFee);

        invested = exchangeInfo.invested.sub(totalRedeemed.add(tradingFeeRedeemed).add(platformFeeRedeemed));
        exchangeInfo.invested = invested;
        tradingFeeInvested = _tradingFeeInvested.add(tradingFeeRedeemed);
        _tradingFeeInvested = tradingFeeInvested;
        platformFeeInvested = _platformFeeInvested[marketID].add(platformFeeRedeemed);
        _platformFeeInvested[marketID] = platformFeeInvested;
        dai = exchangeInfo.dai.sub(amounts.raw);
        exchangeInfo.dai = dai;
        }

        emit InvestedState(marketID, ideaToken, dai, invested, tradingFeeInvested, platformFeeInvested, amounts.raw);
        require(_dai.transfer(recipient, amounts.total), "dai-transfer");
    }


    function getPriceForSellingTokens(address ideaToken, uint amount) external virtual view override returns (uint) {

        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByTokenAddress(ideaToken);
        return getPricesForSellingTokens(marketDetails, IERC20(ideaToken).totalSupply(), amount, _tokenFeeKillswitch[ideaToken]).total;
    }

    function getPricesForSellingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) public virtual pure override returns (CostAndPriceAmounts memory) {

        
        uint rawPrice = getRawPriceForSellingTokens(marketDetails.baseCost,
                                                    marketDetails.priceRise,
                                                    marketDetails.hatchTokens,
                                                    supply,
                                                    amount);

        uint tradingFee = 0;
        uint platformFee = 0;

        if(!feesDisabled) {
            tradingFee = rawPrice.mul(marketDetails.tradingFeeRate).div(FEE_SCALE);
            platformFee = rawPrice.mul(marketDetails.platformFeeRate).div(FEE_SCALE);
        }   
        
        uint totalPrice = rawPrice.sub(tradingFee).sub(platformFee);

        return CostAndPriceAmounts({
            total: totalPrice,
            raw: rawPrice,
            tradingFee: tradingFee,
            platformFee: platformFee
        });
    }

    function getRawPriceForSellingTokens(uint baseCost, uint priceRise, uint hatchTokens, uint supply, uint amount) internal virtual pure returns (uint) {


        uint hatchPrice = 0;
        uint updatedAmount = amount;
        uint updatedSupply;

        if(supply.sub(amount) < hatchTokens) {

            if(supply <= hatchTokens) {
                return baseCost.mul(amount).div(10**18);
            }

            uint tokensInHatch = hatchTokens - (supply - amount);
            hatchPrice = baseCost.mul(tokensInHatch).div(10**18);
            updatedAmount = amount.sub(tokensInHatch);
            updatedSupply = supply - hatchTokens;
        } else {
            updatedSupply = supply - hatchTokens;
        }

        uint priceAtSupply = baseCost.add(priceRise.mul(updatedSupply).div(10**18));
        uint priceAtSupplyMinusAmount = baseCost.add(priceRise.mul(updatedSupply.sub(updatedAmount)).div(10**18));
        uint average = priceAtSupply.add(priceAtSupplyMinusAmount).div(2);
    
        return hatchPrice.add(average.mul(updatedAmount).div(10**18));
    }

    function buyTokens(address ideaToken, uint amount, uint fallbackAmount, uint cost, address recipient) external virtual override {

        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByTokenAddress(ideaToken);
        require(marketDetails.exists, "token-not-exist");
        uint marketID = marketDetails.id;

        uint supply = IERC20(ideaToken).totalSupply();
        bool feesDisabled = _tokenFeeKillswitch[ideaToken];
        uint actualAmount = amount;

        CostAndPriceAmounts memory amounts = getCostsForBuyingTokens(marketDetails, supply, actualAmount, feesDisabled);

        if(amounts.total > cost) {
            actualAmount = fallbackAmount;
            amounts = getCostsForBuyingTokens(marketDetails, supply, actualAmount, feesDisabled);
    
            require(amounts.total <= cost, "slippage");
        }

        
        require(_dai.allowance(msg.sender, address(this)) >= amounts.total, "insufficient-allowance");
        require(_dai.transferFrom(msg.sender, address(_interestManager), amounts.total), "dai-transfer");
        
        _interestManager.accrueInterest();
        _interestManager.invest(amounts.total);


        ExchangeInfo storage exchangeInfo;
        if(marketDetails.allInterestToPlatform) {
            exchangeInfo = _platformsExchangeInfo[marketID];
        } else {
            exchangeInfo = _tokensExchangeInfo[ideaToken];
        }

        exchangeInfo.invested = exchangeInfo.invested.add(_interestManager.underlyingToInvestmentToken(amounts.raw));
        uint tradingFeeInvested = _tradingFeeInvested.add(_interestManager.underlyingToInvestmentToken(amounts.tradingFee));
        _tradingFeeInvested = tradingFeeInvested;
        uint platformFeeInvested = _platformFeeInvested[marketID].add(_interestManager.underlyingToInvestmentToken(amounts.platformFee));
        _platformFeeInvested[marketID] = platformFeeInvested;
        exchangeInfo.dai = exchangeInfo.dai.add(amounts.raw);
    
        emit InvestedState(marketID, ideaToken, exchangeInfo.dai, exchangeInfo.invested, tradingFeeInvested, platformFeeInvested, amounts.total);
        IIdeaToken(ideaToken).mint(recipient, actualAmount);
    }

    function getCostForBuyingTokens(address ideaToken, uint amount) external virtual view override returns (uint) {

        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByTokenAddress(ideaToken);

        return getCostsForBuyingTokens(marketDetails, IERC20(ideaToken).totalSupply(), amount, _tokenFeeKillswitch[ideaToken]).total;
    }

    function getCostsForBuyingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) public virtual pure override returns (CostAndPriceAmounts memory) {

        uint rawCost = getRawCostForBuyingTokens(marketDetails.baseCost,
                                                 marketDetails.priceRise,
                                                 marketDetails.hatchTokens,
                                                 supply,
                                                 amount);

        uint tradingFee = 0;
        uint platformFee = 0;

        if(!feesDisabled) {
            tradingFee = rawCost.mul(marketDetails.tradingFeeRate).div(FEE_SCALE);
            platformFee = rawCost.mul(marketDetails.platformFeeRate).div(FEE_SCALE);
        }
        
        uint totalCost = rawCost.add(tradingFee).add(platformFee);

        return CostAndPriceAmounts({
            total: totalCost,
            raw: rawCost,
            tradingFee: tradingFee,
            platformFee: platformFee
        });
    }

    function getRawCostForBuyingTokens(uint baseCost, uint priceRise, uint hatchTokens, uint supply, uint amount) internal virtual pure returns (uint) {


        uint hatchCost = 0;
        uint updatedAmount = amount;
        uint updatedSupply;

        if(supply < hatchTokens) {
            uint remainingHatchTokens = hatchTokens - supply;

            if(amount <= remainingHatchTokens) {
                return baseCost.mul(amount).div(10**18);
            }

            hatchCost = baseCost.mul(remainingHatchTokens).div(10**18);
            updatedSupply = 0;
            updatedAmount = amount - remainingHatchTokens;
        } else {
            updatedSupply = supply - hatchTokens;
        }

        uint priceAtSupply = baseCost.add(priceRise.mul(updatedSupply).div(10**18));
        uint priceAtSupplyPlusAmount = baseCost.add(priceRise.mul(updatedSupply.add(updatedAmount)).div(10**18));
        uint average = priceAtSupply.add(priceAtSupplyPlusAmount).div(2);

        return hatchCost.add(average.mul(updatedAmount).div(10**18));
    }

    function withdrawTokenInterest(address token) external virtual override {

        require(_tokenOwner[token] == msg.sender, "not-authorized");
        _interestManager.accrueInterest();

        uint interestPayable = getInterestPayable(token);
        if(interestPayable == 0) {
            return;
        }

        ExchangeInfo storage exchangeInfo = _tokensExchangeInfo[token];
        exchangeInfo.invested = exchangeInfo.invested.sub(_interestManager.redeem(msg.sender, interestPayable));

        emit TokenInterestRedeemed(token, exchangeInfo.invested, interestPayable);
    }

    function getInterestPayable(address token) public virtual view override returns (uint) {

        ExchangeInfo storage exchangeInfo = _tokensExchangeInfo[token];
        return _interestManager.investmentTokenToUnderlying(exchangeInfo.invested).sub(exchangeInfo.dai);
    }

    function setTokenOwner(address token, address owner) external virtual override {

        address sender = msg.sender;
        address current = _tokenOwner[token];

        require((current == address(0) && (sender == _owner || sender == _authorizer)) ||
                (current != address(0) && (sender == _owner || sender == current)),
                "not-authorized");

        _tokenOwner[token] = owner;

        emit NewTokenOwner(token, owner);
    }

    function withdrawPlatformInterest(uint marketID) external virtual override {

        address sender = msg.sender;

        require(_platformOwner[marketID] == sender, "not-authorized");
        _interestManager.accrueInterest();

        uint platformInterestPayable = getPlatformInterestPayable(marketID);
        if(platformInterestPayable == 0) {
            return;
        }

        ExchangeInfo storage exchangeInfo = _platformsExchangeInfo[marketID];
        exchangeInfo.invested = exchangeInfo.invested.sub(_interestManager.redeem(sender, platformInterestPayable));

        emit PlatformInterestRedeemed(marketID, exchangeInfo.invested, platformInterestPayable);
    }

    function getPlatformInterestPayable(uint marketID) public virtual view override returns (uint) {

        ExchangeInfo storage exchangeInfo = _platformsExchangeInfo[marketID];
        return _interestManager.investmentTokenToUnderlying(exchangeInfo.invested).sub(exchangeInfo.dai);
    }

    function withdrawPlatformFee(uint marketID) external virtual override {

        address sender = msg.sender;
    
        require(_platformOwner[marketID] == sender, "not-authorized");
        _interestManager.accrueInterest();

        uint platformFeePayable = getPlatformFeePayable(marketID);
        if(platformFeePayable == 0) {
            return;
        }

        _platformFeeInvested[marketID] = 0;
        _interestManager.redeem(sender, platformFeePayable);

        emit PlatformFeeRedeemed(marketID, platformFeePayable);
    }

    function getPlatformFeePayable(uint marketID) public virtual view override returns (uint) {

        return _interestManager.investmentTokenToUnderlying(_platformFeeInvested[marketID]);
    }

    function setPlatformOwner(uint marketID, address owner) external virtual override {

        address sender = msg.sender;
        address current = _platformOwner[marketID];

        require((current == address(0) && (sender == _owner || sender == _authorizer)) ||
                (current != address(0) && (sender == _owner || sender == current)),
                "not-authorized");
        
        _platformOwner[marketID] = owner;

        emit NewPlatformOwner(marketID, owner);
    }

    function withdrawTradingFee() external virtual override {


        uint invested = _tradingFeeInvested;
        if(invested == 0) {
            return;
        }

        _interestManager.accrueInterest();

        _tradingFeeInvested = 0;
        uint redeem = _interestManager.investmentTokenToUnderlying(invested);
        _interestManager.redeem(_tradingFeeRecipient, redeem);

        emit TradingFeeRedeemed(redeem);
    }

    function getTradingFeePayable() public virtual view override returns (uint) {

        return _interestManager.investmentTokenToUnderlying(_tradingFeeInvested);
    }

    function setAuthorizer(address authorizer) external virtual override onlyOwner {

        require(authorizer != address(0), "invalid-params");
        _authorizer = authorizer;
    }

    function isTokenFeeDisabled(address ideaToken) external virtual view override returns (bool) {

        return _tokenFeeKillswitch[ideaToken];
    }

    function setTokenFeeKillswitch(address ideaToken, bool set) external virtual override onlyOwner {

        _tokenFeeKillswitch[ideaToken] = set;
    }

    function setIdeaTokenFactoryAddress(address factory) external virtual onlyOwner {

        require(address(_ideaTokenFactory) == address(0));
        _ideaTokenFactory = IIdeaTokenFactory(factory);
    }
}// MIT
pragma solidity 0.6.9;

interface IBridgeAVM {

    function initialize(address l1Exchange, address l2Exchange, address l2Factory) external;

    function receiveExchangeStaticVars(uint tradingFeeInvested) external;

    function receiveExchangePlatformVars(uint marketID, uint dai, uint invested, uint platformFeeInvested) external;

    function receiveExchangeTokenVars(uint marketID, uint[] calldata tokenIDs, string[] calldata names, uint[] calldata supplies, uint[] calldata dais, uint[] calldata investeds) external;

    function setTokenVars(uint marketID, uint[] calldata tokenID) external;

    function receiveIdeaTokenTransfer(uint marketID, uint tokenID, uint amount, address to) external;

}// MIT

pragma solidity 0.6.9;

interface IInbox {

    function createRetryableTicket(
        address destAddr,
        uint256 arbTxCallValue,
        uint256 maxSubmissionCost,
        address submissionRefundAddress,
        address valueRefundAddress,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) external payable returns (uint256);

}// MIT
pragma solidity 0.6.9;


contract IdeaTokenExchangeStateTransfer is IdeaTokenExchange, IIdeaTokenExchangeStateTransfer {


    uint __gapStateTransfer__;

    address public _transferManager;
    address public _l2Bridge;
    IInbox public _l1Inbox;
    bool public _tokenTransferEnabled;

    event StaticVarsTransferred();
    event PlatformVarsTransferred(uint marketID);
    event TokenVarsTransferred(uint marketID, uint tokenID);
    event TokensTransferred(uint marketID, uint tokenID, address user, uint amount, address recipient);
    event TokenTransferEnabled();

    modifier onlyTransferManager {

        require(msg.sender == _transferManager, "only-transfer-manager");
        _;
    }

    function initializeStateTransfer(address transferManager, address l2Bridge, address l1Inbox) external override {

        require(_transferManager == address(0), "already-init");
        require(transferManager != address(0) && l2Bridge != address(0) &&  l1Inbox != address(0), "invalid-args");

        _transferManager = transferManager;
        _l2Bridge = l2Bridge;
        _l1Inbox = IInbox(l1Inbox);
    }

    function transferStaticVars(uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable override onlyTransferManager returns (uint) {

        address l2Bridge = _l2Bridge;
        bytes4 selector = IBridgeAVM(l2Bridge).receiveExchangeStaticVars.selector;
        bytes memory cdata = abi.encodeWithSelector(selector, _tradingFeeInvested);
        
        uint ticketID = sendL2TxInternal(l2Bridge, msg.sender, gasLimit, maxSubmissionCost, l2GasPriceBid, cdata);

        emit StaticVarsTransferred();

        return ticketID;
    }

    function transferPlatformVars(uint marketID, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable override onlyTransferManager returns (uint) {

        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByID(marketID);
        require(marketDetails.exists, "not-exist");

        ExchangeInfo memory exchangeInfo = _platformsExchangeInfo[marketID];

        address l2Bridge = _l2Bridge;
        bytes4 selector = IBridgeAVM(l2Bridge).receiveExchangePlatformVars.selector;
        bytes memory cdata = abi.encodeWithSelector(selector, marketID, exchangeInfo.dai, exchangeInfo.invested, _platformFeeInvested[marketID]);
        
        uint ticketID = sendL2TxInternal(l2Bridge, msg.sender, gasLimit, maxSubmissionCost, l2GasPriceBid, cdata);

        emit PlatformVarsTransferred(marketID);

        return ticketID;
    }

    function transferTokenVars(uint marketID, uint[] calldata tokenIDs, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable override onlyTransferManager returns (uint) {

        {
        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByID(marketID);
        require(marketDetails.exists, "market-not-exist");
        }

        (string[] memory names, uint[] memory supplies, uint[] memory dais, uint[] memory investeds) = makeTokenStateArraysInternal(marketID, tokenIDs);        

        address l2Bridge = _l2Bridge;
        bytes4 selector = IBridgeAVM(l2Bridge).receiveExchangeTokenVars.selector;
        bytes memory cdata = abi.encodeWithSelector(selector, marketID, tokenIDs, names, supplies, dais, investeds);

        return sendL2TxInternal(l2Bridge, msg.sender, gasLimit, maxSubmissionCost, l2GasPriceBid, cdata);
    }

    function makeTokenStateArraysInternal(uint marketID, uint[] memory tokenIDs) internal returns (string[] memory, uint[] memory, uint[] memory, uint[] memory) {

        uint length = tokenIDs.length;
        require(length > 0, "length-0");

        string[] memory names = new string[](length);
        uint[] memory supplies = new uint[](length);
        uint[] memory dais = new uint[](length);
        uint[] memory investeds = new uint[](length);

        for(uint i = 0; i < length; i++) {

            uint tokenID = tokenIDs[i];
            {
            TokenInfo memory tokenInfo = _ideaTokenFactory.getTokenInfo(marketID, tokenID);
            require(tokenInfo.exists, "token-not-exist");

            IIdeaToken ideaToken = tokenInfo.ideaToken;
            ExchangeInfo memory exchangeInfo = _tokensExchangeInfo[address(ideaToken)];
            
            names[i] = tokenInfo.name;
            supplies[i] = ideaToken.totalSupply();
            dais[i] = exchangeInfo.dai;
            investeds[i] = exchangeInfo.invested;
            }

            emit TokenVarsTransferred(marketID, tokenID);
        }

        return (names, supplies, dais, investeds);
    }

    function transferIdeaTokens(uint marketID, uint tokenID, address l2Recipient, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable override returns (uint) {

        
        require(_tokenTransferEnabled, "not-enabled");
        require(l2Recipient != address(0), "zero-addr");

        TokenInfo memory tokenInfo = _ideaTokenFactory.getTokenInfo(marketID, tokenID);
        require(tokenInfo.exists, "not-exists");

        IIdeaToken ideaToken = tokenInfo.ideaToken;
        uint balance = ideaToken.balanceOf(msg.sender);
        require(balance > 0, "no-balance");

        ideaToken.burn(msg.sender, balance);
        
        address l2Bridge = _l2Bridge;
        bytes4 selector = IBridgeAVM(l2Bridge).receiveIdeaTokenTransfer.selector;
        bytes memory cdata = abi.encodeWithSelector(selector, marketID, tokenID, balance, l2Recipient);
        
        uint ticketID = sendL2TxInternal(l2Bridge, l2Recipient, gasLimit, maxSubmissionCost, l2GasPriceBid, cdata);

        emitTokensTransferredEventInternal(marketID, tokenID, balance, l2Recipient);
    
        return ticketID;
    }

    function emitTokensTransferredEventInternal(uint marketID, uint tokenID, uint balance, address l2Recipient) internal {

        emit TokensTransferred(marketID, tokenID, msg.sender, balance, l2Recipient); 
    }

    function setTokenTransferEnabled() external override onlyTransferManager {

        _tokenTransferEnabled = true;

        emit TokenTransferEnabled();
    }

    function sendL2TxInternal(address to, address refund, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid, bytes memory cdata) internal returns (uint) {

        require(gasLimit > 0 && maxSubmissionCost > 0 && l2GasPriceBid > 0, "l2-gas");
        require(msg.value == maxSubmissionCost.add(gasLimit.mul(l2GasPriceBid)), "value");

        return _l1Inbox.createRetryableTicket{value: msg.value}(
            to,                     // L2 destination
            0,                      // value
            maxSubmissionCost,      // maxSubmissionCost
            refund,                 // submission refund address
            refund,                 // value refund address
            gasLimit,               // max gas
            l2GasPriceBid,          // gas price bid
            cdata                   // L2 calldata
        );
    }


    function initialize(address owner, address authorizer, address tradingFeeRecipient, address interestManager, address dai) external override {

        owner; authorizer; tradingFeeRecipient; interestManager; dai;
        revert("x");
    }

    function sellTokens(address ideaToken, uint amount, uint minPrice, address recipient) external override {

        ideaToken; amount; minPrice; recipient;
        revert("x");
    }

    function getPriceForSellingTokens(address ideaToken, uint amount) external view override returns (uint) {

        ideaToken; amount;
        revert("x");
    }

    function getPricesForSellingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) public pure override returns (CostAndPriceAmounts memory) {

        marketDetails; supply; amount; feesDisabled;
        revert("x");
    }

    function getRawPriceForSellingTokens(uint baseCost, uint priceRise, uint hatchTokens, uint supply, uint amount) internal pure override returns (uint) {

        baseCost; priceRise; hatchTokens; supply; amount;
        revert("x");
    }

    function buyTokens(address ideaToken, uint amount, uint fallbackAmount, uint cost, address recipient) external override {

        ideaToken; amount; fallbackAmount; cost; recipient;
        revert("x");
    }

    function getCostForBuyingTokens(address ideaToken, uint amount) external view override returns (uint) {

        ideaToken; amount;
        revert("x");
    }

    function getCostsForBuyingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) public pure override returns (CostAndPriceAmounts memory) {

        marketDetails; supply; amount; feesDisabled;
        revert("x");
    }

    function getRawCostForBuyingTokens(uint baseCost, uint priceRise, uint hatchTokens, uint supply, uint amount) internal pure override returns (uint) {

        baseCost; priceRise; hatchTokens; supply; amount;
        revert("x");
    }

    function withdrawTokenInterest(address token) external override {

        token;
        revert("x");
    }

    function getInterestPayable(address token) public view override returns (uint) {

        token;
        revert("x");
    }

    function setTokenOwner(address token, address owner) external virtual override {

        token; owner;
        revert("x");
    }

    function withdrawPlatformInterest(uint marketID) external override {

        marketID;
        revert("x");
    }

    function getPlatformInterestPayable(uint marketID) public view override returns (uint) {

        marketID;
        revert("x");
    }

    function withdrawPlatformFee(uint marketID) external override {

        marketID;
        revert("x");
    }

    function getPlatformFeePayable(uint marketID) public view override returns (uint) {

        marketID;
        revert("x");
    }

    function setPlatformOwner(uint marketID, address owner) external override {

        marketID; owner;
        revert("x");
    }

    function withdrawTradingFee() external override {

        revert("x");
    }

    function getTradingFeePayable() public view override returns (uint) {

        revert("x");
    }

    function setAuthorizer(address authorizer) external override {

        authorizer;
        revert("x");
    }

    function isTokenFeeDisabled(address ideaToken) external view override returns (bool) {

        ideaToken;
        revert("x");
    }

    function setTokenFeeKillswitch(address ideaToken, bool set) external override {

        ideaToken; set;
        revert("x");
    }

    function setIdeaTokenFactoryAddress(address factory) external override {

        factory;
        revert("x");
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
