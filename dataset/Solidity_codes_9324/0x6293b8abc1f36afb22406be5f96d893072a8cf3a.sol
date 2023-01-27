
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



enum MinipoolDeposit {
    None,    // Marks an invalid deposit type
    Full,    // The minipool requires 32 ETH from the node operator, 16 ETH of which will be refinanced from user deposits
    Half,    // The minipool required 16 ETH from the node operator to be matched with 16 ETH from user deposits
    Empty    // The minipool requires 0 ETH from the node operator to be matched with 32 ETH from user deposits (trusted nodes only)
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



enum MinipoolStatus {
    Initialised,    // The minipool has been initialised and is awaiting a deposit of user ETH
    Prelaunch,      // The minipool has enough ETH to begin staking and is awaiting launch by the node operator
    Staking,        // The minipool is currently staking
    Withdrawable,   // The minipool has become withdrawable on the beacon chain and can be withdrawn from by the node operator
    Dissolved       // The minipool has been dissolved and its user deposited ETH has been returned to the deposit pool
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





abstract contract RocketMinipoolStorageLayout {
    enum StorageState {
        Undefined,
        Uninitialised,
        Initialised
    }

    RocketStorageInterface internal rocketStorage = RocketStorageInterface(0);

    MinipoolStatus internal status;
    uint256 internal statusBlock;
    uint256 internal statusTime;
    uint256 internal withdrawalBlock;

    MinipoolDeposit internal depositType;

    address internal nodeAddress;
    uint256 internal nodeFee;
    uint256 internal nodeDepositBalance;
    bool internal nodeDepositAssigned;
    uint256 internal nodeRefundBalance;
    uint256 internal nodeSlashBalance;

    uint256 internal userDepositBalance;
    uint256 internal userDepositAssignedTime;

    bool internal useLatestDelegate = false;
    address internal rocketMinipoolDelegate;
    address internal rocketMinipoolDelegatePrev;

    address internal rocketTokenRETH;

    address internal rocketMinipoolPenalty;

    StorageState storageState = StorageState.Undefined;

    bool internal finalised;

    mapping(address => bool) memberScrubVotes;
    uint256 totalScrubVotes;
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




contract RocketMinipool is RocketMinipoolStorageLayout {


    event EtherReceived(address indexed from, uint256 amount, uint256 time);
    event DelegateUpgraded(address oldDelegate, address newDelegate, uint256 time);
    event DelegateRolledBack(address oldDelegate, address newDelegate, uint256 time);


    modifier onlyMinipoolOwner() {

        address withdrawalAddress = rocketStorage.getNodeWithdrawalAddress(nodeAddress);
        require(msg.sender == nodeAddress || msg.sender == withdrawalAddress, "Only the node operator can access this method");
        _;
    }

    constructor(RocketStorageInterface _rocketStorageAddress, address _nodeAddress, MinipoolDeposit _depositType) {
        require(address(_rocketStorageAddress) != address(0x0), "Invalid storage address");
        rocketStorage = RocketStorageInterface(_rocketStorageAddress);
        storageState = StorageState.Uninitialised;
        address delegateAddress = getContractAddress("rocketMinipoolDelegate");
        rocketMinipoolDelegate = delegateAddress;
        require(contractExists(delegateAddress), "Delegate contract does not exist");
        (bool success, bytes memory data) = delegateAddress.delegatecall(abi.encodeWithSignature('initialise(address,uint8)', _nodeAddress, uint8(_depositType)));
        if (!success) { revert(getRevertMessage(data)); }
    }

    receive() external payable {
        emit EtherReceived(msg.sender, msg.value, block.timestamp);
    }

    function delegateUpgrade() external onlyMinipoolOwner {

        rocketMinipoolDelegatePrev = rocketMinipoolDelegate;
        rocketMinipoolDelegate = getContractAddress("rocketMinipoolDelegate");
        require(rocketMinipoolDelegate != rocketMinipoolDelegatePrev, "New delegate is the same as the existing one");
        emit DelegateUpgraded(rocketMinipoolDelegatePrev, rocketMinipoolDelegate, block.timestamp);
    }

    function delegateRollback() external onlyMinipoolOwner {

        require(rocketMinipoolDelegatePrev != address(0x0), "Previous delegate contract is not set");
        address originalDelegate = rocketMinipoolDelegate;
        rocketMinipoolDelegate = rocketMinipoolDelegatePrev;
        rocketMinipoolDelegatePrev = address(0x0);
        emit DelegateRolledBack(originalDelegate, rocketMinipoolDelegate, block.timestamp);
    }

    function setUseLatestDelegate(bool _setting) external onlyMinipoolOwner {

        useLatestDelegate = _setting;
    }

    function getUseLatestDelegate() external view returns (bool) {

        return useLatestDelegate;
    }

    function getDelegate() external view returns (address) {

        return rocketMinipoolDelegate;
    }

    function getPreviousDelegate() external view returns (address) {

        return rocketMinipoolDelegatePrev;
    }

    function getEffectiveDelegate() external view returns (address) {

        return useLatestDelegate ? getContractAddress("rocketMinipoolDelegate") : rocketMinipoolDelegate;
    }

    fallback(bytes calldata _input) external payable returns (bytes memory) {
        address delegateContract = useLatestDelegate ? getContractAddress("rocketMinipoolDelegate") : rocketMinipoolDelegate;
        require(contractExists(delegateContract), "Delegate contract does not exist");
        (bool success, bytes memory data) = delegateContract.delegatecall(_input);
        if (!success) { revert(getRevertMessage(data)); }
        return data;
    }

    function getContractAddress(string memory _contractName) private view returns (address) {

        address contractAddress = rocketStorage.getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
        require(contractAddress != address(0x0), "Contract not found");
        return contractAddress;
    }

    function getRevertMessage(bytes memory _returnData) private pure returns (string memory) {

        if (_returnData.length < 68) { return "Transaction reverted silently"; }
        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }

    function contractExists(address _contractAddress) private returns (bool) {

        uint32 codeSize;
        assembly {
            codeSize := extcodesize(_contractAddress)
        }
        return codeSize > 0;
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


interface RocketDAONodeTrustedInterface {

    function getBootstrapModeDisabled() external view returns (bool);

    function getMemberQuorumVotesRequired() external view returns (uint256);

    function getMemberAt(uint256 _index) external view returns (address);

    function getMemberCount() external view returns (uint256);

    function getMemberMinRequired() external view returns (uint256);

    function getMemberIsValid(address _nodeAddress) external view returns (bool);

    function getMemberLastProposalTime(address _nodeAddress) external view returns (uint256);

    function getMemberID(address _nodeAddress) external view returns (string memory);

    function getMemberUrl(address _nodeAddress) external view returns (string memory);

    function getMemberJoinedTime(address _nodeAddress) external view returns (uint256);

    function getMemberProposalExecutedTime(string memory _proposalType, address _nodeAddress) external view returns (uint256);

    function getMemberRPLBondAmount(address _nodeAddress) external view returns (uint256);

    function getMemberIsChallenged(address _nodeAddress) external view returns (bool);

    function getMemberUnbondedValidatorCount(address _nodeAddress) external view returns (uint256);

    function incrementMemberUnbondedValidatorCount(address _nodeAddress) external;

    function decrementMemberUnbondedValidatorCount(address _nodeAddress) external;

    function bootstrapMember(string memory _id, string memory _url, address _nodeAddress) external;

    function bootstrapSettingUint(string memory _settingContractName, string memory _settingPath, uint256 _value) external;

    function bootstrapSettingBool(string memory _settingContractName, string memory _settingPath, bool _value) external;

    function bootstrapUpgrade(string memory _type, string memory _name, string memory _contractAbi, address _contractAddress) external;

    function bootstrapDisable(bool _confirmDisableBootstrapMode) external;

    function memberJoinRequired(string memory _id, string memory _url) external;

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



interface RocketMinipoolInterface {

    function initialise(address _nodeAddress, MinipoolDeposit _depositType) external;

    function getStatus() external view returns (MinipoolStatus);

    function getFinalised() external view returns (bool);

    function getStatusBlock() external view returns (uint256);

    function getStatusTime() external view returns (uint256);

    function getScrubVoted(address _member) external view returns (bool);

    function getDepositType() external view returns (MinipoolDeposit);

    function getNodeAddress() external view returns (address);

    function getNodeFee() external view returns (uint256);

    function getNodeDepositBalance() external view returns (uint256);

    function getNodeRefundBalance() external view returns (uint256);

    function getNodeDepositAssigned() external view returns (bool);

    function getUserDepositBalance() external view returns (uint256);

    function getUserDepositAssigned() external view returns (bool);

    function getUserDepositAssignedTime() external view returns (uint256);

    function getTotalScrubVotes() external view returns (uint256);

    function calculateNodeShare(uint256 _balance) external view returns (uint256);

    function calculateUserShare(uint256 _balance) external view returns (uint256);

    function nodeDeposit(bytes calldata _validatorPubkey, bytes calldata _validatorSignature, bytes32 _depositDataRoot) external payable;

    function userDeposit() external payable;

    function distributeBalance() external;

    function distributeBalanceAndFinalise() external;

    function refund() external;

    function slash() external;

    function finalise() external;

    function canStake() external view returns (bool);

    function stake(bytes calldata _validatorSignature, bytes32 _depositDataRoot) external;

    function setWithdrawable() external;

    function dissolve() external;

    function close() external;

    function voteScrub() external;

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



interface RocketMinipoolManagerInterface {

    function getMinipoolCount() external view returns (uint256);

    function getStakingMinipoolCount() external view returns (uint256);

    function getFinalisedMinipoolCount() external view returns (uint256);

    function getActiveMinipoolCount() external view returns (uint256);

    function getMinipoolCountPerStatus(uint256 offset, uint256 limit) external view returns (uint256, uint256, uint256, uint256, uint256);

    function getPrelaunchMinipools(uint256 offset, uint256 limit) external view returns (address[] memory);

    function getMinipoolAt(uint256 _index) external view returns (address);

    function getNodeMinipoolCount(address _nodeAddress) external view returns (uint256);

    function getNodeActiveMinipoolCount(address _nodeAddress) external view returns (uint256);

    function getNodeFinalisedMinipoolCount(address _nodeAddress) external view returns (uint256);

    function getNodeStakingMinipoolCount(address _nodeAddress) external view returns (uint256);

    function getNodeMinipoolAt(address _nodeAddress, uint256 _index) external view returns (address);

    function getNodeValidatingMinipoolCount(address _nodeAddress) external view returns (uint256);

    function getNodeValidatingMinipoolAt(address _nodeAddress, uint256 _index) external view returns (address);

    function getMinipoolByPubkey(bytes calldata _pubkey) external view returns (address);

    function getMinipoolExists(address _minipoolAddress) external view returns (bool);

    function getMinipoolDestroyed(address _minipoolAddress) external view returns (bool);

    function getMinipoolPubkey(address _minipoolAddress) external view returns (bytes memory);

    function getMinipoolWithdrawalCredentials(address _minipoolAddress) external pure returns (bytes memory);

    function createMinipool(address _nodeAddress, MinipoolDeposit _depositType, uint256 _salt) external returns (RocketMinipoolInterface);

    function destroyMinipool() external;

    function incrementNodeStakingMinipoolCount(address _nodeAddress) external;

    function decrementNodeStakingMinipoolCount(address _nodeAddress) external;

    function incrementNodeFinalisedMinipoolCount(address _nodeAddress) external;

    function setMinipoolPubkey(bytes calldata _pubkey) external;

    function getMinipoolBytecode() external pure returns (bytes memory);

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



interface RocketMinipoolQueueInterface {

    function getTotalLength() external view returns (uint256);

    function getLength(MinipoolDeposit _depositType) external view returns (uint256);

    function getTotalCapacity() external view returns (uint256);

    function getEffectiveCapacity() external view returns (uint256);

    function getNextCapacity() external view returns (uint256);

    function getNextDeposit() external view returns (MinipoolDeposit, uint256);

    function enqueueMinipool(MinipoolDeposit _depositType, address _minipool) external;

    function dequeueMinipool() external returns (address minipoolAddress);

    function dequeueMinipoolByDeposit(MinipoolDeposit _depositType) external returns (address minipoolAddress);

    function removeMinipool(MinipoolDeposit _depositType) external;

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


interface AddressSetStorageInterface {

    function getCount(bytes32 _key) external view returns (uint);

    function getItem(bytes32 _key, uint _index) external view returns (address);

    function getIndexOf(bytes32 _key, address _value) external view returns (int);

    function addItem(bytes32 _key, address _value) external;

    function removeItem(bytes32 _key, address _value) external;

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


interface RocketNetworkPricesInterface {

    function getPricesBlock() external view returns (uint256);

    function getRPLPrice() external view returns (uint256);

    function getEffectiveRPLStake() external view returns (uint256);

    function getEffectiveRPLStakeUpdatedBlock() external view returns (uint256);

    function getLatestReportableBlock() external view returns (uint256);

    function inConsensus() external view returns (bool);

    function submitPrices(uint256 _block, uint256 _rplPrice, uint256 _effectiveRplStake) external;

    function executeUpdatePrices(uint256 _block, uint256 _rplPrice, uint256 _effectiveRplStake) external;

    function increaseEffectiveRPLStake(uint256 _amount) external;

    function decreaseEffectiveRPLStake(uint256 _amount) external;

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



interface RocketDAOProtocolSettingsMinipoolInterface {

    function getLaunchBalance() external view returns (uint256);

    function getDepositNodeAmount(MinipoolDeposit _depositType) external view returns (uint256);

    function getFullDepositNodeAmount() external view returns (uint256);

    function getHalfDepositNodeAmount() external view returns (uint256);

    function getEmptyDepositNodeAmount() external view returns (uint256);

    function getDepositUserAmount(MinipoolDeposit _depositType) external view returns (uint256);

    function getFullDepositUserAmount() external view returns (uint256);

    function getHalfDepositUserAmount() external view returns (uint256);

    function getEmptyDepositUserAmount() external view returns (uint256);

    function getSubmitWithdrawableEnabled() external view returns (bool);

    function getLaunchTimeout() external view returns (uint256);

    function getMaximumCount() external view returns (uint256);

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


interface RocketDAOProtocolSettingsNodeInterface {

    function getRegistrationEnabled() external view returns (bool);

    function getDepositEnabled() external view returns (bool);

    function getMinimumPerMinipoolStake() external view returns (uint256);

    function getMaximumPerMinipoolStake() external view returns (uint256);

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





contract RocketMinipoolManager is RocketBase, RocketMinipoolManagerInterface {


    using SafeMath for uint;

    event MinipoolCreated(address indexed minipool, address indexed node, uint256 time);
    event MinipoolDestroyed(address indexed minipool, address indexed node, uint256 time);

    constructor(RocketStorageInterface _rocketStorageAddress) RocketBase(_rocketStorageAddress) {
        version = 1;
    }

    function getMinipoolCount() override public view returns (uint256) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        return addressSetStorage.getCount(keccak256(bytes("minipools.index")));
    }

    function getStakingMinipoolCount() override external view returns (uint256) {

        return getUint(keccak256(bytes("minipools.staking.count")));
    }

    function getFinalisedMinipoolCount() override external view returns (uint256) {

        return getUint(keccak256(bytes("minipools.finalised.count")));
    }

    function getActiveMinipoolCount() override public view returns (uint256) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        uint256 total = addressSetStorage.getCount(keccak256(bytes("minipools.index")));
        uint256 finalised = getUint(keccak256(bytes("minipools.finalised.count")));
        return total.sub(finalised);
    }

    function getMinipoolCountPerStatus(uint256 offset, uint256 limit) override external view 
    returns (uint256 initialisedCount, uint256 prelaunchCount, uint256 stakingCount, uint256 withdrawableCount, uint256 dissolvedCount) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        bytes32 minipoolKey = keccak256(abi.encodePacked("minipools.index"));
        uint256 totalMinipools = getMinipoolCount();
        uint256 max = offset.add(limit);
        if (max > totalMinipools || limit == 0) { max = totalMinipools; }
        for (uint256 i = offset; i < max; i++) {
            RocketMinipoolInterface minipool = RocketMinipoolInterface(addressSetStorage.getItem(minipoolKey, i));
            MinipoolStatus status = minipool.getStatus();
            if (status == MinipoolStatus.Initialised) {
                initialisedCount++;
            }
            else if (status == MinipoolStatus.Prelaunch) {
                prelaunchCount++;
            }
            else if (status == MinipoolStatus.Staking) {
                stakingCount++;
            }
            else if (status == MinipoolStatus.Withdrawable) {
                withdrawableCount++;
            }
            else if (status == MinipoolStatus.Dissolved) {
                dissolvedCount++;
            }
        }
    }

    function getPrelaunchMinipools(uint256 offset, uint256 limit) override external view
    returns (address[] memory) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        bytes32 minipoolKey = keccak256(abi.encodePacked("minipools.index"));
        uint256 totalMinipools = getMinipoolCount();
        uint256 max = offset.add(limit);
        if (max > totalMinipools || limit == 0) { max = totalMinipools; }
        address[] memory minipools = new address[](max.sub(offset));
        uint256 total = 0;
        for (uint256 i = offset; i < max; i++) {
            RocketMinipoolInterface minipool = RocketMinipoolInterface(addressSetStorage.getItem(minipoolKey, i));
            MinipoolStatus status = minipool.getStatus();
            if (status == MinipoolStatus.Prelaunch) {
                minipools[total] = address(minipool);
                total++;
            }
        }
        assembly {
            mstore(minipools, total)
        }
        return minipools;
    }

    function getMinipoolAt(uint256 _index) override external view returns (address) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        return addressSetStorage.getItem(keccak256(abi.encodePacked("minipools.index")), _index);
    }

    function getNodeMinipoolCount(address _nodeAddress) override external view returns (uint256) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        return addressSetStorage.getCount(keccak256(abi.encodePacked("node.minipools.index", _nodeAddress)));
    }

    function getNodeActiveMinipoolCount(address _nodeAddress) override public view returns (uint256) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        uint256 finalised = getUint(keccak256(abi.encodePacked("node.minipools.finalised.count", _nodeAddress)));
        uint256 total = addressSetStorage.getCount(keccak256(abi.encodePacked("node.minipools.index", _nodeAddress)));
        return total.sub(finalised);
    }

    function getNodeFinalisedMinipoolCount(address _nodeAddress) override external view returns (uint256) {

        return getUint(keccak256(abi.encodePacked("node.minipools.finalised.count", _nodeAddress)));
    }

    function getNodeStakingMinipoolCount(address _nodeAddress) override external view returns (uint256) {

        return getUint(keccak256(abi.encodePacked("node.minipools.staking.count", _nodeAddress)));
    }

    function getNodeMinipoolAt(address _nodeAddress, uint256 _index) override external view returns (address) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        return addressSetStorage.getItem(keccak256(abi.encodePacked("node.minipools.index", _nodeAddress)), _index);
    }

    function getNodeValidatingMinipoolCount(address _nodeAddress) override external view returns (uint256) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        return addressSetStorage.getCount(keccak256(abi.encodePacked("node.minipools.validating.index", _nodeAddress)));
    }

    function getNodeValidatingMinipoolAt(address _nodeAddress, uint256 _index) override external view returns (address) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        return addressSetStorage.getItem(keccak256(abi.encodePacked("node.minipools.validating.index", _nodeAddress)), _index);
    }

    function getMinipoolByPubkey(bytes memory _pubkey) override external view returns (address) {

        return getAddress(keccak256(abi.encodePacked("validator.minipool", _pubkey)));
    }

    function getMinipoolExists(address _minipoolAddress) override external view returns (bool) {

        return getBool(keccak256(abi.encodePacked("minipool.exists", _minipoolAddress)));
    }

    function getMinipoolDestroyed(address _minipoolAddress) override external view returns (bool) {

        return getBool(keccak256(abi.encodePacked("minipool.destroyed", _minipoolAddress)));
    }

    function getMinipoolPubkey(address _minipoolAddress) override public view returns (bytes memory) {

        return getBytes(keccak256(abi.encodePacked("minipool.pubkey", _minipoolAddress)));
    }

    function getMinipoolWithdrawalCredentials(address _minipoolAddress) override public pure returns (bytes memory) {

        return abi.encodePacked(byte(0x01), bytes11(0x0), address(_minipoolAddress));
    }

    function incrementNodeStakingMinipoolCount(address _nodeAddress) override external onlyLatestContract("rocketMinipoolManager", address(this)) onlyRegisteredMinipool(msg.sender) {

        bytes32 nodeKey = keccak256(abi.encodePacked("node.minipools.staking.count", _nodeAddress));
        uint256 nodeValue = getUint(nodeKey);
        setUint(nodeKey, nodeValue.add(1));
        bytes32 totalKey = keccak256(abi.encodePacked("minipools.staking.count"));
        uint256 totalValue = getUint(totalKey);
        setUint(totalKey, totalValue.add(1));
        updateTotalEffectiveRPLStake(_nodeAddress, nodeValue, nodeValue.add(1));
    }

    function decrementNodeStakingMinipoolCount(address _nodeAddress) override external onlyLatestContract("rocketMinipoolManager", address(this)) onlyRegisteredMinipool(msg.sender) {

        bytes32 nodeKey = keccak256(abi.encodePacked("node.minipools.staking.count", _nodeAddress));
        uint256 nodeValue = getUint(nodeKey);
        setUint(nodeKey, nodeValue.sub(1));
        bytes32 totalKey = keccak256(abi.encodePacked("minipools.staking.count"));
        uint256 totalValue = getUint(totalKey);
        setUint(totalKey, totalValue.sub(1));
        updateTotalEffectiveRPLStake(_nodeAddress, nodeValue, nodeValue.sub(1));
    }

    function incrementNodeFinalisedMinipoolCount(address _nodeAddress) override external onlyLatestContract("rocketMinipoolManager", address(this)) onlyRegisteredMinipool(msg.sender) {

        addUint(keccak256(abi.encodePacked("node.minipools.finalised.count", _nodeAddress)), 1);
        addUint(keccak256(bytes("minipools.finalised.count")), 1);
    }

    function createMinipool(address _nodeAddress, MinipoolDeposit _depositType, uint256 _salt) override external onlyLatestContract("rocketMinipoolManager", address(this)) onlyLatestContract("rocketNodeDeposit", msg.sender) returns (RocketMinipoolInterface) {

        RocketNodeStakingInterface rocketNodeStaking = RocketNodeStakingInterface(getContractAddress("rocketNodeStaking"));
        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        require(
            getNodeActiveMinipoolCount(_nodeAddress) < rocketNodeStaking.getNodeMinipoolLimit(_nodeAddress),
            "Minipool count after deposit exceeds limit based on node RPL stake"
        );
        { // Local scope to prevent stack too deep error
          RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
          uint256 totalMinipoolCount = getActiveMinipoolCount();
          require(totalMinipoolCount.add(1) <= rocketDAOProtocolSettingsMinipool.getMaximumCount(), "Global minipool limit reached");
        }
        address contractAddress = deployContract(address(rocketStorage), _nodeAddress, _depositType, _salt);
        setBool(keccak256(abi.encodePacked("minipool.exists", contractAddress)), true);
        addressSetStorage.addItem(keccak256(abi.encodePacked("minipools.index")), contractAddress);
        addressSetStorage.addItem(keccak256(abi.encodePacked("node.minipools.index", _nodeAddress)), contractAddress);
        if (_depositType == MinipoolDeposit.Empty) {
            RocketDAONodeTrustedInterface rocketDAONodeTrusted = RocketDAONodeTrustedInterface(getContractAddress("rocketDAONodeTrusted"));
            rocketDAONodeTrusted.incrementMemberUnbondedValidatorCount(_nodeAddress);
        }
        emit MinipoolCreated(contractAddress, _nodeAddress, block.timestamp);
        RocketMinipoolQueueInterface(getContractAddress("rocketMinipoolQueue")).enqueueMinipool(_depositType, contractAddress);
        return RocketMinipoolInterface(contractAddress);
    }

    function destroyMinipool() override external onlyLatestContract("rocketMinipoolManager", address(this)) onlyRegisteredMinipool(msg.sender) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        RocketMinipoolInterface minipool = RocketMinipoolInterface(msg.sender);
        address nodeAddress = minipool.getNodeAddress();
        setBool(keccak256(abi.encodePacked("minipool.exists", msg.sender)), false);
        setBool(keccak256(abi.encodePacked("minipool.destroyed", msg.sender)), true);
        addressSetStorage.removeItem(keccak256(abi.encodePacked("minipools.index")), msg.sender);
        addressSetStorage.removeItem(keccak256(abi.encodePacked("node.minipools.index", nodeAddress)), msg.sender);
        bytes memory pubkey = getMinipoolPubkey(msg.sender);
        deleteBytes(keccak256(abi.encodePacked("minipool.pubkey", msg.sender)));
        deleteAddress(keccak256(abi.encodePacked("validator.minipool", pubkey)));
        emit MinipoolDestroyed(msg.sender, nodeAddress, block.timestamp);
    }

    function updateTotalEffectiveRPLStake(address _nodeAddress, uint256 _oldCount, uint256 _newCount) private {

        RocketNetworkPricesInterface rocketNetworkPrices = RocketNetworkPricesInterface(getContractAddress("rocketNetworkPrices"));
        RocketDAOProtocolSettingsMinipoolInterface rocketDAOProtocolSettingsMinipool = RocketDAOProtocolSettingsMinipoolInterface(getContractAddress("rocketDAOProtocolSettingsMinipool"));
        RocketDAOProtocolSettingsNodeInterface rocketDAOProtocolSettingsNode = RocketDAOProtocolSettingsNodeInterface(getContractAddress("rocketDAOProtocolSettingsNode"));
        RocketNodeStakingInterface rocketNodeStaking = RocketNodeStakingInterface(getContractAddress("rocketNodeStaking"));
        require(rocketNetworkPrices.inConsensus(), "Network is not in consensus");
        uint256 rplStake = rocketNodeStaking.getNodeRPLStake(_nodeAddress);
        uint256 maxRplStakePerMinipool = rocketDAOProtocolSettingsMinipool.getHalfDepositUserAmount()
            .mul(rocketDAOProtocolSettingsNode.getMaximumPerMinipoolStake());
        uint256 oldMaxRplStake = maxRplStakePerMinipool
            .mul(_oldCount)
            .div(rocketNetworkPrices.getRPLPrice());
        uint256 newMaxRplStake = maxRplStakePerMinipool
            .mul(_newCount)
            .div(rocketNetworkPrices.getRPLPrice());
        if (_oldCount > _newCount) {
            if (rplStake <= newMaxRplStake) {
                return;
            }
            uint256 decrease = oldMaxRplStake.sub(newMaxRplStake);
            uint256 delta = rplStake.sub(newMaxRplStake);
            if (delta > decrease) { delta = decrease; }
            rocketNetworkPrices.decreaseEffectiveRPLStake(delta);
            return;
        }
        if (_newCount > _oldCount) {
            if (rplStake <= oldMaxRplStake) {
                return;
            }
            uint256 increase = newMaxRplStake.sub(oldMaxRplStake);
            uint256 delta = rplStake.sub(oldMaxRplStake);
            if (delta > increase) { delta = increase; }
            rocketNetworkPrices.increaseEffectiveRPLStake(delta);
            return;
        }
    }

    function setMinipoolPubkey(bytes calldata _pubkey) override external onlyLatestContract("rocketMinipoolManager", address(this)) onlyRegisteredMinipool(msg.sender) {

        AddressSetStorageInterface addressSetStorage = AddressSetStorageInterface(getContractAddress("addressSetStorage"));
        RocketMinipoolInterface minipool = RocketMinipoolInterface(msg.sender);
        address nodeAddress = minipool.getNodeAddress();
        setBytes(keccak256(abi.encodePacked("minipool.pubkey", msg.sender)), _pubkey);
        setAddress(keccak256(abi.encodePacked("validator.minipool", _pubkey)), msg.sender);
        addressSetStorage.addItem(keccak256(abi.encodePacked("node.minipools.validating.index", nodeAddress)), msg.sender);
    }

    function getMinipoolBytecode() override public pure returns (bytes memory) {

        return type(RocketMinipool).creationCode;
    }

    function deployContract(address rocketStorage, address _nodeAddress, MinipoolDeposit _depositType, uint256 _salt) private returns (address) {

        bytes memory creationCode = getMinipoolBytecode();
        bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(rocketStorage, _nodeAddress, _depositType));
        uint256 salt = uint256(keccak256(abi.encodePacked(_nodeAddress, _salt)));
        address contractAddress;
        uint256 codeSize;
        assembly {
            contractAddress := create2(
            0,
            add(bytecode, 0x20),
            mload(bytecode),
            salt
            )

            codeSize := extcodesize(contractAddress)
        }
        require(codeSize > 0, "Contract creation failed");
        return contractAddress;
    }

}