pragma solidity ^0.7.3;

interface ITrading {


    function processOrder(uint256 id, bytes32 symbol, uint256 price, uint256 margin, uint256 positionId, address liquidator) external;

    function cancelOrder(uint256 id, uint256 positionId, address liquidator, string calldata reason) external;


}pragma solidity ^0.7.3;


contract Queue {



    struct Order {
        address liquidator; // 20 bytes
        bytes12 symbol; // 12 bytes
        uint64 positionId; // 8 bytes
        uint64 margin; // 8 bytes
    }


    address public oracle;

    address public trading;

    uint256 public firstOrderId;

    uint256 public nextOrderId;

    mapping(uint256 => Order) private queue;

    address public owner;
    bool private initialized;

    event NewContracts(address oracle, address trading);


    function initialize() public {

        require(!initialized, '!initialized');
        initialized = true;
        owner = msg.sender;
        firstOrderId = 1;
        nextOrderId = 1;
    }


    function registerContracts(
        address _oracle,
        address _trading
    ) external onlyOwner {

        oracle = _oracle;
        trading = _trading;
        emit NewContracts(_oracle, _trading);
    }



    function getQueuedOrders() external view returns (
        bytes32[] memory symbols,
        uint256 firstId,
        uint256 lastId
    ) {


        uint256 _queueLength = queueLength();

        symbols = new bytes32[](_queueLength);

        if (_queueLength > 0) {

            uint256 mFirstOrderId = firstOrderId;
            uint256 mNextOrderId = nextOrderId;

            for (uint256 i = mFirstOrderId; i < mNextOrderId; i++) {
                symbols[i - mFirstOrderId] = bytes12(queue[i].symbol);
            }

        }

        return (
            symbols,
            firstOrderId,
            nextOrderId
        );

    }

    function queueOrder(
        bytes32 symbol,
        uint256 margin,
        uint256 positionId,
        address liquidator
    ) external onlyTrading returns (uint256 id) {


        uint256 mNextOrderId = nextOrderId;
        require(mNextOrderId - firstOrderId < maxQueueSize(), '!full');

        Order storage order = queue[mNextOrderId];
        nextOrderId = mNextOrderId + 1;

        order.symbol = bytes12(symbol);

        if (positionId > 0) {
            order.positionId = uint64(positionId);
            if (liquidator != address(0)) {
                order.liquidator = liquidator;
            } else {
                order.margin = uint64(margin);
            }
        }

        return mNextOrderId;

    }

    function setPricesAndProcessQueue(
        uint256[] calldata prices,
        uint256 firstId,
        uint256 lastId
    ) external onlyOracle {


        require(firstId < lastId, '!range');
        require(prices.length > 0 && prices.length == (lastId - firstId), '!incompatible');
        require(firstId == firstOrderId, '!first_id');
        require(lastId <= nextOrderId, '!last_id');
        
        firstOrderId = lastId;

        uint256 i = 0;
        while (firstId < lastId) {

            Order memory order = queue[firstId];
            delete queue[firstId];
            
            processOrder(
                firstId,
                order,
                prices[i]
            );

            i++;
            firstId++;

        }

    }


    function processOrder(
        uint256 id,
        Order memory order,
        uint256 price
    ) internal {


        if (price != 0) {


            try ITrading(trading).processOrder(
                id,
                order.symbol,
                price,
                order.margin,
                order.positionId,
                order.liquidator
            ) {} catch Error(string memory reason) {
                ITrading(trading).cancelOrder(
                    id,
                    order.positionId,
                    order.liquidator,
                    reason
                );
            } catch (bytes memory /*lowLevelData*/) {
                ITrading(trading).cancelOrder(
                    id,
                    order.positionId,
                    order.liquidator,
                    '!failed'
                );
            }

        } else {
            ITrading(trading).cancelOrder(
                id,
                order.positionId,
                order.liquidator,
                '!unavailable'
            );
        }

    }


    function queueLength() public view returns (uint256 length) {
        return nextOrderId - firstOrderId;
    }

    function processedOrdersCount() external view returns (uint256 count) {
        return firstOrderId;
    }

    function maxQueueSize() internal pure virtual returns (uint256 maxSize) {
        return 60;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, '!authorized');
        _;
    }

    modifier onlyTrading() {
        require(msg.sender == trading, '!authorized');
        _;
    }

    modifier onlyOracle() {
        require(msg.sender == oracle, '!authorized');
        _;
    }

}