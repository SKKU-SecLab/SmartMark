


pragma solidity ^0.5.2;





library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {



        require(address(token).isContract());

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}



pragma solidity ^0.5.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}



pragma solidity ^0.5.2;

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
}


pragma solidity ^0.5.2;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity 0.5.17;





contract TokenVesting {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(uint256 mTokensAmount, uint256 sTokensAmount);

    address private _beneficiary;

    uint256 private _cliff;
    uint256 private _start;
    uint256 private _duration;

    address public mainToken;
    
    address public secondaryToken;
    
    uint256 public multiplier;
    
    address public factory;
    
    uint256 public totalVestingAmount;
    
    mapping (address => uint256) private _released;
    
    
    constructor (address beneficiary, uint256 amount, uint256 start, uint256 cliffDuration, uint256 duration, address _mainToken, address _secondaryToken, uint256 _multipier) public {
        require(beneficiary != address(0));
        require(cliffDuration <= duration);
        require(duration > 0);
        require(start.add(duration) > block.timestamp);

        _beneficiary = beneficiary;
        _duration = duration;
        _cliff = start.add(cliffDuration);
        _start = start;
        mainToken = _mainToken;
        secondaryToken = _secondaryToken;
        multiplier = _multipier;
        factory = msg.sender;
        totalVestingAmount = amount;
    }

    function beneficiary() public view returns (address) {

        return _beneficiary;
    }

    function cliff() public view returns (uint256) {

        return _cliff;
    }

    function start() public view returns (uint256) {

        return _start;
    }

    function duration() public view returns (uint256) {

        return _duration;
    }
    
    function available() public view returns (uint256) {

        return totalVestingAmount.sub(_released[mainToken]);
    }
    
    function released(address token) public view returns (uint256) {

        return (_released[token]);
    }
    
    function _accruedAmount() public view returns (uint256) {

        return _releasableAmount().mul(multiplier).div(10000);
    }
  
 
    function release() public {

        uint256 unreleased = _releasableAmount();
        

        require(unreleased > 0);
        
        uint256 sTokensToRelease = unreleased.mul(multiplier).div(10000);

        _released[mainToken] = _released[mainToken].add(unreleased);
        _released[secondaryToken] = _released[secondaryToken].add(sTokensToRelease);


        IERC20(mainToken).safeTransfer(_beneficiary, unreleased);
        IERC20(secondaryToken).safeTransferFrom(factory, _beneficiary, sTokensToRelease);

        emit TokensReleased(unreleased, sTokensToRelease);
    }

    function _releasableAmount() private view returns (uint256) {

        return _vestedAmount().sub(_released[mainToken]);
    }
    

    function _vestedAmount() private view returns (uint256) {

       

        if (block.timestamp < _cliff) {
            return 0;
        } else if (block.timestamp >= _start.add(_duration)) {
            return totalVestingAmount;
        } else {
            return totalVestingAmount.mul(block.timestamp.sub(_start)).div(_duration);
        }
    }
}

pragma solidity 0.5.17;






contract VestingFactory {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    uint256 public cliffTime;
    
    uint256 public duration;
    
    uint256 public multipier;
    
    address public mainToken;
    
    address public secondaryToken;
    
    
    uint256 public maxVesting;
    
    uint256 public currentVestedAmount;
    
    mapping(address => address[]) public userVsVesting;
    
    event Vested(address indexed user, address indexed vestingContract);
    
    constructor(
        uint256 _cliffTime,
        uint256 _duration,
        uint256 _multipier,
        address _mainToken,
        address _secondaryToken,
        uint256 _maxVesting
    )
        public
    {
        cliffTime = _cliffTime;
        duration = _duration;
        multipier = _multipier;
        mainToken = _mainToken;
        secondaryToken = _secondaryToken;
        maxVesting = _maxVesting;
    }
    
    function vest(uint256 amount) external {

        
        require(currentVestedAmount.add(amount) <= maxVesting, "Breaching max vesting limit");
        currentVestedAmount = currentVestedAmount.add(amount);
        uint256 cliff = 0;
        
        if (cliffTime > block.timestamp) {
            cliff = cliffTime.sub(block.timestamp);
        }
        
        
        TokenVesting vesting = new TokenVesting(
            msg.sender,
            amount,
            block.timestamp,
            cliff,
            duration,
            mainToken,
            secondaryToken,
            multipier
        );
        
        userVsVesting[msg.sender].push(address(vesting));
        IERC20(mainToken).safeTransferFrom(msg.sender, address(vesting), amount);
        IERC20(secondaryToken).safeApprove(address(vesting), amount.mul(multipier).div(10000));
        
        emit Vested(msg.sender, address(vesting));
        
    }
    
    function userContracts(address user) public view returns(address[] memory){

        return userVsVesting[user];
    }
    
    function accruedAmount(address user) public view returns(uint256){

        uint256 amount = 0;
        for(uint i=0; i<userVsVesting[user].length;i++){
           amount = amount.add(TokenVesting(userVsVesting[user][i])._accruedAmount()); 
        }
        return amount;
    }
    
    function mainTokenBalance(address user) public view returns(uint256){

        uint256 amount = 0;
        for(uint i=0; i<userVsVesting[user].length;i++){
           amount = amount.add(TokenVesting(userVsVesting[user][i]).available()); 
        }
        return amount;
    }
    
}