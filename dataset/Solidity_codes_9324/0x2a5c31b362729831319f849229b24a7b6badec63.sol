
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
}// MIT
pragma solidity ^0.8.7;


contract IPhoenix {
	function getTotalLevels(address _user) external view returns(uint256){}
}


contract Blaze is ERC20, Ownable {

	using SafeMath for uint256;
	
	mapping(address => uint) lastUpdate;

	mapping(address => bool) burnAddresses;

	mapping(address => uint) tokensOwed;

	IPhoenix[] public phoenixContracts;

	uint[] ratePerLevel;

	constructor() ERC20("Blaze", "BLAZE") {

	}

	                                                                                                               
	function updateTokens(address _userAddress) external {

		if (_userAddress != address(0)) {

			uint lastTime = lastUpdate[_userAddress];
			
			uint currentTime = block.timestamp;

			lastUpdate[_userAddress] = currentTime;
 
			IPhoenix[] memory phoenix_contracts = phoenixContracts;

			uint[] memory ratePerLev = ratePerLevel; 

			if(lastTime > 0) {

				uint claimable;

				for(uint i = 0; i < phoenix_contracts.length; i++) {

					claimable += phoenix_contracts[i].getTotalLevels(_userAddress).mul(ratePerLev[i]);

				}
 
				tokensOwed[_userAddress] += claimable.mul(currentTime - lastTime).div(86400);
			}
			
		}

	}

	function updateTransfer(address _fromAddress, address _toAddress) external {

		uint currentTime = block.timestamp;

		uint claimable;

		uint timeDifference;

		uint lastTime;

		IPhoenix[] memory phoenix_contracts = phoenixContracts;

		uint[] memory ratePerLev = ratePerLevel;

		if(_fromAddress != address(0)) {

			lastTime = lastUpdate[_fromAddress];
			lastUpdate[_fromAddress] = currentTime;

			if(lastTime > 0) {

				claimable = 0;

				timeDifference = currentTime - lastTime;

				for(uint i = 0; i < phoenix_contracts.length; i++) {

					claimable += phoenix_contracts[i].getTotalLevels(_fromAddress).mul(ratePerLev[i]);

				}
 
				tokensOwed[_fromAddress] += claimable.mul(timeDifference).div(86400);
			}

		}

		if(_toAddress != address(0)) {

			lastTime = lastUpdate[_toAddress];
			lastUpdate[_toAddress] = currentTime;

			if(lastTime > 0) {

				claimable = 0;

				timeDifference = currentTime - lastTime;

				for(uint i = 0; i < phoenix_contracts.length; i++) {

					claimable += phoenix_contracts[i].getTotalLevels(_toAddress).mul(ratePerLev[i]);

				}
 
				tokensOwed[_toAddress] += claimable.mul(timeDifference).div(86400);
			}

		}

	}

	function claim() external {

    	address sender = _msgSender();

    	uint lastUpdated = lastUpdate[sender];
    	uint time = block.timestamp;

    	require(lastUpdated > 0, "No tokens to claim");

    	lastUpdate[sender] = time;

    	uint unclaimed = getPendingTokens(sender, time - lastUpdated);

    	if(tokensOwed[sender] > 0) {

    		unclaimed += tokensOwed[sender];
    		tokensOwed[sender] = 0;

    	}

    	require(unclaimed > 0, "No tokens to claim");

    	_mint(sender, unclaimed);

    }

	function burn(address _from, uint256 _amount) external {

		require(burnAddresses[_msgSender()] == true, "Don't have permission to call this function");

		uint owed = tokensOwed[_from];	

		if(owed >= _amount) {
			tokensOwed[_from] -= _amount;
			return;
		}

		uint balance = balanceOf(_from);

		if(balance >= _amount) {
			_burn(_from, _amount);
			return;

		}

		if(balance + owed >= _amount) {

			tokensOwed[_from] = 0;

			_burn(_from, _amount - owed);

			return;

		}

		uint lastUpdated = lastUpdate[_from];

		require(lastUpdated > 0, "User doesn't have enough blaze to complete this action");

		uint time = block.timestamp;

		uint claimable = getPendingTokens(_from,  time - lastUpdated);

		lastUpdate[_from] = time;

		if(claimable >= _amount) {

			tokensOwed[_from] += claimable - _amount;
			return;

		} 

		if(claimable + owed >= _amount) {

			tokensOwed[_from] -= _amount - claimable;
			return;

		}

		if(balance + owed + claimable >= _amount) {

			tokensOwed[_from] = 0;

			_burn(_from, _amount - (owed + claimable));

			return;

		}

		revert("User doesn't have enough blaze available to complete this action");

			
	}



	function lastUpdateTime(address _userAddress) public view returns(uint) {
		return lastUpdate[_userAddress];
	}

	function getClaimableTokens(address _userAddress) public view returns(uint) {
		return tokensOwed[_userAddress] + getPendingTokens(_userAddress);
	}

	function getTokensOwed(address _userAddress) public view returns(uint) {
		return tokensOwed[_userAddress];
	}

	
	function getPendingTokens(address _userAddress, uint _timeDifference) public view returns(uint) {

		uint claimable;

		for(uint i = 0; i < phoenixContracts.length; i++) {

			claimable += phoenixContracts[i].getTotalLevels(_userAddress).mul(ratePerLevel[i]);

		}

		return claimable.mul(_timeDifference).div(86400);
	}


	function getPendingTokens(address _userAddress) public view returns(uint) {
		
		uint lastUpdated = lastUpdate[_userAddress];

		if(lastUpdated == 0) {
			return 0;
		}

		return getPendingTokens(_userAddress, block.timestamp - lastUpdated);

	}

   
        
    function setPhoenixContract(address _phoenixAddress, uint _index, uint _ratePerLevel) external onlyOwner {
		require(_index <= phoenixContracts.length, "index outside range");

		if(phoenixContracts.length == _index) {
			phoenixContracts.push(IPhoenix(_phoenixAddress));
			ratePerLevel.push(_ratePerLevel);
		} 
		else {

			if(burnAddresses[address(phoenixContracts[_index])] == true) {
				burnAddresses[address(phoenixContracts[_index])] = false;
			}

			phoenixContracts[_index] = IPhoenix(_phoenixAddress);
			ratePerLevel[_index] = _ratePerLevel;


		}

		burnAddresses[_phoenixAddress] = true;
	}

	function setBurnAddress(address _burnAddress, bool _value) external onlyOwner {
		burnAddresses[_burnAddress] = _value;
	}

}