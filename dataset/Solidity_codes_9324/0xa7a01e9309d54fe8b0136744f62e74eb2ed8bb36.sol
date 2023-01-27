
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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT
pragma solidity ^0.8.4;

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

    struct Iterator {
        RLPItem item; // Item that's being iterated over.
        uint256 nextPtr; // Position of the next item in the list.
    }

    function next(Iterator memory self) internal pure returns (RLPItem memory) {

        require(hasNext(self));

        uint256 ptr = self.nextPtr;
        uint256 itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    function hasNext(Iterator memory self) internal pure returns (bool) {

        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    function toRlpItem(bytes memory item)
        internal
        pure
        returns (RLPItem memory)
    {

        uint256 memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    function iterator(RLPItem memory self)
        internal
        pure
        returns (Iterator memory)
    {

        require(isList(self));

        uint256 ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    function rlpLen(RLPItem memory item) internal pure returns (uint256) {

        return item.len;
    }

    function payloadLocation(RLPItem memory item)
        internal
        pure
        returns (uint256, uint256)
    {

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 memPtr = item.memPtr + offset;
        uint256 len = item.len - offset; // data length
        return (memPtr, len);
    }

    function payloadLen(RLPItem memory item) internal pure returns (uint256) {

        (, uint256 len) = payloadLocation(item);
        return len;
    }

    function toList(RLPItem memory item)
        internal
        pure
        returns (RLPItem[] memory)
    {

        require(isList(item));

        uint256 items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

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

        if (item.len == 0) return false;

        uint8 byte0;
        uint256 memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }

    function rlpBytesKeccak256(RLPItem memory item)
        internal
        pure
        returns (bytes32)
    {

        uint256 ptr = item.memPtr;
        uint256 len = item.len;
        bytes32 result;
        assembly {
            result := keccak256(ptr, len)
        }
        return result;
    }

    function payloadKeccak256(RLPItem memory item)
        internal
        pure
        returns (bytes32)
    {

        (uint256 memPtr, uint256 len) = payloadLocation(item);
        bytes32 result;
        assembly {
            result := keccak256(memPtr, len)
        }
        return result;
    }


    function toRlpBytes(RLPItem memory item)
        internal
        pure
        returns (bytes memory)
    {

        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;

        uint256 ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    function toBoolean(RLPItem memory item) internal pure returns (bool) {

        require(item.len == 1);
        uint256 result;
        uint256 memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        if (result == 0 || result == STRING_SHORT_START) {
            return false;
        } else {
            return true;
        }
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {

        require(item.len == 21);

        return address(uint160(toUint(item)));
    }

    function toUint(RLPItem memory item) internal pure returns (uint256) {

        require(item.len > 0 && item.len <= 33);

        (uint256 memPtr, uint256 len) = payloadLocation(item);

        uint256 result;
        assembly {
            result := mload(memPtr)

            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    function toUintStrict(RLPItem memory item) internal pure returns (uint256) {

        require(item.len == 33);

        uint256 result;
        uint256 memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {

        require(item.len > 0);

        (uint256 memPtr, uint256 len) = payloadLocation(item);
        bytes memory result = new bytes(len);

        uint256 destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(memPtr, destPtr, len);
        return result;
    }


    function numItems(RLPItem memory item) private pure returns (uint256) {

        if (item.len == 0) return 0;

        uint256 count = 0;
        uint256 currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
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

        if (len > 0) {
            uint256 mask = 256**(WORD_SIZE - len) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask)) // zero out src
                let destpart := and(mload(dest), mask) // retrieve the bytes
                mstore(dest, or(destpart, srcpart))
            }
        }
    }
}// MIT
pragma solidity ^0.8.4;

interface IBridgeToken {

    function burn(address from, uint256 amount) external;


    function mint(address to, uint256 amount) external;


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}// MIT
pragma solidity ^0.8.4;


library RToken {

    using SafeERC20 for IERC20;

    enum IssueType {
        DEFAULT,
        MINTABLE
    }

    struct Token {
        address addr;
        uint256 chainId;
        IssueType issueType;
        bool exist;
    }

    function unsafeTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {

        require(from.balance >= amount, "RT: INSUFFICIENT_BALANCE");

        (bool success, ) = to.call{value: amount}("");
        require(success, "RT: SEND_REVERT");
    }

    function enter(
        Token memory token,
        address from,
        address to,
        uint256 amount
    ) internal returns (Token memory) {

        require(token.exist, "RT: NOT_LISTED");
        if (token.issueType == IssueType.MINTABLE) {
            IBridgeToken(token.addr).burn(from, amount);
        } else if (token.issueType == IssueType.DEFAULT) {
            IERC20(token.addr).safeTransferFrom(from, to, amount);
        } else {
            assert(false);
        }
        return token;
    }

    function exit(
        Token memory token,
        address from,
        address to,
        uint256 amount
    ) internal returns (Token memory) {

        require(token.exist, "RT: NOT_LISTED");
        if (token.addr == address(0)) {
            unsafeTransfer(from, to, amount);
        } else if (token.issueType == IssueType.MINTABLE) {
            IBridgeToken(token.addr).mint(to, amount);
        } else if (token.issueType == IssueType.DEFAULT) {
            IERC20(token.addr).safeTransfer(to, amount);
        } else {
            assert(false);
        }
        return token;
    }
}// MIT
pragma solidity ^0.8.4;

contract Version0 {

    uint8 public constant VERSION = 0;
}// MIT
pragma solidity ^0.8.4;

interface IBridgeCosignerManager {

    event CosignerAdded(address indexed cosaddr, uint256 chainId);
    event CosignerRemoved(address indexed cosaddr, uint256 chainId);
    struct Cosigner {
        address addr;
        uint256 chainId;
        uint256 index;
        bool active;
    }

    function addCosigner(address cosaddr, uint256 chainId) external;


    function addCosignerBatch(address[] calldata cosaddrs, uint256 chainId)
        external;


    function removeCosigner(address cosaddr) external;


    function removeCosignerBatch(address[] calldata cosaddrs) external;


    function getCosigners(uint256 chainId)
        external
        view
        returns (address[] memory);


    function getCosignCount(uint256 chainId) external view returns (uint8);


    function verify(
        bytes32 commitment,
        uint256 chainId,
        bytes[] calldata signatures
    ) external view returns (bool);

}// MIT
pragma solidity ^0.8.4;


interface IBridgeTokenManager {

    event TokenAdded(address indexed addr, uint256 chainId);
    event TokenRemoved(address indexed addr, uint256 chainId);

    function issue(
        address[] calldata tokens,
        RToken.IssueType[] calldata issueTypes,
        uint256 targetChainId
    ) external;


    function revoke(address targetAddr) external;


    function getLocal(address sourceAddr, uint256 targetChainId)
        external
        view
        returns (RToken.Token memory token);


    function isZero(uint256 targetChainId) external view returns (bool);

}// MIT
pragma solidity >=0.6.0 <0.9.0;


interface IWETH is IERC20 {

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    function deposit() external payable;


    function withdraw(uint256) external;

}// MIT
pragma solidity ^0.8.4;

interface IOwnable {

    function transferOwnership(address newOwner) external;

}// MIT
pragma solidity ^0.8.4;



contract BridgeRouter is
    Version0,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{

    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;
    using RToken for RToken.Token;

    mapping(address => uint256) internal _nonces;
    mapping(bytes32 => bool) internal _commitments;

    IBridgeCosignerManager public cosignerManager;
    IBridgeTokenManager public tokenManager;
    uint256 internal _chainId;

    bytes32 internal constant ENTER_EVENT_SIG =
        keccak256("Enter(address,address,uint256,uint256,uint256,uint256)");


    uint256[49] private __gap;


    receive() external payable {}


    event Enter(
        address indexed token,
        address indexed exitor,
        uint256 amount,
        uint256 nonce,
        uint256 localChainId,
        uint256 targetChainId
    );

    event Exit(
        address indexed token,
        address indexed exitor,
        uint256 amount,
        bytes32 commitment,
        uint256 localChainId,
        uint256 extChainId
    );

    function emitEnter(
        address token,
        address from,
        uint256 amount,
        uint256 targetChainId
    ) internal {

        emit Enter(token, from, amount, _nonces[from], _chainId, targetChainId);
        _nonces[from]++;
    }

    function emitExit(
        address token,
        address to,
        bytes32 commitment,
        uint256 amount,
        uint256 extChainId
    ) internal {

        emit Exit(token, to, amount, commitment, _chainId, extChainId);
    }


    function setTokenManager(address newTokenManager) external onlyOwner {

        require(newTokenManager != address(0), "BR: ZERO_ADDRESS");
        tokenManager = IBridgeTokenManager(newTokenManager);
    }

    function setCosignerManager(address newCosignerManager) external onlyOwner {

        require(newCosignerManager != address(0), "BR: ZERO_ADDRESS");
        cosignerManager = IBridgeCosignerManager(newCosignerManager);
    }

    function initialize(
        IBridgeCosignerManager cosignerManager_,
        IBridgeTokenManager tokenManager_
    ) public initializer {

        cosignerManager = cosignerManager_;
        tokenManager = tokenManager_;
        assembly {
            sstore(_chainId.slot, chainid())
        }

        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();
    }

    function enter(
        address token,
        uint256 amount,
        uint256 targetChainId
    ) external nonReentrant whenNotPaused {

        require(token != address(0), "BR: ZERO_ADDRESS");
        require(amount != 0, "BR: ZERO_AMOUNT");

        RToken.Token memory localToken = tokenManager
            .getLocal(token, targetChainId)
            .enter(_msgSender(), address(this), amount);
        emitEnter(localToken.addr, _msgSender(), amount, targetChainId);
    }

    function enterETH(uint256 targetChainId)
        external
        payable
        nonReentrant
        whenNotPaused
    {

        require(msg.value != 0, "BR: ZERO_AMOUNT");
        require(tokenManager.isZero(targetChainId), "BR: NOT_FOUND");

        emitEnter(address(0), _msgSender(), msg.value, targetChainId);
    }

    function exit(bytes calldata data, bytes[] calldata signatures)
        external
        nonReentrant
        whenNotPaused
    {

        RLPReader.RLPItem[] memory logRLPList = data.toRlpItem().toList();
        RLPReader.RLPItem[] memory logTopicRLPList = logRLPList[1].toList(); // topics

        require(
            bytes32(logTopicRLPList[0].toUint()) == ENTER_EVENT_SIG, // topic0 is event sig
            "BR: INVALID_EVT"
        );

        address extTokenAddr = logTopicRLPList[1].toAddress();
        address exitor = logTopicRLPList[2].toAddress();
        require(exitor == _msgSender(), "BR: NOT_ONWER");

        uint256 amount = logRLPList[2].toUint();
        require(amount != 0, "BR: ZERO_AMOUNT");

        uint256 localChainId = logRLPList[5].toUint();
        require(localChainId == _chainId, "BR: WRONG_TARGET_CHAIN");

        uint256 extChainId = logRLPList[4].toUint();
        require(extChainId != _chainId, "BR: WRONG_SOURCE_CHAIN");

        bytes32 commitment = keccak256(data);

        require(!_commitments[commitment], "BR: COMMITMENT_KNOWN");
        _commitments[commitment] = true;
        require(
            cosignerManager.verify(commitment, extChainId, signatures),
            "BR: INVALID_SIGNATURES"
        );

        RToken.Token memory localToken = tokenManager
            .getLocal(extTokenAddr, _chainId)
            .exit(address(this), exitor, amount);
        emitExit(localToken.addr, exitor, commitment, amount, extChainId);
    }
}