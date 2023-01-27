
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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

library StorageSlotUpgradeable {

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


abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            _functionDelegateCall(newImplementation, data);
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
            _functionDelegateCall(newImplementation, data);
        }

        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            _functionDelegateCall(
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
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
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

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT
pragma solidity ^0.8.2;


interface IGolemsAndDragons {

    function ownerOf(uint256 id) external view returns (address);


    function transferFrom(
        address from_,
        address to_,
        uint256 tokenId
    ) external;


    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId,
        bytes memory data_
    ) external;


    function isDragon(uint256 token) external view returns (bool);


    function addStats(
        uint256 tokenID,
        uint16 health,
        uint16 attack,
        uint16 defense,
        uint16 agility
    ) external;

}

interface IAncientGold {

    function balanceOf(address address_) external view returns (uint256);


    function bgTransfer(address to_, uint256 amount_) external;

}

contract BattleGround is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    IERC721ReceiverUpgradeable
{

    struct Stake {
        address owner;
        uint256 token;
        uint80 time;
    }

    constructor() initializer {}

    bool private _paused;

    IGolemsAndDragons public golemsAndDragons;
    IAncientGold public ancientGold;

    uint256 public totalTokensStaked;

    mapping(uint256 => uint256) public stakeIndices;
    mapping(address => Stake[]) public stakes;

    uint256 public constant TTE = 1 days;
    uint256 public constant EARNINGS_RATE = 15000 ether;
    uint256 public constant HEALTH_RATE = 10;
    uint256 public constant ATTACK_RATE = 1;
    uint256 public constant DEFENSE_RATE = 5;
    uint256 public constant AGILITY_RATE = 1;

    modifier whenPaused() {

        require(_paused, "GAD-BG-E1");
        _;
    }

    modifier whenNotPaused() {

        require(!_paused, "GAD-BG-E2");
        _;
    }

    function initialize() public initializer {

        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function startTrainingTokens(address address_, uint16[] calldata tokens)
        external
    {

        require(
            address_ == _msgSender() ||
                _msgSender() == address(golemsAndDragons),
            "GAD-BG-E3"
        );

        for (uint256 i = 0; i < tokens.length; i++) {
            if (_msgSender() != address(golemsAndDragons)) {
                require(
                    golemsAndDragons.ownerOf(tokens[i]) == _msgSender(),
                    "GAD-BG-E4"
                );
                golemsAndDragons.transferFrom(
                    _msgSender(),
                    address(this),
                    tokens[i]
                );
            }

            totalTokensStaked += 1;
            stakeIndices[tokens[i]] = stakes[address_].length;
            stakes[address_].push(
                Stake(address_, tokens[i], uint80(block.timestamp))
            );
        }
    }

    event TokenStatsUpgraded(
        uint256 tokenId,
        uint256 health,
        uint256 attack,
        uint256 defense,
        uint256 agility
    );

    function claimFromTraining(uint16[] calldata tokens, bool unstake)
        external
        whenNotPaused
    {

        uint256 earnings = 0;

        for (uint256 i = 0; i < tokens.length; i++) {
            Stake memory stake = stakes[_msgSender()][stakeIndices[tokens[i]]];
            require(stake.owner == _msgSender(), "GOD-BG-E5");
            require(
                !unstake || block.timestamp - stake.time >= TTE,
                "GOD-BG-E6"
            );

            uint256 actualHealthRate = golemsAndDragons.isDragon(tokens[i])
                ? HEALTH_RATE * 3
                : HEALTH_RATE;

            earnings += ((block.timestamp - stake.time) * EARNINGS_RATE) / TTE;
            uint256 health = ((block.timestamp - stake.time) *
                actualHealthRate) / TTE;
            uint256 attack = ((block.timestamp - stake.time) * ATTACK_RATE) /
                TTE;
            uint256 defense = ((block.timestamp - stake.time) * DEFENSE_RATE) /
                TTE;
            uint256 agility = ((block.timestamp - stake.time) * AGILITY_RATE) /
                TTE;

            if (unstake) {
                totalTokensStaked -= 1;

                Stake memory lastStake = stakes[_msgSender()][
                    stakes[_msgSender()].length - 1
                ];
                stakes[_msgSender()][stakeIndices[tokens[i]]] = lastStake;
                stakeIndices[lastStake.token] = stakeIndices[tokens[i]];
                stakes[_msgSender()].pop();
                delete stakeIndices[tokens[i]];

                golemsAndDragons.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    tokens[i],
                    ""
                );
            } else {
                stakes[_msgSender()][stakeIndices[tokens[i]]] = Stake(
                    _msgSender(),
                    tokens[i],
                    uint80(block.timestamp)
                );
            }

            emit TokenStatsUpgraded(
                tokens[i],
                health,
                attack,
                defense,
                agility
            );

            golemsAndDragons.addStats(
                tokens[i],
                uint16(health),
                uint16(attack),
                uint16(defense),
                uint16(agility)
            );
        }

        uint256 balance = ancientGold.balanceOf(address(ancientGold));
        if (balance < earnings) earnings = balance;

        ancientGold.bgTransfer(_msgSender(), earnings);
    }

    function setGolemsAndDragons(address contract_) external onlyOwner {

        golemsAndDragons = IGolemsAndDragons(contract_);
    }

    function setAncientGold(address contract_) external onlyOwner {

        ancientGold = IAncientGold(contract_);
    }

    function getAllStakes(address user) external view returns (Stake[] memory) {

        return stakes[user];
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}


    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }
}