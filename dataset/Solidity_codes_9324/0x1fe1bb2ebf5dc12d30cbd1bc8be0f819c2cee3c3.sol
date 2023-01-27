
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
                        address dai) external initializer {

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

    function sellTokens(address ideaToken, uint amount, uint minPrice, address recipient) external override {


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


    function getPriceForSellingTokens(address ideaToken, uint amount) external view override returns (uint) {

        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByTokenAddress(ideaToken);
        return getPricesForSellingTokens(marketDetails, IERC20(ideaToken).totalSupply(), amount, _tokenFeeKillswitch[ideaToken]).total;
    }

    function getPricesForSellingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) public pure override returns (CostAndPriceAmounts memory) {

        
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

    function getRawPriceForSellingTokens(uint baseCost, uint priceRise, uint hatchTokens, uint supply, uint amount) internal pure returns (uint) {


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

    function buyTokens(address ideaToken, uint amount, uint fallbackAmount, uint cost, address recipient) external override {

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

    function getCostForBuyingTokens(address ideaToken, uint amount) external view override returns (uint) {

        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByTokenAddress(ideaToken);

        return getCostsForBuyingTokens(marketDetails, IERC20(ideaToken).totalSupply(), amount, _tokenFeeKillswitch[ideaToken]).total;
    }

    function getCostsForBuyingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) public pure override returns (CostAndPriceAmounts memory) {

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

    function getRawCostForBuyingTokens(uint baseCost, uint priceRise, uint hatchTokens, uint supply, uint amount) internal pure returns (uint) {


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

    function withdrawTokenInterest(address token) external override {

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

    function getInterestPayable(address token) public view override returns (uint) {

        ExchangeInfo storage exchangeInfo = _tokensExchangeInfo[token];
        return _interestManager.investmentTokenToUnderlying(exchangeInfo.invested).sub(exchangeInfo.dai);
    }

    function setTokenOwner(address token, address owner) external override {

        address sender = msg.sender;
        address current = _tokenOwner[token];

        require((current == address(0) && (sender == _owner || sender == _authorizer)) ||
                (current != address(0) && (sender == _owner || sender == current)),
                "not-authorized");

        _tokenOwner[token] = owner;

        emit NewTokenOwner(token, owner);
    }

    function withdrawPlatformInterest(uint marketID) external override {

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

    function getPlatformInterestPayable(uint marketID) public view override returns (uint) {

        ExchangeInfo storage exchangeInfo = _platformsExchangeInfo[marketID];
        return _interestManager.investmentTokenToUnderlying(exchangeInfo.invested).sub(exchangeInfo.dai);
    }

    function withdrawPlatformFee(uint marketID) external override {

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

    function getPlatformFeePayable(uint marketID) public view override returns (uint) {

        return _interestManager.investmentTokenToUnderlying(_platformFeeInvested[marketID]);
    }

    function setPlatformOwner(uint marketID, address owner) external override {

        address sender = msg.sender;
        address current = _platformOwner[marketID];

        require((current == address(0) && (sender == _owner || sender == _authorizer)) ||
                (current != address(0) && (sender == _owner || sender == current)),
                "not-authorized");
        
        _platformOwner[marketID] = owner;

        emit NewPlatformOwner(marketID, owner);
    }

    function withdrawTradingFee() external override {


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

    function getTradingFeePayable() public view override returns (uint) {

        return _interestManager.investmentTokenToUnderlying(_tradingFeeInvested);
    }

    function setAuthorizer(address authorizer) external override onlyOwner {

        require(authorizer != address(0), "invalid-params");
        _authorizer = authorizer;
    }

    function isTokenFeeDisabled(address ideaToken) external view override returns (bool) {

        return _tokenFeeKillswitch[ideaToken];
    }

    function setTokenFeeKillswitch(address ideaToken, bool set) external override onlyOwner {

        _tokenFeeKillswitch[ideaToken] = set;
    }

    function setIdeaTokenFactoryAddress(address factory) external onlyOwner {

        require(address(_ideaTokenFactory) == address(0));
        _ideaTokenFactory = IIdeaTokenFactory(factory);
    }
}