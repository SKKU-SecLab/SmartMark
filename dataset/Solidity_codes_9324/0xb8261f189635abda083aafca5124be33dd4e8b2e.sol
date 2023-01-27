
pragma solidity 0.4.24;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}


contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
       emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


interface Token {

    function transfer(address _to, uint _amount) external  returns (bool success);

    function balanceOf(address _owner) external constant returns (uint balance);

}


contract Airdrop is Ownable {

    using SafeMath for uint;

    address public tokenAddr;

    event EtherTransfer(address beneficiary, uint amount);

    constructor(address _tokenAddr) public {
        tokenAddr = _tokenAddr;
    }

    function dropTokens(address[] _recipients, uint256[] _amount) public onlyOwner returns (bool) {

        require(_recipients.length == _amount.length);

        for (uint i = 0; i < _recipients.length; i++) {
            uint256 toSend = _amount[i] * 10**6;
            require(_recipients[i] != address(0));
            require(Token(tokenAddr).transfer(_recipients[i], toSend));
        }

        return true;
    }

    function updateTokenAddress(address newTokenAddr) public onlyOwner {

        tokenAddr = newTokenAddr;
    }

    function withdrawTokens(address beneficiary) public onlyOwner {

        require(Token(tokenAddr).transfer(beneficiary, Token(tokenAddr).balanceOf(this)));
    }

    function withdrawEther(address beneficiary) public onlyOwner {

        beneficiary.transfer(address(this).balance);
    }
  

}