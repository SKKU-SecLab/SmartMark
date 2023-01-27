
pragma solidity >=0.6.0;

library SafeMath {

  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    uint256 c = a + b;
    if (c < a) return (false, 0);
    return (true, c);
  }

  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    if (b > a) return (false, 0);
    return (true, a - b);
  }

  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    if (a == 0) return (true, 0);
    uint256 c = a * b;
    if (c / a != b) return (false, 0);
    return (true, c);
  }

  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    if (b == 0) return (false, 0);
    return (true, a / b);
  }

  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    if (b == 0) return (false, 0);
    return (true, a % b);
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath: modulo by zero");
    return a % b;
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

    require(b <= a, errorMessage);
    return a - b;
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    return a / b;
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    return a % b;
  }
}//Unlicense
pragma solidity 0.6.12;


contract Test {

  using SafeMath for uint256;

  event MigratedToNodePack(address indexed entity, uint128 fromNodeId, uint toPackId, uint nodeSeconds, uint totalSeconds);
  event Created(address indexed entity, uint packType, uint nodesCount, bool usedCredit, uint timestamp, address migratedFrom, uint lastPaidAt);

  uint constant public secondsPerBlock = 13;

  mapping(address => uint128) public entityNodeCount;
  mapping(bytes => uint256) public entityNodePaidOnBlock;
  mapping(bytes => uint256) public entityNodeClaimedTotal;

  function getNodeId(address entity, uint128 nodeId) public view returns (bytes memory) {

    uint128 id = nodeId != 0 ? nodeId : entityNodeCount[entity] + 1;
    return abi.encodePacked(entity, id);
  }

  function getRewardAll(address entity, uint256 blockNumber) public view returns (uint256) {

    return 0;
  }

  function setup() external {

    entityNodeCount[msg.sender] = 5;
    entityNodePaidOnBlock[getNodeId(msg.sender, 1)] = 14848087;
    entityNodePaidOnBlock[getNodeId(msg.sender, 2)] = 14945039;
    entityNodePaidOnBlock[getNodeId(msg.sender, 3)] = 14851391;
    entityNodePaidOnBlock[getNodeId(msg.sender, 4)] = 14982358;
    entityNodePaidOnBlock[getNodeId(msg.sender, 5)] = 14936284;
  }

  function migrateAll() external payable {


    uint256 totalClaimed = 0;
    uint128 migratedNodes = 0;
    uint256 totalSeconds = 0;
    uint256 rewardsDue = getRewardAll(msg.sender, 0);

    for (uint128 nodeId = 1; nodeId <= entityNodeCount[msg.sender]; nodeId++) {
      bytes memory id = getNodeId(msg.sender, nodeId);
      bool migrated = true;
      if (migrated) {
        migratedNodes += 1;
        totalClaimed = totalClaimed.add(entityNodeClaimedTotal[id]);
        totalSeconds = totalSeconds.add(block.timestamp - ((block.number - entityNodePaidOnBlock[id]) * secondsPerBlock));
        emit MigratedToNodePack(msg.sender, nodeId, 1, block.timestamp - ((block.number - entityNodePaidOnBlock[id]) * secondsPerBlock), totalSeconds);
      }
    }


    require(migratedNodes > 0, "nothing to migrate");

    migrateNodes(msg.sender, 1, migratedNodes, totalSeconds / migratedNodes, rewardsDue, totalClaimed);
  }

  function migrateNodes(address _entity, uint _packType, uint _nodeCount, uint _lastPaidAt, uint _rewardsDue, uint _totalClaimed) public returns (bool) {

    emit Created(_entity, _packType, _nodeCount, false, block.timestamp, msg.sender, _lastPaidAt);

    return true;
  }
}