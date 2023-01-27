
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function burnFuel(uint256 amount) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// UNLICENSED

pragma solidity ^0.7.0;


contract GraphLinqDepositor {

    using SafeMath for uint256;

    address private _graphLinkContract;
    mapping (address => uint256) _balances;
    address private _engineManager;

    constructor(address engineManager, address graphLinqContract) {
        _engineManager = engineManager;
        _graphLinkContract = graphLinqContract;
    }

    function burnAmount(uint256 amount) public {

        IERC20 graphLinqToken = IERC20(address(_graphLinkContract));
         require (
            msg.sender == _engineManager,
            "Only the GraphLinq engine manager can decide which funds should be burned for graph costs."
        );
        require(
            graphLinqToken.balanceOf(address(this)) >= amount, 
            "Invalid fund in the depositor contract, cant reach the contract balance amount."
        );
        graphLinqToken.burnFuel(amount);
    }

    function burnBalance(address fromWallet, uint256 amount) public {

        IERC20 graphLinqToken = IERC20(address(_graphLinkContract));
        require (
            msg.sender == _engineManager,
            "Only the GraphLinq engine manager can decide which funds should be burned for graph costs."
        );

        require (_balances[fromWallet] >= amount,
            "Invalid amount to withdraw, amount is higher then current wallet balance."
        );

        require(
            graphLinqToken.balanceOf(address(this)) >= amount, 
            "Invalid fund in the depositor contract, cant reach the contract balance amount."
        );

        graphLinqToken.burnFuel(amount);
        _balances[fromWallet] -= amount;
    }

    function withdrawWalletBalance(address walletOwner, uint256 amount,
     uint256 removeFees) public {

        IERC20 graphLinqToken = IERC20(address(_graphLinkContract));

        require (
            msg.sender == _engineManager,
            "Only the GraphLinq engine manager can decide which funds are withdrawable or not."
        );

        uint256 summedAmount = amount.add(removeFees);
        require (_balances[walletOwner] >= summedAmount,
            "Invalid amount to withdraw, amount is higher then current wallet balance."
        );

        require(
            graphLinqToken.balanceOf(address(this)) >= summedAmount, 
            "Invalid fund in the depositor contract, cant reach the wallet balance amount."
        );

        _balances[walletOwner] -= amount;
        require(
            graphLinqToken.transfer(walletOwner, amount),
            "Error transfering balance back to his owner from the depositor contract."
        );
        
        if (removeFees > 0) {
            graphLinqToken.burnFuel(removeFees);
            _balances[walletOwner] -= removeFees;
        }
    }

    function addBalance(uint256 amount) public {

         IERC20 graphLinqToken = IERC20(address(_graphLinkContract));

         require(
             graphLinqToken.balanceOf(msg.sender) >= amount,
             "Invalid balance to add in your credits"
         );

         require(
             graphLinqToken.transferFrom(msg.sender, address(this), amount) == true,
             "Error while trying to add credit to your balance, please check allowance."
         );

         _balances[msg.sender] += amount;
    }

    function getBalance(address from) public view returns(uint256) {

        return _balances[from];
    }
}