

pragma solidity 0.4.26;

contract IOwned {

    function owner() public view returns (address) {this;}


    function transferOwnership(address _newOwner) public;

    function acceptOwnership() public;

}


pragma solidity 0.4.26;


contract Owned is IOwned {

    address public owner;
    address public newOwner;

    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier ownerOnly {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public ownerOnly {

        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


pragma solidity 0.4.26;

contract Utils {

    constructor() public {
    }

    modifier greaterThanZero(uint256 _amount) {

        require(_amount > 0);
        _;
    }

    modifier validAddress(address _address) {

        require(_address != address(0));
        _;
    }

    modifier notThis(address _address) {

        require(_address != address(this));
        _;
    }

}


pragma solidity 0.4.26;

contract IContractRegistry {

    function addressOf(bytes32 _contractName) public view returns (address);


    function getAddress(bytes32 _contractName) public view returns (address);

}


pragma solidity 0.4.26;




contract ContractRegistryClient is Owned, Utils {

    bytes32 internal constant CONTRACT_FEATURES = "ContractFeatures";
    bytes32 internal constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 internal constant NON_STANDARD_TOKEN_REGISTRY = "NonStandardTokenRegistry";
    bytes32 internal constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 internal constant BANCOR_FORMULA = "BancorFormula";
    bytes32 internal constant BANCOR_GAS_PRICE_LIMIT = "BancorGasPriceLimit";
    bytes32 internal constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";
    bytes32 internal constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 internal constant BANCOR_CONVERTER_REGISTRY = "BancorConverterRegistry";
    bytes32 internal constant BANCOR_CONVERTER_REGISTRY_DATA = "BancorConverterRegistryData";
    bytes32 internal constant BNT_TOKEN = "BNTToken";
    bytes32 internal constant BANCOR_X = "BancorX";
    bytes32 internal constant BANCOR_X_UPGRADER = "BancorXUpgrader";

    IContractRegistry public registry;      // address of the current contract-registry
    IContractRegistry public prevRegistry;  // address of the previous contract-registry
    bool public adminOnly;                  // only an administrator can update the contract-registry

    modifier only(bytes32 _contractName) {

        require(msg.sender == addressOf(_contractName));
        _;
    }

    constructor(IContractRegistry _registry) internal validAddress(_registry) {
        registry = IContractRegistry(_registry);
        prevRegistry = IContractRegistry(_registry);
    }

    function updateRegistry() public {

        require(!adminOnly || isAdmin());

        address newRegistry = addressOf(CONTRACT_REGISTRY);

        require(newRegistry != address(registry) && newRegistry != address(0));

        require(IContractRegistry(newRegistry).addressOf(CONTRACT_REGISTRY) != address(0));

        prevRegistry = registry;

        registry = IContractRegistry(newRegistry);
    }

    function restoreRegistry() public {

        require(isAdmin());

        registry = prevRegistry;
    }

    function restrictRegistryUpdate(bool _adminOnly) public {

        require(adminOnly != _adminOnly && isAdmin());

        adminOnly = _adminOnly;
    }

    function isAdmin() internal view returns (bool) {

        return msg.sender == owner;
    }

    function addressOf(bytes32 _contractName) internal view returns (address) {

        return registry.addressOf(_contractName);
    }
}


pragma solidity 0.4.26;

interface IBancorConverterRegistryData {

    function addSmartToken(address _smartToken) external;

    function removeSmartToken(address _smartToken) external;

    function addLiquidityPool(address _liquidityPool) external;

    function removeLiquidityPool(address _liquidityPool) external;

    function addConvertibleToken(address _convertibleToken, address _smartToken) external;

    function removeConvertibleToken(address _convertibleToken, address _smartToken) external;

    function getSmartTokenCount() external view returns (uint);

    function getSmartTokens() external view returns (address[]);

    function getSmartToken(uint _index) external view returns (address);

    function isSmartToken(address _value) external view returns (bool);

    function getLiquidityPoolCount() external view returns (uint);

    function getLiquidityPools() external view returns (address[]);

    function getLiquidityPool(uint _index) external view returns (address);

    function isLiquidityPool(address _value) external view returns (bool);

    function getConvertibleTokenCount() external view returns (uint);

    function getConvertibleTokens() external view returns (address[]);

    function getConvertibleToken(uint _index) external view returns (address);

    function isConvertibleToken(address _value) external view returns (bool);

    function getConvertibleTokenSmartTokenCount(address _convertibleToken) external view returns (uint);

    function getConvertibleTokenSmartTokens(address _convertibleToken) external view returns (address[]);

    function getConvertibleTokenSmartToken(address _convertibleToken, uint _index) external view returns (address);

    function isConvertibleTokenSmartToken(address _convertibleToken, address _value) external view returns (bool);

}


pragma solidity 0.4.26;



contract BancorConverterRegistryData is IBancorConverterRegistryData, ContractRegistryClient {

    struct Item {
        bool valid;
        uint index;
    }

    struct Items {
        address[] array;
        mapping(address => Item) table;
    }

    struct List {
        uint index;
        Items items;
    }

    struct Lists {
        address[] array;
        mapping(address => List) table;
    }

    Items smartTokens;
    Items liquidityPools;
    Lists convertibleTokens;

    constructor(IContractRegistry _registry) ContractRegistryClient(_registry) public {
    }

    function addSmartToken(address _smartToken) external only(BANCOR_CONVERTER_REGISTRY) {

        addItem(smartTokens, _smartToken);
    }

    function removeSmartToken(address _smartToken) external only(BANCOR_CONVERTER_REGISTRY) {

        removeItem(smartTokens, _smartToken);
    }

    function addLiquidityPool(address _liquidityPool) external only(BANCOR_CONVERTER_REGISTRY) {

        addItem(liquidityPools, _liquidityPool);
    }

    function removeLiquidityPool(address _liquidityPool) external only(BANCOR_CONVERTER_REGISTRY) {

        removeItem(liquidityPools, _liquidityPool);
    }

    function addConvertibleToken(address _convertibleToken, address _smartToken) external only(BANCOR_CONVERTER_REGISTRY) {

        List storage list = convertibleTokens.table[_convertibleToken];
        if (list.items.array.length == 0) {
            list.index = convertibleTokens.array.push(_convertibleToken) - 1;
        }
        addItem(list.items, _smartToken);
    }

    function removeConvertibleToken(address _convertibleToken, address _smartToken) external only(BANCOR_CONVERTER_REGISTRY) {

        List storage list = convertibleTokens.table[_convertibleToken];
        removeItem(list.items, _smartToken);
        if (list.items.array.length == 0) {
            address lastConvertibleToken = convertibleTokens.array[convertibleTokens.array.length - 1];
            convertibleTokens.table[lastConvertibleToken].index = list.index;
            convertibleTokens.array[list.index] = lastConvertibleToken;
            convertibleTokens.array.length--;
            delete convertibleTokens.table[_convertibleToken];
        }
    }

    function getSmartTokenCount() external view returns (uint) {

        return smartTokens.array.length;
    }

    function getSmartTokens() external view returns (address[]) {

        return smartTokens.array;
    }

    function getSmartToken(uint _index) external view returns (address) {

        return smartTokens.array[_index];
    }

    function isSmartToken(address _value) external view returns (bool) {

        return smartTokens.table[_value].valid;
    }

    function getLiquidityPoolCount() external view returns (uint) {

        return liquidityPools.array.length;
    }

    function getLiquidityPools() external view returns (address[]) {

        return liquidityPools.array;
    }

    function getLiquidityPool(uint _index) external view returns (address) {

        return liquidityPools.array[_index];
    }

    function isLiquidityPool(address _value) external view returns (bool) {

        return liquidityPools.table[_value].valid;
    }

    function getConvertibleTokenCount() external view returns (uint) {

        return convertibleTokens.array.length;
    }

    function getConvertibleTokens() external view returns (address[]) {

        return convertibleTokens.array;
    }

    function getConvertibleToken(uint _index) external view returns (address) {

        return convertibleTokens.array[_index];
    }

    function isConvertibleToken(address _value) external view returns (bool) {

        return convertibleTokens.table[_value].items.array.length > 0;
    }

    function getConvertibleTokenSmartTokenCount(address _convertibleToken) external view returns (uint) {

        return convertibleTokens.table[_convertibleToken].items.array.length;
    }

    function getConvertibleTokenSmartTokens(address _convertibleToken) external view returns (address[]) {

        return convertibleTokens.table[_convertibleToken].items.array;
    }

    function getConvertibleTokenSmartToken(address _convertibleToken, uint _index) external view returns (address) {

        return convertibleTokens.table[_convertibleToken].items.array[_index];
    }

    function isConvertibleTokenSmartToken(address _convertibleToken, address _value) external view returns (bool) {

        return convertibleTokens.table[_convertibleToken].items.table[_value].valid;
    }

    function addItem(Items storage _items, address _value) internal {

        Item storage item = _items.table[_value];
        require(item.valid == false);

        item.index = _items.array.push(_value) - 1;
        item.valid = true;
    }

    function removeItem(Items storage _items, address _value) internal {

        Item storage item = _items.table[_value];
        require(item.valid == true);

        address lastValue = _items.array[_items.array.length - 1];
        _items.table[lastValue].index = item.index;
        _items.array[item.index] = lastValue;
        _items.array.length--;
        delete _items.table[_value];
    }
}