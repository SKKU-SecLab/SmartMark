
pragma solidity 0.4.24;

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

library Utils {


    uint  constant PRECISION = (10**18);
    uint  constant MAX_DECIMALS = 18;

    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {

        if( dstDecimals >= srcDecimals ) {
            require((dstDecimals-srcDecimals) <= MAX_DECIMALS);
            return (srcQty * rate * (10**(dstDecimals-srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals-dstDecimals) <= MAX_DECIMALS);
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals-dstDecimals)));
        }
    }

}

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

contract ERC20Extended is ERC20 {

    uint256 public decimals;
    string public name;
    string public symbol;

}

contract ComponentInterface {

    string public name;
    string public description;
    string public category;
    string public version;
}

contract ExchangeInterface is ComponentInterface {

    function supportsTradingPair(address _srcAddress, address _destAddress, bytes32 _exchangeId)
        external view returns(bool supported);


    function buyToken
        (
        ERC20Extended _token, uint _amount, uint _minimumRate,
        address _depositAddress, bytes32 _exchangeId, address _partnerId
        ) external payable returns(bool success);

    function sellToken
        (
        ERC20Extended _token, uint _amount, uint _minimumRate,
        address _depositAddress, bytes32 _exchangeId, address _partnerId
        ) external returns(bool success);
}

contract KyberNetworkInterface {


    function getExpectedRate(ERC20Extended src, ERC20Extended dest, uint srcQty)
        external view returns (uint expectedRate, uint slippageRate);


    function trade(
        ERC20Extended source,
        uint srcAmount,
        ERC20Extended dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId)
        external payable returns(uint);

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

contract OlympusExchangeAdapterInterface is Ownable {


    function supportsTradingPair(address _srcAddress, address _destAddress)
        external view returns(bool supported);


    function getPrice(ERC20Extended _sourceAddress, ERC20Extended _destAddress, uint _amount)
        external view returns(uint expectedRate, uint slippageRate);


    function sellToken
        (
        ERC20Extended _token, uint _amount, uint _minimumRate,
        address _depositAddress
        ) external returns(bool success);

    function buyToken
        (
        ERC20Extended _token, uint _amount, uint _minimumRate,
        address _depositAddress
        ) external payable returns(bool success);

    function enable() external returns(bool);

    function disable() external returns(bool);

    function isEnabled() external view returns (bool success);


    function setExchangeDetails(bytes32 _id, bytes32 _name) external returns(bool success);

    function getExchangeDetails() external view returns(bytes32 _name, bool _enabled);


}

contract ERC20NoReturn {

    uint256 public decimals;
    string public name;
    string public symbol;
    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public;

    function approve(address spender, uint tokens) public;

    function transferFrom(address from, address to, uint tokens) public;


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract KyberNetworkAdapter is OlympusExchangeAdapterInterface{

    using SafeMath for uint256;

    KyberNetworkInterface public kyber;
    address public exchangeAdapterManager;
    bytes32 public exchangeId;
    bytes32 public name;
    ERC20Extended public constant ETH_TOKEN_ADDRESS = ERC20Extended(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    address public walletId = 0x09227deaeE08a5Ba9D6Eb057F922aDfAd191c36c;

    bool public adapterEnabled;

    modifier onlyExchangeAdapterManager() {

        require(msg.sender == address(exchangeAdapterManager));
        _;
    }

    constructor (KyberNetworkInterface _kyber, address _exchangeAdapterManager) public {
        require(address(_kyber) != 0x0);
        kyber = _kyber;
        exchangeAdapterManager = _exchangeAdapterManager;
        adapterEnabled = true;
    }

    function setExchangeAdapterManager(address _exchangeAdapterManager) external onlyOwner{

        exchangeAdapterManager = _exchangeAdapterManager;
    }

    function setExchangeDetails(bytes32 _id, bytes32 _name)
    external onlyExchangeAdapterManager returns(bool)
    {

        exchangeId = _id;
        name = _name;
        return true;
    }

    function getExchangeDetails()
    external view returns(bytes32 _name, bool _enabled)
    {

        return (name, adapterEnabled);
    }

    function getExpectAmount(uint eth, uint destDecimals, uint rate) internal pure returns(uint){

        return Utils.calcDstQty(eth, 18, destDecimals, rate);
    }

    function configAdapter(KyberNetworkInterface _kyber, address _walletId) external onlyOwner returns(bool success) {

        if(address(_kyber) != 0x0){
            kyber = _kyber;
        }
        if(_walletId != 0x0){
            walletId = _walletId;
        }
        return true;
    }

    function supportsTradingPair(address _srcAddress, address _destAddress) external view returns(bool supported){

        uint amount = ERC20Extended(_srcAddress) == ETH_TOKEN_ADDRESS ? 10**18 : 10**ERC20Extended(_srcAddress).decimals();
        uint price;
        (price,) = this.getPrice(ERC20Extended(_srcAddress), ERC20Extended(_destAddress), amount);
        return price > 0;
    }

    function enable() external onlyOwner returns(bool){

        adapterEnabled = true;
        return true;
    }

    function disable() external onlyOwner returns(bool){

        adapterEnabled = false;
        return true;
    }

    function isEnabled() external view returns (bool success) {

        return adapterEnabled;
    }

    function getPrice(ERC20Extended _sourceAddress, ERC20Extended _destAddress, uint _amount) external view returns(uint, uint){

        return kyber.getExpectedRate(_sourceAddress, _destAddress, _amount);
    }

    function buyToken(ERC20Extended _token, uint _amount, uint _minimumRate, address _depositAddress)
    external payable returns(bool) {

        if (address(this).balance < _amount) {
            return false;
        }
        require(msg.value == _amount);
        uint slippageRate;

        (, slippageRate) = kyber.getExpectedRate(ETH_TOKEN_ADDRESS, _token, _amount);
        if(slippageRate < _minimumRate){
            return false;
        }

        uint beforeTokenBalance = _token.balanceOf(_depositAddress);
        slippageRate = _minimumRate;
        kyber.trade.value(msg.value)(
            ETH_TOKEN_ADDRESS,
            _amount,
            _token,
            _depositAddress,
            2**256 - 1,
            slippageRate,
            walletId);

        require(_token.balanceOf(_depositAddress) > beforeTokenBalance);

        return true;
    }
    function sellToken(ERC20Extended _token, uint _amount, uint _minimumRate, address _depositAddress)
    external returns(bool success)
    {

        ERC20NoReturn(_token).approve(address(kyber), 0);
        ERC20NoReturn(_token).approve(address(kyber), _amount);
        uint slippageRate;
        (,slippageRate) = kyber.getExpectedRate(_token, ETH_TOKEN_ADDRESS, _amount);

        if(slippageRate < _minimumRate){
            return false;
        }
        slippageRate = _minimumRate;

        kyber.trade(
            _token,
            _amount,
            ETH_TOKEN_ADDRESS,
            _depositAddress,
            2**256 - 1,
            slippageRate,
            walletId);


        return true;
    }

    function withdraw(uint amount) external onlyOwner {


        require(amount <= address(this).balance);

        uint sendAmount = amount;
        if (amount == 0){
            sendAmount = address(this).balance;
        }
        msg.sender.transfer(sendAmount);
    }

}