
pragma solidity ^0.4.24;


contract EternalStorage {


    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20 {

    uint256 public totalSupply;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);


    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
contract Ownable is EternalStorage {

    event OwnershipTransferred(address previousOwner, address newOwner);
    
    address ownerAddress;
    
    constructor () {
        ownerAddress = msg.sender;
    }
    
    modifier onlyOwner() {

        require(msg.sender == owner());
        _;
    }

    function owner() public view returns (address) {

        return ownerAddress;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        setOwner(newOwner);
    }

    function setOwner(address newOwner) internal {

        emit OwnershipTransferred(owner(), newOwner);
        ownerAddress = newOwner;
    }
}


contract airdrop is Ownable{

      using SafeMath for uint256;

    event Multisended(uint256 total, address tokenAddress);

        
    function setTxCount(address customer, uint256 _txCount) private {

        uintStorage[keccak256(abi.encodePacked("txCount", customer))] = _txCount;
    }

    
    function txCount(address customer) public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("txCount", customer))];
    }
    
    function multisendToken(address token, address[] _contributors, uint256[] _balances) public onlyOwner  {

      
            uint256 total = 0;
            ERC20 erc20token = ERC20(token);
            uint8 i = 0;
            for (i; i < _contributors.length; i++) {
                erc20token.transfer(_contributors[i], _balances[i]);
                total += _balances[i];
            }
            setTxCount(msg.sender, txCount(msg.sender).add(1));
            emit Multisended(total, token);
        }
    
    
}