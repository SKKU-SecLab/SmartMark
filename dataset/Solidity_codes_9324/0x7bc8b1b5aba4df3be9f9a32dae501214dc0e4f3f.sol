
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
}// Unlicensed

pragma solidity ^0.8.0;
pragma abicoder v2;


interface IWETH is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 wad) external;

}// Unlicensed

pragma solidity ^0.8.0;

interface IMintable {

    function mint(address to, bytes memory data) external;

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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// Unlicensed

pragma solidity ^0.8.0;


contract MarketNG is IERC721Receiver, IERC1155Receiver, ReentrancyGuard, Ownable, Pausable {

    using SafeERC20 for IERC20;

    uint8 public constant KIND_SELL = 1;
    uint8 public constant KIND_BUY = 2;
    uint8 public constant KIND_AUCTION = 3;

    uint8 public constant STATUS_OPEN = 0;
    uint8 public constant STATUS_DONE = 1;
    uint8 public constant STATUS_CANCELLED = 2;

    uint8 public constant OP_MIN = 0; // invalid, for checks only
    uint8 public constant OP_COMPLETE_SELL = 1; // complete sell (off-chain)
    uint8 public constant OP_COMPLETE_BUY = 2; // complete buy (off-chain)
    uint8 public constant OP_BUY = 3; // create KIND_BUY
    uint8 public constant OP_ACCEPT_BUY = 4; // complete KIND_BUY
    uint8 public constant OP_CANCEL_BUY = 5; // cancel KIND_BUY
    uint8 public constant OP_REJECT_BUY = 6; // reject KIND_BUY
    uint8 public constant OP_BID = 7; // bid (create or update KIND_AUCTION)
    uint8 public constant OP_COMPLETE_AUCTION = 8; // complete auction (by anyone)
    uint8 public constant OP_ACCEPT_AUCTION = 9; // accept auction in an early stage (by seller)
    uint8 public constant OP_MAX = 10;

    uint8 public constant TOKEN_MINT = 0; // mint token (do anything)
    uint8 public constant TOKEN_721 = 1; // 721 token
    uint8 public constant TOKEN_1155 = 2; // 1155 token

    uint256 public constant RATE_BASE = 1e6;

    struct Pair721 {
        IERC721 token;
        uint256 tokenId;
    }

    struct TokenPair {
        address token; // token contract address
        uint256 tokenId; // token id (if applicable)
        uint256 amount; // token amount (if applicable)
        uint8 kind; // token kind (721/1151/mint)
        bytes mintData; // mint data (if applicable)
    }

    struct Inventory {
        address seller;
        address buyer;
        IERC20 currency;
        uint256 price; // display price
        uint256 netPrice; // actual price (auction: minus incentive)
        uint256 deadline; // deadline for the inventory
        uint8 kind;
        uint8 status;
    }

    struct Intention {
        address user;
        TokenPair[] bundle;
        IERC20 currency;
        uint256 price;
        uint256 deadline;
        bytes32 salt;
        uint8 kind;
    }

    struct Detail {
        bytes32 intentionHash;
        address signer;
        uint256 txDeadline; // deadline for the transaction
        bytes32 salt;
        uint256 id; // inventory id
        uint8 opcode; // OP_*
        address caller;
        IERC20 currency;
        uint256 price;
        uint256 incentiveRate;
        Settlement settlement;
        TokenPair[] bundle;
        uint256 deadline; // deadline for buy offer
    }

    struct Settlement {
        uint256[] coupons;
        uint256 feeRate;
        uint256 royaltyRate;
        uint256 buyerCashbackRate;
        address feeAddress;
        address royaltyAddress;
    }

    struct Swap {
        bytes32 salt;
        address creator;
        uint256 deadline;
        Pair721[] has;
        Pair721[] wants;
    }


    event EvCouponSpent(uint256 indexed id, uint256 indexed couponId);
    event EvInventoryUpdate(uint256 indexed id, Inventory inventory);
    event EvAuctionRefund(uint256 indexed id, address bidder, uint256 refund);
    event EvSettingsUpdated();
    event EvMarketSignerUpdate(address addr, bool isRemoval);
    event EvSwapped(Swap req, bytes signature, address swapper);


    IWETH public immutable weth;

    mapping(uint256 => Inventory) public inventories;
    mapping(uint256 => bool) public couponSpent;
    mapping(uint256 => mapping(uint256 => TokenPair)) public inventoryTokens;
    mapping(uint256 => uint256) public inventoryTokenCounts;
    mapping(address => bool) public marketSigners;

    uint256 public minAuctionIncrement = (5 * RATE_BASE) / 100;
    uint256 public minAuctionDuration = 10 * 60;

    bool internal _canReceive = false;


    constructor(IWETH weth_) {
        weth = weth_;
    }

    function updateSettings(uint256 minAuctionIncrement_, uint256 minAuctionDuration_)
        public
        onlyOwner
    {

        minAuctionDuration = minAuctionDuration_;
        minAuctionIncrement = minAuctionIncrement_;
        emit EvSettingsUpdated();
    }

    function updateSigner(address addr, bool remove) public onlyOwner {

        if (remove) {
            delete marketSigners[addr];
        } else {
            marketSigners[addr] = true;
        }
        emit EvMarketSignerUpdate(addr, remove);
    }


    receive() external payable {}

    function pause() public onlyOwner {

        _pause();
    }

    function unpause() public onlyOwner {

        _unpause();
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external view override _onTransferOnly returns (bytes4) {

        (operator);
        (from);
        (tokenId);
        (data);
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external view override _onTransferOnly returns (bytes4) {

        (operator);
        (from);
        (id);
        (value);
        (data);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external view override _onTransferOnly returns (bytes4) {

        (operator);
        (from);
        (ids);
        (values);
        (data);
        return this.onERC1155BatchReceived.selector;
    }

    modifier _onTransferOnly() {

        require(_canReceive, 'can not transfer token directly');
        _;
    }

    modifier _allowTransfer() {

        _canReceive = true;
        _;
        _canReceive = false;
    }


    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {

        return
            (interfaceId == type(IERC721Receiver).interfaceId) ||
            (interfaceId == type(IERC1155Receiver).interfaceId);
    }

    function run(
        Intention calldata intent,
        Detail calldata detail,
        bytes calldata sigIntent,
        bytes calldata sigDetail
    ) public payable nonReentrant whenNotPaused {

        require(detail.txDeadline > block.timestamp, 'transaction deadline reached');
        require(marketSigners[detail.signer], 'unknown market signer');

        _validateOpCode(detail.opcode);
        require(
            isSignatureValid(sigDetail, keccak256(abi.encode(detail)), detail.signer),
            'offer signature error'
        );

        if (hasSignedIntention(detail.opcode)) {
            bytes memory encodedInt = abi.encode(intent);
            require(keccak256(encodedInt) == detail.intentionHash, 'intention hash does not match');
            require(
                isSignatureValid(sigIntent, keccak256(encodedInt), intent.user),
                'intention signature error'
            );
        }

        if (detail.opcode == OP_COMPLETE_SELL) {
            _assertSender(detail.caller);
            require(intent.kind == KIND_SELL, 'intent.kind should be KIND_SELL');
            _newSellDeal(
                detail.id,
                intent.user,
                intent.bundle,
                intent.currency,
                intent.price,
                intent.deadline,
                detail.caller,
                detail.settlement
            );
        } else if (detail.opcode == OP_COMPLETE_BUY) {
            _assertSender(detail.caller);
            require(intent.kind == KIND_BUY, 'intent.kind should be KIND_BUY');
            _newBuyDeal(
                detail.id,
                intent.user, // buyer
                detail.caller, // seller
                intent.bundle,
                intent.currency,
                intent.price,
                intent.deadline,
                detail.settlement
            );
        } else if (detail.opcode == OP_BUY) {
            _assertSender(detail.caller);
            _newBuy(
                detail.id,
                detail.caller,
                detail.currency,
                detail.price,
                detail.bundle,
                detail.deadline
            );
        } else if (detail.opcode == OP_ACCEPT_BUY) {
            _assertSender(detail.caller);
            _acceptBuy(detail.id, detail.caller, detail.settlement);
        } else if (detail.opcode == OP_CANCEL_BUY) {
            _cancelBuyAnyway(detail.id);
        } else if (detail.opcode == OP_REJECT_BUY) {
            _rejectBuy(detail.id);
        } else if (detail.opcode == OP_BID) {
            _assertSender(detail.caller);
            require(intent.kind == KIND_AUCTION, 'intent.kind should be KIND_AUCTION');
            _bid(
                detail.id,
                intent.user,
                intent.bundle,
                intent.currency,
                intent.price,
                intent.deadline,
                detail.caller,
                detail.price,
                detail.incentiveRate
            );
        } else if (detail.opcode == OP_COMPLETE_AUCTION) {
            _completeAuction(detail.id, detail.settlement);
        } else if (detail.opcode == OP_ACCEPT_AUCTION) {
            _assertSender(detail.caller);
            require(detail.caller == intent.user, 'only seller can call');
            _acceptAuction(detail.id, detail.settlement);
        } else {
            revert('impossible');
        }
    }

    function cancelBuys(uint256[] calldata ids) public nonReentrant whenNotPaused {

        for (uint256 i = 0; i < ids.length; i++) {
            _cancelBuy(ids[i]);
        }
    }

    function inCaseMoneyGetsStuck(address to, IERC20 currency, uint256 amount) public onlyOwner {

        _transfer(currency, to, amount);
    }

    function emergencyCancelAuction(uint256 id, bool noBundle) public onlyOwner {

        require(isAuction(id), 'not auction');
        require(isStatusOpen(id), 'not open');
        Inventory storage inv = inventories[id];

        if (!noBundle) {
            _transferBundle(id, address(this), inv.seller, false);
        }
        _transfer(inv.currency, inv.buyer, inv.netPrice);

        inv.status = STATUS_CANCELLED;
        emit EvInventoryUpdate(id, inv);
    }

    function swap(Swap memory req, bytes memory signature) public nonReentrant whenNotPaused {

        require(req.deadline > block.timestamp, 'deadline reached');
        require(
            isSignatureValid(signature, keccak256(abi.encode(req)), req.creator),
            'signature error'
        );

        for (uint256 i = 0; i < req.wants.length; i++) {
            req.wants[i].token.safeTransferFrom(msg.sender, req.creator, req.wants[i].tokenId);
        }

        for (uint256 i = 0; i < req.has.length; i++) {
            req.has[i].token.safeTransferFrom(req.creator, msg.sender, req.has[i].tokenId);
        }

        emit EvSwapped(req, signature, msg.sender);
    }

    function send(address to, Pair721[] memory tokens) public nonReentrant whenNotPaused {

        for (uint256 i = 0; i < tokens.length; i++) {
            Pair721 memory p = tokens[i];
            p.token.safeTransferFrom(msg.sender, to, p.tokenId);
        }
    }


    function _assertSender(address sender) internal view {

        require(sender == msg.sender, 'wrong sender');
    }

    function _validateOpCode(uint8 opCode) internal pure {

        require(opCode > OP_MIN && opCode < OP_MAX, 'invalid opcode');
    }

    function _saveBundle(uint256 invId, TokenPair[] calldata bundle) internal {

        require(bundle.length > 0, 'empty bundle');
        inventoryTokenCounts[invId] = bundle.length;
        for (uint256 i = 0; i < bundle.length; i++) {
            inventoryTokens[invId][i] = bundle[i];
        }
    }

    function _newBuy(
        uint256 id,
        address buyer,
        IERC20 currency,
        uint256 price,
        TokenPair[] calldata bundle,
        uint256 deadline
    ) internal {

        require(!hasInv(id), 'inventoryId already exists');
        require(deadline > block.timestamp, 'deadline must be greater than now');
        _saveBundle(id, bundle);

        if (_isNative(currency)) {
            require(price == msg.value, 'price == msg.value');
            weth.deposit{value: price}(); // convert to erc20 (weth)
        } else {
            currency.safeTransferFrom(buyer, address(this), price);
        }

        inventories[id] = Inventory({
            seller: address(0),
            buyer: buyer,
            currency: currency,
            price: price,
            netPrice: price,
            kind: KIND_BUY,
            status: STATUS_OPEN,
            deadline: deadline
        });
        emit EvInventoryUpdate(id, inventories[id]);
    }

    function _cancelBuy(uint256 id) internal {

        Inventory storage inv = inventories[id];
        require(inv.buyer == msg.sender || isExpired(id), 'caller is not buyer');
        _cancelBuyAnyway(id);
    }

    function _cancelBuyAnyway(uint256 id) internal {

        require(isBuy(id) && isStatusOpen(id), 'not open buy');
        Inventory storage inv = inventories[id];

        inv.status = STATUS_CANCELLED;
        _transfer(inv.currency, inv.buyer, inv.netPrice);

        emit EvInventoryUpdate(id, inventories[id]);
    }

    function _rejectBuy(uint256 id) internal {

        address caller = msg.sender;
        require(isBuy(id) && isStatusOpen(id), 'not open buy');

        for (uint256 i = 0; i < inventoryTokenCounts[id]; i++) {
            TokenPair storage p = inventoryTokens[id][i];
            if (p.kind == TOKEN_721) {
                IERC721 t = IERC721(p.token);
                require(t.ownerOf(p.tokenId) == caller, 'caller does not own token');
            } else {
                revert('cannot reject non-721 token');
            }
        }

        _cancelBuyAnyway(id);
    }

    function _acceptBuy(
        uint256 id,
        address seller,
        Settlement calldata settlement
    ) internal {

        require(isBuy(id), 'id does not exist');
        Inventory storage inv = inventories[id];
        require(isStatusOpen(id), 'not open');
        require(isBundleApproved(id, seller), 'bundle not approved');
        require(!isExpired(id), 'buy offer expired');

        inv.status = STATUS_DONE;
        inv.seller = seller;
        _transferBundle(id, seller, inv.buyer, true);

        emit EvInventoryUpdate(id, inventories[id]);
        _completeTransaction(id, settlement);
    }

    function _newBuyDeal(
        uint256 id,
        address buyer,
        address seller,
        TokenPair[] calldata bundle,
        IERC20 currency,
        uint256 price,
        uint256 deadline,
        Settlement calldata settlement
    ) internal {

        require(!hasInv(id), 'inventory already exists');
        require(deadline > block.timestamp, 'buy has already ended');
        require(!_isNative(currency), 'cannot use native token');

        _saveBundle(id, bundle);
        _transferBundle(id, seller, buyer, true);
        currency.safeTransferFrom(buyer, address(this), price);

        inventories[id] = Inventory({
            seller: seller,
            buyer: buyer,
            currency: currency,
            price: price,
            netPrice: price,
            kind: KIND_BUY,
            status: STATUS_DONE,
            deadline: deadline
        });
        emit EvInventoryUpdate(id, inventories[id]);

        _completeTransaction(id, settlement);
    }

    function _newSellDeal(
        uint256 id,
        address seller,
        TokenPair[] calldata bundle,
        IERC20 currency,
        uint256 price,
        uint256 deadline,
        address buyer,
        Settlement calldata settlement
    ) internal {

        require(!hasInv(id), 'duplicate id');
        require(deadline > block.timestamp, 'sell has already ended');

        _saveBundle(id, bundle);
        _transferBundle(id, seller, buyer, true);

        if (_isNative(currency)) {
            require(price == msg.value, 'price == msg.value');
            weth.deposit{value: price}(); // convert to erc20 (weth)
        } else {
            currency.safeTransferFrom(buyer, address(this), price);
        }

        inventories[id] = Inventory({
            seller: seller,
            buyer: buyer,
            currency: currency,
            price: price,
            netPrice: price,
            kind: KIND_SELL,
            status: STATUS_DONE,
            deadline: deadline
        });
        emit EvInventoryUpdate(id, inventories[id]);

        _completeTransaction(id, settlement);
    }

    function _bid(
        uint256 id,
        address seller,
        TokenPair[] calldata bundle,
        IERC20 currency,
        uint256 startPrice,
        uint256 deadline,
        address buyer,
        uint256 price,
        uint256 incentiveRate
    ) internal _allowTransfer {

        require(incentiveRate < RATE_BASE, 'incentiveRate too large');

        if (_isNative(currency)) {
            require(price == msg.value, 'price == msg.value');
            weth.deposit{value: price}(); // convert to erc20 (weth)
        } else {
            currency.safeTransferFrom(buyer, address(this), price);
        }

        if (isAuction(id)) {
            Inventory storage auc = inventories[id];
            require(auc.seller == seller, 'seller does not match'); // TODO check more
            require(auc.status == STATUS_OPEN, 'auction not open');
            require(auc.deadline > block.timestamp, 'auction ended');

            require(
                price >= auc.price + ((auc.price * minAuctionIncrement) / RATE_BASE),
                'bid price too low'
            );

            uint256 incentive = (price * incentiveRate) / RATE_BASE;
            _transfer(currency, auc.buyer, auc.netPrice + incentive);
            emit EvAuctionRefund(id, auc.buyer, auc.netPrice + incentive);

            auc.buyer = buyer;
            auc.price = price;
            auc.netPrice = price - incentive;

            if (block.timestamp + minAuctionDuration >= auc.deadline) {
                auc.deadline += minAuctionDuration;
            }
        } else {
            require(!hasInv(id), 'inventory is not auction');
            require(price >= startPrice, 'bid lower than start price');
            require(deadline > block.timestamp, 'auction ended');

            uint256 deadline0 = deadline;
            if (block.timestamp + minAuctionDuration >= deadline) {
                deadline0 += minAuctionDuration;
            }

            inventories[id] = Inventory({
                seller: seller,
                buyer: buyer,
                currency: currency,
                price: price,
                netPrice: price,
                deadline: deadline0,
                status: STATUS_OPEN,
                kind: KIND_AUCTION
            });
            _saveBundle(id, bundle);
            _transferBundle(id, seller, address(this), false);
        }
        emit EvInventoryUpdate(id, inventories[id]);
    }

    function _completeAuction(uint256 id, Settlement calldata settlement) internal {

        require(inventories[id].deadline < block.timestamp, 'auction still going');
        _acceptAuction(id, settlement);
    }

    function _acceptAuction(uint256 id, Settlement calldata settlement) internal {

        require(isAuction(id), 'auction does not exist');
        require(isStatusOpen(id), 'auction not open');
        Inventory storage auc = inventories[id];

        auc.status = STATUS_DONE;
        emit EvInventoryUpdate(id, inventories[id]);
        _transferBundle(id, address(this), auc.buyer, true);
        _completeTransaction(id, settlement);
    }

    function _completeTransaction(uint256 id, Settlement calldata settlement) internal {

        Inventory storage inv = inventories[id];
        require(hasInv(id) && inv.status == STATUS_DONE, 'no inventory or state error'); // sanity

        _markCoupon(id, settlement.coupons);

        uint256 price = inv.price;
        uint256 fee = (price * settlement.feeRate) / RATE_BASE;
        uint256 royalty = (price * settlement.royaltyRate) / RATE_BASE;
        uint256 buyerAmount = (price * settlement.buyerCashbackRate) / RATE_BASE;
        uint256 sellerAmount = inv.netPrice - fee - royalty - buyerAmount;

        _transfer(inv.currency, inv.seller, sellerAmount);
        _transfer(inv.currency, inv.buyer, buyerAmount);
        _transfer(inv.currency, settlement.feeAddress, fee);
        _transfer(inv.currency, settlement.royaltyAddress, royalty);
    }

    function _markCoupon(uint256 invId, uint256[] calldata coupons) internal {

        for (uint256 i = 0; i < coupons.length; i++) {
            uint256 id = coupons[i];
            require(!couponSpent[id], 'coupon already spent');
            couponSpent[id] = true;
            emit EvCouponSpent(invId, id);
        }
    }

    function _isNative(IERC20 currency) internal pure returns (bool) {

        return address(currency) == address(0);
    }

    function _transfer(
        IERC20 currency,
        address to,
        uint256 amount
    ) internal {

        if (amount == 0) {
            return;
        }
        require(to != address(0), 'cannot transfer to address(0)');
        if (_isNative(currency)) {
            weth.withdraw(amount);
            payable(to).transfer(amount);
        } else {
            currency.safeTransfer(to, amount);
        }
    }

    function _transferBundle(
        uint256 invId,
        address from,
        address to,
        bool doMint
    ) internal {

        uint256 tokenCount = inventoryTokenCounts[invId];
        for (uint256 i = 0; i < tokenCount; i++) {
            TokenPair storage p = inventoryTokens[invId][i];
            if (p.kind == TOKEN_MINT) {
                if (doMint) {
                    require(
                        to != address(0) && to != address(this),
                        'mint target cannot be zero or market'
                    );
                    IMintable(p.token).mint(to, p.mintData);
                }
            } else if (p.kind == TOKEN_721) {
                IERC721(p.token).safeTransferFrom(from, to, p.tokenId);
            } else if (p.kind == TOKEN_1155) {
                IERC1155(p.token).safeTransferFrom(from, to, p.tokenId, p.amount, '');
            } else {
                revert('unsupported token');
            }
        }
    }


    function isBundleApproved(uint256 invId, address owner) public view returns (bool) {

        require(hasInv(invId), 'no inventory');

        for (uint256 i = 0; i < inventoryTokenCounts[invId]; i++) {
            TokenPair storage p = inventoryTokens[invId][i];
            if (p.kind == TOKEN_MINT) {
            } else if (p.kind == TOKEN_721) {
                IERC721 t = IERC721(p.token);
                if (
                    t.ownerOf(p.tokenId) == owner &&
                    (t.getApproved(p.tokenId) == address(this) ||
                        t.isApprovedForAll(owner, address(this)))
                ) {
                } else {
                    return false;
                }
            } else if (p.kind == TOKEN_1155) {
                IERC1155 t = IERC1155(p.token);
                if (
                    t.balanceOf(owner, p.tokenId) >= p.amount &&
                    t.isApprovedForAll(owner, address(this))
                ) {
                } else {
                    return false;
                }
            } else {
                revert('unsupported token');
            }
        }
        return true;
    }

    function isAuctionOpen(uint256 id) public view returns (bool) {

        return
            isAuction(id) &&
            inventories[id].status == STATUS_OPEN &&
            inventories[id].deadline > block.timestamp;
    }

    function isBuyOpen(uint256 id) public view returns (bool) {

        return
            isBuy(id) &&
            inventories[id].status == STATUS_OPEN &&
            inventories[id].deadline > block.timestamp;
    }

    function isAuction(uint256 id) public view returns (bool) {

        return inventories[id].kind == KIND_AUCTION;
    }

    function isBuy(uint256 id) public view returns (bool) {

        return inventories[id].kind == KIND_BUY;
    }

    function isSell(uint256 id) public view returns (bool) {

        return inventories[id].kind == KIND_SELL;
    }

    function hasInv(uint256 id) public view returns (bool) {

        return inventories[id].kind != 0;
    }

    function isStatusOpen(uint256 id) public view returns (bool) {

        return inventories[id].status == STATUS_OPEN;
    }

    function isExpired(uint256 id) public view returns (bool) {

        return block.timestamp >= inventories[id].deadline;
    }

    function isSignatureValid(
        bytes memory signature,
        bytes32 hash,
        address signer
    ) public pure returns (bool) {

        return ECDSA.recover(ECDSA.toEthSignedMessageHash(hash), signature) == signer;
    }

    function hasSignedIntention(uint8 op) public pure returns (bool) {

        return op != OP_BUY && op != OP_CANCEL_BUY && op != OP_ACCEPT_BUY && op != OP_REJECT_BUY;
    }
}