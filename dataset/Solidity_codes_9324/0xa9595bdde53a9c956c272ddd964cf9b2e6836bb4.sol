
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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

}// MIT

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
}// MIT

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
}//

pragma solidity ^0.8.4;


interface MGEX0 {
	function balanceOG(address _user) external view returns(uint256);
}
interface NTTZV1 {
	function getTotalClaimable(address _user) external view returns(uint256);
}

contract NTTZToken is ERC20("EntitiesDAO Token", "NTTZ"), Ownable {
    
	using SafeMath for uint256;
	bool public hasClaimingStarted = false;
	bool public hasBurningStarted = false;
	bool public oldBurnAllowed = false;
	uint256 constant public BASE_RATE = 10 ether; 
	uint256 constant public INITIAL_ISSUANCE = 1800 ether;
	uint256 constant public END = 1951230000; //Friday, October 31, 2031 4:20:00 PM (GMT)
	mapping(address => uint256) public rewards;
	mapping(address => uint256) public lastUpdate;
	mapping(address => uint256) public rates; // Contributor wallet daily rate
	mapping(address => uint256) public ends; // Contributor wallet vesting end

	MGEX0 public metaGeckosContract;
	NTTZV1 public nttzV1Contract;

	event RewardPaid(address indexed user, uint256 reward);
	event RewardBal(address indexed user, uint256 reward);
	event RewardCreated(uint256 rewards);
	
	function nttz_V1SetAddress(address _nttz) external onlyOwner {
		nttzV1Contract = NTTZV1(_nttz);
	}
	
	function createInitialReward(address _user, uint256 _initial) public onlyOwner {
		_initial = _initial * 10**uint(decimals());
		setInitialReward(_user, _initial);
	}
	
    function setInitialReward(address _user, uint256 _amount) internal {
        rewards[_user] = rewards[_user] + _amount;
        emit RewardCreated(rewards[_user]);
    }
	
	function createDailyReward(address _user, uint256 _rates, uint256 _ends) public onlyOwner {
	    _rates = _rates * 10**uint(decimals());
		setDailyReward(_user, _rates, _ends);
	}
	
	function setDailyReward(address _user, uint256 _amount, uint256 _ends) internal {
        ends[_user] = _ends;
        rates[_user] = _amount;
        emit RewardCreated(rewards[_user]);
    }
    
    function resetDailyContribReward(address _user)public onlyOwner{
        ends[_user] = 0;
        rates[_user] = 0;
    }
    
    function resetAllContribReward(address _user)public onlyOwner{
        ends[_user] = 0;
        rates[_user] = 0;
        rewards[_user] = 0;
    }
	
	function startClaiming() public onlyOwner {
        hasClaimingStarted = true;
    }
    
    function pauseClaiming() public onlyOwner {
        hasClaimingStarted = false;
    }
    
	function startBurning() public onlyOwner {
        hasBurningStarted = true;
    }
    
    function pauseBurning() public onlyOwner {
        hasBurningStarted = false;
    }
	constructor(address _mgex0) {
		metaGeckosContract = MGEX0(_mgex0);
	}
	
	function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a < b ? a : b;
	}

    function updateV1MintRewards(address _user) public onlyOwner {
        uint256 _prevBal = nttzV1Contract.getTotalClaimable(_user);
        uint256 time = min(block.timestamp, END);
		rewards[_user] = _prevBal;
		lastUpdate[_user] = time;
	}
	
	function updateRewardOnMint(address _user, uint256 _amount) external {
		require(msg.sender == address(metaGeckosContract), "Can't call this");
		uint256 time = min(block.timestamp, END);
		uint256 timerUser = lastUpdate[_user];
		if (timerUser > 0)
			rewards[_user] = rewards[_user].add(metaGeckosContract.balanceOG(_user).mul(BASE_RATE.mul((time.sub(timerUser)))).div(86400)
			.add(_amount.mul(INITIAL_ISSUANCE)));
		else 
			rewards[_user] = rewards[_user].add(_amount.mul(INITIAL_ISSUANCE));
		    lastUpdate[_user] = time;
	}
	
	function updateReward(address _from, address _to, uint256 _tokenId) external {
		require(msg.sender == address(metaGeckosContract));
		if (_tokenId < 4000) {
			uint256 time = min(block.timestamp, END);
			uint256 timerFrom = lastUpdate[_from];
			if (timerFrom > 0)
				rewards[_from] += metaGeckosContract.balanceOG(_from).mul(BASE_RATE.mul((time.sub(timerFrom)))).div(86400);
			if (timerFrom != END)
				lastUpdate[_from] = time;
			if (_to != address(0)) {
				uint256 timerTo = lastUpdate[_to];
				if (timerTo > 0)
					rewards[_to] += metaGeckosContract.balanceOG(_to).mul(BASE_RATE.mul((time.sub(timerTo)))).div(86400);
				if (timerTo != END)
					lastUpdate[_to] = time;
			}
		}
	}
	
	function updateContribReward(address _from) external {
		uint256 time = min(block.timestamp, ends[_from]);
		uint256 timerFrom = lastUpdate[_from];
		if (timerFrom > 0)
			rewards[_from] += rates[_from].mul((time.sub(timerFrom))).div(86400);
		if (timerFrom != ends[_from])
			lastUpdate[_from] = time;
		}

	function getReward(address _to) external {
		require(msg.sender == address(metaGeckosContract));
	    require(hasClaimingStarted == true, "NTTZ claiming is paused");
		uint256 reward = rewards[_to];
		if (reward > 0) {
        	rewards[_to] = 0;
        	_mint(_to, reward);
        	emit RewardPaid(_to, reward);
		}
	}
	
	function burnNTTZ(uint256 _amount) public {
	    require(hasBurningStarted == true, "NTTZ burning is paused");
	    address _from = msg.sender;
	    _burn(_from, _amount);
	}
	function burn(address _from, uint256 _amount) external {
		require(msg.sender == address(metaGeckosContract));
	    require(oldBurnAllowed == true, "This function is locked");
		_burn(_from, _amount);
	}

	function getTotalClaimable(address _user) external view returns(uint256) {
		uint256 time = min(block.timestamp, END);
		uint256 pending = metaGeckosContract.balanceOG(_user).mul(BASE_RATE.mul((time.sub(lastUpdate[_user])))).div(86400);
		return rewards[_user] + pending;
	}
	
}