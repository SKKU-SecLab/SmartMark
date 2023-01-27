
pragma solidity ^0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
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
contract IConvertPortal {

  function isConvertibleToCOT(address _token, uint256 _amount)
  public
  view
  returns(uint256);


  function isConvertibleToETH(address _token, uint256 _amount)
  public
  view
  returns(uint256);


  function convertTokentoCOT(address _token, uint256 _amount)
  public
  payable
  returns (uint256 cotAmount);


  function convertTokentoCOTviaETH(address _token, uint256 _amount)
  public
  returns (uint256 cotAmount);

}
contract IStake {

  function addReserve(uint256 _amount) public;

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





library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


contract CoTraderDAOWallet is Ownable{

  using SafeMath for uint256;
  ERC20 public COT;
  IConvertPortal public convertPortal;
  IStake public stake;
  address[] public voters;
  mapping(address => address) public candidatesMap;
  mapping(address => bool) public votersMap;
  ERC20 constant private ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
  address public deadAddress = address(0x000000000000000000000000000000000000dEaD);


  constructor(address _COT, address _stake, address _convertPortal) public {
    COT = ERC20(_COT);
    stake = IStake(_stake);
    convertPortal = IConvertPortal(_convertPortal);
  }

  function _burn(ERC20 _token, uint256 _amount) private {

    uint256 cotAmount = (_token == COT)
    ? _amount
    : convertTokenToCOT(_token, _amount);
    if(cotAmount > 0)
      COT.transfer(deadAddress, cotAmount);
  }

  function _stake(ERC20 _token, uint256 _amount) private {

    uint256 cotAmount = (_token == COT)
    ? _amount
    : convertTokenToCOT(_token, _amount);

    if(cotAmount > 0){
      COT.approve(address(stake), cotAmount);
      stake.addReserve(cotAmount);
    }
  }

  function _withdraw(ERC20 _token, uint256 _amount) private {

    if(_amount > 0)
      if(_token == ETH_TOKEN_ADDRESS){
        address(owner).transfer(_amount);
      }else{
        _token.transfer(owner, _amount);
      }
  }

  function destribute(ERC20[] tokens) {

   for(uint i = 0; i < tokens.length; i++){
      uint256 curentTokenTotalBalance = getTokenBalance(tokens[i]);
      uint256 burnAmount = curentTokenTotalBalance.div(2);
      uint256 stakeAmount = burnAmount.div(5);
      uint256 managerAmount = stakeAmount.mul(4);

      _burn(tokens[i], burnAmount);
      _stake(tokens[i], stakeAmount);
      _withdraw(tokens[i], managerAmount);
    }
  }

  function getTokenBalance(ERC20 _token) public view returns(uint256){

    if(_token == ETH_TOKEN_ADDRESS){
      return address(this).balance;
    }else{
      return _token.balanceOf(address(this));
    }
  }

  function withdrawNonConvertibleERC(ERC20 _token, uint256 _amount) public onlyOwner {

    uint256 cotReturnAmount = convertPortal.isConvertibleToCOT(_token, _amount);
    uint256 ethReturnAmount = convertPortal.isConvertibleToETH(_token, _amount);

    require(_token != ETH_TOKEN_ADDRESS, "token can not be a ETH");
    require(cotReturnAmount == 0, "token can not be converted to COT");
    require(ethReturnAmount == 0, "token can not be converted to ETH");

    _token.transfer(owner, _amount);
  }


  function convertTokenToCOT(address _token, uint256 _amount)
  private
  returns(uint256 cotAmount)
  {

    uint256 cotReturnAmount = convertPortal.isConvertibleToCOT(_token, _amount);
    if(cotReturnAmount > 0) {
      if(ERC20(_token) == ETH_TOKEN_ADDRESS){
        cotAmount = convertPortal.convertTokentoCOT.value(_amount)(_token, _amount);
      }
      else{
        ERC20(_token).approve(address(convertPortal), _amount);
        cotAmount = convertPortal.convertTokentoCOT(_token, _amount);
      }
    }
    else {
      uint256 ethReturnAmount = convertPortal.isConvertibleToETH(_token, _amount);
      if(ethReturnAmount > 0) {
        ERC20(_token).approve(address(convertPortal), _amount);
        cotAmount = convertPortal.convertTokentoCOTviaETH(_token, _amount);
      }
      else{
        cotAmount = 0;
      }
    }
  }

  function changeConvertPortal(address _newConvertPortal)
  public
  onlyOwner
  {

    convertPortal = IConvertPortal(_newConvertPortal);
  }

  function addStakeReserveFromSender(uint256 _amount) public {

    require(COT.transferFrom(msg.sender, address(this), _amount));
    COT.approve(address(stake), _amount);
    stake.addReserve(_amount);
  }



  function voterRegister() public {

    require(!votersMap[msg.sender], "not allowed register the same wallet twice");
    voters.push(msg.sender);
    votersMap[msg.sender] = true;
  }

  function vote(address _candidate) public {

    require(votersMap[msg.sender], "wallet must be registered to vote");
    candidatesMap[msg.sender] = _candidate;
  }

  function calculateCOTHalfSupply() public view returns(uint256){

    uint256 supply = COT.totalSupply();
    uint256 burned = COT.balanceOf(deadAddress);
    return supply.sub(burned).div(2);
  }

  function calculateVoters(address _candidate)public view returns(uint256){

    uint256 count;
    for(uint i = 0; i<voters.length; i++){
      if(_candidate == candidatesMap[voters[i]]){
          count = count.add(COT.balanceOf(voters[i]));
      }
    }
    return count;
  }

  function changeOwner(address _newOwner) public {

    uint256 totalVotersBalance = calculateVoters(_newOwner);
    uint256 totalCOT = calculateCOTHalfSupply();
    require(totalVotersBalance > totalCOT);
    super._transferOwnership(_newOwner);
  }

  function() public payable {}
}