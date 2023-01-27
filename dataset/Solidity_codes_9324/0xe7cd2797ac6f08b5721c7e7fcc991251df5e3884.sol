
pragma solidity ^0.6.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

struct Signature {
    bytes32 r;
    bytes32 s;
    uint8 v;
}

interface IOptIn {

    struct OptInStatus {
        bool isOptedIn;
        bool permaBoostActive;
        address optedInTo;
        uint32 optOutPeriod;
    }

    function getOptInStatusPair(address accountA, address accountB)
        external
        view
        returns (OptInStatus memory, OptInStatus memory);


    function getOptInStatus(address account)
        external
        view
        returns (OptInStatus memory);


    function isOptedInBy(address _sender, address _account)
        external
        view
        returns (bool, uint256);

}// MIT
pragma solidity 0.6.12;

struct BoosterFuel {
    uint96 dubi;
    uint96 unlockedPrps;
    uint96 lockedPrps;
    uint96 intrinsicFuel;
}

struct BoosterPayload {
    address booster;
    uint64 timestamp;
    uint64 nonce;
    bool isLegacySignature;
}

library BoostableLib {

    bytes32 private constant BOOSTER_PAYLOAD_TYPEHASH = keccak256(
        "BoosterPayload(address booster,uint64 timestamp,uint64 nonce,bool isLegacySignature)"
    );

    bytes32 internal constant BOOSTER_FUEL_TYPEHASH = keccak256(
        "BoosterFuel(uint96 dubi,uint96 unlockedPrps,uint96 lockedPrps,uint96 intrinsicFuel)"
    );

    function hashWithDomainSeparator(
        bytes32 domainSeparator,
        bytes32 messageHash
    ) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, messageHash)
            );
    }

    function hashBoosterPayload(BoosterPayload memory payload, address booster)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    BOOSTER_PAYLOAD_TYPEHASH,
                    booster,
                    payload.timestamp,
                    payload.nonce,
                    payload.isLegacySignature
                )
            );
    }

    function hashBoosterFuel(BoosterFuel memory fuel)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    BOOSTER_FUEL_TYPEHASH,
                    fuel.dubi,
                    fuel.unlockedPrps,
                    fuel.lockedPrps,
                    fuel.intrinsicFuel
                )
            );
    }

    function _readBoosterTag(bytes memory boosterMessage)
        internal
        pure
        returns (uint8)
    {

        uint8 tag = uint8(boosterMessage[31]);
        if (tag >= 32) {
            tag = uint8(boosterMessage[31 + tag]);
        }

        return tag;
    }
}// MIT
pragma solidity 0.6.12;

struct TokenFuel {
    uint8 tokenAlias;
    uint96 amount;
}

interface IBoostableERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );


    function boostedTransferFrom(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);


    function burnFuel(address from, TokenFuel memory fuel) external;

}// MIT
pragma solidity 0.6.12;


abstract contract EIP712Boostable {
    using ECDSA for bytes32;

    IOptIn internal immutable _OPT_IN;
    bytes32 internal immutable _DOMAIN_SEPARATOR;

    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 private constant BOOSTER_PAYLOAD_TYPEHASH = keccak256(
        "BoosterPayload(address booster,uint64 timestamp,uint64 nonce,bool isLegacySignature)"
    );

    bytes32 internal constant BOOSTER_FUEL_TYPEHASH = keccak256(
        "BoosterFuel(uint96 dubi,uint96 unlockedPrps,uint96 lockedPrps,uint96 intrinsicFuel)"
    );

    uint96 internal constant MAX_BOOSTER_FUEL = 10 ether;

    bytes6 private constant MAGIC_BOOSTER_PERMISSION_PREFIX = "BOOST-";

    constructor(address optIn, bytes32 domainSeparator) public {
        _OPT_IN = IOptIn(optIn);
        _DOMAIN_SEPARATOR = domainSeparator;
    }

    mapping(address => uint64) private _nonces;


    function getNonce(address account) external virtual view returns (uint64) {
        return _nonces[account];
    }

    function getOptInStatus(address account)
        internal
        view
        returns (IOptIn.OptInStatus memory)
    {
        return _OPT_IN.getOptInStatus(account);
    }

    function verifyBoost(
        address from,
        bytes32 messageHash,
        BoosterPayload memory payload,
        Signature memory signature
    ) internal {
        uint64 currentNonce = _nonces[from];
        require(currentNonce == payload.nonce - 1, "AB-1");

        _nonces[from] = currentNonce + 1;

        _verifyBoostWithoutNonce(from, messageHash, payload, signature);
    }

    function _verifyBoostWithoutNonce(
        address from,
        bytes32 messageHash,
        BoosterPayload memory payload,
        Signature memory signature
    ) internal view {
        require(msg.sender == payload.booster, "AB-2");

        (bool isOptedInToSender, uint256 optOutPeriod) = _OPT_IN.isOptedInBy(
            msg.sender,
            from
        );

        require(isOptedInToSender, "AB-3");

        uint64 _now = uint64(block.timestamp);
        uint64 _optOutPeriod = uint64(optOutPeriod);

        bool notTooFarInFuture = payload.timestamp <= _now + 1 hours;
        bool belowMaxAge = true;

        if (payload.timestamp <= _now) {
            belowMaxAge = _now - payload.timestamp <= _optOutPeriod;
        }

        require(notTooFarInFuture && belowMaxAge, "AB-4");

        if (payload.isLegacySignature) {
            messageHash = messageHash.toEthSignedMessageHash();
        }


        address signer = ecrecover(
            messageHash,
            signature.v,
            signature.r,
            signature.s
        );

        if (!payload.isLegacySignature && signer != from) {
            signer = ecrecover(
                messageHash.toEthSignedMessageHash(),
                signature.v,
                signature.r,
                signature.s
            );
        }

        require(from == signer, "AB-5");
    }

    function hashBoosterPayload(BoosterPayload memory payload, address booster)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    BOOSTER_PAYLOAD_TYPEHASH,
                    booster,
                    payload.timestamp,
                    payload.nonce
                )
            );
    }

    function _getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}// MIT
pragma solidity 0.6.12;

library DubiexLib {

    enum CurrencyType {NULL, ETH, ERC20, BOOSTABLE_ERC20, ERC721}

    enum OrderPairReadStrategy {SKIP, MAKER, TAKER, FULL}

    struct OrderPair {
        address makerContractAddress;
        CurrencyType makerCurrencyType;
        address takerContractAddress;
        CurrencyType takerCurrencyType;
    }

    struct PackedOrderPair {
        uint168 makerPair;
        uint168 takerPair;
    }

    struct PackedOrderBookItem {
        uint256 packedData;
        uint32 successorOrderId;
        uint32 ancestorOrderId;
    }

    struct UnpackedOrderBookItem {
        uint32 id;
        uint96 makerValue;
        uint96 takerValue;
        uint32 orderPairAlias;
        OrderPair pair;
        OrderFlags flags;
    }

    struct PrettyOrderBookItem {
        uint32 id;
        uint96 makerValue;
        uint96 takerValue;
        uint32 orderPairAlias;
        OrderPair pair;
        OrderFlags flags;
        uint32 successorOrderId;
        uint32 ancestorOrderId;
    }

    struct OrderFlags {
        bool isMakerERC721;
        bool isTakerERC721;
        bool isHidden;
        bool hasSuccessor;
    }

    function packOrderBookItem(UnpackedOrderBookItem memory _unpacked)
        internal
        pure
        returns (uint256)
    {





        uint256 packedData;
        uint256 offset;

        uint32 id = _unpacked.id;
        packedData |= id;
        offset += 32;

        uint96 makerValue = _unpacked.makerValue;
        packedData |= uint256(makerValue) << offset;
        offset += 96;

        uint96 takerValue = _unpacked.takerValue;
        packedData |= uint256(takerValue) << offset;
        offset += 96;

        uint32 orderPairAlias = _unpacked.orderPairAlias;
        uint32 orderPairAliasMask = (1 << 28) - 1;
        packedData |= uint256(orderPairAlias & orderPairAliasMask) << offset;
        offset += 28;

        OrderFlags memory flags = _unpacked.flags;
        if (flags.isMakerERC721) {
            packedData |= 1 << (offset + 0);
        }

        if (flags.isTakerERC721) {
            packedData |= 1 << (offset + 1);
        }

        if (flags.isHidden) {
            packedData |= 1 << (offset + 2);
        }

        if (flags.hasSuccessor) {
            packedData |= 1 << (offset + 3);
        }

        offset += 4;

        assert(offset == 256);
        return packedData;
    }

    function unpackOrderBookItem(uint256 packedData)
        internal
        pure
        returns (UnpackedOrderBookItem memory)
    {

        UnpackedOrderBookItem memory _unpacked;
        uint256 offset;

        _unpacked.id = uint32(packedData >> offset);
        offset += 32;

        _unpacked.makerValue = uint96(packedData >> offset);
        offset += 96;

        _unpacked.takerValue = uint96(packedData >> offset);
        offset += 96;

        uint32 orderPairAlias = uint32(packedData >> offset);
        uint32 orderPairAliasMask = (1 << 28) - 1;
        _unpacked.orderPairAlias = orderPairAlias & orderPairAliasMask;
        offset += 28;


        OrderFlags memory flags = _unpacked.flags;

        flags.isMakerERC721 = (packedData >> (offset + 0)) & 1 == 1;
        flags.isTakerERC721 = (packedData >> (offset + 1)) & 1 == 1;
        flags.isHidden = (packedData >> (offset + 2)) & 1 == 1;
        flags.hasSuccessor = (packedData >> (offset + 3)) & 1 == 1;

        offset += 4;

        assert(offset == 256);

        return _unpacked;
    }

    function packOrderPair(OrderPair memory unpacked)
        internal
        pure
        returns (PackedOrderPair memory)
    {

        uint168 packedMaker = uint160(unpacked.makerContractAddress);
        packedMaker |= uint168(unpacked.makerCurrencyType) << 160;

        uint168 packedTaker = uint160(unpacked.takerContractAddress);
        packedTaker |= uint168(unpacked.takerCurrencyType) << 160;

        return PackedOrderPair(packedMaker, packedTaker);
    }

    function unpackOrderPairAddressType(uint168 packed)
        internal
        pure
        returns (address, CurrencyType)
    {

        address unpackedAddress = address(packed);
        CurrencyType unpackedCurrencyType = CurrencyType(uint8(packed >> 160));

        return (unpackedAddress, unpackedCurrencyType);
    }

    struct MakeOrderInput {
        uint96 makerValue;
        uint96 takerValue;
        OrderPair pair;
        uint32 orderId;
        uint32 ancestorOrderId;
        uint128 updatedRatioWei;
    }

    struct TakeOrderInput {
        uint32 id;
        address payable maker;
        uint96 takerValue;
        uint256 maxTakerMakerRatio;
    }

    struct CancelOrderInput {
        uint32 id;
        address payable maker;
    }
}// MIT
pragma solidity 0.6.12;


abstract contract Boostable is EIP712Boostable {
    bytes32 private constant BOOSTED_MAKE_ORDER_TYPEHASH = keccak256(
        "BoostedMakeOrder(MakeOrderInput input,address maker,BoosterFuel fuel,BoosterPayload boosterPayload)BoosterFuel(uint96 dubi,uint96 unlockedPrps,uint96 lockedPrps,uint96 intrinsicFuel)BoosterPayload(address booster,uint64 timestamp,uint64 nonce,bool isLegacySignature)MakeOrderInput(uint96 makerValue,uint96 takerValue,OrderPair pair,uint32 orderId,uint32 ancestorOrderId,uint128 updatedRatioWei)OrderPair(address makerContractAddress,address takerContractAddress,uint8 makerCurrencyType,uint8 takerCurrencyType)"
    );

    bytes32 private constant BOOSTED_TAKE_ORDER_TYPEHASH = keccak256(
        "BoostedTakeOrder(TakeOrderInput input,address taker,BoosterFuel fuel,BoosterPayload boosterPayload)BoosterFuel(uint96 dubi,uint96 unlockedPrps,uint96 lockedPrps,uint96 intrinsicFuel)BoosterPayload(address booster,uint64 timestamp,uint64 nonce,bool isLegacySignature)TakeOrderInput(uint32 id,address maker,uint96 takerValue,uint256 maxTakerMakerRatio)"
    );

    bytes32 private constant BOOSTED_CANCEL_ORDER_TYPEHASH = keccak256(
        "BoostedCancelOrder(CancelOrderInput input,BoosterFuel fuel,BoosterPayload boosterPayload)BoosterFuel(uint96 dubi,uint96 unlockedPrps,uint96 lockedPrps,uint96 intrinsicFuel)BoosterPayload(address booster,uint64 timestamp,uint64 nonce,bool isLegacySignature)CancelOrderInput(uint32 id,address maker)"
    );

    bytes32 private constant MAKE_ORDER_INPUT_TYPEHASH = keccak256(
        "MakeOrderInput(uint96 makerValue,uint96 takerValue,OrderPair pair,uint32 orderId,uint32 ancestorOrderId,uint128 updatedRatioWei)OrderPair(address makerContractAddress,address takerContractAddress,uint8 makerCurrencyType,uint8 takerCurrencyType)"
    );

    bytes32 private constant TAKE_ORDER_INPUT_TYPEHASH = keccak256(
        "TakeOrderInput(uint32 id,address maker,uint96 takerValue,uint256 maxTakerMakerRatio)"
    );

    bytes32 private constant CANCEL_ORDER_INPUT_TYPEHASH = keccak256(
        "CancelOrderInput(uint32 id,address maker)"
    );

    bytes32 private constant ORDER_PAIR_TYPEHASH = keccak256(
        "OrderPair(address makerContractAddress,address takerContractAddress,uint8 makerCurrencyType,uint8 takerCurrencyType)"
    );

    constructor(address optIn)
        public
        EIP712Boostable(
            optIn,
            keccak256(
                abi.encode(
                    EIP712_DOMAIN_TYPEHASH,
                    keccak256("Dubiex"),
                    keccak256("1"),
                    _getChainId(),
                    address(this)
                )
            )
        )
    {}

    struct BoostedMakeOrder {
        DubiexLib.MakeOrderInput input;
        address payable maker;
        BoosterFuel fuel;
        BoosterPayload boosterPayload;
    }

    struct BoostedTakeOrder {
        DubiexLib.TakeOrderInput input;
        address payable taker;
        BoosterFuel fuel;
        BoosterPayload boosterPayload;
    }

    struct BoostedCancelOrder {
        DubiexLib.CancelOrderInput input;
        BoosterFuel fuel;
        BoosterPayload boosterPayload;
    }

    function hashBoostedMakeOrder(
        BoostedMakeOrder memory boostedMakeOrder,
        address booster
    ) internal view returns (bytes32) {
        return
            BoostableLib.hashWithDomainSeparator(
                _DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        BOOSTED_MAKE_ORDER_TYPEHASH,
                        hashMakeOrderInput(boostedMakeOrder.input),
                        boostedMakeOrder.maker,
                        BoostableLib.hashBoosterFuel(boostedMakeOrder.fuel),
                        BoostableLib.hashBoosterPayload(
                            boostedMakeOrder.boosterPayload,
                            booster
                        )
                    )
                )
            );
    }

    function hashBoostedTakeOrder(
        BoostedTakeOrder memory boostedTakeOrder,
        address booster
    ) internal view returns (bytes32) {
        return
            BoostableLib.hashWithDomainSeparator(
                _DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        BOOSTED_TAKE_ORDER_TYPEHASH,
                        hashTakeOrderInput(boostedTakeOrder.input),
                        boostedTakeOrder.taker,
                        BoostableLib.hashBoosterFuel(boostedTakeOrder.fuel),
                        BoostableLib.hashBoosterPayload(
                            boostedTakeOrder.boosterPayload,
                            booster
                        )
                    )
                )
            );
    }

    function hashBoostedCancelOrder(
        BoostedCancelOrder memory boostedCancelOrder,
        address booster
    ) internal view returns (bytes32) {
        return
            BoostableLib.hashWithDomainSeparator(
                _DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        BOOSTED_CANCEL_ORDER_TYPEHASH,
                        hashCancelOrderInput(boostedCancelOrder.input),
                        BoostableLib.hashBoosterFuel(boostedCancelOrder.fuel),
                        BoostableLib.hashBoosterPayload(
                            boostedCancelOrder.boosterPayload,
                            booster
                        )
                    )
                )
            );
    }

    function hashMakeOrderInput(DubiexLib.MakeOrderInput memory input)
        private
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    MAKE_ORDER_INPUT_TYPEHASH,
                    input.makerValue,
                    input.takerValue,
                    hashOrderPair(input.pair),
                    input.orderId,
                    input.ancestorOrderId,
                    input.updatedRatioWei
                )
            );
    }

    function hashOrderPair(DubiexLib.OrderPair memory pair)
        private
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    ORDER_PAIR_TYPEHASH,
                    pair.makerContractAddress,
                    pair.takerContractAddress,
                    pair.makerCurrencyType,
                    pair.takerCurrencyType
                )
            );
    }

    function hashTakeOrderInput(DubiexLib.TakeOrderInput memory input)
        private
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    TAKE_ORDER_INPUT_TYPEHASH,
                    input.id,
                    input.maker,
                    input.takerValue,
                    input.maxTakerMakerRatio
                )
            );
    }

    function hashCancelOrderInput(DubiexLib.CancelOrderInput memory input)
        private
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(CANCEL_ORDER_INPUT_TYPEHASH, input.id, input.maker)
            );
    }
}// MIT

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.6.0;

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
}// MIT

pragma solidity ^0.6.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.6.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}// MIT

pragma solidity ^0.6.0;


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}// MIT

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
}// MIT

pragma solidity ^0.6.0;

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;


    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}// MIT

pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity 0.6.12;


contract Dubiex is ReentrancyGuard, ERC721Holder, Boostable {

    using SafeERC20 for IERC20;

    bytes32 private constant _BOOSTABLE_ERC20_TOKEN_HASH = keccak256(
        "BoostableERC20Token"
    );

    bytes4 private constant _ERC721_INTERFACE_HASH = 0x80ac58cd;

    IERC1820Registry private constant _ERC1820_REGISTRY = IERC1820Registry(
        0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24
    );

    DubiexLib.PackedOrderBookItem private emptyOrder;

    address private immutable _prps;
    address private immutable _dubi;

    bool private _killSwitchOn;

    function activateKillSwitch() public {

        require(!_killSwitchOn, "Dubiex: kill switch already on");

        uint256 oneBillion = 1000000000 * 1 ether;

        uint256 totalPrpsSupply = IERC20(_prps).totalSupply();
        uint256 totalDubiSupply = IERC20(_dubi).totalSupply();

        require(
            totalPrpsSupply >= oneBillion || totalDubiSupply >= oneBillion,
            "Dubiex: insufficient total supply for kill switch"
        );
        _killSwitchOn = true;
    }

    constructor(
        address optIn,
        address prps,
        address dubi
    ) public ReentrancyGuard() Boostable(optIn) {
        _prps = prps;
        _dubi = dubi;
    }

    event MadeOrder(
        uint32 id,
        address maker,
        uint256 packedData
    );

    event TookOrder(
        uint32 id,
        address maker,
        address taker,
        uint256 packedData
    );
    event CanceledOrder(address maker, uint32 id);

    event UpdatedOrder(address maker, uint32 id);

    uint32 private _orderPairAliasCounter;

    mapping(uint32 => DubiexLib.PackedOrderPair) private _orderPairsByAlias;
    mapping(bytes32 => uint32) private _orderPairAliasesByHash;

    mapping(address => uint32) private _counters;

    mapping(address => DubiexLib.PackedOrderBookItem[])
        private _ordersByAddress;

    function getOrder(address maker, uint64 id)
        public
        view
        returns (DubiexLib.PrettyOrderBookItem memory)
    {


            DubiexLib.PackedOrderBookItem[] storage orders
         = _ordersByAddress[maker];
        for (uint256 i = 0; i < orders.length; i++) {
            DubiexLib.PackedOrderBookItem storage _packed = orders[i];
            DubiexLib.UnpackedOrderBookItem memory _unpacked = DubiexLib
                .unpackOrderBookItem(_packed.packedData);

            if (_unpacked.id == id) {
                DubiexLib.PrettyOrderBookItem memory pretty;
                pretty.id = _unpacked.id;
                pretty.makerValue = _unpacked.makerValue;
                pretty.takerValue = _unpacked.takerValue;

                pretty.orderPairAlias = _unpacked.orderPairAlias;
                pretty.pair = getOrderPairByAlias(_unpacked.orderPairAlias);

                pretty.flags = _unpacked.flags;

                pretty.successorOrderId = _packed.successorOrderId;
                pretty.ancestorOrderId = _packed.ancestorOrderId;

                return pretty;
            }
        }

        DubiexLib.PrettyOrderBookItem memory empty;
        return empty;
    }

    function getOrderPairByAlias(uint32 orderPairAlias)
        public
        view
        returns (DubiexLib.OrderPair memory)
    {

        DubiexLib.OrderPair memory orderPair;


            DubiexLib.PackedOrderPair storage packedOrderPair
         = _orderPairsByAlias[orderPairAlias];

        (
            address makerContractAddress,
            DubiexLib.CurrencyType makerCurrencyType
        ) = DubiexLib.unpackOrderPairAddressType(packedOrderPair.makerPair);

        (
            address takerContractAddress,
            DubiexLib.CurrencyType takerCurrencyType
        ) = DubiexLib.unpackOrderPairAddressType(packedOrderPair.takerPair);

        orderPair.makerContractAddress = makerContractAddress;
        orderPair.makerCurrencyType = makerCurrencyType;
        orderPair.takerContractAddress = takerContractAddress;
        orderPair.takerCurrencyType = takerCurrencyType;

        return orderPair;
    }

    function getOrderPairByHash(bytes32 orderPairHash)
        public
        view
        returns (DubiexLib.OrderPair memory)
    {

        uint32 orderPairAlias = _orderPairAliasesByHash[orderPairHash];
        return getOrderPairByAlias(orderPairAlias);
    }

    function getOrderPairAliasByHash(bytes32 orderPairHash)
        public
        view
        returns (uint32)
    {

        return _orderPairAliasesByHash[orderPairHash];
    }

    function makeOrder(DubiexLib.MakeOrderInput memory input)
        external
        payable
        nonReentrant
        returns (uint32)
    {

        require(!_killSwitchOn, "Dubiex: make order prevented by kill switch");

        uint256 excessEth = msg.value;
        uint32 orderId;

        (orderId, excessEth) = _makeOrderInternal({
            input: input,
            maker: msg.sender,
            excessEthAndIntrinsicFuel: excessEth,
            isBoosted: false,
            revertOnUpdateError: true
        });

        _refundExcessEth(excessEth);

        return orderId;
    }

    function makeOrders(DubiexLib.MakeOrderInput[] memory inputs)
        external
        payable
        nonReentrant
        returns (uint32[] memory)
    {

        require(!_killSwitchOn, "Dubiex: make order prevented by kill switch");
        require(inputs.length > 0, "Dubiex: empty inputs");

        uint32[] memory orderIds = new uint32[](inputs.length);

        uint256 excessEth = msg.value;

        for (uint256 i = 0; i < inputs.length; i++) {
            uint32 orderId;

            (orderId, excessEth) = _makeOrderInternal({
                input: inputs[i],
                maker: msg.sender,
                excessEthAndIntrinsicFuel: excessEth,
                isBoosted: false,
                revertOnUpdateError: false
            });

            orderIds[i] = orderId;
        }

        _refundExcessEth(excessEth);

        return orderIds;
    }

    function takeOrder(DubiexLib.TakeOrderInput calldata input)
        external
        payable
        nonReentrant
    {

        require(!_killSwitchOn, "Dubiex: take order prevented by kill switch");

        uint256 excessEth = msg.value;

        (, excessEth, ) = _takeOrderInternal({
            input: input,
            taker: msg.sender,
            excessEthAndIntrinsicFuel: excessEth,
            revertOnError: true,
            isBoosted: false
        });

        _refundExcessEth(excessEth);
    }

    function takeOrders(DubiexLib.TakeOrderInput[] calldata inputs)
        external
        payable
        nonReentrant
        returns (bool[] memory)
    {

        require(!_killSwitchOn, "Dubiex: take order prevented by kill switch");
        require(inputs.length > 0, "Dubiex: empty inputs");

        bool[] memory result = new bool[](inputs.length);

        uint256 excessEth = msg.value;

        for (uint256 i = 0; i < inputs.length; i++) {
            bool success;
            (success, excessEth, ) = _takeOrderInternal({
                input: inputs[i],
                taker: msg.sender,
                excessEthAndIntrinsicFuel: uint96(excessEth),
                revertOnError: false,
                isBoosted: false
            });

            result[i] = success;
        }

        _refundExcessEth(excessEth);

        return result;
    }

    function cancelOrder(DubiexLib.CancelOrderInput memory input)
        external
        nonReentrant
    {

        _cancelOrderInternal({
            maker: input.maker,
            id: input.id,
            intrinsicFuel: 0,
            isBoosted: false,
            revertOnError: true,
            isKillSwitchOn: _killSwitchOn
        });
    }

    function cancelOrders(DubiexLib.CancelOrderInput[] calldata inputs)
        external
        nonReentrant
        returns (bool[] memory)
    {

        require(inputs.length > 0, "Dubiex: empty inputs");

        bool[] memory result = new bool[](inputs.length);

        bool isKillSwitchOn = _killSwitchOn;

        for (uint256 i = 0; i < inputs.length; i++) {
            result[i] = _cancelOrderInternal({
                maker: inputs[i].maker,
                id: inputs[i].id,
                intrinsicFuel: 0,
                isBoosted: false,
                revertOnError: false,
                isKillSwitchOn: isKillSwitchOn
            });
        }

        return result;
    }

    function boostedMakeOrder(
        BoostedMakeOrder memory order,
        Signature memory signature
    ) public payable nonReentrant returns (uint32) {

        require(!_killSwitchOn, "Dubiex: make order prevented by kill switch");

        uint32 orderId;
        uint256 excessEth = msg.value;
        (orderId, excessEth) = _boostedMakeOrderInternal(
            order,
            signature,
            excessEth,
            true
        );

        _refundExcessEth(excessEth);
        return orderId;
    }

    function _boostedMakeOrderInternal(
        BoostedMakeOrder memory order,
        Signature memory signature,
        uint256 excessEth,
        bool revertOnUpdateError
    ) private returns (uint32, uint256) {

        uint96 intrinsicFuel = _burnFuel(order.maker, order.fuel);

        if (
            order.input.pair.makerCurrencyType == DubiexLib.CurrencyType.ERC721
        ) {
            _verifyBoostWithoutNonce(
                order.maker,
                hashBoostedMakeOrder(order, msg.sender),
                order.boosterPayload,
                signature
            );
        } else {
            verifyBoost(
                order.maker,
                hashBoostedMakeOrder(order, msg.sender),
                order.boosterPayload,
                signature
            );
        }

        uint32 orderId;

        uint256 excessEthAndIntrinsicFuel = excessEth;
        excessEthAndIntrinsicFuel |= uint256(intrinsicFuel) << 96;

        (orderId, excessEth) = _makeOrderInternal({
            maker: order.maker,
            input: order.input,
            excessEthAndIntrinsicFuel: excessEthAndIntrinsicFuel,
            isBoosted: true,
            revertOnUpdateError: revertOnUpdateError
        });

        return (orderId, excessEth);
    }

    function boostedTakeOrder(
        BoostedTakeOrder memory order,
        Signature memory signature
    ) public payable nonReentrant {

        require(!_killSwitchOn, "Dubiex: take order prevented by kill switch");

        uint256 excessEth = _boostedTakeOrderInternal({
            order: order,
            signature: signature,
            excessEth: msg.value,
            revertOnError: true
        });

        _refundExcessEth(excessEth);
    }

    function _boostedTakeOrderInternal(
        BoostedTakeOrder memory order,
        Signature memory signature,
        uint256 excessEth,
        bool revertOnError
    ) private returns (uint256) {

        uint96 intrinsicFuel = _burnFuel(order.taker, order.fuel);

        uint256 excessEthAndIntrinsicFuel = excessEth;
        excessEthAndIntrinsicFuel |= uint256(intrinsicFuel) << 96;

        DubiexLib.CurrencyType takerCurrencyType;
        (, excessEth, takerCurrencyType) = _takeOrderInternal({
            input: order.input,
            taker: order.taker,
            excessEthAndIntrinsicFuel: excessEthAndIntrinsicFuel,
            revertOnError: revertOnError,
            isBoosted: true
        });

        if (takerCurrencyType == DubiexLib.CurrencyType.ERC721) {
            _verifyBoostWithoutNonce(
                order.taker,
                hashBoostedTakeOrder(order, msg.sender),
                order.boosterPayload,
                signature
            );
        } else {
            verifyBoost(
                order.taker,
                hashBoostedTakeOrder(order, msg.sender),
                order.boosterPayload,
                signature
            );
        }

        return excessEth;
    }

    function boostedCancelOrder(
        BoostedCancelOrder memory order,
        Signature memory signature
    ) public payable nonReentrant {

        bool isKillSwitchOn = _killSwitchOn;
        _boostedCancelOrderInternal(order, signature, true, isKillSwitchOn);
    }

    function _boostedCancelOrderInternal(
        BoostedCancelOrder memory order,
        Signature memory signature,
        bool reverOnError,
        bool isKillSwitchOn
    ) private {

        uint96 intrinsicFuel = _burnFuel(order.input.maker, order.fuel);

        _verifyBoostWithoutNonce(
            order.input.maker,
            hashBoostedCancelOrder(order, msg.sender),
            order.boosterPayload,
            signature
        );

        uint256 excessEthAndIntrinsicFuel;
        excessEthAndIntrinsicFuel |= uint256(intrinsicFuel) << 96;

        _cancelOrderInternal({
            maker: order.input.maker,
            id: order.input.id,
            isBoosted: true,
            intrinsicFuel: excessEthAndIntrinsicFuel,
            revertOnError: reverOnError,
            isKillSwitchOn: isKillSwitchOn
        });
    }

    function boostedMakeOrderBatch(
        BoostedMakeOrder[] calldata orders,
        Signature[] calldata signatures
    ) external payable nonReentrant {

        require(!_killSwitchOn, "Dubiex: make order prevented by kill switch");
        require(
            orders.length > 0 && orders.length == signatures.length,
            "Dubiex: invalid input lengths"
        );

        uint256 excessEth = msg.value;

        for (uint256 i = 0; i < orders.length; i++) {
            (, excessEth) = _boostedMakeOrderInternal(
                orders[i],
                signatures[i],
                uint96(excessEth),
                false
            );
        }
    }

    function boostedTakeOrderBatch(
        BoostedTakeOrder[] memory boostedTakeOrders,
        Signature[] calldata signatures
    ) external payable nonReentrant {

        require(!_killSwitchOn, "Dubiex: take order prevented by kill switch");
        require(
            boostedTakeOrders.length > 0 &&
                boostedTakeOrders.length == signatures.length,
            "Dubiex: invalid input lengths"
        );

        uint256 excessEth = msg.value;
        for (uint256 i = 0; i < boostedTakeOrders.length; i++) {
            excessEth = _boostedTakeOrderInternal(
                boostedTakeOrders[i],
                signatures[i],
                uint96(excessEth),
                false
            );
        }

        _refundExcessEth(excessEth);
    }

    function boostedCancelOrderBatch(
        BoostedCancelOrder[] memory orders,
        Signature[] calldata signatures
    ) external payable nonReentrant returns (uint32) {

        require(
            orders.length > 0 && orders.length == signatures.length,
            "Dubiex: invalid input lengths"
        );

        bool isKillSwitchOn = _killSwitchOn;

        for (uint256 i = 0; i < orders.length; i++) {
            _boostedCancelOrderInternal(
                orders[i],
                signatures[i],
                false,
                isKillSwitchOn
            );
        }
    }

    function _makeOrderInternal(
        DubiexLib.MakeOrderInput memory input,
        address payable maker,
        uint256 excessEthAndIntrinsicFuel,
        bool isBoosted,
        bool revertOnUpdateError
    ) private returns (uint32, uint256) {

        require(
            maker != address(this) && maker != address(0),
            "Dubiex: unexpected maker"
        );

        if (input.orderId > 0) {
            return (
                _updateOrder(
                    maker,
                    input.orderId,
                    input.updatedRatioWei,
                    revertOnUpdateError
                ),
                uint96(excessEthAndIntrinsicFuel)
            );
        }

        require(input.makerValue > 0, "Dubiex: makerValue must be greater 0");
        require(input.takerValue > 0, "Dubiex: takerValue must be greater 0");

        uint32 orderPairAlias = _getOrCreateOrderPairAlias(input.pair);

        bool deposited;

        (deposited, excessEthAndIntrinsicFuel) = _transfer({
            from: maker,
            to: payable(address(this)),
            value: input.makerValue,
            valueContractAddress: input.pair.makerContractAddress,
            valueCurrencyType: input.pair.makerCurrencyType,
            excessEthAndIntrinsicFuel: excessEthAndIntrinsicFuel,
            isBoosted: isBoosted
        });

        require(deposited, "Dubiex: failed to deposit. not enough funds?");

        DubiexLib.PackedOrderBookItem memory _packed;

        DubiexLib.UnpackedOrderBookItem memory _unpacked;
        _unpacked.id = _getNextOrderId(maker);
        _unpacked.makerValue = input.makerValue;
        _unpacked.takerValue = input.takerValue;
        _unpacked.orderPairAlias = orderPairAlias;
        _unpacked.flags.isMakerERC721 =
            input.pair.makerCurrencyType == DubiexLib.CurrencyType.ERC721;
        _unpacked.flags.isTakerERC721 =
            input.pair.takerCurrencyType == DubiexLib.CurrencyType.ERC721;

        _updateOrderAncestorIfAny(input, maker, _unpacked, _packed);

        _packed.packedData = DubiexLib.packOrderBookItem(_unpacked);
        _ordersByAddress[maker].push(_packed);


        uint256 packedData;
        packedData |= input.makerValue;
        packedData |= uint256(input.takerValue) << 96;
        packedData |= uint256(orderPairAlias) << (96 + 96);

        emit MadeOrder(_unpacked.id, maker, packedData);

        return (_unpacked.id, excessEthAndIntrinsicFuel);
    }

    function _updateOrderAncestorIfAny(
        DubiexLib.MakeOrderInput memory input,
        address maker,
        DubiexLib.UnpackedOrderBookItem memory unpacked,
        DubiexLib.PackedOrderBookItem memory packed
    ) private {

        if (input.ancestorOrderId > 0) {
            packed.ancestorOrderId = input.ancestorOrderId;

            bool success = _setSuccessorOfAncestor(
                maker,
                input.ancestorOrderId,
                unpacked.id
            );

            unpacked.flags.isHidden = success;
        }
    }

    function _takeOrderInternal(
        address payable taker,
        DubiexLib.TakeOrderInput memory input,
        uint256 excessEthAndIntrinsicFuel,
        bool revertOnError,
        bool isBoosted
    )
        private
        returns (
            bool,
            uint256,
            DubiexLib.CurrencyType
        )
    {

        (
            DubiexLib.PackedOrderBookItem storage _packed,
            DubiexLib.UnpackedOrderBookItem memory _unpacked,
            uint256 index
        ) = _assertTakeOrderInput(input, revertOnError);

        if (_unpacked.id == 0) {
            return (
                false,
                uint96(excessEthAndIntrinsicFuel),
                DubiexLib.CurrencyType.NULL
            );
        }

        (uint96 _makerValue, uint96 _takerValue) = _calculateMakerAndTakerValue(
            _unpacked,
            input.takerValue,
            input.maxTakerMakerRatio
        );
        if (_makerValue == 0 || _takerValue == 0) {
            if (revertOnError) {
                revert("Dubiex: invalid takerValue");
            }

            return (
                false,
                uint96(excessEthAndIntrinsicFuel),
                DubiexLib.CurrencyType.NULL
            );
        }

        excessEthAndIntrinsicFuel = _transferFromTakerToMaker(
            taker,
            input.maker,
            _takerValue,
            _unpacked.pair,
            excessEthAndIntrinsicFuel,
            isBoosted
        );

        if (
            !_transferFromContractToTaker(
                taker,
                _makerValue,
                _unpacked.pair,
                false,
                0
            )
        ) {
            if (revertOnError) {
                revert("Dubiex: failed to transfer value to taker");
            }

            return (
                false,
                excessEthAndIntrinsicFuel,
                DubiexLib.CurrencyType.NULL
            );
        }

        if (_unpacked.makerValue - _makerValue == 0) {
            if (_unpacked.flags.hasSuccessor) {
                _setOrderVisible(input.maker, _packed.successorOrderId);
            }

            _deleteOrder({maker: input.maker, index: index});
        } else {
            _unpacked.makerValue -= _makerValue;
            _unpacked.takerValue -= _takerValue;

            _packed.packedData = DubiexLib.packOrderBookItem(_unpacked);
        }

        _unpacked.makerValue = _makerValue;
        _unpacked.takerValue = _takerValue;

        return
            _emitTookOrder(
                input.maker,
                taker,
                _unpacked,
                excessEthAndIntrinsicFuel
            );
    }

    function _emitTookOrder(
        address maker,
        address taker,
        DubiexLib.UnpackedOrderBookItem memory unpacked,
        uint256 excessEthAndIntrinsicFuel
    )
        private
        returns (
            bool,
            uint256,
            DubiexLib.CurrencyType
        )
    {

        uint256 packedData;
        packedData |= unpacked.makerValue;
        packedData |= uint256(unpacked.takerValue) << 96;
        packedData |= uint256(unpacked.orderPairAlias) << (96 + 96);

        emit TookOrder(unpacked.id, maker, taker, packedData);

        return (
            true,
            excessEthAndIntrinsicFuel,
            unpacked.pair.takerCurrencyType
        );
    }

    function _cancelOrderInternal(
        address payable maker,
        uint32 id,
        uint256 intrinsicFuel,
        bool isBoosted,
        bool revertOnError,
        bool isKillSwitchOn
    ) private returns (bool) {

        if (!isBoosted && !isKillSwitchOn) {
            require(maker == msg.sender, "Dubiex: msg.sender must be maker");
        }

        if (!revertOnError && !_orderExists(maker, id)) {
            return false;
        }

        (
            ,
            DubiexLib.UnpackedOrderBookItem memory unpacked,
            uint256 index
        ) = _safeGetOrder(maker, id, DubiexLib.OrderPairReadStrategy.MAKER);


        if (
            !_transferFromContractToTaker({
                taker: maker,
                makerValue: unpacked.makerValue,
                pair: unpacked.pair,
                isBoosted: isBoosted,
                excessEthAndIntrinsicFuel: intrinsicFuel
            })
        ) {
            return false;
        }

        _deleteOrder({maker: maker, index: index});

        emit CanceledOrder(maker, id);

        return true;
    }

    function _updateOrder(
        address maker,
        uint32 orderId,
        uint128 updatedRatioWei,
        bool revertOnUpdateError
    ) private returns (uint32) {

        (
            DubiexLib.PackedOrderBookItem storage _packed,
            DubiexLib.UnpackedOrderBookItem memory _unpacked,

        ) = _getOrder(maker, orderId, DubiexLib.OrderPairReadStrategy.SKIP);

        if (_unpacked.id == 0) {
            if (revertOnUpdateError) {
                revert("Dubiex: order does not exist");
            }

            return 0;
        }


        require(updatedRatioWei > 0, "Dubiex: ratio is 0");

        require(
            !_unpacked.flags.isMakerERC721 && !_unpacked.flags.isTakerERC721,
            "Dubiex: cannot update ERC721 value"
        );


        uint256 updatedTakerValue = (uint256(_unpacked.makerValue) *
            uint256(updatedRatioWei)) / 1 ether;

        require(updatedTakerValue < 2**96, "Dubiex: takerValue overflow");

        _unpacked.takerValue = uint96(updatedTakerValue);
        _packed.packedData = DubiexLib.packOrderBookItem(_unpacked);

        emit UpdatedOrder(maker, orderId);

        return orderId;
    }

    function _calculateMakerAndTakerValue(
        DubiexLib.UnpackedOrderBookItem memory _unpacked,
        uint96 takerValue,
        uint256 maxTakerMakerRatio
    ) private pure returns (uint96, uint96) {

        uint256 calculatedMakerValue = _unpacked.makerValue;
        uint256 calculatedTakerValue = takerValue;

        if (
            _unpacked.pair.makerCurrencyType == DubiexLib.CurrencyType.ERC721 ||
            _unpacked.pair.takerCurrencyType == DubiexLib.CurrencyType.ERC721
        ) {
            if (takerValue != _unpacked.takerValue) {
                return (0, 0);
            }

        } else {
            uint256 takerMakerRatio = (uint256(_unpacked.takerValue) *
                1 ether) / calculatedMakerValue;

            if (maxTakerMakerRatio < takerMakerRatio) {
                return (0, 0);
            }

            if (calculatedTakerValue > _unpacked.takerValue) {
                calculatedTakerValue = _unpacked.takerValue;
            }

            calculatedMakerValue *= 1 ether;
            calculatedMakerValue *= calculatedTakerValue;
            calculatedMakerValue /= _unpacked.takerValue;
            calculatedMakerValue /= 1 ether;
        }

        assert(
            calculatedMakerValue < 2**96 &&
                calculatedMakerValue <= _unpacked.makerValue
        );
        assert(
            calculatedTakerValue < 2**96 &&
                calculatedTakerValue <= _unpacked.takerValue
        );

        return (uint96(calculatedMakerValue), uint96(calculatedTakerValue));
    }

    function _assertTakeOrderInput(
        DubiexLib.TakeOrderInput memory input,
        bool revertOnError
    )
        private
        view
        returns (
            DubiexLib.PackedOrderBookItem storage,
            DubiexLib.UnpackedOrderBookItem memory,
            uint256 // index
        )
    {

        (
            DubiexLib.PackedOrderBookItem storage packed,
            DubiexLib.UnpackedOrderBookItem memory unpacked,
            uint256 index
        ) = _getOrder(
            input.maker,
            input.id,
            DubiexLib.OrderPairReadStrategy.FULL
        );

        bool validTakerValue = input.takerValue > 0;
        bool orderExistsAndNotHidden = unpacked.id > 0 &&
            !unpacked.flags.isHidden;
        if (revertOnError) {
            require(validTakerValue, "Dubiex: takerValue must be greater 0");

            require(orderExistsAndNotHidden, "Dubiex: order does not exist");
        } else {
            if (!validTakerValue || !orderExistsAndNotHidden) {
                DubiexLib.UnpackedOrderBookItem memory emptyUnpacked;
                return (emptyOrder, emptyUnpacked, 0);
            }
        }

        return (packed, unpacked, index);
    }

    function _orderExists(address maker, uint32 id)
        private
        view
        returns (bool)
    {



            DubiexLib.PackedOrderBookItem[] storage orders
         = _ordersByAddress[maker];

        uint256 length = orders.length;
        for (uint256 i = 0; i < length; i++) {
            uint32 orderId = uint32(orders[i].packedData);
            if (orderId == id) {
                return true;
            }
        }

        return false;
    }

    function _refundExcessEth(uint256 excessEth) private {

        excessEth = uint96(excessEth);

        assert(msg.value >= excessEth);

        if (excessEth > 0) {
            msg.sender.transfer(excessEth);
        }
    }

    function _transferFromTakerToMaker(
        address payable taker,
        address payable maker,
        uint96 takerValue,
        DubiexLib.OrderPair memory pair,
        uint256 excessEthAndIntrinsicFuel,
        bool isBoosted
    ) private returns (uint256) {

        (bool success, uint256 excessEth) = _transfer(
            taker,
            maker,
            takerValue,
            pair.takerContractAddress,
            pair.takerCurrencyType,
            excessEthAndIntrinsicFuel,
            isBoosted
        );

        require(success, "Dubiex: failed to transfer value to maker");

        return excessEth;
    }

    function _transferFromContractToTaker(
        address payable taker,
        uint96 makerValue,
        DubiexLib.OrderPair memory pair,
        bool isBoosted,
        uint256 excessEthAndIntrinsicFuel
    ) private returns (bool) {

        (bool success, ) = _transfer(
            payable(address(this)),
            taker,
            makerValue,
            pair.makerContractAddress,
            pair.makerCurrencyType,
            excessEthAndIntrinsicFuel,
            isBoosted
        );

        return success;
    }

    function _transfer(
        address payable from,
        address payable to,
        uint256 value,
        address valueContractAddress,
        DubiexLib.CurrencyType valueCurrencyType,
        uint256 excessEthAndIntrinsicFuel,
        bool isBoosted
    ) private returns (bool, uint256) {

        uint256 excessEth = uint96(excessEthAndIntrinsicFuel);
        if (valueCurrencyType == DubiexLib.CurrencyType.ETH) {
            if (from != address(this)) {
                if (excessEth < value) {
                    return (false, excessEth);
                }

                excessEth -= value;
            }

            if (to != address(this)) {
                to.transfer(value);
            }

            return (true, excessEth);
        }

        if (valueCurrencyType == DubiexLib.CurrencyType.ERC20) {
            IERC20 erc20 = IERC20(valueContractAddress);
            uint256 recipientBalanceBefore = erc20.balanceOf(to);

            if (from == address(this)) {
                erc20.safeTransfer(to, value);
            } else {
                erc20.safeTransferFrom(from, to, value);
            }

            uint256 recipientBalanceAfter = erc20.balanceOf(to);
            require(
                recipientBalanceAfter == recipientBalanceBefore + value,
                "Dubiex: failed to transfer ERC20 token"
            );

            return (true, excessEth);
        }

        if (valueCurrencyType == DubiexLib.CurrencyType.BOOSTABLE_ERC20) {
            IBoostableERC20 erc20 = IBoostableERC20(valueContractAddress);

            if (from == address(this)) {
                IERC20(address(erc20)).safeTransfer(to, value);
            } else {
                bool success = erc20.boostedTransferFrom(
                    from,
                    to,
                    value,
                    abi.encodePacked(isBoosted)
                );

                require(
                    success,
                    "Dubiex: failed to transfer boosted ERC20 token"
                );
            }

            return (true, excessEth);
        }

        if (valueCurrencyType == DubiexLib.CurrencyType.ERC721) {
            IERC721 erc721 = IERC721(valueContractAddress);

            erc721.safeTransferFrom(
                from,
                to,
                value,
                abi.encodePacked(
                    isBoosted,
                    uint96(excessEthAndIntrinsicFuel >> 96)
                )
            );

            require(
                erc721.ownerOf(value) == to,
                "Dubiex: failed to transfer ERC721 token"
            );

            return (true, excessEth);
        }

        revert("Dubiex: unexpected currency type");
    }

    function _validateCurrencyType(
        DubiexLib.CurrencyType currencyType,
        address contractAddress
    ) private returns (bool) {

        if (currencyType == DubiexLib.CurrencyType.ETH) {
            require(
                contractAddress == address(0),
                "Dubiex: expected zero address"
            );
            return true;
        }

        if (currencyType == DubiexLib.CurrencyType.ERC721) {
            require(
                IERC165(contractAddress).supportsInterface(
                    _ERC721_INTERFACE_HASH
                ),
                "Dubiex: not ERC721 compliant"
            );
            return true;
        }

        if (currencyType == DubiexLib.CurrencyType.BOOSTABLE_ERC20) {
            address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(
                contractAddress,
                _BOOSTABLE_ERC20_TOKEN_HASH
            );

            require(
                implementer != address(0),
                "Dubiex: not BoostableERC20 compliant"
            );
            return true;
        }

        if (currencyType == DubiexLib.CurrencyType.ERC20) {
            (bool success, bytes memory result) = contractAddress.call(
                abi.encodeWithSelector(0x01ffc9a7, _ERC721_INTERFACE_HASH)
            );

            bool isERC721 = false;
            if (result.length > 0) {
                isERC721 = abi.decode(result, (bool));
            }

            require(!success || !isERC721, "Dubiex: ERC20 implements ERC721");

            result = Address.functionCall(
                contractAddress,
                abi.encodeWithSelector(0x70a08231, contractAddress)
            );
            require(result.length > 0, "Dubiex: not ERC20 compliant");

            return true;
        }

        return false;
    }

    function _getNextOrderId(address account) private returns (uint32) {

        uint32 currentId = _counters[account];
        assert(currentId < 2**32);

        uint32 nextId = currentId + 1;
        _counters[account] = nextId;

        return nextId;
    }

    function _getOrCreateOrderPairAlias(DubiexLib.OrderPair memory pair)
        private
        returns (uint32)
    {

        bytes32 orderPairHash = keccak256(
            abi.encode(
                pair.makerContractAddress,
                pair.takerContractAddress,
                pair.makerCurrencyType,
                pair.takerCurrencyType
            )
        );

        uint32 orderPairAlias = _orderPairAliasesByHash[orderPairHash];
        if (orderPairAlias == 0) {
            require(
                _validateCurrencyType(
                    pair.makerCurrencyType,
                    pair.makerContractAddress
                ),
                "Dubiex: makerContractAddress and currencyType mismatch"
            );
            require(
                _validateCurrencyType(
                    pair.takerCurrencyType,
                    pair.takerContractAddress
                ),
                "Dubiex: takerContractAddress and currencyType mismatch"
            );

            uint32 orderPairAliasCounter = _orderPairAliasCounter;
            orderPairAliasCounter++;

            orderPairAlias = orderPairAliasCounter;

            _orderPairAliasCounter = orderPairAliasCounter;

            _orderPairAliasesByHash[orderPairHash] = orderPairAlias;
            _orderPairsByAlias[orderPairAlias] = DubiexLib.packOrderPair(pair);
        }

        return orderPairAlias;
    }

    function _safeGetOrderPairByAlias(
        uint32 orderPairAlias,
        DubiexLib.OrderPairReadStrategy strategy
    ) private view returns (DubiexLib.OrderPair memory) {

        DubiexLib.OrderPair memory _unpackedOrderPair;

        if (strategy == DubiexLib.OrderPairReadStrategy.SKIP) {
            return _unpackedOrderPair;
        }


            DubiexLib.PackedOrderPair storage _pairStorage
         = _orderPairsByAlias[orderPairAlias];

        if (
            strategy == DubiexLib.OrderPairReadStrategy.MAKER ||
            strategy == DubiexLib.OrderPairReadStrategy.FULL
        ) {
            (
                address makerContractAddress,
                DubiexLib.CurrencyType makerCurrencyType
            ) = DubiexLib.unpackOrderPairAddressType(_pairStorage.makerPair);
            _unpackedOrderPair.makerContractAddress = makerContractAddress;
            _unpackedOrderPair.makerCurrencyType = makerCurrencyType;

            require(
                _unpackedOrderPair.makerCurrencyType !=
                    DubiexLib.CurrencyType.NULL,
                "Dubiex: maker order pair not found"
            );
        }

        if (
            strategy == DubiexLib.OrderPairReadStrategy.TAKER ||
            strategy == DubiexLib.OrderPairReadStrategy.FULL
        ) {
            (
                address takerContractAddress,
                DubiexLib.CurrencyType takerCurrencyType
            ) = DubiexLib.unpackOrderPairAddressType(_pairStorage.takerPair);
            _unpackedOrderPair.takerContractAddress = takerContractAddress;
            _unpackedOrderPair.takerCurrencyType = takerCurrencyType;

            require(
                _unpackedOrderPair.takerCurrencyType !=
                    DubiexLib.CurrencyType.NULL,
                "Dubiex: taker order pair not found"
            );
        }

        return _unpackedOrderPair;
    }

    function _setSuccessorOfAncestor(
        address account,
        uint32 ancestorOrderId,
        uint32 successorOrderId
    ) private returns (bool) {


            DubiexLib.PackedOrderBookItem[] storage orders
         = _ordersByAddress[account];
        uint256 length = orders.length;
        for (uint256 i = 0; i < length; i++) {
            DubiexLib.PackedOrderBookItem storage _packed = orders[i];

            uint256 packedData = _packed.packedData;

            uint32 orderId = uint32(packedData);
            if (orderId == ancestorOrderId) {
                DubiexLib.UnpackedOrderBookItem memory _unpacked = DubiexLib
                    .unpackOrderBookItem(packedData);

                if (!_unpacked.flags.hasSuccessor) {
                    _unpacked.flags.hasSuccessor = true;
                    _packed.successorOrderId = successorOrderId;

                    _packed.packedData = DubiexLib.packOrderBookItem(_unpacked);

                    return true;
                }

                revert("Dubiex: ancestor order already has a successor");
            }
        }

        return false;
    }

    function _setOrderVisible(address account, uint32 successorOrderId)
        private
    {


            DubiexLib.PackedOrderBookItem[] storage orders
         = _ordersByAddress[account];

        uint256 length = orders.length;
        for (uint256 i = 0; i < length; i++) {
            DubiexLib.PackedOrderBookItem storage _packed = orders[i];

            uint256 packedData = _packed.packedData;

            uint32 orderId = uint32(packedData);
            if (orderId == successorOrderId) {
                DubiexLib.UnpackedOrderBookItem memory _unpacked = DubiexLib
                    .unpackOrderBookItem(packedData);
                _unpacked.flags.isHidden = false;

                _packed.packedData = DubiexLib.packOrderBookItem(_unpacked);

                break;
            }
        }
    }

    function _safeGetOrder(
        address account,
        uint32 id,
        DubiexLib.OrderPairReadStrategy strategy
    )
        private
        view
        returns (
            DubiexLib.PackedOrderBookItem storage,
            DubiexLib.UnpackedOrderBookItem memory,
            uint256
        )
    {


            DubiexLib.PackedOrderBookItem[] storage orders
         = _ordersByAddress[account];

        uint256 length = orders.length;
        for (uint256 i = 0; i < length; i++) {
            DubiexLib.PackedOrderBookItem storage _packed = orders[i];

            uint256 packedData = _packed.packedData;

            uint32 orderId = uint32(packedData);
            if (orderId == id) {
                DubiexLib.UnpackedOrderBookItem memory _unpacked = DubiexLib
                    .unpackOrderBookItem(packedData);

                _unpacked.pair = _safeGetOrderPairByAlias(
                    _unpacked.orderPairAlias,
                    strategy
                );

                return (_packed, _unpacked, i);
            }
        }

        revert("Dubiex: order does not exist");
    }

    function _getOrder(
        address account,
        uint32 id,
        DubiexLib.OrderPairReadStrategy strategy
    )
        private
        view
        returns (
            DubiexLib.PackedOrderBookItem storage,
            DubiexLib.UnpackedOrderBookItem memory,
            uint256
        )
    {


            DubiexLib.PackedOrderBookItem[] storage orders
         = _ordersByAddress[account];

        uint256 length = orders.length;
        for (uint256 i = 0; i < length; i++) {
            DubiexLib.PackedOrderBookItem storage _packed = orders[i];

            uint256 packedData = _packed.packedData;

            uint32 orderId = uint32(packedData);
            if (orderId == id) {
                DubiexLib.UnpackedOrderBookItem memory _unpacked = DubiexLib
                    .unpackOrderBookItem(packedData);

                _unpacked.pair = _safeGetOrderPairByAlias(
                    _unpacked.orderPairAlias,
                    strategy
                );

                return (_packed, _unpacked, i);
            }
        }

        DubiexLib.UnpackedOrderBookItem memory _unpacked;
        return (emptyOrder, _unpacked, 0);
    }

    function _deleteOrder(address maker, uint256 index) private {


            DubiexLib.PackedOrderBookItem[] storage orders
         = _ordersByAddress[maker];

        uint256 length = orders.length;
        if (index != length - 1) {
            orders[index] = orders[length - 1];
        }

        orders.pop();
    }


    function _burnFuel(address from, BoosterFuel memory fuel)
        internal
        returns (uint96)
    {

        if (fuel.unlockedPrps > 0) {
            IBoostableERC20(address(_prps)).burnFuel(
                from,
                TokenFuel({
                    tokenAlias: 0, /* UNLOCKED PRPS */
                    amount: fuel.unlockedPrps
                })
            );

            return 0;
        }

        if (fuel.lockedPrps > 0) {
            IBoostableERC20(address(_prps)).burnFuel(
                from,
                TokenFuel({
                    tokenAlias: 1, /* LOCKED PRPS */
                    amount: fuel.lockedPrps
                })
            );

            return 0;
        }

        if (fuel.dubi > 0) {
            IBoostableERC20(address(_dubi)).burnFuel(
                from,
                TokenFuel({
                    tokenAlias: 2, /* DUBI */
                    amount: fuel.dubi
                })
            );

            return 0;
        }

        if (fuel.intrinsicFuel > 0) {
            return fuel.intrinsicFuel;
        }

        return 0;
    }
}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.2;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.6.2;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

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
}// MIT

pragma solidity ^0.6.0;

library EnumerableMap {


    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    function baseURI() public view returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}// MIT

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT
pragma solidity 0.6.12;


contract DummyVanillaERC20 is ERC20, Ownable {
    string public constant NAME = "Dummy";
    string public constant SYMBOL = "DUMMY";

    constructor() public ERC20(NAME, SYMBOL) Ownable() {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}// MIT
pragma solidity 0.6.12;


contract DummyVanillaERC721 is ERC721 {
    string public constant NAME = "Vanilla ERC721";
    string public constant SYMBOL = "VANILLA-";

    constructor() public ERC721(NAME, SYMBOL) {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}