
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
    uint256[49] private __gap;
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

interface IERC20Upgradeable {

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}pragma solidity ^0.8.0;


contract BlackholePreventionUpgradeable {

    using AddressUpgradeable for address payable;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event WithdrawStuckEther(address indexed receiver, uint256 amount);
    event WithdrawStuckERC20(
        address indexed receiver,
        address indexed tokenAddress,
        uint256 amount
    );
    event WithdrawStuckERC721(
        address indexed receiver,
        address indexed tokenAddress,
        uint256 indexed tokenId
    );

    function _withdrawEther(address payable receiver, uint256 amount)
        internal
        virtual
    {

        require(receiver != address(0x0), "BHP:E-403");
        if (address(this).balance >= amount) {
            receiver.sendValue(amount);
            emit WithdrawStuckEther(receiver, amount);
        }
    }

    function _withdrawERC20(
        address payable receiver,
        address tokenAddress,
        uint256 amount
    ) internal virtual {

        require(receiver != address(0x0), "BHP:E-403");
        if (
            IERC20Upgradeable(tokenAddress).balanceOf(address(this)) >= amount
        ) {
            IERC20Upgradeable(tokenAddress).safeTransfer(receiver, amount);
            emit WithdrawStuckERC20(receiver, tokenAddress, amount);
        }
    }

    function _withdrawERC721(
        address payable receiver,
        address tokenAddress,
        uint256 tokenId
    ) internal virtual {

        require(receiver != address(0x0), "BHP:E-403");
        if (
            IERC721Upgradeable(tokenAddress).ownerOf(tokenId) == address(this)
        ) {
            IERC721Upgradeable(tokenAddress).transferFrom(
                address(this),
                receiver,
                tokenId
            );
            emit WithdrawStuckERC721(receiver, tokenAddress, tokenId);
        }
    }
}pragma solidity ^0.8.0;

contract UpgradeableBase is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    constructor() initializer {}

    function _authorizeUpgrade(address) internal override onlyOwner {}


    function initOwner() internal {

        __Ownable_init();
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}//Unlicense
pragma solidity ^0.8.0;


contract VialExchangeV2 is
    UpgradeableBase,
    IERC1155ReceiverUpgradeable,
    ERC165Upgradeable,
    PausableUpgradeable
{

    address public constant DEAD_ADDRESS = address(0xdead);    

    IERC1155Upgradeable public vial;
    uint256 public vialTokenId;
    IERC1155Upgradeable[] public rewardTokens;
    uint256[] public rewardTokenIds;
    uint256[] public timestampStartClaims;
    uint256[] public claimDurations;
    uint256[] public rewardQuantities;  //remaining rewards quantities
    uint256[] public rewardTotalQuantities;

    event VialUpdated(address vial, uint256 vialTokenId, address executor);
    event Exchange(address user, address vial, uint256 vialTokenId, uint256 vialAmount, address rewardToken, uint256 rewardTokenId);
    event RewardTokenlUpdated(
        bytes rewardTokens,
        bytes rewardTokenIds,
        bytes rewardQuantities,
        bytes timestampStartClaims,
        bytes claimDurations,
        address executor
    );
    event AddMoreReward(
        address rewardToken, 
        uint256 rewardTokenId, 
        uint256 quantity, 
        uint256 startClaim, 
        uint256 duration
    );
    event UpdateRewardClaimTime(
        uint256 _index, 
        uint256 _start, 
        uint256 _duration);
    event UpdateRewardQuantities(
        uint256 _index, 
        uint256 _newQuantity);
    event StopExchange();

    uint256 public maxExchange;

    function initialize(
        IERC1155Upgradeable _vial,
        uint256 _vialTokenId,
        IERC1155Upgradeable[] memory _rewardTokens,
        uint256[] memory _rewardTokenIds,
        uint256[] memory _rewardQuantities,
        uint256[] memory _timestampStartClaims,
        uint256[] memory _claimDurations
    ) external initializer {

        initOwner();
        vial = _vial;
        vialTokenId = _vialTokenId;
        _changeRewardToken(
            _rewardTokens,
            _rewardTokenIds,
            _rewardQuantities,
            _timestampStartClaims,
            _claimDurations
        );
    }

    function changeVial(IERC1155Upgradeable _vial, uint256 _vialTokenId)
        external
        onlyOwner
    {   

        require((address(vial) != address(_vial) || vialTokenId != _vialTokenId), "Already be vial");
        vial = _vial;
        vialTokenId = _vialTokenId;
        emit VialUpdated(address(vial), vialTokenId, msg.sender);
    }

    function changeRewardToken(
        IERC1155Upgradeable[] memory _rewardTokens,
        uint256[] memory _rewardTokenIds,
        uint256[] memory _rewardQuantities,
        uint256[] memory _timestampStartClaims,
        uint256[] memory _claimDurations
    ) external onlyOwner {

        _changeRewardToken(
            _rewardTokens,
            _rewardTokenIds,
            _rewardQuantities,
            _timestampStartClaims,
            _claimDurations
        );
    }


    function updateRewardQuantities(uint256 _index, uint256 _newQuantity) external onlyOwner {

        require(_index< rewardQuantities.length, "Wrong input index");
        require((rewardTotalQuantities[_index] - rewardQuantities[_index]) <= _newQuantity, "invalid new quantity");
        rewardQuantities[_index] = _newQuantity - (rewardTotalQuantities[_index] - rewardQuantities[_index]);
        rewardTotalQuantities[_index] = _newQuantity;
        emit UpdateRewardQuantities(_index, _newQuantity);
    }

    function updateRewardClaimTime(uint256 _index, uint256 _start, uint256 _duration) external onlyOwner {

        require(_index< timestampStartClaims.length, "Wrong input index");
        timestampStartClaims[_index] = _start;
        claimDurations[_index] = _duration;
        emit UpdateRewardClaimTime(_index, _start, _duration);
    }

    function addMoreReward(address _rewardToken, uint256 _rewardTokenId, uint256 _quantity, uint256 _startClaim, uint256 _duration) external onlyOwner {

        for(uint256 i = 0; i < rewardTokens.length; i++) {
            if (address(rewardTokens[i]) == _rewardToken && rewardTokenIds[i] == _rewardTokenId) {
                revert("duplicate");
            }
        }
        rewardTokens.push(IERC1155Upgradeable(_rewardToken));
        rewardTokenIds.push(_rewardTokenId);
        rewardQuantities.push(_quantity);
        rewardTotalQuantities.push(_quantity);
        timestampStartClaims.push(_startClaim);
        claimDurations.push(_duration);
        emit AddMoreReward(_rewardToken, _rewardTokenId, _quantity, _startClaim, _duration);
    }

    function _changeRewardToken(
        IERC1155Upgradeable[] memory _rewardTokens,
        uint256[] memory _rewardTokenIds,
        uint256[] memory _rewardQuantities,
        uint256[] memory _timestampStartClaims,
        uint256[] memory _claimDurations
    ) internal {

        require(
            _rewardTokenIds.length == _rewardTokens.length &&
            _rewardTokenIds.length == _rewardQuantities.length &&
                _rewardQuantities.length == _timestampStartClaims.length &&
                _timestampStartClaims.length == _claimDurations.length,
            "invalid input array length"
        );
        rewardTokens = _rewardTokens;
        rewardTokenIds = _rewardTokenIds;
        rewardQuantities = _rewardQuantities;
        rewardTotalQuantities = _rewardQuantities;
        timestampStartClaims = _timestampStartClaims;
        claimDurations = _claimDurations;
        address[] memory addrList = new address[](_rewardTokens.length);
        for(uint256 i = 0; i < _rewardTokens.length; i++) {
            addrList[i] = address(_rewardTokens[i]);
        }
        emit RewardTokenlUpdated(
            abi.encodePacked(addrList),
            abi.encodePacked(rewardTokenIds),
            abi.encodePacked(rewardQuantities),
            abi.encodePacked(timestampStartClaims),
            abi.encodePacked(claimDurations),
            msg.sender
        );
    }

    function pauseExchange() external onlyOwner {

        _pause();
    }

    function resumeExchange() external onlyOwner {

        _unpause();
    }

    function exchange(uint256 _vialAmount, uint256 _rewardIndex, address _rewardToken, uint256 _rewardTokenId) external whenNotPaused {

        require(_rewardIndex < rewardTokens.length, "index out of bound");
        require(address(rewardTokens[_rewardIndex]) == _rewardToken, "invalid reward token address");
        require(rewardTokenIds[_rewardIndex] == _rewardTokenId, "invalid reward token id");

        require(timestampStartClaims[_rewardIndex] != 0, "not start yet");
        require(
            (timestampStartClaims[_rewardIndex] <= block.timestamp) && (
                block.timestamp <=
                (timestampStartClaims[_rewardIndex] + claimDurations[_rewardIndex])),
            "not start yet"
        );

        require(_vialAmount <= maxExchange, "Exceeded Maximum Exchange");
        require(rewardQuantities[_rewardIndex] >= _vialAmount, "rewards drained");
        rewardQuantities[_rewardIndex] = rewardQuantities[_rewardIndex] - _vialAmount;
        vial.safeTransferFrom(
            msg.sender,
            DEAD_ADDRESS,
            vialTokenId,
            _vialAmount,
            ""
        );

        IERC1155Upgradeable _selectedRewardToken = rewardTokens[_rewardIndex];
        _selectedRewardToken.safeTransferFrom(
            address(this),
            msg.sender,
            _rewardTokenId,
            _vialAmount,
            ""
        );
        emit Exchange(msg.sender, address(vial), vialTokenId, _vialAmount, _rewardToken, _rewardTokenId);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {

        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4) {

        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165Upgradeable, ERC165Upgradeable)
        returns (bool)
    {

        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId;
    }

    function getRewardTokenIds() external view returns (uint256[] memory) {

        return rewardTokenIds;
    }

    function getRewardTokenIdsBalance()
        external
        view
        returns (address[] memory tokens, uint256[] memory tokenIds, uint256[] memory balances)
    {

        tokenIds = rewardTokenIds;
        balances = new uint256[](rewardTokenIds.length);
        tokens = new address[](rewardTokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            balances[i] = rewardTokens[i].balanceOf(address(this), tokenIds[i]);
            tokens[i] = address(rewardTokens[i]);
        }
    }

    function getRewardTokenIdsQuantities()
        external
        view
        returns (uint256[] memory tokenIds, uint256[] memory quantities)
    {

        tokenIds = rewardTokenIds;
        quantities = rewardQuantities;
    }

    function getRewardInfo()
        external
        view
        returns (
            IERC1155Upgradeable[] memory _rewardTokens,
            uint256[] memory _rewardTokenIds,
            uint256[] memory _remainRewardQuantities,
            uint256[] memory _totalRewardQuantities,
            uint256[] memory _timestampStartClaims,
            uint256[] memory _claimDurations
        )
    {

        return (
            rewardTokens,
            rewardTokenIds,
            rewardQuantities,
            rewardTotalQuantities,
            timestampStartClaims,
            claimDurations
        );
    }

    function updateMaxExchange(uint256 max) public onlyOwner
    {

        maxExchange = max;
    }
}