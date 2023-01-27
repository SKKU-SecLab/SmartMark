

pragma solidity 0.4.26;

library ArrayUtils {


    function guardedArrayReplace(bytes memory array, bytes memory desired, bytes memory mask)
    internal
    pure
    {

        require(array.length == desired.length);
        require(array.length == mask.length);

        uint words = array.length / 0x20;
        uint index = words * 0x20;
        assert(index / 0x20 == words);
        uint i;

        for (i = 0; i < words; i++) {
            assembly {
                let commonIndex := mul(0x20, add(1, i))
                let maskValue := mload(add(mask, commonIndex))
                mstore(add(array, commonIndex), or(and(not(maskValue), mload(add(array, commonIndex))), and(maskValue, mload(add(desired, commonIndex)))))
            }
        }

        if (words > 0) {
            i = words;
            assembly {
                let commonIndex := mul(0x20, add(1, i))
                let maskValue := mload(add(mask, commonIndex))
                mstore(add(array, commonIndex), or(and(not(maskValue), mload(add(array, commonIndex))), and(maskValue, mload(add(desired, commonIndex)))))
            }
        } else {
            for (i = index; i < array.length; i++) {
                array[i] = ((mask[i] ^ 0xff) & array[i]) | (mask[i] & desired[i]);
            }
        }
    }

    function arrayEq(bytes memory a, bytes memory b)
    internal
    pure
    returns (bool)
    {

        return keccak256(a) == keccak256(b);
    }

    function unsafeWriteBytes(uint index, bytes source)
    internal
    pure
    returns (uint)
    {

        if (source.length > 0) {
            assembly {
                let length := mload(source)
                let end := add(source, add(0x20, length))
                let arrIndex := add(source, 0x20)
                let tempIndex := index
                for { } eq(lt(arrIndex, end), 1) {
                    arrIndex := add(arrIndex, 0x20)
                    tempIndex := add(tempIndex, 0x20)
                } {
                    mstore(tempIndex, mload(arrIndex))
                }
                index := add(index, length)
            }
        }
        return index;
    }

    function unsafeWriteAddress(uint index, address source)
    internal
    pure
    returns (uint)
    {
        uint conv = uint(source) << 0x60;
        assembly {
            mstore(index, conv)
            index := add(index, 0x14)
        }
        return index;
    }

    function unsafeWriteAddressWord(uint index, address source)
    internal
    pure
    returns (uint)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x20)
        }
        return index;
    }

    function unsafeWriteUint(uint index, uint source)
    internal
    pure
    returns (uint)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x20)
        }
        return index;
    }

    function unsafeWriteUint8(uint index, uint8 source)
    internal
    pure
    returns (uint)
    {
        assembly {
            mstore8(index, source)
            index := add(index, 0x1)
        }
        return index;
    }

    function unsafeWriteUint8Word(uint index, uint8 source)
    internal
    pure
    returns (uint)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x20)
        }
        return index;
    }

    function unsafeWriteBytes32(uint index, bytes32 source)
    internal
    pure
    returns (uint)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x20)
        }
        return index;
    }
}


pragma solidity ^0.4.24;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address who) external view returns (uint256);


  function allowance(address owner, address spender)
    external view returns (uint256);


  function transfer(address to, uint256 value) external returns (bool);


  function approve(address spender, uint256 value)
    external returns (bool);


  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


pragma solidity ^0.4.24;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}


pragma solidity ^0.4.24;



library SafeERC20 {


  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {

    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {

    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {

    require((value == 0) || (token.allowance(address(this), spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {

    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {

    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}


pragma solidity 0.4.26;



contract TokenTransferProxy {

    using SafeERC20 for IERC20;

    bool public initialized = false;

    address public exchangeAddress;

    function initialize (address _exchangeAddress)
    public
    {
        require(!initialized);
        initialized = true;
        exchangeAddress = _exchangeAddress;
    }
    function transferFrom(address token, address from, address to, uint amount)
    public
    returns (bool)
    {

        require(msg.sender==exchangeAddress, "not authorized");
        IERC20(token).safeTransferFrom(from, to, amount);
        return true;
    }

}


pragma solidity 0.4.26;


interface IERC2981 {

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount);

}


pragma solidity 0.4.26;


interface IRoyaltyRegisterHub {

    function royaltyInfo(address _nftAddress, uint256 _salePrice)  external view returns (address receiver, uint256 royaltyAmount);

}


pragma solidity 0.4.26;

contract ReentrancyGuarded {


    bool reentrancyLock = false;

    modifier reentrancyGuard {

        if (reentrancyLock) {
            revert();
        }
        reentrancyLock = true;
        _;
        reentrancyLock = false;
    }

}


pragma solidity 0.4.26;

contract Ownable {

    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}


pragma solidity 0.4.26;

contract Governable {

    address public governor;
    address public pendingGovernor;

    event GovernanceTransferred(
        address indexed previousGovernor,
        address indexed newGovernor
    );
    event NewPendingGovernor(address indexed newPendingGovernor);


    constructor() public {
        governor = msg.sender;
    }

    modifier onlyGovernor() {

        require(msg.sender == governor);
        _;
    }

    function acceptGovernance() external {

        require(msg.sender == pendingGovernor, "acceptGovernance: Call must come from pendingGovernor.");
        address previousGovernor = governor;
        governor = msg.sender;
        pendingGovernor = address(0);

        emit GovernanceTransferred(previousGovernor, governor);
    }

    function setPendingGovernor(address pendingGovernor_) external {

        require(msg.sender == governor, "setPendingGovernor: Call must come from governor.");
        pendingGovernor = pendingGovernor_;

        emit NewPendingGovernor(pendingGovernor);
    }
}


pragma solidity 0.4.26;


library SaleKindInterface {


    enum Side { Buy, Sell }

    enum SaleKind { FixedPrice, DutchAuction }

    function validateParameters(SaleKind saleKind, uint expirationTime)
    pure
    internal
    returns (bool)
    {

        return (saleKind == SaleKind.FixedPrice || expirationTime > 0);
    }

    function canSettleOrder(uint listingTime, uint expirationTime)
    view
    internal
    returns (bool)
    {

        return (listingTime < now) && (expirationTime == 0 || now < expirationTime);
    }

    function calculateFinalPrice(Side side, SaleKind saleKind, uint basePrice, uint extra, uint listingTime, uint expirationTime)
    view
    internal
    returns (uint finalPrice)
    {

        if (saleKind == SaleKind.FixedPrice) {
            return basePrice;
        } else if (saleKind == SaleKind.DutchAuction) {
            uint diff = SafeMath.div(SafeMath.mul(extra, SafeMath.sub(now, listingTime)), SafeMath.sub(expirationTime, listingTime));
            if (side == Side.Sell) {
                return SafeMath.sub(basePrice, diff);
            } else {
                return SafeMath.add(basePrice, diff);
            }
        }
    }

}


pragma solidity 0.4.26;









contract ExchangeCore is ReentrancyGuarded, Ownable, Governable {

    string public constant name = "NiftyConnect Exchange Contract";
    string public constant version = "1.0";

    bytes32 private constant _EIP_712_DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
    bytes32 private constant _NAME_HASH = 0x97b3fae253daa304aa40063e4f71c3efec8d260848d7379fc623e35f84c73f47;
    bytes32 private constant _VERSION_HASH = 0xe6bbd6277e1bf288eed5e8d1780f9a50b239e86b153736bceebccf4ea79d90b3;
    bytes32 private constant _ORDER_TYPEHASH = 0xf446866267029076a71bb126e250b9480cd4ac2699baa745a582b10b361ec951;

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a; // bytes4(keccak256("royaltyInfo(uint256,uint256)"));
    bytes4 private constant _EIP_165_SUPPORT_INTERFACE = 0x01ffc9a7; // bytes4(keccak256("supportsInterface(bytes4)"));

    uint256 private constant _CHAIN_ID = 1;

    bytes32 public constant DOMAIN_SEPARATOR = 0x048b125515112cdaed03d1edbee453f1de399178750917e49ce82b75444d7a21;

    uint256 public constant MAXIMUM_EXCHANGE_RATE = 500; //5%

    TokenTransferProxy public tokenTransferProxy;

    mapping(bytes32 => bool) public cancelledOrFinalized;

    mapping(bytes32 => uint256) private _approvedOrdersByNonce;

    mapping(address => uint256) public nonces;

    uint public exchangeFeeRate = 0;

    uint public takerRelayerFeeShare = 1500;

    uint public makerRelayerFeeShare = 8000;

    uint public protocolFeeShare = 500;

    address public protocolFeeRecipient;

    uint public constant INVERSE_BASIS_POINT = 10000;

    address public merkleValidatorContract;

    address public royaltyRegisterHub;

    struct Order {
        address exchange;
        address maker;
        address taker;
        address makerRelayerFeeRecipient;
        address takerRelayerFeeRecipient;
        SaleKindInterface.Side side;
        SaleKindInterface.SaleKind saleKind;
        address nftAddress;
        uint tokenId;
        bytes calldata;
        bytes replacementPattern;
        address staticTarget;
        bytes staticExtradata;
        address paymentToken;
        uint basePrice;
        uint extra;
        uint listingTime;
        uint expirationTime;
        uint salt;
    }

    event OrderApprovedPartOne    (bytes32 indexed hash, address exchange, address indexed maker, address taker, address indexed makerRelayerFeeRecipient, SaleKindInterface.Side side, SaleKindInterface.SaleKind saleKind, address nftAddress, uint256 tokenId, bytes32 ipfsHash);
    event OrderApprovedPartTwo    (bytes32 indexed hash, bytes calldata, bytes replacementPattern, address staticTarget, bytes staticExtradata, address paymentToken, uint basePrice, uint extra, uint listingTime, uint expirationTime, uint salt);
    event OrderCancelled          (bytes32 indexed hash);
    event OrdersMatched           (bytes32 buyHash, bytes32 sellHash, address indexed maker, address indexed taker, address makerRelayerFeeRecipient, address takerRelayerFeeRecipient, uint price, bytes32 indexed metadata);
    event NonceIncremented        (address indexed maker, uint newNonce);

    constructor () public {
        require(keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)") == _EIP_712_DOMAIN_TYPEHASH);
        require(keccak256(bytes(name)) == _NAME_HASH);
        require(keccak256(bytes(version)) == _VERSION_HASH);
        require(keccak256("Order(address exchange,address maker,address taker,address makerRelayerFeeRecipient,address takerRelayerFeeRecipient,uint8 side,uint8 saleKind,address nftAddress,uint tokenId,bytes32 merkleRoot,bytes calldata,bytes replacementPattern,address staticTarget,bytes staticExtradata,address paymentToken,uint256 basePrice,uint256 extra,uint256 listingTime,uint256 expirationTime,uint256 salt,uint256 nonce)") == _ORDER_TYPEHASH);
        require(DOMAIN_SEPARATOR == _deriveDomainSeparator());
    }

    function _deriveDomainSeparator() private view returns (bytes32) {

        return keccak256(
            abi.encode(
            _EIP_712_DOMAIN_TYPEHASH, // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
            _NAME_HASH, // keccak256("NiftyConnect Exchange Contract")
            _VERSION_HASH, // keccak256(bytes("1.0"))
            _CHAIN_ID,
            address(this)
        )); // NOTE: this is fixed, need to use solidity 0.5+ or make external call to support!
    }

    function checkRoyalties(address _contract) internal returns (bool) {

        bool success;
        bytes memory data = abi.encodeWithSelector(_EIP_165_SUPPORT_INTERFACE, _INTERFACE_ID_ERC2981);
        bytes memory result = new bytes(32);
        assembly {
            success := call(
                gas,            // gas remaining
                _contract,      // destination address
                0,              // no ether
                add(data, 32),  // input buffer (starts after the first 32 bytes in the `data` array)
                mload(data),    // input length (loaded from the first 32 bytes in the `data` array)
                result,         // output buffer
                32              // output length
            )
        }
        if (!success) {
            return false;
        }
        bool supportERC2981;
        assembly {
            supportERC2981 := mload(result)
        }
        return supportERC2981;
    }

    function incrementNonce() external {

        uint newNonce = ++nonces[msg.sender];
        emit NonceIncremented(msg.sender, newNonce);
    }

    function changeExchangeFeeRate(uint newExchangeFeeRate)
    public
    onlyGovernor
    {

        require(newExchangeFeeRate<=MAXIMUM_EXCHANGE_RATE, "invalid exchange fee rate");
        exchangeFeeRate = newExchangeFeeRate;
    }

    function changeTakerRelayerFeeShare(uint newTakerRelayerFeeShare, uint newMakerRelayerFeeShare, uint newProtocolFeeShare)
    public
    onlyGovernor
    {

        require(SafeMath.add(SafeMath.add(newTakerRelayerFeeShare, newMakerRelayerFeeShare), newProtocolFeeShare) == INVERSE_BASIS_POINT, "invalid new fee share");
        takerRelayerFeeShare = newTakerRelayerFeeShare;
        makerRelayerFeeShare = newMakerRelayerFeeShare;
        protocolFeeShare = newProtocolFeeShare;
    }

    function changeProtocolFeeRecipient(address newProtocolFeeRecipient)
    public
    onlyOwner
    {

        protocolFeeRecipient = newProtocolFeeRecipient;
    }

    function transferTokens(address token, address from, address to, uint amount)
    internal
    {

        if (amount > 0) {
            require(tokenTransferProxy.transferFrom(token, from, to, amount));
        }
    }

    function staticCall(address target, bytes memory calldata, bytes memory extradata)
    public
    view
    returns (bool result)
    {

        bytes memory combined = new bytes(calldata.length + extradata.length);
        uint index;
        assembly {
            index := add(combined, 0x20)
        }
        index = ArrayUtils.unsafeWriteBytes(index, extradata);
        ArrayUtils.unsafeWriteBytes(index, calldata);
        assembly {
            result := staticcall(gas, target, add(combined, 0x20), mload(combined), mload(0x40), 0)
        }
        return result;
    }

    function hashOrder(Order memory order, uint nonce)
    internal
    pure
    returns (bytes32 hash)
    {

        uint size = 672;
        bytes memory array = new bytes(size);
        uint index;
        assembly {
            index := add(array, 0x20)
        }
        index = ArrayUtils.unsafeWriteBytes32(index, _ORDER_TYPEHASH);
        index = ArrayUtils.unsafeWriteAddressWord(index, order.exchange);
        index = ArrayUtils.unsafeWriteAddressWord(index, order.maker);
        index = ArrayUtils.unsafeWriteAddressWord(index, order.taker);
        index = ArrayUtils.unsafeWriteAddressWord(index, order.makerRelayerFeeRecipient);
        index = ArrayUtils.unsafeWriteAddressWord(index, order.takerRelayerFeeRecipient);
        index = ArrayUtils.unsafeWriteUint8Word(index, uint8(order.side));
        index = ArrayUtils.unsafeWriteUint8Word(index, uint8(order.saleKind));
        index = ArrayUtils.unsafeWriteAddressWord(index, order.nftAddress);
        index = ArrayUtils.unsafeWriteUint(index, order.tokenId);
        index = ArrayUtils.unsafeWriteBytes32(index, keccak256(order.calldata));
        index = ArrayUtils.unsafeWriteBytes32(index, keccak256(order.replacementPattern));
        index = ArrayUtils.unsafeWriteAddressWord(index, order.staticTarget);
        index = ArrayUtils.unsafeWriteBytes32(index, keccak256(order.staticExtradata));
        index = ArrayUtils.unsafeWriteAddressWord(index, order.paymentToken);
        index = ArrayUtils.unsafeWriteUint(index, order.basePrice);
        index = ArrayUtils.unsafeWriteUint(index, order.extra);
        index = ArrayUtils.unsafeWriteUint(index, order.listingTime);
        index = ArrayUtils.unsafeWriteUint(index, order.expirationTime);
        index = ArrayUtils.unsafeWriteUint(index, order.salt);
        index = ArrayUtils.unsafeWriteUint(index, nonce);
        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
        return hash;
    }

    function hashToSign(Order memory order, uint nonce)
    internal
    pure
    returns (bytes32)
    {

        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashOrder(order, nonce)));
    }

    function requireValidOrder(Order memory order, uint nonce)
    internal
    view
    returns (bytes32)
    {

        bytes32 hash = hashToSign(order, nonce);
        require(validateOrder(hash, order), "invalid order");
        return hash;
    }

    function validateOrderParameters(Order memory order)
    internal
    view
    returns (bool)
    {

        if (order.exchange != address(this)) {
            return false;
        }

        if (order.maker == address(0)) {
            return false;
        }

        if (!SaleKindInterface.validateParameters(order.saleKind, order.expirationTime)) {
            return false;
        }

        return true;
    }

    function validateOrder(bytes32 hash, Order memory order)
    internal
    view
    returns (bool)
    {


        if (!validateOrderParameters(order)) {
            return false;
        }

        if (cancelledOrFinalized[hash]) {
            return false;
        }

        uint approvedOrderNoncePlusOne = _approvedOrdersByNonce[hash];
        if (approvedOrderNoncePlusOne == 0) {
            return false;
        }
        return approvedOrderNoncePlusOne == nonces[order.maker] + 1;
    }

    function approvedOrders(bytes32 hash) public view returns (bool approved) {

        return _approvedOrdersByNonce[hash] != 0;
    }

    function makeOrder(Order memory order, bytes32 ipfsHash)
    internal
    {


        require(msg.sender == order.maker);

        bytes32 hash = hashToSign(order, nonces[order.maker]);

        require(_approvedOrdersByNonce[hash] == 0, "duplicated order hash");


        _approvedOrdersByNonce[hash] = nonces[order.maker] + 1;

        {
            emit OrderApprovedPartOne(hash, order.exchange, order.maker, order.taker, order.makerRelayerFeeRecipient, order.side, order.saleKind, order.nftAddress, order.tokenId, ipfsHash);
        }
        {
            emit OrderApprovedPartTwo(hash, order.calldata, order.replacementPattern, order.staticTarget, order.staticExtradata, order.paymentToken, order.basePrice, order.extra, order.listingTime, order.expirationTime, order.salt);
        }
    }

    function cancelOrder(Order memory order, uint nonce)
    internal
    {


        bytes32 hash = requireValidOrder(order, nonce);

        require(msg.sender == order.maker);


        cancelledOrFinalized[hash] = true;

        emit OrderCancelled(hash);
    }

    function calculateCurrentPrice (Order memory order)
    internal
    view
    returns (uint)
    {
        return SaleKindInterface.calculateFinalPrice(order.side, order.saleKind, order.basePrice, order.extra, order.listingTime, order.expirationTime);
    }

    function calculateMatchPrice(Order memory buy, Order memory sell)
    view
    internal
    returns (uint)
    {

        uint sellPrice = SaleKindInterface.calculateFinalPrice(sell.side, sell.saleKind, sell.basePrice, sell.extra, sell.listingTime, sell.expirationTime);

        uint buyPrice = SaleKindInterface.calculateFinalPrice(buy.side, buy.saleKind, buy.basePrice, buy.extra, buy.listingTime, buy.expirationTime);

        require(buyPrice >= sellPrice);

        return sell.makerRelayerFeeRecipient != address(0) ? sellPrice : buyPrice;
    }

    function executeFundsTransfer(Order memory buy, Order memory sell)
    internal
    returns (uint)
    {

        if (sell.paymentToken != address(0)) {
            require(msg.value == 0);
        }

        uint price = calculateMatchPrice(buy, sell);

        if (price > 0 && sell.paymentToken != address(0)) {
            transferTokens(sell.paymentToken, buy.maker, sell.maker, price);
        }

        uint receiveAmount = price;

        uint requiredAmount = price;

        uint exchangeFee = SafeMath.div(SafeMath.mul(exchangeFeeRate, price), INVERSE_BASIS_POINT);

        address royaltyReceiver = address(0x00);
        uint256 royaltyAmount;
        if (checkRoyalties(sell.nftAddress)) {
            (royaltyReceiver, royaltyAmount) = IERC2981(sell.nftAddress).royaltyInfo(buy.tokenId, price);
        } else {
            (royaltyReceiver, royaltyAmount) = IRoyaltyRegisterHub(royaltyRegisterHub).royaltyInfo(sell.nftAddress, price);
        }

        if (royaltyReceiver != address(0x00) && royaltyAmount != 0) {
            if (sell.paymentToken == address(0)) {
                receiveAmount = SafeMath.sub(receiveAmount, royaltyAmount);
                royaltyReceiver.transfer(royaltyAmount);
            } else {
                transferTokens(sell.paymentToken, sell.maker, royaltyReceiver, royaltyAmount);
            }
        }

        if (sell.makerRelayerFeeRecipient != address(0) && exchangeFee != 0) {


            uint makerRelayerFee = SafeMath.div(SafeMath.mul(makerRelayerFeeShare, exchangeFee), INVERSE_BASIS_POINT);
            if (sell.paymentToken == address(0)) {
                receiveAmount = SafeMath.sub(receiveAmount, makerRelayerFee);
                sell.makerRelayerFeeRecipient.transfer(makerRelayerFee);
            } else {
                transferTokens(sell.paymentToken, sell.maker, sell.makerRelayerFeeRecipient, makerRelayerFee);
            }

            if (buy.takerRelayerFeeRecipient != address(0)) {
                uint takerRelayerFee = SafeMath.div(SafeMath.mul(takerRelayerFeeShare, exchangeFee), INVERSE_BASIS_POINT);
                if (sell.paymentToken == address(0)) {
                    receiveAmount = SafeMath.sub(receiveAmount, takerRelayerFee);
                    buy.takerRelayerFeeRecipient.transfer(takerRelayerFee);
                } else {
                    transferTokens(sell.paymentToken, sell.maker, buy.takerRelayerFeeRecipient, takerRelayerFee);
                }
            }

            uint protocolFee = SafeMath.div(SafeMath.mul(protocolFeeShare, exchangeFee), INVERSE_BASIS_POINT);
            if (sell.paymentToken == address(0)) {
                receiveAmount = SafeMath.sub(receiveAmount, protocolFee);
                protocolFeeRecipient.transfer(protocolFee);
            } else {
                transferTokens(sell.paymentToken, sell.maker, protocolFeeRecipient, protocolFee);
            }
        } else if (sell.makerRelayerFeeRecipient == address(0)){

            require(sell.paymentToken != address(0));

            if (exchangeFee != 0) {
                makerRelayerFee = SafeMath.div(SafeMath.mul(makerRelayerFeeShare, exchangeFee), INVERSE_BASIS_POINT);
                transferTokens(sell.paymentToken, sell.maker, buy.makerRelayerFeeRecipient, makerRelayerFee);

                if (sell.takerRelayerFeeRecipient != address(0)) {
                    takerRelayerFee = SafeMath.div(SafeMath.mul(takerRelayerFeeShare, exchangeFee), INVERSE_BASIS_POINT);
                    transferTokens(sell.paymentToken, sell.maker, sell.takerRelayerFeeRecipient, takerRelayerFee);
                }

                protocolFee = SafeMath.div(SafeMath.mul(protocolFeeShare, exchangeFee), INVERSE_BASIS_POINT);
                transferTokens(sell.paymentToken, sell.maker, protocolFeeRecipient, protocolFee);
            }
        }

        if (sell.paymentToken == address(0)) {
            require(msg.value >= requiredAmount);
            sell.maker.transfer(receiveAmount);
            uint diff = SafeMath.sub(msg.value, requiredAmount);
            if (diff > 0) {
                buy.maker.transfer(diff);
            }
        }


        return price;
    }

    function ordersCanMatch(Order memory buy, Order memory sell)
    internal
    view
    returns (bool)
    {

        return (
        (buy.side == SaleKindInterface.Side.Buy && sell.side == SaleKindInterface.Side.Sell) &&
        (buy.paymentToken == sell.paymentToken) &&
        (sell.taker == address(0) || sell.taker == buy.maker) &&
        (buy.taker == address(0) || buy.taker == sell.maker) &&
        ((sell.makerRelayerFeeRecipient == address(0) && buy.makerRelayerFeeRecipient != address(0)) || (sell.makerRelayerFeeRecipient != address(0) && buy.makerRelayerFeeRecipient == address(0))) &&
        (buy.nftAddress == sell.nftAddress) &&
        SaleKindInterface.canSettleOrder(buy.listingTime, buy.expirationTime) &&
        SaleKindInterface.canSettleOrder(sell.listingTime, sell.expirationTime)
        );
    }

    function takeOrder(Order memory buy, Order memory sell, bytes32 metadata)
    internal
    reentrancyGuard
    {


        bytes32 buyHash;
        if (buy.maker == msg.sender) {
            require(validateOrderParameters(buy), "invalid buy params");
        } else {
            buyHash = _requireValidOrderWithNonce(buy);
        }

        bytes32 sellHash;
        if (sell.maker == msg.sender) {
            require(validateOrderParameters(sell), "invalid sell params");
        } else {
            sellHash = _requireValidOrderWithNonce(sell);
        }

        require(ordersCanMatch(buy, sell), "order can't match");

        if (buy.replacementPattern.length > 0) {
            ArrayUtils.guardedArrayReplace(buy.calldata, sell.calldata, buy.replacementPattern);
        }
        if (sell.replacementPattern.length > 0) {
            ArrayUtils.guardedArrayReplace(sell.calldata, buy.calldata, sell.replacementPattern);
        }
        require(ArrayUtils.arrayEq(buy.calldata, sell.calldata), "calldata doesn't equal");


        if (msg.sender != buy.maker) {
            cancelledOrFinalized[buyHash] = true;
        }
        if (msg.sender != sell.maker) {
            cancelledOrFinalized[sellHash] = true;
        }


        uint price = executeFundsTransfer(buy, sell);

        require(merkleValidatorContract.delegatecall(sell.calldata), "order calldata failure");


        if (buy.staticTarget != address(0)) {
            require(staticCall(buy.staticTarget, sell.calldata, buy.staticExtradata));
        }

        if (sell.staticTarget != address(0)) {
            require(staticCall(sell.staticTarget, sell.calldata, sell.staticExtradata));
        }

        emit OrdersMatched(
            buyHash, sellHash,
            sell.makerRelayerFeeRecipient != address(0) ? sell.maker : buy.maker,
            sell.makerRelayerFeeRecipient != address(0) ? buy.maker : sell.maker,
            sell.makerRelayerFeeRecipient != address(0) ? sell.makerRelayerFeeRecipient : buy.makerRelayerFeeRecipient,
            sell.makerRelayerFeeRecipient != address(0) ? buy.takerRelayerFeeRecipient : sell.takerRelayerFeeRecipient,
            price, metadata);
    }

    function _requireValidOrderWithNonce(Order memory order) internal view returns (bytes32) {

        return requireValidOrder(order, nonces[order.maker]);
    }
}


pragma solidity 0.4.26;




contract NiftyConnectExchange is ExchangeCore {


    enum MerkleValidatorSelector {
        MatchERC721UsingCriteria,
        MatchERC721WithSafeTransferUsingCriteria,
        MatchERC1155UsingCriteria
    }

    constructor (
        TokenTransferProxy tokenTransferProxyAddress,
        address protocolFeeAddress,
        address merkleValidatorAddress,
        address royaltyRegisterHubAddress)
    public {
        tokenTransferProxy = tokenTransferProxyAddress;
        protocolFeeRecipient = protocolFeeAddress;
        merkleValidatorContract = merkleValidatorAddress;
        royaltyRegisterHub = royaltyRegisterHubAddress;
    }

    function buildCallData(
        uint selector,
        address from,
        address to,
        address nftAddress,
        uint256 tokenId,
        uint256 amount,
        bytes32 merkleRoot,
        bytes32[] memory merkleProof)
    public view returns(bytes) {

        MerkleValidatorSelector merkleValidatorSelector = MerkleValidatorSelector(selector);
        if (merkleValidatorSelector == MerkleValidatorSelector.MatchERC721UsingCriteria) {
            return abi.encodeWithSignature("matchERC721UsingCriteria(address,address,address,uint256,bytes32,bytes32[])", from, to, nftAddress, tokenId, merkleRoot, merkleProof);
        } else if (merkleValidatorSelector == MerkleValidatorSelector.MatchERC721WithSafeTransferUsingCriteria) {
            return abi.encodeWithSignature("matchERC721WithSafeTransferUsingCriteria(address,address,address,uint256,bytes32,bytes32[])", from, to, nftAddress, tokenId, merkleRoot, merkleProof);
        } else if (merkleValidatorSelector == MerkleValidatorSelector.MatchERC1155UsingCriteria) {
            return abi.encodeWithSignature("matchERC1155UsingCriteria(address,address,address,uint256,uint256,bytes32,bytes32[])", from, to, nftAddress, tokenId, amount, merkleRoot, merkleProof);
        } else {
            return new bytes(0);
        }
    }

    function buildCallDataInternal(
        address from,
        address to,
        address nftAddress,
        uint[9] uints,
        bytes32 merkleRoot)
    internal view returns(bytes) {

        bytes32[] memory merkleProof;
        if (uints[8]==0) {
            require(merkleRoot==bytes32(0x00), "invalid merkleRoot");
            return buildCallData(uints[5],from,to,nftAddress,uints[6],uints[7],merkleRoot,merkleProof);
        }
        require(uints[8]>=2&&merkleRoot!=bytes32(0x00), "invalid merkle data");
        uint256 merkleProofLength;
        uint256 divResult = uints[8];
        bool hasMod = false;
        for(;divResult!=0;) {
            uint256 tempDivResult = divResult/2;
            if (SafeMath.mul(tempDivResult, 2)<divResult) {
                hasMod = true;
            }
            divResult=tempDivResult;
            merkleProofLength++;
        }
        if (!hasMod) {
            merkleProofLength--;
        }
        merkleProof = new bytes32[](merkleProofLength);
        return buildCallData(uints[5],from,to,nftAddress,uints[6],uints[7],merkleRoot,merkleProof);
    }

    function guardedArrayReplace(bytes array, bytes desired, bytes mask)
    public
    pure
    returns (bytes)
    {

        ArrayUtils.guardedArrayReplace(array, desired, mask);
        return array;
    }

    function calculateFinalPrice(SaleKindInterface.Side side, SaleKindInterface.SaleKind saleKind, uint basePrice, uint extra, uint listingTime, uint expirationTime)
    public
    view
    returns (uint)
    {

        return SaleKindInterface.calculateFinalPrice(side, saleKind, basePrice, extra, listingTime, expirationTime);
    }

    function hashToSign_(
        address[9] addrs,
        uint[9] uints,
        SaleKindInterface.Side side,
        SaleKindInterface.SaleKind saleKind,
        bytes replacementPattern,
        bytes staticExtradata,
        bytes32 merkleRoot)
    public
    view
    returns (bytes32)
    {

        bytes memory orderCallData = buildCallDataInternal(addrs[7],addrs[8],addrs[4],uints,merkleRoot);
        return hashToSign(
            Order(addrs[0], addrs[1], addrs[2], addrs[3], address(0x00), side, saleKind, addrs[4], uints[6], orderCallData, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[0], uints[1], uints[2], uints[3], uints[4]),
            nonces[addrs[1]]
        );
    }

    function validateOrderParameters_ (
        address[9] addrs,
        uint[9] uints,
        SaleKindInterface.Side side,
        SaleKindInterface.SaleKind saleKind,
        bytes replacementPattern,
        bytes staticExtradata,
        bytes32 merkleRoot)
    view
    public
    returns (bool) {
        bytes memory orderCallData = buildCallDataInternal(addrs[7],addrs[8],addrs[4],uints,merkleRoot);
        Order memory order = Order(addrs[0], addrs[1], addrs[2], addrs[3], address(0x00), side, saleKind, addrs[4], uints[6], orderCallData, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[0], uints[1], uints[2], uints[3], uints[4]);
        return validateOrderParameters(
            order
        );
    }

    function validateOrder_ (
        address[9] addrs,
        uint[9] uints,
        SaleKindInterface.Side side,
        SaleKindInterface.SaleKind saleKind,
        bytes replacementPattern,
        bytes staticExtradata,
        bytes32 merkleRoot)
    view
    public
    returns (bool)
    {
        bytes memory orderCallData = buildCallDataInternal(addrs[7],addrs[8],addrs[4],uints,merkleRoot);
        Order memory order = Order(addrs[0], addrs[1], addrs[2], addrs[3], address(0x00), side, saleKind, addrs[4], uints[6], orderCallData, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[0], uints[1], uints[2], uints[3], uints[4]);
        return validateOrder(
            hashToSign(order, nonces[order.maker]),
            order
        );
    }

    function makeOrder_ (
        address[9] addrs,
        uint[9] uints,
        SaleKindInterface.Side side,
        SaleKindInterface.SaleKind saleKind,
        bytes replacementPattern,
        bytes staticExtradata,
        bytes32[2] merkleData)
    public
    {
        bytes memory orderCallData = buildCallDataInternal(addrs[7],addrs[8],addrs[4],uints,merkleData[0]);
        require(addrs[3]!=address(0x00), "makerRelayerFeeRecipient must not be zero");
        require(orderCallData.length==replacementPattern.length, "replacement pattern length mismatch");
        Order memory order = Order(addrs[0], addrs[1], addrs[2], addrs[3], address(0x00), side, saleKind, addrs[4], uints[6], orderCallData, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[0], uints[1], uints[2], uints[3], uints[4]);
        return makeOrder(order, merkleData[1]);
    }

    function cancelOrder_(
        address[9] addrs,
        uint[9] uints,
        SaleKindInterface.Side side,
        SaleKindInterface.SaleKind saleKind,
        bytes replacementPattern,
        bytes staticExtradata,
        bytes32 merkleRoot)
    public
    {

        bytes memory orderCallData = buildCallDataInternal(addrs[7],addrs[8],addrs[4],uints,merkleRoot);
        Order memory order = Order(addrs[0], addrs[1], addrs[2], addrs[3], address(0x00), side, saleKind, addrs[4], uints[6], orderCallData, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[0], uints[1], uints[2], uints[3], uints[4]);
        return cancelOrder(
            order,
            nonces[order.maker]
        );
    }

    function calculateCurrentPrice_(
        address[9] addrs,
        uint[9] uints,
        SaleKindInterface.Side side,
        SaleKindInterface.SaleKind saleKind,
        bytes replacementPattern,
        bytes staticExtradata,
        bytes32 merkleRoot)
    public
    view
    returns (uint)
    {

        bytes memory orderCallData = buildCallDataInternal(addrs[7],addrs[8],addrs[4],uints,merkleRoot);
        return calculateCurrentPrice(
            Order(addrs[0], addrs[1], addrs[2], addrs[3], address(0x00), side, saleKind, addrs[4], uints[6], orderCallData, replacementPattern, addrs[5], staticExtradata, IERC20(addrs[6]), uints[0], uints[1], uints[2], uints[3], uints[4])
        );
    }

    function ordersCanMatch_(
        address[16] addrs,
        uint[12] uints,
        uint8[4] sidesKinds,
        bytes calldataBuy,
        bytes calldataSell,
        bytes replacementPatternBuy,
        bytes replacementPatternSell,
        bytes staticExtradataBuy,
        bytes staticExtradataSell)
    public
    view
    returns (bool)
    {

        Order memory buy = Order(addrs[0], addrs[1], addrs[2], addrs[3], addrs[4], SaleKindInterface.Side(sidesKinds[0]), SaleKindInterface.SaleKind(sidesKinds[1]), addrs[5], uints[5], calldataBuy, replacementPatternBuy, addrs[6], staticExtradataBuy, IERC20(addrs[7]), uints[0], uints[1], uints[2], uints[3], uints[4]);
        Order memory sell = Order(addrs[8], addrs[9], addrs[10], addrs[11], addrs[12], SaleKindInterface.Side(sidesKinds[2]), SaleKindInterface.SaleKind(sidesKinds[3]), addrs[13], uints[11], calldataSell, replacementPatternSell, addrs[14], staticExtradataSell, IERC20(addrs[15]), uints[6], uints[7], uints[8], uints[9], uints[10]);
        return ordersCanMatch(
            buy,
            sell
        );
    }

    function orderCalldataCanMatch(bytes buyCalldata, bytes buyReplacementPattern, bytes sellCalldata, bytes sellReplacementPattern)
    public
    pure
    returns (bool)
    {

        if (buyReplacementPattern.length > 0) {
            ArrayUtils.guardedArrayReplace(buyCalldata, sellCalldata, buyReplacementPattern);
        }
        if (sellReplacementPattern.length > 0) {
            ArrayUtils.guardedArrayReplace(sellCalldata, buyCalldata, sellReplacementPattern);
        }
        return ArrayUtils.arrayEq(buyCalldata, sellCalldata);
    }

    function calculateMatchPrice_(
        address[16] addrs,
        uint[12] uints,
        uint8[4] sidesKinds,
        bytes calldataBuy,
        bytes calldataSell,
        bytes replacementPatternBuy,
        bytes replacementPatternSell,
        bytes staticExtradataBuy,
        bytes staticExtradataSell)
    public
    view
    returns (uint)
    {

        Order memory buy = Order(addrs[0], addrs[1], addrs[2], addrs[3], addrs[4], SaleKindInterface.Side(sidesKinds[0]), SaleKindInterface.SaleKind(sidesKinds[1]), addrs[5], uints[5], calldataBuy, replacementPatternBuy, addrs[6], staticExtradataBuy, IERC20(addrs[7]), uints[0], uints[1], uints[2], uints[3], uints[4]);
        Order memory sell = Order(addrs[8], addrs[9], addrs[10], addrs[11], addrs[12], SaleKindInterface.Side(sidesKinds[2]), SaleKindInterface.SaleKind(sidesKinds[3]), addrs[13], uints[11], calldataSell, replacementPatternSell, addrs[14], staticExtradataSell, IERC20(addrs[15]), uints[6], uints[7], uints[8], uints[9], uints[10]);
        return calculateMatchPrice(
            buy,
            sell
        );
    }

    function takeOrder_(
        address[16] addrs,
        uint[12] uints,
        uint8[4] sidesKinds,
        bytes calldataBuy,
        bytes calldataSell,
        bytes replacementPatternBuy,
        bytes replacementPatternSell,
        bytes staticExtradataBuy,
        bytes staticExtradataSell,
        bytes32 rssMetadata)
    public
    payable
    {


        return takeOrder(
            Order(addrs[0], addrs[1], addrs[2], addrs[3], addrs[4], SaleKindInterface.Side(sidesKinds[0]), SaleKindInterface.SaleKind(sidesKinds[1]), addrs[5], uints[5], calldataBuy, replacementPatternBuy, addrs[6], staticExtradataBuy, IERC20(addrs[7]), uints[0], uints[1], uints[2], uints[3], uints[4]),
            Order(addrs[8], addrs[9], addrs[10], addrs[11], addrs[12], SaleKindInterface.Side(sidesKinds[2]), SaleKindInterface.SaleKind(sidesKinds[3]), addrs[13], uints[11], calldataSell, replacementPatternSell, addrs[14], staticExtradataSell, IERC20(addrs[15]), uints[6], uints[7], uints[8], uints[9], uints[10]),
            rssMetadata
        );
    }

}