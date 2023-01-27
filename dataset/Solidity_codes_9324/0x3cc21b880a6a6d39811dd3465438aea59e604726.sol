
pragma solidity 0.5.3;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
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

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ITransferPolicy {

    function isTransferPossible(address from, address to, uint256 amount) 
        external view returns (bool);

    
    function isBehalfTransferPossible(address sender, address from, address to, uint256 amount) 
        external view returns (bool);

}

contract BlacklistTransferPolicy is ITransferPolicy, Ownable {

    mapping (address => bool) private blacklist;

    event AddressBlacklisted(address address_);
    event AddressUnblacklisted(address address_);

    function blacklistAddress(address address_) public onlyOwner returns (bool){

        addToBlacklist(address_);
        return true;
    }

    function unblacklistAddress(address address_) public onlyOwner returns (bool){

        removeFromBlacklist(address_);
        return true;
    }

    function blacklistAddresses(address[] memory addresses) public onlyOwner returns (bool) {

        uint256 len = addresses.length;
        for (uint256 i; i < len; i++) {
            addToBlacklist(addresses[i]);
        }
        return true;
    }

    function unblacklistAddresses(address[] memory addresses) public onlyOwner returns (bool) {

        uint256 len = addresses.length;
        for (uint256 i; i < len; i++) {
            removeFromBlacklist(addresses[i]);
        }
        return true;
    }

    function isBlacklisted(address address_) public view returns (bool){

        return blacklist[address_];
    }

    function isTransferPossible(address from, address to, uint256) public view returns (bool) {

        return (!blacklist[from] && !blacklist[to]);
    }

    function isBehalfTransferPossible(address sender, address from, address to, uint256) 
    public view returns (bool) {

        return (!blacklist[sender] && !blacklist[from] && !blacklist[to]);
    }

    function addToBlacklist(address address_) internal {

        blacklist[address_] = true;
        emit AddressBlacklisted(address_);
    }

    function removeFromBlacklist(address address_) internal {

        blacklist[address_] = false;
        emit AddressUnblacklisted(address_);
    }
}