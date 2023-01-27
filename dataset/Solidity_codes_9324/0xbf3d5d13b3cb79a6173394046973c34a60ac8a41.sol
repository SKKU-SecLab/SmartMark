


pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.6.2;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}


pragma solidity 0.6.6;

interface IMintableERC1155 is IERC1155 {

    function mint(address account, uint256 id, uint256 amount, bytes calldata data) external;


    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}



pragma solidity ^0.6.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}



pragma solidity ^0.6.0;


contract ERC165 is IERC165 {

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
}



pragma solidity ^0.6.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() public {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}



pragma solidity ^0.6.0;

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
}



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;




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
}


pragma solidity 0.6.6;


contract AccessControlMixin is AccessControl {

    string private _revertMsg;
    function _setupContractId(string memory contractId) internal {

        _revertMsg = string(abi.encodePacked(contractId, ": INSUFFICIENT_PERMISSIONS"));
    }

    modifier only(bytes32 role) {

        require(
            hasRole(role, _msgSender()),
            _revertMsg
        );
        _;
    }
}


pragma solidity 0.6.6;

library RLPReader {

    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint256 len;
        uint256 memPtr;
    }

    function toRlpItem(bytes memory item)
        internal
        pure
        returns (RLPItem memory)
    {

        require(item.length > 0, "RLPReader: INVALID_BYTES_LENGTH");
        uint256 memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    function toList(RLPItem memory item)
        internal
        pure
        returns (RLPItem[] memory)
    {

        require(isList(item), "RLPReader: ITEM_NOT_LIST");

        uint256 items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);
        uint256 listLength = _itemLength(item.memPtr);
        require(listLength == item.len, "RLPReader: LIST_DECODED_LENGTH_MISMATCH");

        uint256 memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 dataLen;
        for (uint256 i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    function isList(RLPItem memory item) internal pure returns (bool) {

        uint8 byte0;
        uint256 memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }


    function toRlpBytes(RLPItem memory item)
        internal
        pure
        returns (bytes memory)
    {

        bytes memory result = new bytes(item.len);

        uint256 ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {

        require(!isList(item), "RLPReader: DECODING_LIST_AS_ADDRESS");
        require(item.len == 21, "RLPReader: INVALID_ADDRESS_LENGTH");

        return address(toUint(item));
    }

    function toUint(RLPItem memory item) internal pure returns (uint256) {

        require(!isList(item), "RLPReader: DECODING_LIST_AS_UINT");
        require(item.len <= 33, "RLPReader: INVALID_UINT_LENGTH");

        uint256 itemLength = _itemLength(item.memPtr);
        require(itemLength == item.len, "RLPReader: UINT_DECODED_LENGTH_MISMATCH");

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset;
        uint256 result;
        uint256 memPtr = item.memPtr + offset;
        assembly {
            result := mload(memPtr)

            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    function toUintStrict(RLPItem memory item) internal pure returns (uint256) {

        uint256 itemLength = _itemLength(item.memPtr);
        require(itemLength == item.len, "RLPReader: UINT_STRICT_DECODED_LENGTH_MISMATCH");
        require(item.len == 33, "RLPReader: INVALID_UINT_STRICT_LENGTH");

        uint256 result;
        uint256 memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {

        uint256 listLength = _itemLength(item.memPtr);
        require(listLength == item.len, "RLPReader: BYTES_DECODED_LENGTH_MISMATCH");
        uint256 offset = _payloadOffset(item.memPtr);

        uint256 len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint256 destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }


    function numItems(RLPItem memory item) private pure returns (uint256) {


        uint256 count = 0;
        uint256 currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            require(currPtr <= endPtr, "RLPReader: NUM_ITEMS_DECODED_LENGTH_MISMATCH");
            count++;
        }

        return count;
    }

    function _itemLength(uint256 memPtr) private pure returns (uint256) {

        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) itemLen = 1;
        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    function _payloadOffset(uint256 memPtr) private pure returns (uint256) {

        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (
            byte0 < STRING_LONG_START ||
            (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)
        ) return 1;
        else if (byte0 < LIST_SHORT_START)
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }

    function copy(
        uint256 src,
        uint256 dest,
        uint256 len
    ) private pure {

        if (len == 0) return;

        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        uint256 mask = 256**(WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}


pragma solidity 0.6.6;


interface ITokenPredicate {


    function lockTokens(
        address depositor,
        address depositReceiver,
        address rootToken,
        bytes calldata depositData
    ) external;


    function exitTokens(
        address sender,
        address rootToken,
        bytes calldata logRLPList
    ) external;

}


pragma solidity 0.6.6;

contract Initializable {

    bool inited = false;

    modifier initializer() {

        require(!inited, "already inited");
        _;
        inited = true;
    }
}


pragma solidity 0.6.6;


contract MintableERC1155Predicate is
    ITokenPredicate,
    ERC1155Receiver,
    AccessControlMixin,
    Initializable
{

    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant TOKEN_TYPE = keccak256("MintableERC1155");

    bytes32 public constant TRANSFER_SINGLE_EVENT_SIG = keccak256(
        "TransferSingle(address,address,address,uint256,uint256)"
    );
    bytes32 public constant TRANSFER_BATCH_EVENT_SIG = keccak256(
        "TransferBatch(address,address,address,uint256[],uint256[])"
    );

    event LockedBatchMintableERC1155(
        address indexed depositor,
        address indexed depositReceiver,
        address indexed rootToken,
        uint256[] ids,
        uint256[] amounts
    );

    constructor() public {}

    function initialize(address _owner) external initializer {

        _setupContractId("MintableERC1155Predicate");
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(MANAGER_ROLE, _owner);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {

        return 0;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external override returns (bytes4) {

        return ERC1155Receiver(0).onERC1155BatchReceived.selector;
    }

    function lockTokens(
        address depositor,
        address depositReceiver,
        address rootToken,
        bytes calldata depositData
    ) external override only(MANAGER_ROLE) {

        (
            uint256[] memory ids,
            uint256[] memory amounts,
            bytes memory data
        ) = abi.decode(depositData, (uint256[], uint256[], bytes));

        emit LockedBatchMintableERC1155(
            depositor,
            depositReceiver,
            rootToken,
            ids,
            amounts
        );
        IMintableERC1155(rootToken).safeBatchTransferFrom(
            depositor,
            address(this),
            ids,
            amounts,
            data
        );
    }

    function makeArrayWithAddress(address addr, uint256 size)
        internal
        pure
        returns (address[] memory)
    {

        require(
            addr != address(0),
            "MintableERC1155Predicate: Invalid address"
        );
        require(
            size > 0,
            "MintableERC1155Predicate: Invalid resulting array length"
        );

        address[] memory addresses = new address[](size);

        for (uint256 i = 0; i < size; i++) {
            addresses[i] = addr;
        }

        return addresses;
    }

    function calculateAmountsToBeMinted(
        uint256[] memory tokenBalances,
        uint256[] memory amountsToBeExited
    ) internal pure returns (uint256[] memory) {

        require(
            tokenBalances.length == amountsToBeExited.length,
            "MintableERC1155Predicate: Array length mismatch found"
        );

        uint256[] memory toBeMintedAmounts = new uint256[](
            tokenBalances.length
        );

        for (uint256 i = 0; i < tokenBalances.length; i++) {
            if (tokenBalances[i] < amountsToBeExited[i]) {
                toBeMintedAmounts[i] = amountsToBeExited[i] - tokenBalances[i];
            }
        }

        return toBeMintedAmounts;
    }

    function exitTokens(
        address,
        address rootToken,
        bytes memory log
    ) public override only(MANAGER_ROLE) {

        RLPReader.RLPItem[] memory logRLPList = log.toRlpItem().toList();
        RLPReader.RLPItem[] memory logTopicRLPList = logRLPList[1].toList(); // topics
        bytes memory logData = logRLPList[2].toBytes();

        address withdrawer = address(logTopicRLPList[2].toUint()); // topic2 is from address

        require(
            address(logTopicRLPList[3].toUint()) == address(0), // topic3 is to address
            "MintableERC1155Predicate: INVALID_RECEIVER"
        );

        if (bytes32(logTopicRLPList[0].toUint()) == TRANSFER_SINGLE_EVENT_SIG) {
            (uint256 id, uint256 amount) = abi.decode(
                logData,
                (uint256, uint256)
            );

            IMintableERC1155 token = IMintableERC1155(rootToken);
            uint256 tokenBalance = token.balanceOf(address(this), id);

            if (tokenBalance < amount) {
                token.mint(address(this), id, amount - tokenBalance, bytes(""));
            }

            token.safeTransferFrom(
                address(this),
                withdrawer,
                id,
                amount,
                bytes("")
            );
        } else if (
            bytes32(logTopicRLPList[0].toUint()) == TRANSFER_BATCH_EVENT_SIG
        ) {
            (uint256[] memory ids, uint256[] memory amounts) = abi.decode(
                logData,
                (uint256[], uint256[])
            );

            IMintableERC1155 token = IMintableERC1155(rootToken);

            token.mintBatch(
                address(this),
                ids,
                calculateAmountsToBeMinted(
                    token.balanceOfBatch(
                        makeArrayWithAddress(address(this), ids.length),
                        ids
                    ),
                    amounts
                ),
                bytes("")
            );

            IMintableERC1155(rootToken).safeBatchTransferFrom(
                address(this),
                withdrawer,
                ids,
                amounts,
                bytes("")
            );
        } else {
            revert("MintableERC1155Predicate: INVALID_WITHDRAW_SIG");
        }
    }
}