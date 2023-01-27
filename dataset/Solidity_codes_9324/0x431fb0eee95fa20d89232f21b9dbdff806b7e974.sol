

pragma solidity ^0.4.24;


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


pragma solidity ^0.4.24;


interface RegulatorServiceI {

  function check(address _token, address _spender, address _from, address _to, uint256 _amount) external returns (uint8);

  function participants(address _token, address participant) external view returns (uint8);

  function messageForReason(uint8 reason) external view returns (string);

}

interface RegulatedTokenERC1404I {

  function _service() external view returns (RegulatorServiceI);

}

contract PermissionChecker is Ownable {

  mapping(bytes32 => address) internal tokenAddresses;

  event NewToken(string name, address addr);

    function getTokenAddress(string name) public view returns (address) {

        return tokenAddresses[stringToBytes32(name)];
    }
    
  function setTokenAddress(string name, address addr) public onlyOwner {

    tokenAddresses[stringToBytes32(name)] = addr;
    emit NewToken(name, addr);
  }
  
  function checkTransfer(string _token, address _from, address _to, uint256 _amount) public view returns (uint8) {

    bytes32 token = stringToBytes32(_token);
    RegulatedTokenERC1404I rtoken = RegulatedTokenERC1404I(tokenAddresses[token]);
    RegulatorServiceI service = rtoken._service();
    return service.check(tokenAddresses[token], _from, _from, _to, _amount);
  }

  function checkPermission(string tokenName, address addr) public view returns (uint8) {

    bytes32 token = stringToBytes32(tokenName);
    RegulatedTokenERC1404I rtoken = RegulatedTokenERC1404I(tokenAddresses[token]);
    RegulatorServiceI service = rtoken._service();
    return service.participants(tokenAddresses[token], addr);
  }
  
  function messageForReason(string tokenName, uint8 _reason) public view returns (string) {

    bytes32 token = stringToBytes32(tokenName);
    RegulatedTokenERC1404I rtoken = RegulatedTokenERC1404I(tokenAddresses[token]);
    RegulatorServiceI service = rtoken._service();
    return service.messageForReason(_reason);
  }
  
  function stringToBytes32(string memory source) public pure returns (bytes32 result) {

    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
  }
}