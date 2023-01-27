
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT
pragma solidity ^0.8.0;

interface ITransferProxy {

    function erc721SafeTransferFrom(
        address token,
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function erc1155SafeTransferFrom(
        address token,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external;

}// MIT
pragma solidity ^0.8.0;

abstract contract MessageSigning {
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function recoverMessageSignature(
        bytes32 message,
        Signature memory signature
    ) public pure returns (address) {
        uint8 v = signature.v;
        if (v < 27) {
            v += 27;
        }

        return
            ecrecover(
                keccak256(
                    abi.encodePacked(
                        '\x19Ethereum Signed Message:\n32',
                        message
                    )
                ),
                v,
                signature.r,
                signature.s
            );
    }
}// MIT
pragma solidity ^0.8.0;


interface IERC2981Royalties is IERC165Upgradeable {

    function royaltyInfo(uint256 tokenId, uint256 value)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}// MIT
pragma solidity ^0.8.0;



contract BaseExchange is OwnableUpgradeable, MessageSigning {

    address payable public beneficiary;
    ITransferProxy public transferProxy;

    struct OrderTransfers {
        uint256 total;
        uint256 sellerEndValue;
        uint256 totalTransaction;
        uint256 serviceFees;
        uint256 royaltiesAmount;
        address royaltiesRecipient;
    }

    function __BaseExchange_init(
        address payable _beneficiary,
        address _transferProxy
    ) internal initializer {

        __Ownable_init();

        setBeneficiary(_beneficiary);
        setTransferProxy(_transferProxy);
    }

    function setTransferProxy(address transferProxy_) public virtual onlyOwner {

        require(transferProxy_ != address(0));
        transferProxy = ITransferProxy(transferProxy_);
    }

    function setBeneficiary(address payable beneficiary_)
        public
        virtual
        onlyOwner
    {

        require(beneficiary_ != address(0));
        beneficiary = beneficiary_;
    }

    function _computeValues(
        uint256 unitPrice,
        address token,
        uint256 tokenId,
        uint256 amount,
        uint256 buyerServiceFee,
        uint256 sellerServiceFee
    ) internal view returns (OrderTransfers memory orderTransfers) {

        orderTransfers.total = unitPrice * amount;
        uint256 buyerFee = (orderTransfers.total * buyerServiceFee) / 10000;
        uint256 sellerFee = (orderTransfers.total * sellerServiceFee) / 10000;

        orderTransfers.totalTransaction = orderTransfers.total + buyerFee;
        orderTransfers.sellerEndValue = orderTransfers.total - sellerFee;
        orderTransfers.serviceFees = sellerFee + buyerFee;

        (address royaltiesRecipient, uint256 royaltiesAmount) = _getRoyalties(
            token,
            tokenId,
            orderTransfers.total
        );

        if (
            royaltiesAmount > 0 &&
            royaltiesAmount <= orderTransfers.sellerEndValue
        ) {
            orderTransfers.royaltiesRecipient = royaltiesRecipient;
            orderTransfers.royaltiesAmount = royaltiesAmount;
            orderTransfers.sellerEndValue =
                orderTransfers.sellerEndValue -
                royaltiesAmount;
        }
    }

    function _getRoyalties(
        address token,
        uint256 tokenId,
        uint256 saleValue
    )
        internal
        view
        virtual
        returns (address royaltiesRecipient, uint256 royaltiesAmount)
    {

        IERC2981Royalties withRoyalties = IERC2981Royalties(token);
        if (
            withRoyalties.supportsInterface(type(IERC2981Royalties).interfaceId)
        ) {
            (royaltiesRecipient, royaltiesAmount) = withRoyalties.royaltyInfo(
                tokenId,
                saleValue
            );
        }
    }
}// MIT
pragma solidity ^0.8.0;

pragma experimental ABIEncoderV2;



contract ExchangeStorage {

    enum TokenType {
        ETH,
        ERC20,
        ERC1155,
        ERC721
    }

    event Buy(
        uint256 indexed orderNonce,
        address indexed token,
        uint256 indexed tokenId,
        uint256 amount,
        address maker,
        address buyToken,
        uint256 buyTokenId,
        uint256 buyAmount,
        address buyer,
        uint256 total,
        uint256 serviceFee
    );

    event CloseOrder(
        uint256 orderNonce,
        address indexed token,
        uint256 indexed tokenId,
        address maker
    );

    struct Asset {
        TokenType tokenType;
        address token;
        uint256 tokenId;
        uint256 quantity;
    }

    struct OrderData {
        address exchange;
        address maker;
        address taker;
        Asset outAsset;
        Asset inAsset;
        uint256 maxPerBuy;
        uint256 orderNonce;
        uint256 expiration;
    }

    struct OrderMeta {
        address buyer;
        uint256 sellerFee;
        uint256 buyerFee;
        uint256 expiration;
        uint256 nonce;
    }

    address public exchangeSigner;

    mapping(bytes32 => bool) public usedSaleMeta;

    mapping(bytes32 => uint256) public completed;
}// MIT
pragma solidity ^0.8.0;




contract Exchange is BaseExchange, ReentrancyGuardUpgradeable, ExchangeStorage {

    function initialize(
        address payable beneficiary_,
        address transferProxy_,
        address exchangeSigner_
    ) public initializer {

        __BaseExchange_init(beneficiary_, transferProxy_);

        __ReentrancyGuard_init_unchained();

        setExchangeSigner(exchangeSigner_);
    }

    function setExchangeSigner(address exchangeSigner_) public onlyOwner {

        require(exchangeSigner_ != address(0), 'Exchange signer must be valid');
        exchangeSigner = exchangeSigner_;
    }

    function prepareOrderMessage(OrderData memory order)
        public
        pure
        returns (bytes32)
    {

        return keccak256(abi.encode(order));
    }

    function prepareOrderMetaMessage(
        Signature memory orderSig,
        OrderMeta memory saleMeta
    ) public pure returns (bytes32) {

        return keccak256(abi.encode(orderSig, saleMeta));
    }

    function computeValues(
        OrderData memory order,
        uint256 amount,
        OrderMeta memory saleMeta
    ) public view returns (OrderTransfers memory orderTransfers) {

        return
            _computeValues(
                order.inAsset.quantity,
                order.outAsset.token,
                order.outAsset.tokenId,
                amount,
                saleMeta.buyerFee,
                saleMeta.sellerFee
            );
    }

    function buy(
        OrderData memory order,
        Signature memory sig,
        uint256 amount, // quantity to buy
        OrderMeta memory saleMeta,
        Signature memory saleMetaSignature
    ) external payable nonReentrant {

        require(order.exchange == address(this), 'Sale: Wrong exchange.');

        if (order.taker != address(0)) {
            require(msg.sender == order.taker, 'Sale: Wrong user.');
        }

        require(
            (amount > 0) &&
                (order.maxPerBuy == 0 || amount <= order.maxPerBuy),
            'Sale: Wrong amount.'
        );

        _verifyOrderMeta(sig, saleMeta, saleMetaSignature);

        _validateOrderSig(order, sig);

        bool closed = _verifyOpenAndModifyState(order, amount);

        OrderTransfers memory orderTransfers = _doTransfers(
            order,
            amount,
            saleMeta
        );

        emit Buy(
            order.orderNonce,
            order.outAsset.token,
            order.outAsset.tokenId,
            amount,
            order.maker,
            order.inAsset.token,
            order.inAsset.tokenId,
            order.inAsset.quantity,
            msg.sender,
            orderTransfers.total,
            orderTransfers.serviceFees
        );

        if (closed) {
            emit CloseOrder(
                order.orderNonce,
                order.outAsset.token,
                order.outAsset.tokenId,
                order.maker
            );
        }
    }

    function cancelOrder(
        address token,
        uint256 tokenId,
        uint256 quantity,
        uint256 orderNonce
    ) public {

        bytes32 orderId = _getOrderId(
            token,
            tokenId,
            quantity,
            msg.sender,
            orderNonce
        );
        completed[orderId] = quantity;
        emit CloseOrder(orderNonce, token, tokenId, msg.sender);
    }

    function _validateOrderSig(OrderData memory order, Signature memory sig)
        public
        pure
    {

        require(
            recoverMessageSignature(prepareOrderMessage(order), sig) ==
                order.maker,
            'Sale: Incorrect order signature'
        );
    }

    function _getOrderId(
        address token,
        uint256 tokenId,
        uint256 quantity,
        address maker,
        uint256 orderNonce
    ) internal pure returns (bytes32) {

        return
            keccak256(abi.encode(token, tokenId, quantity, maker, orderNonce));
    }

    function _verifyOpenAndModifyState(
        OrderData memory order,
        uint256 buyingAmount
    ) internal returns (bool) {

        bytes32 orderId = _getOrderId(
            order.outAsset.token,
            order.outAsset.tokenId,
            order.outAsset.quantity,
            order.maker,
            order.orderNonce
        );
        uint256 comp = completed[orderId] + buyingAmount;

        require(
            comp <= order.outAsset.quantity,
            'Sale: Order already closed or quantity too high'
        );

        completed[orderId] = comp;

        return comp == order.outAsset.quantity;
    }

    function _verifyOrderMeta(
        Signature memory orderSig,
        OrderMeta memory saleMeta,
        Signature memory saleSig
    ) internal {

        require(
            saleMeta.expiration == 0 || saleMeta.expiration >= block.timestamp,
            'Sale: Buy Order expired'
        );

        require(saleMeta.buyer == msg.sender, 'Sale Metadata not for operator');

        bytes32 message = prepareOrderMetaMessage(orderSig, saleMeta);
        require(
            recoverMessageSignature(message, saleSig) == exchangeSigner,
            'Sale: Incorrect order meta signature'
        );

        require(usedSaleMeta[message] == false, 'Sale Metadata already used');

        usedSaleMeta[message] = true;
    }

    function _doTransfers(
        OrderData memory order,
        uint256 amount,
        OrderMeta memory saleMeta
    ) internal returns (OrderTransfers memory orderTransfers) {

        orderTransfers = computeValues(order, amount, saleMeta);

        require(
            msg.value == orderTransfers.totalTransaction,
            'Sale: Sent value is incorrect'
        );

        if (orderTransfers.totalTransaction > 0) {
            if (orderTransfers.serviceFees > 0) {
                beneficiary.transfer(orderTransfers.serviceFees);
            }

            if (orderTransfers.royaltiesAmount > 0) {
                payable(orderTransfers.royaltiesRecipient).transfer(
                    orderTransfers.royaltiesAmount
                );
            }

            if (orderTransfers.sellerEndValue > 0) {
                payable(order.maker).transfer(orderTransfers.sellerEndValue);
            }
        }

        if (order.outAsset.tokenType == TokenType.ERC1155) {
            transferProxy.erc1155SafeTransferFrom(
                order.outAsset.token,
                order.maker,
                msg.sender,
                order.outAsset.tokenId,
                amount,
                ''
            );
        } else {
            transferProxy.erc721SafeTransferFrom(
                order.outAsset.token,
                order.maker,
                msg.sender,
                order.outAsset.tokenId,
                ''
            );
        }
    }
}