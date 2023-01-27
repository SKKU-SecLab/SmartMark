

pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.6.0;


contract Lockable {

    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        _preEntranceCheck();
        _preEntranceSet();
        _;
        _postEntranceReset();
    }

    modifier nonReentrantView() {

        _preEntranceCheck();
        _;
    }

    function _preEntranceCheck() internal view {

        require(_notEntered, "ReentrancyGuard: reentrant call");
    }

    function _preEntranceSet() internal {

        _notEntered = false;
    }

    function _postEntranceReset() internal {

        _notEntered = true;
    }
}


pragma solidity ^0.6.0;




contract AddressWhitelist is Ownable, Lockable {

    enum Status { None, In, Out }
    mapping(address => Status) public whitelist;

    address[] public whitelistIndices;

    event AddedToWhitelist(address indexed addedAddress);
    event RemovedFromWhitelist(address indexed removedAddress);

    function addToWhitelist(address newElement) external nonReentrant() onlyOwner {

        if (whitelist[newElement] == Status.In) {
            return;
        }

        if (whitelist[newElement] == Status.None) {
            whitelistIndices.push(newElement);
        }

        whitelist[newElement] = Status.In;

        emit AddedToWhitelist(newElement);
    }

    function removeFromWhitelist(address elementToRemove) external nonReentrant() onlyOwner {

        if (whitelist[elementToRemove] != Status.Out) {
            whitelist[elementToRemove] = Status.Out;
            emit RemovedFromWhitelist(elementToRemove);
        }
    }

    function isOnWhitelist(address elementToCheck) external view nonReentrantView() returns (bool) {

        return whitelist[elementToCheck] == Status.In;
    }

    function getWhitelist() external view nonReentrantView() returns (address[] memory activeWhitelist) {

        uint256 activeCount = 0;
        for (uint256 i = 0; i < whitelistIndices.length; i++) {
            if (whitelist[whitelistIndices[i]] == Status.In) {
                activeCount++;
            }
        }

        activeWhitelist = new address[](activeCount);
        activeCount = 0;
        for (uint256 i = 0; i < whitelistIndices.length; i++) {
            address addr = whitelistIndices[i];
            if (whitelist[addr] == Status.In) {
                activeWhitelist[activeCount] = addr;
                activeCount++;
            }
        }
    }
}