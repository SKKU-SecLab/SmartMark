
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !Address.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


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

pragma solidity 0.8.9;


interface ICapsule is IERC721 {

    function counter() external view returns (uint256);


    function mint(address account, string memory _uri) external;


    function burn(address owner, uint256 tokenId) external;


    function exists(uint256 tokenId) external view returns (bool);


    function isCollectionMinter(address _account) external view returns (bool);


    function setTokenURI(uint256 _tokenId, string memory _newTokenURI) external;


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity 0.8.9;

interface IGovernable {

    function governor() external view returns (address _governor);


    function transferGovernorship(address _proposedGovernor) external;

}// MIT

pragma solidity 0.8.9;


interface ICapsuleFactory is IGovernable {

    function capsuleMinter() external view returns (address);


    function createCapsuleCollection(
        string memory _name,
        string memory _symbol,
        address _tokenURIOwner,
        bool _isCollectionPrivate
    ) external payable returns (address);


    function getAllCapsuleCollections() external view returns (address[] memory);


    function getCapsuleCollectionsOf(address _owner) external view returns (address[] memory);


    function getBlacklist() external view returns (address[] memory);


    function getWhitelist() external view returns (address[] memory);


    function isCapsule(address _capsule) external view returns (bool);


    function isBlacklisted(address _user) external view returns (bool);


    function isWhitelisted(address _user) external view returns (bool);


    function taxCollector() external view returns (address);


    function VERSION() external view returns (string memory);


    function addToWhitelist(address _user) external;


    function removeFromWhitelist(address _user) external;


    function addToBlacklist(address _user) external;


    function removeFromBlacklist(address _user) external;


    function flushTaxAmount() external;


    function setCapsuleMinter(address _newCapsuleMinter) external;


    function updateCapsuleCollectionOwner(address _previousOwner, address _newOwner) external;


    function updateCapsuleCollectionTax(uint256 _newTax) external;


    function updateTaxCollector(address _newTaxCollector) external;

}// MIT

pragma solidity 0.8.9;


interface ICapsuleMinter is IGovernable {

    struct SingleERC20Capsule {
        address tokenAddress;
        uint256 tokenAmount;
    }

    struct MultiERC20Capsule {
        address[] tokenAddresses;
        uint256[] tokenAmounts;
    }

    struct SingleERC721Capsule {
        address tokenAddress;
        uint256 id;
    }

    struct MultiERC721Capsule {
        address[] tokenAddresses;
        uint256[] ids;
    }

    function getMintWhitelist() external view returns (address[] memory);


    function getCapsuleOwner(address _capsule, uint256 _id) external view returns (address);


    function isMintWhitelisted(address _user) external view returns (bool);


    function multiERC20Capsule(address _capsule, uint256 _id) external view returns (MultiERC20Capsule memory _data);


    function multiERC721Capsule(address _capsule, uint256 _id) external view returns (MultiERC721Capsule memory _data);


    function singleERC20Capsule(address _capsule, uint256 _id) external view returns (address _token, uint256 _amount);


    function mintSimpleCapsule(
        address _capsule,
        string memory _uri,
        address _receiver
    ) external payable;


    function burnSimpleCapsule(address _capsule, uint256 _id) external;


    function mintSingleERC20Capsule(
        address _capsule,
        address _token,
        uint256 _amount,
        string memory _uri,
        address _receiver
    ) external payable;


    function burnSingleERC20Capsule(address _capsule, uint256 _id) external;


    function mintSingleERC721Capsule(
        address _capsule,
        address _token,
        uint256 _id,
        string memory _uri,
        address _receiver
    ) external payable;


    function burnSingleERC721Capsule(address _capsule, uint256 _id) external;


    function mintMultiERC20Capsule(
        address _capsule,
        address[] memory _tokens,
        uint256[] memory _amounts,
        string memory _uri,
        address _receiver
    ) external payable;


    function burnMultiERC20Capsule(address _capsule, uint256 _id) external;


    function mintMultiERC721Capsule(
        address _capsule,
        address[] memory _tokens,
        uint256[] memory _ids,
        string memory _uri,
        address _receiver
    ) external payable;


    function burnMultiERC721Capsule(address _capsule, uint256 _id) external;


    function addToWhitelist(address _user) external;


    function removeFromWhitelist(address _user) external;


    function flushTaxAmount() external;


    function updateCapsuleMintTax(uint256 _newTax) external;

}// BUSL-1.1

pragma solidity 0.8.9;


abstract contract CapsuleMinterStorage is ICapsuleMinter {
    ICapsuleFactory public factory;

    uint256 public capsuleMintTax;

    mapping(address => mapping(uint256 => bool)) public isSimpleCapsule;
    mapping(address => mapping(uint256 => SingleERC20Capsule)) public singleERC20Capsule;
    mapping(address => mapping(uint256 => SingleERC721Capsule)) public singleERC721Capsule;

    mapping(address => mapping(uint256 => MultiERC20Capsule)) internal _multiERC20Capsule;

    mapping(address => mapping(uint256 => MultiERC721Capsule)) internal _multiERC721Capsule;

    EnumerableSet.AddressSet internal mintWhitelist;
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity 0.8.9;


abstract contract Governable is IGovernable, Context, Initializable {
    address public governor;
    address private proposedGovernor;

    event UpdatedGovernor(address indexed previousGovernor, address indexed proposedGovernor);

    constructor() {
        address msgSender = _msgSender();
        governor = msgSender;
        emit UpdatedGovernor(address(0), msgSender);
    }

    function __Governable_init() internal onlyInitializing {
        address msgSender = _msgSender();
        governor = msgSender;
        emit UpdatedGovernor(address(0), msgSender);
    }

    modifier onlyGovernor() {
        require(governor == _msgSender(), "not governor");
        _;
    }

    function transferGovernorship(address _proposedGovernor) external onlyGovernor {
        require(_proposedGovernor != address(0), "invalid proposed governor");
        proposedGovernor = _proposedGovernor;
    }

    function acceptGovernorship() external {
        require(proposedGovernor == _msgSender(), "not the proposed governor");
        emit UpdatedGovernor(governor, proposedGovernor);
        governor = proposedGovernor;
        proposedGovernor = address(0);
    }

    uint256[49] private __gap;
}// BUSL-1.1
pragma solidity 0.8.9;

library Errors {

    string public constant INVALID_TOKEN_AMOUNT = "1"; // Input token amount must be greater than 0
    string public constant INVALID_TOKEN_ADDRESS = "2"; // Input token address is zero
    string public constant INVALID_TOKEN_ARRAY_LENGTH = "3"; // Invalid tokenAddresses array length. 0 < length <= 100. Max 100 elements
    string public constant INVALID_AMOUNT_ARRAY_LENGTH = "4"; // Invalid tokenAmounts array length. 0 < length <= 100. Max 100 elements
    string public constant INVALID_IDS_ARRAY_LENGTH = "5"; // Invalid tokenIds array length. 0 < length <= 100. Max 100 elements
    string public constant LENGTH_MISMATCH = "6"; // Array length must be same
    string public constant NOT_NFT_OWNER = "7"; // Caller/Minter is not NFT owner
    string public constant NOT_CAPSULE = "8"; // Provided address or caller is not a valid Capsule address
    string public constant NOT_MINTER = "9"; // Provided address or caller is not Capsule minter
    string public constant NOT_COLLECTION_MINTER = "10"; // Provided address or caller is not collection minter
    string public constant ZERO_ADDRESS = "11"; // Input/provided address is zero.
    string public constant NON_ZERO_ADDRESS = "12"; // Address under check must be 0
    string public constant SAME_AS_EXISTING = "13"; // Provided address/value is same as stored in state
    string public constant NOT_SIMPLE_CAPSULE = "14"; // Provided Capsule id is not simple Capsule
    string public constant NOT_ERC20_CAPSULE_ID = "15"; // Provided token id is not the id of single/multi ERC20 Capsule
    string public constant NOT_ERC721_CAPSULE_ID = "16"; // Provided token id is not the id of single/multi ERC721 Capsule
    string public constant ADDRESS_DOES_NOT_EXIST = "17"; // Provided address does not exist in valid address list
    string public constant ADDRESS_ALREADY_EXIST = "18"; // Provided address does exist in valid address lists
    string public constant INCORRECT_TAX_AMOUNT = "19"; // Tax amount is incorrect
    string public constant UNAUTHORIZED = "20"; // Caller is not authorized to perform this task
    string public constant BLACKLISTED = "21"; // Caller is blacklisted and can not interact with Capsule protocol
    string public constant WHITELISTED = "22"; // Caller is whitelisted
    string public constant NOT_TOKEN_URI_OWNER = "23"; // Provided address or caller is not tokenUri owner
}// BUSL-1.1

pragma solidity 0.8.9;


contract CapsuleMinter is Initializable, Governable, ReentrancyGuard, IERC721Receiver, CapsuleMinterStorage {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    string public constant VERSION = "1.0.0";
    uint256 public constant TOKEN_TYPE_LIMIT = 100;
    uint256 internal constant MAX_CAPSULE_MINT_TAX = 0.1 ether;

    event AddedToWhitelist(address indexed user);
    event RemovedFromWhitelist(address indexed user);
    event FlushedTaxAmount(uint256 taxAmount);
    event CapsuleMintTaxUpdated(uint256 oldMintTax, uint256 newMintTax);
    event SimpleCapsuleMinted(address indexed account, address indexed capsule, string uri);
    event SimpleCapsuleBurnt(address indexed account, address indexed capsule, string uri);
    event SingleERC20CapsuleMinted(
        address indexed account,
        address indexed capsule,
        address indexed token,
        uint256 amount,
        string uri
    );
    event SingleERC20CapsuleBurnt(
        address indexed account,
        address indexed capsule,
        address indexed token,
        uint256 amount,
        string uri
    );
    event SingleERC721CapsuleMinted(
        address indexed account,
        address indexed capsule,
        address indexed token,
        uint256 id,
        string uri
    );
    event SingleERC721CapsuleBurnt(
        address indexed account,
        address indexed capsule,
        address indexed token,
        uint256 id,
        string uri
    );
    event MultiERC20CapsuleMinted(
        address indexed account,
        address indexed capsule,
        address[] tokens,
        uint256[] amounts,
        string uri
    );
    event MultiERC20CapsuleBurnt(
        address indexed account,
        address indexed capsule,
        address[] tokens,
        uint256[] amounts,
        string uri
    );
    event MultiERC721CapsuleMinted(
        address indexed account,
        address indexed capsule,
        address[] tokens,
        uint256[] ids,
        string uri
    );
    event MultiERC721CapsuleBurnt(
        address indexed account,
        address indexed capsule,
        address[] tokens,
        uint256[] ids,
        string uri
    );

    function initialize(address _factory) external initializer {

        require(_factory != address(0), Errors.ZERO_ADDRESS);
        __Governable_init();
        factory = ICapsuleFactory(_factory);
        capsuleMintTax = 0.001 ether;
    }

    modifier checkStatus() {

        if (!mintWhitelist.contains(_msgSender())) {
            require(msg.value == capsuleMintTax, Errors.INCORRECT_TAX_AMOUNT);
        }
        _;
    }

    modifier onlyValidCapsuleCollections(address _capsule) {

        require(factory.isCapsule(_capsule), Errors.NOT_CAPSULE);
        _;
    }

    modifier onlyCollectionMinter(address _capsule) {

        require(factory.isCapsule(_capsule), Errors.NOT_CAPSULE);
        require(ICapsule(_capsule).isCollectionMinter(_msgSender()), Errors.NOT_COLLECTION_MINTER);
        _;
    }


    function getCapsuleOwner(address _capsule, uint256 _id) external view returns (address) {

        return ICapsule(_capsule).ownerOf(_id);
    }

    function getMintWhitelist() external view returns (address[] memory) {

        return mintWhitelist.values();
    }

    function multiERC20Capsule(address _capsule, uint256 _id) external view returns (MultiERC20Capsule memory _data) {

        return _multiERC20Capsule[_capsule][_id];
    }

    function multiERC721Capsule(address _capsule, uint256 _id) external view returns (MultiERC721Capsule memory _data) {

        return _multiERC721Capsule[_capsule][_id];
    }

    function isMintWhitelisted(address _user) external view returns (bool) {

        return mintWhitelist.contains(_user);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return 0x150b7a02;
    }

    function mintSimpleCapsule(
        address _capsule,
        string calldata _uri,
        address _receiver
    ) external payable nonReentrant onlyCollectionMinter(_capsule) checkStatus {

        isSimpleCapsule[_capsule][ICapsule(_capsule).counter()] = true;
        ICapsule(_capsule).mint(_receiver, _uri);
        emit SimpleCapsuleMinted(_receiver, _capsule, _uri);
    }

    function burnSimpleCapsule(address _capsule, uint256 _id)
        external
        nonReentrant
        onlyValidCapsuleCollections(_capsule)
    {

        require(isSimpleCapsule[_capsule][_id], Errors.NOT_SIMPLE_CAPSULE);
        delete isSimpleCapsule[_capsule][_id];
        emit SimpleCapsuleBurnt(_msgSender(), _capsule, ICapsule(_capsule).tokenURI(_id));
        ICapsule(_capsule).burn(_msgSender(), _id);
    }

    function mintSingleERC20Capsule(
        address _capsule,
        address _token,
        uint256 _amount,
        string calldata _uri,
        address _receiver
    ) external payable nonReentrant onlyCollectionMinter(_capsule) checkStatus {

        require(_amount > 0, Errors.INVALID_TOKEN_AMOUNT);
        require(_token != address(0), Errors.INVALID_TOKEN_ADDRESS);

        uint256 id = ICapsule(_capsule).counter();

        uint256 _actualAmount = _depositToken(IERC20(_token), _msgSender(), _amount);

        singleERC20Capsule[_capsule][id].tokenAddress = _token;
        singleERC20Capsule[_capsule][id].tokenAmount = _actualAmount;
        ICapsule(_capsule).mint(_receiver, _uri);

        emit SingleERC20CapsuleMinted(_receiver, _capsule, _token, _amount, _uri);
    }

    function burnSingleERC20Capsule(address _capsule, uint256 _id)
        external
        nonReentrant
        onlyValidCapsuleCollections(_capsule)
    {

        SingleERC20Capsule memory _capsuleData = singleERC20Capsule[_capsule][_id];
        require(_capsuleData.tokenAmount > 0, Errors.NOT_ERC20_CAPSULE_ID);

        address heldTokenAddress = _capsuleData.tokenAddress;
        uint256 tokensHeldById = _capsuleData.tokenAmount;
        delete singleERC20Capsule[_capsule][_id];

        string memory uri = ICapsule(_capsule).tokenURI(_id);
        ICapsule(_capsule).burn(_msgSender(), _id);

        IERC20(heldTokenAddress).safeTransfer(_msgSender(), tokensHeldById);
        emit SingleERC20CapsuleBurnt(_msgSender(), _capsule, heldTokenAddress, tokensHeldById, uri);
    }

    function mintSingleERC721Capsule(
        address _capsule,
        address _token,
        uint256 _id,
        string calldata _uri,
        address _receiver
    ) external payable nonReentrant onlyCollectionMinter(_capsule) checkStatus {

        uint256 capsuleId = ICapsule(_capsule).counter();

        IERC721(_token).safeTransferFrom(_msgSender(), address(this), _id);

        require(IERC721(_token).ownerOf(_id) == address(this), Errors.NOT_NFT_OWNER);

        singleERC721Capsule[_capsule][capsuleId].tokenAddress = _token;
        singleERC721Capsule[_capsule][capsuleId].id = _id;
        ICapsule(_capsule).mint(_receiver, _uri);

        emit SingleERC721CapsuleMinted(_receiver, _capsule, _token, _id, _uri);
    }

    function burnSingleERC721Capsule(address _capsule, uint256 _id)
        external
        nonReentrant
        onlyValidCapsuleCollections(_capsule)
    {

        SingleERC721Capsule memory _capsuleData = singleERC721Capsule[_capsule][_id];
        require(_capsuleData.tokenAddress != address(0), Errors.NOT_ERC721_CAPSULE_ID);

        address heldTokenAddress = _capsuleData.tokenAddress;
        uint256 tokenId = _capsuleData.id;
        delete singleERC721Capsule[_capsule][_id];

        string memory uri = ICapsule(_capsule).tokenURI(_id);
        ICapsule(_capsule).burn(_msgSender(), _id);
        IERC721(heldTokenAddress).safeTransferFrom(address(this), _msgSender(), tokenId);

        emit SingleERC721CapsuleBurnt(_msgSender(), _capsule, heldTokenAddress, tokenId, uri);
    }

    function mintMultiERC20Capsule(
        address _capsule,
        address[] calldata _tokens,
        uint256[] calldata _amounts,
        string calldata _uri,
        address _receiver
    ) external payable nonReentrant onlyCollectionMinter(_capsule) checkStatus {

        uint256 tokensLength = _tokens.length;

        require(tokensLength > 0 && tokensLength <= TOKEN_TYPE_LIMIT, Errors.INVALID_TOKEN_ARRAY_LENGTH);
        require(_amounts.length > 0 && _amounts.length <= TOKEN_TYPE_LIMIT, Errors.INVALID_AMOUNT_ARRAY_LENGTH);
        require(tokensLength == _amounts.length, Errors.LENGTH_MISMATCH);

        uint256 _id = ICapsule(_capsule).counter();
        uint256[] memory _actualAmounts = new uint256[](tokensLength);
        for (uint256 i; i < tokensLength; i++) {
            address _token = _tokens[i];
            uint256 _amount = _amounts[i];

            require(_amount > 0, Errors.INVALID_TOKEN_AMOUNT);
            require(_token != address(0), Errors.INVALID_TOKEN_ADDRESS);

            _actualAmounts[i] = _depositToken(IERC20(_token), _msgSender(), _amount);
        }

        _multiERC20Capsule[_capsule][_id].tokenAddresses = _tokens;
        _multiERC20Capsule[_capsule][_id].tokenAmounts = _actualAmounts;

        ICapsule(_capsule).mint(_receiver, _uri);

        emit MultiERC20CapsuleMinted(_receiver, _capsule, _tokens, _amounts, _uri);
    }

    function burnMultiERC20Capsule(address _capsule, uint256 _id)
        external
        nonReentrant
        onlyValidCapsuleCollections(_capsule)
    {

        address[] memory tokens = _multiERC20Capsule[_capsule][_id].tokenAddresses;
        uint256[] memory amounts = _multiERC20Capsule[_capsule][_id].tokenAmounts;
        require(tokens.length > 0, Errors.NOT_ERC20_CAPSULE_ID);

        delete _multiERC20Capsule[_capsule][_id];

        string memory uri = ICapsule(_capsule).tokenURI(_id);
        ICapsule(_capsule).burn(_msgSender(), _id);

        for (uint256 i; i < tokens.length; i++) {
            IERC20(tokens[i]).safeTransfer(_msgSender(), amounts[i]);
        }

        emit MultiERC20CapsuleBurnt(_msgSender(), _capsule, tokens, amounts, uri);
    }

    function mintMultiERC721Capsule(
        address _capsule,
        address[] calldata _tokens,
        uint256[] calldata _ids,
        string calldata _uri,
        address _receiver
    ) external payable nonReentrant onlyCollectionMinter(_capsule) checkStatus {

        uint256 tokensLength = _tokens.length;
        uint256 idsLength = _ids.length;

        require(tokensLength > 0 && tokensLength <= TOKEN_TYPE_LIMIT, Errors.INVALID_TOKEN_ARRAY_LENGTH);
        require(idsLength > 0 && idsLength <= TOKEN_TYPE_LIMIT, Errors.INVALID_IDS_ARRAY_LENGTH);
        require(tokensLength == idsLength, Errors.LENGTH_MISMATCH);

        uint256 _capsuleId = ICapsule(_capsule).counter();

        for (uint256 i; i < tokensLength; i++) {
            address _token = _tokens[i];
            uint256 _id = _ids[i];

            require(_token != address(0), Errors.INVALID_TOKEN_ADDRESS);

            IERC721(_token).safeTransferFrom(_msgSender(), address(this), _id);

            require(IERC721(_token).ownerOf(_id) == address(this), Errors.NOT_NFT_OWNER);
        }

        _multiERC721Capsule[_capsule][_capsuleId].tokenAddresses = _tokens;
        _multiERC721Capsule[_capsule][_capsuleId].ids = _ids;

        ICapsule(_capsule).mint(_receiver, _uri);

        emit MultiERC721CapsuleMinted(_receiver, _capsule, _tokens, _ids, _uri);
    }

    function burnMultiERC721Capsule(address _capsule, uint256 _id)
        external
        nonReentrant
        onlyValidCapsuleCollections(_capsule)
    {

        address[] memory tokens = _multiERC721Capsule[_capsule][_id].tokenAddresses;
        uint256[] memory ids = _multiERC721Capsule[_capsule][_id].ids;
        require(tokens.length > 0, Errors.NOT_ERC721_CAPSULE_ID);

        delete _multiERC721Capsule[_capsule][_id];

        string memory uri = ICapsule(_capsule).tokenURI(_id);
        ICapsule(_capsule).burn(_msgSender(), _id);

        for (uint256 i; i < tokens.length; i++) {
            IERC721(tokens[i]).safeTransferFrom(address(this), _msgSender(), ids[i]);
        }

        emit MultiERC721CapsuleBurnt(_msgSender(), _capsule, tokens, ids, uri);
    }

    function flushTaxAmount() external {

        address _taxCollector = factory.taxCollector();
        require(_msgSender() == governor || _msgSender() == _taxCollector, Errors.UNAUTHORIZED);
        uint256 _taxAmount = address(this).balance;
        emit FlushedTaxAmount(_taxAmount);
        Address.sendValue(payable(_taxCollector), _taxAmount);
    }

    function addToWhitelist(address _user) external onlyGovernor {

        require(_user != address(0), Errors.ZERO_ADDRESS);
        require(mintWhitelist.add(_user), Errors.ADDRESS_ALREADY_EXIST);
        emit AddedToWhitelist(_user);
    }

    function removeFromWhitelist(address _user) external onlyGovernor {

        require(_user != address(0), Errors.ZERO_ADDRESS);
        require(mintWhitelist.remove(_user), Errors.ADDRESS_DOES_NOT_EXIST);
        emit RemovedFromWhitelist(_user);
    }

    function updateCapsuleMintTax(uint256 _newTax) external onlyGovernor {

        require(_newTax <= MAX_CAPSULE_MINT_TAX, Errors.INCORRECT_TAX_AMOUNT);
        require(_newTax != capsuleMintTax, Errors.SAME_AS_EXISTING);
        emit CapsuleMintTaxUpdated(capsuleMintTax, _newTax);
        capsuleMintTax = _newTax;
    }

    function _depositToken(
        IERC20 _token,
        address _depositor,
        uint256 _amount
    ) internal returns (uint256 _actualAmount) {

        uint256 _balanceBefore = _token.balanceOf(address(this));
        _token.safeTransferFrom(_depositor, address(this), _amount);
        _actualAmount = _token.balanceOf(address(this)) - _balanceBefore;
    }
}