

pragma solidity 0.8.12;


contract SafeMath {

	function safeAdd(uint256 a, uint256 b) internal pure returns (uint256 c) {

		c = a + b;
		require(c >= a, "SafeMath: addition overflow");
	}

	function safeSub(uint256 a, uint256 b) internal pure returns (uint256 c) {

		require(b <= a, "SafeMath: subtraction overflow");
		c = a - b;
	}

	function safeMul(uint256 a, uint256 b) internal pure returns (uint256 c) {

		if (a == 0) {
			c = 0;
		} else {
			c = a * b;
		}
		require((a == 0 || c / a == b), "SafeMath: multiplication overflow");
	}

	function safeDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

		require(b > 0, "SafeMath: division by zero");
		c = a / b;
	}

	function safeMod(uint256 a, uint256 b) internal pure returns (uint256 c) {

		require(b != 0, "SafeMath: modulo by zero");
		c = a % b;
	}
}

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes memory) {
		this; // Warning: silence state mutability without generating bytecode
		return msg.data;
	}
}

abstract contract ERC20Interface {
	function totalSupply() public view virtual returns (uint256);

	function balanceOf(address tokenOwner) public view virtual returns (uint256 balance);

	function allowance(address tokenOwner, address spender)
		public
		view
		virtual
		returns (uint256 remaining);

	function transfer(address to, uint256 tokens) external virtual returns (bool success);

	function approve(address spender, uint256 tokens) public virtual returns (bool success);

	function transferFrom(
		address from,
		address to,
		uint256 tokens
	) external virtual returns (bool success);

	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

abstract contract ApproveAndCallFallBack {
	function receiveApproval(
		address from,
		uint256 tokens,
		address token,
		bytes memory data
	) public virtual;
}

contract Owned {

	address public owner;
	address public newOwner;

	event OwnershipTransferred(address indexed _from, address indexed _to);

	constructor() {
		owner = msg.sender;
	}

	modifier onlyOwner() {

		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address _newOwner) external onlyOwner {

		newOwner = _newOwner;
	}

	function acceptOwnership() external {

		require(msg.sender == newOwner);
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
		newOwner = address(0);
	}
}

library Address {

	function isContract(address account) internal view returns (bool) {

		bytes32 codehash;
		bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
		assembly {
			codehash := extcodehash(account)
		}
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

	function functionCall(
		address target,
		bytes memory data,
		string memory errorMessage
	) internal returns (bytes memory) {

		return _functionCallWithValue(target, data, 0, errorMessage);
	}

	function functionCallWithValue(
		address target,
		bytes memory data,
		uint256 value
	) internal returns (bytes memory) {

		return
			functionCallWithValue(target, data, value, "Address: low-level call with value failed");
	}

	function functionCallWithValue(
		address target,
		bytes memory data,
		uint256 value,
		string memory errorMessage
	) internal returns (bytes memory) {

		require(address(this).balance >= value, "Address: insufficient balance for call");
		return _functionCallWithValue(target, data, value, errorMessage);
	}

	function _functionCallWithValue(
		address target,
		bytes memory data,
		uint256 weiValue,
		string memory errorMessage
	) private returns (bytes memory) {

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

contract TELEToken is ERC20Interface, Owned, SafeMath, Context {

	using Address for address;

	string public symbol;
	string public name;
	uint8 public decimals;
	uint256 private _totalSupply;
	address private _minter;

	mapping(address => uint256) balances;
	mapping(address => mapping(address => uint256)) allowed;

	uint256 public mintingAllowedAfter;

	uint32 public constant minimumTimeBetweenMints = 1 days * 7;

	uint8 public constant mintCap = 2;

	mapping(address => address) internal _delegates;

	struct Checkpoint {
		uint32 fromBlock;
		uint256 votes;
	}

	mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

	mapping(address => uint32) public numCheckpoints;

	bytes32 public constant DOMAIN_TYPEHASH =
		keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

	bytes32 public constant DELEGATION_TYPEHASH =
		keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

	bytes32 public constant PERMIT_TYPEHASH =
		keccak256(
			"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
		);

	mapping(address => uint256) public nonces;

	event TransferMultiple(address indexed from, address[] indexed to, uint256[] tokens);

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

	event MinterChanged(address minter, address newMinter);

	constructor() {
		symbol = "TELE";
		name = "Telefy";
		decimals = 18;
		_totalSupply = 600_000_000e18;
		balances[owner] = _totalSupply;
		emit Transfer(address(0), owner, _totalSupply);
		_minter = 0xa270dA3c3175ED9992c9Ad3B6Bb679Bf81c35BA8;
		mintingAllowedAfter = safeAdd(block.timestamp, minimumTimeBetweenMints);
	}

	function totalSupply() public view override returns (uint256) {

		return safeSub(_totalSupply, balances[address(0)]);
	}

	function balanceOf(address tokenOwner) public view override returns (uint256 balance) {

		return balances[tokenOwner];
	}

	function transfer(address to, uint256 tokens) external override returns (bool success) {

		require(to != address(0), "TELE: transfer to the zero address");
		_transferTokens(to, tokens);
		emit Transfer(_msgSender(), to, tokens);
		return true;
	}

	function transferMultiple(address[] memory to, uint256[] memory tokens)
		external
		returns (bool success)
	{

		require(
			to.length == tokens.length,
			"TELE: number of receiver addresses and number of amounts should be equal"
		);
		for (uint256 i = 0; i < to.length; i++) {
			if (to[i] != address(0)) {
				_transferTokens(to[i], tokens[i]);
			}
		}
		emit TransferMultiple(_msgSender(), to, tokens);
		return true;
	}

	function approve(address spender, uint256 tokens) public override returns (bool success) {

		require(spender != address(0), "TELE: transfer to the zero address");
		allowed[_msgSender()][spender] = tokens;
		emit Approval(_msgSender(), spender, tokens);
		return true;
	}

	function permit(
		address owner,
		address spender,
		uint256 rawAmount,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external {

		bytes32 domainSeparator = keccak256(
			abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this))
		);
		bytes32 structHash = keccak256(
			abi.encode(PERMIT_TYPEHASH, owner, spender, rawAmount, nonces[owner]++, deadline)
		);
		bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
		address signatory = ecrecover(digest, v, r, s);
		require(signatory != address(0), "TELE::permit: invalid signature");
		require(signatory == owner, "TELE::permit: unauthorized");
		require(block.timestamp <= deadline, "TELE::permit: signature expired");

		allowed[owner][spender] = rawAmount;

		emit Approval(owner, spender, rawAmount);
	}

	function transferFrom(
		address from,
		address to,
		uint256 tokens
	) external override returns (bool success) {

		balances[from] = safeSub(balances[from], tokens);
		allowed[from][_msgSender()] = safeSub(allowed[from][_msgSender()], tokens);
		emit Approval(from, to, tokens);
		balances[to] = safeAdd(balances[to], tokens);
		emit Transfer(from, to, tokens);
		_moveDelegates(_delegates[from], _delegates[to], tokens);
		return true;
	}

	function allowance(address tokenOwner, address spender)
		public
		view
		override
		returns (uint256 remaining)
	{

		return allowed[tokenOwner][spender];
	}

	function increaseAllowance(address spender, uint256 addedValue)
		external
		virtual
		returns (bool)
	{

		approve(spender, safeAdd(allowed[_msgSender()][spender], addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue)
		external
		virtual
		returns (bool)
	{

		approve(spender, safeSub(allowed[_msgSender()][spender], subtractedValue));
		return true;
	}

	function approveAndCall(
		address spender,
		uint256 tokens,
		bytes memory data
	) external returns (bool success) {

		allowed[_msgSender()][spender] = tokens;
		emit Approval(_msgSender(), spender, tokens);
		ApproveAndCallFallBack(spender).receiveApproval(_msgSender(), tokens, address(this), data);
		return true;
	}

	function transferAnyERC20Token(address tokenAddress, uint256 tokens)
		external
		onlyOwner
		returns (bool success)
	{

		return ERC20Interface(tokenAddress).transfer(owner, tokens);
	}

	function burn(address account, uint256 amount) external {

		require(_msgSender() == _minter, "TELE::burn: only the minter can mint");
		require(account != address(0), "TELE: burn from the zero address");

		_beforeTokenTransfer(account, address(0), amount);

		balances[account] = safeSub(balances[account], amount);

		allowed[account][_msgSender()] = safeSub(allowed[account][_msgSender()], amount);
		emit Approval(account, _msgSender(), amount);

		_totalSupply = safeSub(_totalSupply, amount);
		emit Transfer(account, address(0), amount);
		_moveDelegates(address(0), _delegates[account], amount);
	}

	function mint(address account, uint256 amount) external {

		require(_msgSender() == _minter, "TELE::mint: only the minter can mint");
		require(block.timestamp >= mintingAllowedAfter, "TELE::mint: minting not allowed yet");
		require(account != address(0), "TELE: mint to the zero address");

		mintingAllowedAfter = safeAdd(block.timestamp, minimumTimeBetweenMints);

		_beforeTokenTransfer(address(0), account, amount);

		require(amount <= safeDiv(safeMul(_totalSupply, mintCap), 1000));
		_totalSupply = safeAdd(_totalSupply, amount);
		balances[account] = safeAdd(balances[account], amount);
		emit Transfer(address(0), account, amount);
		_moveDelegates(address(0), _delegates[account], amount);
	}

	function setMinter(address minter_) external {

		require(
			_msgSender() == _minter,
			"TELE::setMinter: only the minter can change the minter address"
		);
		emit MinterChanged(_minter, minter_);
		_minter = minter_;
	}

	function delegates(address delegator) external view returns (address) {

		return _delegates[delegator];
	}

	function delegate(address delegatee) external {

		return _delegate(_msgSender(), delegatee);
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
			abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this))
		);

		bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));

		bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

		address signatory = ecrecover(digest, v, r, s);
		require(signatory != address(0), "TELE::delegateBySig: invalid signature");
		require(nonce == nonces[signatory]++, "TELE::delegateBySig: invalid nonce");
		require(block.timestamp <= expiry, "TELE::delegateBySig: signature expired");
		return _delegate(signatory, delegatee);
	}

	function getCurrentVotes(address account) external view returns (uint256) {

		uint32 nCheckpoints = numCheckpoints[account];
		return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
	}

	function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256) {

		require(blockNumber < block.number, "TELE::getPriorVotes: not yet determined");

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

	function _transferTokens(address to, uint256 tokens) internal {

		balances[_msgSender()] = safeSub(balances[_msgSender()], tokens);
		balances[to] = safeAdd(balances[to], tokens);
		_moveDelegates(_delegates[_msgSender()], _delegates[to], tokens);
	}

	function _delegate(address delegator, address delegatee) internal {

		address currentDelegate = _delegates[delegator];
		uint256 delegatorBalance = balanceOf(delegator); // balance of underlying TELEs (not scaled);
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
				uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
				uint256 srcRepNew = safeSub(srcRepOld, amount);
				_writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
			}

			if (dstRep != address(0)) {
				uint32 dstRepNum = numCheckpoints[dstRep];
				uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
				uint256 dstRepNew = safeAdd(dstRepOld, amount);
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
			"TELE::_writeCheckpoint: block number exceeds 32 bits"
		);

		if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
			checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
		} else {
			checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
			numCheckpoints[delegatee] = nCheckpoints + 1;
		}

		emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
	}

	function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {

		require(n < 2**32, errorMessage);
		return uint32(n);
	}

	function getChainId() internal view returns (uint256) {

		uint256 chainId;
		assembly {
			chainId := chainid()
		}
		return chainId;
	}

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 amount
	) internal virtual {}

}