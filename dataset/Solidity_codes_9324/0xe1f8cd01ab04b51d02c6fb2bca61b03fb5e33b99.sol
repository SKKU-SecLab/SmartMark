



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





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity ^0.6.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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



abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}




pragma solidity ^0.6.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}




pragma solidity 0.6.12;








contract HulkToken is ERC20Burnable, Ownable {
	uint256 public startBlock;
	uint256 public bonusPool = 0 ether;
	uint256 public bigBonusPool = 0 ether;
	uint256 public burnPool = 0 ether;
	uint256 public minSupply = 0 ether;
	uint256 public constant maxSupply = 100000 ether;
	uint256 public burnRate = 0;
	uint256 public bonusRate = 0;
	uint256 public bigBurnRate = 0;
	uint256 public bigBonusRate = 0;
	uint256 public bigBurnStartBlock = 0;
	uint256 public bigBurnBlocks = 0;

	mapping(address => uint256) public burnSenderWhitelist;
	mapping(address => uint256) public burnReceiverWhitelist;

	bool public burnOn = false;
	bool public bonusOn = false;
	bool public bigBurnOn = false;
	bool public bigBonusOn = false;

	function mint(address _to, uint256 _amount) public onlyOwner {
		require(this.totalSupply().add(_amount) <= maxSupply);
		_mint(_to, _amount);
		_moveDelegates(address(0), _delegates[_to], _amount);
	}


	mapping(address => address) internal _delegates;

	struct Checkpoint {
		uint32 fromBlock;
		uint256 votes;
	}

	mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

	mapping(address => uint32) public numCheckpoints;

	bytes32 public constant DOMAIN_TYPEHASH = keccak256(
		'EIP712Domain(string name,uint256 chainId,address verifyingContract)'
	);

	bytes32 public constant DELEGATION_TYPEHASH = keccak256(
		'Delegation(address delegatee,uint256 nonce,uint256 expiry)'
	);

	mapping(address => uint256) public nonces;

	event DelegateChanged(
		address indexed delegator,
		address indexed fromDelegate,
		address indexed toDelegate
	);

	event DelegateVotesChanged(
		address indexed delegate,
		uint256 previousBalance,
		uint256 newBalance
	);

	constructor() public ERC20('HULK.finance', 'HULK') {}

	function delegates(address delegator) external view returns (address) {
		return _delegates[delegator];
	}

	function delegate(address delegatee) external {
		return _delegate(msg.sender, delegatee);
	}

	function delegateBySig(
		address delegatee,
		uint256 nonce,
		uint256 expiry,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external {
		bytes32 domainSeparator = keccak256(
			abi.encode(
				DOMAIN_TYPEHASH,
				keccak256(bytes(name())),
				getChainId(),
				address(this)
			)
		);

		bytes32 structHash = keccak256(
			abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry)
		);

		bytes32 digest = keccak256(
			abi.encodePacked('\x19\x01', domainSeparator, structHash)
		);

		address signatory = ecrecover(digest, v, r, s);
		require(signatory != address(0), 'HULK::delegateBySig: invalid signature');
		require(nonce == nonces[signatory]++, 'HULK::delegateBySig: invalid nonce');
		require(now <= expiry, 'HULK::delegateBySig: signature expired');
		return _delegate(signatory, delegatee);
	}

	function getCurrentVotes(address account) external view returns (uint256) {
		uint32 nCheckpoints = numCheckpoints[account];
		return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
	}

	function getPriorVotes(address account, uint256 blockNumber)
		external
		view
		returns (uint256)
	{
		require(
			blockNumber < block.number,
			'HULK::getPriorVotes: not yet determined'
		);

		uint32 nCheckpoints = numCheckpoints[account];
		if (nCheckpoints == 0) {
			return 0;
		}

		if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
			return checkpoints[account][nCheckpoints - 1].votes;
		}

		if (checkpoints[account][0].fromBlock > blockNumber) {
			return 0;
		}

		uint32 lower = 0;
		uint32 upper = nCheckpoints - 1;
		while (upper > lower) {
			uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
			Checkpoint memory cp = checkpoints[account][center];
			if (cp.fromBlock == blockNumber) {
				return cp.votes;
			} else if (cp.fromBlock < blockNumber) {
				lower = center;
			} else {
				upper = center - 1;
			}
		}
		return checkpoints[account][lower].votes;
	}

	function _delegate(address delegator, address delegatee) internal {
		address currentDelegate = _delegates[delegator];
		uint256 delegatorBalance = balanceOf(delegator); // balance of underlying HULKs (not scaled);
		_delegates[delegator] = delegatee;

		emit DelegateChanged(delegator, currentDelegate, delegatee);

		_moveDelegates(currentDelegate, delegatee, delegatorBalance);
	}

	function _moveDelegates(
		address srcRep,
		address dstRep,
		uint256 amount
	) internal {
		if (srcRep != dstRep && amount > 0) {
			if (srcRep != address(0)) {
				uint32 srcRepNum = numCheckpoints[srcRep];
				uint256 srcRepOld = srcRepNum > 0
					? checkpoints[srcRep][srcRepNum - 1].votes
					: 0;
				uint256 srcRepNew = srcRepOld.sub(amount);
				_writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
			}

			if (dstRep != address(0)) {
				uint32 dstRepNum = numCheckpoints[dstRep];
				uint256 dstRepOld = dstRepNum > 0
					? checkpoints[dstRep][dstRepNum - 1].votes
					: 0;
				uint256 dstRepNew = dstRepOld.add(amount);
				_writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
			}
		}
	}

	function _writeCheckpoint(
		address delegatee,
		uint32 nCheckpoints,
		uint256 oldVotes,
		uint256 newVotes
	) internal {
		uint32 blockNumber = safe32(
			block.number,
			'HULK::_writeCheckpoint: block number exceeds 32 bits'
		);

		if (
			nCheckpoints > 0 &&
			checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
		) {
			checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
		} else {
			checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
			numCheckpoints[delegatee] = nCheckpoints + 1;
		}

		emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
	}

	function safe32(uint256 n, string memory errorMessage)
		internal
		pure
		returns (uint32)
	{
		require(n < 2**32, errorMessage);
		return uint32(n);
	}

	function getChainId() internal pure returns (uint256) {
		uint256 chainId;
		assembly {
			chainId := chainid()
		}
		return chainId;
	}

	function calcRate(
		address sender,
		address recipient,
		uint256 amount
	)
		public
		view
		returns (
			uint256,
			uint256,
			uint256
		)
	{
		if (
			burnReceiverWhitelist[recipient] == 1 ||
			burnSenderWhitelist[recipient] == 1 ||
			sender == this.owner() ||
			recipient == this.owner()
		) {
			return (0, 0, amount);
		}
		if (burnOn == false && bigBurnOn == false) {
			return (0, 0, amount);
		}
		if (this.totalSupply() <= minSupply) {
			return (0, 0, amount);
		}
		uint256 burnAmount = 0;
		uint256 bonusAmount = 0;
		if (
			bigBurnOn == true && (block.number).sub(bigBurnStartBlock) < bigBurnBlocks
		) {
			burnAmount = amount.mul(bigBurnRate).div(10000);
			bonusAmount = amount.mul(bigBonusRate).div(10000);
		} else if (burnOn == true) {
			burnAmount = amount.mul(burnRate).div(10000);
			bonusAmount = amount.mul(bonusRate).div(10000);
		}
		if (this.totalSupply().sub(burnAmount).sub(bonusAmount) < minSupply) {
			burnAmount = 0;
			bonusAmount = -(minSupply.sub(this.totalSupply()));
		}

		return (burnAmount, bonusAmount, amount.sub(burnAmount).sub(bonusAmount));
	}

	function sendBonusMany(address[] memory recs, uint256[] memory amounts)
		public
		onlyOwner
		returns (bool)
	{
		require(recs.length == amounts.length);
		uint256 totalAmount;
		for (uint256 x = 0; x < recs.length; x++) {
			require(recs[x] == address(recs[x]), 'Invalid address');
			totalAmount = totalAmount.add(amounts[x]);
		}
		require(totalAmount <= bonusPool);
		for (uint256 i = 0; i < recs.length; i++) {
			require(bonusPool >= amounts[i]);
			bonusPool = bonusPool.sub(amounts[i]);
			_transfer(address(this), recs[i], amounts[i]);
		}
	}

	function sendBonus(address recipient, uint256 amount)
		public
		onlyOwner
		returns (bool)
	{
		require(recipient == address(recipient), 'Invalid address');
		require(amount <= bonusPool);
		bonusPool = bonusPool.sub(amount);
		_transfer(address(this), recipient, amount);
	}

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) public override returns (bool) {
		(uint256 burnAmount, uint256 bonusAmount, uint256 amountToSend) = calcRate(
			sender,
			recipient,
			amount
		);
		burnPool = burnPool.add(burnAmount);
		_burn(sender, burnAmount);
		bonusPool = bonusPool.add(bonusAmount);
		super.transferFrom(sender, address(this), bonusAmount);
		super.transferFrom(sender, recipient, amountToSend);
		return true;
	}

	function transfer(address recipient, uint256 amount)
		public
		override
		returns (bool)
	{
		(uint256 burnAmount, uint256 bonusAmount, uint256 amountToSend) = calcRate(
			_msgSender(),
			recipient,
			amount
		);
		burnPool = burnPool.add(burnAmount);
		_burn(_msgSender(), burnAmount);
		bonusPool = bonusPool.add(bonusAmount);
		_transfer(_msgSender(), address(this), bonusAmount);
		_transfer(_msgSender(), recipient, amountToSend);
		return true;
	}

	function removeReceiverBurnWhitelist(address toRemove)
		public
		onlyOwner
		returns (bool)
	{
		burnReceiverWhitelist[toRemove] = 0;
		return true;
	}

	function removeSenderBurnWhitelist(address toRemove)
		public
		onlyOwner
		returns (bool)
	{
		burnSenderWhitelist[toRemove] = 0;
		return true;
	}

	function addReceiverBurnWhitelist(address toAdd)
		public
		onlyOwner
		returns (bool)
	{
		burnReceiverWhitelist[toAdd] = 1;
		return true;
	}

	function addSenderBurnWhitelist(address toAdd)
		public
		onlyOwner
		returns (bool)
	{
		burnSenderWhitelist[toAdd] = 1;
		return true;
	}

	function bigBurnStart(
		uint256 newBigBurnBlocks,
		uint256 newBigBurnRate,
		uint256 newBigBonusRate
	) public onlyOwner returns (bool) {
		bigBurnStartBlock = block.number;
		bigBurnBlocks = newBigBurnBlocks;
		bigBurnRate = newBigBurnRate;
		bigBonusRate = newBigBonusRate;
		return true;
	}

	function bigBurnStop() public onlyOwner returns (bool) {
		bigBurnOn = false;
		bigBurnBlocks = 0;
		return true;
	}

	function burnStart(uint256 newBurnRate, uint256 newBonusRate)
		public
		onlyOwner
		returns (bool)
	{
		burnOn = true;
		burnRate = newBurnRate;
		bonusRate = newBonusRate;
		return true;
	}

	function burnStop() public onlyOwner returns (bool) {
		burnOn = false;
		return true;
	}
}