
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

contract PoolPortalInterface {

  function buyPool
  (
    uint256 _amount,
    uint _type,
    ERC20 _poolToken
  )
  external
  payable;

  function sellPool
  (
    uint256 _amount,
    uint _type,
    ERC20 _poolToken
  )
  external
  payable;

  function getBacorConverterAddressByRelay(address relay)
  public
  view
  returns(address converter);


  function getBancorConnectorsAmountByRelayAmount
  (
    uint256 _amount,
    ERC20 _relay
  )
  public view returns(uint256 bancorAmount, uint256 connectorAmount);

  function getBancorConnectorsByRelay(address relay)
  public
  view
  returns(
    ERC20 BNTConnector,
    ERC20 ERCConnector
  );


  function getBancorRatio(address _from, address _to, uint256 _amount)
  public
  view
  returns(uint256);


  function getUniswapConnectorsAmountByPoolAmount(
    uint256 _amount,
    address _exchange
  )
  public
  view
  returns(uint256 ethAmount, uint256 ercAmount);


  function getUniswapTokenAmountByETH(address _token, uint256 _amount)
  public
  view
  returns(uint256);


  function getTokenByUniswapExchange(address _exchange)
  public
  view
  returns(address);

}
contract PermittedStabelsInterface {

  mapping (address => bool) public permittedAddresses;
}


contract ExchangePortalInterface {


  event Trade(address src, uint256 srcAmount, address dest, uint256 destReceived);

  function trade(
    ERC20 _source,
    uint256 _sourceAmount,
    ERC20 _destination,
    uint256 _type,
    bytes32[] _additionalArgs,
    bytes _additionalData
  )
    external
    payable
    returns (uint256);


  function getValue(address _from, address _to, uint256 _amount) public view returns (uint256);

  function getTotalValue(address[] _fromAddresses, uint256[] _amounts, address _to) public view returns (uint256);

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


contract IOneSplitAudit {

  function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 disableFlags
    ) public payable;


  function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 featureFlags // See contants in IOneSplit.sol
    )
      public
      view
      returns(
          uint256 returnAmount,
          uint256[] memory distribution
      );

}


contract PathFinderInterface {

 function generatePath(address _sourceToken, address _targetToken) public view returns (address[] memory);

}



contract BancorNetworkInterface {

   function getReturnByPath(ERC20[] _path, uint256 _amount) public view returns (uint256, uint256);


    function convert(
        ERC20[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) public payable returns (uint256);


    function claimAndConvert(
        ERC20[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) public returns (uint256);


    function convertFor(
        ERC20[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) public payable returns (uint256);


    function claimAndConvertFor(
        ERC20[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) public returns (uint256);


}


contract IGetBancorAddressFromRegistry{

  function getBancorContractAddresByName(string _name) public view returns (address result);

}


contract IParaswapParams{

  function getParaswapParamsFromBytes32Array(bytes32[] memory _additionalArgs)
  public pure returns
  (
    uint256 minDestinationAmount,
    address[] memory callees,
    uint256[] memory startIndexes,
    uint256[] memory values,
    uint256 mintPrice
  );

}


contract IPriceFeed{

  function getBestPriceSimple(address _from, address _to, uint256 _amount) public view returns (uint256 result);

}


contract ParaswapInterface{

  function swap(
     address sourceToken,
     address destinationToken,
     uint256 sourceAmount,
     uint256 minDestinationAmount,
     address[] memory callees,
     bytes memory exchangeData,
     uint256[] memory startIndexes,
     uint256[] memory values,
     string memory referrer,
     uint256 mintPrice
   )
   public
   payable;


   function getTokenTransferProxy() external view returns (address);

}



contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
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





contract DetailedERC20 is ERC20 {

  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}















contract ExchangePortal is ExchangePortalInterface, Ownable {

  using SafeMath for uint256;

  uint public version = 2;

  address public paraswap;
  ParaswapInterface public paraswapInterface;
  IPriceFeed public priceFeedInterface;
  IParaswapParams public paraswapParams;
  address public paraswapSpender;

  IOneSplitAudit public oneInch;

  address public BancorEtherToken;
  IGetBancorAddressFromRegistry public bancorRegistry;

  PoolPortalInterface public poolPortal;
  PermittedStabelsInterface public permitedStable;

  enum ExchangeType { Paraswap, Bancor, OneInch}

  ERC20 constant private ETH_TOKEN_ADDRESS = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

  event Trade(
     address trader,
     address src,
     uint256 srcAmount,
     address dest,
     uint256 destReceived,
     uint8 exchangeType);

  mapping (address => bool) disabledTokens;

  modifier tokenEnabled(ERC20 _token) {

    require(!disabledTokens[address(_token)]);
    _;
  }

  constructor(
    address _paraswap,
    address _paraswapPrice,
    address _paraswapParams,
    address _bancorRegistryWrapper,
    address _BancorEtherToken,
    address _permitedStable,
    address _poolPortal,
    address _oneInch
    )
    public
    {
    paraswap = _paraswap;
    paraswapInterface = ParaswapInterface(_paraswap);
    priceFeedInterface = IPriceFeed(_paraswapPrice);
    paraswapParams = IParaswapParams(_paraswapParams);
    paraswapSpender = paraswapInterface.getTokenTransferProxy();
    bancorRegistry = IGetBancorAddressFromRegistry(_bancorRegistryWrapper);
    BancorEtherToken = _BancorEtherToken;
    permitedStable = PermittedStabelsInterface(_permitedStable);
    poolPortal = PoolPortalInterface(_poolPortal);
    oneInch = IOneSplitAudit(_oneInch);
  }


  function trade(
    ERC20 _source,
    uint256 _sourceAmount,
    ERC20 _destination,
    uint256 _type,
    bytes32[] _additionalArgs,
    bytes _additionalData
  )
    external
    payable
    tokenEnabled(_destination)
    returns (uint256)
  {


    require(_source != _destination);

    uint256 receivedAmount;

    if (_source == ETH_TOKEN_ADDRESS) {
      require(msg.value == _sourceAmount);
    } else {
      require(msg.value == 0);
    }

    if (_type == uint(ExchangeType.Paraswap)) {
      receivedAmount = _tradeViaParaswap(
          _source,
          _destination,
          _sourceAmount,
          _additionalData,
          _additionalArgs
      );
    }
    else if (_type == uint(ExchangeType.Bancor)){
      receivedAmount = _tradeViaBancorNewtork(
          _source,
          _destination,
          _sourceAmount
      );
    }
    else if (_type == uint(ExchangeType.OneInch)){
      receivedAmount = _tradeViaOneInch(
          _source,
          _destination,
          _sourceAmount
      );
    }

    else {
      revert();
    }

    if (_destination == ETH_TOKEN_ADDRESS) {
      (msg.sender).transfer(receivedAmount);
    } else {
      _destination.transfer(msg.sender, receivedAmount);
    }

    uint256 endAmount = (_source == ETH_TOKEN_ADDRESS) ? address(this).balance : _source.balanceOf(address(this));

    if (endAmount > 0) {
      if (_source == ETH_TOKEN_ADDRESS) {
        (msg.sender).transfer(endAmount);
      } else {
        _source.transfer(msg.sender, endAmount);
      }
    }

    emit Trade(msg.sender, _source, _sourceAmount, _destination, receivedAmount, uint8(_type));

    return receivedAmount;
  }


  function _tradeViaParaswap(
    address sourceToken,
    address destinationToken,
    uint256 sourceAmount,
    bytes   exchangeData,
    bytes32[] _additionalArgs
 )
   private
   returns (uint256 destinationReceived)
 {

   (uint256 minDestinationAmount,
    address[] memory callees,
    uint256[] memory startIndexes,
    uint256[] memory values,
    uint256 mintPrice) = paraswapParams.getParaswapParamsFromBytes32Array(_additionalArgs);

   if (ERC20(sourceToken) == ETH_TOKEN_ADDRESS) {
     paraswapInterface.swap.value(sourceAmount)(
       sourceToken,
       destinationToken,
       sourceAmount,
       minDestinationAmount,
       callees,
       exchangeData,
       startIndexes,
       values,
       "CoTrader", // referrer
       mintPrice
     );
   } else {
     _transferFromSenderAndApproveTo(ERC20(sourceToken), sourceAmount, paraswapSpender);
     paraswapInterface.swap(
       sourceToken,
       destinationToken,
       sourceAmount,
       minDestinationAmount,
       callees,
       exchangeData,
       startIndexes,
       values,
       "CoTrader", // referrer
       mintPrice
     );
   }

   destinationReceived = tokenBalance(ERC20(destinationToken));
 }

 function _tradeViaOneInch(
   address sourceToken,
   address destinationToken,
   uint256 sourceAmount
   )
   private
   returns(uint256 destinationReceived)
 {

    (, uint256[] memory distribution) = oneInch.getExpectedReturn(
      IERC20(sourceToken),
      IERC20(destinationToken),
      sourceAmount,
      10,
      0);

    if(ERC20(sourceToken) == ETH_TOKEN_ADDRESS) {
      oneInch.swap.value(sourceAmount)(
        IERC20(sourceToken),
        IERC20(destinationToken),
        sourceAmount,
        1,
        distribution,
        0
        );
    } else {
      oneInch.swap(
        IERC20(sourceToken),
        IERC20(destinationToken),
        sourceAmount,
        1,
        distribution,
        0
        );
    }

    destinationReceived = tokenBalance(ERC20(destinationToken));
 }


 function _tradeViaBancorNewtork(
   address sourceToken,
   address destinationToken,
   uint256 sourceAmount
   )
   private
   returns(uint256 returnAmount)
 {

    BancorNetworkInterface bancorNetwork = BancorNetworkInterface(
      bancorRegistry.getBancorContractAddresByName("BancorNetwork")
    );

    PathFinderInterface pathFinder = PathFinderInterface(
      bancorRegistry.getBancorContractAddresByName("BancorNetworkPathFinder")
    );

    address source = ERC20(sourceToken) == ETH_TOKEN_ADDRESS ? BancorEtherToken : sourceToken;
    address destination = ERC20(destinationToken) == ETH_TOKEN_ADDRESS ? BancorEtherToken : destinationToken;

    address[] memory path = pathFinder.generatePath(source, destination);

    ERC20[] memory pathInERC20 = new ERC20[](path.length);
    for(uint i=0; i<path.length; i++){
        pathInERC20[i] = ERC20(path[i]);
    }

    if (ERC20(sourceToken) == ETH_TOKEN_ADDRESS) {
      returnAmount = bancorNetwork.convert.value(sourceAmount)(pathInERC20, sourceAmount, 1);
    }
    else {
      _transferFromSenderAndApproveTo(ERC20(sourceToken), sourceAmount, address(bancorNetwork));
      returnAmount = bancorNetwork.claimAndConvert(pathInERC20, sourceAmount, 1);
    }
 }


 function tokenBalance(ERC20 _token) private view returns (uint256) {

   if (_token == ETH_TOKEN_ADDRESS)
     return address(this).balance;
   return _token.balanceOf(address(this));
 }

  function _transferFromSenderAndApproveTo(ERC20 _source, uint256 _sourceAmount, address _to) private {

    require(_source.transferFrom(msg.sender, address(this), _sourceAmount));

    _source.approve(_to, _sourceAmount);
  }


  function getValue(address _from, address _to, uint256 _amount) public view returns (uint256) {

     if(_amount > 0){
       uint256 paraswapResult = getValueViaParaswap(_from, _to, _amount);
       if(paraswapResult > 0)
         return paraswapResult;

       uint256 oneInchResult = getValueViaOneInch(_from, _to, _amount);
       if(oneInchResult > 0)
         return oneInchResult;

       uint256 bancorResult = getValueViaBancor(_from, _to, _amount);
       if(bancorResult > 0)
          return bancorResult;

       return getValueForUniswapPools(_from, _to, _amount);
     }else{
       return 0;
     }
  }

  function getValueViaParaswap(
    address _from,
    address _to,
    uint256 _amount
  ) public view returns (uint256 value) {

    (bool success) = address(priceFeedInterface).call(
    abi.encodeWithSelector(priceFeedInterface.getBestPriceSimple.selector, _from, _to, _amount));
    if(success){
      value = priceFeedInterface.getBestPriceSimple(_from, _to, _amount);
    }else{
      value = 0;
    }
  }

  function getValueViaOneInch(
    address _from,
    address _to,
    uint256 _amount
  ) public view returns (uint256 value) {

    (bool success) = address(oneInch).call(
    abi.encodeWithSelector(oneInch.getExpectedReturn.selector, IERC20(_from), IERC20(_to), _amount));
    if(success){
      (uint256 returnAmount, ) = oneInch.getExpectedReturn(
        IERC20(_from),
        IERC20(_to),
        _amount,
        10,
        0);
      value = returnAmount;
    }else{
      value = 0;
    }
  }

  function getValueViaBancor(
    address _from,
    address _to,
    uint256 _amount
  )
  public
  view
  returns (uint256 value)
  {

    (bool success) = address(poolPortal).call(
    abi.encodeWithSelector(poolPortal.getBancorRatio.selector, _from, _to, _amount));
    if(success){
      value = poolPortal.getBancorRatio(_from, _to, _amount);
    }else{
      value = 0;
    }
  }

  function getValueForUniswapPools(
    address _from,
    address _to,
    uint256 _amount
  )
  public
  view
  returns (uint256)
  {

    (uint256 ethAmount,
     uint256 ercAmount) = poolPortal.getUniswapConnectorsAmountByPoolAmount(
      _amount,
      _from
    );
    address token = poolPortal.getTokenByUniswapExchange(_from);
    uint256 ercAmountInETH = getValueViaParaswap(token, ETH_TOKEN_ADDRESS, ercAmount);
    uint256 totalETH = ethAmount.add(ercAmountInETH);

    if(!permitedStable.permittedAddresses(_to))
       return totalETH;
    return getValueViaParaswap(ETH_TOKEN_ADDRESS, _to, totalETH);
  }

  function getTotalValue(address[] _fromAddresses, uint256[] _amounts, address _to) public view returns (uint256) {

    uint256 sum = 0;
    for (uint256 i = 0; i < _fromAddresses.length; i++) {
      sum = sum.add(getValue(_fromAddresses[i], _to, _amounts[i]));
    }
    return sum;
  }

  function setToken(address _token, bool _enabled) external onlyOwner {

    disabledTokens[_token] = _enabled;
  }

  function setNewIFeed(address _paraswapPrice) external onlyOwner {

    priceFeedInterface = IPriceFeed(_paraswapPrice);
  }

  function setNewParaswapSpender(address _paraswapSpender) external onlyOwner {

    paraswapSpender = _paraswapSpender;
  }

  function setNewParaswapMain(address _paraswap) external onlyOwner {

    paraswapInterface = ParaswapInterface(_paraswap);
  }

  function setNewOneInch(address _oneInch) external onlyOwner {

    oneInch = IOneSplitAudit(_oneInch);
  }

  function() public payable {}

}