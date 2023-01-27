
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
interface CToken {

    function underlying() external view returns(address);

    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(address src, address dst, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function mint(uint mintAmount) external returns (uint);

    function borrow(uint borrowAmount) external returns (uint);

    function repayBorrow(uint repayAmount) external returns (uint);

    function liquidateBorrow(address borrower, uint repayAmount, CToken cTokenCollateral) external returns (uint);

    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function exchangeRateCurrent() external returns (uint);

    function exchangeRateStored() external view returns (uint);

    function totalSupply() external view returns(uint);

    function balanceOfUnderlying(address account) external view returns (uint);

    function balanceOf(address account) external view returns (uint);

}
interface ITokensTypeStorage {

  function isRegistred(address _address) external view returns(bool);


  function getType(address _address) external view returns(bytes32);


  function isPermittedAddress(address _address) external view returns(bool);


  function owner() external view returns(address);


  function addNewTokenType(address _token, string calldata _type) external;


  function setTokenTypeAsOwner(address _token, string calldata _type) external;

}


interface PoolPortalInterface {

  function buyPool
  (
    uint256 _amount,
    uint _type,
    IERC20 _poolToken
  )
  external
  payable;

  function sellPool
  (
    uint256 _amount,
    uint _type,
    IERC20 _poolToken
  )
  external
  payable;

  function getBacorConverterAddressByRelay(address relay)
  external
  view
  returns(address converter);


  function getBancorConnectorsAmountByRelayAmount
  (
    uint256 _amount,
    IERC20 _relay
  )
  external view returns(uint256 bancorAmount, uint256 connectorAmount);

  function getBancorConnectorsByRelay(address relay)
  external
  view
  returns(
    IERC20 BNTConnector,
    IERC20 ERCConnector
  );


  function getBancorRatio(address _from, address _to, uint256 _amount)
  external
  view
  returns(uint256);


  function getUniswapConnectorsAmountByPoolAmount(
    uint256 _amount,
    address _exchange
  )
  external
  view
  returns(uint256 ethAmount, uint256 ercAmount);


  function getUniswapTokenAmountByETH(address _token, uint256 _amount)
  external
  view
  returns(uint256);


  function getTokenByUniswapExchange(address _exchange)
  external
  view
  returns(address);

}
interface PermittedStablesInterface {

  function permittedAddresses(address _address) external view returns(bool);

}


interface ExchangePortalInterface {


  event Trade(address src, uint256 srcAmount, address dest, uint256 destReceived);

  function trade(
    IERC20 _source,
    uint256 _sourceAmount,
    IERC20 _destination,
    uint256 _type,
    bytes32[] calldata _additionalArgs,
    bytes calldata _additionalData
  )
    external
    payable
    returns (uint256);


  function compoundRedeemByPercent(uint _percent, address _cToken) external returns(uint256);


  function compoundMint(uint256 _amount, address _cToken) external payable returns(uint256);


  function getPercentFromCTokenBalance(uint _percent, address _cToken, address _holder)
   external
   view
   returns(uint256);


  function getValue(address _from, address _to, uint256 _amount) external view returns (uint256);


  function getTotalValue(
    address[] calldata _fromAddresses,
    uint256[] calldata _amounts,
    address _to
    )
    external
    view
   returns (uint256);


   function getCTokenUnderlying(address _cToken) external view returns(address);

}


interface CEther{

    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(address src, address dst, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function mint() external payable;

    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function borrow(uint borrowAmount) external returns (uint);

    function repayBorrow() external payable;

    function liquidateBorrow(address borrower, CToken cTokenCollateral) external payable;

    function exchangeRateCurrent() external returns (uint);

    function exchangeRateStored() external view returns (uint);

    function totalSupply() external view returns (uint);

    function balanceOfUnderlying(address account) external view returns (uint);

    function balanceOf(address account) external view returns (uint);

}


interface IOneSplitAudit {

  function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256 disableFlags
    ) external payable;


  function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 featureFlags // See contants in IOneSplit.sol
    )
      external
      view
      returns(
          uint256 returnAmount,
          uint256[] memory distribution
      );

}
interface PathFinderInterface {

 function generatePath(address _sourceToken, address _targetToken) external view returns (address[] memory);

}

interface BancorNetworkInterface {

   function getReturnByPath(
     IERC20[] calldata _path,
     uint256 _amount)
     external
     view
     returns (uint256, uint256);


    function convert(
        IERC20[] calldata _path,
        uint256 _amount,
        uint256 _minReturn
    ) external payable returns (uint256);


    function claimAndConvert(
        IERC20[] calldata _path,
        uint256 _amount,
        uint256 _minReturn
    ) external returns (uint256);


    function convertFor(
        IERC20[] calldata _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) external payable returns (uint256);


    function claimAndConvertFor(
        IERC20[] calldata _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) external returns (uint256);


}
interface IGetBancorAddressFromRegistry {

  function getBancorContractAddresByName(string calldata _name) external view returns (address result);

}
interface IParaswapParams{

  function getParaswapParamsFromBytes32Array(bytes32[] calldata _additionalArgs)
  external pure returns
  (
    uint256 minDestinationAmount,
    address[] memory callees,
    uint256[] memory startIndexes,
    uint256[] memory values,
    uint256 mintPrice
  );

}
interface IPriceFeed{

  function getBestPriceSimple(address _from, address _to, uint256 _amount) external view returns (uint256 result);

}
interface ParaswapInterface{

  function swap(
     address sourceToken,
     address destinationToken,
     uint256 sourceAmount,
     uint256 minDestinationAmount,
     address[] calldata callees,
     bytes calldata exchangeData,
     uint256[] calldata startIndexes,
     uint256[] calldata values,
     string calldata referrer,
     uint256 mintPrice
   )
   external
   payable;


   function getTokenTransferProxy() external view returns (address);

}







contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

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





















contract ExchangePortal is ExchangePortalInterface, Ownable {

  using SafeMath for uint256;

  uint public version = 2;

  ITokensTypeStorage public tokensTypes;

  CEther public cEther;

  address public paraswap;
  ParaswapInterface public paraswapInterface;
  IPriceFeed public priceFeedInterface;
  IParaswapParams public paraswapParams;
  address public paraswapSpender;

  IOneSplitAudit public oneInch;

  address public BancorEtherToken;
  IGetBancorAddressFromRegistry public bancorRegistry;

  PoolPortalInterface public poolPortal;
  PermittedStablesInterface public permitedStable;

  enum ExchangeType { Paraswap, Bancor, OneInch }

  IERC20 constant private ETH_TOKEN_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

  event Trade(
     address trader,
     address src,
     uint256 srcAmount,
     address dest,
     uint256 destReceived,
     uint8 exchangeType
  );

  mapping (address => bool) disabledTokens;

  modifier tokenEnabled(IERC20 _token) {

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
    address _oneInch,
    address _cEther,
    address _tokensTypes
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
    permitedStable = PermittedStablesInterface(_permitedStable);
    poolPortal = PoolPortalInterface(_poolPortal);
    oneInch = IOneSplitAudit(_oneInch);
    cEther = CEther(_cEther);
    tokensTypes = ITokensTypeStorage(_tokensTypes);
  }



  function trade(
    IERC20 _source,
    uint256 _sourceAmount,
    IERC20 _destination,
    uint256 _type,
    bytes32[] calldata _additionalArgs,
    bytes calldata _additionalData
  )
    external
    override
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
          address(_source),
          address(_destination),
          _sourceAmount,
          _additionalData,
          _additionalArgs
      );
    }
    else if (_type == uint(ExchangeType.Bancor)){
      receivedAmount = _tradeViaBancorNewtork(
          address(_source),
          address(_destination),
          _sourceAmount
      );
    }
    else if (_type == uint(ExchangeType.OneInch)){
      receivedAmount = _tradeViaOneInch(
          address(_source),
          address(_destination),
          _sourceAmount
      );
    }

    else {
      revert();
    }

    require(receivedAmount > 0, "received amount can not be zerro");

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

    emit Trade(
      msg.sender,
      address(_source),
      _sourceAmount,
      address(_destination),
      receivedAmount,
      uint8(_type)
    );

    return receivedAmount;
  }


  function _tradeViaParaswap(
    address sourceToken,
    address destinationToken,
    uint256 sourceAmount,
    bytes memory exchangeData,
    bytes32[] memory _additionalArgs
 )
   private
   returns (uint256 destinationReceived)
 {

   (uint256 minDestinationAmount,
    address[] memory callees,
    uint256[] memory startIndexes,
    uint256[] memory values,
    uint256 mintPrice) = paraswapParams.getParaswapParamsFromBytes32Array(_additionalArgs);

   if (IERC20(sourceToken) == ETH_TOKEN_ADDRESS) {
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
     _transferFromSenderAndApproveTo(IERC20(sourceToken), sourceAmount, paraswapSpender);
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

   destinationReceived = tokenBalance(IERC20(destinationToken));
   setTokenType(destinationToken, "CRYPTOCURRENCY");
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

    if(IERC20(sourceToken) == ETH_TOKEN_ADDRESS) {
      oneInch.swap.value(sourceAmount)(
        IERC20(sourceToken),
        IERC20(destinationToken),
        sourceAmount,
        1,
        distribution,
        0
        );
    } else {
      _transferFromSenderAndApproveTo(IERC20(sourceToken), sourceAmount, address(oneInch));
      oneInch.swap(
        IERC20(sourceToken),
        IERC20(destinationToken),
        sourceAmount,
        1,
        distribution,
        0
        );
    }

    destinationReceived = tokenBalance(IERC20(destinationToken));
    setTokenType(destinationToken, "CRYPTOCURRENCY");
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

    address source = IERC20(sourceToken) == ETH_TOKEN_ADDRESS ? BancorEtherToken : sourceToken;
    address destination = IERC20(destinationToken) == ETH_TOKEN_ADDRESS ? BancorEtherToken : destinationToken;

    address[] memory path = pathFinder.generatePath(source, destination);

    IERC20[] memory pathInERC20 = new IERC20[](path.length);
    for(uint i=0; i<path.length; i++){
        pathInERC20[i] = IERC20(path[i]);
    }

    if (IERC20(sourceToken) == ETH_TOKEN_ADDRESS) {
      returnAmount = bancorNetwork.convert.value(sourceAmount)(pathInERC20, sourceAmount, 1);
    }
    else {
      _transferFromSenderAndApproveTo(IERC20(sourceToken), sourceAmount, address(bancorNetwork));
      returnAmount = bancorNetwork.claimAndConvert(pathInERC20, sourceAmount, 1);
    }

    setTokenType(destinationToken, "BANCOR_ASSET");
 }


  function _transferFromSenderAndApproveTo(IERC20 _source, uint256 _sourceAmount, address _to) private {

    require(_source.transferFrom(msg.sender, address(this), _sourceAmount));

    _source.approve(_to, _sourceAmount);
  }


  function compoundMint(uint256 _amount, address _cToken)
   external
   override
   payable
   returns(uint256)
  {

    uint256 receivedAmount = 0;
    if(_cToken == address(cEther)){
      cEther.mint.value(_amount)();
      receivedAmount = cEther.balanceOf(address(this));
      cEther.transfer(msg.sender, receivedAmount);
    }else{
      CToken cToken = CToken(_cToken);
      address underlyingAddress = cToken.underlying();
      _transferFromSenderAndApproveTo(IERC20(underlyingAddress), _amount, address(_cToken));
      cToken.mint(_amount);
      receivedAmount = cToken.balanceOf(address(this));
      cToken.transfer(msg.sender, receivedAmount);
    }

    require(receivedAmount > 0, "received amount can not be zerro");

    setTokenType(_cToken, "COMPOUND");
    return receivedAmount;
  }

  function compoundRedeemByPercent(uint _percent, address _cToken)
   external
   override
   returns(uint256)
  {

    uint256 receivedAmount = 0;

    uint256 amount = getPercentFromCTokenBalance(_percent, _cToken, msg.sender);

    IERC20(_cToken).transferFrom(msg.sender, address(this), amount);

    if(_cToken == address(cEther)){
      cEther.redeem(amount);
      receivedAmount = address(this).balance;
      (msg.sender).transfer(receivedAmount);

    }else{
      CToken cToken = CToken(_cToken);
      cToken.redeem(amount);
      address underlyingAddress = cToken.underlying();
      IERC20 underlying = IERC20(underlyingAddress);
      receivedAmount = underlying.balanceOf(address(this));
      underlying.transfer(msg.sender, receivedAmount);
    }

    require(receivedAmount > 0, "received amount can not be zerro");

    return receivedAmount;
  }


  function tokenBalance(IERC20 _token) private view returns (uint256) {

    if (_token == ETH_TOKEN_ADDRESS)
      return address(this).balance;
    return _token.balanceOf(address(this));
  }

  function getValue(address _from, address _to, uint256 _amount)
    public
    override
    view
    returns (uint256)
  {

    if(_amount > 0){
      if(tokensTypes.getType(_from) == bytes32("CRYPTOCURRENCY")){
        return getValueViaDEXsAgregators(_from, _to, _amount);
      }
      else if (tokensTypes.getType(_from) == bytes32("BANCOR_ASSET")){
        return getValueViaBancor(_from, _to, _amount);
      }
      else if (tokensTypes.getType(_from) == bytes32("UNISWAP_POOL")){
        return getValueForUniswapPools(_from, _to, _amount);
      }
      else if (tokensTypes.getType(_from) == bytes32("COMPOUND")){
        return getValueViaCompound(_from, _to, _amount);
      }
      else{
        return findValue(_from, _to, _amount);
      }
    }
    else{
      return 0;
    }
  }

  function findValue(address _from, address _to, uint256 _amount) private view returns (uint256) {

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

       uint256 compoundResult = getValueViaCompound(_from, _to, _amount);
       if(compoundResult > 0)
          return compoundResult;

       return getValueForUniswapPools(_from, _to, _amount);
     }
     else{
       return 0;
     }
  }

  function getValueViaDEXsAgregators(
    address _from,
    address _to,
    uint256 _amount
  )
  public view returns (uint256){

    uint256 valueFromOneInch = getValueViaOneInch(_from, _to, _amount);
    if(valueFromOneInch > 0){
      return valueFromOneInch;
    }
    else{
      uint256 valueFromParaswap = getValueViaParaswap(_from, _to, _amount);
      return valueFromParaswap;
    }
  }

  function getValueViaParaswap(
    address _from,
    address _to,
    uint256 _amount
  )
  public view returns (uint256 value) {

    try priceFeedInterface.getBestPriceSimple(_from, _to, _amount) returns (uint256 result)
    {
      value = result;
    }catch{
      value = 0;
    }
  }

  function getValueViaOneInch(
    address _from,
    address _to,
    uint256 _amount
  )
    public
    view
    returns (uint256 value)
  {

    try oneInch.getExpectedReturn(
       IERC20(_from),
       IERC20(_to),
       _amount,
       10,
       0)
      returns(uint256 returnAmount, uint256[] memory distribution)
     {
       value = returnAmount;
     }
     catch{
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

    try poolPortal.getBancorRatio(_from, _to, _amount) returns(uint256 result){
      value = result;
    }catch{
      value = 0;
    }
  }

  function getValueViaCompound(
    address _from,
    address _to,
    uint256 _amount
  ) public view returns (uint256 value) {

    uint256 underlyingAmount = getCompoundUnderlyingRatio(
      _from,
      _amount
    );
    if(underlyingAmount > 0){
      address underlyingAddress = (_from == address(cEther))
      ? address(ETH_TOKEN_ADDRESS)
      : CToken(_from).underlying();
      return getValueViaDEXsAgregators(underlyingAddress, _to, underlyingAmount);
    }
    else{
      return 0;
    }
  }

  function getCompoundUnderlyingRatio(
    address _from,
    uint256 _amount
  )
    public
    view
    returns (uint256)
  {

    try CToken(_from).exchangeRateStored() returns(uint256 rate)
    {
      uint256 underlyingAmount = _amount.mul(rate).div(1e18);
      return underlyingAmount;
    }
    catch{
      return 0;
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
    uint256 ercAmountInETH = getValueViaDEXsAgregators(token, address(ETH_TOKEN_ADDRESS), ercAmount);
    uint256 totalETH = ethAmount.add(ercAmountInETH);

    if(_to == address(ETH_TOKEN_ADDRESS)){
      return totalETH;
    }
    else{
      return getValueViaDEXsAgregators(address(ETH_TOKEN_ADDRESS), _to, totalETH);
    }
  }

  function getPercentFromCTokenBalance(uint _percent, address _cToken, address _holder)
   public
   override
   view
   returns(uint256)
  {

    if(_percent == 100){
      return IERC20(_cToken).balanceOf(_holder);
    }
    else if(_percent > 0 && _percent < 100){
      uint256 currectBalance = IERC20(_cToken).balanceOf(_holder);
      return currectBalance.div(100).mul(_percent);
    }
    else{
      return 0;
    }
  }

  function getCTokenUnderlying(address _cToken) external override view returns(address){

    return CToken(_cToken).underlying();
  }

  function getTotalValue(
    address[] calldata _fromAddresses,
    uint256[] calldata _amounts,
    address _to)
    external
    override
    view
    returns (uint256)
  {

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

  function setTokenType(address _token, string memory _type) private {

    if(tokensTypes.isRegistred(_token))
      return;

    tokensTypes.addNewTokenType(_token,  _type);
  }

  fallback() external payable {}

}