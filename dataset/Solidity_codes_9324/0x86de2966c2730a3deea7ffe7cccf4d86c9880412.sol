
pragma solidity ^0.5.0;


contract ERC20Interface {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


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

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract BVAFounders {

    using SafeMath for uint;

    ERC20Interface erc20Contract;
    address payable owner;


    modifier isOwner() {

        require(msg.sender == owner, "must be contract owner");
        _;
    }


    constructor(ERC20Interface ctr) public {
        erc20Contract = ctr;
        owner         = msg.sender;
    }


    function unlockTokens(address to) external isOwner {


        require(now >= 1606752000, "locked");

        uint balance = erc20Contract.balanceOf(address(this));
        uint amount;
        uint remain;

        if (now < 1638288000) {
            require(balance >= 1260000e18, "checkpoint 1 balance error");
            remain = 945000e18;
            amount = balance.sub(remain);
        } else if (now < 1669824000) {
            require(balance >= 945000e18, "checkpoint 2 balance error");
            remain = 630000e18;
            amount = balance.sub(remain);
        } else if (now < 1701360000) {
            require(balance >= 630000e18, "checkpoint 3 balance error");
            remain = 441000e18;
            amount = balance.sub(remain);
        } else if (now < 1732982400) {
            require(balance >= 441000e18, "checkpoint 4 balance error");
            remain = 252000e18;
            amount = balance.sub(remain);
        } else if (now < 1764518400) {
            require(balance >= 252000e18, "checkpoint 5 balance error");
            remain = 126000e18;
            amount = balance.sub(remain);
        } else {
            amount = balance;
        }

        if (amount > 0) {
            erc20Contract.transfer(to, amount);
        }
    }


    function withdrawEther(uint _amount) external isOwner {

        owner.transfer(_amount);
    }


    function () external payable {
    }
}