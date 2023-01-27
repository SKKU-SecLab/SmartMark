
pragma solidity ^0.4.24;

interface IModuleRegistry {


    function useModule(address _moduleFactory) external;


    function registerModule(address _moduleFactory) external;


    function removeModule(address _moduleFactory) external;


    function verifyModule(address _moduleFactory, bool _verified) external;


    function getReputationByFactory(address _factoryAddress) external view returns(address[]);


    function getTagsByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns(bytes32[], address[]);


    function getTagsByType(uint8 _moduleType) external view returns(bytes32[], address[]);


    function getModulesByType(uint8 _moduleType) external view returns(address[]);


    function getModulesByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns (address[]);


    function updateFromRegistry() external;


    function owner() external view returns(address);


    function isPaused() external view returns(bool);


}

interface IModuleFactory {


    event ChangeFactorySetupFee(uint256 _oldSetupCost, uint256 _newSetupCost, address _moduleFactory);
    event ChangeFactoryUsageFee(uint256 _oldUsageCost, uint256 _newUsageCost, address _moduleFactory);
    event ChangeFactorySubscriptionFee(uint256 _oldSubscriptionCost, uint256 _newMonthlySubscriptionCost, address _moduleFactory);
    event GenerateModuleFromFactory(
        address _module,
        bytes32 indexed _moduleName,
        address indexed _moduleFactory,
        address _creator,
        uint256 _setupCost,
        uint256 _timestamp
    );
    event ChangeSTVersionBound(string _boundType, uint8 _major, uint8 _minor, uint8 _patch);

    function deploy(bytes _data) external returns(address);


    function getTypes() external view returns(uint8[]);


    function getName() external view returns(bytes32);


    function getInstructions() external view returns (string);


    function getTags() external view returns (bytes32[]);


    function changeFactorySetupFee(uint256 _newSetupCost) external;


    function changeFactoryUsageFee(uint256 _newUsageCost) external;


    function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) external;


    function changeSTVersionBounds(string _boundType, uint8[] _newVersion) external;


    function getSetupCost() external view returns (uint256);


    function getLowerSTVersionBounds() external view returns(uint8[]);


    function getUpperSTVersionBounds() external view returns(uint8[]);


}

interface ISecurityTokenRegistry {


    function generateSecurityToken(string _name, string _ticker, string _tokenDetails, bool _divisible) external;


    function modifySecurityToken(
        string _name,
        string _ticker,
        address _owner,
        address _securityToken,
        string _tokenDetails,
        uint256 _deployedAt
    )
        external;


    function registerTicker(address _owner, string _ticker, string _tokenName) external;


    function setProtocolVersion(address _STFactoryAddress, uint8 _major, uint8 _minor, uint8 _patch) external;


    function isSecurityToken(address _securityToken) external view returns (bool);


    function transferOwnership(address _newOwner) external;


    function getSecurityTokenAddress(string _ticker) external view returns (address);


    function getSecurityTokenData(address _securityToken) external view returns (string, address, string, uint256);


    function getSTFactoryAddress() external view returns(address);


    function getProtocolVersion() external view returns(uint8[]);


    function getTickersByOwner(address _owner) external view returns(bytes32[]);


    function getTokensByOwner(address _owner) external view returns(address[]);


    function getTickerDetails(string _ticker) external view returns (address, uint256, uint256, string, bool);


    function modifyTicker(
        address _owner,
        string _ticker,
        string _tokenName,
        uint256 _registrationDate,
        uint256 _expiryDate,
        bool _status
    )
        external;


    function removeTicker(string _ticker) external;


    function transferTickerOwnership(address _newOwner, string _ticker) external;


    function changeExpiryLimit(uint256 _newExpiry) external;


   function changeTickerRegistrationFee(uint256 _tickerRegFee) external;


   function changeSecurityLaunchFee(uint256 _stLaunchFee) external;


    function updatePolyTokenAddress(address _newAddress) external;


    function getSecurityTokenLaunchFee() external view returns(uint256);


    function getTickerRegistrationFee() external view returns(uint256);


    function getExpiryLimit() external view returns(uint256);


    function isPaused() external view returns(bool);


    function owner() external view returns(address);


}

interface IPolymathRegistry {


    function getAddress(string _nameKey) external view returns(address);


}

interface IFeatureRegistry {


    function getFeatureStatus(string _nameKey) external view returns(bool);


}

interface IERC20 {

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);

    function increaseApproval(address _spender, uint _addedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library VersionUtils {


    function isValidVersion(uint8[] _current, uint8[] _new) internal pure returns(bool) {

        bool[] memory _temp = new bool[](_current.length);
        uint8 counter = 0;
        for (uint8 i = 0; i < _current.length; i++) {
            if (_current[i] < _new[i])
                _temp[i] = true;
            else
                _temp[i] = false;
        }

        for (i = 0; i < _current.length; i++) {
            if (i == 0) {
                if (_current[i] <= _new[i])
                    if(_temp[0]) {
                        counter = counter + 3;
                        break;
                    } else
                        counter++;
                else
                    return false;
            } else {
                if (_temp[i-1])
                    counter++;
                else if (_current[i] <= _new[i])
                    counter++;
                else
                    return false;
            }
        }
        if (counter == _current.length)
            return true;
    }

    function compareLowerBound(uint8[] _version1, uint8[] _version2) internal pure returns(bool) {

        require(_version1.length == _version2.length, "Input length mismatch");
        uint counter = 0;
        for (uint8 j = 0; j < _version1.length; j++) {
            if (_version1[j] == 0)
                counter ++;
        }
        if (counter != _version1.length) {
            counter = 0;
            for (uint8 i = 0; i < _version1.length; i++) {
                if (_version2[i] > _version1[i])
                    return true;
                else if (_version2[i] < _version1[i])
                    return false;
                else
                    counter++;
            }
            if (counter == _version1.length - 1)
                return true;
            else
                return false;
        } else
            return true;
    }

    function compareUpperBound(uint8[] _version1, uint8[] _version2) internal pure returns(bool) {

        require(_version1.length == _version2.length, "Input length mismatch");
        uint counter = 0;
        for (uint8 j = 0; j < _version1.length; j++) {
            if (_version1[j] == 0)
                counter ++;
        }
        if (counter != _version1.length) {
            counter = 0;
            for (uint8 i = 0; i < _version1.length; i++) {
                if (_version1[i] > _version2[i])
                    return true;
                else if (_version1[i] < _version2[i])
                    return false;
                else
                    counter++;
            }
            if (counter == _version1.length - 1)
                return true;
            else
                return false;
        } else
            return true;
    }


    function pack(uint8 _major, uint8 _minor, uint8 _patch) internal pure returns(uint24) {

        return (uint24(_major) << 16) | (uint24(_minor) << 8) | uint24(_patch);
    }

    function unpack(uint24 _packedVersion) internal pure returns (uint8[]) {

        uint8[] memory _unpackVersion = new uint8[](3);
        _unpackVersion[0] = uint8(_packedVersion >> 16);
        _unpackVersion[1] = uint8(_packedVersion >> 8);
        _unpackVersion[2] = uint8(_packedVersion);
        return _unpackVersion;
    }


}

contract EternalStorage {


    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
    mapping(bytes32 => bytes32) internal bytes32Storage;

    mapping(bytes32 => bytes32[]) internal bytes32ArrayStorage;
    mapping(bytes32 => uint256[]) internal uintArrayStorage;
    mapping(bytes32 => address[]) internal addressArrayStorage;
    mapping(bytes32 => string[]) internal stringArrayStorage;


    function set(bytes32 _key, uint256 _value) internal {

        uintStorage[_key] = _value;
    }

    function set(bytes32 _key, address _value) internal {

        addressStorage[_key] = _value;
    }

    function set(bytes32 _key, bool _value) internal {

        boolStorage[_key] = _value;
    }

    function set(bytes32 _key, bytes32 _value) internal {

        bytes32Storage[_key] = _value;
    }

    function set(bytes32 _key, string _value) internal {

        stringStorage[_key] = _value;
    }


    function getBool(bytes32 _key) internal view returns (bool) {

        return boolStorage[_key];
    }

    function getUint(bytes32 _key) internal view returns (uint256) {

        return uintStorage[_key];
    }

    function getAddress(bytes32 _key) internal view returns (address) {

        return addressStorage[_key];
    }

    function getString(bytes32 _key) internal view returns (string) {

        return stringStorage[_key];
    }

    function getBytes32(bytes32 _key) internal view returns (bytes32) {

        return bytes32Storage[_key];
    }




    function deleteArrayAddress(bytes32 _key, uint256 _index) internal {

        address[] storage array = addressArrayStorage[_key];
        require(_index < array.length, "Index should less than length of the array");
        array[_index] = array[array.length - 1];
        array.length = array.length - 1;
    }

    function deleteArrayBytes32(bytes32 _key, uint256 _index) internal {

        bytes32[] storage array = bytes32ArrayStorage[_key];
        require(_index < array.length, "Index should less than length of the array");
        array[_index] = array[array.length - 1];
        array.length = array.length - 1;
    }

    function deleteArrayUint(bytes32 _key, uint256 _index) internal {

        uint256[] storage array = uintArrayStorage[_key];
        require(_index < array.length, "Index should less than length of the array");
        array[_index] = array[array.length - 1];
        array.length = array.length - 1;
    }

    function deleteArrayString(bytes32 _key, uint256 _index) internal {

        string[] storage array = stringArrayStorage[_key];
        require(_index < array.length, "Index should less than length of the array");
        array[_index] = array[array.length - 1];
        array.length = array.length - 1;
    }


    function pushArray(bytes32 _key, address _value) internal {

        addressArrayStorage[_key].push(_value);
    }

    function pushArray(bytes32 _key, bytes32 _value) internal {

        bytes32ArrayStorage[_key].push(_value);
    }

    function pushArray(bytes32 _key, string _value) internal {

        stringArrayStorage[_key].push(_value);
    }

    function pushArray(bytes32 _key, uint256 _value) internal {

        uintArrayStorage[_key].push(_value);
    }

    
    function setArray(bytes32 _key, address[] _value) internal {

        addressArrayStorage[_key] = _value;
    }

    function setArray(bytes32 _key, uint256[] _value) internal {

        uintArrayStorage[_key] = _value;
    }

    function setArray(bytes32 _key, bytes32[] _value) internal {

        bytes32ArrayStorage[_key] = _value;
    }

    function setArray(bytes32 _key, string[] _value) internal {

        stringArrayStorage[_key] = _value;
    }


    function getArrayAddress(bytes32 _key) internal view returns(address[]) {

        return addressArrayStorage[_key];
    }

    function getArrayBytes32(bytes32 _key) internal view returns(bytes32[]) {

        return bytes32ArrayStorage[_key];
    }

    function getArrayString(bytes32 _key) internal view returns(string[]) {

        return stringArrayStorage[_key];
    }

    function getArrayUint(bytes32 _key) internal view returns(uint[]) {

        return uintArrayStorage[_key];
    }


    function setArrayIndexValue(bytes32 _key, uint256 _index, address _value) internal {

        addressArrayStorage[_key][_index] = _value;
    }

    function setArrayIndexValue(bytes32 _key, uint256 _index, uint256 _value) internal {

        uintArrayStorage[_key][_index] = _value;
    }

    function setArrayIndexValue(bytes32 _key, uint256 _index, bytes32 _value) internal {

        bytes32ArrayStorage[_key][_index] = _value;
    }

    function setArrayIndexValue(bytes32 _key, uint256 _index, string _value) internal {

        stringArrayStorage[_key][_index] = _value;
    }


    function getUintValues(bytes32 _variable) public view returns(uint256) {

        return uintStorage[_variable];
    }

    function getBoolValues(bytes32 _variable) public view returns(bool) {

        return boolStorage[_variable];
    }

    function getStringValues(bytes32 _variable) public view returns(string) {

        return stringStorage[_variable];
    }

    function getAddressValues(bytes32 _variable) public view returns(address) {

        return addressStorage[_variable];
    }

    function getBytes32Values(bytes32 _variable) public view returns(bytes32) {

        return bytes32Storage[_variable];
    }

    function getBytesValues(bytes32 _variable) public view returns(bytes) {

        return bytesStorage[_variable];
    }

}

library Encoder {


    function getKey(string _key) internal pure returns (bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key)));
    }

    function getKey(string _key1, address _key2) internal pure returns (bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

    function getKey(string _key1, string _key2) internal pure returns (bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

    function getKey(string _key1, uint256 _key2) internal pure returns (bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

    function getKey(string _key1, bytes32 _key2) internal pure returns (bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

    function getKey(string _key1, bool _key2) internal pure returns (bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

}

interface IOwnable {

    function owner() external view returns (address);


    function renounceOwnership() external;


    function transferOwnership(address _newOwner) external;


}

interface ISecurityToken {


    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);

    function increaseApproval(address _spender, uint _addedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function verifyTransfer(address _from, address _to, uint256 _value) external returns (bool success);


    function mint(address _investor, uint256 _value) external returns (bool success);


    function mintWithData(address _investor, uint256 _value, bytes _data) external returns (bool success);


    function burnFromWithData(address _from, uint256 _value, bytes _data) external;


    function burnWithData(uint256 _value, bytes _data) external;


    event Minted(address indexed _to, uint256 _value);
    event Burnt(address indexed _burner, uint256 _value);

    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns (bool);


    function getModule(address _module) external view returns(bytes32, address, address, bool, uint8, uint256, uint256);


    function getModulesByName(bytes32 _name) external view returns (address[]);


    function getModulesByType(uint8 _type) external view returns (address[]);


    function totalSupplyAt(uint256 _checkpointId) external view returns (uint256);


    function balanceOfAt(address _investor, uint256 _checkpointId) external view returns (uint256);


    function createCheckpoint() external returns (uint256);


    function getInvestors() external view returns (address[]);


    function getInvestorsAt(uint256 _checkpointId) external view returns(address[]);


    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]);

    
    function currentCheckpointId() external view returns (uint256);


    function investors(uint256 _index) external view returns (address);


    function withdrawERC20(address _tokenContract, uint256 _value) external;


    function changeModuleBudget(address _module, uint256 _budget) external;


    function updateTokenDetails(string _newTokenDetails) external;


    function changeGranularity(uint256 _granularity) external;


    function pruneInvestors(uint256 _start, uint256 _iters) external;


    function freezeTransfers() external;


    function unfreezeTransfers() external;


    function freezeMinting() external;


    function mintMulti(address[] _investors, uint256[] _values) external returns (bool success);


    function addModule(
        address _moduleFactory,
        bytes _data,
        uint256 _maxCost,
        uint256 _budget
    ) external;


    function archiveModule(address _module) external;


    function unarchiveModule(address _module) external;


    function removeModule(address _module) external;


    function setController(address _controller) external;


    function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) external;


    function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) external;


     function disableController() external;


     function getVersion() external view returns(uint8[]);


     function getInvestorCount() external view returns(uint256);


     function transferWithData(address _to, uint256 _value, bytes _data) external returns (bool success);


     function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) external returns(bool);


     function granularity() external view returns(uint256);

}

contract ModuleRegistry is IModuleRegistry, EternalStorage {



    event Pause(uint256 _timestammp);
    event Unpause(uint256 _timestamp);
    event ModuleUsed(address indexed _moduleFactory, address indexed _securityToken);
    event ModuleRegistered(address indexed _moduleFactory, address indexed _owner);
    event ModuleVerified(address indexed _moduleFactory, bool _verified);
    event ModuleRemoved(address indexed _moduleFactory, address indexed _decisionMaker);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier onlyOwner() {

        require(msg.sender == owner(),"sender must be owner");
        _;
    }

    modifier whenNotPausedOrOwner() {

        if (msg.sender == owner())
            _;
        else {
            require(!isPaused(), "Already paused");
            _;
        }
    }

    modifier whenNotPaused() {

        require(!isPaused(), "Already paused");
        _;
    }

    modifier whenPaused() {

        require(isPaused(), "Should not be paused");
        _;
    }


    constructor () public
    {

    }

    function initialize(address _polymathRegistry, address _owner) external payable {

        require(!getBool(Encoder.getKey("initialised")),"already initialized");
        require(_owner != address(0) && _polymathRegistry != address(0), "0x address is invalid");
        set(Encoder.getKey("polymathRegistry"), _polymathRegistry);
        set(Encoder.getKey("owner"), _owner);
        set(Encoder.getKey("paused"), false);
        set(Encoder.getKey("initialised"), true);
    }

    function useModule(address _moduleFactory) external {

        if (ISecurityTokenRegistry(getAddress(Encoder.getKey("securityTokenRegistry"))).isSecurityToken(msg.sender)) {
            if (IFeatureRegistry(getAddress(Encoder.getKey("featureRegistry"))).getFeatureStatus("customModulesAllowed")) {
                require(getBool(Encoder.getKey("verified", _moduleFactory)) || IOwnable(_moduleFactory).owner() == IOwnable(msg.sender).owner(),"ModuleFactory must be verified or SecurityToken owner must be ModuleFactory owner");
            } else {
                require(getBool(Encoder.getKey("verified", _moduleFactory)), "ModuleFactory must be verified");
            }
            require(_isCompatibleModule(_moduleFactory, msg.sender), "Version should within the compatible range of ST");
            pushArray(Encoder.getKey("reputation", _moduleFactory), msg.sender);
            emit ModuleUsed(_moduleFactory, msg.sender);
        }
    }

    function _isCompatibleModule(address _moduleFactory, address _securityToken) internal view returns(bool) {

        uint8[] memory _latestVersion = ISecurityToken(_securityToken).getVersion();
        uint8[] memory _lowerBound = IModuleFactory(_moduleFactory).getLowerSTVersionBounds();
        uint8[] memory _upperBound = IModuleFactory(_moduleFactory).getUpperSTVersionBounds();
        bool _isLowerAllowed = VersionUtils.compareLowerBound(_lowerBound, _latestVersion);
        bool _isUpperAllowed = VersionUtils.compareUpperBound(_upperBound, _latestVersion);
        return (_isLowerAllowed && _isUpperAllowed);
    }

    function registerModule(address _moduleFactory) external whenNotPausedOrOwner {

        if (IFeatureRegistry(getAddress(Encoder.getKey("featureRegistry"))).getFeatureStatus("customModulesAllowed")) {
            require(msg.sender == IOwnable(_moduleFactory).owner() || msg.sender == owner(),"msg.sender must be the Module Factory owner or registry curator");
        } else {
            require(msg.sender == owner(), "Only owner allowed to register modules");
        }
        require(getUint(Encoder.getKey("registry", _moduleFactory)) == 0, "Module factory should not be pre-registered");
        IModuleFactory moduleFactory = IModuleFactory(_moduleFactory);
        uint256 i;
        uint256 j;
        uint8[] memory moduleTypes = moduleFactory.getTypes();
        for (i = 1; i < moduleTypes.length; i++) {
            for (j = 0; j < i; j++) {
                require(moduleTypes[i] != moduleTypes[j], "Type mismatch");
            }
        }
        require(moduleTypes.length != 0, "Factory must have type");
        uint8 moduleType = moduleFactory.getTypes()[0];
        set(Encoder.getKey("registry", _moduleFactory), uint256(moduleType));
        set(
            Encoder.getKey("moduleListIndex", _moduleFactory),
            uint256(getArrayAddress(Encoder.getKey("moduleList", uint256(moduleType))).length)
        );
        pushArray(Encoder.getKey("moduleList", uint256(moduleType)), _moduleFactory);
        emit ModuleRegistered (_moduleFactory, IOwnable(_moduleFactory).owner());
    }

    function removeModule(address _moduleFactory) external whenNotPausedOrOwner {

        uint256 moduleType = getUint(Encoder.getKey("registry", _moduleFactory));

        require(moduleType != 0, "Module factory should be registered");
        require(
            msg.sender == IOwnable(_moduleFactory).owner() || msg.sender == owner(),
            "msg.sender must be the Module Factory owner or registry curator"
        );
        uint256 index = getUint(Encoder.getKey("moduleListIndex", _moduleFactory));
        uint256 last = getArrayAddress(Encoder.getKey("moduleList", moduleType)).length - 1;
        address temp = getArrayAddress(Encoder.getKey("moduleList", moduleType))[last];

        if (index != last) {
            setArrayIndexValue(Encoder.getKey("moduleList", moduleType), index, temp);
            set(Encoder.getKey("moduleListIndex", temp), index);
        }
        deleteArrayAddress(Encoder.getKey("moduleList", moduleType), last);

        set(Encoder.getKey("registry", _moduleFactory), uint256(0));
        setArray(Encoder.getKey("reputation", _moduleFactory), new address[](0));
        set(Encoder.getKey("verified", _moduleFactory), false);
        set(Encoder.getKey("moduleListIndex", _moduleFactory), uint256(0));
        emit ModuleRemoved(_moduleFactory, msg.sender);
    }

    function verifyModule(address _moduleFactory, bool _verified) external onlyOwner {

        require(getUint(Encoder.getKey("registry", _moduleFactory)) != uint256(0), "Module factory must be registered");
        set(Encoder.getKey("verified", _moduleFactory), _verified);
        emit ModuleVerified(_moduleFactory, _verified);
    }

    function getTagsByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns(bytes32[], address[]) {

        address[] memory modules = getModulesByTypeAndToken(_moduleType, _securityToken);
        return _tagsByModules(modules);
    }

    function getTagsByType(uint8 _moduleType) external view returns(bytes32[], address[]) {

        address[] memory modules = getModulesByType(_moduleType);
        return _tagsByModules(modules);
    }

    function _tagsByModules(address[] _modules) internal view returns(bytes32[], address[]) {

        uint256 counter = 0;
        uint256 i;
        uint256 j;
        for (i = 0; i < _modules.length; i++) {
            counter = counter + IModuleFactory(_modules[i]).getTags().length;
        }
        bytes32[] memory tags = new bytes32[](counter);
        address[] memory modules = new address[](counter);
        bytes32[] memory tempTags;
        counter = 0;
        for (i = 0; i < _modules.length; i++) {
            tempTags = IModuleFactory(_modules[i]).getTags();
            for (j = 0; j < tempTags.length; j++) {
                tags[counter] = tempTags[j];
                modules[counter] = _modules[i];
                counter++;
            }
        }
        return (tags, modules);
    }

    function getReputationByFactory(address _factoryAddress) external view returns(address[]) {

        return getArrayAddress(Encoder.getKey("reputation", _factoryAddress));
    }

    function getModulesByType(uint8 _moduleType) public view returns(address[]) {

        return getArrayAddress(Encoder.getKey("moduleList", uint256(_moduleType)));
    }

    function getModulesByTypeAndToken(uint8 _moduleType, address _securityToken) public view returns (address[]) {

        uint256 _len = getArrayAddress(Encoder.getKey("moduleList", uint256(_moduleType))).length;
        address[] memory _addressList = getArrayAddress(Encoder.getKey("moduleList", uint256(_moduleType)));
        bool _isCustomModuleAllowed = IFeatureRegistry(getAddress(Encoder.getKey("featureRegistry"))).getFeatureStatus("customModulesAllowed");
        uint256 counter = 0;
        for (uint256 i = 0; i < _len; i++) {
            if (_isCustomModuleAllowed) {
                if (IOwnable(_addressList[i]).owner() == IOwnable(_securityToken).owner() || getBool(Encoder.getKey("verified", _addressList[i])))
                    if(_isCompatibleModule(_addressList[i], _securityToken))
                        counter++;
            }
            else if (getBool(Encoder.getKey("verified", _addressList[i]))) {
                if(_isCompatibleModule(_addressList[i], _securityToken))
                    counter++;
            }
        }
        address[] memory _tempArray = new address[](counter);
        counter = 0;
        for (uint256 j = 0; j < _len; j++) {
            if (_isCustomModuleAllowed) {
                if (IOwnable(_addressList[j]).owner() == IOwnable(_securityToken).owner() || getBool(Encoder.getKey("verified", _addressList[j]))) {
                    if(_isCompatibleModule(_addressList[j], _securityToken)) {
                        _tempArray[counter] = _addressList[j];
                        counter ++;
                    }
                }
            }
            else if (getBool(Encoder.getKey("verified", _addressList[j]))) {
                if(_isCompatibleModule(_addressList[j], _securityToken)) {
                    _tempArray[counter] = _addressList[j];
                    counter ++;
                }
            }
        }
        return _tempArray;
    }

    function reclaimERC20(address _tokenContract) external onlyOwner {

        require(_tokenContract != address(0), "0x address is invalid");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner(), balance),"token transfer failed");
    }

    function pause() external whenNotPaused onlyOwner {

        set(Encoder.getKey("paused"), true);
        emit Pause(now);
    }

    function unpause() external whenPaused onlyOwner {

        set(Encoder.getKey("paused"), false);
        emit Unpause(now);
    }

    function updateFromRegistry() external onlyOwner {

        address _polymathRegistry = getAddress(Encoder.getKey("polymathRegistry"));
        set(Encoder.getKey("securityTokenRegistry"), IPolymathRegistry(_polymathRegistry).getAddress("SecurityTokenRegistry"));
        set(Encoder.getKey("featureRegistry"), IPolymathRegistry(_polymathRegistry).getAddress("FeatureRegistry"));
        set(Encoder.getKey("polyToken"), IPolymathRegistry(_polymathRegistry).getAddress("PolyToken"));
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner(), _newOwner);
        set(Encoder.getKey("owner"), _newOwner);
    }

    function owner() public view returns(address) {

        return getAddress(Encoder.getKey("owner"));
    }

    function isPaused() public view returns(bool) {

        return getBool(Encoder.getKey("paused"));
    }
}