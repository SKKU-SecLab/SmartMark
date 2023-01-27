
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


interface IAccessControlEnumerable is IAccessControl {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

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

pragma solidity ^0.8.0;


abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
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

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT
pragma solidity ^0.8.12;


interface IFancyBears is IERC721, IERC721Enumerable {


    function tokensInWallet(address _owner) external view returns(uint256[] memory);


}// MIT
pragma solidity ^0.8.12;


interface IHoneyJars is IERC721, IERC721Enumerable {


    function tokensInWallet(address _owner) external view returns(uint256[] memory);


}// MIT
pragma solidity ^0.8.11;


abstract contract IHoneyToken is IERC20 {}// MIT
pragma solidity ^0.8.12;

abstract contract IHoneyVesting {
    function spendHoney(
        uint256[] calldata _fancyBearTokens, 
        uint256[] calldata _amountPerFancyBearToken, 
        uint256[] calldata _honeyJarTokens,
        uint256[] calldata _amountPerHoneyJarToken
    )
        external
        virtual;
}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

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
pragma solidity ^0.8.12;


abstract contract IFancyBearTraits is IERC1155 {

    mapping(string => bool) public categoryValidation;
    uint256 public categoryPointer;
    string[] public categories;
    function getTrait(uint256 _tokenId) public virtual returns (string memory, string memory, uint256);
    function getCategories() public virtual returns (string[] memory);
    function mint(address _account, uint256 _id, uint256 _amount, bytes memory _data) public virtual;
    function mintBatch(address _account, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) public virtual;
}// MIT
pragma solidity ^0.8.12;

abstract contract IFancyBearHoneyConsumption {

    mapping(uint256 => uint256) public honeyConsumed;
    function consumeHoney(uint256 _tokenId, uint256 _honeyAmount) public virtual;
    
}// MIT
pragma solidity ^0.8.12;


contract FancyTraitSale is AccessControlEnumerable {


    struct TokenSaleData {
        uint256 price;
        uint256 counter;
        uint256 maxSupply;
        bool saleActive;
    }

    struct PurchaseData {
        uint256[] fancyBear; 
        uint256[] amountToSpendFromBear;
        uint256[] honeyJars;
        uint256[] amountToSpendFromHoneyJars;
        uint256 amountToSpendFromWallet;
        uint256[] traitTokenIds;
        uint256[] amountPerTrait;
    }

    using SafeMath for uint256;
    using SafeERC20 for IHoneyToken;

    bytes32 public constant SALE_MANAGER_ROLE = keccak256("SALE_MANAGER_ROLE");
    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");

    mapping(uint256 => TokenSaleData) public tokenSaleData;

    IFancyBears public fancyBearsContract;
    IHoneyJars public honeyJarsContract;
    IHoneyToken public honeyTokenContract;
    IHoneyVesting public honeyVestingContract;
    IFancyBearTraits public fancyBearTraitsContract;
    IFancyBearHoneyConsumption public fancyBearHoneyConsumptionContract;

    event SaleDataUpdated(uint256 indexed _tokenId);
    event PriceUpdated(uint256 indexed _tokenId, uint256 _price);
    event CounterCleared(uint256 indexed _tokenId);
    event MaxSupplyUpdated(uint256 indexed _tokenId, uint256 _maxSupply);
    event SaleToggled(uint256 indexed _tokenId, bool _saleActive);
    event SaleDataDeleted(uint256 indexed _tokenId);
    event Withdraw(address _destination, uint256 _amount);

    constructor(
        IFancyBears _fancyBearsContract,
        IHoneyJars _honeyJarsContract,
        IHoneyToken _honeyTokenContract,
        IHoneyVesting _honeyVestingContract,
        IFancyBearTraits _fancyBearTraitsContract,
        IFancyBearHoneyConsumption _fancyBearHoneyConsumptionContract
    ) 
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        fancyBearsContract = _fancyBearsContract;
        honeyJarsContract = _honeyJarsContract;
        honeyTokenContract = _honeyTokenContract;
        honeyVestingContract = _honeyVestingContract;
        fancyBearTraitsContract = _fancyBearTraitsContract;
        fancyBearHoneyConsumptionContract = _fancyBearHoneyConsumptionContract;

    }

    function purchaseTraits(PurchaseData calldata purchaseData) public {


        uint256 totalHoneyRequired;
        uint256 totalHoneySubmitted = purchaseData.amountToSpendFromWallet;

        require(
            purchaseData.fancyBear.length <= 1,
            "purchaseTraits: cannot submit more than one fancy bear"
        );

        require(
            purchaseData.amountToSpendFromBear.length == purchaseData.fancyBear.length,
            "purchaseTraits: fancy bear and amount to spend must match in length"
        );

        if(purchaseData.fancyBear.length == 1){

            require(
                fancyBearsContract.tokenByIndex(purchaseData.fancyBear[0].sub(1)) == purchaseData.fancyBear[0]
            );

            if(purchaseData.amountToSpendFromBear[0] > 0){
                require(
                    fancyBearsContract.ownerOf(purchaseData.fancyBear[0]) == msg.sender,
                    "purchaseTraits: caller must own fancy bear if spending honey in bear"
                );

                totalHoneySubmitted += purchaseData.amountToSpendFromBear[0];
            }
        }
        
        require(
            purchaseData.traitTokenIds.length > 0, "purchaseTraits: must request at least 1 trait"
        );

        require(
            purchaseData.traitTokenIds.length == purchaseData.amountPerTrait.length,
            "purchaseTraits: trait token ids and amounts must match in length"
        );

        for(uint256 i = 0; i < purchaseData.traitTokenIds.length; i++) {
            
            require(
                tokenSaleData[purchaseData.traitTokenIds[i]].saleActive,
                "purchaseTraits: trait is not available for sale"
            );
    
            require(
                tokenSaleData[purchaseData.traitTokenIds[i]].counter.add(purchaseData.amountPerTrait[i]) <= tokenSaleData[purchaseData.traitTokenIds[i]].maxSupply,
                "purchaseTraits: request exceeds supply of trait"
            );

            totalHoneyRequired += (tokenSaleData[purchaseData.traitTokenIds[i]]).price.mul(purchaseData.amountPerTrait[i]);

            tokenSaleData[purchaseData.traitTokenIds[i]].counter += purchaseData.amountPerTrait[i];
        }

        require(
            purchaseData.honeyJars.length == purchaseData.amountToSpendFromHoneyJars.length, 
            "purchaseTraits: honey jar ids and amounts to spend must match in length"
        );
        
        for(uint256 i = 0; i < purchaseData.honeyJars.length; i++) {
            require(
                honeyJarsContract.ownerOf(purchaseData.honeyJars[i]) == msg.sender,
                "purchaseTraits: caller must be owner of all honey jars"
            );

            totalHoneySubmitted += purchaseData.amountToSpendFromHoneyJars[i];
        }

        require(
            totalHoneyRequired == totalHoneySubmitted, 
            "purchaseTraits: caller must submit the required amount of honey"
        );

        if(purchaseData.fancyBear.length == 1 && purchaseData.amountToSpendFromBear[0] > 0) {
           
            honeyVestingContract.spendHoney(
                purchaseData.fancyBear,
                purchaseData.amountToSpendFromBear,
                purchaseData.honeyJars,
                purchaseData.amountToSpendFromHoneyJars
            );

        }
        else {
            honeyVestingContract.spendHoney(
                new uint256[](0),
                new uint256[](0),
                purchaseData.honeyJars,
                purchaseData.amountToSpendFromHoneyJars);
        }

        fancyBearTraitsContract.mintBatch(
            msg.sender,
            purchaseData.traitTokenIds,
            purchaseData.amountPerTrait,
            ""
        );

        if(purchaseData.fancyBear.length == 1){
            fancyBearHoneyConsumptionContract.consumeHoney(purchaseData.fancyBear[0], totalHoneyRequired);
        }

        if(purchaseData.amountToSpendFromWallet > 0){
            honeyTokenContract.safeTransferFrom(msg.sender, address(this), purchaseData.amountToSpendFromWallet);
        }
        
    }

    function updateSaleData(uint256 _tokenId, TokenSaleData calldata _tokenSaleData) public onlyRole(SALE_MANAGER_ROLE) {

        tokenSaleData[_tokenId] = _tokenSaleData;
        emit SaleDataUpdated(_tokenId);
    }

    function updateSaleDataBulk(
        uint256[] calldata _tokenIds, 
        TokenSaleData[] calldata _tokenSaleData
    ) 
        public 
        onlyRole(SALE_MANAGER_ROLE) 
    {

        require(
            _tokenIds.length == _tokenSaleData.length, 
            "updateSaleDataBulk: arrays must match in length"
        );
        for(uint256 i = 0; i < _tokenIds.length; i++){
            tokenSaleData[_tokenIds[i]] = _tokenSaleData[i];
            emit SaleDataUpdated(_tokenIds[i]);
        }
       
    }

    function updatePrice(uint256[] calldata _tokenIds, uint256[] calldata _prices) public onlyRole(SALE_MANAGER_ROLE) {

        require(_tokenIds.length == _prices.length, "updatePrice: token Ids and prices array must match in length");
        for(uint256 i = 0; i < _tokenIds.length; i++){
            tokenSaleData[_tokenIds[i]].price = _prices[i];
            emit PriceUpdated(_tokenIds[i], _prices[i]);
        }
    }

    function clearCounter(uint256[] calldata _tokenIds) public onlyRole(SALE_MANAGER_ROLE) {

        for(uint256 i = 0; i < _tokenIds.length; i++){
            tokenSaleData[_tokenIds[i]].counter = 0;
            emit CounterCleared(_tokenIds[i]);
        }
    }

    function updateMaxSupply(uint256[] calldata _tokenIds, uint256[] calldata _maxSupplies) public onlyRole(SALE_MANAGER_ROLE) {

        require(_tokenIds.length == _maxSupplies.length, "updatePrice: token Ids and max supplies array must match in length");
        for(uint256 i = 0; i < _tokenIds.length; i++){
            require(
                _maxSupplies[i] >= tokenSaleData[_tokenIds[i]].counter, 
                "updateMaxSupply: cannot set max supply below item counter"
            );

            tokenSaleData[_tokenIds[i]].maxSupply = _maxSupplies[i];
            emit MaxSupplyUpdated(_tokenIds[i], _maxSupplies[i]);
        }
    }

    function toggleSale(uint256[] calldata _tokenIds) public onlyRole(SALE_MANAGER_ROLE) {

        for(uint256 i = 0; i < _tokenIds.length; i++){
            tokenSaleData[_tokenIds[i]].saleActive = !tokenSaleData[_tokenIds[i]].saleActive;
            emit SaleToggled(_tokenIds[i], tokenSaleData[_tokenIds[i]].saleActive);
        } 
    }

    function deleteSaleData(uint256[] calldata _tokenIds) public onlyRole(SALE_MANAGER_ROLE) {

        for(uint256 i = 0; i < _tokenIds.length; i++){
            delete(tokenSaleData[_tokenIds[i]]);
            emit SaleDataDeleted(_tokenIds[i]); 
        }
    }

    function withdraw(address _beneficiary, uint256 _amount) public onlyRole(WITHDRAW_ROLE) {

        honeyTokenContract.safeTransfer(_beneficiary, _amount);
        emit Withdraw(_beneficiary, _amount);
    }

}