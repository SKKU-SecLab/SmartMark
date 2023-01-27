

pragma solidity >=0.6.0;


contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    
    function balanceOf(address account) public view override returns (uint256) {

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

 
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

   
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

   
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _burnFrom(address account, uint256 amount) internal virtual {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

contract ERC20Burnable is Context, ERC20 {
    
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

  
    function burnFrom(address account, uint256 amount) public virtual {
        _burnFrom(account, amount);
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;


    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

   
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract YieldValueCoreFinance is ERC20, ERC20Detailed,ERC20Burnable {
    constructor(uint256 initialSupply) ERC20Detailed("YieldValueCore.finance", "YVCORE", 18) public
    {
        _mint(msg.sender, initialSupply);
    }
}

contract YVFarm {
    string public name = "YieldValue Token Farm";
    address public owner;
    uint256 private totalLocked;
    uint256 private remainReward;
    YieldValueCoreFinance public yieldValueCoreToken;

    uint256 CONST_MULTIPLY;

    address[] private stakers;
    mapping(address => uint256) private stakingBalance;
    mapping(address => bool) private hasStaked;
    mapping(address => bool) private isStaking;
    mapping(address => uint256) private stakingRewards;
    mapping(address => uint256) public firstStakingTime;
    mapping(address => uint256) public lastRewardUpdated;

    event eventLogUint256(uint256 value);

    event eventLogString(string value);

    constructor(YieldValueCoreFinance _yieldValueCoreToken) public {
        yieldValueCoreToken = _yieldValueCoreToken;
        owner = msg.sender;
        totalLocked = 1000000000000000000;
        remainReward = 10000000000000000000000;

        CONST_MULTIPLY = 100000000;
    }

    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "amount cannot be less than 0");

        yieldValueCoreToken.transferFrom(msg.sender, address(this), _amount);

        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        totalLocked += _amount;

        if (firstStakingTime[msg.sender] == 0) {
            firstStakingTime[msg.sender] = now;
        }

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    function unstakeTokens() public {
        uint256 balance = stakingBalance[msg.sender];

        require(balance > 0, "staking balance cannot be 0");

        yieldValueCoreToken.transfer(msg.sender, balance);

        caculateUserRewards(msg.sender);

        stakingBalance[msg.sender] = 0;
        if (totalLocked > 0) {
            totalLocked -= balance;
        }

        uint256 userRewards = getUserReward(msg.sender);
        if (userRewards > 0) {
            yieldValueCoreToken.transfer(msg.sender, userRewards);
            remainReward -= userRewards;
        }

        stakingRewards[msg.sender] = 0;
        isStaking[msg.sender] = false;
        firstStakingTime[msg.sender] = 0;
        lastRewardUpdated[msg.sender] = 0;
    }

    function balanceStaked() public view returns (uint256) {
        return stakingBalance[msg.sender];
    }

    function getTotalLocked() public view returns (uint256) {
        return totalLocked;
    }

    function getRemainReward() public view returns (uint256) {
        return remainReward;
    }

    function caculateRewards() public {
        require(msg.sender == owner, "caller must be the owner");

        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 balance = stakingBalance[recipient];
            uint256 _firstStakingTime = firstStakingTime[recipient];

            uint256 preUpdateTime = lastRewardUpdated[recipient];
            if (preUpdateTime == 0) {
                preUpdateTime = _firstStakingTime;
            }

            uint256 passTime = uint256((now - preUpdateTime) / 60);

            uint256 APY = getCurrentAPY();

            stakingRewards[recipient] +=
                ((APY / 365 / 1440) / 100) *
                passTime *
                balance;
            lastRewardUpdated[recipient] = now;
        }
    }

    function caculateUserRewards(address recipient) public {
        uint256 balance = stakingBalance[recipient];
        require(balance > 0, "stake balance need to greater 0");

        uint256 _firstStakingTime = firstStakingTime[recipient];

        uint256 preUpdateTime = lastRewardUpdated[recipient];
        if (preUpdateTime == 0) {
            preUpdateTime = _firstStakingTime;
        }

        uint256 passTime = uint256((now - preUpdateTime) / 60);

        uint256 APY = getCurrentAPY();

        stakingRewards[recipient] +=
            ((APY / 365 / 1440) / 100) *
            passTime *
            balance;
        lastRewardUpdated[recipient] = now;
    }

    function getCurrentAPY() public view returns (uint256) {
        return (remainReward / totalLocked) * 250 * CONST_MULTIPLY;
    }

    function getUserReward(address _address) public view returns (uint256) {
        return stakingRewards[_address] / CONST_MULTIPLY;
    }
}