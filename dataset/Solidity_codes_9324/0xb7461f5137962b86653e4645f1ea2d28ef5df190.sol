pragma solidity 0.5.0;

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }
}
pragma solidity 0.5.0;

contract RewardContract {

    function balanceOf(bytes32 _bladeId) public view returns (uint256 balance);

    function assignRewards(bytes32[] calldata _bladeIds, uint256[] calldata _rewards) external;

    function claimRewards(bytes32[] calldata _bladeIds, address[] calldata _wallets) external;

    function claimReward(bytes32 _bladeId, address _to) external returns (bool ok);


    event RewardClaimed(bytes32 _bladeId, address _wallet, uint256 _amount);
    event RewardAssigned(bytes32 _bladeId, uint256 _amount);
}
pragma solidity 0.5.0;

contract Adbank {


    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint _amount) public returns (bool ok);

}
pragma solidity 0.5.0;


contract AdbankRewardClaimContract is RewardContract {

    using SafeMath for uint256;

    bool public suspended;

    uint8 public batchLimit;

    address public owner;
    mapping(bytes32 => uint256) public balances;
    uint256 public totalReward;

    Adbank public adbankContract;

    modifier onlyOwner() {

        require (msg.sender == owner);
        _;
    }

    modifier notSuspended() {

        require (suspended == false);
        _;
    }

    constructor(address _adbankContract, uint8 _batchLimit) public {
        owner = msg.sender;
        suspended = false;
        totalReward = 0;
        adbankContract = Adbank(_adbankContract);
        batchLimit = _batchLimit;
    }

    function suspend(bool _suspended) external onlyOwner {

        suspended = _suspended;
    }

    function changeOwner(address _newOwner) external onlyOwner {

        require(_newOwner != address(0x0));
        owner = _newOwner;
    }

    function drain() external onlyOwner {

        uint256 contractBalance = adbankContract.balanceOf(address(this));
        require(contractBalance > 0);

        require(transferReward(owner, contractBalance));
        suspended = true;
    }

    function setBatchLimit(uint8 newLimit) onlyOwner external {

        require(newLimit > 0);
        batchLimit = newLimit;
    }

    function setAdbankContract(address _adbankContract) onlyOwner external {

        require(_adbankContract != address(0x0));
        adbankContract = Adbank(_adbankContract);
    }

    function balanceOf(bytes32 _bladeId) public view returns (uint256 balance) {

        return balances[_bladeId];
    }

    function assignRewards(bytes32[] calldata _bladeIds, uint256[] calldata _rewards) notSuspended onlyOwner external {

        require(_bladeIds.length > 0 && _bladeIds.length <= batchLimit);
        require(_bladeIds.length == _rewards.length);

        for (uint8 i = 0; i < _bladeIds.length; i++) {
            balances[_bladeIds[i]] = (balances[_bladeIds[i]]).add(_rewards[i]);
            totalReward = (totalReward).add(_rewards[i]);
            emit RewardAssigned(_bladeIds[i], _rewards[i]);
        }

        require(hasEnoughBalance());
    }

    function claimRewards(bytes32[] calldata _bladeIds, address[] calldata _wallets) notSuspended onlyOwner external {

        require(_bladeIds.length > 0 && _bladeIds.length <= batchLimit);
        require(_bladeIds.length == _wallets.length);

        require(hasEnoughBalance());

        for (uint8 i = 0; i < _bladeIds.length; i++) {
            processReward(_bladeIds[i], _wallets[i], false);
        }
    }

    function claimReward(bytes32 _bladeId, address _to) notSuspended onlyOwner external returns (bool ok) {

        return processReward(_bladeId, _to, true);
    }

    function processReward(bytes32 _bladeId, address _to, bool _requireValid) notSuspended onlyOwner internal returns (bool ok) {

        bool valid = validAddressAndBalance(_to, _bladeId);

        if (_requireValid) {
            require(valid);
        } else if (!valid) {
            return false;
        }

        uint256 rewardToSend = balances[_bladeId];

        balances[_bladeId] = 0;
        totalReward = (totalReward).sub(rewardToSend);

        bool transferStatus = transferReward(_to, rewardToSend);
        emit RewardClaimed(_bladeId, _to, rewardToSend);
        return transferStatus;
    }

    function transferReward(address _to, uint256 _amount) onlyOwner internal returns (bool ok) {

        bool result = adbankContract.transfer(_to, _amount);
        require(result);
        return result;
    }

    function validAddressAndBalance(address _address, bytes32 _bladeId) internal view returns (bool valid) {

        if (_address != address(0x0) && balances[_bladeId] > 0) {
            return true;
        }

        return false;
    }

    function hasEnoughBalance() public view returns (bool enoughBalance) {

        return adbankContract.balanceOf(address(this)) >= totalReward;
    }
}
pragma solidity ^0.5.0;

contract Migrations {

  address public owner;
  uint public last_completed_migration;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {

    if (msg.sender == owner) _;
  }

  function setCompleted(uint completed) public restricted {

    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {

    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
