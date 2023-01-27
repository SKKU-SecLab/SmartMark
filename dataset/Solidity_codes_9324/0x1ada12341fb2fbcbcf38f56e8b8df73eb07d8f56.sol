
pragma solidity ^0.7.4;

interface ERC20 {

    function transfer(address, uint256) external;

}

contract PermissionedPayments {


    address[] public s_entities;

    mapping(address => uint256) public s_rates;

    address public s_owner;

    modifier onlyOwner() {

        require(msg.sender == s_owner, "sender-not-owner");
        _;
    }

    event Payment(address indexed payee, uint256 indexed amount);

    constructor(address owner) {
        s_owner = owner;
    }

    function addEntity(address entity, uint256 rate) public onlyOwner {

        s_entities.push(entity);
        s_rates[entity] = rate;
    }

    function addEntities(address[] memory entities, uint256[] memory rates) public onlyOwner {

        require(entities.length == rates.length, "length-mismatch");
        for (uint256 i = 0; i < entities.length; i += 1) {
            addEntity(entities[i], rates[i]);
        }
    }

    function changeEntity(address entity, uint256 rate) public onlyOwner {

        s_rates[entity] = rate;
    }

    function removeEntity(address entity) public onlyOwner {

        s_rates[entity] = 0;

        for (uint256 i = 0; i < s_entities.length; i += 1) {
            if (s_entities[i] == entity) {
                s_entities[i] = s_entities[s_entities.length - 1];
                s_entities.pop();
            }
        }
    }

    function withdrawTokens(address tokenAddress, uint256 amt) public onlyOwner {

        ERC20(tokenAddress).transfer(msg.sender, amt);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        s_owner = newOwner;
    }

    function executeAutomatic(address tokenAddress) public onlyOwner returns (uint256 totalAmount) {

        totalAmount = 0;
        for (uint256 i = 0; i < s_entities.length; i += 1) {
            address payee = s_entities[i];
            uint256 amount = s_rates[payee];
            totalAmount += amount;
            ERC20(tokenAddress).transfer(payee, amount);
            emit Payment(payee, amount);
        }
    }

    function executeManual(
        address tokenAddress,
        address[] memory entities,
        uint256[] memory amounts
    ) public onlyOwner returns (uint256 totalAmount) {

        totalAmount = 0;
        require(entities.length == amounts.length, "length-mismatch");
        for (uint256 i = 0; i < entities.length; i += 1) {
            totalAmount += amounts[i];
            ERC20(tokenAddress).transfer(entities[i], amounts[i]);
            emit Payment(entities[i], amounts[i]);
        }
    }
}