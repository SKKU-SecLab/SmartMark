
pragma solidity ^0.4.24;

contract ERC20DividendCheckpointStorage {


    mapping (uint256 => address) public dividendTokens;

}

contract DividendCheckpointStorage {


    address public wallet;
    uint256 public EXCLUDED_ADDRESS_LIMIT = 150;
    bytes32 public constant DISTRIBUTE = "DISTRIBUTE";
    bytes32 public constant MANAGE = "MANAGE";
    bytes32 public constant CHECKPOINT = "CHECKPOINT";

    struct Dividend {
        uint256 checkpointId;
        uint256 created; // Time at which the dividend was created
        uint256 maturity; // Time after which dividend can be claimed - set to 0 to bypass
        uint256 expiry;  // Time until which dividend can be claimed - after this time any remaining amount can be withdrawn by issuer -
        uint256 amount; // Dividend amount in WEI
        uint256 claimedAmount; // Amount of dividend claimed so far
        uint256 totalSupply; // Total supply at the associated checkpoint (avoids recalculating this)
        bool reclaimed;  // True if expiry has passed and issuer has reclaimed remaining dividend
        uint256 totalWithheld;
        uint256 totalWithheldWithdrawn;
        mapping (address => bool) claimed; // List of addresses which have claimed dividend
        mapping (address => bool) dividendExcluded; // List of addresses which cannot claim dividends
        mapping (address => uint256) withheld; // Amount of tax withheld from claim
        bytes32 name; // Name/title - used for identification
    }

    Dividend[] public dividends;

    address[] public excluded;

    mapping (address => uint256) public withholdingTax;

}

contract Proxy {


    function _implementation() internal view returns (address);


    function _fallback() internal {

        _delegate(_implementation());
    }

    function _delegate(address implementation) internal {

        assembly {
            calldatacopy(0, 0, calldatasize)

            let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

            returndatacopy(0, 0, returndatasize)

            switch result
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }

    function () public payable {
        _fallback();
    }
}

contract OwnedProxy is Proxy {


    address private __owner;

    address internal __implementation;

    event ProxyOwnershipTransferred(address _previousOwner, address _newOwner);

    modifier ifOwner() {

        if (msg.sender == _owner()) {
            _;
        } else {
            _fallback();
        }
    }

    constructor() public {
        _setOwner(msg.sender);
    }

    function _owner() internal view returns (address) {

        return __owner;
    }

    function _setOwner(address _newOwner) internal {

        require(_newOwner != address(0), "Address should not be 0x");
        __owner = _newOwner;
    }

    function _implementation() internal view returns (address) {

        return __implementation;
    }

    function proxyOwner() external ifOwner returns (address) {

        return _owner();
    }

    function implementation() external ifOwner returns (address) {

        return _implementation();
    }

    function transferProxyOwnership(address _newOwner) external ifOwner {

        require(_newOwner != address(0), "Address should not be 0x");
        emit ProxyOwnershipTransferred(_owner(), _newOwner);
        _setOwner(_newOwner);
    }

}

contract Pausable {


    event Pause(uint256 _timestammp);
    event Unpause(uint256 _timestamp);

    bool public paused = false;

    modifier whenNotPaused() {

        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {

        require(paused, "Contract is not paused");
        _;
    }

    function _pause() internal whenNotPaused {

        paused = true;
        emit Pause(now);
    }

    function _unpause() internal whenPaused {

        paused = false;
        emit Unpause(now);
    }

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

contract ModuleStorage {


    constructor (address _securityToken, address _polyAddress) public {
        securityToken = _securityToken;
        factory = msg.sender;
        polyToken = IERC20(_polyAddress);
    }
    
    address public factory;

    address public securityToken;

    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";

    IERC20 public polyToken;

}

contract ERC20DividendCheckpointProxy is ERC20DividendCheckpointStorage, DividendCheckpointStorage, ModuleStorage, Pausable, OwnedProxy {


    constructor (address _securityToken, address _polyAddress, address _implementation)
    public
    ModuleStorage(_securityToken, _polyAddress)
    {
        require(
            _implementation != address(0),
            "Implementation address should not be 0x"
        );
        __implementation = _implementation;
    }

}

library Util {


    function upper(string _base) internal pure returns (string) {

        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            bytes1 b1 = _baseBytes[i];
            if (b1 >= 0x61 && b1 <= 0x7A) {
                b1 = bytes1(uint8(b1)-32);
            }
            _baseBytes[i] = b1;
        }
        return string(_baseBytes);
    }

    function stringToBytes32(string memory _source) internal pure returns (bytes32) {

        return bytesToBytes32(bytes(_source), 0);
    }

    function bytesToBytes32(bytes _b, uint _offset) internal pure returns (bytes32) {

        bytes32 result;

        for (uint i = 0; i < _b.length; i++) {
            result |= bytes32(_b[_offset + i] & 0xFF) >> (i * 8);
        }
        return result;
    }

    function bytes32ToString(bytes32 _source) internal pure returns (string result) {

        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_source) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function getSig(bytes _data) internal pure returns (bytes4 sig) {

        uint len = _data.length < 4 ? _data.length : 4;
        for (uint i = 0; i < len; i++) {
            sig = bytes4(uint(sig) + uint(_data[i]) * (2 ** (8 * (len - 1 - i))));
        }
    }


}

interface IBoot {


    function getInitFunction() external pure returns(bytes4);

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

contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
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

contract ModuleFactory is IModuleFactory, Ownable {


    IERC20 public polyToken;
    uint256 public usageCost;
    uint256 public monthlySubscriptionCost;

    uint256 public setupCost;
    string public description;
    string public version;
    bytes32 public name;
    string public title;

    mapping(string => uint24) compatibleSTVersionRange;

    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public {
        polyToken = IERC20(_polyAddress);
        setupCost = _setupCost;
        usageCost = _usageCost;
        monthlySubscriptionCost = _subscriptionCost;
    }

    function changeFactorySetupFee(uint256 _newSetupCost) public onlyOwner {

        emit ChangeFactorySetupFee(setupCost, _newSetupCost, address(this));
        setupCost = _newSetupCost;
    }

    function changeFactoryUsageFee(uint256 _newUsageCost) public onlyOwner {

        emit ChangeFactoryUsageFee(usageCost, _newUsageCost, address(this));
        usageCost = _newUsageCost;
    }

    function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) public onlyOwner {

        emit ChangeFactorySubscriptionFee(monthlySubscriptionCost, _newSubscriptionCost, address(this));
        monthlySubscriptionCost = _newSubscriptionCost;

    }

    function changeTitle(string _newTitle) public onlyOwner {

        require(bytes(_newTitle).length > 0, "Invalid title");
        title = _newTitle;
    }

    function changeDescription(string _newDesc) public onlyOwner {

        require(bytes(_newDesc).length > 0, "Invalid description");
        description = _newDesc;
    }

    function changeName(bytes32 _newName) public onlyOwner {

        require(_newName != bytes32(0),"Invalid name");
        name = _newName;
    }

    function changeVersion(string _newVersion) public onlyOwner {

        require(bytes(_newVersion).length > 0, "Invalid version");
        version = _newVersion;
    }

    function changeSTVersionBounds(string _boundType, uint8[] _newVersion) external onlyOwner {

        require(
            keccak256(abi.encodePacked(_boundType)) == keccak256(abi.encodePacked("lowerBound")) ||
            keccak256(abi.encodePacked(_boundType)) == keccak256(abi.encodePacked("upperBound")),
            "Must be a valid bound type"
        );
        require(_newVersion.length == 3);
        if (compatibleSTVersionRange[_boundType] != uint24(0)) { 
            uint8[] memory _currentVersion = VersionUtils.unpack(compatibleSTVersionRange[_boundType]);
            require(VersionUtils.isValidVersion(_currentVersion, _newVersion), "Failed because of in-valid version");
        }
        compatibleSTVersionRange[_boundType] = VersionUtils.pack(_newVersion[0], _newVersion[1], _newVersion[2]);
        emit ChangeSTVersionBound(_boundType, _newVersion[0], _newVersion[1], _newVersion[2]);
    }

    function getLowerSTVersionBounds() external view returns(uint8[]) {

        return VersionUtils.unpack(compatibleSTVersionRange["lowerBound"]);
    }

    function getUpperSTVersionBounds() external view returns(uint8[]) {

        return VersionUtils.unpack(compatibleSTVersionRange["upperBound"]);
    }

    function getSetupCost() external view returns (uint256) {

        return setupCost;
    }

    function getName() public view returns(bytes32) {

        return name;
    }

}

contract ERC20DividendCheckpointFactory is ModuleFactory {


    address public logicContract;

    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost, address _logicContract) public
    ModuleFactory(_polyAddress, _setupCost, _usageCost, _subscriptionCost)
    {
        require(_logicContract != address(0), "Invalid logic contract");
        version = "2.1.1";
        name = "ERC20DividendCheckpoint";
        title = "ERC20 Dividend Checkpoint";
        description = "Create ERC20 dividends for token holders at a specific checkpoint";
        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));
        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));
        logicContract = _logicContract;
    }

    function deploy(bytes _data) external returns(address) {

        if (setupCost > 0)
            require(polyToken.transferFrom(msg.sender, owner, setupCost), "insufficent allowance");
        address erc20DividendCheckpoint = new ERC20DividendCheckpointProxy(msg.sender, address(polyToken), logicContract);
        require(Util.getSig(_data) == IBoot(erc20DividendCheckpoint).getInitFunction(), "Invalid data");
        require(erc20DividendCheckpoint.call(_data), "Unsuccessfull call");
        emit GenerateModuleFromFactory(erc20DividendCheckpoint, getName(), address(this), msg.sender, setupCost, now);
        return erc20DividendCheckpoint;
    }

    function getTypes() external view returns(uint8[]) {

        uint8[] memory res = new uint8[](1);
        res[0] = 4;
        return res;
    }

    function getInstructions() external view returns(string) {

        return "Create ERC20 dividend to be paid out to token holders based on their balances at dividend creation time";
    }

    function getTags() external view returns(bytes32[]) {

        bytes32[] memory availableTags = new bytes32[](3);
        availableTags[0] = "ERC20";
        availableTags[1] = "Dividend";
        availableTags[2] = "Checkpoint";
        return availableTags;
    }
}