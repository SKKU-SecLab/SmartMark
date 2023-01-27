
pragma solidity 0.4.23;

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

contract SuterToken {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

}

contract SuterLock {

    using SafeMath for uint256;

    SuterToken public token;

    address public admin_address = 0x0713591DBdA93C1E5F407aBEF044a0FaF9F2f212; 
    uint256 public user_release_time = 1665331200; // 2022/10/10 0:0:0 UTC+8
    uint256 public contract_release_time = 1625068800; // 2021/7/1 0:0:0 UTC+8
    uint256 public release_ratio = 278;
    uint256 ratio_base = 100000;
    uint256 public amount_per_day = 4104000 ether;
    uint256 day_time = 86400; // Seconds of one day.
    uint256 public day_amount = 360;
    uint256 public start_time;
    uint256 public releasedAmount;
    uint256 public user_lock_amount;
    uint256 public contract_lock_amount;
    uint256 valid_amount;
 
    mapping(address => uint256) public lockedAmount;
    event LockToken(address indexed target, uint256 amount);
    event ReleaseToken(address indexed target, uint256 amount); 

    constructor() public {
        token = SuterToken(0xBA8c0244FBDEB10f19f6738750dAeEDF7a5081eb);
        start_time = now;
        valid_amount = (contract_release_time.sub(start_time)).div(day_time).mul(amount_per_day);
    }

    function lockToken(address _target, uint256 _amount) public admin_only {

        require(_target != address(0), "target is a zero address");
        require(now < user_release_time, "Current time is greater than lock time");
        if (contract_lock_amount == 0) {
            uint256 num = (now.sub(start_time)).div(day_time).mul(amount_per_day);
            if (num > valid_amount) {
                num = valid_amount;
            }
            require(token.balanceOf(address(this)).sub(num).sub(user_lock_amount) >= _amount, "Not enough balance");
        } else {
            require(token.balanceOf(address(this)).add(releasedAmount).sub(contract_lock_amount).sub(user_lock_amount) >= _amount, "Not enough balance");
        }
        lockedAmount[_target] = lockedAmount[_target].add(_amount);
        user_lock_amount = user_lock_amount.add(_amount);
        emit LockToken(_target, _amount);
    }

    function releaseTokenToUser(address _target) public {

        uint256 releasable_amount = releasableAmountOfUser(_target);
        if (releasable_amount == 0) {
            return;
        } else {
            token.transfer(_target, releasable_amount);
            emit ReleaseToken(_target, releasable_amount);
            lockedAmount[_target] = 0;
            user_lock_amount = user_lock_amount.sub(releasable_amount);
        }
    }

    function releaseTokenToAdmin() public admin_only {

        require(now > contract_release_time, "Release time not reached");
        if(contract_lock_amount == 0) {
            contract_lock_amount = token.balanceOf(address(this)).sub(user_lock_amount);
            if (contract_lock_amount > valid_amount) {
                contract_lock_amount = valid_amount;
            }
        }
        uint256 amount = releasableAmountOfContract();
        require(token.transfer(msg.sender, amount));
        releasedAmount = releasedAmount.add(amount);
        emit ReleaseToken(msg.sender, amount);
    }

    function withdrawSuter() public admin_only {

        require(contract_lock_amount > 0, "The number of token releases has not been determined");
        uint256 lockAmount_ = user_lock_amount.add(contract_lock_amount).sub(releasedAmount); // The amount of tokens locked.
        uint256 remainingAmount_ =  token.balanceOf(address(this)).sub(lockAmount_); // The amount of extra tokens in the contract.
        require(remainingAmount_ > 0, "No extra tokens");
        require(token.transfer(msg.sender, remainingAmount_));
    }

    modifier admin_only() {

        require(msg.sender==admin_address);
        _;
    }

    function setAdmin( address new_admin_address ) public admin_only returns (bool) {

        require(new_admin_address != address(0), "New admin is a zero address");
        admin_address = new_admin_address;
        return true;
    }

    function withDraw() public admin_only {

        require(address(this).balance > 0, "Contract eth balance is 0");
        admin_address.transfer(address(this).balance);
    }

    function () external payable {    

    }

    function releasableAmountOfUser(address _target) public view returns (uint256) {

        if(now < user_release_time) {
            return 0;
        } else {
            return lockedAmount[_target];
        }
    }

    function releasableAmountOfContract() public view returns (uint256) {

        if(now < contract_release_time) {
            return 0;
        } else {
            uint256 num = contract_lock_amount;
            if (contract_lock_amount == 0) {
                num = token.balanceOf(address(this)).sub(user_lock_amount);
                if (num > valid_amount) {
                    num = valid_amount;
                }
            }
            uint256 _days =(now.sub(contract_release_time)).div(day_time);
            uint256 _amount = num.mul(release_ratio).mul(_days).div(ratio_base);
            if (_amount > num) {
                _amount = num;
            }
            return _amount.sub(releasedAmount);
        }
    }

    function getContractLockAmount() public view returns(uint256 num2) {

        if (contract_lock_amount == 0) {
            uint256 num1 = (now.sub(start_time)).div(day_time).mul(amount_per_day);
            num2 = token.balanceOf(address(this)).sub(user_lock_amount);
            if (num2 > num1) {
                num2 = num1;
            } 
        } else {
            num2 = contract_lock_amount;
        }
    }
}