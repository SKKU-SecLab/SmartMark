


pragma solidity 0.8.9;

enum AuthorizationState {
    Unused,
    Used,
    Canceled
}

struct AppStorage {
    address owner;
    address pauser;
    bool paused;
    address blacklister;
    mapping(address => bool) blacklisted;
    string name;
    string symbol;
    uint8 decimals;
    string currency;
    address masterMinter;
    bool initialized;
    bool initializing;
    bool initializedV2;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    uint256 totalSupply;
    mapping(address => bool) minters;
    mapping(address => uint256) minterAllowed;
    address rescuer;
    bytes32 domainSeparator;
    mapping(address => mapping(bytes32 => AuthorizationState)) authorizationStates;
    mapping(address => uint256) nonces;
}

library LibAppStorage {

    function diamondStorage() internal pure returns (AppStorage storage ds) {

        assembly {
            ds.slot := 0
        }
    }
}




library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



library LibContext {

    function _msgSender() internal view returns (address sender) {

        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }
}



library LibOwnable {

    function _requireOnlyOwner() internal view {

        require(
            LibContext._msgSender() == LibAppStorage.diamondStorage().owner,
            "Ownable: caller is not the owner"
        );
    }
}



contract Ownable {

    event OwnershipTransferred(address previousOwner, address newOwner);

    constructor() {
        setOwner(msg.sender);
    }

    function owner() external view returns (address) {

        return LibAppStorage.diamondStorage().owner;
    }

    function setOwner(address newOwner) internal {

        LibAppStorage.diamondStorage().owner = newOwner;
    }

    modifier onlyOwner() {

        LibOwnable._requireOnlyOwner();
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(LibAppStorage.diamondStorage().owner, newOwner);
        setOwner(newOwner);
    }
}



library LibBlacklistable {

    function _requireBlacklister() internal view {

        require(
            msg.sender == LibAppStorage.diamondStorage().blacklister,
            "Blacklistable: caller is not the blacklister"
        );
    }

    function _requireNotBlacklisted(address account) internal view {

        require(
            !LibAppStorage.diamondStorage().blacklisted[account],
            "Blacklistable: account is blacklisted"
        );
    }
}



contract Blacklistable is Ownable {

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event BlacklisterChanged(address indexed newBlacklister);

    modifier onlyBlacklister() {

        LibBlacklistable._requireBlacklister();
        _;
    }

    modifier notBlacklisted(address account) {

        LibBlacklistable._requireNotBlacklisted(account);
        _;
    }

    function blacklister() external view returns (address) {

        return LibAppStorage.diamondStorage().blacklister;
    }

    function isBlacklisted(address account) external view returns (bool) {

        return LibAppStorage.diamondStorage().blacklisted[account];
    }

    function blacklist(address account) external onlyBlacklister {

        LibAppStorage.diamondStorage().blacklisted[account] = true;
        emit Blacklisted(account);
    }

    function unBlacklist(address account) external onlyBlacklister {

        LibAppStorage.diamondStorage().blacklisted[account] = false;
        emit UnBlacklisted(account);
    }

    function updateBlacklister(address newBlacklister) external onlyOwner {

        require(newBlacklister != address(0), "Blacklistable: new blacklister is the zero address");
        AppStorage storage appStorage = LibAppStorage.diamondStorage();
        appStorage.blacklister = newBlacklister;
        emit BlacklisterChanged(appStorage.blacklister);
    }
}



interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}







interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}





library LibERC20 {

    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _approve(
        address owner_,
        address spender,
        uint256 value
    ) internal {

        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        AppStorage storage appStorage = LibAppStorage.diamondStorage();
        appStorage.allowed[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }

    function _increaseAllowance(
        address owner,
        address spender,
        uint256 increment
    ) internal {

        AppStorage storage appStorage = LibAppStorage.diamondStorage();
        uint256 currentAllowance = appStorage.allowed[owner][spender];
        _approve(owner, spender, currentAllowance.add(increment));
    }

    function _decreaseAllowance(
        address owner,
        address spender,
        uint256 decrement
    ) internal {

        AppStorage storage appStorage = LibAppStorage.diamondStorage();
        _approve(
            owner,
            spender,
            appStorage.allowed[owner][spender].sub(
                decrement,
                "ERC20: decreased allowance below zero"
            )
        );
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        AppStorage storage appStorage = LibAppStorage.diamondStorage();
        require(value <= appStorage.balances[from], "ERC20: transfer amount exceeds balance");

        appStorage.balances[from] = appStorage.balances[from].sub(value);
        appStorage.balances[to] = appStorage.balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 value
    ) internal returns (bool) {

        _transfer(from, to, value);

        AppStorage storage appStorage = LibAppStorage.diamondStorage();
        address msgSender = LibContext._msgSender();
        uint256 currentAllowance = appStorage.allowed[from][msgSender];
        require(value <= currentAllowance, "ERC20: transfer amount exceeds allowance");
        appStorage.allowed[from][msgSender] = currentAllowance.sub(value);
        return true;
    }
}



library LibPausable {

    function _requireNotPaused() internal view {

        require(!LibAppStorage.diamondStorage().paused, "Pausable: paused");
    }

    function _requireOnlyPauser() internal view {

        require(
            LibContext._msgSender() == LibAppStorage.diamondStorage().pauser,
            "Pausable: caller is not the pauser"
        );
    }
}



contract Pausable is Ownable {

    event Pause();
    event Unpause();
    event PauserChanged(address indexed newAddress);

    modifier whenNotPaused() {

        LibPausable._requireNotPaused();
        _;
    }

    modifier onlyPauser() {

        LibPausable._requireOnlyPauser();
        _;
    }

    function pause() external onlyPauser {

        LibAppStorage.diamondStorage().paused = true;
        emit Pause();
    }

    function paused() external view returns (bool) {

        return LibAppStorage.diamondStorage().paused;
    }

    function unpause() external onlyPauser {

        LibAppStorage.diamondStorage().paused = false;
        emit Unpause();
    }

    function pauser() external view returns (address) {

        return LibAppStorage.diamondStorage().pauser;
    }

    function updatePauser(address newPauser) external onlyOwner {

        require(newPauser != address(0), "Pausable: new pauser is the zero address");
        LibAppStorage.diamondStorage().pauser = newPauser;
        emit PauserChanged(LibAppStorage.diamondStorage().pauser);
    }
}



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

        (bool success, ) = recipient.call{ value: amount }("");
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

        return
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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
}



library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



contract Rescuable is Ownable {

    using SafeERC20 for IERC20;

    event RescuerChanged(address indexed newRescuer);

    function rescuer() external view returns (address) {

        return LibAppStorage.diamondStorage().rescuer;
    }

    modifier onlyRescuer() {

        _requireOnlyRescuer();
        _;
    }

    function _requireOnlyRescuer() internal view {

        require(
            msg.sender == LibAppStorage.diamondStorage().rescuer,
            "Rescuable: caller is not the rescuer"
        );
    }

    function rescueERC20(
        IERC20 tokenContract,
        address to,
        uint256 amount
    ) external onlyRescuer {

        tokenContract.safeTransfer(to, amount);
    }

    function updateRescuer(address newRescuer) external onlyOwner {

        require(newRescuer != address(0), "Rescuable: new rescuer is the zero address");
        LibAppStorage.diamondStorage().rescuer = newRescuer;
        emit RescuerChanged(newRescuer);
    }
}



interface IBeacon {

    function implementation() external view returns (address);

}



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
}



abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT =
        0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(
            Address.isContract(newImplementation),
            "ERC1967: new implementation is not a contract"
        );
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

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(
            _ROLLBACK_SLOT
        );
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(
                oldImplementation == _getImplementation(),
                "ERC1967Upgrade: upgrade breaks further upgrades"
            );
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

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

    bytes32 internal constant _BEACON_SLOT =
        0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

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
}



abstract contract UUPSUpgradeable is ERC1967Upgrade {
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data)
        external
        payable
        virtual
        onlyProxy
    {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
}



abstract contract BaseToken is
    UUPSUpgradeable,
    IERC165,
    IERC20,
    IERC20Metadata,
    Ownable,
    Pausable,
    Blacklistable,
    Rescuable
{
    using SafeMath for uint256;

    AppStorage internal appStorage;

    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);
    event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);
    event MinterRemoved(address indexed oldMinter);
    event MasterMinterChanged(address indexed newMasterMinter);

    function _msgSender() internal view virtual returns (address) {
        return LibContext._msgSender();
    }

    function _authorizeUpgrade(address) internal virtual override onlyOwner {
        this;
    }

    function implementation() external view returns (address) {
        return _getImplementation();
    }

    function name() external view returns (string memory) {
        return appStorage.name;
    }

    function symbol() external view returns (string memory) {
        return appStorage.symbol;
    }

    function decimals() external view returns (uint8) {
        return appStorage.decimals;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC20).interfaceId ||
            interfaceId == type(IERC20Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function _mint(address to, uint256 amount) internal returns (bool) {
        address msgSender = _msgSender();
        appStorage.totalSupply = appStorage.totalSupply.add(amount);
        appStorage.balances[to] = appStorage.balances[to].add(amount);
        emit Mint(msgSender, to, amount);
        emit Transfer(address(0), to, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return appStorage.allowed[tokenOwner][spender];
    }

    function totalSupply() external view override returns (uint256) {
        return appStorage.totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return appStorage.balances[account];
    }

    function approve(address spender, uint256 value)
        external
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(spender)
        returns (bool)
    {
        LibERC20._approve(_msgSender(), spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(from)
        notBlacklisted(to)
        returns (bool)
    {
        return LibERC20._transferFrom(from, to, value);
    }

    function transfer(address to, uint256 value)
        external
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(to)
        returns (bool)
    {
        LibERC20._transfer(_msgSender(), to, value);
        return true;
    }

    function _burn(uint256 amount) internal virtual {
        address msgSender = _msgSender();
        uint256 balance = appStorage.balances[msgSender];
        require(amount > 0, "BaseToken: burn amount not greater than 0");
        require(balance >= amount, "BaseToken: burn amount exceeds balance");

        appStorage.totalSupply = appStorage.totalSupply.sub(amount);
        appStorage.balances[msgSender] = balance.sub(amount);
    }
}



library LibECRecover {

    function recover(
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECRecover: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECRecover: invalid signature 'v' value");
        }

        address signer = ecrecover(digest, v, r, s);
        require(signer != address(0), "ECRecover: invalid signature");

        return signer;
    }
}



library LibEIP712 {

    function makeDomainSeparator(string memory name, string memory version)
        internal
        view
        returns (bytes32)
    {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return
            keccak256(
                abi.encode(
                    0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                    keccak256(bytes(name)),
                    keccak256(bytes(version)),
                    chainId,
                    address(this)
                )
            );
    }

    function recover(
        bytes32 domainSeparator,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes memory typeHashAndData
    ) internal pure returns (address) {

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, keccak256(typeHashAndData))
        );
        return LibECRecover.recover(digest, v, r, s);
    }
}



interface IERC1363 is IERC165, IERC20 {



    function transferAndCall(address to, uint256 value) external returns (bool);


    function transferAndCall(
        address to,
        uint256 value,
        bytes memory data
    ) external returns (bool);


    function transferFromAndCall(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function transferFromAndCall(
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) external returns (bool);


    function approveAndCall(address spender, uint256 value) external returns (bool);


    function approveAndCall(
        address spender,
        uint256 value,
        bytes memory data
    ) external returns (bool);

}



interface IERC1363Receiver {


    function onTransferReceived(
        address operator,
        address from,
        uint256 value,
        bytes memory data
    ) external returns (bytes4);

}



interface IERC1363Spender {


    function onApprovalReceived(
        address owner,
        uint256 value,
        bytes memory data
    ) external returns (bytes4);

}



library LibERC1363 {

    using Address for address;
    using SafeMath for uint256;

    bytes4 private constant INTERFACE_TRANSFER_AND_CALL = 0x4bbee2df;

    bytes4 private constant INTERFACE_APPROVE_AND_CALL = 0xfb9ec8ce;

    function _supportsInterface(bytes4 interfaceId) internal pure returns (bool) {

        return
            interfaceId == INTERFACE_TRANSFER_AND_CALL ||
            interfaceId == INTERFACE_APPROVE_AND_CALL ||
            interfaceId == type(IERC1363).interfaceId;
    }

    function _transferAndCall(
        address to,
        uint256 value,
        bytes memory data
    ) internal returns (bool) {

        address msgSender = LibContext._msgSender();
        LibERC20._transfer(msgSender, to, value);
        require(
            _checkAndCallTransfer(msgSender, to, value, data),
            "ERC1363: _checkAndCallTransfer reverts"
        );
        return true;
    }

    function _transferFromAndCall(
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal returns (bool) {

        LibERC20._transferFrom(from, to, value);
        require(
            _checkAndCallTransfer(from, to, value, data),
            "ERC1363: _checkAndCallTransfer reverts"
        );
        return true;
    }

    function _checkAndCallTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data
    ) internal returns (bool) {

        if (!recipient.isContract()) {
            return false;
        }
        bytes4 retval = IERC1363Receiver(recipient).onTransferReceived(
            LibContext._msgSender(),
            sender,
            amount,
            data
        );
        return (retval == IERC1363Receiver(recipient).onTransferReceived.selector);
    }

    function _approveAndCall(
        address spender,
        uint256 value,
        bytes memory data
    ) internal returns (bool) {

        LibERC20._approve(LibContext._msgSender(), spender, value);
        require(
            _checkAndCallApprove(spender, value, data),
            "ERC1363: _checkAndCallApprove reverts"
        );
        return true;
    }

    function _checkAndCallApprove(
        address spender,
        uint256 amount,
        bytes memory data
    ) internal returns (bool) {

        if (!spender.isContract()) {
            return false;
        }
        bytes4 retval = IERC1363Spender(spender).onApprovalReceived(
            LibContext._msgSender(),
            amount,
            data
        );
        return (retval == IERC1363Spender(spender).onApprovalReceived.selector);
    }
}



abstract contract ERC1363 is IERC1363, Pausable, Blacklistable {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return LibERC1363._supportsInterface(interfaceId);
    }

    function transferAndCall(address to, uint256 value)
        external
        whenNotPaused
        notBlacklisted(LibContext._msgSender())
        notBlacklisted(to)
        returns (bool)
    {
        return LibERC1363._transferAndCall(to, value, "");
    }

    function transferAndCall(
        address to,
        uint256 value,
        bytes memory data
    )
        external
        whenNotPaused
        notBlacklisted(LibContext._msgSender())
        notBlacklisted(to)
        returns (bool)
    {
        return LibERC1363._transferAndCall(to, value, data);
    }

    function transferFromAndCall(
        address from,
        address to,
        uint256 value
    )
        external
        whenNotPaused
        notBlacklisted(LibContext._msgSender())
        notBlacklisted(from)
        notBlacklisted(to)
        returns (bool)
    {
        return LibERC1363._transferFromAndCall(from, to, value, "");
    }

    function transferFromAndCall(
        address from,
        address to,
        uint256 value,
        bytes memory data
    )
        external
        whenNotPaused
        notBlacklisted(LibContext._msgSender())
        notBlacklisted(from)
        notBlacklisted(to)
        returns (bool)
    {
        return LibERC1363._transferFromAndCall(from, to, value, data);
    }

    function approveAndCall(address spender, uint256 value)
        external
        whenNotPaused
        notBlacklisted(LibContext._msgSender())
        notBlacklisted(spender)
        returns (bool)
    {
        return LibERC1363._approveAndCall(spender, value, "");
    }

    function approveAndCall(
        address spender,
        uint256 value,
        bytes memory data
    )
        external
        whenNotPaused
        notBlacklisted(LibContext._msgSender())
        notBlacklisted(spender)
        returns (bool)
    {
        return LibERC1363._approveAndCall(spender, value, data);
    }
}



bytes32 constant _TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;
bytes32 constant _APPROVE_WITH_AUTHORIZATION_TYPEHASH = 0x808c10407a796f3ef2c7ea38c0638ea9d2b8a1c63e3ca9e1f56ce84ae59df73c;
bytes32 constant _INCREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH = 0x424222bb050a1f7f14017232a5671f2680a2d3420f504bd565cf03035c53198a;
bytes32 constant _DECREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH = 0xb70559e94cbda91958ebec07f9b65b3b490097c8d25c8dacd71105df1015b6d8;
bytes32 constant _CANCEL_AUTHORIZATION_TYPEHASH = 0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429;
bytes32 constant _PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

library LibGasAbstraction {

    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);

    function _transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {

        _requireValidAuthorization(from, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            _TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce
        );
        require(
            LibEIP712.recover(LibAppStorage.diamondStorage().domainSeparator, v, r, s, data) ==
                from,
            "GasAbstraction: invalid signature"
        );

        _markAuthorizationAsUsed(from, nonce);
        LibERC20._transfer(from, to, value);
    }

    function _increaseAllowanceWithAuthorization(
        address owner,
        address spender,
        uint256 increment,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {

        _requireValidAuthorization(owner, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            _INCREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH,
            owner,
            spender,
            increment,
            validAfter,
            validBefore,
            nonce
        );
        require(
            LibEIP712.recover(LibAppStorage.diamondStorage().domainSeparator, v, r, s, data) ==
                owner,
            "GasAbstraction: invalid signature"
        );

        _markAuthorizationAsUsed(owner, nonce);
        LibERC20._increaseAllowance(owner, spender, increment);
    }

    function _decreaseAllowanceWithAuthorization(
        address owner,
        address spender,
        uint256 decrement,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {

        _requireValidAuthorization(owner, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            _DECREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH,
            owner,
            spender,
            decrement,
            validAfter,
            validBefore,
            nonce
        );
        require(
            LibEIP712.recover(LibAppStorage.diamondStorage().domainSeparator, v, r, s, data) ==
                owner,
            "GasAbstraction: invalid signature"
        );

        _markAuthorizationAsUsed(owner, nonce);
        LibERC20._decreaseAllowance(owner, spender, decrement);
    }

    function _approveWithAuthorization(
        address owner,
        address spender,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {

        _requireValidAuthorization(owner, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            _APPROVE_WITH_AUTHORIZATION_TYPEHASH,
            owner,
            spender,
            value,
            validAfter,
            validBefore,
            nonce
        );
        require(
            LibEIP712.recover(LibAppStorage.diamondStorage().domainSeparator, v, r, s, data) ==
                owner,
            "GasAbstraction: invalid signature"
        );

        _markAuthorizationAsUsed(owner, nonce);
        LibERC20._approve(owner, spender, value);
    }

    function _cancelAuthorization(
        address authorizer,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {

        _requireUnusedAuthorization(authorizer, nonce);

        bytes memory data = abi.encode(_CANCEL_AUTHORIZATION_TYPEHASH, authorizer, nonce);
        require(
            LibEIP712.recover(LibAppStorage.diamondStorage().domainSeparator, v, r, s, data) ==
                authorizer,
            "GasAbstraction: invalid signature"
        );

        LibAppStorage.diamondStorage().authorizationStates[authorizer][nonce] = AuthorizationState
            .Canceled;
        emit AuthorizationCanceled(authorizer, nonce);
    }

    function _requireUnusedAuthorization(address authorizer, bytes32 nonce) private view {

        require(
            LibAppStorage.diamondStorage().authorizationStates[authorizer][nonce] ==
                AuthorizationState.Unused,
            "GasAbstraction: authorization is used or canceled"
        );
    }

    function _requireValidAuthorization(
        address authorizer,
        bytes32 nonce,
        uint256 validAfter,
        uint256 validBefore
    ) private view {

        require(block.timestamp > validAfter, "GasAbstraction: authorization is not yet valid");
        require(block.timestamp < validBefore, "GasAbstraction: authorization is expired");
        _requireUnusedAuthorization(authorizer, nonce);
    }

    function _markAuthorizationAsUsed(address authorizer, bytes32 nonce) private {

        LibAppStorage.diamondStorage().authorizationStates[authorizer][nonce] = AuthorizationState
            .Used;
        emit AuthorizationUsed(authorizer, nonce);
    }

    function _permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {

        require(deadline >= block.timestamp, "Permit: permit is expired");

        AppStorage storage appStorage = LibAppStorage.diamondStorage();
        bytes memory data = abi.encode(
            _PERMIT_TYPEHASH,
            owner,
            spender,
            value,
            appStorage.nonces[owner]++,
            deadline
        );
        require(
            LibEIP712.recover(appStorage.domainSeparator, v, r, s, data) == owner,
            "Permit: invalid signature"
        );

        LibERC20._approve(owner, spender, value);
    }
}



contract EIP712Domain {

    function DOMAIN_SEPARATOR() external view returns (bytes32) {

        return LibAppStorage.diamondStorage().domainSeparator;
    }
}



abstract contract GasAbstraction is EIP712Domain {
    bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH =
        _TRANSFER_WITH_AUTHORIZATION_TYPEHASH;
    bytes32 public constant APPROVE_WITH_AUTHORIZATION_TYPEHASH =
        _APPROVE_WITH_AUTHORIZATION_TYPEHASH;
    bytes32 public constant INCREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH =
        _INCREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH;
    bytes32 public constant DECREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH =
        _DECREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH;
    bytes32 public constant CANCEL_AUTHORIZATION_TYPEHASH = _CANCEL_AUTHORIZATION_TYPEHASH;

    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);

    function authorizationState(address authorizer, bytes32 nonce)
        external
        view
        returns (AuthorizationState)
    {
        return LibAppStorage.diamondStorage().authorizationStates[authorizer][nonce];
    }

    function increaseAllowance(address spender, uint256 increment) external returns (bool) {
        LibPausable._requireNotPaused();
        LibBlacklistable._requireNotBlacklisted(msg.sender);
        LibBlacklistable._requireNotBlacklisted(spender);

        LibERC20._increaseAllowance(msg.sender, spender, increment);
        return true;
    }

    function decreaseAllowance(address spender, uint256 decrement) external returns (bool) {
        LibPausable._requireNotPaused();
        LibBlacklistable._requireNotBlacklisted(msg.sender);
        LibBlacklistable._requireNotBlacklisted(spender);

        LibERC20._decreaseAllowance(msg.sender, spender, decrement);
        return true;
    }

    function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        LibPausable._requireNotPaused();
        LibBlacklistable._requireNotBlacklisted(from);
        LibBlacklistable._requireNotBlacklisted(to);

        LibGasAbstraction._transferWithAuthorization(
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function approveWithAuthorization(
        address tokenOwner,
        address spender,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        LibPausable._requireNotPaused();
        LibBlacklistable._requireNotBlacklisted(tokenOwner);
        LibBlacklistable._requireNotBlacklisted(spender);

        LibGasAbstraction._approveWithAuthorization(
            tokenOwner,
            spender,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function increaseAllowanceWithAuthorization(
        address tokenOwner,
        address spender,
        uint256 increment,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        LibPausable._requireNotPaused();
        LibBlacklistable._requireNotBlacklisted(tokenOwner);
        LibBlacklistable._requireNotBlacklisted(spender);

        LibGasAbstraction._increaseAllowanceWithAuthorization(
            tokenOwner,
            spender,
            increment,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function decreaseAllowanceWithAuthorization(
        address tokenOwner,
        address spender,
        uint256 decrement,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        LibPausable._requireNotPaused();
        LibBlacklistable._requireNotBlacklisted(tokenOwner);
        LibBlacklistable._requireNotBlacklisted(spender);

        LibGasAbstraction._decreaseAllowanceWithAuthorization(
            tokenOwner,
            spender,
            decrement,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function cancelAuthorization(
        address authorizer,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        LibPausable._requireNotPaused();

        LibGasAbstraction._cancelAuthorization(authorizer, nonce, v, r, s);
    }
}



abstract contract Permit is EIP712Domain {
    bytes32 public constant PERMIT_TYPEHASH = _PERMIT_TYPEHASH;

    function nonces(address owner) external view returns (uint256) {
        return LibAppStorage.diamondStorage().nonces[owner];
    }

    function permit(
        address tokenOwner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        LibPausable._requireNotPaused();
        LibBlacklistable._requireNotBlacklisted(tokenOwner);
        LibBlacklistable._requireNotBlacklisted(spender);

        LibGasAbstraction._permit(tokenOwner, spender, value, deadline, v, r, s);
    }
}



contract HeartToken is BaseToken, GasAbstraction, Permit, ERC1363 {

    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 692000000 * 1e18;

    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        address newPauser,
        address newBlacklister,
        address newOwner,
        address tokenReceiver
    ) external {

        require(!appStorage.initialized, "HeartToken: contract is already initialized");
        require(newPauser != address(0), "HeartToken: new pauser is the zero address");
        require(newBlacklister != address(0), "HeartToken: new blacklister is the zero address");
        require(newOwner != address(0), "HeartToken: new owner is the zero address");
        require(tokenReceiver != address(0), "HeartToken: token receiver is the zero address");

        appStorage.name = tokenName;
        appStorage.symbol = tokenSymbol;
        appStorage.decimals = 18;
        appStorage.pauser = newPauser;
        appStorage.blacklister = newBlacklister;
        setOwner(newOwner);

        appStorage.domainSeparator = LibEIP712.makeDomainSeparator(tokenName, "1");

        _mint(tokenReceiver, MAX_SUPPLY);
        require(
            appStorage.totalSupply == MAX_SUPPLY,
            "HeartToken: totalSupply is not expected value"
        );
        require(
            appStorage.balances[tokenReceiver] == MAX_SUPPLY,
            "HeartToken: tokenReceiver balance is not expected value"
        );

        appStorage.initialized = true;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(BaseToken, ERC1363)
        returns (bool)
    {

        return ERC1363.supportsInterface(interfaceId) || BaseToken.supportsInterface(interfaceId);
    }
}