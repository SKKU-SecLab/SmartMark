
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT


pragma solidity 0.6.12;


interface IERC721Token {


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    external;


    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    )
    external;


    function approve(address _approved, uint256 _tokenId)
    external;


    function setApprovalForAll(address _operator, bool _approved)
    external;


    function balanceOf(address _owner)
    external
    view
    returns (uint256);


    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    external;


    function ownerOf(uint256 _tokenId)
    external
    view
    returns (address);


    function getApproved(uint256 _tokenId)
    external
    view
    returns (address);


    function isApprovedForAll(address _owner, address _operator)
    external
    view
    returns (bool);

}// MIT


pragma solidity 0.6.12;


interface IERC721Receiver {


    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    )
    external
    returns (bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSet {


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

library Address {

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

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
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
}// MIT

pragma solidity 0.6.12;


contract HashtagAccessControls is AccessControl {

    bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER");
    bytes32 public constant SMART_CONTRACT_ROLE = keccak256("SMART_CONTRACT");

    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function isSmartContract(address _addr) public view returns (bool) {

        return hasRole(SMART_CONTRACT_ROLE, _addr);
    }

    function isAdmin(address _addr) public view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, _addr);
    }

    function isPublisher(address _addr) public view returns (bool) {

        return hasRole(PUBLISHER_ROLE, _addr);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Strings {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}// MIT

pragma solidity 0.6.12;




contract HashtagProtocol is IERC721Token, ERC165, Context {

    using SafeMath for uint256;

    event MintHashtag(
        uint256 indexed tokenId,
        string displayHashtag,
        address indexed publisher,
        address creator
    );

    event HashtagReset(
        uint256 indexed tokenId,
        address indexed owner
    );

    event HashtagRenewed(
        uint256 indexed tokenId,
        address indexed caller
    );

    event OwnershipTermLengthUpdated(
        uint256 originalOwnershipLength,
        uint256 updatedOwnershipLength
    );

    event RenewalPeriodUpdated(
        uint256 originalRenewalPeriod,
        uint256 updatedRenewalPeriod
    );

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    string public name = "Hashtag Protocol";

    string public symbol = "HASHTAG";

    uint256 public ownershipTermLength = 730 days;

    bytes4 constant internal ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

    mapping(uint256 => address) internal owners;

    mapping(uint256 => address) internal approvals;

    mapping(address => uint256) internal balances;

    mapping(address => mapping(address => bool)) internal operatorApprovals;

    string public baseURI = "https://api.hashtag-protocol.io/";

    struct Hashtag {
        address originalPublisher;
        address creator;
        string displayVersion;
    }

    uint256 public tokenPointer;

    mapping(uint256 => Hashtag) public tokenIdToHashtag;

    mapping(string => uint256) public hashtagToTokenId;

    mapping(uint256 => uint256) public tokenIdToLastTransferTime;

    address payable public platform;

    uint256 constant public hashtagMinStringLength = 3;

    uint256 public hashtagMaxStringLength = 32;

    HashtagAccessControls public accessControls;

    modifier onlyAdmin() {

        require(accessControls.isAdmin(_msgSender()), "Caller must be admin");
        _;
    }

    constructor (HashtagAccessControls _accessControls, address payable _platform) public {
        accessControls = _accessControls;
        platform = _platform;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }


    function setBaseURI(string memory _baseURI) onlyAdmin public {

        baseURI = _baseURI;
    }

    function setHashtagMaxStringLength(uint256 _hashtagMaxStringLength) onlyAdmin public {

        hashtagMaxStringLength = _hashtagMaxStringLength;
    }

    function setOwnershipTermLength(uint256 _ownershipTermLength) onlyAdmin public {

        emit OwnershipTermLengthUpdated(ownershipTermLength, _ownershipTermLength);
        ownershipTermLength = _ownershipTermLength;
    }

    function mint(string calldata _hashtag, address payable _publisher, address _creator) payable external returns (uint256 _tokenId) {

        require(accessControls.isPublisher(_publisher), "Mint: The publisher must be whitelisted");

        string memory lowerHashtagToMint = _assertHashtagIsValid(_hashtag);

        tokenPointer = tokenPointer.add(1);
        uint256 tokenId = tokenPointer;

        tokenIdToHashtag[tokenId] = Hashtag({
        displayVersion : _hashtag,
        originalPublisher : _publisher,
        creator : _creator
        });

        hashtagToTokenId[lowerHashtagToMint] = tokenId;

        emit Transfer(address(0), platform, tokenId);
        emit MintHashtag(tokenId, _hashtag, _publisher, _creator);

        return tokenId;
    }

    function setPlatform(address payable _platform) onlyAdmin external {

        platform = _platform;
    }

    function getPaymentAddresses(uint256 _tokenId) public view returns (
        address payable _platform,
        address payable _owner
    ) {

        return (
        platform,
        payable(ownerOf(_tokenId))
        );
    }

    function updateAccessControls(HashtagAccessControls _accessControls) onlyAdmin external {

        require(address(_accessControls) != address(0), "HashtagProtocol.updateAccessControls: Cannot be zero");
        accessControls = _accessControls;
    }

    function getCreatorAddress(uint256 _tokenId) public view returns (address _creator) {

        return tokenIdToHashtag[_tokenId].creator;
    }

    function exists(uint256 _tokenId) public view returns (bool) {

        return tokenIdToHashtag[_tokenId].creator != address(0);
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {

        require(tokenIdToHashtag[_tokenId].creator != address(0), "Token ID must exist");
        return string(abi.encodePacked(baseURI, Strings.toString(_tokenId)));
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    )
    override
    external
    {

        transferFrom(
            _from,
            _to,
            _tokenId
        );

        uint256 receiverCodeSize;
        assembly {
            receiverCodeSize := extcodesize(_to)
        }
        if (receiverCodeSize > 0) {
            bytes4 selector = IERC721Receiver(_to).onERC721Received(
                _msgSender(),
                _from,
                _tokenId,
                _data
            );
            require(
                selector == ERC721_RECEIVED,
                "ERC721_INVALID_SELECTOR"
            );
        }
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    override
    external
    {

        transferFrom(
            _from,
            _to,
            _tokenId
        );

        uint256 receiverCodeSize;
        assembly {
            receiverCodeSize := extcodesize(_to)
        }
        if (receiverCodeSize > 0) {
            bytes4 selector = IERC721Receiver(_to).onERC721Received(
                _msgSender(),
                _from,
                _tokenId,
                ""
            );
            require(
                selector == ERC721_RECEIVED,
                "ERC721_INVALID_SELECTOR"
            );
        }
    }

    function approve(address _approved, uint256 _tokenId)
    override
    external
    {

        address owner = ownerOf(_tokenId);
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721_INVALID_SENDER"
        );

        approvals[_tokenId] = _approved;
        emit Approval(
            owner,
            _approved,
            _tokenId
        );
    }

    function setApprovalForAll(address _operator, bool _approved)
    override
    external
    {

        operatorApprovals[_msgSender()][_operator] = _approved;
        emit ApprovalForAll(
            _msgSender(),
            _operator,
            _approved
        );
    }

    function balanceOf(address _owner)
    override
    external
    view
    returns (uint256)
    {

        require(
            _owner != address(0),
            "ERC721_ZERO_OWNER"
        );
        return balances[_owner];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    override
    public
    {

        require(
            _to != address(0),
            "ERC721_ZERO_TO_ADDRESS"
        );

        require(
            _to != platform,
            "ERC721_CANNOT_TRANSFER_TO_PLATFORM"
        );

        address owner = ownerOf(_tokenId);
        require(
            _from == owner,
            "ERC721_OWNER_MISMATCH"
        );

        address spender = _msgSender();
        address approvedAddress = getApproved(_tokenId);

        if (owner == platform) {
            require(
                spender == owner ||
                accessControls.isSmartContract(spender) ||
                isApprovedForAll(owner, spender) ||
                approvedAddress == spender,
                "ERC721_INVALID_SPENDER"
            );
        } else {
            require(
                spender == owner ||
                isApprovedForAll(owner, spender) ||
                approvedAddress == spender,
                "ERC721_INVALID_SPENDER"
            );
        }

        _transferFrom(_tokenId, approvedAddress, _to, _from);
    }

    function renewHashtag(uint256 _tokenId) external {

        require(_msgSender() == ownerOf(_tokenId), "renewHashtag: Invalid sender");

        tokenIdToLastTransferTime[_tokenId] = block.timestamp;

        emit HashtagRenewed(_tokenId, _msgSender());
    }

    function recycleHashtag(uint256 _tokenId) external {

        require(exists(_tokenId), "recycleHashtag: Invalid token ID");
        require(ownerOf(_tokenId) != platform, "recycleHashtag: Already owned by the platform");

        uint256 lastTransferTime = tokenIdToLastTransferTime[_tokenId];
        require(
            lastTransferTime.add(ownershipTermLength) < block.timestamp,
            "recycleHashtag: Token not eligible for recycling yet"
        );

        _transferFrom(_tokenId, getApproved(_tokenId), platform, ownerOf(_tokenId));

        emit HashtagReset(_tokenId, _msgSender());
    }

    function ownerOf(uint256 _tokenId)
    override
    public
    view
    returns (address)
    {

        address owner = owners[_tokenId];
        if (owner == address(0) && tokenIdToHashtag[_tokenId].creator != address(0)) {
            return platform;
        }

        require(owner != address(0), "ERC721_ZERO_OWNER");
        return owner;
    }

    function getApproved(uint256 _tokenId)
    override
    public
    view
    returns (address)
    {

        return approvals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
    override
    public
    view
    returns (bool)
    {

        return operatorApprovals[_owner][_operator];
    }

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function _assertHashtagIsValid(string memory _hashtag) private view returns (string memory) {

        bytes memory hashtagStringBytes = bytes(_hashtag);
        require(
            hashtagStringBytes.length >= hashtagMinStringLength && hashtagStringBytes.length <= hashtagMaxStringLength,
            "Invalid format: Hashtag must not exceed length requirements"
        );

        require(hashtagStringBytes[0] == 0x23, "Must start with #");

        string memory hashtagKey = _lower(_hashtag);
        require(hashtagToTokenId[hashtagKey] == 0, "Hashtag validation: Hashtag already owned.");

        uint256 alphabetCharCount = 0;
        for (uint256 i = 1; i < hashtagStringBytes.length; i++) {
            bytes1 char = hashtagStringBytes[i];

            bool isInvalidCharacter = !(char >= 0x30 && char <= 0x39) && //0-9
            !(char >= 0x41 && char <= 0x5A) && //A-Z
            !(char >= 0x61 && char <= 0x7A);

            require(!isInvalidCharacter, "Invalid character found: Hashtag may only contain characters A-Z, a-z, 0-9 and #");

            if ((char >= 0x41 && char <= 0x5A) || (char >= 0x61 && char <= 0x7A)) {
                alphabetCharCount = alphabetCharCount.add(1);
            }
        }

        require(alphabetCharCount >= 1, "Invalid format: Hashtag must contain at least 1 alphabetic character.");

        return hashtagKey;
    }

    function _lower(string memory _base) private pure returns (string memory) {

        bytes memory bStr = bytes(_base);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            if ((bStr[i] >= 0x41) && (bStr[i] <= 0x5A)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function _transferFrom(uint256 _tokenId, address _approvedAddress, address _to, address _from) private {

        if (_approvedAddress != address(0)) {
            approvals[_tokenId] = address(0);
        }

        owners[_tokenId] = _to;

        if (_from != platform) {
            balances[_from] = balances[_from].sub(1);
        }

        tokenIdToLastTransferTime[_tokenId] = block.timestamp;

        if (_to != platform) {
            balances[_to] = balances[_to].add(1);
        }

        emit Transfer(
            _from,
            _to,
            _tokenId
        );
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
    private returns (bool)
    {

        if (!isContract(to)) {
            return true;
        }
        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
                IERC721Receiver(to).onERC721Received.selector,
                _msgSender(),
                from,
                tokenId,
                _data
            ));
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == ERC721_RECEIVED);
        }
    }
}