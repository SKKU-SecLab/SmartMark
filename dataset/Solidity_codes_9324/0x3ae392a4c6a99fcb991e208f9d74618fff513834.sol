
pragma solidity ^0.4.24;

library stringToBytes32 {

  function convert(string memory source) internal pure returns (bytes32 result) {

    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
   }
}

interface IContractRegistry {

    function addressOf(bytes32 _contractName) external view returns (address);

    function getAddress(bytes32 _contractName) external view returns (address);

}


interface ERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface BancorNetworkInterface {

   function getReturnByPath(
     address[] _path,
     uint256 _amount)
     external
     view
     returns (uint256, uint256);


    function conversionPath(
      ERC20 _sourceToken,
      ERC20 _targetToken
    ) external view returns (address[]);


    function rateByPath(
        address[] _path,
        uint256 _amount
    ) external view returns (uint256);

}


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


contract GetBancorData is Ownable{

  using stringToBytes32 for string;

  IContractRegistry public bancorRegistry;

  constructor(address _bancorRegistry)public{
    bancorRegistry = IContractRegistry(_bancorRegistry);
  }

  function getBancorContractAddresByName(string _name) public view returns (address result){

     bytes32 name = stringToBytes32.convert(_name);
     result = bancorRegistry.addressOf(name);
  }

  function getBancorRatioForAssets(ERC20 _from, ERC20 _to, uint256 _amount) public view returns(uint256 result){

    if(_amount > 0){
      BancorNetworkInterface bancorNetwork = BancorNetworkInterface(
        getBancorContractAddresByName("BancorNetwork")
      );

      address[] memory path = bancorNetwork.conversionPath(_from, _to);

      return bancorNetwork.rateByPath(path, _amount);
    }
    else{
      result = 0;
    }
  }

  function getBancorPathForAssets(ERC20 _from, ERC20 _to) public view returns(address[] memory){

    BancorNetworkInterface bancorNetwork = BancorNetworkInterface(
      getBancorContractAddresByName("BancorNetwork")
    );

    address[] memory path = bancorNetwork.conversionPath(_from, _to);

    return path;
  }

  function changeRegistryAddress(address _bancorRegistry) public onlyOwner{

    bancorRegistry = IContractRegistry(_bancorRegistry);
  }
}