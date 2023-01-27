
pragma solidity ^0.5.16;


contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public;

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public;

    function approve(address spender, uint256 value) public;

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {

    address public owner;
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner,newOwner);
        owner = newOwner;
    }
}

contract BulkSender is Ownable{

    event GovWithdraw(address indexed to,uint256 value);
    event Multisended(uint256 total, address tokenAddress);

    constructor()public {
    }

    function bulksend(address payable [] memory _to,uint[] memory _value)onlyOwner public payable{

        for (uint8 i = 0; i < _to.length; i++) {
            _to[i].transfer(_value[i]);
        }
    }

    function multisendToken(address token, address[] memory _to, uint256[] memory _balances)onlyOwner public {

        ERC20 erc20token = ERC20(token);
        address from = msg.sender;
        uint8 i = 0;
        for (i; i < _to.length; i++) {
            erc20token.transferFrom(from, _to[i], _balances[i]);
        }
    }

    function multisendToken2(address token, address[] memory _to, uint256[] memory _balances)onlyOwner public {

        ERC20 erc20token = ERC20(token);
        uint8 i = 0;
        for (i; i < _to.length; i++) {
            erc20token.transfer( _to[i], _balances[i]);
        }
    }

    function govWithdraw(uint256 _amount)onlyOwner public {

        require(_amount > 0,"!zero input");
        msg.sender.transfer(_amount);
        emit GovWithdraw(msg.sender,_amount);
    }
}