


pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}


library SafeERC20 {

    using SafeMath for uint256;

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

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {



        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}




abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;


    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}


interface IDODOApproveProxy {

    function claimTokens(address token,address who,address dest,uint256 amount) external;

}



contract InitializableOwnable {

    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier notInitialized() {

        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    function initOwner(address newOwner) public notInitialized {

        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}



library ArgumentsDecoder {

    function decodeSelector(bytes memory data) internal pure returns(bytes4 selector) {

        assembly { // solhint-disable-line no-inline-assembly
            selector := mload(add(data, 0x20))
        }
    }

    function decodeAddress(bytes memory data, uint256 argumentIndex) internal pure returns(address account) {

        assembly { // solhint-disable-line no-inline-assembly
            account := mload(add(add(data, 0x24), mul(argumentIndex, 0x20)))
        }
    }

    function decodeUint256(bytes memory data, uint256 argumentIndex) internal pure returns(uint256 value) {

        assembly { // solhint-disable-line no-inline-assembly
            value := mload(add(add(data, 0x24), mul(argumentIndex, 0x20)))
        }
    }

    function patchAddress(bytes memory data, uint256 argumentIndex, address account) internal pure {

        assembly { // solhint-disable-line no-inline-assembly
            mstore(add(add(data, 0x24), mul(argumentIndex, 0x20)), account)
        }
    }

    function patchUint256(bytes memory data, uint256 argumentIndex, uint256 value) internal pure {

        assembly { // solhint-disable-line no-inline-assembly
            mstore(add(add(data, 0x24), mul(argumentIndex, 0x20)), value)
        }
    }
}




contract DODOLimitOrder is EIP712("DODO Limit Order Protocol", "1"), InitializableOwnable{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using ArgumentsDecoder for bytes;

    struct Order {
        address makerToken;
        address takerToken;
        uint256 makerAmount;
        uint256 takerAmount;
        address maker;
        address taker;
        uint256 expiration;
        uint256 salt;
    }

    struct RfqOrder {
        address makerToken;
        address takerToken;
        uint256 makerAmount;
        uint256 takerAmount;
        uint256 makerTokenFeeAmount;
        uint256 takerFillAmount;
        address maker;
        address taker;
        uint256 expiration;
        uint256 slot;
    }

    bytes32 constant public ORDER_TYPEHASH = keccak256(
        "Order(address makerToken,address takerToken,uint256 makerAmount,uint256 takerAmount,address maker,address taker,uint256 expiration,uint256 salt)"
    );

    bytes32 constant public RFQ_ORDER_TYPEHASH = keccak256(
        "Order(address makerToken,address takerToken,uint256 makerAmount,uint256 takerAmount,uint256 makerTokenFeeAmount,uint256 takerFillAmount,address maker,address taker,uint256 expiration,uint256 slot)"
    );


    mapping(bytes32 => uint256) public _FILLED_TAKER_AMOUNT_; //limitOrder
    mapping(address => mapping(uint256 => uint256)) public _RFQ_FILLED_TAKER_AMOUNT_; //RFQ
    
    mapping (address => bool) public isWhiteListed;
    mapping (address => bool) public isAdminListed;
    address public _DODO_APPROVE_PROXY_;
    address public _FEE_RECEIVER_;
    
    event LimitOrderFilled(address indexed maker, address indexed taker, bytes32 orderHash, uint256 curTakerFillAmount, uint256 curMakerFillAmount);
    event RFQByUserFilled(address indexed maker, address indexed taker, bytes32 orderHash, uint256 curTakerFillAmount, uint256 curMakerFillAmount);
    event RFQByPlatformFilled(address indexed maker, address indexed taker, bytes32 orderHash, uint256 curTakerFillAmount, uint256 curMakerFillAmount);
    event AddWhileList(address addr);
    event RemoveWhiteList(address addr);
    event AddAdmin(address admin);
    event RemoveAdmin(address admin);
    event ChangeFeeReceiver(address newFeeReceiver);
    
    function init(address owner, address dodoApproveProxy, address feeReciver) external {

        initOwner(owner);
        _DODO_APPROVE_PROXY_ = dodoApproveProxy;
        _FEE_RECEIVER_ = feeReciver;
    }

    function fillLimitOrder(
        Order memory order,
        bytes memory signature,
        uint256 takerFillAmount,
        uint256 thresholdTakerAmount,
        bytes memory takerInteraction
    ) public returns(uint256 curTakerFillAmount, uint256 curMakerFillAmount) {

        bytes32 orderHash = _orderHash(order);
        uint256 filledTakerAmount = _FILLED_TAKER_AMOUNT_[orderHash];

        require(filledTakerAmount < order.takerAmount, "DLOP: ALREADY_FILLED");

        require(order.taker == msg.sender, "DLOP:PRIVATE_ORDER");

        require(ECDSA.recover(orderHash, signature) == order.maker, "DLOP:INVALID_SIGNATURE");
        require(order.expiration > block.timestamp, "DLOP: EXPIRE_ORDER");


        uint256 leftTakerAmount = order.takerAmount.sub(filledTakerAmount);
        curTakerFillAmount = takerFillAmount < leftTakerAmount ? takerFillAmount:leftTakerAmount;
        curMakerFillAmount = curTakerFillAmount.mul(order.makerAmount).div(order.takerAmount);

        require(curTakerFillAmount > 0 && curMakerFillAmount > 0, "DLOP: ZERO_FILL_INVALID");
        require(curTakerFillAmount >= thresholdTakerAmount, "DLOP: FILL_AMOUNT_NOT_ENOUGH");

        _FILLED_TAKER_AMOUNT_[orderHash] = filledTakerAmount.add(curTakerFillAmount);

        IDODOApproveProxy(_DODO_APPROVE_PROXY_).claimTokens(order.makerToken, order.maker, msg.sender, curMakerFillAmount);

        if(takerInteraction.length > 0) {
            takerInteraction.patchUint256(0, curTakerFillAmount);
            takerInteraction.patchUint256(1, curMakerFillAmount);
            require(isWhiteListed[msg.sender], "DLOP: Not Whitelist Contract");
            (bool success, ) = msg.sender.call(takerInteraction);
            require(success, "DLOP: TAKER_INTERACTIVE_FAILED");
        }

        IERC20(order.takerToken).safeTransferFrom(msg.sender, order.maker, curTakerFillAmount);

        emit LimitOrderFilled(order.maker, msg.sender, orderHash, curTakerFillAmount, curMakerFillAmount);
    }


    function matchingRFQByPlatform(
        RfqOrder memory order,
        bytes memory makerSignature,
        bytes memory takerSignature,
        uint256 takerFillAmount,
        uint256 thresholdMakerAmount,
        uint256 makerTokenFeeAmount,
        address taker
    ) public returns(uint256 curTakerFillAmount, uint256 curMakerFillAmount) {

        require(isAdminListed[msg.sender], "ACCESS_DENIED");
        uint256 filledTakerAmount = _RFQ_FILLED_TAKER_AMOUNT_[order.maker][order.slot];
        require(filledTakerAmount < order.takerAmount, "DLOP: ALREADY_FILLED");

        bytes32 orderHashForMaker = _rfqOrderHash(order);
        require(ECDSA.recover(orderHashForMaker, makerSignature) == order.maker, "DLOP:INVALID_MAKER_SIGNATURE");
        require(order.taker == address(0), "DLOP:TAKER_INVALID");

        order.taker = taker;
        order.makerTokenFeeAmount = makerTokenFeeAmount;
        order.takerFillAmount = takerFillAmount;

        bytes32 orderHashForTaker = _rfqOrderHash(order);
        require(ECDSA.recover(orderHashForTaker, takerSignature) == taker, "DLOP:INVALID_TAKER_SIGNATURE");

        (curTakerFillAmount, curMakerFillAmount) = _settleRFQ(order,filledTakerAmount,takerFillAmount,thresholdMakerAmount,taker);
        
        emit RFQByPlatformFilled(order.maker, taker, orderHashForMaker, curTakerFillAmount, curMakerFillAmount);
    }

    function addWhiteList (address contractAddr) public onlyOwner {
        isWhiteListed[contractAddr] = true;
        emit AddWhileList(contractAddr);
    }

    function removeWhiteList (address contractAddr) public onlyOwner {
        isWhiteListed[contractAddr] = false;
        emit RemoveWhiteList(contractAddr);
    }

    function addAdminList (address userAddr) external onlyOwner {
        isAdminListed[userAddr] = true;
        emit AddAdmin(userAddr);
    }

    function removeAdminList (address userAddr) external onlyOwner {
        isAdminListed[userAddr] = false;
        emit RemoveAdmin(userAddr);
    }

    function changeFeeReceiver (address newFeeReceiver) public onlyOwner {
        _FEE_RECEIVER_ = newFeeReceiver;
        emit ChangeFeeReceiver(newFeeReceiver);
    }

    function _settleRFQ(
        RfqOrder memory order,
        uint256 filledTakerAmount,
        uint256 takerFillAmount,
        uint256 thresholdMakerAmount,
        address taker
    ) internal returns(uint256,uint256) {

        require(order.expiration > block.timestamp, "DLOP: EXPIRE_ORDER");

        uint256 leftTakerAmount = order.takerAmount.sub(filledTakerAmount);
        require(takerFillAmount <= leftTakerAmount, "DLOP: RFQ_TAKER_AMOUNT_NOT_ENOUGH");
        
        uint256 curTakerFillAmount = takerFillAmount;
        uint256 curMakerFillAmount = curTakerFillAmount.mul(order.makerAmount).div(order.takerAmount);

        require(curTakerFillAmount > 0 && curMakerFillAmount > 0, "DLOP: ZERO_FILL_INVALID");
        require(curMakerFillAmount.sub(order.makerTokenFeeAmount) >= thresholdMakerAmount, "DLOP: FILL_AMOUNT_NOT_ENOUGH");

        _RFQ_FILLED_TAKER_AMOUNT_[order.maker][order.slot] = filledTakerAmount.add(curTakerFillAmount);

        if(order.makerTokenFeeAmount > 0) {
            IDODOApproveProxy(_DODO_APPROVE_PROXY_).claimTokens(order.makerToken, order.maker, _FEE_RECEIVER_, order.makerTokenFeeAmount);
        }
        IDODOApproveProxy(_DODO_APPROVE_PROXY_).claimTokens(order.makerToken, order.maker, taker, curMakerFillAmount.sub(order.makerTokenFeeAmount));
        IDODOApproveProxy(_DODO_APPROVE_PROXY_).claimTokens(order.takerToken, taker, order.maker, curTakerFillAmount);

        return (curTakerFillAmount, curMakerFillAmount);
    }


    function _orderHash(Order memory order) private view returns(bytes32) {

        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    ORDER_TYPEHASH,
                    order.makerToken,
                    order.takerToken,
                    order.makerAmount,
                    order.takerAmount,
                    order.maker,
                    order.taker,
                    order.expiration,
                    order.salt
                )
            )
        );
    }

    function _rfqOrderHash(RfqOrder memory order) private view returns(bytes32) {

        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    RFQ_ORDER_TYPEHASH,
                    order.makerToken,
                    order.takerToken,
                    order.makerAmount,
                    order.takerAmount,
                    order.makerTokenFeeAmount,
                    order.takerFillAmount,
                    order.maker,
                    order.taker,
                    order.expiration,
                    order.slot
                )
            )
        );
    }
}