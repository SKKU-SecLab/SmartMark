
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

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

}//

pragma solidity ^0.8.4;



contract GlitchMarketplace is Ownable {

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private orderIds;
    Counters.Counter private tradeIds;

    bool public active = true;
    uint256 royalty = 5;
    address royaltyAddress;

    IERC721 Glitch;

    struct Order {
        address seller;
        address buyer;
        uint256 tokenId;
        uint256 price;
        bool isActive;
    }

    struct Trade {
        address seller;
        address buyer;
        uint256 tokenId_1;
        uint256 tokenId_2;
        bool isActive;
        string memo;
        uint256 responses;
    }

    struct Status {
        uint256 forSale;
        uint256 forTrade;
        uint256 forTradeResponse;
    }

    uint256 public activeOrders;
    mapping (uint256 => Order) public Orders;

    uint256 public activeTrades;
    mapping (uint256 => Trade) public Trades;
    mapping (uint256 => mapping(uint256 => uint256)) public TradeResponses;  // maps trade id to token ids

    event TradeEvent(uint256 tradeId, uint256 tokenId_1, uint256 tokenId_2, address seller, address buyer);
    event TradeListedEvent(uint256 tradeId, uint256 tokenId_1, string memo, address seller);
    event SaleEvent(uint256 orderId, uint256 tokenId, uint256 amount, address seller, address buyer);
    event SaleListedEvent(uint256 orderId, uint256 tokenId, uint256 amount, address seller);

    constructor(address glitchAddress, address _royaltyAddress) {
        Glitch = IERC721(glitchAddress);
        royaltyAddress = _royaltyAddress;
    }

    function list(uint256 tokenId, uint256 price) public {

        require(active, "Transfers are not active.");
        require(Glitch.ownerOf(tokenId) == msg.sender, "You must be owner to list.");
        require(Glitch.isApprovedForAll(msg.sender, address(this)), "You must approve tokens first.");
        Status memory status = getGlitchStatus(tokenId);
        require(status.forSale == 0, "Glitch is already for sale.");
        require(status.forTrade == 0, "Glitch is already for trade.");
        require(status.forTradeResponse == 0, "Glitch is already for trade response.");

        orderIds.increment();
        Orders[orderIds.current()] = Order(msg.sender, address(0), tokenId, price, true);
        activeOrders++;

        emit SaleListedEvent(orderIds.current(), tokenId, price, msg.sender);
    }

    function changePrice(uint256 tokenId, uint256 price) public {

        require(Glitch.ownerOf(tokenId) == msg.sender, "You must be owner to change price.");
        Status memory status = getGlitchStatus(tokenId);
        require(status.forSale > 0, "Glitch is not for sale.");

        Orders[status.forSale].price = price;
    }

    function buy(uint256 orderId) public payable {

        require(active, "Transfers are not active.");
        require(Orders[orderId].isActive, "Order is not active.");
        require(msg.value == Orders[orderId].price, "Price is not correct.");

        Order memory order = Orders[orderId];
        order.buyer = msg.sender;
        order.isActive = false;
        Orders[orderId] = order;
        activeOrders--;

        uint256 royaltyAmount = order.price.mul(royalty).div(100);

        Glitch.safeTransferFrom(order.seller, order.buyer, order.tokenId);
        payable(order.seller).transfer(order.price.sub(royaltyAmount));

        emit SaleEvent(orderId, order.tokenId, order.price, order.seller, order.buyer);
    }

    function tradeSeek(uint256 tokenId, string memory memo) public {

        require(active, "Transfers are not active.");
        require(Glitch.ownerOf(tokenId) == msg.sender, "You must be owner to trade.");
        require(Glitch.isApprovedForAll(msg.sender, address(this)), "You must approve tokens first.");

        Status memory status = getGlitchStatus(tokenId);
        require(status.forSale == 0, "Glitch is already for sale.");
        require(status.forTrade == 0, "Glitch is already for trade.");
        require(status.forTradeResponse == 0, "Glitch is already for trade response.");

        tradeIds.increment();
        Trades[tradeIds.current()] = Trade(msg.sender, address(0), tokenId, 0, true, memo, 0);
        activeTrades++;

        emit TradeListedEvent(tradeIds.current(), tokenId, memo, msg.sender);
    }

    function tradeResponse(uint256 tradeId, uint256 tokenId) public {

        require(active, "Transfers are not active.");
        require(Glitch.ownerOf(tokenId) == msg.sender, "You must be owner to trade.");
        require(Glitch.isApprovedForAll(msg.sender, address(this)), "You must approve tokens first.");
        require(Trades[tradeId].isActive, "Trade is no longer active.");

        Status memory status = getGlitchStatus(tokenId);
        require(status.forSale == 0, "Glitch is already for sale.");
        require(status.forTrade == 0, "Glitch is already for trade.");
        require(status.forTradeResponse == 0, "Glitch is already for trade response.");

        Trades[tradeId].responses++;
        TradeResponses[tradeId][Trades[tradeId].responses] = tokenId;
    }

    function tradeAccept(uint256 tradeId, uint256 responseId) public {

        require(active, "Transfers are not active.");
        require(Trades[tradeId].seller == msg.sender, "You are not the seller.");
        require(Glitch.ownerOf(Trades[tradeId].tokenId_1) == msg.sender, "You must be owner to trade.");
        require(Trades[tradeId].isActive, "Trade is no longer active.");

        uint256 tradeTokenId = TradeResponses[tradeId][responseId];
        Trade memory trade = Trades[tradeId];

        require(Glitch.isApprovedForAll(Trades[tradeId].seller, address(this)), "Seller is not approved.");
        require(Glitch.isApprovedForAll(Glitch.ownerOf(tradeTokenId), address(this)), "Buyer is not approved.");

        trade.tokenId_2 = tradeTokenId;
        trade.buyer = Glitch.ownerOf(tradeTokenId);
        trade.isActive = false;
        Trades[tradeId] = trade;
        activeTrades--;

        Glitch.safeTransferFrom(trade.seller, trade.buyer, trade.tokenId_1);
        Glitch.safeTransferFrom(trade.buyer, trade.seller, trade.tokenId_2);

        emit TradeEvent(tradeId, trade.tokenId_1, trade.tokenId_2, trade.seller, trade.buyer);
    }

    function cancelListing(uint256 orderId) public {

        require(Orders[orderId].seller == msg.sender, "You are not the seller.");
        Orders[orderId].isActive = false;
        activeOrders--;
    }

    function cancelTradeSeek(uint256 tradeId) public {

        require(Trades[tradeId].seller == msg.sender, "You are not the seller.");
        Trades[tradeId].isActive = false;
        activeTrades--;
    }

    function cancelTradeResponse(uint256 tradeId, uint256 tokenId) public {

        require(Glitch.ownerOf(tokenId) == msg.sender, "You must be owner to cancel trade.");
        for(uint256 i = 0; i <= Trades[tradeId].responses; i++) {
            if(TradeResponses[tradeId][i] == tokenId) {
                TradeResponses[tradeId][i] = 0;
            }
        }
    }

    function getActiveOrders() view public returns(uint256[] memory result) {

        result = new uint256[](activeOrders);
        uint256 resultIndex = 0;
        for (uint256 t = 1; t <= orderIds.current(); t++) {
            if (Orders[t].isActive) {
                result[resultIndex] = t;
                resultIndex++;
            }
        }
    }

    function getActiveTrades() view public returns(uint256[] memory result) {

        result = new uint256[](activeTrades);
        uint256 resultIndex = 0;
        for (uint256 t = 1; t <= tradeIds.current(); t++) {
            if (Trades[t].isActive) {
                result[resultIndex] = t;
                resultIndex++;
            }
        }
    }

    function getGlitchStatus(uint256 tokenId) public view returns (Status memory status) {

        status = Status(0, 0, 0);

        for (uint256 t = 1; t <= orderIds.current(); t++) {
            if (Orders[t].tokenId == tokenId && Orders[t].isActive) {
                status.forSale = t;
            }
        }

        for (uint256 t = 1; t <= tradeIds.current(); t++) {
            if (Trades[t].tokenId_1 == tokenId && Trades[t].isActive) {
                status.forTrade= t;
            } else {
                for(uint256 k=1; k<=Trades[t].responses; k++) {
                    if(TradeResponses[t][k] == tokenId && Trades[t].isActive) {
                        status.forTradeResponse = t;
                    }
                }
            }
        }
    }

    function setRoyalty(uint256 _royalty) public onlyOwner {

        royalty = _royalty;
    }

    function setRoyaltyAddress(address _royaltyAddress) public onlyOwner {

        royaltyAddress = _royaltyAddress;
    }

    function setActive(bool _active) public onlyOwner {

        active = _active;
    }

    function withdraw() public payable onlyOwner {

        require(payable(royaltyAddress).send(address(this).balance));
    }
}