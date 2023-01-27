
pragma solidity ^0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}




contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}
contract ITokensTypeStorage {

  mapping(address => bool) public isRegistred;

  mapping(address => bytes32) public getType;

  mapping(address => bool) public isPermittedAddress;

  address public owner;

  function addNewTokenType(address _token, string _type) public;


  function setTokenTypeAsOwner(address _token, string _type) public;

}


contract UniswapFactoryInterface {

    address public exchangeTemplate;
    uint256 public tokenCount;
    function createExchange(address token) external returns (address exchange);

    function getExchange(address token) external view returns (address exchange);

    function getToken(address exchange) external view returns (address token);

    function getTokenWithId(uint256 tokenId) external view returns (address token);

    function initializeFactory(address template) external;

}


contract UniswapExchangeInterface {

    function tokenAddress() external view returns (address token);

    function factoryAddress() external view returns (address factory);

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);

    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);

    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);

    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);

    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);

    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);

    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);

    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);

    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);

    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);

    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function setup(address token_addr) external;

}


contract IBancorFormula {

    function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _depositAmount) public view returns (uint256);

    function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _sellAmount) public view returns (uint256);

    function calculateCrossReserveReturn(uint256 _fromReserveBalance, uint32 _fromReserveRatio, uint256 _toReserveBalance, uint32 _toReserveRatio, uint256 _amount) public view returns (uint256);

    function calculateFundCost(uint256 _supply, uint256 _reserveBalance, uint32 _totalRatio, uint256 _amount) public view returns (uint256);

    function calculateLiquidateReturn(uint256 _supply, uint256 _reserveBalance, uint32 _totalRatio, uint256 _amount) public view returns (uint256);

}


contract IGetBancorAddressFromRegistry{

  function getBancorContractAddresByName(string _name) public view returns (address result);

}


contract IGetRatioForBancorAssets {

  function getRatio(address _from, address _to, uint256 _amount) public view returns(uint256 result);

}



contract BancorConverterInterface {

  ERC20[] public connectorTokens;
  function fund(uint256 _amount) public;

  function liquidate(uint256 _amount) public;

  function getConnectorBalance(ERC20 _connectorToken) public view returns (uint256);

}







library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}







contract SmartTokenInterface is ERC20 {

  function disableTransfers(bool _disable) public;

  function issue(address _to, uint256 _amount) public;

  function destroy(address _from, uint256 _amount) public;

  function owner() public view returns (address);

}









contract PoolPortal {

  using SafeMath for uint256;

  IGetRatioForBancorAssets public bancorRatio;
  IGetBancorAddressFromRegistry public bancorRegistry;
  UniswapFactoryInterface public uniswapFactory;

  address public BancorEtherToken;

  ERC20 constant private ETH_TOKEN_ADDRESS = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

  enum PortalType { Bancor, Uniswap }

  event BuyPool(address poolToken, uint256 amount, address trader);
  event SellPool(address poolToken, uint256 amount, address trader);

  ITokensTypeStorage public tokensTypes;

  constructor(
    address _bancorRegistryWrapper,
    address _bancorRatio,
    address _bancorEtherToken,
    address _uniswapFactory,
    address _tokensTypes

  )
  public
  {
    bancorRegistry = IGetBancorAddressFromRegistry(_bancorRegistryWrapper);
    bancorRatio = IGetRatioForBancorAssets(_bancorRatio);
    BancorEtherToken = _bancorEtherToken;
    uniswapFactory = UniswapFactoryInterface(_uniswapFactory);
    tokensTypes = ITokensTypeStorage(_tokensTypes);
  }


  function buyPool
  (
    uint256 _amount,
    uint _type,
    ERC20 _poolToken
  )
  external
  payable
  {
    if(_type == uint(PortalType.Bancor)){
      buyBancorPool(_poolToken, _amount);
    }
    else if (_type == uint(PortalType.Uniswap)){
      require(_amount == msg.value, "Not enough ETH");
      buyUniswapPool(_poolToken, _amount);
    }
    else{
      revert();
    }

    emit BuyPool(address(_poolToken), _amount, msg.sender);
  }


  function buyBancorPool(ERC20 _poolToken, uint256 _amount) private {

    address converterAddress = getBacorConverterAddressByRelay(address(_poolToken));
    (uint256 bancorAmount,
     uint256 connectorAmount) = getBancorConnectorsAmountByRelayAmount(_amount, _poolToken);
    BancorConverterInterface converter = BancorConverterInterface(converterAddress);
    (ERC20 bancorConnector,
    ERC20 ercConnector) = getBancorConnectorsByRelay(address(_poolToken));
    bancorConnector.approve(converterAddress, 0);
    ercConnector.approve(converterAddress, 0);
    _transferFromSenderAndApproveTo(bancorConnector, bancorAmount, converterAddress);
    _transferFromSenderAndApproveTo(ercConnector, connectorAmount, converterAddress);
    converter.fund(_amount);

    require(_amount > 0, "BNT pool recieved amount can not be zerro");

    _poolToken.transfer(msg.sender, _amount);

    uint256 bancorRemains = bancorConnector.balanceOf(address(this));
    if(bancorRemains > 0)
       bancorConnector.transfer(msg.sender, bancorRemains);

    uint256 ercRemains = ercConnector.balanceOf(address(this));
    if(ercRemains > 0)
        ercConnector.transfer(msg.sender, ercRemains);

    setTokenType(_poolToken, "BANCOR POOL");
  }


  function buyUniswapPool(address _poolToken, uint256 _ethAmount)
  private
  returns(uint256 poolAmount)
  {

    address tokenAddress = uniswapFactory.getToken(_poolToken);
    if(tokenAddress != address(0x0000000000000000000000000000000000000000)){
      uint256 erc20Amount = getUniswapTokenAmountByETH(tokenAddress, _ethAmount);
      _transferFromSenderAndApproveTo(ERC20(tokenAddress), erc20Amount, _poolToken);
      UniswapExchangeInterface exchange = UniswapExchangeInterface(_poolToken);
      uint256 deadline = now + 15 minutes;
      poolAmount = exchange.addLiquidity.value(_ethAmount)(
        1,
        erc20Amount,
        deadline);
      ERC20(tokenAddress).approve(_poolToken, 0);

      require(poolAmount > 0, "UNI pool recieved amount can not be zerro");

      ERC20(_poolToken).transfer(msg.sender, poolAmount);
      uint256 remainsERC = ERC20(tokenAddress).balanceOf(address(this));
      if(remainsERC > 0)
          ERC20(tokenAddress).transfer(msg.sender, remainsERC);

      setTokenType(_poolToken, "UNISWAP POOL");
    }else{
      revert();
    }
  }

  function getUniswapTokenAmountByETH(address _token, uint256 _amount)
  public
  view
  returns(uint256)
  {

    UniswapExchangeInterface exchange = UniswapExchangeInterface(
      uniswapFactory.getExchange(_token));
    return exchange.getTokenToEthOutputPrice(_amount);
  }


  function sellPool
  (
    uint256 _amount,
    uint _type,
    ERC20 _poolToken
  )
  external
  payable
  {
    if(_type == uint(PortalType.Bancor)){
      sellPoolViaBancor(_poolToken, _amount);
    }
    else if (_type == uint(PortalType.Uniswap)){
      sellPoolViaUniswap(_poolToken, _amount);
    }
    else{
      revert();
    }

    emit SellPool(address(_poolToken), _amount, msg.sender);
  }

  function sellPoolViaBancor(ERC20 _poolToken, uint256 _amount) private {

    _poolToken.transferFrom(msg.sender, address(this), _amount);
    address converterAddress = getBacorConverterAddressByRelay(address(_poolToken));
    BancorConverterInterface(converterAddress).liquidate(_amount);
    (ERC20 bancorConnector,
    ERC20 ercConnector) = getBancorConnectorsByRelay(address(_poolToken));
    bancorConnector.transfer(msg.sender, bancorConnector.balanceOf(this));
    ercConnector.transfer(msg.sender, ercConnector.balanceOf(this));
  }


  function sellPoolViaUniswap(ERC20 _poolToken, uint256 _amount) private {

    address tokenAddress = uniswapFactory.getToken(_poolToken);
    if(tokenAddress != address(0x0000000000000000000000000000000000000000)){
      UniswapExchangeInterface exchange = UniswapExchangeInterface(_poolToken);
      _transferFromSenderAndApproveTo(ERC20(_poolToken), _amount, _poolToken);
      (uint256 minEthAmount,
        uint256 minErcAmount) = getUniswapConnectorsAmountByPoolAmount(
          _amount,
          address(_poolToken));
      uint256 deadline = now + 15 minutes;
      (uint256 eth_amount,
       uint256 token_amount) = exchange.removeLiquidity(
         _amount,
         minEthAmount,
         minErcAmount,
         deadline);
      msg.sender.transfer(eth_amount);
      ERC20(tokenAddress).transfer(msg.sender, token_amount);
    }else{
      revert();
    }
  }

  function getBacorConverterAddressByRelay(address _relay)
  public
  view
  returns(address converter)
  {

    converter = SmartTokenInterface(_relay).owner();
  }

  function getBancorConnectorsByRelay(address _relay)
  public
  view
  returns(
    ERC20 BNTConnector,
    ERC20 ERCConnector
  )
  {

    address converterAddress = getBacorConverterAddressByRelay(_relay);
    BancorConverterInterface converter = BancorConverterInterface(converterAddress);
    BNTConnector = converter.connectorTokens(0);
    ERCConnector = converter.connectorTokens(1);
  }


  function getTokenByUniswapExchange(address _exchange)
  public
  view
  returns(address)
  {

    return uniswapFactory.getToken(_exchange);
  }


  function getUniswapConnectorsAmountByPoolAmount(
    uint256 _amount,
    address _exchange
  )
  public
  view
  returns(uint256 ethAmount, uint256 ercAmount)
  {

    ERC20 token = ERC20(uniswapFactory.getToken(_exchange));
    uint256 totalLiquidity = UniswapExchangeInterface(_exchange).totalSupply();
    ethAmount = _amount.mul(_exchange.balance).div(totalLiquidity);
    ercAmount = _amount.mul(token.balanceOf(_exchange)).div(totalLiquidity);
  }


  function getBancorConnectorsAmountByRelayAmount
  (
    uint256 _amount,
    ERC20 _relay
  )
  public view returns(uint256 bancorAmount, uint256 connectorAmount) {
    BancorConverterInterface converter = BancorConverterInterface(
      SmartTokenInterface(_relay).owner());
    ERC20 bancorConnector = converter.connectorTokens(0);
    ERC20 ercConnector = converter.connectorTokens(1);
    uint256 bntBalance = converter.getConnectorBalance(bancorConnector);
    uint256 ercBalance = converter.getConnectorBalance(ercConnector);
    IBancorFormula bancorFormula = IBancorFormula(
      bancorRegistry.getBancorContractAddresByName("BancorFormula"));
    bancorAmount = bancorFormula.calculateFundCost(
      _relay.totalSupply(),
      bntBalance,
      1000000,
       _amount);
    connectorAmount = bancorFormula.calculateFundCost(
      _relay.totalSupply(),
      ercBalance,
      1000000,
       _amount);
  }

  function getBancorRatio(address _from, address _to, uint256 _amount)
  public
  view
  returns(uint256)
  {

    address fromAddress = ERC20(_from) == ETH_TOKEN_ADDRESS ? BancorEtherToken : _from;
    address toAddress = ERC20(_to) == ETH_TOKEN_ADDRESS ? BancorEtherToken : _to;
    return bancorRatio.getRatio(fromAddress, toAddress, _amount);
  }


  function _transferFromSenderAndApproveTo(ERC20 _source, uint256 _sourceAmount, address _to) private {

    require(_source.transferFrom(msg.sender, address(this), _sourceAmount));

    _source.approve(_to, _sourceAmount);
  }

  function setTokenType(address _token, string _type) private {

    if(tokensTypes.isRegistred(_token))
      return;

    tokensTypes.addNewTokenType(_token,  _type);
  }

  function() public payable {}
}