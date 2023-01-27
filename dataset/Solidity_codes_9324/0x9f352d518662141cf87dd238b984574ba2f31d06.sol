
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

library ClonesUpgradeable {

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
}// Apache-2.0
pragma solidity 0.8.10;

interface IBaseToken {

    function initialize(
        string memory name_,
        string memory symbol_
    ) external;

    function grantRole(bytes32 role, address account) external;

    function DEFAULT_ADMIN_ROLE() external returns(bytes32);

    function MINTER_ROLE() external returns(bytes32);

    function mint(address to) external;

    function totalMinted() external returns (uint256);

    function maxSupply() external returns (uint256);

    function setBaseURI(string memory baseURI_) external;

    function setTokenURI(uint256 tokenId, string memory newTokenURI) external;

    function getUserBalance(address user) external view returns (uint256);

    function getTokenOfUserByIndex(address user, uint256 index) external view returns (uint256);

    function transferOwnership(address newOwner) external;

}// Apache-2.0
pragma solidity 0.8.10;

interface IMinter {

    function initialize(
        address _tokenContract,
        address[] memory payees,
        uint256[] memory shares_
    ) external;

    function grantRole(bytes32 role, address account) external;

    function ADMIN_ROLE() external returns(bytes32);

    function DEFAULT_ADMIN_ROLE() external returns(bytes32);

    function mint(uint256 numberOfTokens) external payable;

}// Apache-2.0
pragma solidity 0.8.10;



contract Registry is Initializable, AccessControlEnumerableUpgradeable {



    enum ProjectStatus { Locked, Whitelist, Active, WhitelistByToken }
    enum ProjectType { Land, Buildings, Pets, Items }

    struct Project {
        ProjectDetail detail;
        ProjectMint minting;
    }

    struct KingdomDetail {
        string name;
        string kingdomImage;
        string description;
        bytes32 kingdomHash;
    }

    struct ProjectDetail {
        ProjectType projectType;
        uint128 kingdomIdx;
        string name;
        string symbol;
        string description;
        string license;
    }

    struct ProjectMint {
        uint256 maxSupply;
        uint256 maxBlockPurchase;
        uint256 maxWalletPurchase;
        uint256 price;
        address minter;
        address baseTokenImplementation;
        address staking;
        bool isFreeMint;
        ProjectStatus status;
    }



    mapping(address => Project) public projects;
    address[] public projectIdToAddress;
    KingdomDetail[] public kingdoms;



    event LogProjectCreated(address indexed project);
    event LogMinterCreated(address indexed minter);
    event LogKingdomCreated(uint256 indexed kingdomIdx, bytes32 indexed kingdomHash);



    modifier onlyRegistryAdminOrProjectAdmin(address project) {

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) || hasRole(getProjectAdminRole(project), _msgSender()),
            "onlyRegistryAdminOrProjectAdmin: caller is not the Registry or Project or admin");
        _;
    }

    modifier onlyDefaultAdmin() {

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "onlyDefaultAdmin: caller is not the admin");
        _;
    }



    function initialize() public initializer {


        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }



    function getProjectAdminRole(address project)
        public
        pure
        returns(bytes32)
    {

        return keccak256(abi.encodePacked("ADMIN_ROLE", project));
    }

    function getProjectMinter(address project)
        public
        view
        returns(address)
    {

        return projects[project].minting.minter;
    }

    function getProject(address project)
        public
        view
        returns(Project memory)
    {

        Project memory res = projects[project];
        return res;
    }

    function getKingdom(uint256 kingdomIdx)
        public
        view
        returns(KingdomDetail memory)
    {

        KingdomDetail memory res = kingdoms[kingdomIdx];
        return res;
    }

    function getProjectDetail(address project)
        public
        view
        returns(ProjectDetail memory)
    {

        ProjectDetail memory res = projects[project].detail;
        return res;
    }

    function getProjectMinting(address project)
        public
        view
        returns(ProjectMint memory)
    {

        ProjectMint memory res = projects[project].minting;
        return res;
    }

    function getProjectStatus(address project)
        public
        view
        returns(ProjectStatus)
    {

        return projects[project].minting.status;
    }

    function getProjectPrice(address project)
        public
        view
        returns(uint256)
    {

        return projects[project].minting.price;
    }

    function getProjectMaxSupply(address project)
        public
        view
        returns(uint256)
    {

        return projects[project].minting.maxSupply;
    }

    function getProjectMaxBlockPurchase(address project)
        public
        view
        returns(uint256)
    {

        return projects[project].minting.maxBlockPurchase;
    }

    function getProjectMaxWalletPurchase(address project)
        public
        view
        returns(uint256)
    {

        return projects[project].minting.maxWalletPurchase;
    }

    function getProjectFreeStatus(address project)
       public
       view
       returns(bool)
   {

       return projects[project].minting.isFreeMint;
   }

    function getProjectLicense(address project)
       public
       view
       returns(string memory)
   {

        return projects[project].detail.license;
   }

    function getNumbProjects()
        public
        view
        returns(uint256)
    {

        return projectIdToAddress.length;
    }



    function createKingdom(KingdomDetail calldata kingdom)
        external
        onlyDefaultAdmin
    {

        kingdoms.push(kingdom);

        unchecked {
            emit LogKingdomCreated(kingdoms.length - 1, kingdom.kingdomHash);
        }
    }

    function createProject(ProjectDetail calldata projectDetail, ProjectMint calldata projectMint, address owner, bytes32 kingdomHash)
        public
        onlyDefaultAdmin
    {

        require(projectMint.baseTokenImplementation != address(0), "createProject: baseTokenImplementation not set");
        require(kingdomHash == kingdoms[projectDetail.kingdomIdx].kingdomHash, "createProject: kingdom mismatch");
        IBaseToken projectContract = IBaseToken(ClonesUpgradeable.clone(projectMint.baseTokenImplementation));
        projectContract.initialize(projectDetail.name, projectDetail.symbol);

        address projectAddress = address(projectContract);
        projectIdToAddress.push(projectAddress);

        projects[projectAddress].detail = projectDetail;
        projects[projectAddress].minting = projectMint;

        address admin = getRoleMember(DEFAULT_ADMIN_ROLE, 0);
        projectContract.grantRole(
            projectContract.DEFAULT_ADMIN_ROLE(),
            admin
        );

        projectContract.transferOwnership(owner);

        emit LogProjectCreated(address(projectContract));
    }

    function createMinter(
        address project,
        address minterImplementation,
        address[] memory payees,
        uint256[] memory shares
    )
        public
        onlyDefaultAdmin
    {

        require(minterImplementation != address(0), "createMinter: minterImplementation not set");

        IMinter minterContract = IMinter(ClonesUpgradeable.clone(minterImplementation));
        minterContract.initialize(project, payees, shares);

        IBaseToken(project).grantRole(
            IBaseToken(project).MINTER_ROLE(),
            address(minterContract)
        );

        minterContract.grantRole(
            minterContract.ADMIN_ROLE(),
            getRoleMember(DEFAULT_ADMIN_ROLE, 0)
        );
        minterContract.grantRole(
            minterContract.DEFAULT_ADMIN_ROLE(),
            getRoleMember(DEFAULT_ADMIN_ROLE, 0)
        );

        projects[project].minting.minter = address(minterContract);

        emit LogMinterCreated(address(minterContract));
    }

    function addProjectAdmin(address project, address admin)
        public
        onlyDefaultAdmin
    {

        _grantRole(getProjectAdminRole(project), admin);

        IBaseToken(project).grantRole(
            IBaseToken(project).DEFAULT_ADMIN_ROLE(),
            admin
        );

        address minter = projects[project].minting.minter;
        require(minter != address(0),
            "addProjectAdmin: Deploy minter first"
        );
        IMinter(payable(minter)).grantRole(IMinter(payable(minter)).ADMIN_ROLE(), admin);

    }



    function updateProjectMinting(address project, ProjectMint memory info)
        public
        onlyRegistryAdminOrProjectAdmin(project)
    {

        projects[project].minting = info;
    }

    function updateProjectInfo(address project, Project memory info)
        public
        onlyRegistryAdminOrProjectAdmin(project)
    {

        projects[project] = info;
    }

    function updateProjectDetail(address project, ProjectDetail memory info)
        public
        onlyRegistryAdminOrProjectAdmin(project)
    {

        projects[project].detail = info;
    }

    function updateProjectPrice(address project, uint256 price)
        public
        onlyRegistryAdminOrProjectAdmin(project)
    {

        projects[project].minting.price = price;
    }

    function updateProjectStatus(address project, ProjectStatus status)
        public
        onlyRegistryAdminOrProjectAdmin(project)
    {

        projects[project].minting.status = status;
    }

    function updateProjectMaxWalletPurchase(address project, uint256 maxPurchase)
        public
        onlyRegistryAdminOrProjectAdmin(project)
    {

        projects[project].minting.maxWalletPurchase = maxPurchase;
    }

    function updateProjectMaxBlockPurchase(address project, uint256 maxPurchase)
        public
        onlyRegistryAdminOrProjectAdmin(project)
    {

        projects[project].minting.maxBlockPurchase = maxPurchase;
    }

    function setBaseURI(address project, string memory baseURI_)
        external
        onlyRegistryAdminOrProjectAdmin(project)
    {

        IBaseToken(project).setBaseURI(baseURI_);
    }

    function setTokenURI(address project, uint256 tokenId, string memory newTokenURI)
        external
        onlyRegistryAdminOrProjectAdmin(project)
    {

        IBaseToken(project).setTokenURI(tokenId, newTokenURI);
    }

    function setMaxSupply(address project, uint256 supply)
        public
        onlyRegistryAdminOrProjectAdmin(project)
    {

        projects[project].minting.maxSupply = supply;
    }

    function updateProjectFreeStatus(address project, bool isFree)
        public
        onlyRegistryAdminOrProjectAdmin(project)
    {

        projects[project].minting.isFreeMint = isFree;
    }

}