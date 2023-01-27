
pragma solidity ^0.5.0;


interface TokenInterface {

    function totalSupply() external view returns (uint);

    function balanceOf(address tokenOwner) external view returns (uint balance);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

    function transfer(address to, uint tokens) external returns (bool success);

    function approve(address spender, uint tokens) external returns (bool success);

    function transferFrom(address from, address to, uint tokens) external returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


contract TellorCommunitySale{

    using SafeMath for uint256;

    uint public tribPrice;
    uint public endDate;
    uint public saleAmount;
    address public tellorAddress;
    address payable public owner;
    TokenInterface tellor;

    mapping(address => uint) saleByAddress;

    event NewPrice(uint _price);
    event NewAddress(address _newAddress, uint _amount);
    event NewSale(address _buyer,uint _amount);


    constructor(address _Tellor) public {
        owner = msg.sender;
        endDate = now + 7 days;
        tellorAddress = _Tellor;
        tellor = TokenInterface(_Tellor);
    }


    function setPrice(uint _price) external {

        require(msg.sender == owner);
        tribPrice = _price;
        emit NewPrice(_price);
    }


    function enterAddress(address _address, uint _amount) external {

        require(msg.sender == owner);
        require(checkThisAddressTokens()/1e18 >= saleAmount.add(_amount));
        saleAmount += _amount;
        saleByAddress[_address] += _amount;
        emit NewAddress(_address,_amount);
    }


    function withdrawTokens() external{

        require(msg.sender == owner);
        require(now > endDate);
        tellor.transfer(owner,tellor.balanceOf(address(this)));
    }


    function withdrawETH() external{

        require(msg.sender == owner);
        address(owner).transfer(address(this).balance);
    }
    

    function () external payable{
        require (saleByAddress[msg.sender] > 0);
        require(msg.value >= tribPrice.mul(saleByAddress[msg.sender]));//are decimals an issue?
        tellor.transfer(msg.sender,saleByAddress[msg.sender]*1e18); 
        emit NewSale(msg.sender,saleByAddress[msg.sender]);
        saleByAddress[msg.sender] = 0;
    }    



    function getSaleByAddress(address _address) external view returns(uint){

        return saleByAddress[_address];
    }


    function checkThisAddressTokens() public view returns(uint){

        return tellor.balanceOf(address(this));
    }


    function priceForUserTokens(address _address) public view returns(uint){

        return tribPrice.mul(saleByAddress[_address]);
    }
}