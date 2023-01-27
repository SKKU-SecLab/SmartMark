
pragma solidity 0.6.12;

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
}// MIT

pragma solidity 0.6.12;

interface IX2Market {

    function bullToken() external view returns (address);

    function bearToken() external view returns (address);

    function latestPrice() external view returns (uint256);

    function getDivisor(address token) external view returns (uint256);

    function cachedDivisors(address token) external view returns (uint256);

    function collateralToken() external view returns (address);

    function deposit(address token, address receiver, bool withFeeSubsidy) external returns (uint256);

    function withdraw(address token, uint256 amount, address receiver, bool withFeeSubsidy) external returns (uint256);

    function rebase() external returns (bool);

}// MIT

pragma solidity 0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity 0.6.12;


contract X2Reader {

    using SafeMath for uint256;

    function getMarketInfo(address _market, address _account) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        address bullToken = IX2Market(_market).bullToken();
        address bearToken = IX2Market(_market).bearToken();

        return (
            _account.balance, // index: 0
            IX2Market(_market).latestPrice(), // index: 1
            IERC20(bullToken).totalSupply(), // index: 2
            IERC20(bearToken).totalSupply(), // index: 3
            IERC20(bullToken).balanceOf(_account), // index: 4
            IERC20(bearToken).balanceOf(_account) // index: 5
        );
    }

    function getTokenInfo(address _market, address _router, address _account) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        address bullToken = IX2Market(_market).bullToken();
        address bearToken = IX2Market(_market).bearToken();

        uint256 bullAllowance = IERC20(bullToken).allowance(_account, _router);
        uint256 bearAllowance = IERC20(bearToken).allowance(_account, _router);

        return(
            IX2Market(_market).cachedDivisors(bullToken), // index: 0
            IX2Market(_market).cachedDivisors(bearToken), // index: 1
            IX2Market(_market).getDivisor(bullToken), // index: 2
            IX2Market(_market).getDivisor(bearToken), // index: 3
            bullAllowance, // index: 4
            bearAllowance // index: 5
        );
    }
}