
pragma solidity 0.5.0;
pragma experimental ABIEncoderV2;

interface ERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Must be owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Cannot transfer to zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SubscriptionsContract is Ownable {

    address public feeWallet;
    address public currency;
    uint public feePercent;
    
    using SafeMath for uint256;
    
    struct Subscription {
        address user;
        address merchant;
        string productId;
        string parentProductId;
        string status;
        bool unlimited;
        bool isSubProduct;
        uint cycles;
        uint payment;
        uint successPaymentsAmount;
        uint lastPaymentDate;
    }
    
    mapping(string => Subscription) subscriptions;
    mapping(string => bool) productPaused;
    
    event SubscriptioMonthlyPaymentPaid(address, address, uint, uint);
    
    constructor(address _feeWallet, address _currency, uint _feePercent) public {
        feeWallet = _feeWallet;
        currency = _currency;
        feePercent = _feePercent;
    }
    
    function subscribeUser(address user, address merchant, string memory subscriptionId, string memory productId, uint cycles, uint payment, bool unlimited, bool isSubProduct, string memory parentProductId) public onlyOwner {

        require(ERC20(currency).balanceOf(user) >= payment, 'User doesnt have enough tokens for first payment');
        require(ERC20(currency).allowance(user, address(this)) >= payment.mul(cycles), 'User didnt approve needed amount of tokens');
        require(!productPaused[productId], 'Product paused by merchant');
        require(keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked(("active"))), "User already has an active subscription for this merchant");
        
        if(subscriptions[subscriptionId].isSubProduct) {
            require(!productPaused[subscriptions[subscriptionId].parentProductId], "Parent product paused by merchant");
        }
        
        subscriptions[subscriptionId] = Subscription(user, merchant, productId, parentProductId, 'active', unlimited, isSubProduct, cycles, payment, 0, 0);
        
        processPayment(subscriptionId, payment);
    }
    
    function processPayment(string memory subscriptionId, uint payment) public onlyOwner {

        require((subscriptions[subscriptionId].successPaymentsAmount < subscriptions[subscriptionId].cycles) || subscriptions[subscriptionId].unlimited, 'Subscription is over');
        require((payment <= subscriptions[subscriptionId].payment) || subscriptions[subscriptionId].unlimited, 'Payment cant be more then started payment amount');
        require(!productPaused[subscriptions[subscriptionId].productId], 'Product paused by merchant');
        require(keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked(("unsubscribed"))), 'Subscription must be unsubscribed');
        require(keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked(("paused"))), 'Subscription must not be paused');
        
        if(ERC20(currency).balanceOf(subscriptions[subscriptionId].user) < subscriptions[subscriptionId].payment) {
            subscriptions[subscriptionId].status = "unsubscribed";
            return;
        }
        
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, subscriptions[subscriptionId].merchant, payment.mul(uint(1000).sub(feePercent)).div(1000).sub(300000000000000000)), "Transfer to merchant failed");
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, feeWallet, payment.mul(feePercent).div(1000).add(300000000000000000)), "Transfer to fee wallet failed");
        
        subscriptions[subscriptionId].status = "active";
        subscriptions[subscriptionId].lastPaymentDate = block.timestamp;
        subscriptions[subscriptionId].successPaymentsAmount = subscriptions[subscriptionId].successPaymentsAmount.add(1);
        
        emit SubscriptioMonthlyPaymentPaid(subscriptions[subscriptionId].user, subscriptions[subscriptionId].merchant, payment, subscriptions[subscriptionId].lastPaymentDate);
        
        if(subscriptions[subscriptionId].successPaymentsAmount == subscriptions[subscriptionId].cycles && !subscriptions[subscriptionId].unlimited) {
            subscriptions[subscriptionId].status = "end";
        }
    }
    
    function pauseSubscriptionsByMerchant(string memory productId) public onlyOwner {

        productPaused[productId] = true;
    }
    
    function activateSubscriptionsByMerchant(string memory productId) public onlyOwner {

        productPaused[productId] = false;
    }
    
    function unsubscriveBatchByMerchant(string[] memory subscriptionIds) public onlyOwner {

        for(uint i = 0; i < subscriptionIds.length; i++) {
            subscriptions[subscriptionIds[i]].status = "unsubscribed";
        }
    }
    
    function cancelSubscription(string memory subscriptionId) public onlyOwner {

        subscriptions[subscriptionId].status = "unsubscribed";
    }
    
    function pauseSubscription(string memory subscriptionId) public onlyOwner {

        require(ERC20(currency).balanceOf(subscriptions[subscriptionId].user) >= subscriptions[subscriptionId].payment.mul(125).div(1000), 'User doesnt have enough tokens for first payment');
        require(ERC20(currency).allowance(subscriptions[subscriptionId].user, address(this)) >= subscriptions[subscriptionId].payment.mul(125).div(1000), 'User didnt approve needed amount of tokens');
        
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, subscriptions[subscriptionId].merchant, subscriptions[subscriptionId].payment.mul(10).div(100)), "Transfer to merchant failed");
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, feeWallet, subscriptions[subscriptionId].payment.mul(25).div(1000)), "Transfer to fee wallet failed");
        
        subscriptions[subscriptionId].status = "paused";
    }
    
    function activateSubscription(string memory subscriptionId) public onlyOwner {

        require(keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) == keccak256(abi.encodePacked(("unsubscribed"))), "Subscription must be unsubscribed");
        subscriptions[subscriptionId].status = "active";
    }
    
    function getSubscriptionStatus(string calldata subscriptionId) external view returns(string memory) {

        return subscriptions[subscriptionId].status;
    }
    
    function getSubscriptionDetails(string calldata subscriptionId) external view returns(Subscription memory) {

        return subscriptions[subscriptionId];
    }
    
}