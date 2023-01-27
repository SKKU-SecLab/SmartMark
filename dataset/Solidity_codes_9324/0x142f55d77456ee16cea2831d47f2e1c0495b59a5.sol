
pragma solidity ^0.4.25;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}


contract Ownable {

  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    _owner = msg.sender;
  }

  function owner() public view returns(address) {

    return _owner;
  }

  modifier onlyOwner() {

    require(isOwner());
    _;
  }

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(_owner);
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


contract AirDropStore is Ownable {

    using SafeMath for uint256;
    
    address[] public arrayAirDrops;
    mapping (address => uint256) public indexOfAirDropAddress;
    
    event addToAirDropList(address _address);
    event removeFromAirDropList(address _address);
    
    function getArrayAirDropsLength() public view returns (uint256) {

        return arrayAirDrops.length;
    }
    
    function addAirDropAddress(address _address) public onlyOwner {

        arrayAirDrops.push(_address);
        indexOfAirDropAddress[_address] = arrayAirDrops.length.sub(1);
    
        emit addToAirDropList(_address);
    }
    
    function addAirDropAddresses(address[] _addresses) public onlyOwner {

        for (uint i = 0; i < _addresses.length; i++) {
            arrayAirDrops.push(_addresses[i]);
            indexOfAirDropAddress[_addresses[i]] = arrayAirDrops.length.sub(1);

            emit addToAirDropList(_addresses[i]);
        }
    }
    
    function removeAirDropAddress(address _address) public onlyOwner {

        uint256 index =  indexOfAirDropAddress[_address];

        arrayAirDrops[index] = address(0);
        emit removeFromAirDropList(_address);
    }
    
    function removeAirDropAddresses(address[] _addresses) public onlyOwner {

        uint256 index;
        
        for (uint i = 0; i < _addresses.length; i++) {
        
            index =  indexOfAirDropAddress[_addresses[i]];

            arrayAirDrops[index] = address(0);
            emit removeFromAirDropList(_addresses[i]);
        }
    }
}