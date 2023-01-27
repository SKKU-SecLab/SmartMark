pragma solidity ^0.6.1;

contract Owned {

    constructor() public { owner = msg.sender; }
    address payable public owner;

    modifier onlyOwner {

        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }

    function transferOwnership(address payable newOwner) external onlyOwner {

        owner = newOwner;
    }
}
pragma solidity ^0.6.1;


contract Swap is Owned {

    uint public refundDelay = 4 * 60 * 4;

    uint constant MAX_REFUND_DELAY = 60 * 60 * 2 * 4;

    function setRefundDelay(uint delay) external onlyOwner {

        require(delay <= MAX_REFUND_DELAY, "Delay is too large.");
        refundDelay = delay;
    }
}
pragma solidity ^0.6.1;
pragma experimental ABIEncoderV2;


contract EtherSwap is Swap {

    enum OrderState { HasFundingBalance, Claimed, Refunded }

    struct FundDetails {
        bytes16 orderUUID;
        bytes32 paymentHash;
    }
    struct FundDetailsWithAdminRefundEnabled {
        bytes16 orderUUID;
        bytes32 paymentHash;
        bytes32 refundHash;
    }
    struct ClaimDetails {
        bytes16 orderUUID;
        bytes32 paymentPreimage;
    }
    struct AdminRefundDetails {
        bytes16 orderUUID;
        bytes32 refundPreimage;
    }
    struct SwapOrder {
        address payable user;
        bytes32 paymentHash;
        bytes32 refundHash;
        uint256 onchainAmount;
        uint256 refundBlockHeight;
        OrderState state;
        bool exist;
    }

    mapping(bytes16 => SwapOrder) orders;

    event OrderFundingReceived(
        bytes16 orderUUID,
        uint256 onchainAmount,
        bytes32 paymentHash,
        uint256 refundBlockHeight
    );
    event OrderFundingReceivedWithAdminRefundEnabled(
        bytes16 orderUUID,
        uint256 onchainAmount,
        bytes32 paymentHash,
        uint256 refundBlockHeight,
        bytes32 refundHash
    );
    event OrderClaimed(bytes16 orderUUID);
    event OrderRefunded(bytes16 orderUUID);
    event OrderAdminRefunded(bytes16 orderUUID);

    function deleteUnnecessaryOrderData(SwapOrder storage order) internal {

        delete order.user;
        delete order.paymentHash;
        delete order.onchainAmount;
        delete order.refundBlockHeight;
    }

    function fund(FundDetails memory details) public payable {

        SwapOrder storage order = orders[details.orderUUID];

        if (!order.exist) {
            order.user = msg.sender;
            order.exist = true;
            order.paymentHash = details.paymentHash;
            order.refundBlockHeight = block.number + refundDelay;
            order.state = OrderState.HasFundingBalance;
        } else {
            require(order.state == OrderState.HasFundingBalance, "Order already claimed or refunded.");
        }
        order.onchainAmount += msg.value;

        emit OrderFundingReceived(details.orderUUID, order.onchainAmount, order.paymentHash, order.refundBlockHeight);
    }

    function fundWithAdminRefundEnabled(FundDetailsWithAdminRefundEnabled memory details) public payable {

        SwapOrder storage order = orders[details.orderUUID];

        if (!order.exist) {
            order.user = msg.sender;
            order.exist = true;
            order.paymentHash = details.paymentHash;
            order.refundHash = details.refundHash;
            order.refundBlockHeight = block.number + refundDelay;
            order.state = OrderState.HasFundingBalance;
        } else {
            require(order.state == OrderState.HasFundingBalance, "Order already claimed or refunded.");
        }
        order.onchainAmount += msg.value;

        emit OrderFundingReceivedWithAdminRefundEnabled(
            details.orderUUID,
            order.onchainAmount,
            order.paymentHash,
            order.refundBlockHeight,
            order.refundHash
        );
    }

    function claim(ClaimDetails memory details) public {

        SwapOrder storage order = orders[details.orderUUID];

        require(order.exist == true, "Order does not exist.");
        require(order.state == OrderState.HasFundingBalance, "Order not in claimable state.");
        require(sha256(abi.encodePacked(details.paymentPreimage)) == order.paymentHash, "Incorrect payment preimage.");
        require(block.number <= order.refundBlockHeight, "Too late to claim.");

        order.state = OrderState.Claimed;

        (bool success, ) = owner.call.value(order.onchainAmount)("");
        require(success, "Transfer failed.");

        deleteUnnecessaryOrderData(order);
        emit OrderClaimed(details.orderUUID);
    }

    function refund(bytes16 orderUUID) public {

        SwapOrder storage order = orders[orderUUID];

        require(order.exist == true, "Order does not exist.");
        require(order.state == OrderState.HasFundingBalance, "Order not in refundable state.");
        require(block.number > order.refundBlockHeight, "Too early to refund.");

        order.state = OrderState.Refunded;

        (bool success, ) = order.user.call.value(order.onchainAmount)("");
        require(success, "Transfer failed.");

        deleteUnnecessaryOrderData(order);
        emit OrderRefunded(orderUUID);
    }

    function adminRefund(AdminRefundDetails memory details) public {

        SwapOrder storage order = orders[details.orderUUID];

        require(order.exist == true, "Order does not exist.");
        require(order.state == OrderState.HasFundingBalance, "Order not in refundable state.");
        require(order.refundHash != 0, "Admin refund not allowed.");
        require(sha256(abi.encodePacked(details.refundPreimage)) == order.refundHash, "Incorrect refund preimage.");

        order.state = OrderState.Refunded;

        (bool success, ) = order.user.call.value(order.onchainAmount)("");
        require(success, "Transfer failed.");

        deleteUnnecessaryOrderData(order);
        emit OrderAdminRefunded(details.orderUUID);
    }
}
