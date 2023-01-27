

pragma solidity ^0.6.11;

abstract contract WhitelistConsumer {
    address public whitelist;

    event WhitelistSourceUpdated(address newSource);

    modifier onlyWhitelisted() {
        if (whitelist != address(0)) {
            require(Whitelist(whitelist).isAllowed(msg.sender), "NOT_WHITELISTED");
        }
        _;
    }

    function updateWhitelistSource(address newSource) external {
        require(msg.sender == whitelist, "NOT_FROM_LIST");
        whitelist = newSource;
        emit WhitelistSourceUpdated(newSource);
    }
}

contract Whitelist {

    address public owner;
    mapping(address => bool) public isAllowed;

    event OwnerUpdated(address newOwner);
    event WhitelistUpgraded(address newWhitelist, address[] targets);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {

        owner = newOwner;
        emit OwnerUpdated(newOwner);
    }

    function setWhitelist(address[] memory user, bool[] memory val) external onlyOwner {

        require(user.length == val.length, "INVALID_INPUT");

        for (uint256 i = 0; i < user.length; i++) {
            isAllowed[user[i]] = val[i];
        }
    }

    function triggerConsumers(address newWhitelist, address[] memory targets) external onlyOwner {

        for (uint256 i = 0; i < targets.length; i++) {
            WhitelistConsumer(targets[i]).updateWhitelistSource(newWhitelist);
        }
        emit WhitelistUpgraded(newWhitelist, targets);
    }
}