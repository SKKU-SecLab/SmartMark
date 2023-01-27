pragma solidity ^0.5.10;

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

        require(b > 0);
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
}pragma solidity ^0.5.10;


contract ERC20
{

    function balanceOf(address _who) view public returns (uint256) {}

    function transfer(address _to, uint256 _value) public returns (bool) {}
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {}

    function allowance(address _owner, address _spender) view external returns (uint256) {}
}

contract NestreeDropTest
{

    using SafeMath for uint256;

    address public _self;
    address public _owner;

    mapping (address => ERC20) public tokens;

    event Drop(address _tokenAddress, address[] _toList, uint256[] _amountList);

    constructor() public
    {
        _self = address(this);
        _owner = msg.sender;
    }

    function balanceOf(address _tokenAddress) public view returns (uint256)
    {

        ERC20 token = ERC20(_tokenAddress);
        return token.allowance(msg.sender, _self);
    }

    function drop(address _tokenAddress, address[] calldata _toList, uint256[] calldata _amountList) external returns (bool)
    {

        require(_tokenAddress != address(0), 'Token address is not valid');
        require(msg.sender == _owner, 'Not Owner');
        require(_toList.length == _amountList.length, 'Not valid list length');

        ERC20 token = ERC20(_tokenAddress);

        uint256 sumOfBalances = 0;
        for(uint256 i=0; i<_amountList.length; i++)
        {
            sumOfBalances = sumOfBalances.add(_amountList[i]);
        }

        uint256 balance = balanceOf(_tokenAddress);

        require(balance >= sumOfBalances);

        for(uint256 i=0; i<_toList.length; i++)
        {
            token.transferFrom(msg.sender, _toList[i], _amountList[i]);
        }

        emit Drop(_tokenAddress, _toList, _amountList);

        return true;
    }
}