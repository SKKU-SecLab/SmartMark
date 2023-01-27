
pragma solidity >=0.6.0 <0.8.0;

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
}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketStorageInterface {


    function getDeployedStatus() external view returns (bool);


    function getGuardian() external view returns(address);

    function setGuardian(address _newAddress) external;

    function confirmGuardian() external;


    function getAddress(bytes32 _key) external view returns (address);

    function getUint(bytes32 _key) external view returns (uint);

    function getString(bytes32 _key) external view returns (string memory);

    function getBytes(bytes32 _key) external view returns (bytes memory);

    function getBool(bytes32 _key) external view returns (bool);

    function getInt(bytes32 _key) external view returns (int);

    function getBytes32(bytes32 _key) external view returns (bytes32);


    function setAddress(bytes32 _key, address _value) external;

    function setUint(bytes32 _key, uint _value) external;

    function setString(bytes32 _key, string calldata _value) external;

    function setBytes(bytes32 _key, bytes calldata _value) external;

    function setBool(bytes32 _key, bool _value) external;

    function setInt(bytes32 _key, int _value) external;

    function setBytes32(bytes32 _key, bytes32 _value) external;


    function deleteAddress(bytes32 _key) external;

    function deleteUint(bytes32 _key) external;

    function deleteString(bytes32 _key) external;

    function deleteBytes(bytes32 _key) external;

    function deleteBool(bytes32 _key) external;

    function deleteInt(bytes32 _key) external;

    function deleteBytes32(bytes32 _key) external;


    function addUint(bytes32 _key, uint256 _amount) external;

    function subUint(bytes32 _key, uint256 _amount) external;


    function getNodeWithdrawalAddress(address _nodeAddress) external view returns (address);

    function getNodePendingWithdrawalAddress(address _nodeAddress) external view returns (address);

    function setWithdrawalAddress(address _nodeAddress, address _newWithdrawalAddress, bool _confirm) external;

    function confirmWithdrawalAddress(address _nodeAddress) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;




abstract contract RocketBase {

    uint256 constant calcBase = 1 ether;

    uint8 public version;

    RocketStorageInterface rocketStorage = RocketStorageInterface(0);



    modifier onlyLatestNetworkContract() {
        require(getBool(keccak256(abi.encodePacked("contract.exists", msg.sender))), "Invalid or outdated network contract");
        _;
    }

    modifier onlyLatestContract(string memory _contractName, address _contractAddress) {
        require(_contractAddress == getAddress(keccak256(abi.encodePacked("contract.address", _contractName))), "Invalid or outdated contract");
        _;
    }

    modifier onlyRegisteredNode(address _nodeAddress) {
        require(getBool(keccak256(abi.encodePacked("node.exists", _nodeAddress))), "Invalid node");
        _;
    }

    modifier onlyTrustedNode(address _nodeAddress) {
        require(getBool(keccak256(abi.encodePacked("dao.trustednodes.", "member", _nodeAddress))), "Invalid trusted node");
        _;
    }

    modifier onlyRegisteredMinipool(address _minipoolAddress) {
        require(getBool(keccak256(abi.encodePacked("minipool.exists", _minipoolAddress))), "Invalid minipool");
        _;
    }
    

    modifier onlyGuardian() {
        require(msg.sender == rocketStorage.getGuardian(), "Account is not a temporary guardian");
        _;
    }





    constructor(RocketStorageInterface _rocketStorageAddress) {
        rocketStorage = RocketStorageInterface(_rocketStorageAddress);
    }


    function getContractAddress(string memory _contractName) internal view returns (address) {
        address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
        require(contractAddress != address(0x0), "Contract not found");
        return contractAddress;
    }


    function getContractAddressUnsafe(string memory _contractName) internal view returns (address) {
        address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
        return contractAddress;
    }


    function getContractName(address _contractAddress) internal view returns (string memory) {
        string memory contractName = getString(keccak256(abi.encodePacked("contract.name", _contractAddress)));
        require(bytes(contractName).length > 0, "Contract not found");
        return contractName;
    }

    function getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        if (_returnData.length < 68) return "Transaction reverted silently";
        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }





    function getAddress(bytes32 _key) internal view returns (address) { return rocketStorage.getAddress(_key); }
    function getUint(bytes32 _key) internal view returns (uint) { return rocketStorage.getUint(_key); }
    function getString(bytes32 _key) internal view returns (string memory) { return rocketStorage.getString(_key); }
    function getBytes(bytes32 _key) internal view returns (bytes memory) { return rocketStorage.getBytes(_key); }
    function getBool(bytes32 _key) internal view returns (bool) { return rocketStorage.getBool(_key); }
    function getInt(bytes32 _key) internal view returns (int) { return rocketStorage.getInt(_key); }
    function getBytes32(bytes32 _key) internal view returns (bytes32) { return rocketStorage.getBytes32(_key); }

    function setAddress(bytes32 _key, address _value) internal { rocketStorage.setAddress(_key, _value); }
    function setUint(bytes32 _key, uint _value) internal { rocketStorage.setUint(_key, _value); }
    function setString(bytes32 _key, string memory _value) internal { rocketStorage.setString(_key, _value); }
    function setBytes(bytes32 _key, bytes memory _value) internal { rocketStorage.setBytes(_key, _value); }
    function setBool(bytes32 _key, bool _value) internal { rocketStorage.setBool(_key, _value); }
    function setInt(bytes32 _key, int _value) internal { rocketStorage.setInt(_key, _value); }
    function setBytes32(bytes32 _key, bytes32 _value) internal { rocketStorage.setBytes32(_key, _value); }

    function deleteAddress(bytes32 _key) internal { rocketStorage.deleteAddress(_key); }
    function deleteUint(bytes32 _key) internal { rocketStorage.deleteUint(_key); }
    function deleteString(bytes32 _key) internal { rocketStorage.deleteString(_key); }
    function deleteBytes(bytes32 _key) internal { rocketStorage.deleteBytes(_key); }
    function deleteBool(bytes32 _key) internal { rocketStorage.deleteBool(_key); }
    function deleteInt(bytes32 _key) internal { rocketStorage.deleteInt(_key); }
    function deleteBytes32(bytes32 _key) internal { rocketStorage.deleteBytes32(_key); }

    function addUint(bytes32 _key, uint256 _amount) internal { rocketStorage.addUint(_key, _amount); }
    function subUint(bytes32 _key, uint256 _amount) internal { rocketStorage.subUint(_key, _amount); }
}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;
pragma abicoder v2;


interface RocketNodeManagerInterface {


    struct TimezoneCount {
        string timezone;
        uint256 count;
    }

    function getNodeCount() external view returns (uint256);

    function getNodeCountPerTimezone(uint256 offset, uint256 limit) external view returns (TimezoneCount[] memory);

    function getNodeAt(uint256 _index) external view returns (address);

    function getNodeExists(address _nodeAddress) external view returns (bool);

    function getNodeWithdrawalAddress(address _nodeAddress) external view returns (address);

    function getNodePendingWithdrawalAddress(address _nodeAddress) external view returns (address);

    function getNodeTimezoneLocation(address _nodeAddress) external view returns (string memory);

    function registerNode(string calldata _timezoneLocation) external;

    function setTimezoneLocation(string calldata _timezoneLocation) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketNodeStakingInterface {

    function getTotalRPLStake() external view returns (uint256);

    function getNodeRPLStake(address _nodeAddress) external view returns (uint256);

    function getNodeRPLStakedTime(address _nodeAddress) external view returns (uint256);

    function getTotalEffectiveRPLStake() external view returns (uint256);

    function calculateTotalEffectiveRPLStake(uint256 offset, uint256 limit, uint256 rplPrice) external view returns (uint256);

    function getNodeEffectiveRPLStake(address _nodeAddress) external view returns (uint256);

    function getNodeMinimumRPLStake(address _nodeAddress) external view returns (uint256);

    function getNodeMaximumRPLStake(address _nodeAddress) external view returns (uint256);

    function getNodeMinipoolLimit(address _nodeAddress) external view returns (uint256);

    function stakeRPL(uint256 _amount) external;

    function withdrawRPL(uint256 _amount) external;

    function slashRPL(address _nodeAddress, uint256 _ethSlashAmount) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketRewardsPoolInterface {

    function getRPLBalance() external view returns(uint256);

    function getClaimIntervalTimeStart() external view returns(uint256);

    function getClaimIntervalTimeStartComputed() external view returns(uint256);

    function getClaimIntervalsPassed() external view returns(uint256);

    function getClaimIntervalTime() external view returns(uint256);

    function getClaimTimeLastMade() external view returns(uint256);

    function getClaimIntervalRewardsTotal() external view returns(uint256);

    function getClaimingContractTotalClaimed(string memory _claimingContract) external view returns(uint256);

    function getClaimingContractUserTotalNext(string memory _claimingContract) external view returns(uint256);

    function getClaimingContractUserTotalCurrent(string memory _claimingContract) external view returns(uint256);  

    function getClaimingContractUserHasClaimed(uint256 _claimIntervalStartTime, string memory _claimingContract, address _claimerAddress) external view returns(bool);

    function getClaimingContractUserCanClaim(string memory _claimingContract, address _claimerAddress) external view returns(bool);

    function getClaimingContractUserRegisteredTime(string memory _claimingContract, address _claimerAddress) external view returns(uint256);

    function getClaimingContractAllowance(string memory _claimingContract) external view returns(uint256);

    function getClaimingContractPerc(string memory _claimingContract) external view returns(uint256);

    function getClaimingContractPercLast(string memory _claimingContract) external view returns(uint256);

    function getClaimingContractExists(string memory _contractName) external view returns (bool);

    function getClaimingContractEnabled(string memory _contractName) external view returns (bool);

    function getClaimAmount(string memory _claimingContract, address _claimerAddress, uint256 _claimerAmountPerc) external view returns (uint256);

    function registerClaimer(address _claimerAddress, bool _enabled) external;

    function claim(address _claimerAddress, address _toAddress, uint256 _claimerAmount) external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;


interface RocketClaimNodeInterface {

    function getEnabled() external view returns (bool);

    function getClaimPossible(address _nodeAddress) external view returns (bool);

    function getClaimRewardsPerc(address _nodeAddress) external view returns (uint256);

    function getClaimRewardsAmount(address _nodeAddress) external view returns (uint256);

    function register(address _nodeAddress, bool _enable) external;

    function claim() external;

}/**
  *       .
  *      / \
  *     |.'.|
  *     |'.'|
  *   ,'|   |`.
  *  |,-'-|-'-.|
  *   __|_| |         _        _      _____           _
  *  | ___ \|        | |      | |    | ___ \         | |
  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |
  *  |    // _ \ / __| |/ / _ \ __|  |  __/ _ \ / _ \| |
  *  | |\ \ (_) | (__|   <  __/ |_   | | | (_) | (_) | |
  *  \_| \_\___/ \___|_|\_\___|\__|  \_|  \___/ \___/|_|
  * +---------------------------------------------------+
  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |
  * +---------------------------------------------------+
  *
  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to
  *  be community-owned, decentralised, and trustless.
  *
  *  For more information about Rocket Pool, visit https://rocketpool.net
  *
  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty
  *
  */

pragma solidity 0.7.6;





contract RocketClaimNode is RocketBase, RocketClaimNodeInterface {


    using SafeMath for uint;

    constructor(RocketStorageInterface _rocketStorageAddress) RocketBase(_rocketStorageAddress) {
        version = 1;
    }

    function getEnabled() override external view returns (bool) {

        RocketRewardsPoolInterface rocketRewardsPool = RocketRewardsPoolInterface(getContractAddress("rocketRewardsPool"));
        return rocketRewardsPool.getClaimingContractEnabled("rocketClaimNode");
    }

    function getClaimPossible(address _nodeAddress) override public view onlyRegisteredNode(_nodeAddress) returns (bool) {

        RocketRewardsPoolInterface rocketRewardsPool = RocketRewardsPoolInterface(getContractAddress("rocketRewardsPool"));
        RocketNodeStakingInterface rocketNodeStaking = RocketNodeStakingInterface(getContractAddress("rocketNodeStaking"));
        return (
            rocketRewardsPool.getClaimingContractUserCanClaim("rocketClaimNode", _nodeAddress) &&
            rocketNodeStaking.getNodeRPLStake(_nodeAddress) >= rocketNodeStaking.getNodeMinimumRPLStake(_nodeAddress)
        );
    }

    function getClaimRewardsPerc(address _nodeAddress) override public view onlyRegisteredNode(_nodeAddress) returns (uint256) {

        if (!getClaimPossible(_nodeAddress)) { return 0; }
        RocketNodeStakingInterface rocketNodeStaking = RocketNodeStakingInterface(getContractAddress("rocketNodeStaking"));
        uint256 totalRplStake = rocketNodeStaking.getTotalEffectiveRPLStake();
        if (totalRplStake == 0) { return 0; }
        return calcBase.mul(rocketNodeStaking.getNodeEffectiveRPLStake(_nodeAddress)).div(totalRplStake);
    }

    function getClaimRewardsAmount(address _nodeAddress) override external view onlyRegisteredNode(_nodeAddress) returns (uint256) {

        RocketRewardsPoolInterface rocketRewardsPool = RocketRewardsPoolInterface(getContractAddress("rocketRewardsPool"));
        return rocketRewardsPool.getClaimAmount("rocketClaimNode", _nodeAddress, getClaimRewardsPerc(_nodeAddress));
    }

    function register(address _nodeAddress, bool _enable) override external onlyLatestContract("rocketClaimNode", address(this)) onlyLatestContract("rocketNodeManager", msg.sender) onlyRegisteredNode(_nodeAddress) {

        RocketRewardsPoolInterface rocketRewardsPool = RocketRewardsPoolInterface(getContractAddress("rocketRewardsPool"));
        rocketRewardsPool.registerClaimer(_nodeAddress, _enable);
    }

    function claim() override external onlyLatestContract("rocketClaimNode", address(this)) onlyRegisteredNode(msg.sender) {

        require(getClaimPossible(msg.sender), "The node is currently unable to claim");
        RocketNodeManagerInterface rocketNodeManager = RocketNodeManagerInterface(getContractAddress("rocketNodeManager"));
        address nodeWithdrawalAddress = rocketNodeManager.getNodeWithdrawalAddress(msg.sender);
        RocketRewardsPoolInterface rocketRewardsPool = RocketRewardsPoolInterface(getContractAddress("rocketRewardsPool"));
        rocketRewardsPool.claim(msg.sender, nodeWithdrawalAddress, getClaimRewardsPerc(msg.sender));
    }

}