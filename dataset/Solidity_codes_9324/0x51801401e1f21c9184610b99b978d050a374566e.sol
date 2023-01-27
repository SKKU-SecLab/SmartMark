


pragma solidity ^0.6.0;

abstract contract Context {
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

pragma solidity 0.6.4;

interface IRegistry {

    function inRegistry(address _pool) external view returns(bool);

    function entries(uint256 _index) external view returns(address);

    function addBasket(address _basket) external;

    function removeBasket(uint256 _index) external;

    function removeBasketByAddress(address _address) external;

}

pragma solidity 0.6.4;

contract BasketRegistry is IRegistry, Ownable {

    mapping(address => bool) public override inRegistry;
    address[] public override entries;

    function addBasket(address _basket) external override onlyOwner {

        require(!inRegistry[_basket], "Basket is already in Registry");
        entries.push(_basket);
        inRegistry[_basket] = true;
    }

    function removeBasket(uint256 _index) public override onlyOwner {

        address registryAddress = entries[_index];

        inRegistry[registryAddress] = false;

        entries[_index] = entries[entries.length - 1];
        entries.pop();
    }
    
    function removeBasketByAddress(address _address) external override onlyOwner {

        for(uint256 i = 0; i < entries.length; i ++) {
            if(_address == entries[i]) {
                removeBasket(i);
                break;
            }
        }   
    }
}