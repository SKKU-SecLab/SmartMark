
pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;


interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

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

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
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


abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function __AccessControlEnumerable_init_unchained() internal onlyInitializing {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
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

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}//MIT
pragma solidity ^0.8.9;


contract UtilitiesV2Upgradeable is Initializable, AccessControlEnumerableUpgradeable, PausableUpgradeable {


    bytes32 internal constant OWNER_ROLE = keccak256("OWNER");
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 internal constant ROLE_GRANTER_ROLE = keccak256("ROLE_GRANTER");

    function __Utilities_init() internal onlyInitializing {

        AccessControlEnumerableUpgradeable.__AccessControlEnumerable_init();
        PausableUpgradeable.__Pausable_init();

        __Utilities_init_unchained();
    }

    function __Utilities_init_unchained() internal onlyInitializing {

        _pause();

        _grantRole(OWNER_ROLE, msg.sender);
    }

    function setPause(bool _shouldPause) external requiresEitherRole(ADMIN_ROLE, OWNER_ROLE) {

        if(_shouldPause) {
            _pause();
        } else {
            _unpause();
        }
    }

    function grantRole(bytes32 _role, address _account) public override requiresEitherRole(ROLE_GRANTER_ROLE, OWNER_ROLE) {

        require(_role != OWNER_ROLE, "Cannot change owner role through grantRole");
        _grantRole(_role, _account);
    }

    function revokeRole(bytes32 _role, address _account) public override requiresEitherRole(ROLE_GRANTER_ROLE, OWNER_ROLE) {

        require(_role != OWNER_ROLE, "Cannot change owner role through grantRole");
        _revokeRole(_role, _account);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {

        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    modifier onlyEOA() {

        require(msg.sender == tx.origin, "No contracts");
        _;
    }

    modifier requiresRole(bytes32 _role) {

        require(hasRole(_role, msg.sender), "Does not have required role");
        _;
    }

    modifier requiresEitherRole(bytes32 _roleOption1, bytes32 _roleOption2) {

        require(hasRole(_roleOption1, msg.sender) || hasRole(_roleOption2, msg.sender), "Does not have required role");

        _;
    }
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

interface ISwiperSwiping {


}//MIT
pragma solidity ^0.8.0;



abstract contract SwiperSwipingState is Initializable, ISwiperSwiping, UtilitiesV2Upgradeable {

    IWnDRoot public wnd;
    address public tower1Address;
    address public tower2Address;

    bytes32 public merkleRootTower1;
    bytes32 public merkleRootTower2;

    mapping(address => SwiperInfo) internal addressToClaimInfoTower1;
    mapping(address => SwiperInfo) internal addressToClaimInfoTower2;

    uint8 public maxBatchSize;

    function __SwiperSwipingState_init() internal initializer {
        UtilitiesV2Upgradeable.__Utilities_init();
        maxBatchSize = 10;
    }
}

struct SwiperInfo {
    bool hasClaimedAll;
    EnumerableSetUpgradeable.UintSet tokenIdsClaimed;
}//MIT
pragma solidity ^0.8.0;



abstract contract SwiperSwipingContracts is Initializable, SwiperSwipingState {

    function __SwiperSwipingContracts_init() internal initializer {
        SwiperSwipingState.__SwiperSwipingState_init();
    }

    function setContracts(address _wndAddress, address _tower1Address, address _tower2Address) external requiresEitherRole(ADMIN_ROLE, OWNER_ROLE) {
        wnd = IWnDRoot(_wndAddress);
        tower1Address = _tower1Address;
        tower2Address = _tower2Address;
    }

    modifier contractsAreSet() {
        require(areContractsSet(), "Contracts aren't set");
        _;
    }

    function areContractsSet() public view returns(bool) {
        return address(wnd) != address(0) && tower1Address != address(0) && tower2Address != address(0);
    }
}//MIT
pragma solidity ^0.8.0;



abstract contract SwiperSwipingSetup is Initializable, SwiperSwipingContracts {

    function __SwiperSwipingSetup_init() internal initializer {
        SwiperSwipingContracts.__SwiperSwipingContracts_init();
    }

    function setMerkleRootTower1(bytes32 _merkleRoot) external requiresEitherRole(ADMIN_ROLE, OWNER_ROLE) {
        merkleRootTower1 = _merkleRoot;
    }

    function setMerkleRootTower2(bytes32 _merkleRoot) external requiresEitherRole(ADMIN_ROLE, OWNER_ROLE) {
        merkleRootTower2 = _merkleRoot;
    }

    function setMaxBatchSize(uint8 _maxBatchSize) external requiresEitherRole(ADMIN_ROLE, OWNER_ROLE) {
        maxBatchSize = _maxBatchSize;
    }
}//MIT
pragma solidity ^0.8.0;



contract SwiperSwiping is Initializable, SwiperSwipingSetup {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    function initialize() external initializer {

        SwiperSwipingSetup.__SwiperSwipingSetup_init();
    }

    function claimTower1(RescueTokenParams[] calldata _tokenIds) external {

        _claim(_tokenIds, true);
    }

    function claimTower2(RescueTokenParams[] calldata _tokenIds) external {

        _claim(_tokenIds, false);
    }

    function getTokenIdsToClaimTower1(address _addr, uint256[] calldata _tokenIds) public view returns (uint256[] memory) {

        return _getTokenIdsToClaim(_addr, _tokenIds, true);
    }

    function getTokenIdsToClaimTower2(address _addr, uint256[] calldata _tokenIds) public view returns (uint256[] memory) {

        return _getTokenIdsToClaim(_addr, _tokenIds, false);
    }

    function _claim(RescueTokenParams[] memory _tokenIds, bool isTower1) internal {

        require(_tokenIds.length > 0, "No tokens given");
        SwiperInfo storage info = isTower1 ? addressToClaimInfoTower1[msg.sender] : addressToClaimInfoTower2[msg.sender];
        bytes32 _merkleRoot = isTower1 ? merkleRootTower1 : merkleRootTower2;
        address _towerAddress = isTower1 ? tower1Address : tower2Address;


        uint256 _counter;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _token = _tokenIds[i].tokenId;
            if(info.tokenIdsClaimed.contains(_token) || wnd.ownerOf(_token) != _towerAddress) {
                continue;
            }
            bytes32 _leaf = keccak256(abi.encodePacked(msg.sender, _token));

            require(
                MerkleProof.verify(_tokenIds[i].proof, _merkleRoot, _leaf),
                "Proof invalid"
            );
            info.tokenIdsClaimed.add(_token);
            wnd.transferFrom(_towerAddress, msg.sender, _token);
            if(++_counter == maxBatchSize) {
                return;
            }
        }
        require(_counter > 0, "no tokens were rescued");
    }

    function _getTokenIdsToClaim(address _addr, uint256[] calldata _tokenIds, bool isTower1) internal view returns(uint256[] memory) {

        SwiperInfo storage info = isTower1 ? addressToClaimInfoTower1[_addr] : addressToClaimInfoTower2[_addr];
        uint256[] memory _retVal = new uint256[] (_tokenIds.length);
        uint256 _counter = 0;
        if(info.hasClaimedAll) {
            return _retVal;
        }
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 _token = _tokenIds[i];
            if(!info.tokenIdsClaimed.contains(_token)) {
                _retVal[_counter++] = _token;
            }
        }
        return _retVal;
    }

    
}

struct RescueTokenParams {
    uint256 tokenId;
    bytes32[] proof;
}