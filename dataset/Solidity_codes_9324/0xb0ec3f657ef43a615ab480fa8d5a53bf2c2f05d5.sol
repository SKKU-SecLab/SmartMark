
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


interface RocketDAONodeTrustedProposalsInterface {

    function propose(string memory _proposalMessage, bytes memory _payload) external returns (uint256);

    function vote(uint256 _proposalID, bool _support) external;

    function cancel(uint256 _proposalID) external;

    function execute(uint256 _proposalID) external;

    function proposalInvite(string memory _id, string memory _url, address _nodeAddress) external;

    function proposalLeave(address _nodeAddress) external;

    function proposalKick(address _nodeAddress, uint256 _rplFine) external;

    function proposalSettingUint(string memory _settingContractName, string memory _settingPath, uint256 _value) external;

    function proposalSettingBool(string memory _settingContractName, string memory _settingPath, bool _value) external;

    function proposalUpgrade(string memory _type, string memory _name, string memory _contractAbi, address _contractAddress) external;

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


interface RocketDAONodeTrustedActionsInterface {

    function actionJoin() external;

    function actionJoinRequired(address _nodeAddress) external;

    function actionLeave(address _rplBondRefundAddress) external;

    function actionKick(address _nodeAddress, uint256 _rplFine) external;

    function actionChallengeMake(address _nodeAddress) external payable;

    function actionChallengeDecide(address _nodeAddress) external;

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


interface RocketDAONodeTrustedUpgradeInterface {

    function upgrade(string memory _type, string memory _name, string memory _contractAbi, address _contractAddress) external;

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


interface RocketDAONodeTrustedSettingsInterface {

    function getSettingUint(string memory _settingPath) external view returns (uint256);

    function setSettingUint(string memory _settingPath, uint256 _value) external;

    function getSettingBool(string memory _settingPath) external view returns (bool);

    function setSettingBool(string memory _settingPath, bool _value) external;

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


interface RocketDAONodeTrustedSettingsProposalsInterface {

    function getCooldownTime() external view returns(uint256);

    function getVoteTime() external view returns(uint256);

    function getVoteDelayTime() external view returns(uint256);

    function getExecuteTime() external view returns(uint256);

    function getActionTime() external view returns(uint256);

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


interface RocketDAOProposalInterface {


    enum ProposalState {
        Pending,
        Active,
        Cancelled,
        Defeated,
        Succeeded,
        Expired,
        Executed
    }

    function getTotal() external view returns (uint256);

    function getDAO(uint256 _proposalID) external view returns (string memory);

    function getProposer(uint256 _proposalID) external view returns (address);

    function getMessage(uint256 _proposalID) external view returns (string memory);

    function getStart(uint256 _proposalID) external view returns (uint256);

    function getEnd(uint256 _proposalID) external view returns (uint256);

    function getExpires(uint256 _proposalID) external view returns (uint256);

    function getCreated(uint256 _proposalID) external view returns (uint256);

    function getVotesFor(uint256 _proposalID) external view returns (uint256);

    function getVotesAgainst(uint256 _proposalID) external view returns (uint256);

    function getVotesRequired(uint256 _proposalID) external view returns (uint256);

    function getCancelled(uint256 _proposalID) external view returns (bool);

    function getExecuted(uint256 _proposalID) external view returns (bool);

    function getPayload(uint256 _proposalID) external view returns (bytes memory);

    function getReceiptHasVoted(uint256 _proposalID, address _nodeAddress) external view returns (bool);

    function getReceiptSupported(uint256 _proposalID, address _nodeAddress) external view returns (bool);

    function getState(uint256 _proposalID) external view returns (ProposalState);

    function add(address _member, string memory _dao, string memory _message, uint256 _startBlock, uint256 _durationBlocks, uint256 _expiresBlocks, uint256 _votesRequired, bytes memory _payload) external returns (uint256);

    function vote(address _member, uint256 _votes, uint256 _proposalID, bool _support) external; 

    function cancel(address _member, uint256 _proposalID) external;

    function execute(uint256 _proposalID) external;

    
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





contract RocketDAONodeTrustedProposals is RocketBase, RocketDAONodeTrustedProposalsInterface {  


    using SafeMath for uint;

    string constant daoNameSpace = "dao.trustednodes.";

    modifier onlyExecutingContracts() {

        require(msg.sender == getContractAddress("rocketDAONodeTrusted") || msg.sender == getContractAddress("rocketDAOProposal"), "Sender is not permitted to access executing methods");
        _;
    }

    constructor(RocketStorageInterface _rocketStorageAddress) RocketBase(_rocketStorageAddress) {
        version = 1;
    }

        

    function propose(string memory _proposalMessage, bytes memory _payload) override external onlyTrustedNode(msg.sender) onlyLatestContract("rocketDAONodeTrustedProposals", address(this)) returns (uint256) {

        RocketDAOProposalInterface daoProposal = RocketDAOProposalInterface(getContractAddress("rocketDAOProposal"));
        RocketDAONodeTrustedInterface daoNodeTrusted = RocketDAONodeTrustedInterface(getContractAddress("rocketDAONodeTrusted"));
        RocketDAONodeTrustedSettingsProposalsInterface rocketDAONodeTrustedSettingsProposals = RocketDAONodeTrustedSettingsProposalsInterface(getContractAddress("rocketDAONodeTrustedSettingsProposals"));
        require(daoNodeTrusted.getMemberLastProposalTime(msg.sender).add(rocketDAONodeTrustedSettingsProposals.getCooldownTime()) <= block.timestamp, "Member has not waited long enough to make another proposal");
        require(daoNodeTrusted.getMemberCount() >= daoNodeTrusted.getMemberMinRequired(), "Min member count not met to allow proposals to be added");
        setUint(keccak256(abi.encodePacked(daoNameSpace, "member.proposal.lasttime", msg.sender)), block.timestamp);
        return daoProposal.add(msg.sender, "rocketDAONodeTrustedProposals", _proposalMessage, block.timestamp.add(rocketDAONodeTrustedSettingsProposals.getVoteDelayTime()), rocketDAONodeTrustedSettingsProposals.getVoteTime(), rocketDAONodeTrustedSettingsProposals.getExecuteTime(), daoNodeTrusted.getMemberQuorumVotesRequired(), _payload);
    }

    function vote(uint256 _proposalID, bool _support) override external onlyTrustedNode(msg.sender) onlyLatestContract("rocketDAONodeTrustedProposals", address(this)) {

        RocketDAOProposalInterface daoProposal = RocketDAOProposalInterface(getContractAddress("rocketDAOProposal"));
        RocketDAONodeTrustedInterface daoNodeTrusted = RocketDAONodeTrustedInterface(getContractAddress("rocketDAONodeTrusted"));
        require(daoNodeTrusted.getMemberJoinedTime(msg.sender) < daoProposal.getCreated(_proposalID), "Member cannot vote on proposal created before they became a member");
        daoProposal.vote(msg.sender, 1 ether, _proposalID, _support);
    }
    
    function cancel(uint256 _proposalID) override external onlyTrustedNode(msg.sender) onlyLatestContract("rocketDAONodeTrustedProposals", address(this)) {

        RocketDAOProposalInterface daoProposal = RocketDAOProposalInterface(getContractAddress("rocketDAOProposal"));
        daoProposal.cancel(msg.sender, _proposalID);
    }

    function execute(uint256 _proposalID) override external onlyLatestContract("rocketDAONodeTrustedProposals", address(this)) {

        RocketDAOProposalInterface daoProposal = RocketDAOProposalInterface(getContractAddress("rocketDAOProposal"));
        daoProposal.execute(_proposalID);
    }




    function proposalInvite(string memory _id, string memory _url, address _nodeAddress) override external onlyExecutingContracts onlyRegisteredNode(_nodeAddress) {

        setUint(keccak256(abi.encodePacked(daoNameSpace, "member.executed.time", "invited", _nodeAddress)), block.timestamp);
        _memberInit(_id, _url, _nodeAddress);
    }


    function proposalLeave(address _nodeAddress) override external onlyExecutingContracts onlyTrustedNode(_nodeAddress) {

        RocketDAONodeTrustedInterface daoNodeTrusted = RocketDAONodeTrustedInterface(getContractAddress("rocketDAONodeTrusted"));
        require(daoNodeTrusted.getMemberCount() > daoNodeTrusted.getMemberMinRequired(), "Member count will fall below min required");
        setUint(keccak256(abi.encodePacked(daoNameSpace, "member.executed.time", "leave", _nodeAddress)), block.timestamp);
    }


    function proposalKick(address _nodeAddress, uint256 _rplFine) override external onlyExecutingContracts onlyTrustedNode(_nodeAddress) {

        RocketDAONodeTrustedInterface daoNodeTrusted = RocketDAONodeTrustedInterface(getContractAddress("rocketDAONodeTrusted"));
        RocketDAONodeTrustedActionsInterface daoActionsContract = RocketDAONodeTrustedActionsInterface(getContractAddress("rocketDAONodeTrustedActions"));
        uint256 rplBondAmount = daoNodeTrusted.getMemberRPLBondAmount(_nodeAddress);
        require(_rplFine <= rplBondAmount, "RPL Fine must be lower or equal to the RPL bond amount of the node being kicked");
        setUint(keccak256(abi.encodePacked(daoNameSpace, "member.bond.rpl", _nodeAddress)), rplBondAmount.sub(_rplFine));
        daoActionsContract.actionKick(_nodeAddress, _rplFine);
    }



    function proposalSettingUint(string memory _settingContractName, string memory _settingPath, uint256 _value) override external onlyExecutingContracts() {

        RocketDAONodeTrustedSettingsInterface rocketDAONodeTrustedSettings = RocketDAONodeTrustedSettingsInterface(getContractAddress(_settingContractName));
        rocketDAONodeTrustedSettings.setSettingUint(_settingPath, _value);
    }

    function proposalSettingBool(string memory _settingContractName, string memory _settingPath, bool _value) override external onlyExecutingContracts() {

        RocketDAONodeTrustedSettingsInterface rocketDAONodeTrustedSettings = RocketDAONodeTrustedSettingsInterface(getContractAddress(_settingContractName));
        rocketDAONodeTrustedSettings.setSettingBool(_settingPath, _value);
    }



    function proposalUpgrade(string memory _type, string memory _name, string memory _contractAbi, address _contractAddress) override external onlyExecutingContracts() {

        RocketDAONodeTrustedUpgradeInterface rocketDAONodeTrustedUpgradeInterface = RocketDAONodeTrustedUpgradeInterface(getContractAddress("rocketDAONodeTrustedUpgrade"));
        rocketDAONodeTrustedUpgradeInterface.upgrade(_type, _name, _contractAbi, _contractAddress);
    }



    function _memberInit(string memory _id, string memory _url, address _nodeAddress) private onlyRegisteredNode(_nodeAddress) {

        RocketDAONodeTrustedInterface daoNodeTrusted = RocketDAONodeTrustedInterface(getContractAddress("rocketDAONodeTrusted"));
        require(!daoNodeTrusted.getMemberIsValid(_nodeAddress), "This node is already part of the trusted node DAO");
        require(bytes(_id).length >= 3, "The ID for this new member must be at least 3 characters");
        require(bytes(_url).length >= 6, "The URL for this new member must be at least 6 characters");
        setBool(keccak256(abi.encodePacked(daoNameSpace, "member", _nodeAddress)), false);
        setAddress(keccak256(abi.encodePacked(daoNameSpace, "member.address", _nodeAddress)), _nodeAddress);
        setString(keccak256(abi.encodePacked(daoNameSpace, "member.id", _nodeAddress)), _id);
        setString(keccak256(abi.encodePacked(daoNameSpace, "member.url", _nodeAddress)), _url);
        setUint(keccak256(abi.encodePacked(daoNameSpace, "member.bond.rpl", _nodeAddress)), 0);
        setUint(keccak256(abi.encodePacked(daoNameSpace, "member.joined.time", _nodeAddress)), 0);
    }
        

}