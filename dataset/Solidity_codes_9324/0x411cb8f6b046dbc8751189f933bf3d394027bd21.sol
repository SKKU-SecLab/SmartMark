
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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
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

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal onlyInitializing {

        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {

    function __ERC1155Holder_init() internal onlyInitializing {

        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {

    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
    uint256[50] private __gap;
}// MIT
pragma solidity ^0.8.0;

interface IRandomizer {


    function setNumBlocksAfterIncrement(uint8 _numBlocksAfterIncrement) external;


    function incrementCommitId() external;


    function addRandomForCommit(uint256 _seed) external;


    function requestRandomNumber() external returns(uint256);


    function revealRandomNumber(uint256 _requestId) external view returns(uint256);


    function isRandomReady(uint256 _requestId) external view returns(bool);

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
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

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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
}//MIT
pragma solidity ^0.8.0;


contract UtilitiesUpgradeable is Initializable, OwnableUpgradeable, PausableUpgradeable {


    function __Utilities__init() internal initializer {

        OwnableUpgradeable.__Ownable_init();
        PausableUpgradeable.__Pausable_init();

        _pause();
    }

    modifier nonZeroAddress(address _address) {

        require(address(0) != _address, "0 address");
        _;
    }

    modifier nonZeroLength(uint[] memory _array) {

        require(_array.length > 0, "Empty array");
        _;
    }

    modifier lengthsAreEqual(uint[] memory _array1, uint[] memory _array2) {

        require(_array1.length == _array2.length, "Unequal lengths");
        _;
    }

    modifier onlyEOA() {

        require(msg.sender == tx.origin, "No contracts");
        _;
    }

    function isOwner() internal view returns(bool) {

        return owner() == msg.sender;
    }
}//MIT
pragma solidity ^0.8.0;



contract AdminableUpgradeable is UtilitiesUpgradeable {


    mapping(address => bool) private admins;

    function __Adminable_init() internal initializer {

        UtilitiesUpgradeable.__Utilities__init();
    }

    function addAdmin(address _address) external onlyOwner {

        admins[_address] = true;
    }

    function addAdmins(address[] calldata _addresses) external onlyOwner {

        for(uint256 i = 0; i < _addresses.length; i++) {
            admins[_addresses[i]] = true;
        }
    }

    function removeAdmin(address _address) external onlyOwner {

        admins[_address] = false;
    }

    function removeAdmins(address[] calldata _addresses) external onlyOwner {

        for(uint256 i = 0; i < _addresses.length; i++) {
            admins[_addresses[i]] = false;
        }
    }

    function setPause(bool _shouldPause) external onlyAdminOrOwner {

        if(_shouldPause) {
            _pause();
        } else {
            _unpause();
        }
    }

    function isAdmin(address _address) public view returns(bool) {

        return admins[_address];
    }

    modifier onlyAdmin() {

        require(admins[msg.sender], "Not admin");
        _;
    }

    modifier onlyAdminOrOwner() {

        require(admins[msg.sender] || isOwner(), "Not admin or owner");
        _;
    }
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


interface IGP is IERC20Upgradeable {

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

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

}// MIT

pragma solidity ^0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT
pragma solidity ^0.8.0;


interface IWnDRoot {

    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    function getTokenTraits(uint256 _tokenId) external returns(WizardDragon memory);

    function ownerOf(uint256 _tokenId) external returns(address);

    function approve(address _to, uint256 _tokenId) external;

}

interface IWnD is IERC721EnumerableUpgradeable {

    function mint(address _to, uint256 _tokenId, WizardDragon calldata _traits) external;

    function burn(uint256 _tokenId) external;

    function isWizard(uint256 _tokenId) external view returns(bool);

    function getTokenTraits(uint256 _tokenId) external view returns(WizardDragon memory);

    function exists(uint256 _tokenId) external view returns(bool);

    function adminTransferFrom(address _from, address _to, uint256 _tokenId) external;

}

struct WizardDragon {
    bool isWizard;
    uint8 body;
    uint8 head;
    uint8 spell;
    uint8 eyes;
    uint8 neck;
    uint8 mouth;
    uint8 wand;
    uint8 tail;
    uint8 rankIndex;
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


interface ISacrificialAlter is IERC1155Upgradeable {

    function mint(uint256 typeId, uint16 qty, address recipient) external;

    function burn(uint256 typeId, uint16 qty, address burnFrom) external;

    function adminSafeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount) external;

    function adminSafeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts) external;

}// MIT LICENSE

pragma solidity ^0.8.0;


interface IConsumables is IERC1155Upgradeable {

    function mint(uint256 typeId, uint256 qty, address recipient) external;

    function burn(uint256 typeId, uint256 qty, address burnFrom) external;

    function adminSafeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount) external;

    function adminSafeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts) external;

}// MIT
pragma solidity ^0.8.0;

interface IMessageHandler {


    function handleMessage(bytes calldata _data) external;

}// MIT
pragma solidity ^0.8.0;

interface IRootTunnel {


    function sendMessageToChild(bytes calldata _data) external;

}// MIT
pragma solidity ^0.8.0;

interface IRiftRoot {


}// MIT
pragma solidity ^0.8.0;

interface IOldTrainingGrounds {

    function ownsToken(uint256 tokenId) external view returns (bool);

}//MIT
pragma solidity ^0.8.0;



abstract contract RiftRootState is Initializable, IRiftRoot, IMessageHandler, ERC721HolderUpgradeable, ERC1155HolderUpgradeable, AdminableUpgradeable {

    IGP public gp;
    IWnDRoot public wnd;
    ISacrificialAlter public sacrificialAlter;
    IConsumables public consumables;
    IRootTunnel public rootTunnel;
    IOldTrainingGrounds public oldTrainingGrounds;

    EnumerableSetUpgradeable.AddressSet internal addressesStaked;
    mapping(address => uint256) public addressToGPStaked;
    uint256 public amountNeededToOpenPortal;
    uint256 public amountCurrentlyStaked;

    function __RiftRootState_init() internal initializer {
        AdminableUpgradeable.__Adminable_init();
        ERC721HolderUpgradeable.__ERC721Holder_init();
        ERC1155HolderUpgradeable.__ERC1155Holder_init();

        amountNeededToOpenPortal = 42_000_000 ether;
    }
}//MIT
pragma solidity ^0.8.0;



abstract contract RiftRootContracts is Initializable, RiftRootState {

    function __RiftRootContracts_init() internal initializer {
        RiftRootState.__RiftRootState_init();
    }

    function setContracts(
        address _gpAddress,
        address _wndAddress,
        address _sacrificialAlterAddress,
        address _consumablesAddress,
        address _rootTunnelAddress,
        address _oldTrainingGroundsAddress)
    external onlyAdminOrOwner
    {
        gp = IGP(_gpAddress);
        wnd = IWnDRoot(_wndAddress);
        sacrificialAlter = ISacrificialAlter(_sacrificialAlterAddress);
        consumables = IConsumables(_consumablesAddress);
        rootTunnel = IRootTunnel(_rootTunnelAddress);
        oldTrainingGrounds = IOldTrainingGrounds(_oldTrainingGroundsAddress);
    }

    modifier contractsAreSet() {
        require(areContractsSet(), "RiftRoot: Contracts aren't set");

        _;
    }

    function areContractsSet() public view returns(bool) {
        return address(gp) != address(0)
            && address(wnd) != address(0)
            && address(sacrificialAlter) != address(0)
            && address(rootTunnel) != address(0)
            && address(oldTrainingGrounds) != address(0)
            && address(consumables) != address(0);
    }
}//MIT
pragma solidity ^0.8.0;



abstract contract RiftRootGP is Initializable, RiftRootContracts {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    function __RiftRootGP_init() internal initializer {
        RiftRootContracts.__RiftRootContracts_init();
    }

    function updateStakeSettings(uint256 _amountNeededToOpenPortal) external onlyAdminOrOwner {
        amountNeededToOpenPortal = _amountNeededToOpenPortal;
    }

    function stakeGP(uint256 _amount) external {
        require(_amount > 0, "Must stake some GP.");
        amountCurrentlyStaked += _amount;
        addressToGPStaked[msg.sender] += _amount;

        if(!addressesStaked.contains(msg.sender)) {
            addressesStaked.add(msg.sender);
        }

        bool _wasTransferred = gp.transferFrom(msg.sender, address(this), _amount);
        require(_wasTransferred, "GP not transferred");
    }

    function unstakeGP(uint256 _amount) external {
        uint256 _amountStaked = addressToGPStaked[msg.sender];
        require(_amountStaked >= _amount, "Too much GP to unstake");

        amountCurrentlyStaked -= _amount;
        addressToGPStaked[msg.sender] -= _amount;

        if(addressToGPStaked[msg.sender] == 0) {
            addressesStaked.remove(msg.sender);
        }

        bool _wasTransferred = gp.transfer(msg.sender, _amount);
        require(_wasTransferred, "GP not transferred");
    }

}//MIT
pragma solidity ^0.8.0;



contract RiftRoot is Initializable, RiftRootGP {


    function initialize() external initializer {

        RiftRootGP.__RiftRootGP_init();
    }

    function transferToL2(
        uint256 _gpAmount,
        uint256[] calldata _wndTokenIds,
        uint256[] calldata _saIds,
        uint256[] calldata _saAmounts,
        uint256[] memory _consumableIds,
        uint256[] memory _consumableAmounts)
    external
    onlyEOA
    whenNotPaused
    contractsAreSet
    {

        require(_saIds.length == _saAmounts.length, "Bad SA lengths");
        require(_consumableIds.length == _consumableAmounts.length, "Bad lengths");
        require(_wndTokenIds.length <= 10, "too many NFTs to transfer");

        require(amountCurrentlyStaked >= amountNeededToOpenPortal, "Not enough GP staked");

        bytes memory message = _getMessageForChild(_gpAmount, _wndTokenIds, _saIds, _saAmounts, _consumableIds, _consumableAmounts);

        rootTunnel.sendMessageToChild(message);
    }

    function _getMessageForChild(
        uint256 _gpAmount,
        uint256[] memory _wndTokenIds,
        uint256[] memory _saIds,
        uint256[] memory _saAmounts,
        uint256[] memory _consumableIds,
        uint256[] memory _consumableAmounts)
        internal returns(bytes memory)
    {

        if(_gpAmount > 0) {
            gp.burn(msg.sender, _gpAmount);
        }

        WizardDragon[] memory _traits = new WizardDragon[](_wndTokenIds.length);
        for(uint256 i = 0; i < _wndTokenIds.length; i++) {
            uint256 _id = _wndTokenIds[i];
            require(_id != 0, "Bad Wnd ID");

            _traits[i] = wnd.getTokenTraits(_id);

            if(wnd.ownerOf(_id) == address(oldTrainingGrounds) && oldTrainingGrounds.ownsToken(_id)) {
                wnd.transferFrom(address(oldTrainingGrounds), address(this), _id);
            } else {
                wnd.safeTransferFrom(msg.sender, address(this), _id);
            }
        }

        if(_saIds.length > 0) {
            sacrificialAlter.safeBatchTransferFrom(msg.sender, address(this), _saIds, _saAmounts, "");
        }

        if(_consumableIds.length > 0) {
            consumables.adminSafeBatchTransferFrom(msg.sender, address(this), _consumableIds, _consumableAmounts);
        }

        bytes memory message = abi.encode(msg.sender, _gpAmount, _wndTokenIds, _traits, _saIds, _saAmounts, _consumableIds, _consumableAmounts);

        return message;
    }

    function handleMessage(bytes calldata _data) external override onlyAdminOrOwner {

        (address _to,
        uint256 _gpAmount,
        uint256[] memory _wndTokenIds,
        uint256[] memory _saIds,
        uint256[] memory _saAmounts,
        uint256[] memory _consumableIds,
        uint256[] memory _consumableAmounts) = abi.decode(
            _data,
            (address, uint256, uint256[], uint256[], uint256[], uint256[], uint256[])
        );

        processMessageFromChild(_to, _gpAmount, _wndTokenIds, _saIds, _saAmounts, _consumableIds, _consumableAmounts);
    }

    function processMessageFromChild(
        address _to,
        uint256 _gpAmount,
        uint256[] memory _wndTokenIds,
        uint256[] memory _saIds,
        uint256[] memory _saAmounts,
        uint256[] memory _consumableIds,
        uint256[] memory _consumableAmounts)
        public
        onlyAdminOrOwner
    {

        require(_saIds.length == _saAmounts.length, "Bad SA Amounts");
        require(_consumableIds.length == _consumableAmounts.length, "Bad SA Amounts");

        if(_gpAmount > 0) {
            gp.mint(_to, _gpAmount);
        }

        for(uint256 i = 0; i < _wndTokenIds.length; i++) {
            uint256 _tokenId = _wndTokenIds[i];
            require(_tokenId != 0, "Bad token id");
            wnd.safeTransferFrom(address(this), _to, _tokenId);
        }

        if(_saIds.length > 0) {
            address[] memory _addresses = new address[](_saIds.length);
            for(uint256 i = 0; i < _saIds.length; i++) {
                _addresses[i] = address(this);
            }

            uint256[] memory _balances = sacrificialAlter.balanceOfBatch(_addresses, _saIds);

            for(uint256 i = 0; i < _saIds.length; i++) {
                uint256 _currentBalance = _balances[i];
                if(_currentBalance < _saAmounts[i]) {
                    sacrificialAlter.mint(_saIds[i], uint16(_saAmounts[i] - _currentBalance), address(this));
                }
            }

            sacrificialAlter.safeBatchTransferFrom(address(this), _to, _saIds, _saAmounts, "");
        }

        if(_consumableIds.length > 0) {
            address[] memory _addresses = new address[](_consumableIds.length);
            for(uint256 i = 0; i < _consumableIds.length; i++) {
                _addresses[i] = address(this);
            }

            uint256[] memory _balances = consumables.balanceOfBatch(_addresses, _consumableIds);

            for(uint256 i = 0; i < _consumableIds.length; i++) {
                uint256 _currentBalance = _balances[i];
                if(_currentBalance < _consumableAmounts[i]) {
                    consumables.mint(_consumableIds[i], uint16(_consumableAmounts[i] - _currentBalance), address(this));
                }
            }

            consumables.adminSafeBatchTransferFrom(address(this), _to, _consumableIds, _consumableAmounts);
        }
    }
}