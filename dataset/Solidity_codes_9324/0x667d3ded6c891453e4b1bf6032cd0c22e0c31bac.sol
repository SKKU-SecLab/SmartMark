
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}// MIT
pragma solidity ^0.8.13;


interface IOrderBook {

    event SellOrderCreated(address indexed sellOrder);

    event OwnerChanged(address previous, address next);

    event FeeChanged(uint256 previous, uint256 next);

    function owner() external view returns (address);


    function fee() external view returns (uint256);


    function setFee(uint256 _fee) external;


    function setOwner(address _newOwner) external;


    function createSellOrder(
        address seller,
        IERC20 token,
        uint256 stake,
        string memory uri,
        uint256 timeout
    ) external returns (SellOrder);

}// MIT
pragma solidity ^0.8.13;


contract SellOrder {

    error MustBeSeller();

    error InvalidState(State expected, State received);

    event OfferSubmitted(
        address indexed buyer,
        uint256 indexed price,
        uint256 indexed stake,
        string uri
    );

    event OfferWithdrawn(address indexed buyer);

    event OfferCommitted(address indexed buyer);

    event OfferConfirmed(address indexed buyer);

    event OfferEnforced(address indexed buyer);

    IERC20 public token;

    address public seller;

    uint256 public timeout;

    uint256 public orderStake;

    address public orderBook;

    string private _uri;

    enum State {
        Closed,
        Open,
        Committed
    }

    struct Offer {
        uint256 price;
        uint256 stake;
        string uri;
        State state;
        uint256 acceptedAt;
    }

    mapping(address => Offer) public offers;

    uint256 constant ONE_MILLION = 1000000;

    constructor(
        address seller_,
        IERC20 token_,
        uint256 orderStake_,
        string memory uri_,
        uint256 timeout_
    ) {
        orderBook = msg.sender;
        seller = seller_;
        token = token_;
        orderStake = orderStake_;
        _uri = uri_;
        timeout = timeout_;
    }

    function orderURI() external view virtual returns (string memory) {

        return _uri;
    }

    function setURI(string memory uri_) external virtual onlySeller {

        _uri = uri_;
    }

    modifier onlyState(address buyer_, State expected) {

        if (offers[buyer_].state != expected) {
            revert InvalidState(expected, offers[buyer_].state);
        }

        _;
    }

    modifier onlySeller() {

        if (msg.sender != seller) {
            revert MustBeSeller();
        }

        _;
    }

    function submitOffer(
        uint256 price,
        uint256 stake,
        string memory uri
    ) external virtual onlyState(msg.sender, State.Closed) {

        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= stake + price, 'Insufficient allowance');

        offers[msg.sender] = Offer(price, stake, uri, State.Open, 0);

        bool result = token.transferFrom(
            msg.sender,
            address(this),
            stake + price
        );
        require(result, 'Transfer failed');

        emit OfferSubmitted(msg.sender, price, stake, uri);
    }

    function withdrawOffer()
        external
        virtual
        onlyState(msg.sender, State.Open)
    {

        Offer memory offer = offers[msg.sender];

        bool result = token.transfer(msg.sender, offer.stake + offer.price);
        assert(result);

        offers[msg.sender] = Offer(0, 0, offer.uri, State.Closed, 0);

        emit OfferWithdrawn(msg.sender);
    }

    function commit(address buyer_)
        external
        virtual
        onlyState(buyer_, State.Open)
        onlySeller
    {

        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= orderStake);
        bool result = token.transferFrom(msg.sender, address(this), orderStake);
        assert(result);

        Offer memory offer = offers[buyer_];
        offers[buyer_] = Offer(
            offer.price,
            offer.stake,
            offer.uri,
            State.Committed,
            block.timestamp
        );

        emit OfferCommitted(buyer_);
    }

    function confirm() external virtual onlyState(msg.sender, State.Committed) {

        Offer memory offer = offers[msg.sender];
        offers[msg.sender] = Offer(
            0,
            0,
            offer.uri,
            State.Closed,
            block.timestamp
        );

        bool result0 = token.transfer(msg.sender, offer.stake);
        assert(result0);

        bool result1 = token.transfer(seller, orderStake);
        assert(result1);

        uint256 toOrderBook = (offer.price * IOrderBook(orderBook).fee()) /
            ONE_MILLION;
        uint256 toSeller = offer.price - toOrderBook;

        bool result2 = token.transfer(seller, toSeller);
        assert(result2);

        bool result3 = token.transfer(
            IOrderBook(orderBook).owner(),
            toOrderBook
        );
        assert(result3);

        emit OfferConfirmed(msg.sender);
    }

    function enforce(address buyer_)
        external
        virtual
        onlyState(buyer_, State.Committed)
    {

        Offer memory offer = offers[buyer_];
        require(block.timestamp > timeout + offer.acceptedAt);

        offers[buyer_] = Offer(0, 0, offer.uri, State.Closed, block.timestamp);

        bool result0 = token.transfer(seller, offer.price);
        assert(result0);

        bool result1 = token.transfer(
            address(0x000000000000000000000000000000000000dEaD),
            offer.stake
        );
        assert(result1);

        bool result2 = token.transfer(
            address(0x000000000000000000000000000000000000dEaD),
            orderStake
        );
        assert(result2);

        emit OfferEnforced(buyer_);
    }
}// MIT
pragma solidity ^0.8.13;


contract OrderBook is IOrderBook {

    mapping(address => bool) public sellOrders;

    uint256 public fee = 10000; // 1%

    address private _owner;

    error NotOwner();

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        if (owner() != msg.sender) {
            revert NotOwner();
        }
        _;
    }

    function setFee(uint256 _fee) external onlyOwner {

        emit FeeChanged(fee, _fee);
        fee = _fee;
    }

    function setOwner(address _newOwner) external onlyOwner {

        emit OwnerChanged(owner(), _newOwner);
        _owner = _newOwner;
    }

    function createSellOrder(
        address seller,
        IERC20 token,
        uint256 stake,
        string memory uri,
        uint256 timeout
    ) external returns (SellOrder) {

        SellOrder sellOrder = new SellOrder(seller, token, stake, uri, timeout);
        emit SellOrderCreated(address(sellOrder));
        sellOrders[address(sellOrder)] = true;
        return sellOrder;
    }
}