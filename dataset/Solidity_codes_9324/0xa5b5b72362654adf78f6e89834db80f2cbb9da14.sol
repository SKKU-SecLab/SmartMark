
pragma solidity 0.5.6;

contract Whitelist {

    mapping (uint => address) subscriberIndexToAddress;

    mapping (address => uint) subscriberAddressToSubscribed;

    uint subscriberIndex = 1;

    event OnSubscribed(address subscriberAddress);

    event OnUnsubscribed(address subscriberAddress);

    modifier isNotAContract(){

        require (msg.sender == tx.origin, "Contracts are not allowed to interact.");
        _;
    }
    
    function() external {
        subscribe();
    }
    
    function getSubscriberList() external view returns (address[] memory) {

        uint subscriberListAmount = getSubscriberAmount();
        
        address[] memory subscriberList = new address[](subscriberListAmount);
        uint subscriberListCounter = 0;
        
        for (uint i = 1; i < subscriberIndex; i++) {
            address subscriberAddress = subscriberIndexToAddress[i];

            if (isSubscriber(subscriberAddress) == true) {
                subscriberList[subscriberListCounter] = subscriberAddress;
                subscriberListCounter++;
            }
        }

        return subscriberList;
    }

    function getSubscriberAmount() public view returns (uint) {

        uint subscriberListAmount = 0;

        for (uint i = 1; i < subscriberIndex; i++) {
            address subscriberAddress = subscriberIndexToAddress[i];
            
            if (isSubscriber(subscriberAddress) == true) {
                subscriberListAmount++;
            }
        }

        return subscriberListAmount;
    }

    function subscribe() public isNotAContract {

        require(isSubscriber(msg.sender) == false, "You already subscribed.");
        
        subscriberAddressToSubscribed[msg.sender] = subscriberIndex;
        subscriberIndexToAddress[subscriberIndex] = msg.sender;
        subscriberIndex++;

        emit OnSubscribed(msg.sender);
    }

    function unsubscribe() external isNotAContract {

        require(isSubscriber(msg.sender) == true, "You have not subscribed yet.");

        uint index = subscriberAddressToSubscribed[msg.sender];
        delete subscriberIndexToAddress[index];

        emit OnUnsubscribed(msg.sender);
    }
    
    function isSubscriber() external view returns (bool) {

        return isSubscriber(tx.origin);
    }

    function isSubscriber(address subscriberAddress) public view returns (bool) {

        return subscriberIndexToAddress[subscriberAddressToSubscribed[subscriberAddress]] != address(0);
    }
}pragma solidity 0.5.6;


contract WhitelistAdvanced {

    mapping (uint256 => address) internal subscriberIndexToAddress;
    mapping (address => uint256) internal subscriberAddressToSubscribed;
    mapping (address => uint256) internal subscriberAddressToBlockNumber;

    Whitelist internal whitelistContract = Whitelist(0x6198149b79AFE8114dc07b46A01d94a6af304ED9);

    uint256 internal subscriberIndex = 1;

    event OnSubscribed(address _subscriberAddress);
    event OnUnsubscribed(address _subscriberAddress);

    modifier isNotAContract(){

        require (msg.sender == tx.origin, "Contracts are not allowed to interact.");
        _;
    }
    
    constructor() public {
        address[] memory subscriberList = whitelistContract.getSubscriberList();
        for (uint256 i = 0; i < subscriberList.length; i++) {
            _subscribe(subscriberList[i]);
        }
    }

    function() external {
        subscribe();
    }

    function getSubscriberList() external view returns (address[] memory) {

        uint256 subscriberListCounter = 0;
        uint256 subscriberListCount = getSubscriberCount();        
        address[] memory subscriberList = new address[](subscriberListCount);
        
        for (uint256 i = 1; i < subscriberIndex; i++) {
            address subscriberAddress = subscriberIndexToAddress[i];
            if (isSubscriber(subscriberAddress) != 0) {
                subscriberList[subscriberListCounter] = subscriberAddress;
                subscriberListCounter++;
            }
        }

        return subscriberList;
    }

    function getSubscriberCount() public view returns (uint256) {

        uint256 subscriberListCount = 0;

        for (uint256 i = 1; i < subscriberIndex; i++) {
            address subscriberAddress = subscriberIndexToAddress[i];
            if (isSubscriber(subscriberAddress) != 0) {
                subscriberListCount++;
            }
        }

        return subscriberListCount;
    }

    function subscribe() public isNotAContract {

        _subscribe(msg.sender);
    }

    function _subscribe(address _subscriber) internal {

        require(isSubscriber(_subscriber) == 0, "You already subscribed.");
        
        subscriberAddressToSubscribed[_subscriber] = subscriberIndex;
        subscriberAddressToBlockNumber[_subscriber] = block.number;
        subscriberIndexToAddress[subscriberIndex] = _subscriber;
        subscriberIndex++;

        emit OnSubscribed(_subscriber);
    }

    function unsubscribe() external isNotAContract {

        require(isSubscriber(msg.sender) != 0, "You have not subscribed yet.");

        uint256 index = subscriberAddressToSubscribed[msg.sender];
        delete subscriberIndexToAddress[index];

        emit OnUnsubscribed(msg.sender);
    }
    
    function isSubscriber() external view returns (uint256) {

        return isSubscriber(tx.origin);
    }

    function isSubscriber(address _subscriberAddress) public view returns (uint256) {

        if (subscriberIndexToAddress[subscriberAddressToSubscribed[_subscriberAddress]] != address(0)){
            return subscriberAddressToBlockNumber[_subscriberAddress];
        } else {
            return 0;
        }
    }
}