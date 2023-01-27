
pragma solidity 0.6.11;

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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}

contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor() public {
    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

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

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IUniswapV2Router {

  function WETH() external pure returns (address);


  function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
  ) external returns (uint[] memory amounts);

  
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}

contract ConstantReturnStaking_BuyBack is Ownable {

    using Address for address;
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    
    event RewardsTransferred(address indexed holder, uint amount);
    event DepositTokenAdded(address indexed tokenAddress);
    event DepositTokenRemoved(address indexed tokenAddress);
    event Stake(address indexed holder, uint amount);
    event Unstake(address indexed holder, uint amount);
    
    event EmergencyDeclared(address indexed owner);
    
    
    address public constant TRUSTED_TOKEN_ADDRESS = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    
    uint public constant REWARD_RATE_X_100 = 34e2;
    uint public constant REWARD_INTERVAL = 120 days;
    
    uint public LOCKUP_TIME = 60 days;
    
    uint public constant ADMIN_CAN_CLAIM_AFTER = 130 days;
    
    uint public constant EMERGENCY_WAIT_TIME = 3 days;
    
    IUniswapV2Router public constant uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
    
    
    uint public totalClaimedRewards = 0;
    uint public totalDepositedTokens;
    bool public isEmergency = false;
    
    uint public immutable contractStartTime;
    
    modifier noContractsAllowed() {

        require(tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    modifier notDuringEmergency() {

        require(!isEmergency, "Cannot execute during emergency!");
        _;
    }
    
    function declareEmergency() external onlyOwner notDuringEmergency {

        isEmergency = true;
        adminClaimableTime = now.add(EMERGENCY_WAIT_TIME);
        LOCKUP_TIME = 0;
        
        uint contractBalance = IERC20(TRUSTED_TOKEN_ADDRESS).balanceOf(address(this));
        uint adminBalance = 0;
        
        if (contractBalance >= totalDepositedTokens) {
            adminBalance = contractBalance.sub(totalDepositedTokens);
        }
        if (adminBalance > 0) {
            IERC20(TRUSTED_TOKEN_ADDRESS).safeTransfer(owner, adminBalance);
        }
        
        emit EmergencyDeclared(owner);
    }
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    
    mapping (address => uint) public rewardsPendingClaim;
    
    uint public adminClaimableTime;
    
    constructor() public {
        contractStartTime = now;
        adminClaimableTime = now.add(ADMIN_CAN_CLAIM_AFTER);
    }
    
    mapping (address => bool) public trustedDepositTokens;
    function addTrustedDepositToken(address _tokenAddress) external onlyOwner {

        require(_tokenAddress != address(0), "Cannot add 0 address!");
        require(_tokenAddress != TRUSTED_TOKEN_ADDRESS, "Cannot add reward token as deposit token!");
        trustedDepositTokens[_tokenAddress] = true;
        emit DepositTokenAdded(_tokenAddress);
    }
    function removeTrustedDepositToken(address _tokenAddress) external onlyOwner {

        trustedDepositTokens[_tokenAddress] = false;
        emit DepositTokenRemoved(_tokenAddress);
    }
    
    
    function updateAccount(address account) private {

        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            
            uint amount = pendingDivs;
            
            rewardsPendingClaim[account] = rewardsPendingClaim[account].add(amount);
            totalEarnedTokens[account] = totalEarnedTokens[account].add(amount);
            
            totalClaimedRewards = totalClaimedRewards.add(amount);
            
        }
        lastClaimedTime[account] = now;
    }
    
    function getPendingDivs(address _holder) public view returns (uint) {

        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        
        uint timeDiff;
        uint stakingEndTime = contractStartTime.add(REWARD_INTERVAL);
        uint _now = now;
        if (_now > stakingEndTime) {
            _now = stakingEndTime;
        }
        
        if (lastClaimedTime[_holder] >= _now) {
            timeDiff = 0;
        } else {
            timeDiff = _now.sub(lastClaimedTime[_holder]);
        }

        uint stakedAmount = depositedTokens[_holder];
        
        uint pendingDivs = stakedAmount
                            .mul(REWARD_RATE_X_100)
                            .mul(timeDiff)
                            .div(REWARD_INTERVAL)
                            .div(1e4);
            
        return pendingDivs;
    }
    
    function getTotalPendingDivs(address _holder) external view returns (uint) {

        uint pending = getPendingDivs(_holder);
        uint awaitingClaim = rewardsPendingClaim[_holder];
        return pending.add(awaitingClaim);
    }
    
    function getNumberOfHolders() external view returns (uint) {

        return holders.length();
    }
    
    function stake(uint amountToDeposit, address depositToken, uint _amountOutMin, uint _deadline) external noContractsAllowed notDuringEmergency {

        require(amountToDeposit > 0, "Cannot deposit 0 Tokens!");
        require(depositToken != address(0), "Deposit Token Cannot be 0!");
        require(depositToken != TRUSTED_TOKEN_ADDRESS, "Deposit token cannot be same as reward token!");
        require(trustedDepositTokens[depositToken], "Deposit token not trusted yet!");
        IERC20(depositToken).safeTransferFrom(msg.sender, address(this), amountToDeposit);
        IERC20(depositToken).safeApprove(address(uniswapV2Router), 0);
        IERC20(depositToken).safeApprove(address(uniswapV2Router), amountToDeposit);
        
        uint oldPlatformTokenBalance = IERC20(TRUSTED_TOKEN_ADDRESS).balanceOf(address(this));
        
        address[] memory path;
        
        if (depositToken == uniswapV2Router.WETH()) {
            path = new address[](2);
            path[0] = depositToken;
            path[1] = TRUSTED_TOKEN_ADDRESS;
        } else {
            path = new address[](3);
            path[0] = depositToken;
            path[1] = uniswapV2Router.WETH();
            path[2] = TRUSTED_TOKEN_ADDRESS;
        }
        
        uniswapV2Router.swapExactTokensForTokens(amountToDeposit, _amountOutMin, path, address(this), _deadline);
        
        uint newPlatformTokenBalance = IERC20(TRUSTED_TOKEN_ADDRESS).balanceOf(address(this));
        uint platformTokensReceived = newPlatformTokenBalance.sub(oldPlatformTokenBalance);
        uint amountToStake = platformTokensReceived;
        
        require(amountToStake > 0, "Cannot stake 0 Tokens");
        
        updateAccount(msg.sender);
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToStake);
        totalDepositedTokens = totalDepositedTokens.add(amountToStake);
        
        holders.add(msg.sender);
        
        stakingTime[msg.sender] = now;
        emit Stake(msg.sender, amountToStake);
    }
    
    function unstake(uint amountToWithdraw) external noContractsAllowed {

        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(stakingTime[msg.sender]) > LOCKUP_TIME, "You recently staked, please wait before withdrawing.");
        
        updateAccount(msg.sender);
        
        require(IERC20(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        if (totalDepositedTokens >= amountToWithdraw) {
            totalDepositedTokens = totalDepositedTokens.sub(amountToWithdraw);
        }
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
        emit Unstake(msg.sender, amountToWithdraw);
    }
    
    function emergencyUnstake(uint amountToWithdraw) external noContractsAllowed {

        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(stakingTime[msg.sender]) > LOCKUP_TIME, "You recently staked, please wait before withdrawing.");
        
        lastClaimedTime[msg.sender] = now;
        
        require(IERC20(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        if (totalDepositedTokens >= amountToWithdraw) {
            totalDepositedTokens = totalDepositedTokens.sub(amountToWithdraw);
        }
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
        emit Unstake(msg.sender, amountToWithdraw);
    }
    
    function claim() external noContractsAllowed notDuringEmergency {

        updateAccount(msg.sender);
        uint amount = rewardsPendingClaim[msg.sender];
        if (amount > 0) {
            rewardsPendingClaim[msg.sender] = 0;
            require(IERC20(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amount), "Could not transfer earned tokens.");  
            emit RewardsTransferred(msg.sender, amount);
        }
    }
    
    function getStakersList(uint startIndex, uint endIndex) 
        public 
        view 
        returns (address[] memory stakers, 
            uint[] memory stakingTimestamps, 
            uint[] memory lastClaimedTimeStamps,
            uint[] memory stakedTokens) {

        require (startIndex < endIndex);
        
        uint length = endIndex.sub(startIndex);
        address[] memory _stakers = new address[](length);
        uint[] memory _stakingTimestamps = new uint[](length);
        uint[] memory _lastClaimedTimeStamps = new uint[](length);
        uint[] memory _stakedTokens = new uint[](length);
        
        for (uint i = startIndex; i < endIndex; i = i.add(1)) {
            address staker = holders.at(i);
            uint listIndex = i.sub(startIndex);
            _stakers[listIndex] = staker;
            _stakingTimestamps[listIndex] = stakingTime[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTime[staker];
            _stakedTokens[listIndex] = depositedTokens[staker];
        }
        
        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }
    
    function claimAnyToken(address token, uint amount) external onlyOwner {

        require(now > adminClaimableTime, "Contract not expired yet!");
        if (token == address(0)) {
            msg.sender.transfer(amount);
            return;
        }
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}