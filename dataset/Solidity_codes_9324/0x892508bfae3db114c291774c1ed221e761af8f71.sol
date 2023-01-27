
pragma solidity ^0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}
contract IGetRatioForBancorAssets {

  function getRatio(address _from, address _to, uint256 _amount)
  public
  view
  returns(uint256 result);

}





contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


contract KyberNetworkInterface {

  function trade(
    ERC20 src,
    uint srcAmount,
    ERC20 dest,
    address destAddress,
    uint maxDestAmount,
    uint minConversionRate,
    address walletId
  )
    public
    payable
    returns(uint);


  function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view
    returns (uint expectedRate, uint slippageRate);

}
contract PathFinderInterface {

  function generatePath(address _sourceToken, address _targetToken)
  public
  view
  returns (address[] memory);

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










contract ConvertPortal {

  address public BancorEtherToken;
  IGetBancorAddressFromRegistry public bancorRegistry;
  KyberNetworkInterface public kyber;
  IGetRatioForBancorAssets public bancorRatio;
  address public cotToken;
  address constant private ETH_TOKEN_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

  constructor(
    address _bancorRegistryWrapper,
    address _BancorEtherToken,
    address _kyber,
    address _cotToken,
    address _bancorRatio
    )
    public
  {
    bancorRegistry = IGetBancorAddressFromRegistry(_bancorRegistryWrapper);
    BancorEtherToken = _BancorEtherToken;
    kyber = KyberNetworkInterface(_kyber);
    cotToken = _cotToken;
    bancorRatio = IGetRatioForBancorAssets(_bancorRatio);
  }

  function isConvertibleToCOT(address _token, uint256 _amount)
  public
  view
  returns(uint256)
  {

    address fromToken = _token == ETH_TOKEN_ADDRESS ? BancorEtherToken : _token;
    (bool success) = address(bancorRatio).call(
    abi.encodeWithSelector(bancorRatio.getRatio.selector, fromToken, cotToken, _amount));
    if(success){
      return bancorRatio.getRatio(fromToken, cotToken, _amount);
    }else{
      return 0;
    }
  }

  function isConvertibleToETH(address _token, uint256 _amount)
  public
  view
  returns(uint256)
  {

    (bool success) = address(kyber).call(
    abi.encodeWithSelector(
      kyber.getExpectedRate.selector,
      ERC20(_token),
      ERC20(ETH_TOKEN_ADDRESS),
       _amount));

    if(success){
     (uint256 expectedRate, ) = kyber.getExpectedRate(
      ERC20(_token),
      ERC20(ETH_TOKEN_ADDRESS),
      _amount);
      return expectedRate;
    }else{
      return 0;
    }
  }

  function convertTokentoCOT(address _token, uint256 _amount)
  public
  payable
  returns (uint256 cotAmount)
  {

    if(_token == ETH_TOKEN_ADDRESS)
      require(msg.value == _amount, "require ETH");

    cotAmount = _tradeBancor(
        _token,
        cotToken,
        _amount
    );

    ERC20(cotToken).transfer(msg.sender, cotAmount);

    uint256 endAmount = (_token == ETH_TOKEN_ADDRESS)
    ? address(this).balance
    : ERC20(_token).balanceOf(address(this));

    if (endAmount > 0) {
      if (_token == ETH_TOKEN_ADDRESS) {
        (msg.sender).transfer(endAmount);
      } else {
        ERC20(_token).transfer(msg.sender, endAmount);
      }
    }
  }

  function convertTokentoCOTviaETH(address _token, uint256 _amount)
  public
  returns (uint256 cotAmount)
  {

    uint256 receivedETH = _tradeKyber(
        ERC20(_token),
        _amount,
        ERC20(ETH_TOKEN_ADDRESS)
    );

    cotAmount = _tradeBancor(
        ETH_TOKEN_ADDRESS,
        cotToken,
        receivedETH
    );

    ERC20(cotToken).transfer(msg.sender, cotAmount);

    uint256 endAmountOfETH = address(this).balance;
    uint256 endAmountOfERC = ERC20(_token).balanceOf(address(this));

    if(endAmountOfETH > 0)
      (msg.sender).transfer(endAmountOfETH);
    if(endAmountOfERC > 0)
      ERC20(_token).transfer(msg.sender, endAmountOfERC);
  }


 function _tradeKyber(
   ERC20 _source,
   uint256 _sourceAmount,
   ERC20 _destination
 )
   private
   returns (uint256)
 {

   uint256 destinationReceived;
   uint256 _maxDestinationAmount = 2**256-1;
   uint256 _minConversionRate = 1;
   address _walletId = address(0x0000000000000000000000000000000000000000);

   if (_source == ETH_TOKEN_ADDRESS) {
     destinationReceived = kyber.trade.value(_sourceAmount)(
       _source,
       _sourceAmount,
       _destination,
       this,
       _maxDestinationAmount,
       _minConversionRate,
       _walletId
     );
   } else {
     _transferFromSenderAndApproveTo(_source, _sourceAmount, kyber);
     destinationReceived = kyber.trade(
       _source,
       _sourceAmount,
       _destination,
       this,
       _maxDestinationAmount,
       _minConversionRate,
       _walletId
     );
   }

   return destinationReceived;
 }

 function _tradeBancor(
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

  function _transferFromSenderAndApproveTo(ERC20 _source, uint256 _sourceAmount, address _to) private {

    require(_source.transferFrom(msg.sender, address(this), _sourceAmount));

    _source.approve(_to, _sourceAmount);
  }

  function() public payable {}
}