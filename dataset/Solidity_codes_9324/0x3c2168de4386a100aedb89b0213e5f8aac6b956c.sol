

pragma solidity 0.4.24;

interface IBridgeValidators {

    function initialize(uint256 _requiredSignatures, address[] _initialValidators, address _owner) external returns(bool);

    function isValidator(address _validator) external view returns(bool);

    function requiredSignatures() external view returns(uint256);

    function owner() external view returns(address);

}


pragma solidity 0.4.24;

contract IForeignBridge {


  function initialize(
        address _validatorContract,
        address _erc20token,
        uint256 _requiredBlockConfirmations,
        uint256 _gasPrice,
        uint256 _maxPerTx,
        uint256 _homeDailyLimit,
        uint256 _homeMaxPerTx,
        address _owner
    ) public returns(bool);

}


pragma solidity 0.4.24;

contract EternalStorage {


    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;


    mapping(bytes32 => uint256[]) internal uintArrayStorage;
    mapping(bytes32 => string[]) internal stringArrayStorage;
    mapping(bytes32 => address[]) internal addressArrayStorage;
    mapping(bytes32 => bool[]) internal boolArrayStorage;
    mapping(bytes32 => int256[]) internal intArrayStorage;
    mapping(bytes32 => bytes32[]) internal bytes32ArrayStorage;
}


pragma solidity 0.4.24;

contract Proxy {


    function implementation() public view returns (address);


    function setImplementation(address _newImplementation) external;


    function () payable public {
        address _impl = implementation();
        require(_impl != address(0));

        address _innerImpl;
        bytes4 sig;
        address thisAddress = address(this);
        if (_impl.call(0x5c60da1b)) { // bytes(keccak256("implementation()"))
            _innerImpl = Proxy(_impl).implementation();
            this.setImplementation(_innerImpl);
            sig = 0xd784d426; // bytes4(keccak256("setImplementation(address)"))
        }

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            mstore(0x40, add(ptr, returndatasize))
            returndatacopy(ptr, 0, returndatasize)

            let retdatasize := returndatasize

            switch sig
            case 0 {}
            default {
                let x := mload(0x40)
                mstore(x, sig)
                mstore(add(x, 0x04), _impl)
                let success := call(gas, thisAddress, 0, x, 0x24, x, 0x0)
            }

            switch result
            case 0 { revert(ptr, retdatasize) }
            default { return(ptr, retdatasize) }
        }
    }
}


pragma solidity 0.4.24;

contract UpgradeabilityStorage {

    uint256 internal _version;

    address internal _implementation;

    function version() public view returns (uint256) {

        return _version;
    }

    function implementation() public view returns (address) {

        return _implementation;
    }

    function setImplementation(address _newImplementation) external {

        require(msg.sender == address(this));
        _implementation = _newImplementation;
    }
}


pragma solidity 0.4.24;



contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {

    event Upgraded(uint256 version, address indexed implementation);

    function _upgradeTo(uint256 version, address implementation) internal {

        require(_implementation != implementation);
        require(version > _version);
        _version = version;
        _implementation = implementation;
        emit Upgraded(version, implementation);
    }
}


pragma solidity 0.4.24;

contract UpgradeabilityOwnerStorage {

    address private _upgradeabilityOwner;

    function upgradeabilityOwner() public view returns (address) {

        return _upgradeabilityOwner;
    }

    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {

        _upgradeabilityOwner = newUpgradeabilityOwner;
    }
}


pragma solidity 0.4.24;



contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    constructor() public {
        setUpgradeabilityOwner(msg.sender);
    }

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner());
        _;
    }

    function proxyOwner() public view returns (address) {

        return upgradeabilityOwner();
    }

    function transferProxyOwnership(address newOwner) public onlyProxyOwner {

        require(newOwner != address(0));
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

    function upgradeTo(uint256 version, address implementation) public onlyProxyOwner {

        _upgradeTo(version, implementation);
    }

    function upgradeToAndCall(uint256 version, address implementation, bytes data) payable public onlyProxyOwner {

        upgradeTo(version, implementation);
        require(address(this).call.value(msg.value)(data));
    }
}


pragma solidity 0.4.24;



contract EternalStorageProxy is OwnedUpgradeabilityProxy, EternalStorage {}



pragma solidity 0.4.24;


contract EternalOwnable is EternalStorage {

    event EternalOwnershipTransferred(address previousOwner, address newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner());
        _;
    }

    function owner() public view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("owner"))];
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        setOwner(newOwner);
    }

    function setOwner(address newOwner) internal {

        emit EternalOwnershipTransferred(owner(), newOwner);
        addressStorage[keccak256(abi.encodePacked("owner"))] = newOwner;
    }
}


pragma solidity 0.4.24;



contract BasicBridgeFactory is EternalStorage, EternalOwnable {

    uint256 constant public defaultDecimals = 18;

    function getBridgeFactoryVersion() public pure returns(uint64 major, uint64 minor, uint64 patch) {

        return (3, 0, 0);
    }

    function bridgeValidatorsImplementation() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("bridgeValidatorsImplementation"))];
    }

    function setBridgeValidatorsImplementation(address _bridgeValidatorsImplementation) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("bridgeValidatorsImplementation"))] = _bridgeValidatorsImplementation;
    }

    function requiredSignatures() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("requiredSignatures"))];
    }

    function setRequiredSignatures(uint256 _requiredSignatures) public onlyOwner {

        require(initialValidators().length >= _requiredSignatures);
        uintStorage[keccak256(abi.encodePacked("requiredSignatures"))] = _requiredSignatures;
    }

    function initialValidators() public view returns(address[]) {

        return addressArrayStorage[keccak256(abi.encodePacked("initialValidators"))];
    }

    function setInitialValidators(address[] _initialValidators) public onlyOwner {

        require(_initialValidators.length >= requiredSignatures());
        addressArrayStorage[keccak256(abi.encodePacked("initialValidators"))] = _initialValidators;
    }

    function bridgeValidatorsOwner() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("bridgeValidatorsOwner"))];
    }

    function setBridgeValidatorsOwner(address _bridgeValidatorsOwner) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("bridgeValidatorsOwner"))] = _bridgeValidatorsOwner;
    }

    function bridgeValidatorsProxyOwner() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("bridgeValidatorsProxyOwner"))];
    }

    function setBridgeValidatorsProxyOwner(address _bridgeValidatorsProxyOwner) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("bridgeValidatorsProxyOwner"))] = _bridgeValidatorsProxyOwner;
    }

    function requiredBlockConfirmations() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))];
    }

    function setRequiredBlockConfirmations(uint256 _requiredBlockConfirmations) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _requiredBlockConfirmations;
    }

    function gasPrice() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("gasPrice"))];
    }

    function setGasPrice(uint256 _gasPrice) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _gasPrice;
    }

    function homeDailyLimit() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("homeDailyLimit"))];
    }

    function setHomeDailyLimit(uint256 _homeDailyLimit) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("homeDailyLimit"))] = _homeDailyLimit;
    }

    function homeMaxPerTx() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("homeMaxPerTx"))];
    }

    function setHomeMaxPerTx(uint256 _homeMaxPerTx) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("homeMaxPerTx"))] = _homeMaxPerTx;
    }

    function foreignMaxPerTx() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("foreignMaxPerTx"))];
    }

    function setForeignMaxPerTx(uint256 _foreignMaxPerTx) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("foreignMaxPerTx"))] = _foreignMaxPerTx;
    }

    function setInitialize(bool _status) internal {

        boolStorage[keccak256(abi.encodePacked("isInitialized"))] = _status;
    }

    function isInitialized() public view returns(bool) {

        return boolStorage[keccak256(abi.encodePacked("isInitialized"))];
    }

    function adjustToDefaultDecimals(uint256 _amount, uint8 _decimals) public pure  returns(uint256) {

        if (defaultDecimals > _decimals) {
            return _amount / (10 ** (defaultDecimals - _decimals));
        } else if (defaultDecimals < _decimals) {
            return _amount * (10 ** (_decimals - defaultDecimals));
        } else {
            return _amount;
        }
    }
}


pragma solidity ^0.4.24;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address who) external view returns (uint256);


  function allowance(address owner, address spender)
    external view returns (uint256);


  function transfer(address to, uint256 value) external returns (bool);


  function approve(address spender, uint256 value)
    external returns (bool);


  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


pragma solidity ^0.4.24;


contract ERC20Detailed is IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string) {

    return _name;
  }

  function symbol() public view returns(string) {

    return _symbol;
  }

  function decimals() public view returns(uint8) {

    return _decimals;
  }
}


pragma solidity 0.4.24;






contract ForeignBridgeFactory is BasicBridgeFactory {


    event ForeignBridgeDeployed(address indexed _foreignBridge, address indexed _foreignValidators, address _foreignToken, uint256 _blockNumber);

    function initialize(address _owner,
            address _bridgeValidatorsImplementation,
            uint256 _requiredSignatures,
            address[] _initialValidators,
            address _bridgeValidatorsOwner,
            address _foreignBridgeErcToErcImplementation,
            uint256 _requiredBlockConfirmations,
            uint256 _gasPrice,
            uint256 _foreignMaxPerTx,
            uint256 _homeDailyLimit,
            uint256 _homeMaxPerTx,
            address _foreignBridgeOwner,
            address _foreignProxyOwner) public returns(bool) {


        require(!isInitialized());
        require(_owner != address(0));
        require(_bridgeValidatorsImplementation != address(0));
        require(_requiredSignatures >= 1);
        require(_bridgeValidatorsOwner != address(0));
        require(_foreignBridgeErcToErcImplementation != address(0));
        require(_requiredBlockConfirmations != 0);
        require(_gasPrice > 0);
        require(_foreignMaxPerTx >= 0);
        require(_homeMaxPerTx < _homeDailyLimit);
        require(_foreignBridgeOwner != address(0));
        require(_foreignProxyOwner != address(0));
        require(_initialValidators.length >= _requiredSignatures);

        setOwner(msg.sender); // set just to have access to the setters.
        setBridgeValidatorsImplementation(_bridgeValidatorsImplementation);
        setInitialValidators(_initialValidators);
        setRequiredSignatures(_requiredSignatures);
        setBridgeValidatorsOwner(_bridgeValidatorsOwner);
        setBridgeValidatorsProxyOwner(_foreignProxyOwner);
        setForeignBridgeErcToErcImplementation(_foreignBridgeErcToErcImplementation);
        setRequiredBlockConfirmations(_requiredBlockConfirmations);
        setGasPrice(_gasPrice);
        setForeignMaxPerTx(_foreignMaxPerTx);
        setHomeDailyLimit(_homeDailyLimit);
        setHomeMaxPerTx(_homeMaxPerTx);
        setForeignBridgeOwner(_foreignBridgeOwner);
        setForeignBridgeProxyOwner(_foreignProxyOwner);
        setInitialize(true);
        setOwner(_owner); // set to the real owner.
        return isInitialized();
    }

    function deployForeignBridge(address _erc20Token) public {

        EternalStorageProxy proxy = new EternalStorageProxy();
        proxy.upgradeTo(1, bridgeValidatorsImplementation());
        IBridgeValidators bridgeValidators = IBridgeValidators(proxy);
        bridgeValidators.initialize(requiredSignatures(), initialValidators(), bridgeValidatorsOwner());
        proxy.transferProxyOwnership(bridgeValidatorsProxyOwner());
        proxy = new EternalStorageProxy();
        proxy.upgradeTo(1, foreignBridgeErcToErcImplementation());
        IForeignBridge foreignBridge = IForeignBridge(proxy);
        uint8 tokenDecimals = ERC20Detailed(_erc20Token).decimals();
        uint256 foreignMaxPerTxVal = adjustToDefaultDecimals(foreignMaxPerTx(), tokenDecimals);
        uint256 homeDailyLimitVal = adjustToDefaultDecimals(homeDailyLimit(), tokenDecimals);
        uint256 homeMaxPerTxVal = adjustToDefaultDecimals(homeMaxPerTx(), tokenDecimals);
        foreignBridge.initialize(bridgeValidators, _erc20Token, requiredBlockConfirmations(), gasPrice(), foreignMaxPerTxVal, homeDailyLimitVal, homeMaxPerTxVal, foreignBridgeOwner());
        proxy.transferProxyOwnership(foreignBridgeProxyOwner());
        emit ForeignBridgeDeployed(foreignBridge, bridgeValidators, _erc20Token, block.number);
    }

    function registerForeignBridge(address _foreignBridge, address _foreignValidators, address _erc20Token, uint256 _blockNumber) public onlyOwner {

        emit ForeignBridgeDeployed(_foreignBridge, _foreignValidators, _erc20Token, _blockNumber);
    }

    function foreignBridgeErcToErcImplementation() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("foreignBridgeErcToErcImplementation"))];
    }

    function setForeignBridgeErcToErcImplementation(address _foreignBridgeErcToErcImplementation) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("foreignBridgeErcToErcImplementation"))] = _foreignBridgeErcToErcImplementation;
    }

    function foreignBridgeOwner() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("foreignBridgeOwner"))];
    }

    function setForeignBridgeOwner(address _foreignBridgeOwner) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("foreignBridgeOwner"))] = _foreignBridgeOwner;
    }

    function foreignBridgeProxyOwner() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("foreignBridgeProxyOwner"))];
    }

    function setForeignBridgeProxyOwner(address _foreignBridgeProxyOwner) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("foreignBridgeProxyOwner"))] = _foreignBridgeProxyOwner;
    }
}