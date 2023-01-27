

pragma solidity 0.4.26;

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

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}


pragma solidity 0.4.26;


interface IRoyaltyRegisterHub {

    function royaltyInfo(address _nftAddress, uint256 _salePrice)  external view returns (address receiver, uint256 royaltyAmount);

}


pragma solidity ^0.4.24;

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


pragma solidity 0.4.26;




interface IOwnable {

    function owner() external view returns (address);

}

contract RoyaltyRegisterHub is IRoyaltyRegisterHub, Ownable {


    uint public constant INVERSE_BASIS_POINT = 10000;
    uint public constant MAXIMUM_ROYALTY_RATE = 1000;

    bytes4 private constant OWNER_SELECTOR = 0x8da5cb5b; // owner()

    mapping(address => uint) public nftRoyaltyRateMap;
    mapping(address => address) public nftRoyaltyReceiverMap;

    constructor() public {

    }

    function setRoyaltyRate(address _nftAddress, uint256 _royaltyRate, address _receiver) public onlyOwner returns (bool) {

        require(_royaltyRate<MAXIMUM_ROYALTY_RATE, "royalty rate too large");
        require(_receiver!=address(0x0), "invalid royalty receiver");

        nftRoyaltyRateMap[_nftAddress] = _royaltyRate;
        nftRoyaltyReceiverMap[_nftAddress] = _receiver;
        return true;
    }

    function setRoyaltyRateFromNFTOwners(address _nftAddress, uint256 _royaltyRate, address _receiver) public returns (bool) {

        require(_royaltyRate<MAXIMUM_ROYALTY_RATE, "royaltyRate too large");
        require(_receiver!=address(0x0), "invalid royalty receiver");

        bool success;
        bytes memory data = abi.encodeWithSelector(OWNER_SELECTOR);
        bytes memory result = new bytes(32);
        assembly {
            success := call(
            gas,            // gas remaining
            _nftAddress,      // destination address
            0,              // no ether
            add(data, 32),  // input buffer (starts after the first 32 bytes in the `data` array)
            mload(data),    // input length (loaded from the first 32 bytes in the `data` array)
            result,         // output buffer
            32              // output length
            )
        }
        require(success, "no owner method");
        address owner;
        assembly {
            owner := mload(result)
        }
        require(msg.sender == owner, "not authorized");

        nftRoyaltyRateMap[_nftAddress] = _royaltyRate;
        nftRoyaltyReceiverMap[_nftAddress] = _receiver;
        return true;
    }

    function royaltyInfo(address _nftAddress, uint256 _salePrice) external view returns (address, uint256) {

        address receiver = nftRoyaltyReceiverMap[_nftAddress];
        uint256 royaltyAmount = SafeMath.div(SafeMath.mul(nftRoyaltyRateMap[_nftAddress], _salePrice), INVERSE_BASIS_POINT);

        return (receiver, royaltyAmount);
    }

}