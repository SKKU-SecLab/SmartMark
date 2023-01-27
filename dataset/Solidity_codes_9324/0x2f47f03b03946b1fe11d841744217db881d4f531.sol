
pragma solidity 0.6.4;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(this), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(msg.sender == _owner, "Ownable: the caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {

        require(newOwner != address(0), "Ownable: the new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BulkSender is Ownable {


    mapping(address => bool) whitelist;

    modifier onlyWhiteListed() {

        require(whitelist[msg.sender], "Whitelist: the caller is not whitelisted");
        _;
    }

    function approve(address addr) onlyOwner external {

        whitelist[addr] = true;
    }

    function remove(address addr) onlyOwner external {

        whitelist[addr] = false;
    }

    function isWhiteListed(address addr) public view returns (bool) {

        return whitelist[addr];
    }

    function distribute(address[] calldata addresses, uint256[] calldata amounts) onlyWhiteListed external payable  {

        require(addresses.length > 0, "BulkSender: the length of addresses should be greater than zero");
        require(amounts.length == addresses.length, "BulkSender: the length of addresses is not equal the length of amounts");

        for (uint256 i; i < addresses.length; i++) {
            uint256 value = amounts[i];
            require(value > 0, "BulkSender: the value should be greater then zero");
            address payable _to = address(uint160(addresses[i]));
            _to.transfer(value);
        }

        require(address(this).balance == 0, "All received funds must be transfered");
    }

    receive() external payable {
        revert("This contract shouldn't accept payments.");
    }

}