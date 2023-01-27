
pragma solidity 0.5.17;


interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

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

contract EasyVesting {

        using SafeMath for uint256;
        
        address public beneficiary;//Address who will receive tokens
        uint256 public released;//Amount of tokens released so far
        address public token;//EASY token address
        
        uint256[] public timeperiods;// List of dates(in unix timestamp) on which tokens will be released
        uint256[] public tokenAmounts;// Number of tokens to be released after each dates
        
        uint256 public periodsReleased;//Total number of periods released
        
        event Released(uint256 amount, uint256 indexed releaseNumber);
        
        constructor(uint256[] memory periods, uint256[] memory tokenAmounts_, address beneficiary_, address token_) public {
            for(uint256 i = 0; i < periods.length; i++) {
                timeperiods.push(periods[i]);
                tokenAmounts.push(tokenAmounts_[i]);
            }
            beneficiary = beneficiary_;
            token = token_;
        }
        
        function release() external {

            require(periodsReleased < timeperiods.length, "Nothing to release");
            uint256 amount = 0;
            for (uint256 i = periodsReleased; i < timeperiods.length; i++) {
                if (timeperiods[i] <= block.timestamp) {
                    amount = amount.add(tokenAmounts[i]);
                    periodsReleased = periodsReleased.add(1);
                }
                else {
                    break;
                }
            }
            if(amount > 0) {
                IERC20(token).transfer(beneficiary, amount);
                emit Released(amount, periodsReleased);
            }
            
        }
}