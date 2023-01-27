
pragma solidity >=0.6.0 <0.8.0;

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.7.0;

abstract contract Proxy {
    function _delegate(address implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal virtual view returns (address);

    function _fallback() internal {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () payable external {
        _fallback();
    }

    receive () payable external {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}// MIT

pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.7.0;


contract UpgradeableProxy is Proxy {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            (bool success,) = _logic.delegatecall(_data);
            require(success);
        }
    }

    event Upgraded(address indexed implementation);

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal override view returns (address impl) {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}// MIT

pragma solidity ^0.7.0;


contract TransparentUpgradeableProxy is UpgradeableProxy {

    constructor(address _logic, address _admin, bytes memory _data) payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(_admin);
    }

    event AdminChanged(address previousAdmin, address newAdmin);

    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address) {

        return _admin();
    }

    function implementation() external ifAdmin returns (address) {

        return _implementation();
    }

    function changeAdmin(address newAdmin) external ifAdmin {

        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeTo(newImplementation);
        (bool success,) = newImplementation.delegatecall(data);
        require(success);
    }

    function _admin() internal view returns (address adm) {

        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) private {

        bytes32 slot = _ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _beforeFallback() internal override virtual {

        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

interface IContractsRegistry {

    function getUniswapRouterContract() external view returns (address);


    function getUniswapBMIToETHPairContract() external view returns (address);


    function getUniswapBMIToUSDTPairContract() external view returns (address);


    function getSushiswapRouterContract() external view returns (address);


    function getSushiswapBMIToETHPairContract() external view returns (address);


    function getSushiswapBMIToUSDTPairContract() external view returns (address);


    function getSushiSwapMasterChefV2Contract() external view returns (address);


    function getWETHContract() external view returns (address);


    function getUSDTContract() external view returns (address);


    function getBMIContract() external view returns (address);


    function getPriceFeedContract() external view returns (address);


    function getPolicyBookRegistryContract() external view returns (address);


    function getPolicyBookFabricContract() external view returns (address);


    function getBMICoverStakingContract() external view returns (address);


    function getBMICoverStakingViewContract() external view returns (address);


    function getLegacyRewardsGeneratorContract() external view returns (address);


    function getRewardsGeneratorContract() external view returns (address);


    function getBMIUtilityNFTContract() external view returns (address);


    function getNFTStakingContract() external view returns (address);


    function getLiquidityBridgeContract() external view returns (address);


    function getLiquidityMiningContract() external view returns (address);


    function getClaimingRegistryContract() external view returns (address);


    function getPolicyRegistryContract() external view returns (address);


    function getLiquidityRegistryContract() external view returns (address);


    function getClaimVotingContract() external view returns (address);


    function getReinsurancePoolContract() external view returns (address);


    function getLeveragePortfolioViewContract() external view returns (address);


    function getCapitalPoolContract() external view returns (address);


    function getPolicyBookAdminContract() external view returns (address);


    function getPolicyQuoteContract() external view returns (address);


    function getLegacyBMIStakingContract() external view returns (address);


    function getBMIStakingContract() external view returns (address);


    function getSTKBMIContract() external view returns (address);


    function getVBMIContract() external view returns (address);


    function getLegacyLiquidityMiningStakingContract() external view returns (address);


    function getLiquidityMiningStakingETHContract() external view returns (address);


    function getLiquidityMiningStakingUSDTContract() external view returns (address);


    function getReputationSystemContract() external view returns (address);


    function getAaveProtocolContract() external view returns (address);


    function getAaveLendPoolAddressProvdierContract() external view returns (address);


    function getAaveATokenContract() external view returns (address);


    function getCompoundProtocolContract() external view returns (address);


    function getCompoundCTokenContract() external view returns (address);


    function getCompoundComptrollerContract() external view returns (address);


    function getYearnProtocolContract() external view returns (address);


    function getYearnVaultContract() external view returns (address);


    function getYieldGeneratorContract() external view returns (address);


    function getShieldMiningContract() external view returns (address);

}// MIT
pragma solidity ^0.7.4;


abstract contract AbstractDependant {
    bytes32 private constant _INJECTOR_SLOT =
        0xd6b8f2e074594ceb05d47c27386969754b6ad0c15e5eb8f691399cd0be980e76;

    modifier onlyInjectorOrZero() {
        address _injector = injector();

        require(_injector == address(0) || _injector == msg.sender, "Dependant: Not an injector");
        _;
    }

    function setInjector(address _injector) external onlyInjectorOrZero {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            sstore(slot, _injector)
        }
    }

    function setDependencies(IContractsRegistry) external virtual;

    function injector() public view returns (address _injector) {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            _injector := sload(slot)
        }
    }
}// MIT
pragma solidity ^0.7.4;


contract Upgrader {

    address private immutable _owner;

    modifier onlyOwner() {

        require(_owner == msg.sender, "DependencyInjector: Not an owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function upgrade(address what, address to) external onlyOwner {

        TransparentUpgradeableProxy(payable(what)).upgradeTo(to);
    }

    function upgradeAndCall(
        address what,
        address to,
        bytes calldata data
    ) external onlyOwner {

        TransparentUpgradeableProxy(payable(what)).upgradeToAndCall(to, data);
    }

    function getImplementation(address what) external onlyOwner returns (address) {

        return TransparentUpgradeableProxy(payable(what)).implementation();
    }
}// MIT
pragma solidity ^0.7.4;





contract ContractsRegistry is IContractsRegistry, AccessControlUpgradeable {

    Upgrader internal upgrader;

    mapping(bytes32 => address) private _contracts;
    mapping(address => bool) private _isProxy;

    bytes32 public constant REGISTRY_ADMIN_ROLE = keccak256("REGISTRY_ADMIN_ROLE");

    bytes32 public constant UNISWAP_ROUTER_NAME = keccak256("UNI_ROUTER");
    bytes32 public constant UNISWAP_BMI_TO_ETH_PAIR_NAME = keccak256("UNI_BMI_ETH_PAIR");
    bytes32 public constant UNISWAP_BMI_TO_USDT_PAIR_NAME = keccak256("UNI_BMI_USDT_PAIR");

    bytes32 public constant SUSHISWAP_ROUTER_NAME = keccak256("SUSHI_ROUTER");
    bytes32 public constant SUSHISWAP_BMI_TO_ETH_PAIR_NAME = keccak256("SUSHI_BMI_ETH_PAIR");
    bytes32 public constant SUSHISWAP_BMI_TO_USDT_PAIR_NAME = keccak256("SUSHI_BMI_USDT_PAIR");

    bytes32 public constant SUSHI_SWAP_MASTER_CHEF_V2_NAME =
        keccak256("SUSHI_SWAP_MASTER_CHEF_V2");

    bytes32 public constant PRICE_FEED_NAME = keccak256("PRICE_FEED");

    bytes32 public constant POLICY_BOOK_REGISTRY_NAME = keccak256("BOOK_REGISTRY");
    bytes32 public constant POLICY_BOOK_FABRIC_NAME = keccak256("FABRIC");
    bytes32 public constant POLICY_BOOK_ADMIN_NAME = keccak256("POLICY_BOOK_ADMIN");

    bytes32 public constant LEGACY_BMI_STAKING_NAME = keccak256("LEG_BMI_STAKING");
    bytes32 public constant BMI_STAKING_NAME = keccak256("BMI_STAKING");

    bytes32 public constant BMI_COVER_STAKING_NAME = keccak256("BMI_COVER_STAKING");
    bytes32 public constant BMI_COVER_STAKING_VIEW_NAME = keccak256("BMI_COVER_STAKING_VIEW");
    bytes32 public constant LEGACY_REWARDS_GENERATOR_NAME = keccak256("LEG_REWARDS_GENERATOR");
    bytes32 public constant REWARDS_GENERATOR_NAME = keccak256("REWARDS_GENERATOR");

    bytes32 public constant WETH_NAME = keccak256("WETH");
    bytes32 public constant USDT_NAME = keccak256("USDT");
    bytes32 public constant BMI_NAME = keccak256("BMI");
    bytes32 public constant STKBMI_NAME = keccak256("STK_BMI");
    bytes32 public constant VBMI_NAME = keccak256("VBMI");

    bytes32 public constant BMI_UTILITY_NFT_NAME = keccak256("BMI_UTILITY_NFT");
    bytes32 public constant NFT_STAKING_NAME = keccak256("NFT_STAKING");
    bytes32 public constant LIQUIDITY_MINING_NAME = keccak256("LIQ_MINING");

    bytes32 public constant LEGACY_LIQUIDITY_MINING_STAKING_NAME =
        keccak256("LEG_LIQ_MINING_STAKING");
    bytes32 public constant LIQUIDITY_MINING_STAKING_ETH_NAME = keccak256("LIQ_MINING_STAKING");
    bytes32 public constant LIQUIDITY_MINING_STAKING_USDT_NAME =
        keccak256("LIQ_MINING_STAKING_USDT");

    bytes32 public constant LIQUIDITY_REGISTRY_NAME = keccak256("LIQUIDITY_REGISTRY");
    bytes32 public constant POLICY_REGISTRY_NAME = keccak256("POLICY_REGISTRY");
    bytes32 public constant POLICY_QUOTE_NAME = keccak256("POLICY_QUOTE");

    bytes32 public constant CLAIMING_REGISTRY_NAME = keccak256("CLAIMING_REGISTRY");
    bytes32 public constant CLAIM_VOTING_NAME = keccak256("CLAIM_VOTING");
    bytes32 public constant REPUTATION_SYSTEM_NAME = keccak256("REPUTATION_SYSTEM");
    bytes32 public constant REINSURANCE_POOL_NAME = keccak256("REINSURANCE_POOL");
    bytes32 public constant LEVERAGE_PORTFOLIO_VIEW_NAME = keccak256("LEVERAGE_PORTFOLIO_VIEW");
    bytes32 public constant CAPITAL_POOL_NAME = keccak256("CAPITAL_POOL");
    bytes32 public constant YIELD_GENERATOR_NAME = keccak256("YIELD_GENERATOR");

    bytes32 public constant AAVE_PROTOCOL_NAME = keccak256("AAVE_PROTOCOL");
    bytes32 public constant AAVE_LENDPOOL_ADDRESS_PROVIDER_NAME =
        keccak256("AAVE_LENDPOOL_ADDRESS_PROVIDER_NAME");
    bytes32 public constant AAVE_ATOKEN_NAME = keccak256("AAVE_ATOKEN");

    bytes32 public constant COMPOUND_PROTOCOL_NAME = keccak256("COMPOUND_PROTOCOL");
    bytes32 public constant COMPOUND_CTOKEN_NAME = keccak256("COMPOUND_CTOKEN");
    bytes32 public constant COMPOUND_COMPTROLLER_NAME = keccak256("COMPOUND_COMPTROLLER");

    bytes32 public constant YEARN_PROTOCOL_NAME = keccak256("YEARN_PROTOCOL");
    bytes32 public constant YEARN_VAULT_NAME = keccak256("YEARN_VAULT");

    bytes32 public constant SHIELD_MINING_NAME = keccak256("SHIELD_MINING");
    bytes32 public constant LIQUIDITY_BRIDGE_NAME = keccak256("LIQUIDITY_BRIDGE");

    modifier onlyAdmin() {

        require(
            hasRole(REGISTRY_ADMIN_ROLE, msg.sender),
            "ContractsRegistry: Caller is not an admin"
        );
        _;
    }

    function __ContractsRegistry_init() external initializer {

        __AccessControl_init();

        _setupRole(REGISTRY_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(REGISTRY_ADMIN_ROLE, REGISTRY_ADMIN_ROLE);

        upgrader = new Upgrader();
    }

    function getUniswapRouterContract() external view override returns (address) {

        return getContract(UNISWAP_ROUTER_NAME);
    }

    function getUniswapBMIToETHPairContract() external view override returns (address) {

        return getContract(UNISWAP_BMI_TO_ETH_PAIR_NAME);
    }

    function getUniswapBMIToUSDTPairContract() external view override returns (address) {

        return getContract(UNISWAP_BMI_TO_USDT_PAIR_NAME);
    }

    function getSushiswapRouterContract() external view override returns (address) {

        return getContract(SUSHISWAP_ROUTER_NAME);
    }

    function getSushiswapBMIToETHPairContract() external view override returns (address) {

        return getContract(SUSHISWAP_BMI_TO_ETH_PAIR_NAME);
    }

    function getSushiswapBMIToUSDTPairContract() external view override returns (address) {

        return getContract(SUSHISWAP_BMI_TO_USDT_PAIR_NAME);
    }

    function getSushiSwapMasterChefV2Contract() external view override returns (address) {

        return getContract(SUSHI_SWAP_MASTER_CHEF_V2_NAME);
    }

    function getWETHContract() external view override returns (address) {

        return getContract(WETH_NAME);
    }

    function getUSDTContract() external view override returns (address) {

        return getContract(USDT_NAME);
    }

    function getBMIContract() external view override returns (address) {

        return getContract(BMI_NAME);
    }

    function getPriceFeedContract() external view override returns (address) {

        return getContract(PRICE_FEED_NAME);
    }

    function getPolicyBookRegistryContract() external view override returns (address) {

        return getContract(POLICY_BOOK_REGISTRY_NAME);
    }

    function getPolicyBookFabricContract() external view override returns (address) {

        return getContract(POLICY_BOOK_FABRIC_NAME);
    }

    function getBMICoverStakingContract() external view override returns (address) {

        return getContract(BMI_COVER_STAKING_NAME);
    }

    function getBMICoverStakingViewContract() external view override returns (address) {

        return getContract(BMI_COVER_STAKING_VIEW_NAME);
    }

    function getLegacyRewardsGeneratorContract() external view override returns (address) {

        return getContract(LEGACY_REWARDS_GENERATOR_NAME);
    }

    function getRewardsGeneratorContract() external view override returns (address) {

        return getContract(REWARDS_GENERATOR_NAME);
    }

    function getBMIUtilityNFTContract() external view override returns (address) {

        return getContract(BMI_UTILITY_NFT_NAME);
    }

    function getNFTStakingContract() external view override returns (address) {

        return getContract(NFT_STAKING_NAME);
    }

    function getLiquidityBridgeContract() external view override returns (address) {

        return getContract(LIQUIDITY_BRIDGE_NAME);
    }

    function getLiquidityMiningContract() external view override returns (address) {

        return getContract(LIQUIDITY_MINING_NAME);
    }

    function getClaimingRegistryContract() external view override returns (address) {

        return getContract(CLAIMING_REGISTRY_NAME);
    }

    function getPolicyRegistryContract() external view override returns (address) {

        return getContract(POLICY_REGISTRY_NAME);
    }

    function getLiquidityRegistryContract() external view override returns (address) {

        return getContract(LIQUIDITY_REGISTRY_NAME);
    }

    function getClaimVotingContract() external view override returns (address) {

        return getContract(CLAIM_VOTING_NAME);
    }

    function getReputationSystemContract() external view override returns (address) {

        return getContract(REPUTATION_SYSTEM_NAME);
    }

    function getReinsurancePoolContract() external view override returns (address) {

        return getContract(REINSURANCE_POOL_NAME);
    }

    function getLeveragePortfolioViewContract() external view override returns (address) {

        return getContract(LEVERAGE_PORTFOLIO_VIEW_NAME);
    }

    function getYieldGeneratorContract() external view override returns (address) {

        return getContract(YIELD_GENERATOR_NAME);
    }

    function getCapitalPoolContract() external view override returns (address) {

        return getContract(CAPITAL_POOL_NAME);
    }

    function getPolicyBookAdminContract() external view override returns (address) {

        return getContract(POLICY_BOOK_ADMIN_NAME);
    }

    function getPolicyQuoteContract() external view override returns (address) {

        return getContract(POLICY_QUOTE_NAME);
    }

    function getLegacyBMIStakingContract() external view override returns (address) {

        return getContract(LEGACY_BMI_STAKING_NAME);
    }

    function getBMIStakingContract() external view override returns (address) {

        return getContract(BMI_STAKING_NAME);
    }

    function getSTKBMIContract() external view override returns (address) {

        return getContract(STKBMI_NAME);
    }

    function getLegacyLiquidityMiningStakingContract() external view override returns (address) {

        return getContract(LEGACY_LIQUIDITY_MINING_STAKING_NAME);
    }

    function getLiquidityMiningStakingETHContract() external view override returns (address) {

        return getContract(LIQUIDITY_MINING_STAKING_ETH_NAME);
    }

    function getLiquidityMiningStakingUSDTContract() external view override returns (address) {

        return getContract(LIQUIDITY_MINING_STAKING_USDT_NAME);
    }

    function getVBMIContract() external view override returns (address) {

        return getContract(VBMI_NAME);
    }

    function getAaveProtocolContract() external view override returns (address) {

        return getContract(AAVE_PROTOCOL_NAME);
    }

    function getAaveLendPoolAddressProvdierContract() external view override returns (address) {

        return getContract(AAVE_LENDPOOL_ADDRESS_PROVIDER_NAME);
    }

    function getAaveATokenContract() external view override returns (address) {

        return getContract(AAVE_ATOKEN_NAME);
    }

    function getCompoundProtocolContract() external view override returns (address) {

        return getContract(COMPOUND_PROTOCOL_NAME);
    }

    function getCompoundCTokenContract() external view override returns (address) {

        return getContract(COMPOUND_CTOKEN_NAME);
    }

    function getCompoundComptrollerContract() external view override returns (address) {

        return getContract(COMPOUND_COMPTROLLER_NAME);
    }

    function getYearnProtocolContract() external view override returns (address) {

        return getContract(YEARN_PROTOCOL_NAME);
    }

    function getYearnVaultContract() external view override returns (address) {

        return getContract(YEARN_VAULT_NAME);
    }

    function getShieldMiningContract() external view override returns (address) {

        return getContract(SHIELD_MINING_NAME);
    }

    function getContract(bytes32 name) public view returns (address) {

        require(_contracts[name] != address(0), "CR.getContract: This mapping doesn't exist");

        return _contracts[name];
    }

    function hasContract(bytes32 name) external view returns (bool) {

        return _contracts[name] != address(0);
    }

    function injectDependencies(bytes32 name) external onlyAdmin {

        address contractAddress = _contracts[name];

        require(
            contractAddress != address(0),
            "CR.injectDependencies: This mapping doesn't exist"
        );

        AbstractDependant dependant = AbstractDependant(contractAddress);

        if (dependant.injector() == address(0)) {
            dependant.setInjector(address(this));
        }

        dependant.setDependencies(this);
    }

    function getUpgrader() external view returns (address) {

        require(address(upgrader) != address(0), "ContractsRegistry: Bad upgrader");

        return address(upgrader);
    }

    function getImplementation(bytes32 name) external returns (address) {

        address contractProxy = _contracts[name];

        require(contractProxy != address(0), "CR.getImplementation: This mapping doesn't exist");
        require(_isProxy[contractProxy], "ContractsRegistry: Not a proxy contract");

        return upgrader.getImplementation(contractProxy);
    }

    function upgradeContract(bytes32 name, address newImplementation) external onlyAdmin {

        _upgradeContract(name, newImplementation, "");
    }

    function upgradeContractAndCall(
        bytes32 name,
        address newImplementation,
        string calldata functionSignature
    ) external onlyAdmin {

        _upgradeContract(name, newImplementation, functionSignature);
    }

    function _upgradeContract(
        bytes32 name,
        address newImplementation,
        string memory functionSignature
    ) internal {

        address contractToUpgrade = _contracts[name];

        require(
            contractToUpgrade != address(0),
            "CR._upgradeContract: This mapping doesn't exist"
        );
        require(_isProxy[contractToUpgrade], "ContractsRegistry: Not a proxy contract");

        if (bytes(functionSignature).length > 0) {
            upgrader.upgradeAndCall(
                contractToUpgrade,
                newImplementation,
                abi.encodeWithSignature(functionSignature)
            );
        } else {
            upgrader.upgrade(contractToUpgrade, newImplementation);
        }
    }

    function addContract(bytes32 name, address contractAddress) external onlyAdmin {

        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        _contracts[name] = contractAddress;
    }

    function addProxyContract(bytes32 name, address contractAddress) external onlyAdmin {

        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(contractAddress, address(upgrader), "");

        _contracts[name] = address(proxy);
        _isProxy[address(proxy)] = true;
    }

    function justAddProxyContract(bytes32 name, address contractAddress) external onlyAdmin {

        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        _contracts[name] = contractAddress;
        _isProxy[contractAddress] = true;
    }

    function deleteContract(bytes32 name) external onlyAdmin {

        require(_contracts[name] != address(0), "CR.deleteContract: This mapping doesn't exist");

        delete _isProxy[_contracts[name]];
        delete _contracts[name];
    }
}