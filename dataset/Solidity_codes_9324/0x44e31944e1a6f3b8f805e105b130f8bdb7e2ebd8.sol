
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


interface AddressQueueStorageInterface {

    function getLength(bytes32 _key) external view returns (uint);

    function getItem(bytes32 _key, uint _index) external view returns (address);

    function getIndexOf(bytes32 _key, address _value) external view returns (int);

    function enqueueItem(bytes32 _key, address _value) external;

    function dequeueItem(bytes32 _key) external returns (address);

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






contract AddressQueueStorage is RocketBase, AddressQueueStorageInterface {


    using SafeMath for uint256;

    uint256 constant public capacity = 2 ** 255; // max uint256 / 2

    constructor(RocketStorageInterface _rocketStorageAddress) RocketBase(_rocketStorageAddress) {
        version = 1;
    }

    function getLength(bytes32 _key) override public view returns (uint) {

        uint start = getUint(keccak256(abi.encodePacked(_key, ".start")));
        uint end = getUint(keccak256(abi.encodePacked(_key, ".end")));
        if (end < start) { end = end.add(capacity); }
        return end.sub(start);
    }

    function getItem(bytes32 _key, uint _index) override external view returns (address) {

        uint index = getUint(keccak256(abi.encodePacked(_key, ".start"))).add(_index);
        if (index >= capacity) { index = index.sub(capacity); }
        return getAddress(keccak256(abi.encodePacked(_key, ".item", index)));
    }

    function getIndexOf(bytes32 _key, address _value) override external view returns (int) {

        int index = int(getUint(keccak256(abi.encodePacked(_key, ".index", _value)))) - 1;
        if (index != -1) {
            index -= int(getUint(keccak256(abi.encodePacked(_key, ".start"))));
            if (index < 0) { index += int(capacity); }
        }
        return index;
    }

    function enqueueItem(bytes32 _key, address _value) override external onlyLatestContract("addressQueueStorage", address(this)) onlyLatestNetworkContract {

        require(getLength(_key) < capacity.sub(1), "Queue is at capacity");
        require(getUint(keccak256(abi.encodePacked(_key, ".index", _value))) == 0, "Item already exists in queue");
        uint index = getUint(keccak256(abi.encodePacked(_key, ".end")));
        setAddress(keccak256(abi.encodePacked(_key, ".item", index)), _value);
        setUint(keccak256(abi.encodePacked(_key, ".index", _value)), index.add(1));
        index = index.add(1);
        if (index >= capacity) { index = index.sub(capacity); }
        setUint(keccak256(abi.encodePacked(_key, ".end")), index);
    }

    function dequeueItem(bytes32 _key) override external onlyLatestContract("addressQueueStorage", address(this)) onlyLatestNetworkContract returns (address) {

        require(getLength(_key) > 0, "Queue is empty");
        uint start = getUint(keccak256(abi.encodePacked(_key, ".start")));
        address item = getAddress(keccak256(abi.encodePacked(_key, ".item", start)));
        start = start.add(1);
        if (start >= capacity) { start = start.sub(capacity); }
        setUint(keccak256(abi.encodePacked(_key, ".index", item)), 0);
        setUint(keccak256(abi.encodePacked(_key, ".start")), start);
        return item;
    }

    function removeItem(bytes32 _key, address _value) override external onlyLatestContract("addressQueueStorage", address(this)) onlyLatestNetworkContract {

        uint index = getUint(keccak256(abi.encodePacked(_key, ".index", _value)));
        require(index-- > 0, "Item does not exist in queue");
        uint lastIndex = getUint(keccak256(abi.encodePacked(_key, ".end")));
        if (lastIndex == 0) lastIndex = capacity;
        lastIndex = lastIndex.sub(1);
        if (index != lastIndex) {
            address lastItem = getAddress(keccak256(abi.encodePacked(_key, ".item", lastIndex)));
            setAddress(keccak256(abi.encodePacked(_key, ".item", index)), lastItem);
            setUint(keccak256(abi.encodePacked(_key, ".index", lastItem)), index.add(1));
        }
        setUint(keccak256(abi.encodePacked(_key, ".index", _value)), 0);
        setUint(keccak256(abi.encodePacked(_key, ".end")), lastIndex);
    }

}