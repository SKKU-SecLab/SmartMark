pragma solidity 0.7.5;

interface IERC20 {

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function name() external view returns (string memory); // optional method - see eip spec

  function symbol() external view returns (string memory); // optional method - see eip spec

  function decimals() external view returns (uint8); // optional method - see eip spec

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

}// MIT
pragma solidity 0.7.5;

contract Owned {


  address public owner = msg.sender;

  event LogOwnershipTransferred(address indexed owner, address indexed newOwner);

  modifier onlyOwner {

    require(msg.sender == owner, "Only owner");
    _;
  }

  function setOwner(address _owner)
    external
    onlyOwner
  {

    require(_owner != address(0), "Owner cannot be zero address");
    emit LogOwnershipTransferred(owner, _owner);
    owner = _owner;
  }
}// MIT

pragma solidity 0.7.5;

interface IValidatorRegistration {

  struct Node {
    uint stake;
    Fee[12] fees;
    mapping (address => uint) stakerBalance;
  }

  struct Fee {
    uint balance;
    mapping (address => bool) isWithdrawn;
  }

  function getNodeStake(uint8 node) external view returns (uint);


  function getStakerBalance(uint8 node, address staker) external view returns (uint);


  function depositStakeAndAgreeToTermsAndConditions(uint amount, uint8 node) external;


  function withdrawStake(uint amount, uint8 node) external;


  function depositFees(uint amount, uint8 node, uint8 month) external;


  function withdrawFees(uint8 _node, uint8 month) external;


  function flipIsWithdrawStake() external;


  function removeStaker(address staker, uint8 _node) external;


  function drain(address dst) external;

}// MIT

pragma solidity 0.7.5;


contract ValidatorRegistration2 is Owned {  

  uint8 public constant NUM_NODES = 10;
  uint8 public constant NUM_MONTHS = 12;

  struct Node {
    uint stake;
    Fee[NUM_MONTHS] fees;
    mapping (address => uint) stakerBalance;
  }

  struct Fee {
    uint balance;
    mapping (address => bool) isWithdrawn;
  }

  IERC20 public avt;
  IValidatorRegistration public vr;
  bool public isWithdrawStake;
  bool public isWithdrawFees;
  uint[NUM_NODES] public MAX_NODE_STAKE;
  Node[NUM_NODES] public nodes;

  constructor(IValidatorRegistration _vr, IERC20 _avt) {
    vr = _vr;
    avt = _avt;
    isWithdrawStake = false;
    isWithdrawFees = false;
  }

  function getNodeStake(uint8 node)
    external
    view
    returns (uint)
  {

    require(node <= 9, "Invalid node index specified");
    return nodes[node].stake;
  }

  function getStakerBalance(uint8 node, address staker)
    external
    view
    returns (uint)
  {

    require(node <= 9, "Invalid node index specified");
    require(staker != address(0x0), "Staker is null address");
    return nodes[node].stakerBalance[staker];
  }

  function depositStakeAndAgreeToTermsAndConditions(uint amount, uint8 node)
    external
  {

    require(node <= 9, "Invalid node index specified");
    require(nodes[node].stake + amount <= MAX_NODE_STAKE[node], "Balance being deposited is too much for specified bucket");

    nodes[node].stake += amount;
    nodes[node].stakerBalance[msg.sender] += amount;

    require(avt.transferFrom(msg.sender, address(this), amount), "Approved insufficient funds for deposit");
  }

  function withdrawStake(uint amount, uint8 node)
    external
  {

    require(node <= 9, "Invalid node index specified");
    require(isWithdrawStake, "Contract is not currently accepting withdrawals of stake");
    require(nodes[node].stakerBalance[msg.sender] >= amount, "Balance being withdrawn is too much for msg.sender");

    nodes[node].stake -= amount;
    nodes[node].stakerBalance[msg.sender] -= amount;

    require(avt.transfer(msg.sender, amount), "Insufficient contract AVT balance to withdraw stake");
  }

  function depositFees(uint8 node, uint8 month)
    external
  {

    require(node <= 9, "Invalid node index specified");
    require(month <= 12, "Invalid month specified");

    uint amount = avt.balanceOf(address(this));

    vr.withdrawFees(node, month);

    nodes[node].fees[month].balance += avt.balanceOf(address(this)) - amount;
  }

  function withdrawFees(uint8 node, uint8 month)
    external
  {

    require(node <= 9, "Invalid node index specified");
    require(month <= 12, "Invalid month specified");
    require(isWithdrawFees, "Contract is not currently accepting withdrawals of fees");

    require(!nodes[node].fees[month].isWithdrawn[msg.sender], "Transaction sender is not owed any fees for specified node and month");

    uint amount = nodes[node].fees[month].balance * nodes[node].stakerBalance[msg.sender] / nodes[node].stake;

    require(amount > 0, "No amount to be withdrawn");

    nodes[node].fees[month].balance -= amount;
    nodes[node].fees[month].isWithdrawn[msg.sender] = true;

    require(avt.transfer(msg.sender, amount), "Contract has insufficient funds for withdrawal");
  }


  function stakeInValidatorRegistration(uint8 node, uint amount) 
    external
    onlyOwner
  {

    require(node <= 9, "Invalid node index specified");
    require(avt.approve(address(vr), amount), "Specified amount of AVT cannot be approved");

    vr.depositStakeAndAgreeToTermsAndConditions(amount, node);
  }

  function flipIsWithdrawStake()
    external
    onlyOwner
  {

    isWithdrawStake = !isWithdrawStake;
  }

  function flipIsWithdrawFees()
    external
    onlyOwner
  {

    isWithdrawFees = !isWithdrawFees;
  }

  function setMaxNodeStake(uint8 node, uint amount)
    external
    onlyOwner
  {

    require(node <= 9, "Invalid node index specified");
    require(amount <= 250000 ether, "Invalid amount specified");
    MAX_NODE_STAKE[node] = amount;
  }

  function removeStaker(address staker, uint8 node)
    external
    onlyOwner
  {

    require(staker != address(0x0), "Staker is null address");
    require(node <= 9, "Invalid node index specified");

    nodes[node].stake -= nodes[node].stakerBalance[staker];

    nodes[node].stakerBalance[staker] = 0;
  }

  function drain(address dst)
    external
    onlyOwner
  {

    require(dst != address(0x0), "dst is null address");
    require(avt.transfer(dst, avt.balanceOf(address(this))), "AVT transfer failed");
  }
}