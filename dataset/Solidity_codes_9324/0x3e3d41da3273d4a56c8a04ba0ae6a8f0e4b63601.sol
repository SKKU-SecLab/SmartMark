pragma solidity ^0.5.0;

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
pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
pragma solidity ^0.5.0;


contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}
pragma solidity ^0.5.0;


contract EtheleToken is ERC20 {

    using SafeMath for uint256;

    string private _name;
    string private _symbol;

    address private _creator;
    address private _transmuteSource1;
    address private _transmuteSource2;
    address private _transmuteSource3;
    address private _transmuteSource4;
    mapping (address => bool) private _allowBurnsFrom; // Address mapped to true are allowed to burn this contract's tokens

    uint256 private _totalLocked;
    mapping (address => uint256) private _lockedBalance;
    mapping (address => uint256) private _harvestStartPeriod;
    mapping (address => uint256) private _unlockTime;

    uint256 private constant PERIOD_LENGTH = 1 days; 
    uint256 private constant MINT_AMOUNT = 100000 ether; // 'ether' is equivalent to 10^18. This is used since this token has same number of decimals as ETH.
    uint256 private _currentPeriod;
    uint256 private _contractStartTime;
    uint256[] private _cumulTokenPerEth; // Across periods, tracks cumulative harvestable amount of this token per each Eth locked.

    constructor(
        string memory name,
        string memory symbol
    ) public {
        _creator = msg.sender;

        _name = name;
        _symbol = symbol;

        _currentPeriod = 1;
        _cumulTokenPerEth.push(0);
        _contractStartTime = block.timestamp;
    }


    function name() public view returns (string memory) {

        return _name;
    }
    function symbol() public view returns (string memory) {

        return _symbol;
    }
    function decimals() public pure returns (uint8) {

        return 18;
    }
    function getCreator() public view returns (address) {

    	return _creator;
    }

    function getTransmuteSource1() public view returns (address) {

		return _transmuteSource1;
    }
    function getTransmuteSource2() public view returns (address) {

    	return _transmuteSource2;
    }
    function getTransmuteSource3() public view returns (address) {

    	return _transmuteSource3;
    }
    function getTransmuteSource4() public view returns (address) {

    	return _transmuteSource4;
    }
    function getAllowBurnsFrom(address addr) public view returns (bool) {

    	return _allowBurnsFrom[addr];
    }

    function getTotalLocked() public view returns (uint256) {

    	return _totalLocked;
    }
    function getLockedBalance(address addr) public view returns (uint256) {

    	return _lockedBalance[addr];
    }    
    function getHarvestStartPeriod(address addr) public view returns (uint256) {

    	return _harvestStartPeriod[addr];
    }    
    function getUnlockTime(address addr) public view returns (uint256) {

    	return _unlockTime[addr];
    }
    function getHarvestableAmount(address addr) public view returns (uint256) {

        uint256 intendedPeriod = (block.timestamp).sub(_contractStartTime).div(PERIOD_LENGTH).add(1);
        uint256 harvestStartPeriod = _harvestStartPeriod[addr];
        uint256 lockedBalance = _lockedBalance[addr];

        if (harvestStartPeriod >= intendedPeriod.sub(1) ||
            lockedBalance == 0) {
            return 0;
        }
        else {
            uint256 harvestableTokenPerEth = MINT_AMOUNT.mul(1 ether).div(_totalLocked);
            uint256 harvestableAmount;
            if (harvestStartPeriod == _currentPeriod) {
                uint256 periodDiff = intendedPeriod.sub(1).sub(harvestStartPeriod);
                harvestableAmount = periodDiff
                                          .mul(harvestableTokenPerEth)
                                          .mul(lockedBalance)
                                          .div(1 ether);
            } else {
                uint256 periodDiff = intendedPeriod.sub(_currentPeriod);
                uint256 tokenPerEthInPeriodDiff = harvestableTokenPerEth.mul(periodDiff);

                harvestableAmount = tokenPerEthInPeriodDiff
                                            .add(_cumulTokenPerEth[_currentPeriod.sub(1)])
                                            .sub(_cumulTokenPerEth[harvestStartPeriod])
                                            .mul(lockedBalance)
                                            .div(1 ether);
            }

            return harvestableAmount;
        }
    }

    function getPeriodLength() public pure returns (uint256) {

        return PERIOD_LENGTH; 
    }
    function getMintAmount() public pure returns (uint256) {

        return MINT_AMOUNT; 
    }
    function getCurrentPeriod() public view returns (uint256) {

        return _currentPeriod; 
    }
    function getContractStartTime() public view returns (uint256) {

        return _contractStartTime; 
    }
    function getCumulTokenPerEth(uint256 period) public view returns (uint256) {

    	return _cumulTokenPerEth[period];
    }

    function burn(uint256 amount) public {

        _burn(msg.sender, amount);
    }
    function burnFrom(address account, uint256 amount) public {

    	if (_allowBurnsFrom[msg.sender]) {
    		_burn(account, amount);
    	} else {
        	_burnFrom(account, amount);
    	}
    }

    function setTransmuteSources12(address transmuteSource1, address transmuteSource2) public {

        require(msg.sender == _creator);
        _transmuteSource1 = transmuteSource1;
        _transmuteSource2 = transmuteSource2;
    } 

    function setTransmuteSources34(address transmuteSource3, address transmuteSource4) public {

        require(msg.sender == _creator);
        _transmuteSource3 = transmuteSource3;
        _transmuteSource4 = transmuteSource4;
    } 

    function allowBurnsFrom(address burner) public {

    	require(msg.sender == _creator);
    	_allowBurnsFrom[burner] = true;
    }


    function transmute(uint256 amount, uint256 transmuteType) public {

    	require(transmuteType == 0 || transmuteType == 1, "EtheleToken: Transmute type should be 0 or 1.");
    	if (transmuteType == 0) {
			require(_transmuteSource1 != address(0) && _transmuteSource2 != address(0), "EtheleToken: Cannot transmute this.");
    		EtheleToken(_transmuteSource1).burnFrom(msg.sender, amount);
    		EtheleToken(_transmuteSource2).burnFrom(msg.sender, amount);
    		_mint(msg.sender, amount);
		} else if (transmuteType == 1) {
			require(_transmuteSource3 != address(0) && _transmuteSource4 != address(0), "EtheleToken: Cannot transmute this.");
    		EtheleToken(_transmuteSource3).burnFrom(msg.sender, amount);
    		EtheleToken(_transmuteSource4).burnFrom(msg.sender, amount);
    		_mint(msg.sender, amount);
		}
    }

    function updatePeriod(int256 steps) public {

    	uint256 intendedPeriod = (block.timestamp).sub(_contractStartTime).div(PERIOD_LENGTH).add(1);
    	if (_currentPeriod < intendedPeriod) {
			uint256 harvestableTokenPerEth;
    		if (_totalLocked == 0) {
    			harvestableTokenPerEth = 0;
    		} else {
    			harvestableTokenPerEth = MINT_AMOUNT.mul(1 ether).div(_totalLocked);
    		}

    		while (_currentPeriod < intendedPeriod && steps != 0) {
    			_cumulTokenPerEth.push(_cumulTokenPerEth[_currentPeriod-1].add(harvestableTokenPerEth));
    			_currentPeriod += 1;
    			steps -= 1;
    		}
    	}
    }

    function lock() public payable {

    	require(_lockedBalance[msg.sender] == 0, "EtheleToken: To lock, you must not have any existing locked ETH.");
    	updatePeriod(-1);

    	_totalLocked = _totalLocked.add(msg.value);
    	_lockedBalance[msg.sender] = msg.value;
    	_harvestStartPeriod[msg.sender] = _currentPeriod;
    	_unlockTime[msg.sender] = block.timestamp.add(PERIOD_LENGTH);
    }

    function harvest() public {

    	require(_lockedBalance[msg.sender] > 0, "EtheleToken: Require locked balance to harvest.");
    	updatePeriod(-1);

    	require(_harvestStartPeriod[msg.sender] < _currentPeriod-1, "EtheleToken: Nothing to harvest - Lock start period should be before previous currentPeriod.");
    	uint256 amountHarvested = _cumulTokenPerEth[_currentPeriod-1]
    							.sub(_cumulTokenPerEth[_harvestStartPeriod[msg.sender]])
    							.mul(_lockedBalance[msg.sender])
    							.div(1 ether);
    	_harvestStartPeriod[msg.sender] = _currentPeriod-1;
    	_mint(msg.sender, amountHarvested);	
    }

    function unlock() public {

    	require(_lockedBalance[msg.sender] > 0, "EtheleToken: Require locked balance to unlock.");
    	updatePeriod(-1);

    	require(_unlockTime[msg.sender] < block.timestamp, "EtheleToken: Minimum lock time not yet reached.");
    	uint256 amount = _lockedBalance[msg.sender];
    	_lockedBalance[msg.sender] = 0;
    	_totalLocked = _totalLocked.sub(amount);
    	msg.sender.transfer(amount);
    }
}
pragma solidity ^0.5.0;


contract EtheleGenerator {

    address private _fire;
    address private _earth;
    address private _metal;
    address private _water;
    address private _wood;
    address private _yin;
    address private _yang;

    uint256 private _step; // The deploy process has to be completed in steps, because the gas needed is too large.

    uint256 private constant LAUNCH_TIME = 1565438400; // Ethele Token address will only be able to be created after mainnet launch.

    constructor() public {
        _step = 0;
    }

    function getLaunchTime() public pure returns (uint256) {

        return LAUNCH_TIME;
    }

    function step() public {

        require(_step <= 3 && LAUNCH_TIME < block.timestamp);

        if (_step == 0) {
            _fire = address(new EtheleToken("Ethele Fire", "EEFI"));
            _earth = address(new EtheleToken("Ethele Earth", "EEEA"));
        } else if (_step == 1) {
            _metal = address(new EtheleToken("Ethele Metal", "EEME"));
            _water = address(new EtheleToken("Ethele Water", "EEWA"));
        } else if (_step == 2) {
            _wood = address(new EtheleToken("Ethele Wood", "EEWO"));
            _yin = address(new EtheleToken("Ethele Yin", "EEYI"));
        } else if (_step == 3) {
            _yang = address(new EtheleToken("Ethele Yang", "EEYA"));
            EtheleToken(_fire).setTransmuteSources12(_metal, _wood);
            EtheleToken(_earth).setTransmuteSources12(_water, _fire);
            EtheleToken(_metal).setTransmuteSources12(_wood, _earth);
            EtheleToken(_water).setTransmuteSources12(_fire, _metal);
            EtheleToken(_wood).setTransmuteSources12(_earth, _water);
            
            EtheleToken(_fire).setTransmuteSources34(_yin, _yang);
            EtheleToken(_earth).setTransmuteSources34(_yin, _yang);
            EtheleToken(_metal).setTransmuteSources34(_yin, _yang);
            EtheleToken(_water).setTransmuteSources34(_yin, _yang);
            EtheleToken(_wood).setTransmuteSources34(_yin, _yang);

            EtheleToken(_metal).allowBurnsFrom(_fire);
            EtheleToken(_wood).allowBurnsFrom(_fire);
            EtheleToken(_water).allowBurnsFrom(_earth);
            EtheleToken(_fire).allowBurnsFrom(_earth);
            EtheleToken(_wood).allowBurnsFrom(_metal);
            EtheleToken(_earth).allowBurnsFrom(_metal);
            EtheleToken(_fire).allowBurnsFrom(_water);
            EtheleToken(_metal).allowBurnsFrom(_water);
            EtheleToken(_earth).allowBurnsFrom(_wood);
            EtheleToken(_water).allowBurnsFrom(_wood);

            EtheleToken(_yin).allowBurnsFrom(_fire);
            EtheleToken(_yin).allowBurnsFrom(_earth);
            EtheleToken(_yin).allowBurnsFrom(_metal);
            EtheleToken(_yin).allowBurnsFrom(_water);
            EtheleToken(_yin).allowBurnsFrom(_wood);
            EtheleToken(_yang).allowBurnsFrom(_fire);
            EtheleToken(_yang).allowBurnsFrom(_earth);
            EtheleToken(_yang).allowBurnsFrom(_metal);
            EtheleToken(_yang).allowBurnsFrom(_water);
            EtheleToken(_yang).allowBurnsFrom(_wood);
        }

        _step += 1;
    }

    function getStep() public view returns (uint256) {

        return _step;
    }
    function fire() public view returns (address) {

        return _fire;
    }
    function earth() public view returns (address) {

        return _earth;
    }
    function metal() public view returns (address) {

        return _metal;
    }
    function water() public view returns (address) {

        return _water;
    }
    function wood() public view returns (address) {

        return _wood;
    }
    function yin() public view returns (address) {

        return _yin;
    }
    function yang() public view returns (address) {

        return _yang;
    }
}
