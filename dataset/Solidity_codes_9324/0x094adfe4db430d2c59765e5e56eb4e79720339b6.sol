
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

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
}// MIT

pragma solidity ^0.8.0;

interface ILions {
    function balanceOG(address _user) external view returns(uint256);
}// MIT

pragma solidity >=0.8.0 <= 0.9.0;


contract YieldToken is ERC20("SexyToken", "SEXY") {
	using SafeMath for uint256;
    using Address for address;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	uint256 constant public BASE_RATE = 1 ether; 
	uint256 constant public INITIAL_ISSUANCE = 10 ether;

    uint256 constant public REWARD_SEPARATOR = 86400;

    mapping(address => mapping(address => uint256)) rewards;
    mapping(address => mapping(address => uint256)) lastUpdates;

    mapping(address => uint256) rewardsEnd;
    address[] contracts;

    address owner; 

	event RewardPaid(address indexed user, uint256 reward);

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier isContract() {
        require(msg.sender.isContract(), "Address isn`t a contract");
        _;
    }

    modifier isValidAddress() {
        bool _found;
        for(uint i=0; i<contracts.length; i++) {
            if(contracts[i] == msg.sender) {
                _found = true;
                break;
            }
        }

        require(_found, "Address is not one of permissioned addresses");
        _;
    }

	constructor() {
        owner = msg.sender;
        _mint(0x85A5F069C4f2C34C2Aa49611e84b634193d0923b, 1000000000000000000000000000);
        _mint(0x1D23a28C71b5daC1b0F3Af101666d7184b299032, 50000000000000000000000000);
	}

    function transferOwnership(address _newOwner) public virtual onlyOwner {
        require(_newOwner != address(0), "Ownable: new owner is the zero address");
        
        address _oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(_oldOwner, _newOwner);
    }

	function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a < b ? a : b;
	}

	function updateRewardOnMint(address _user, uint256 _amount) external isValidAddress isContract {
        address _contract = msg.sender;
        uint256 _rewardTime = rewardsEnd[_contract];

		uint256 _time = min(block.timestamp, _rewardTime);
        
		uint256 _lastUpdate = lastUpdates[_contract][_user];
        if (_rewardTime <= _lastUpdate){
            rewards[_contract][_user] += _amount.mul(INITIAL_ISSUANCE);
        }else {
            if (_lastUpdate > 0)
                rewards[_contract][_user] = rewards[_contract][_user].add(ILions(_contract).balanceOG(_user).mul(BASE_RATE.mul(_time.sub(_lastUpdate))).div(REWARD_SEPARATOR)
                    .add(_amount.mul(INITIAL_ISSUANCE)));
            else 
                rewards[_contract][_user] = rewards[_contract][_user].add(_amount.mul(INITIAL_ISSUANCE));
        }

        lastUpdates[_contract][_user] = block.timestamp;
	}

	function updateReward(address _from, address _to) external isValidAddress isContract{
        address _contract = msg.sender;
        _updateReward(_contract, _from, _to);
    }

    function _updateReward(address _contract, address _from, address _to) internal {
        uint256 _rewardTime = rewardsEnd[_contract];

        uint256 _time = min(block.timestamp, _rewardTime);
        uint256 _lastUpdate = lastUpdates[_contract][_from];
        if(_rewardTime >= _lastUpdate) {
            if (_lastUpdate > 0)
                rewards[_contract][_from] += ILions(_contract).balanceOG(_from).mul(BASE_RATE.mul(_time.sub(_lastUpdate))).div(REWARD_SEPARATOR);
            if (_lastUpdate != _rewardTime)
                lastUpdates[_contract][_from] = _time;
            if (_to != address(0)) {
                uint256 _timerTo = lastUpdates[_contract][_to];
                if (_timerTo > 0)
                    rewards[_contract][_to] += ILions(_contract).balanceOG(_to).mul(BASE_RATE.mul(_time.sub(_timerTo))).div(REWARD_SEPARATOR);
                if (_timerTo != _rewardTime)
                    lastUpdates[_contract][_to] = _time;
            }
        }
    }


	function getReward(address _to) external isValidAddress isContract {
		getReward(msg.sender, _to);
	}

    function getReward(address _contract, address _to) internal {
        uint256 reward = rewards[_contract][_to];
		if (reward > 0) {
			rewards[_contract][_to] = 0;
			_mint(_to, reward);
			emit RewardPaid(_to, reward);
		}
    }

	function burn(address _from, uint256 _amount) external {
        if(msg.sender.isContract()) {
		    _burn(_from, _amount);
        }else if(msg.sender == owner) {
            _burn(msg.sender, _amount);
        }
	}

	function getTotalClaimable(address _user) external view isValidAddress isContract returns(uint256) {
        address _contract = msg.sender;
        uint256 _rewardTime = rewardsEnd[_contract];

		uint256 _time = min(block.timestamp, _rewardTime);
        uint256 _lastUpdate = lastUpdates[_contract][_user];
    
		        
		return (_rewardTime >= _lastUpdate)? rewards[_contract][_user] +  ILions(msg.sender).balanceOG(_user).mul(BASE_RATE.mul((_time.sub(_lastUpdate)))).div(REWARD_SEPARATOR) : rewards[_contract][_user];
	}

    function addContract(address _contract, uint256 _rewardTime) public onlyOwner {
        require(_contract.isContract(), "Address isn't a contract");
        contracts.push(_contract);
        rewardsEnd[_contract] = block.timestamp + _rewardTime;
    }

    function getAllRewards() public {
        for(uint i=0; i<contracts.length; i++) {
            _updateReward(contracts[i], msg.sender, address(0));
            getReward(contracts[i], msg.sender);
        }
    }
}