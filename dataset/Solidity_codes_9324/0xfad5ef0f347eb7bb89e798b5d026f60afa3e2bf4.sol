
pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity 0.8.9;


contract HeroInfinityNodePool is Ownable {

  using SafeMath for uint256;

  struct NodeEntity {
    string name;
    uint256 creationTime;
    uint256 lastClaimTime;
    uint256 feeTime;
    uint256 dueTime;
  }

  mapping(address => uint256) public nodeOwners;
  mapping(address => NodeEntity[]) private _nodesOfUser;

  uint256 public nodePrice = 200000 * 10**18;
  uint256 public rewardPerDay = 8000 * 10**18;
  uint256 public maxNodes = 25;

  uint256 public feeAmount = 10000000000000000;
  uint256 public feeDuration = 28 days;
  uint256 public overDuration = 2 days;

  uint256 public totalNodesCreated = 0;

  IERC20 public hriToken = IERC20(0x0C4BA8e27e337C5e8eaC912D836aA8ED09e80e78);

  constructor() {}

  function createNode(string memory nodeName, uint256 count) external {

    require(count > 0, "Count should be not 0");
    address account = msg.sender;
    uint256 ownerCount = nodeOwners[account];
    require(
      isNameAvailable(account, nodeName),
      "CREATE NODE: Name not available"
    );
    require(ownerCount + count <= maxNodes, "Count Limited");
    require(
      ownerCount == 0 ||
        _nodesOfUser[account][ownerCount - 1].creationTime < block.timestamp,
      "You are creating many nodes in short time. Please try again later."
    );

    uint256 price = nodePrice * count;

    hriToken.transferFrom(account, address(this), price);

    for (uint256 i = 0; i < count; i++) {
      uint256 time = block.timestamp + i;
      _nodesOfUser[account].push(
        NodeEntity({
          name: nodeName,
          creationTime: time,
          lastClaimTime: time,
          feeTime: time + feeDuration,
          dueTime: time + feeDuration + overDuration
        })
      );
      nodeOwners[account]++;
      totalNodesCreated++;
    }
  }

  function isNameAvailable(address account, string memory nodeName)
    internal
    view
    returns (bool)
  {

    NodeEntity[] memory nodes = _nodesOfUser[account];
    for (uint256 i = 0; i < nodes.length; i++) {
      if (keccak256(bytes(nodes[i].name)) == keccak256(bytes(nodeName))) {
        return false;
      }
    }
    return true;
  }

  function _getNodeWithCreatime(
    NodeEntity[] storage nodes,
    uint256 _creationTime
  ) internal view returns (NodeEntity storage) {

    uint256 numberOfNodes = nodes.length;
    require(numberOfNodes > 0, "CLAIM ERROR: You don't have nodes to claim");
    bool found = false;
    int256 index = binarySearch(nodes, 0, numberOfNodes, _creationTime);
    uint256 validIndex;
    if (index >= 0) {
      found = true;
      validIndex = uint256(index);
    }
    require(found, "NODE SEARCH: No NODE Found with this blocktime");
    return nodes[validIndex];
  }

  function binarySearch(
    NodeEntity[] memory arr,
    uint256 low,
    uint256 high,
    uint256 x
  ) internal view returns (int256) {

    if (high >= low) {
      uint256 mid = (high + low).div(2);
      if (arr[mid].creationTime == x) {
        return int256(mid);
      } else if (arr[mid].creationTime > x) {
        return binarySearch(arr, low, mid - 1, x);
      } else {
        return binarySearch(arr, mid + 1, high, x);
      }
    } else {
      return -1;
    }
  }

  function getNodeReward(NodeEntity memory node)
    internal
    view
    returns (uint256)
  {

    if (block.timestamp > node.dueTime) {
      return 0;
    }
    return (rewardPerDay * (block.timestamp - node.lastClaimTime)) / 86400;
  }

  function payNodeFee(uint256 _creationTime) external payable {

    require(msg.value >= feeAmount, "Need to pay fee amount");
    NodeEntity[] storage nodes = _nodesOfUser[msg.sender];
    NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
    require(node.dueTime >= block.timestamp, "Node is disabled");
    node.feeTime = block.timestamp + feeDuration;
    node.dueTime = node.feeTime + overDuration;
  }

  function payAllNodesFee() external payable {

    NodeEntity[] storage nodes = _nodesOfUser[msg.sender];
    uint256 nodesCount = 0;
    for (uint256 i = 0; i < nodes.length; i++) {
      if (nodes[i].dueTime >= block.timestamp) {
        nodesCount++;
      }
    }
    require(msg.value >= feeAmount * nodesCount, "Need to pay fee amount");
    for (uint256 i = 0; i < nodes.length; i++) {
      if (nodes[i].dueTime >= block.timestamp) {
        nodes[i].feeTime = block.timestamp + feeDuration;
        nodes[i].dueTime = nodes[i].feeTime + overDuration;
      }
    }
  }

  function claimNodeReward(uint256 _creationTime) external {

    address account = msg.sender;
    require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    uint256 numberOfNodes = nodes.length;
    require(numberOfNodes > 0, "CLAIM ERROR: You don't have nodes to claim");
    NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
    uint256 rewardNode = getNodeReward(node);
    node.lastClaimTime = block.timestamp;
    hriToken.transfer(account, rewardNode);
  }

  function claimAllNodesReward() external {

    address account = msg.sender;
    NodeEntity[] storage nodes = _nodesOfUser[account];
    uint256 nodesCount = nodes.length;
    require(nodesCount > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity storage _node;
    uint256 rewardsTotal = 0;
    for (uint256 i = 0; i < nodesCount; i++) {
      _node = nodes[i];
      uint256 nodeReward = getNodeReward(_node);
      rewardsTotal += nodeReward;
      _node.lastClaimTime = block.timestamp;
    }
    hriToken.transfer(account, rewardsTotal);
  }

  function getRewardTotalAmountOf(address account)
    external
    view
    returns (uint256)
  {

    uint256 nodesCount;
    uint256 rewardCount = 0;

    NodeEntity[] storage nodes = _nodesOfUser[account];
    nodesCount = nodes.length;

    for (uint256 i = 0; i < nodesCount; i++) {
      uint256 nodeReward = getNodeReward(nodes[i]);
      rewardCount += nodeReward;
    }

    return rewardCount;
  }

  function getRewardAmountOf(address account, uint256 creationTime)
    external
    view
    returns (uint256)
  {

    require(creationTime > 0, "NODE: CREATIME must be higher than zero");
    NodeEntity[] storage nodes = _nodesOfUser[account];
    uint256 numberOfNodes = nodes.length;
    require(numberOfNodes > 0, "CLAIM ERROR: You don't have nodes to claim");
    NodeEntity storage node = _getNodeWithCreatime(nodes, creationTime);
    uint256 nodeReward = getNodeReward(node);
    return nodeReward;
  }

  function getNodes(address account)
    external
    view
    returns (NodeEntity[] memory nodes)
  {

    nodes = _nodesOfUser[account];
  }

  function getNodeNumberOf(address account) external view returns (uint256) {

    return nodeOwners[account];
  }

  function withdrawReward(uint256 amount) external onlyOwner {

    hriToken.transfer(msg.sender, amount);
  }

  function withdrawFee(uint256 amount) external onlyOwner {

    payable(msg.sender).transfer(amount);
  }

  function changeNodePrice(uint256 newNodePrice) external onlyOwner {

    nodePrice = newNodePrice;
  }

  function changeRewardPerNode(uint256 _rewardPerDay) external onlyOwner {

    rewardPerDay = _rewardPerDay;
  }

  function setFeeAmount(uint256 _feeAmount) external onlyOwner {

    feeAmount = _feeAmount;
  }

  function setFeeDuration(uint256 _feeDuration) external onlyOwner {

    feeDuration = _feeDuration;
  }

  function setOverDuration(uint256 _overDuration) external onlyOwner {

    overDuration = _overDuration;
  }

  function setMaxNodes(uint256 _count) external onlyOwner {

    maxNodes = _count;
  }

  receive() external payable {}
}