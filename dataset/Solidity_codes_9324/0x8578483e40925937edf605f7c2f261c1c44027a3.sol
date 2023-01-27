

pragma solidity ^0.4.23;

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


contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}

library SafeERC20 {

  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {

    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {

    require(token.approve(spender, value));
  }
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


contract MarginlyVesting is Ownable {

  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(address beneficiary, uint256 amount);

  ERC20Basic public token;
  uint256 public cliff;
  uint256 public start;
  uint256 public duration;

  mapping (address => uint256) public shares;

  uint256 released = 0;

  address[] public beneficiaries;

  modifier onlyBeneficiaries {

    require(msg.sender == owner || shares[msg.sender] > 0, "You cannot release tokens!");
    _;
  }

  constructor(
    ERC20Basic _token,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration
  )
  public
  {
    require(_cliff <= _duration, "Cliff has to be lower or equal to duration");
    token = _token;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  function addBeneficiary(address _beneficiary, uint256 _sharesAmount) onlyOwner public {

    require(_beneficiary != address(0), "The beneficiary's address cannot be 0");
    require(_sharesAmount > 0, "Shares amount has to be greater than 0");

    releaseAllTokens();

    if (shares[_beneficiary] == 0) {
      beneficiaries.push(_beneficiary);
    }

    shares[_beneficiary] = shares[_beneficiary].add(_sharesAmount);
  }

  function releaseAllTokens() onlyBeneficiaries public {

    uint256 unreleased = releasableAmount();

    if (unreleased > 0) {
      uint beneficiariesCount = beneficiaries.length;

      released = released.add(unreleased);

      for (uint i = 0; i < beneficiariesCount; i++) {
        release(beneficiaries[i], calculateShares(unreleased, beneficiaries[i]));
      }
    }
  }

  function releasableAmount() public view returns (uint256) {

    return vestedAmount().sub(released);
  }

  function calculateShares(uint256 _amount, address _beneficiary) public view returns (uint256) {

    return _amount.mul(shares[_beneficiary]).div(totalShares());
  }

  function totalShares() public view returns (uint256) {

    uint sum = 0;
    uint beneficiariesCount = beneficiaries.length;

    for (uint i = 0; i < beneficiariesCount; i++) {
      sum = sum.add(shares[beneficiaries[i]]);
    }

    return sum;
  }

  function vestedAmount() public view returns (uint256) {

    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released);

    if (block.timestamp < cliff) {
      return 0;
    } else if (block.timestamp >= start.add(duration)) {
      return totalBalance;
    } else {
      return totalBalance.mul(block.timestamp.sub(start)).div(duration);
    }
  }

  function release(address _beneficiary, uint256 _amount) private {

    token.safeTransfer(_beneficiary, _amount);
    emit Released(_beneficiary, _amount);
  }
}