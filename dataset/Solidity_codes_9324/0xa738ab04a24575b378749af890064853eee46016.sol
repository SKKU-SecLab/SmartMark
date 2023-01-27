
pragma solidity 0.6.8;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
        return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0);
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}

interface ERC20 {

  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint value) external  returns (bool success);

  function transferFrom(address from, address to, uint value) external returns (bool success);

  function approve(address spender, uint amount) external returns (bool success);

}

contract CuraAnnonae {

  using SafeMath for uint256;

  ERC20 public YFMSToken;
  address public owner;
  uint256 public numberOfVaults;
  uint256 public rewardsBalance;
  uint256 public lastRewardUpdate = 0;
  uint256 public currentDailyReward;

  mapping(string => mapping(address => uint256)) internal vaults_data; // { VaultName: { UserAddress: value }}

  constructor(address _wallet) public {
    owner = msg.sender;
    YFMSToken = ERC20(_wallet);
  }

  function getRewardsBalance() public view returns (uint256) {

    return YFMSToken.balanceOf(address(this));
  }

  function getDailyReward() public view returns (uint256) {

    return currentDailyReward;
  }

  function getNumberOfVaults() public view returns (uint256) {

    return numberOfVaults;
  }

  function getUserBalanceInVault(string memory _vault, address _user) public view returns (uint256) {

    require(vaults_data[_vault][_user] >= 0);
    return vaults_data[_vault][_user];
  }

  function updateDailyReward() public {

    require(msg.sender == owner);
    require(now.sub(lastRewardUpdate) >= 1 days || lastRewardUpdate == 0);
    lastRewardUpdate = now;
    currentDailyReward = YFMSToken.balanceOf(address(this)) / 10000 * 40;
  }

  function updateVaultData(string memory vault, address who, address user, uint256 value) public {

    require(msg.sender == who);
    require(value > 0);
    vaults_data[vault][user] = vaults_data[vault][user].add(value);
  }

  function addVault(string memory name) public {

    require(msg.sender == owner);
    vaults_data[name][msg.sender] = 0; 
    numberOfVaults = numberOfVaults.add(1);
  }

  function stake(string memory _vault, address _receiver, uint256 _amount, address vault) public returns (bool) {

    require(msg.sender == vault); // require that the vault is calling the contract.
    vaults_data[_vault][_receiver] = vaults_data[_vault][_receiver].add(_amount);
    return true;
  }

  function unstake(string memory _vault, address _receiver, address vault) public {

    require(msg.sender == vault); // require that the vault is calling the contract.
    vaults_data[_vault][_receiver] = 0;
  }

  function distributeRewardsToVault(address vault) public {

    require(msg.sender == owner);
    require(currentDailyReward > 0);
    uint256 rewards = currentDailyReward.div(numberOfVaults);
    YFMSToken.transfer(vault, rewards);
  }
}