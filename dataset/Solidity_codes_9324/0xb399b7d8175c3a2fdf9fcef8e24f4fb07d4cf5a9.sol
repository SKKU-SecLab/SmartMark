
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();
    }
}// MIT

pragma solidity ^0.8.0;


contract TransparentUpgradeableProxy is ERC1967Proxy {

    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    modifier ifAdmin() {

        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _getAdmin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        _changeAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeToAndCall(newImplementation, data, true);
    }

    function _admin() internal view virtual returns (address) {

        return _getAdmin();
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// MIT

pragma solidity ^0.8.0;


contract ProxyAdmin is Ownable {

    function getProxyImplementation(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {

        proxy.changeAdmin(newAdmin);
    }

    function upgrade(TransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {

        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(
        TransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory data
    ) public payable virtual onlyOwner {

        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}// Apache-2.0
pragma solidity ^0.8.2;
pragma experimental ABIEncoderV2;


interface IBridge {

    struct TONEvent {
        uint64 eventTransactionLt;
        uint32 eventTimestamp;
        bytes eventData;
        int8 configurationWid;
        uint256 configurationAddress;
        int8 eventContractWid;
        uint256 eventContractAddress;
        address proxy;
        uint32 round;
    }

    struct Round {
        uint32 end;
        uint32 ttl;
        uint32 relays;
        uint32 requiredSignatures;
    }

    struct TONAddress {
        int8 wid;
        uint256 addr;
    }

    function updateMinimumRequiredSignatures(uint32 _minimumRequiredSignatures) external;

    function updateRoundRelaysConfiguration(TONAddress calldata _roundRelaysConfiguration) external;

    function updateRoundTTL(uint32 _roundTTL) external;


    function isRelay(
        uint32 round,
        address candidate
    ) external view returns(bool);


    function isBanned(
        address candidate
    ) external view returns(bool);


    function isRoundRotten(
        uint32 round
    ) external view returns(bool);


    function verifySignedTonEvent(
        bytes memory payload,
        bytes[] memory signatures
    ) external view returns(uint32);


    function setRoundRelays(
        bytes calldata payload,
        bytes[] calldata signatures
    ) external;


    function forceRoundRelays(
        uint160[] calldata _relays,
        uint32 roundEnd
    ) external;


    function banRelays(
        address[] calldata _relays
    ) external;


    function unbanRelays(
        address[] calldata _relays
    ) external;


    function pause() external;

    function unpause() external;


    function setRoundSubmitter(address _roundSubmitter) external;


    event EmergencyShutdown(bool active);

    event UpdateMinimumRequiredSignatures(uint32 value);
    event UpdateRoundTTL(uint32 value);
    event UpdateRoundRelaysConfiguration(TONAddress configuration);
    event UpdateRoundSubmitter(address _roundSubmitter);

    event NewRound(uint32 indexed round, Round meta);
    event RoundRelay(uint32 indexed round, address indexed relay);
    event BanRelay(address indexed relay, bool status);
}// Apache-2.0
pragma solidity ^0.8.2;

interface IRegistry {

    event NewVaultRelease(
        uint256 indexed vault_release_id,
        address template,
        string api_version
    );

    event NewWrapperRelease(
        uint256 indexed wrapper_release_id,
        address template,
        string api_version
    );

    event NewVault(
        address indexed token,
        uint256 indexed vault_id,
        address vault,
        string api_version
    );

    event NewExperimentalVault(
        address indexed token,
        address indexed deployer,
        address vault,
        string api_version
    );

    event VaultTagged(address vault, string tag);

    event UpdateVaultWrapper(address indexed vaultWrapper);
}// Apache-2.0
pragma solidity ^0.8.2;


interface IVault {

    struct TONAddress {
        int128 wid;
        uint256 addr;
    }

    struct PendingWithdrawalId {
        address recipient;
        uint256 id;
    }

    function saveWithdraw(
        bytes32 payloadId,
        address recipient,
        uint256 amount,
        uint256 bounty
    ) external;


    function deposit(
        address sender,
        TONAddress calldata recipient,
        uint256 _amount,
        PendingWithdrawalId calldata pendingWithdrawalId,
        bool sendTransferToTon
    ) external;


    function configuration() external view returns(TONAddress memory _configuration);

    function bridge() external view returns(address);

    function apiVersion() external view returns(string memory api_version);


    function initialize(
        address _token,
        address _governance,
        address _bridge,
        address _wrapper,
        address guardian,
        address management,
        uint256 targetDecimals
    ) external;


    function governance() external view returns(address);

    function token() external view returns(address);

    function wrapper() external view returns(address);

}// Apache-2.0
pragma solidity ^0.8.2;


interface IVaultWrapper {

    function initialize(address _vault) external;

    function apiVersion() external view returns(string memory);

}// Apache-2.0
pragma solidity ^0.8.2;




contract Registry is Ownable, IRegistry {

    address constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

    uint256 public numVaultReleases;
    mapping(uint256 => address) public vaultReleases;
    uint256 public numWrapperReleases;
    mapping(uint256 => address) public wrapperReleases;
    mapping(address => uint256) public numVaults;
    mapping(address => mapping(uint256 => address)) vaults;

    mapping(uint256 => address) tokens;
    uint256 public numTokens;
    mapping(address => bool) public isRegistered;

    address public bridge;
    address public proxyAdmin;

    mapping(address => string) public tags;
    mapping(address => bool) public banksy;

    function compareStrings(
        string memory a,
        string memory b
    ) internal pure returns (bool) {

        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    constructor(
        address _bridge,
        address _proxyAdmin
    ) {
        bridge = _bridge;
        proxyAdmin = _proxyAdmin;
    }

    function setBridge(
        address _bridge
    ) external onlyOwner {

        bridge = _bridge;
    }

    function setProxyAdmin(
        address _proxyAdmin
    ) external onlyOwner {

        proxyAdmin = _proxyAdmin;
    }

    function latestVaultRelease()
        external
        view
    returns(
        string memory api_version
    ) {

        return IVault(vaultReleases[numVaultReleases - 1]).apiVersion();
    }

    function latestWrapperRelease()
        external
        view
    returns (
        string memory api_version
    ) {

        return IVaultWrapper(vaultReleases[numVaultReleases - 1]).apiVersion();
    }

    function latestVault(
        address token
    )
        external
        view
    returns(
        address
    ) {

        return vaults[token][numVaults[token] - 1];
    }

    function newVaultRelease(
        address vault
    ) external onlyOwner {

        uint256 vault_release_id = numVaultReleases;

        if (vault_release_id > 0) {
            require(
                !compareStrings(
                    IVault(vaultReleases[vault_release_id - 1]).apiVersion(),
                    IVault(vault).apiVersion()
                ),
                "Registry: new vault release should have different api version"
            );
        }

        vaultReleases[vault_release_id] = vault;
        numVaultReleases = vault_release_id + 1;

        emit NewVaultRelease(vault_release_id, vault, IVault(vault).apiVersion());
    }

    function newWrapperRelease(
        address wrapper
    ) external onlyOwner {

        uint256 wrapper_release_id = numWrapperReleases;

        if (wrapper_release_id > 0) {
            require(
                !compareStrings(
                IVaultWrapper(wrapperReleases[wrapper_release_id - 1]).apiVersion(),
                IVaultWrapper(wrapper).apiVersion()
            ),
                "Registry: new wrapper release should have different api version"
            );
        }

        wrapperReleases[wrapper_release_id] = wrapper;
        numWrapperReleases = wrapper_release_id + 1;

        emit NewWrapperRelease(wrapper_release_id, wrapper, IVaultWrapper(wrapper).apiVersion());
    }

    function _newProxyVault(
        address token,
        address governance,
        address guardian,
        uint256 targetDecimals,
        uint256 vault_release_target,
        uint256 wrapper_release_target
    ) internal returns(address) {

        address vault_release = vaultReleases[vault_release_target];
        address wrapper_release = wrapperReleases[wrapper_release_target];

        require(vault_release != ZERO_ADDRESS, "Registry: vault release target is wrong");
        require(wrapper_release != ZERO_ADDRESS, "Registry: wrapper release target is wrong");

        TransparentUpgradeableProxy vault = new TransparentUpgradeableProxy(
            vault_release,
            proxyAdmin,
            ""
        );

        TransparentUpgradeableProxy wrapper = new TransparentUpgradeableProxy(
            wrapper_release,
            proxyAdmin,
            ""
        );

        IVaultWrapper(address(wrapper)).initialize(
            address(vault)
        );

        IVault(address(vault)).initialize(
            token,
            governance,
            bridge,
            address(wrapper),
            guardian,
            ZERO_ADDRESS,
            targetDecimals
        );

        return address(vault);
    }

    function _registerVault(
        address token,
        address vault
    ) internal {

        uint256 vault_id = numVaults[token];

        if (vault_id > 0) {
            require(
                !compareStrings(
                    IVault(vaults[token][vault_id - 1]).apiVersion(),
                    IVault(vault).apiVersion()
                ),
                "Registry: new vault should have different api version"
            );
        }

        vaults[token][vault_id] = vault;
        numVaults[token] = vault_id + 1;

        if (!isRegistered[token]) {
            isRegistered[token] = true;
            tokens[numTokens] = token;
            numTokens += 1;
        }

        emit NewVault(token, vault_id, vault, IVault(vault).apiVersion());
    }

    function newVault(
        address token,
        address guardian,
        uint256 targetDecimals,
        uint256 vaultReleaseDelta,
        uint256 wrapperReleaseDelta
    ) external onlyOwner returns (address) {

        uint256 vault_release_target = numVaultReleases - 1 - vaultReleaseDelta;
        uint256 wrapper_release_target = numWrapperReleases - 1 - wrapperReleaseDelta;

        address vault = _newProxyVault(
            token,
            msg.sender,
            guardian,
            targetDecimals,
            vault_release_target,
            wrapper_release_target
        );

        _registerVault(token, vault);

        return vault;
    }

    function newExperimentalVault(
        address token,
        address governance,
        address guardian,
        uint256 targetDecimals,
        uint256 vaultReleaseDelta,
        uint256 wrapperReleaseDelta
    ) external returns(address) {

        uint256 vault_release_target = numVaultReleases - 1 - vaultReleaseDelta;
        uint256 wrapper_release_target = numWrapperReleases - 1 - wrapperReleaseDelta;

        address vault = _newProxyVault(
            token,
            governance,
            guardian,
            targetDecimals,
            vault_release_target,
            wrapper_release_target
        );

        emit NewExperimentalVault(
            token,
            msg.sender,
            vault,
            IVault(vault).apiVersion()
        );

        return vault;
    }

    function endorseVault(
        address vault,
        uint256 vaultReleaseDelta,
        uint256 wrapperReleaseDelta
    ) external onlyOwner {

        require(
            IVault(vault).governance() == msg.sender,
            "Registry: wrong vault governance"
        );

        uint256 vault_release_target = numVaultReleases - 1 - vaultReleaseDelta;
        string memory vault_api_version = IVault(vaultReleases[vault_release_target]).apiVersion();

        require(
            compareStrings(IVault(vault).apiVersion(), vault_api_version),
            "Registry: vault should have same api version as specified release"
        );

        uint256 wrapper_release_target = numWrapperReleases - 1 - wrapperReleaseDelta;
        string memory wrapper_api_version = IVaultWrapper(wrapperReleases[wrapper_release_target]).apiVersion();

        address wrapper = IVault(vault).wrapper();

        require(
            compareStrings(IVaultWrapper(wrapper).apiVersion(), wrapper_api_version),
            "Registry: wrapper should have same api version as specified release"
        );

        _registerVault(IVault(vault).token(), vault);
    }

    function setBanksy(
        address tagger,
        bool allowed
    ) external onlyOwner {

        banksy[tagger] = allowed;
    }

    function tagVault(
        address vault,
        string memory tag
    ) external {

        if (msg.sender != owner()) {
            require(
                banksy[msg.sender],
                "Registry: only owner or banksy are allowed to tag"
            );
        }

        tags[vault] = tag;
        emit VaultTagged(vault, tag);
    }
}