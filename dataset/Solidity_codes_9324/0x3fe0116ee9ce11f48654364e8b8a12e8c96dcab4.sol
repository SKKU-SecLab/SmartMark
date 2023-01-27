
pragma solidity ^0.8.0;

interface IAccessControl {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

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
}// Apache-2.0
pragma solidity ^0.8.0;


interface IERC1155 {



  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;


  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;


  function balanceOf(address _owner, uint256 _id) external view returns (uint256);


  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);


  function setApprovalForAll(address _operator, bool _approved) external;


  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

}// MIT
pragma solidity ^0.8.0;


interface IERC1155Tradable is IERC1155 {


    function create(address _initialOwner, uint256 _initialSupply) external returns (uint256);


    function mint(address _to, uint256 _id, uint256 _quantity) external;


    function batchMint( address _to, uint256[] memory _ids, uint256[] memory _quantities) external;


    function setCreator(address _to, uint256[] memory _ids) external;

}// MIT
pragma solidity ^0.8.0;





contract MarketLite is AccessControl, IERC1155Receiver {


    using EnumerableSet for EnumerableSet.UintSet;

    event CreateTokenAndSale(address indexed sender, uint128 amount, uint128 deadline, uint256 price);
    event MintTokenAndSale(address indexed sender, uint128 amount, uint128 deadline, uint256 price);
    event UseTokenAndSale(address indexed sender, uint128 amount, uint128 deadline, uint256 price);
    event Redeem(address indexed account, uint256 tokenId, uint256 price);

    IERC20 private _peaceToken;
    IERC1155Tradable private _erc1155;
    EnumerableSet.UintSet private tokenIds;

    struct TokenSale {
        uint256 price;
        uint128 deadline;
        bytes32 merkleRoot;
        address[] buys;
    }

    bool private inRedeem;

    mapping(uint256 => mapping(address => bool)) private _userHasClaimed;

    mapping(uint256 => TokenSale) private _tokenSales;

    mapping (uint256 => address) private _creators;
 
    bytes32 private constant SELLER_ROLE = keccak256("SELLER_ROLE");

    modifier lockRedeem{

        inRedeem = true;
        _;
        inRedeem = false;
    }

    constructor(address erc1155, address peaceToken, address admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(SELLER_ROLE, admin);
        _erc1155 = IERC1155Tradable(erc1155);
        _peaceToken = IERC20(peaceToken);
    }

    function setPeaceToken(address peaceToken) external onlyRole(DEFAULT_ADMIN_ROLE) {

        _peaceToken = IERC20(peaceToken);
    }

    function setERC1155(address erc1155) external onlyRole(DEFAULT_ADMIN_ROLE) {

        _erc1155 = IERC1155Tradable(erc1155);
    }

    function updateMerkleRoot(uint256 tokenId, bytes32 merkleRoot) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(tokenIds.contains(tokenId), "No sell for tokenId");
        _tokenSales[tokenId].merkleRoot = merkleRoot;
    }

    function updatePrice(uint256 tokenId, uint256 price) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(tokenIds.contains(tokenId), "No sell for tokenId");
        require(price > 0, "Price is 0");
        _tokenSales[tokenId].price = price;
    }

    function updateDeadline(uint256 tokenId, uint128 deadline) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(tokenIds.contains(tokenId), "No sell for tokenId");
        _tokenSales[tokenId].deadline = deadline;
    }

    function withdrawERC1155(uint256 tokenId, uint128 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {

        _erc1155.safeTransferFrom(address(this), _msgSender(), tokenId, amount, "");
    }

    function withdrawERC20(address token) external onlyRole(DEFAULT_ADMIN_ROLE) {

        IERC20(token).transfer(_msgSender(), IERC20(token).balanceOf(address(this)));
    }

    function withdrawOtherERC1155(address token, uint256 tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(token != address(_erc1155), "Call withdrawERC1155 instead");
        IERC1155(token).safeTransferFrom(address(this), _msgSender(), tokenId, IERC1155(token).balanceOf(address(this), tokenId), "");
    }

    function withdrawETH() external onlyRole(DEFAULT_ADMIN_ROLE) {

        payable(_msgSender()).transfer(address(this).balance);
    }

    function createNextTokenAndSale(uint128 amount, uint128 deadline, uint256 price, bytes32 merkleRoot) external onlyRole(SELLER_ROLE) {

        uint256 tokenId = _erc1155.create(address(this), amount);

        _creators[tokenId] = _msgSender();

        _setNewSale(tokenId, price, deadline, merkleRoot);

        emit CreateTokenAndSale(_msgSender(), amount, deadline, price);
    }

    function mintTokenAndSale(uint256 tokenId, uint128 amount, uint128 deadline, uint256 price, bytes32 merkleRoot) external onlyRole(SELLER_ROLE) {

        _erc1155.mint(address(this), tokenId, amount);

        if(tokenIds.contains(tokenId)) _updateSell(tokenId, price, deadline, merkleRoot);
        else _setNewSale(tokenId, price, deadline, merkleRoot);

        _creators[tokenId] = _msgSender();

        emit MintTokenAndSale(_msgSender(), amount, deadline, price);
    }

    function useTokenAndSale(uint256 tokenId, uint128 deadline, uint256 price, bytes32 merkleRoot) external onlyRole(SELLER_ROLE) {

        require(!tokenIds.contains(tokenId), "Sale already created");
        uint128 balance = uint128(_erc1155.balanceOf(address(this), tokenId));
        require(balance > 0, "no token balance");
        _setNewSale(tokenId, price, deadline, merkleRoot);
        emit UseTokenAndSale(_msgSender(), balance, deadline, price);
    }

    function _setNewSale(uint256 tokenId, uint256 price, uint128 deadline, bytes32 merkleRoot) private {

        require(deadline == 0 || deadline > block.timestamp, "wrong deadline");
        require(price > 0, "Price is 0");
        TokenSale memory tokenSale = TokenSale(price, deadline, merkleRoot, new address[](0));
        _tokenSales[tokenId] = tokenSale;
        tokenIds.add(tokenId);
    }

    function _updateSell(uint256 tokenId, uint256 price, uint128 deadline, bytes32 merkleRoot) private {

        require(deadline == 0 || deadline > block.timestamp, "wrong deadline");
        require(price > 0, "Price is 0");
        _tokenSales[tokenId] = TokenSale(
            price, 
            deadline, 
            merkleRoot == "" ? _tokenSales[tokenId].merkleRoot : merkleRoot,
            _tokenSales[tokenId].buys
        );
    }

    function getPeaceToken() external view returns (address) {

        return address(_peaceToken);
    }

    function getERC1155() external view returns (address) {

        return address(_erc1155);
    }

    function getTokensInSale() external view returns (uint256[] memory) {

        return tokenIds.values();
    }

    function getTokenSale(uint128 tokenId) external view returns(TokenSale memory) {

        return _tokenSales[tokenId];
    }

    function hasUserClaimed(uint256 tokenId, address account) external view returns (bool) {

        return _userHasClaimed[tokenId][account];
    }

    function getTokenCreator(uint256 tokenId) external view returns (address) {

        return _creators[tokenId];
    }



    function setCreator(address _to, uint256 _id) public {

        require(_creators[_id] ==_msgSender(), "Only Creator");
        _creators[_id] = _to;
        uint256[] memory ids= new uint[](1);
        ids[0] = _id;
        _erc1155.setCreator(_to, ids);
    }

    function redeem(uint256 tokenId, bytes32[] calldata proof) external lockRedeem {

        TokenSale storage tokenSale = _tokenSales[tokenId];
        address account = _msgSender();

        if(tokenSale.merkleRoot != "") {
            bytes32 leaf = keccak256(abi.encodePacked(account));
            require(_verify(tokenId, leaf, proof), "Invalid merkle proof");
        }
        
        require(!_userHasClaimed[tokenId][account], "User has already bought");
        require(tokenSale.deadline == 0 || tokenSale.deadline > block.timestamp, "Deadline ended");

        _userHasClaimed[tokenId][account] = true;
        tokenSale.buys.push(account);
        uint256 price = tokenSale.price;
        _peaceToken.transferFrom(account, address(this), price);
        _erc1155.safeTransferFrom(address(this), account, tokenId, 1, "");
        emit Redeem(account, tokenId, price);
    }

    function _verify(uint256 tokenId, bytes32 leaf, bytes32[] memory proof) private view returns (bool) {

        return MerkleProof.verify(proof, _tokenSales[tokenId].merkleRoot, leaf);
    }

    function onERC1155Received(
        address /* operator */,
        address /* from */,
        uint256 /* id */,
        uint256 /* value */,
        bytes calldata /* data */
    ) external override pure returns (bytes4) {

        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    } 

    function onERC1155BatchReceived(
        address /* operator */,
        address /* from */,
        uint256[] calldata /* ids */,
        uint256[] calldata /* values */,
        bytes calldata /* data */
    ) external override pure returns (bytes4) {

        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }

    receive() external payable {}

}