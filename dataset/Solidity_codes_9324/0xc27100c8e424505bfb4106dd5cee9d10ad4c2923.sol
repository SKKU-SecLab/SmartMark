pragma solidity 0.5.16;

contract Storage {


  address public governance;
  address public controller;

  constructor() public {
    governance = msg.sender;
  }

  modifier onlyGovernance() {

    require(isGovernance(msg.sender), "Not governance");
    _;
  }

  function setGovernance(address _governance) public onlyGovernance {

    require(_governance != address(0), "new governance shouldn't be empty");
    governance = _governance;
  }

  function setController(address _controller) public onlyGovernance {

    require(_controller != address(0), "new controller shouldn't be empty");
    controller = _controller;
  }

  function isGovernance(address account) public view returns (bool) {

    return account == governance;
  }

  function isController(address account) public view returns (bool) {

    return account == controller;
  }
}pragma solidity 0.5.16;


contract Governable {


  Storage public store;

  constructor(address _store) public {
    require(_store != address(0), "new storage shouldn't be empty");
    store = Storage(_store);
  }

  modifier onlyGovernance() {

    require(store.isGovernance(msg.sender), "Not governance");
    _;
  }

  function setStorage(address _store) public onlyGovernance {

    require(_store != address(0), "new storage shouldn't be empty");
    store = Storage(_store);
  }

  function governance() public view returns (address) {

    return store.governance();
  }
}pragma solidity 0.5.16;


contract Controllable is Governable {


  constructor(address _storage) Governable(_storage) public {
  }

  modifier onlyController() {

    require(store.isController(msg.sender), "Not a controller");
    _;
  }

  modifier onlyControllerOrGovernance(){

    require((store.isController(msg.sender) || store.isGovernance(msg.sender)),
      "The caller must be controller or governance");
    _;
  }

  function controller() public view returns (address) {

    return store.controller();
  }
}pragma solidity 0.5.16;

interface INoMintRewardPool {

    function withdraw(uint) external;

    function getReward() external;

    function stake(uint) external;

    function balanceOf(address) external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function exit() external;


    function rewardDistribution() external view returns (address);

    function lpToken() external view returns(address);

    function rewardToken() external view returns(address);


    function setRewardDistribution(address _rewardDistributor) external;

    function transferOwnership(address _owner) external;

    function notifyRewardAmount(uint256 _reward) external;

}pragma solidity 0.5.16;


contract RewardDistributionSwitcher is Controllable {


  mapping (address => bool) switchingAllowed;

  constructor(address _storage) public Controllable(_storage){}

  function returnOwnership(address poolAddr) public onlyGovernance {

    INoMintRewardPool(poolAddr).transferOwnership(governance());
  }

  function enableSwitchers(address[] memory switchers) public onlyGovernance {

    for(uint256 i = 0; i < switchers.length; i++){
      switchingAllowed[switchers[i]] = true;
    }
  }

  function setSwitcher(address switcher, bool allowed) public onlyGovernance {

    switchingAllowed[switcher] = allowed;
  }


  function setPoolRewardDistribution(address poolAddr, address newRewardDistributor) public {

    require(msg.sender == governance() || switchingAllowed[msg.sender], "msg.sender not allowed to switch");

    INoMintRewardPool(poolAddr).setRewardDistribution(newRewardDistributor);
  }

}