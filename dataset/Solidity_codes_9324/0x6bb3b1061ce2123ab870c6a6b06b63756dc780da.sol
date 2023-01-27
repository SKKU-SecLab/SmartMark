
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

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function init() internal {

        require(_owner == address(0), "Ownable: Contract initialized");
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity ^0.6.6;


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
pragma solidity ^0.6.6;

library ACOAssetHelper {

    uint256 internal constant MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    function _isEther(address _address) internal pure returns(bool) {

        return _address == address(0);
    }
    
    function _callApproveERC20(address token, address spender, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(0x095ea7b3, spender, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "approve");
    }
    
    function _callTransferERC20(address token, address recipient, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(0xa9059cbb, recipient, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "transfer");
    }
    
     function _callTransferFromERC20(address token, address sender, address recipient, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(0x23b872dd, sender, recipient, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "transferFrom");
    }
    
    function _getAssetSymbol(address asset) internal view returns(string memory) {

        if (_isEther(asset)) {
            return "ETH";
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x95d89b41));
            require(success, "symbol");
            return abi.decode(returndata, (string));
        }
    }
    
    function _getAssetDecimals(address asset) internal view returns(uint8) {

        if (_isEther(asset)) {
            return uint8(18);
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x313ce567));
            require(success, "decimals");
            return abi.decode(returndata, (uint8));
        }
    }

    function _getAssetName(address asset) internal view returns(string memory) {

        if (_isEther(asset)) {
            return "Ethereum";
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x06fdde03));
            require(success, "name");
            return abi.decode(returndata, (string));
        }
    }
    
    function _getAssetBalanceOf(address asset, address account) internal view returns(uint256) {

        if (_isEther(asset)) {
            return account.balance;
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x70a08231, account));
            require(success, "balanceOf");
            return abi.decode(returndata, (uint256));
        }
    }
    
    function _getAssetAllowance(address asset, address owner, address spender) internal view returns(uint256) {

        if (_isEther(asset)) {
            return 0;
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0xdd62ed3e, owner, spender));
            require(success, "allowance");
            return abi.decode(returndata, (uint256));
        }
    }

    function _transferAsset(address asset, address to, uint256 amount) internal {

        if (_isEther(asset)) {
            (bool success,) = to.call{value:amount}(new bytes(0));
            require(success, "send");
        } else {
            _callTransferERC20(asset, to, amount);
        }
    }
    
    function _receiveAsset(address asset, uint256 amount) internal {

        if (_isEther(asset)) {
            require(msg.value == amount, "Invalid ETH amount");
        } else {
            require(msg.value == 0, "No payable");
            _callTransferFromERC20(asset, msg.sender, address(this), amount);
        }
    }

    function _setAssetInfinityApprove(address asset, address owner, address spender, uint256 amount) internal {

        if (_getAssetAllowance(asset, owner, spender) < amount) {
            _callApproveERC20(asset, spender, MAX_UINT);
        }
    }
}pragma solidity ^0.6.6;


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
pragma solidity ^0.6.6;


interface IACOToken is IERC20 {

	function init(address _underlying, address _strikeAsset, bool _isCall, uint256 _strikePrice, uint256 _expiryTime, uint256 _acoFee, address payable _feeDestination, uint256 _maxExercisedAccounts) external;

    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function decimals() external view returns(uint8);

    function underlying() external view returns (address);

    function strikeAsset() external view returns (address);

    function feeDestination() external view returns (address);

    function isCall() external view returns (bool);

    function strikePrice() external view returns (uint256);

    function expiryTime() external view returns (uint256);

    function totalCollateral() external view returns (uint256);

    function acoFee() external view returns (uint256);

	function maxExercisedAccounts() external view returns (uint256);

    function underlyingSymbol() external view returns (string memory);

    function strikeAssetSymbol() external view returns (string memory);

    function underlyingDecimals() external view returns (uint8);

    function strikeAssetDecimals() external view returns (uint8);

    function currentCollateral(address account) external view returns(uint256);

    function unassignableCollateral(address account) external view returns(uint256);

    function assignableCollateral(address account) external view returns(uint256);

    function currentCollateralizedTokens(address account) external view returns(uint256);

    function unassignableTokens(address account) external view returns(uint256);

    function assignableTokens(address account) external view returns(uint256);

    function getCollateralAmount(uint256 tokenAmount) external view returns(uint256);

    function getTokenAmount(uint256 collateralAmount) external view returns(uint256);

    function getBaseExerciseData(uint256 tokenAmount) external view returns(address, uint256);

    function numberOfAccountsWithCollateral() external view returns(uint256);

    function getCollateralOnExercise(uint256 tokenAmount) external view returns(uint256, uint256);

    function collateral() external view returns(address);

    function mintPayable() external payable returns(uint256);

    function mintToPayable(address account) external payable returns(uint256);

    function mint(uint256 collateralAmount) external returns(uint256);

    function mintTo(address account, uint256 collateralAmount) external returns(uint256);

    function burn(uint256 tokenAmount) external returns(uint256);

    function burnFrom(address account, uint256 tokenAmount) external returns(uint256);

    function redeem() external returns(uint256);

    function redeemFrom(address account) external returns(uint256);

    function exercise(uint256 tokenAmount, uint256 salt) external payable returns(uint256);

    function exerciseFrom(address account, uint256 tokenAmount, uint256 salt) external payable returns(uint256);

    function exerciseAccounts(uint256 tokenAmount, address[] calldata accounts) external payable returns(uint256);

    function exerciseAccountsFrom(address account, uint256 tokenAmount, address[] calldata accounts) external payable returns(uint256);

    function transferCollateralOwnership(address recipient, uint256 tokenCollateralizedAmount) external;

}pragma solidity ^0.6.6;



contract ACORewards is Ownable {

    using SafeMath for uint256;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPaid(address indexed user, uint256 indexed pid, address indexed aco, uint256 reward);
    event SetLPTokenAllocPoint(uint256 indexed pid, address indexed lpToken, uint256 allocPoint);
	event SetCurrentReward(address indexed aco, uint256 rewardRate);
	event WithdrawStuckToken(address indexed token, address indexed destination, uint256 amount);
	
	struct CurrentRewardData {
		address aco;               // Address of the ACO to be distributed.
		uint256 rewardRate;        // ACOs te be reward per second.
	}
	
	struct PoolInfo {
		address lpToken;           // Address of LP token contract.
		uint256 allocPoint;        // How many allocation points assigned to this LP token.
	}
	
    struct ACORewardData {
		uint256 lastUpdateTime;    // Last timestamp that ACO distribution was updated.
		uint256 accRewardPerShare; // Accumulated ACO per share, times 1e18.
	}
	
	struct UserACORewardData {
		uint256 pendingRewardStored;        // Pending reward stored.
		uint256 accAcoRewardPerShareStored; // Last accumulated ACO per share, times 1e18, since last user interaction with the SC.
	}

	uint256 public totalAllocPoint;
	 
	CurrentRewardData public currentReward;
	
    PoolInfo[] public poolInfo;

	address[] public acos;
	
	mapping(uint256 => mapping(address => ACORewardData)) public acosRewardDataPerLP;

    mapping(uint256 => mapping(address => uint256)) public balanceOf;
	
    mapping(uint256 => mapping(address => mapping(address => UserACORewardData))) public usersAcoRewardData; 
    
    constructor() public {
        super.init();
    }
    
    
    function poolLength() external view returns(uint256) {

        return poolInfo.length;
    }
    
    function acosLength() external view returns(uint256) {

        return acos.length;
    }
    
    function pendingReward(uint256 _pid, address account) external view returns (address[] memory _acos, uint256[] memory _amounts) {

        PoolInfo storage info = poolInfo[_pid];
		uint256 share = balanceOf[_pid][account];
        uint256 totalLPSupply = ACOAssetHelper._getAssetBalanceOf(info.lpToken, address(this));
        
        uint256 qty = 0;
        for (uint256 i = 0; i < acos.length; ++i) {
            uint256 pending = _getPendingReward(
                _pid,
				info.allocPoint, 
	            totalLPSupply,
	            account,
	            share,
	            acos[i]);
                
            if (pending > 0) {
                ++qty;
            }
        }
        
        _acos = new address[](qty);
        _amounts = new uint256[](qty);
        
		if (qty > 0) {
			uint256 index = 0;
			for (uint256 i = 0; i < acos.length; ++i) {
				uint256 pending = _getPendingReward(
					_pid,
					info.allocPoint,
					totalLPSupply,
					account,
					share,
					acos[i]);
					
				if (pending > 0) {
					_acos[index] = acos[i];
					_amounts[index] = pending;
					++index;
				}
			}
		}
    }
    

    function deposit(uint256 _pid, uint256 amount) external {

		CurrentRewardData storage _currentReward = currentReward;
		PoolInfo storage info = poolInfo[_pid];
		require(info.allocPoint > 0 && _currentReward.rewardRate > 0, "LP token is forbidden");
        require(amount > 0, "Invalid amount");
		
		_setCurrentAcoRewardAccPerShare(_pid, _currentReward);
		_getUserAcoReward(_pid, true); // Claim available rewards.

		ACOAssetHelper._callTransferFromERC20(info.lpToken, msg.sender, address(this), amount);

        balanceOf[_pid][msg.sender] = amount.add(balanceOf[_pid][msg.sender]);
        
        emit Deposit(msg.sender, _pid, amount);
    }

    function withdraw(uint256 _pid, uint256 amount) external {

		uint256 totalUserBalance = balanceOf[_pid][msg.sender];
        require(amount > 0 && totalUserBalance >= amount, "Invalid amount");

		_setCurrentAcoRewardAccPerShare(_pid, currentReward);
		_getUserAcoReward(_pid, true); // Claim available rewards.
		
        balanceOf[_pid][msg.sender] = totalUserBalance.sub(amount);
        
        ACOAssetHelper._callTransferERC20(poolInfo[_pid].lpToken, msg.sender, amount);
        
		emit Withdraw(msg.sender, _pid, amount);
    }

    function claimReward(uint256 _pid) public {

		PoolInfo storage info = poolInfo[_pid];
        require(info.lpToken != address(0), "Invalid LP token");
		
		_setCurrentAcoRewardAccPerShare(_pid, currentReward);
		_getUserAcoReward(_pid, false);
    }

	function claimRewards(uint256[] calldata _pids) external {

		for (uint256 i = 0; i < _pids.length; ++i) {
			claimReward(_pids[i]);
		}
    }
	
    function emergencyWithdraw(uint256 _pid) external {

        uint256 totalUserBalance = balanceOf[_pid][msg.sender];
        require(totalUserBalance > 0, "No balance");

		_setCurrentAcoRewardAccPerShare(_pid, currentReward);

		balanceOf[_pid][msg.sender] = 0;
        ACOAssetHelper._callTransferERC20(poolInfo[_pid].lpToken, msg.sender, totalUserBalance);

        emit EmergencyWithdraw(msg.sender, _pid, totalUserBalance);
    }
    
	
	function _getUserAcoReward(uint256 _pid, bool ignoreIfNoBalance) internal {

		uint256 share = balanceOf[_pid][msg.sender];
		for (uint256 i = acos.length; i > 0; --i) {
			address aco = acos[i - 1];
			
			if (IACOToken(aco).expiryTime() <= block.timestamp) { // ACO is expired.
				_removeAco(i - 1);
			} else {
				uint256 acoAccRewardPerShare = acosRewardDataPerLP[_pid][aco].accRewardPerShare;
				
				UserACORewardData storage userAcoRewardData = usersAcoRewardData[_pid][msg.sender][aco];
				
				uint256 pending = _earned(share, acoAccRewardPerShare, userAcoRewardData.accAcoRewardPerShareStored);
				pending = pending.add(userAcoRewardData.pendingRewardStored);

				userAcoRewardData.pendingRewardStored = pending;
				userAcoRewardData.accAcoRewardPerShareStored = acoAccRewardPerShare;
				
				if (pending > 0) {
				    if (ignoreIfNoBalance) {
				        uint256 acoBalance = ACOAssetHelper._getAssetBalanceOf(aco, address(this));
				        if (acoBalance < pending) {
				            continue;
				        }
				    }

				    userAcoRewardData.pendingRewardStored = 0; // All ACO reward was paid.
					ACOAssetHelper._callTransferERC20(aco, msg.sender, pending);
					emit RewardPaid(msg.sender, _pid, aco, pending);
				}
			}
		}
	}
	
	function _setCurrentAcoRewardAccPerShare(uint256 _pid, CurrentRewardData storage _currentReward) internal {

		PoolInfo storage info = poolInfo[_pid];
		if (info.allocPoint > 0) {
			uint256 totalLPSupply = ACOAssetHelper._getAssetBalanceOf(info.lpToken, address(this));
			ACORewardData storage currentAcoData = acosRewardDataPerLP[_pid][_currentReward.aco];
			currentAcoData.accRewardPerShare = _getAccRewardPerAco(totalLPSupply, info.allocPoint, _currentReward.aco, _currentReward.rewardRate, _currentReward.aco, currentAcoData);
			currentAcoData.lastUpdateTime = block.timestamp;
		}
	}
	
	function _getAccRewardPerAco(
		uint256 totalSupply,
		uint256	allocPoint,	
		address currentAco, 
		uint256 currentAcoRewardRate,
		address aco, 
		ACORewardData storage acoRewardData
	) internal view returns (uint256) {

        if (currentAco != aco || totalSupply == 0 || allocPoint == 0 || currentAcoRewardRate == 0) {
            return acoRewardData.accRewardPerShare;
        } else {
			uint256 acoReward = block.timestamp.sub(acoRewardData.lastUpdateTime).mul(currentAcoRewardRate).mul(allocPoint).div(totalAllocPoint);
			return acoReward.mul(1e18).div(totalSupply).add(acoRewardData.accRewardPerShare);
		}
    }
	
	function _earned(
		uint256 accountShare, 
		uint256 acoAccRewardPerShare,
		uint256 userAccAcoRewardPerShareStored
	) internal pure returns (uint256) {

        return accountShare.mul(acoAccRewardPerShare.sub(userAccAcoRewardPerShareStored)).div(1e18);
    }
	
	function _removeAco(uint256 acoIndex) internal {

		uint256 lastIndex = acos.length - 1;
		if (lastIndex != acoIndex) {
			address last = acos[lastIndex];
			acos[acoIndex] = last;
		}
		acos.pop();
	}
	
	function _getPendingReward(
	    uint256 _pid, 
		uint256 allocPoint,
	    uint256 totalLPSupply,
	    address account,
	    uint256 accountShare,
	    address aco
    ) internal view returns(uint256 pending) {

	    pending = 0;
	    if (IACOToken(aco).expiryTime() > block.timestamp) {
                
    	    uint256 accRewardPerShare = _getAccRewardPerAco(
    	        totalLPSupply, 
    	        allocPoint, 
    	        currentReward.aco, 
    	        currentReward.rewardRate, 
    	        aco, 
    	        acosRewardDataPerLP[_pid][aco]
            );
            
            UserACORewardData storage userAcoRewardData = usersAcoRewardData[_pid][account][aco];
			pending = _earned(accountShare, accRewardPerShare, userAcoRewardData.accAcoRewardPerShareStored);
			pending = pending.add(userAcoRewardData.pendingRewardStored);
        }
	}
	
	
	
	function setAllLPTokensCurrentAcoRewardAccPerShare() internal {

		CurrentRewardData storage _currentReward = currentReward;
		for (uint256 i = 0; i < poolInfo.length; ++i) {
			_setCurrentAcoRewardAccPerShare(i, _currentReward);
		}
	}

	function setValidAcos() public {

		for (uint256 i = acos.length; i > 0; --i) {
            address aco = acos[i - 1];
			if (IACOToken(aco).expiryTime() <= block.timestamp) {
				_removeAco(i - 1);
			}
        }
	}
	

	function setLPTokens(address[] calldata lpTokens, uint256[] calldata allocPoints) external onlyOwner {

		require(lpTokens.length == allocPoints.length, "Invalid arguments");
		
		setAllLPTokensCurrentAcoRewardAccPerShare();
		setValidAcos();
		
		address _currentAco = currentReward.aco;
		for (uint256 i = 0; i < lpTokens.length; ++i) {
			require(allocPoints[i] <= 1e18, "Invalid alloc point"); // To avoid overflow.

			bool isNew = true;
			uint256 _pid;
			for (uint256 j = 0; j < poolInfo.length; ++j) {

				PoolInfo storage info = poolInfo[j];
				if (info.lpToken == lpTokens[i]) {
					_pid = j;
					totalAllocPoint = totalAllocPoint.sub(info.allocPoint).add(allocPoints[i]);
					info.allocPoint = allocPoints[i];
					isNew = false;
					break;
				}
			}
			if (isNew) { // It is new LP token.
				_pid = poolInfo.length;
				poolInfo.push(PoolInfo(lpTokens[i], allocPoints[i]));
				totalAllocPoint = totalAllocPoint.add(allocPoints[i]);
			}

			acosRewardDataPerLP[_pid][_currentAco].lastUpdateTime = block.timestamp;

			emit SetLPTokenAllocPoint(_pid, lpTokens[i], allocPoints[i]);
		}
	}
	
	function setCurrentReward(address aco, uint256 rewardRate) external onlyOwner {

		require(rewardRate <= 1e40, "The reward rate is too big"); // To avoid overflow.

		setAllLPTokensCurrentAcoRewardAccPerShare();
		setValidAcos();
		
		bool isNew = true;
		for (uint256 i = 0; i < acos.length; ++i) {
			if (acos[i] == aco) {
				isNew = false;
				break;
			}
		}
		if (isNew) {
			acos.push(aco);
		}
		
		CurrentRewardData storage _currentReward = currentReward;
		_currentReward.aco = aco;
		_currentReward.rewardRate = rewardRate;
		
		for (uint256 i = 0; i < poolInfo.length; ++i) {
			if (poolInfo[i].allocPoint > 0) {
				acosRewardDataPerLP[i][aco].lastUpdateTime = block.timestamp;
			}
		}
		
		emit SetCurrentReward(aco, rewardRate);
	}
	
    function withdrawStuckToken(address token, uint256 amount, address destination) external onlyOwner {

		for (uint256 i = 0; i < poolInfo.length; ++i) {
			require(poolInfo[i].lpToken != token, "Forbidden!");
		}
		
		uint256 tokenBalance = ACOAssetHelper._getAssetBalanceOf(token, address(this));
		if (amount > tokenBalance) {
			amount = tokenBalance;
		}
		if (amount > 0) {
		    ACOAssetHelper._callTransferERC20(token, destination, amount);
			emit WithdrawStuckToken(token, destination, amount);
		}
    }
}