


pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}




pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity >=0.6.0 <0.8.0;



contract DMODCommunity {

    using SafeMath for uint256;

    IERC20 private _token;

    address private _beneficiary;

    uint256 public totalBalance;
    struct VestPeriodInfo {
        uint256 releaseTime;
        uint256 percent;
        bool released;
    }
    VestPeriodInfo[] public vestPeriodInfoArray;

    uint256 constant PRECISION = 10**25;
    uint256 constant PERCENT = 100 * PRECISION;

    constructor(
        IERC20 token_,
        address beneficiary_,
        uint256[] memory releaseTimes_,
        uint256[] memory percents_,
        uint256 totalBalance_
    ) public {
        require(
            percents_.length == releaseTimes_.length,
            "DMODCommunity: there should be equal percents and release times values"
        );
        require(
            beneficiary_ != address(0),
            "DMODCommunity: beneficiary address should not be zero address"
        );
        require(
            address(token_) != address(0),
            "DMODCommunity: token address should not be zero address"
        );

        _token = token_;
        for (uint256 i = 0; i < releaseTimes_.length; i++) {
            vestPeriodInfoArray.push(
                VestPeriodInfo({
                    percent: percents_[i],
                    releaseTime: releaseTimes_[i],
                    released: false
                })
            );
        }
        _beneficiary = beneficiary_;
        totalBalance = totalBalance_;
    }

    function token() public view virtual returns (IERC20) {

        return _token;
    }

    function beneficiary() public view virtual returns (address) {

        return _beneficiary;
    }

    function releaseTime(uint256 index) public view virtual returns (uint256) {

        return vestPeriodInfoArray[index].releaseTime;
    }

    function releasePercent(uint256 index)
        public
        view
        virtual
        returns (uint256)
    {

        return vestPeriodInfoArray[index].percent;
    }

    function release() public virtual {

        uint256 amount;
        for (uint256 i = 0; i < vestPeriodInfoArray.length; i++) {
            VestPeriodInfo memory vestPeriodInfo = vestPeriodInfoArray[i];
            if (vestPeriodInfo.releaseTime < block.timestamp) {
                if (!vestPeriodInfo.released) {
                    vestPeriodInfoArray[i].released = true;
                    amount = amount.add(
                        vestPeriodInfo
                            .percent
                            .mul(PRECISION)
                            .mul(totalBalance)
                            .div(PERCENT)
                    );
                }
            } else {
                break;
            }
        }
        require(amount > 0, "TokenTimelock: no tokens to release");
        token().transfer(_beneficiary, amount);
    }
}