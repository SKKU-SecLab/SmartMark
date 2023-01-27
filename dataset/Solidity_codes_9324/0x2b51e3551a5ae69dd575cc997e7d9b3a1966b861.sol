


pragma solidity ^0.5.0;

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

pragma solidity ^0.5.0;


contract AirDropETH{


    using SafeMath for uint256;
    
    modifier validAddress( address addr ) {

        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }
    
    function airDrop(address payable[]  memory tos,  uint256[] memory vs)
        payable
        public {


        require(tos.length > 0);
        require(vs.length > 0);
        require(tos.length == vs.length);
        uint256 total = 0;
        for(uint256 i = 0 ; i < tos.length; i++){
            tos[i].transfer(vs[i]);
            total = total.add(vs[i]);
            
        }
        uint256 renback = msg.value.sub(total);
        msg.sender.transfer(renback);
    }
    
    
    function resizeEth() public {

        uint256 balance =  address(this).balance;
        msg.sender.transfer(balance);
    }
}