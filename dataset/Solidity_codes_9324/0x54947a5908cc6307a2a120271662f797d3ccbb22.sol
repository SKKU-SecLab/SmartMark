

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    
    function decimals() external view returns (uint8);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _governance;

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _governance = msgSender;
        emit GovernanceTransferred(address(0), msgSender);
    }

    function governance() public view returns (address) {

        return _governance;
    }

    modifier onlyGovernance() {

        require(_governance == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferGovernance(address newOwner) internal virtual onlyGovernance {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit GovernanceTransferred(_governance, newOwner);
        _governance = newOwner;
    }
}


pragma solidity ^0.6.6;


interface WrappedEther {

    function withdraw(uint) external; 

}

interface PickleJar {

    function getRatio() external view returns (uint256);

    function deposit(uint256) external;

    function withdraw(uint256) external;

    function withdrawAll() external;

}

interface PickleFarm {

    function deposit(uint256, uint256) external;

    function withdraw(uint256, uint256) external;

    function userInfo(uint256, address) external view returns (uint256, uint256);

}

interface PickleStake {

    function stake(uint256) external;

    function withdraw(uint256) external;

    function exit() external;

    function earned(address) external view returns (uint256);

    function getReward() external;

}

interface StabilizeStakingPool {

    function notifyRewardAmount(uint256) external;

}

contract StabilizeStrategyPickleDAIV1 is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public treasuryAddress; // Address of the treasury
    address public stakingAddress; // Address to the STBZ staking pool
    address public zsTokenAddress; // The address of the controlling zs-Token
    
    uint256 constant divisionFactor = 100000;
    uint256 public percentLPDepositor = 50000; // 1000 = 1%, depositors earn 50% of all WETH produced, 100% of everything else
    uint256 public percentStakers = 50000; // 50% of non-depositors WETH goes to stakers, can be changed
    
    address[] rewardTokenList;
    
    struct UserInfo {
        uint256 depositTime; // The time the user made the last deposit, token share is calculated from this
        uint256 balanceEstimate;
    }
    
    mapping(address => UserInfo) private userInfo;
    uint256 public weightedAverageDepositTime = 0; // Average time to enter
    
    uint256 private _totalBalancePTokens = 0; // The total amount of pTokens currently staked/stored in contract
    uint256 private _stakedPickle = 0; // The amount of pickles being staked
    address constant wethAddress = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant pickleAddress = address(0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5);
    address constant pJarAddress = address(0x6949Bb624E8e8A90F87cD2058139fcd77D2F3F87); // Pickle jar address / pToken address
    address constant pFarmAddress = address(0xbD17B1ce622d73bD438b9E658acA5996dc394b0d); // Pickle farming contract aka MasterChef
    address constant underlyingAddress = address(0x6B175474E89094C44Da98b954EedeAC495271d0F); // Address of the underlying token
    uint256 constant pTokenID = 16; // The location of the pToken in the pickle staking farm
    address constant pickleStakeAddress = address(0xa17a8883dA1aBd57c690DF9Ebf58fC194eDAb66F); // Pickle staking address
    uint256 constant minETH = 1000000000; // 0.000000001 ETH / 1 Gwei

    constructor(
        address _treasury,
        address _staking,
        address _zsToken
    ) public {
        treasuryAddress = _treasury;
        stakingAddress = _staking;
        zsTokenAddress = _zsToken;
        setupRewardTokens();
    }

    
    function setupRewardTokens() internal {

        rewardTokenList.push(underlyingAddress); // DAI token
        rewardTokenList.push(pickleAddress); // Picke token
        rewardTokenList.push(wethAddress); // Wrapped Ether token
    }
    
    modifier onlyZSToken() {

        require(zsTokenAddress == _msgSender(), "Call not sent from the zs-Token");
        _;
    }
    
    
    function rewardTokensCount() external view returns (uint256) {

        return rewardTokenList.length;
    }
    
    function rewardTokenAddress(uint256 _pos) external view returns (address) {

        require(_pos < rewardTokenList.length,"No token at that position");
        return rewardTokenList[_pos];
    }
    
    function balance() external view returns (uint256) {

        return _totalBalancePTokens;
    }
    
    function pricePerToken() external view returns (uint256) {

        return PickleJar(pJarAddress).getRatio();
    }
    
    
    function enter() external onlyZSToken {

        deposit(_msgSender());
    }
    
    function exit() external onlyZSToken {

        withdraw(_msgSender(),1,1);
    }
    
    function withdraw(address payable _depositor, uint256 _share, uint256 _total) public onlyZSToken returns (uint256) {

        require(_totalBalancePTokens > 0, "There are no LP tokens in this strategy");
        checkWETHAndPay(); // First check if we have unclaimed WETH and claim it
        
        bool _takeAll = false;
        if(_share == _total){
            _takeAll = true; // Remove everything to this user
        }
        
        uint256 pTokenAmount = _totalBalancePTokens;
        if(_takeAll == false){
            pTokenAmount = _totalBalancePTokens.mul(_share).div(_total);
        }else{
            (pTokenAmount, ) = PickleFarm(pFarmAddress).userInfo(pTokenID, address(this)); // Get the total amount at the farm
            _totalBalancePTokens = pTokenAmount;
        }
        
         _totalBalancePTokens = _totalBalancePTokens.sub(pTokenAmount);

        PickleFarm(pFarmAddress).withdraw(pTokenID, pTokenAmount); // This function also returns Pickle earned
        
        IERC20 _lpToken = IERC20(rewardTokenList[0]);
        uint256 lpWithdrawAmount = 0;
        if(_takeAll == false){
            uint256 _before = _lpToken.balanceOf(address(this));
            PickleJar(pJarAddress).withdraw(pTokenAmount);
            lpWithdrawAmount = _lpToken.balanceOf(address(this)).sub(_before);
        }else{
            PickleJar(pJarAddress).withdrawAll();
            lpWithdrawAmount = _lpToken.balanceOf(address(this)); // Get all LP tokens here
        }
        require(lpWithdrawAmount > 0,"Failed to withdraw from the Pickle Jar");

        transferAccessoryTokens(_depositor, _share, _total);
        
        if(_depositor != zsTokenAddress){
            if(pTokenAmount >= userInfo[_depositor].balanceEstimate){
                userInfo[_depositor].balanceEstimate = 0;
            }else{
                userInfo[_depositor].balanceEstimate = userInfo[_depositor].balanceEstimate.sub(pTokenAmount);
            }
            if(_takeAll == true){
                userInfo[_depositor].balanceEstimate = 0;
            }
        }
        
        _lpToken.safeTransfer(_depositor, lpWithdrawAmount);
        return lpWithdrawAmount;
    }
    
    function transferAccessoryTokens(address payable _depositor, uint256 _share, uint256 _total) internal {

        bool _takeAll = false;
        if(_share == _total){
            _takeAll = true;
        }
        if(_takeAll == false){
            
            uint256 exitTime = now;
            uint256 enterTime = userInfo[_depositor].depositTime;
            if(userInfo[_depositor].depositTime == 0){ // User has never deposited into the contract at this address
                enterTime = now; // No access to pickle or weth reward
            }else{
                if(_share > userInfo[_depositor].balanceEstimate){
                    _share = userInfo[_depositor].balanceEstimate; // The user has withdrawn more tokens than attributed to this address, put share to estimate
                }
            }
            uint256 numerator = exitTime.sub(enterTime);
            uint256 denominator = exitTime.sub(weightedAverageDepositTime);
            uint256 timeShare = 0;
            if(numerator > denominator){
                timeShare = divisionFactor; // 100%
            }else{
                if(denominator > 0){
                    timeShare = numerator.mul(divisionFactor).div(denominator);
                }else{
                    timeShare = 0;
                }
            }
            
            IERC20 _token = IERC20(pickleAddress);
            uint256 _tokenBalance = _token.balanceOf(address(this)); // Get balance of pickle in contract not staked
            uint256 tokenWithdrawAmount = _tokenBalance.add(_stakedPickle).mul(_share).div(_total); // First based on our share %
            tokenWithdrawAmount = tokenWithdrawAmount.mul(timeShare).div(divisionFactor); // Then on time in contract
            if(tokenWithdrawAmount > _tokenBalance){
                uint256 _removeAmount = tokenWithdrawAmount.sub(_tokenBalance);
                _stakedPickle = _stakedPickle.sub(_removeAmount);
                PickleStake(pickleStakeAddress).withdraw(_removeAmount);
            }
            if(tokenWithdrawAmount > 0){
                _token.safeTransfer(_depositor, tokenWithdrawAmount);
            }
            
            _token = IERC20(wethAddress);
            _tokenBalance = _token.balanceOf(address(this)); // Weth is just stored in this contract until removed
            tokenWithdrawAmount = _tokenBalance.mul(_share).div(_total); // First based on our share %
            tokenWithdrawAmount = tokenWithdrawAmount.mul(timeShare).div(divisionFactor); // Then on time in contract
            if(tokenWithdrawAmount > 0){
                WrappedEther(wethAddress).withdraw(tokenWithdrawAmount); // This will send ETH to this contract and burn WETH
                _depositor.transfer(tokenWithdrawAmount); // Transfer has low gas allocation, preventing re-entrancy
            }
        }else{
            if(_stakedPickle > 0){
                PickleStake(pickleStakeAddress).exit(); // Will pull all pickle and all WETH (should be near empty)
                _stakedPickle = 0;
            }
            IERC20 _token = IERC20(pickleAddress);
            if( _token.balanceOf(address(this)) > 0){
                _token.safeTransfer(_depositor, _token.balanceOf(address(this)));
            }
            _token = IERC20(wethAddress);
            uint256 wethBalance = _token.balanceOf(address(this));
            if(wethBalance > 0){
                if(_depositor != zsTokenAddress){
                    WrappedEther(wethAddress).withdraw(wethBalance); // This will send ETH to this contract and burn WETH
                    _depositor.transfer(wethBalance);
                }else{
                    _token.safeTransfer(_depositor, wethBalance);
                }                
            }
        }        
    }

    receive() external payable {
    }
    
    function deposit(address _depositor) public onlyZSToken {

        
        IERC20 _token = IERC20(rewardTokenList[0]);
        uint256 _lpBalance = _token.balanceOf(address(this));
        
        _token.safeApprove(pJarAddress ,_lpBalance); // Approve for transfer
        PickleJar(pJarAddress).deposit(_lpBalance); // Send the LP, get the pLP
        IERC20 _pToken = IERC20(pJarAddress);
        uint256 _pBalance = _pToken.balanceOf(address(this));
        require(_pBalance > 0,"Failed to get pTokens from the Pickle Jar");
        
        if(_depositor != zsTokenAddress){
            userInfo[_depositor].depositTime = now;
            userInfo[_depositor].balanceEstimate += _pBalance;
            
            weightedAverageDepositTime = weightedAverageDepositTime.mul(_totalBalancePTokens)
                                        .div(_pBalance.add(_totalBalancePTokens));
            
            weightedAverageDepositTime = userInfo[_depositor].depositTime.mul(_pBalance)
                                        .div(_pBalance.add(_totalBalancePTokens))
                                        .add(weightedAverageDepositTime);
        }else{
            if(weightedAverageDepositTime == 0){
                weightedAverageDepositTime = now;
            }
        }
        
        _pToken.safeApprove(pFarmAddress, _pBalance); // Approve for transfer
        PickleFarm(pFarmAddress).deposit(pTokenID, _pBalance); // This function also returns Pickle earned
        _totalBalancePTokens += _pBalance; // Add to our pTokens accounted for
        
        checkPickleAndStake();
        
        checkWETHAndPay();
    }
    
    function checkPickleAndStake() internal {

        IERC20 _pickle = IERC20(pickleAddress);
        uint256 _balance = _pickle.balanceOf(address(this));
        if(_balance > 0){
            _pickle.safeApprove(pickleStakeAddress, _balance);
            PickleStake(pickleStakeAddress).stake(_balance);
            _stakedPickle += _balance;
        }
    }
    
    function checkWETHAndPay() internal {

        uint256 _balance = PickleStake(pickleStakeAddress).earned(address(this)); // This will return the WETH earned balance
        if(_balance > minETH){
            IERC20 _token = IERC20(wethAddress);
            uint256 _before = _token.balanceOf(address(this));
            PickleStake(pickleStakeAddress).getReward(); // Pull the WETH from the staking address
            uint256 amount = _token.balanceOf(address(this)).sub(_before);
            require(amount > 0,"Pickle staking should have returned some WETH");
            uint256 depositorsAmount = amount.mul(percentLPDepositor).div(divisionFactor); // This amount remains in contract
            uint256 holdersAmount = amount.sub(depositorsAmount);
            uint256 stakersAmount = holdersAmount.mul(percentStakers).div(divisionFactor);
            uint256 treasuryAmount = holdersAmount.sub(stakersAmount);
            if(treasuryAmount > 0){
                _token.safeTransfer(treasuryAddress, treasuryAmount);
            }
            if(stakersAmount > 0){
                _token.safeTransfer(stakingAddress, stakersAmount);
                StabilizeStakingPool(stakingAddress).notifyRewardAmount(stakersAmount);
            }
        }
    }
    
    
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant _timelockDuration = 86400; // Timelock is 24 hours
    
    address private _timelock_address;
    uint256 private _timelock_data_1;
    
    modifier timelockConditionsMet(uint256 _type) {

        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        if(_totalBalancePTokens > 0){ // Timelock only applies when balance exists
            require(now >= _timelockStart + _timelockDuration, "Timelock time not met");
        }
        _;
    }
    
    function startGovernanceChange(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {

        transferGovernance(_timelock_address);
    }
    
    function startChangeTreasury(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 2;
        _timelock_address = _address;
    }
    
    function finishChangeTreasury() external onlyGovernance timelockConditionsMet(2) {

        treasuryAddress = _timelock_address;
    }
    
    function startChangeDepositorPercent(uint256 _percent) external onlyGovernance {

        require(_percent <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 3;
        _timelock_data_1 = _percent;
    }
    
    function finishChangeDepositorPercent() external onlyGovernance timelockConditionsMet(3) {

        percentLPDepositor = _timelock_data_1;
    }
    
    function startChangeStakingPool(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 4;
        _timelock_address = _address;
    }
    
    function finishChangeStakingPool() external onlyGovernance timelockConditionsMet(4) {

        stakingAddress = _timelock_address;
    }
    
    function startChangeZSToken(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 5;
        _timelock_address = _address;
    }
    
    function finishChangeZSToken() external onlyGovernance timelockConditionsMet(5) {

        zsTokenAddress = _timelock_address;
    }
    
    function startChangeStakersPercent(uint256 _percent) external onlyGovernance {

        require(_percent <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 6;
        _timelock_data_1 = _percent;
    }
    
    function finishChangeStakersPercent() external onlyGovernance timelockConditionsMet(6) {

        percentStakers = _timelock_data_1;
    }
}