
pragma solidity ^0.8.0;



library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



pragma solidity ^0.8.0;


interface IBigBang{

    
    
    function addPool  (
        address _stakingToken,
        address _rewardsToken,
        uint256 _tier1Fee,
        uint256 _tier2Fee,
        uint256 _tier3Fee,
        uint256 _tier4Fee,
        uint256 _tier5Fee,
        uint256 _uom,
        uint256 _multiplier
        ) external;
        
     function poolLength() external view returns (uint256);

    

    function totalRewardsInThePool(uint256 _pid, address _poolAddress) external view returns (uint256);


    
    function addRewardsToThePool(uint256 _pid, address _poolAddress, uint256 _amount) external;


    function stake(uint256 _pid, address _address, address _poolAddress, uint256 _dValue, uint256 _tier) external;

    
    function unstake(uint256 _pid, address _address, uint256 wdValue) external;

    
    
    function claimRewards(uint256 _pid, address _address) external;

    
   function getState(uint256 _pid, address _address) external view returns (uint256[] memory);

    
}





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}






pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


pragma solidity ^0.8.0;

contract BigBang is Pausable, Ownable {
    using SafeMath for uint256;
  
    struct PoolInfo {
        address stakingToken;                   // Address of staking token contract.
        address rewardsToken;                   // Address of rewards token contract.
        uint256 tier1Fee;                       // TIER1Fee: uint representing the rewards rate (e.g. 5 stands for 0.005 -> 0.5%)
        uint256 tier2Fee;                       // TIER2Fee: uint representing the rewards rate (e.g. 5  stands for 0.005 -> 0.5%)
        uint256 tier3Fee;                       // TIER3Fee: uint representing the rewards rate (e.g. 5  stands for 0.005 -> 0.5%)
        uint256 tier4Fee;                       // TIER4Fee: uint representing the rewards rate (e.g. 5  stands for 0.005 -> 0.5%)
        uint256 tier5Fee;                       // TIER5Fee: uint representing the rewards rate (e.g. 5  stands for 0.005 -> 0.5%)
        uint256 multiplier;                     // 1 or 10 (1 month)
        uint256  uom;                           // unit of measure: 
        uint256 totalDeposited;                 // Total deposits of the stake contract
        uint256 totalRewards;                   // Total deposits of the rewards contract
        uint256 totalRewardsDebt;               // Total debt towards the stakers
    }
    
  

    struct UserInfo {
        uint256 amount;     // How many Staking tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 endOfStake; // Date when the rewards can be claimed
        uint256 apy;        // APY
    }


    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    PoolInfo[] public poolInfo;


    event NotifyNewStakingContract(address oldSC, address newSC);

    event NotifyNewRewardsContract(address oldRC, address newRC);

    event NotifyStake(uint256 pid, address sender, uint256 amount);

    
    event NotifyUnstake(
        uint256 pid,
        address sender,
        uint256 amount
    );

    event NotifyRewardClaimed(
        uint256 pid, 
        address sender, 
        uint256 rewardAmount);

    event NotifyRewardAdded(
        uint256 pid, 
        uint256 rewardAmount);


    constructor () {}
        
    

    function totalRewardsInThePool(uint256 _pid, address _poolAddress) public view returns (uint256){
        PoolInfo storage pool = poolInfo[_pid];
        return ERC20(pool.rewardsToken).balanceOf(_poolAddress);
        }

    function isAlreadyUser(uint256 _pid, address _address ) public view returns (uint256) {
        UserInfo storage user = userInfo[_pid][_address];
        uint256 isUser = 0;
        if (user.amount > 0)
        {
            isUser = 1;
        }
        return isUser;
        
    }

    function isPoolOpen(uint256 _pid) public view returns (bool) {
        PoolInfo storage pool = poolInfo[_pid];
        if (pool.totalRewards < pool.totalRewardsDebt)
        {
            return false;
        }
        return true;
    }
    
     function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    
    function getBalanceOfDeposit(uint256 _pid, address _address)
        external
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[_pid][_address];
        return user.amount;
    }
    

    function getState(uint256 _pid,  address _address) external view returns (uint256[] memory) {
        UserInfo storage user = userInfo[_pid][_address];
        uint256[] memory state = new uint256[](5);
        state[0] = user.amount;                                     // total staked amount for getting rewards
        state[1] = user.endOfStake;                                 // remaining days for getting rewards
        state[2] = claimableRewards(_pid, _address);                // claimable Rewards
        state[3] = user.apy;                                        // apy
        state[4] = user.rewardDebt;                                 // total reward debt

        return state;
    }



    
    
    
    function addPool  (
        address _stakingToken,
        address _rewardsToken,
        uint256 _tier1Fee,
        uint256 _tier2Fee,
        uint256 _tier3Fee,
        uint256 _tier4Fee,
        uint256 _tier5Fee, 
        uint256 _uom,
        uint256 _multiplier
        ) external 
    {
            poolInfo.push(PoolInfo({
            stakingToken:       _stakingToken,
            rewardsToken:       _rewardsToken,
            tier1Fee:           _tier1Fee,
            tier2Fee:           _tier2Fee,
            tier3Fee:           _tier3Fee,
            tier4Fee:           _tier4Fee,
            tier5Fee:           _tier5Fee,
            uom:                _uom,
            multiplier:         _multiplier,
            totalDeposited:0,
            totalRewards:0,
            totalRewardsDebt:0
        })
        );
    }
    

    function setStakeContract(uint256 _pid, address _stakeContract) external onlyOwner {
        require(_stakeContract != address(0));
        PoolInfo storage pool = poolInfo[_pid];
        address oldSC = pool.stakingToken;
        pool.stakingToken = _stakeContract;
        emit NotifyNewStakingContract(oldSC, _stakeContract);
    }

    function setRewardsContract(uint256 _pid, address _rewardContract) external onlyOwner {
        require(_rewardContract != address(0));
        PoolInfo storage pool = poolInfo[_pid];
        address oldRC = pool.rewardsToken;
        pool.rewardsToken = _rewardContract;
        emit NotifyNewRewardsContract(oldRC, _rewardContract);
    }

    function addRewardsToThePool(uint256 _pid, address _poolAddress, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        require(totalRewardsInThePool(_pid, _poolAddress) >= _amount, 
                "Insufficient Rewards token for the pool"
        );
        pool.totalRewards += _amount;
        emit NotifyRewardAdded(_pid, _amount);
    }

  


    
    function addUserToPool(
        uint256 _pid,
        address _user,
        uint256 _amount,
        uint256 _endOfStake,
        uint256 _apy,
        uint256 _rewardDebt
    ) internal {
        UserInfo memory user = UserInfo({
            amount: _amount,
            rewardDebt: _rewardDebt,
            endOfStake: _endOfStake,
            apy: _apy
        });
        userInfo[_pid][_user] = user;
    }
    

    function removeUserFromPool(
        uint256 _pid,
        address _user
    ) internal {
        delete userInfo[_pid][_user];
    }


    function calculateRewards(uint256 _pid, uint256 _apy, uint256 _amount) public view returns(uint256){
        PoolInfo memory pool = poolInfo[_pid];
        uint256 rewards= _amount.div(pool.totalRewards).mul(_apy).div(1000);
        return rewards;
    }





    function stake(uint256 _pid, address _address, address _poolAddress, uint256 _dValue, uint256 _tier) external whenNotPaused {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 endOfStake;
        uint256 apy;
        uint256 totalSupplyRewardsToken = ERC20(pool.rewardsToken).totalSupply();
        uint256 totalSupplyStakingToken = ERC20(pool.stakingToken).totalSupply();

        require(
            isAlreadyUser(_pid, _address) == 0,
            "User has already a position in the pool"
        );

        require (
            isPoolOpen(_pid) == true,
            "The pool is closed: no enough rewards"
        );

        require(
            ERC20(pool.stakingToken).balanceOf(_address) >= _dValue,
            "The user does not have enough tokens to deposit"
        );

        pool.totalDeposited = pool.totalDeposited.add(_dValue);

        if (_tier == 1) {
            apy = pool.tier1Fee;
        }
        if (_tier == 2) {
            apy = pool.tier2Fee;
        }
        if (_tier == 3) {
            apy = pool.tier3Fee;
        }
        if (_tier == 4) {
            apy = pool.tier4Fee;
        }
        if (_tier == 5) {
            apy = pool.tier5Fee;
        }

        
        if(pool.uom == 0) {
           endOfStake = block.timestamp + (_tier * pool.multiplier *  30 days);    
        }
        if(pool.uom == 1) {
            endOfStake = block.timestamp + (_tier * pool.multiplier * 1 weeks);    
        }
        if(pool.uom == 2) {
            endOfStake = block.timestamp + (_tier * pool.multiplier * 1 days);        
        }
        if(pool.uom == 3) {
            endOfStake = block.timestamp + (_tier * pool.multiplier * 1 hours);    
        }
        if(pool.uom == 4) {
            endOfStake = block.timestamp + (_tier * pool.multiplier * 1 minutes);    
        }
        
        
        uint256 weigthedRatio = totalSupplyRewardsToken / totalSupplyStakingToken;
        uint256 rewards= _dValue.mul(apy).div(1000).mul(weigthedRatio);

        pool.totalRewardsDebt = pool.totalRewardsDebt.add(rewards);

        addUserToPool(
            _pid
            ,_address
            ,_dValue
            ,endOfStake
            ,apy
            ,rewards
        );

        ERC20(pool.stakingToken).transferFrom(_address , _poolAddress, _dValue);
        emit NotifyStake(_pid, _address, _dValue);
    }

    function unstake(uint256 _pid, address _address, uint256 wdValue) external whenNotPaused {
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_address];
        require(wdValue > 0);
        require(user.amount >= wdValue);
        
        ERC20(pool.stakingToken).transferFrom(msg.sender, _address, wdValue);

        emit NotifyUnstake(
            _pid,
            _address,
            wdValue
        );
        
        user.amount.sub(wdValue);

        removeUserFromPool(_pid, _address);
        
        pool.totalDeposited = pool.totalDeposited.sub(wdValue);
        
    }


    function claimableRewards(uint256 _pid, address _address)
        public
        view
        returns (uint256)
    {
        
        UserInfo storage user = userInfo[_pid][_address];
        
        uint256 rewards = 0;
        
        
        if (block.timestamp > user.endOfStake) {
           rewards = user.rewardDebt;
            
        }
        return rewards;
    }

    
    function claimRewards(uint256 _pid, address _address) external whenNotPaused {
        UserInfo storage user = userInfo[_pid][_address];
        uint256 prevRewardDebt = user.rewardDebt;
        uint256 newRewardDebt;
        
        PoolInfo storage pool = poolInfo[_pid]; 
        
        ERC20(pool.rewardsToken).transferFrom(msg.sender, _address,claimableRewards(_pid, _address));
        emit NotifyRewardClaimed(_pid, _address, claimableRewards(_pid, _address));
        
        newRewardDebt = prevRewardDebt - claimableRewards(_pid, _address);
        user.rewardDebt = newRewardDebt;
        
        pool.totalRewardsDebt -= prevRewardDebt;
    }
    
    
}