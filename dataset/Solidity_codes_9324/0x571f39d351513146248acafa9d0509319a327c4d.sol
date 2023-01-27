pragma solidity 0.8.6;

interface ISwapRouter {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);


    function WETH9() external pure returns (address);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT
pragma solidity 0.8.6;


contract HATToken is IERC20 {

    struct PendingMinter {
        uint256 seedAmount;
        uint256 setMinterPendingAt;
    }

    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    string public constant name = "hats.finance";

    string public constant symbol = "HAT";

    uint8 public constant decimals = 18;

    uint public override totalSupply;

    address public governance;
    address public governancePending;
    uint256 public setGovernancePendingAt;
    uint256 public immutable timeLockDelay;
    uint256 public constant CAP = 10000000e18;

    mapping (address => uint256) public minters;

    mapping (address => PendingMinter) public pendingMinters;

    mapping (address => mapping (address => uint96)) internal allowances;

    mapping (address => uint96) internal balances;

    mapping (address => address) public delegates;

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    mapping (address => uint) public nonces;

    bytes32 public constant DOMAIN_TYPEHASH =
    keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH =
    keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    bytes32 public constant PERMIT_TYPEHASH =
    keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    event MinterPending(address indexed minter, uint256 seedAmount, uint256 at);
    event MinterChanged(address indexed minter, uint256 seedAmount);
    event GovernancePending(address indexed oldGovernance, address indexed newGovernance, uint256 at);
    event GovernanceChanged(address indexed oldGovernance, address indexed newGovernance);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    constructor(address _governance, uint256 _timeLockDelay) {
        governance = _governance;
        timeLockDelay = _timeLockDelay;
    }

    function setPendingGovernance(address _governance) external {
        require(msg.sender == governance, "HAT:!governance");
        require(_governance != address(0), "HAT:!_governance");
        governancePending = _governance;
        setGovernancePendingAt = block.timestamp;
        emit GovernancePending(governance, _governance, setGovernancePendingAt);
    }

    function confirmGovernance() external {
        require(msg.sender == governance, "HAT:!governance");
        require(setGovernancePendingAt > 0, "HAT:!governancePending");
        require(block.timestamp - setGovernancePendingAt > timeLockDelay,
        "HAT: cannot confirm governance at this time");
        emit GovernanceChanged(governance, governancePending);
        governance = governancePending;
        setGovernancePendingAt = 0;
    }

    function setPendingMinter(address _minter, uint256 _cap) external {
        require(msg.sender == governance, "HAT::!governance");
        pendingMinters[_minter].seedAmount = _cap;
        pendingMinters[_minter].setMinterPendingAt = block.timestamp;
        emit MinterPending(_minter, _cap, pendingMinters[_minter].setMinterPendingAt);
    }

    function confirmMinter(address _minter) external {
        require(msg.sender == governance, "HAT::mint: only the governance can confirm minter");
        require(pendingMinters[_minter].setMinterPendingAt > 0, "HAT:: no pending minter was set");
        require(block.timestamp - pendingMinters[_minter].setMinterPendingAt > timeLockDelay,
        "HATToken: cannot confirm at this time");
        minters[_minter] = pendingMinters[_minter].seedAmount;
        pendingMinters[_minter].setMinterPendingAt = 0;
        emit MinterChanged(_minter, pendingMinters[_minter].seedAmount);
    }

    function burn(uint256 _amount) external {
        return _burn(msg.sender, _amount);
    }

    function mint(address _account, uint _amount) external {
        require(minters[msg.sender] >= _amount, "HATToken: amount greater than limitation");
        minters[msg.sender] = SafeMath.sub(minters[msg.sender], _amount);
        _mint(_account, _amount);
    }

    function allowance(address account, address spender) external override view returns (uint) {
        return allowances[account][spender];
    }

    function approve(address spender, uint rawAmount) external override returns (bool) {
        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount, "HAT::approve: amount exceeds 96 bits");
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) external virtual returns (bool) {
        require(spender != address(0), "HAT: increaseAllowance to the zero address");
        uint96 valueToAdd = safe96(addedValue, "HAT::increaseAllowance: addedValue exceeds 96 bits");
        allowances[msg.sender][spender] =
        add96(allowances[msg.sender][spender], valueToAdd, "HAT::increaseAllowance: overflows");
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) external virtual returns (bool) {
        require(spender != address(0), "HAT: decreaseAllowance to the zero address");
        uint96 valueTosubtract = safe96(subtractedValue, "HAT::decreaseAllowance: subtractedValue exceeds 96 bits");
        allowances[msg.sender][spender] = sub96(allowances[msg.sender][spender], valueTosubtract,
        "HAT::decreaseAllowance: spender allowance is less than subtractedValue");
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }

    function permit(address owner, address spender, uint rawAmount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount, "HAT::permit: amount exceeds 96 bits");
        }

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, rawAmount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "HAT::permit: invalid signature");
        require(signatory == owner, "HAT::permit: unauthorized");
        require(block.timestamp <= deadline, "HAT::permit: signature expired");

        allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) external view override returns (uint) {
        return balances[account];
    }

    function transfer(address dst, uint rawAmount) external override returns (bool) {
        uint96 amount = safe96(rawAmount, "HAT::transfer: amount exceeds 96 bits");
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint rawAmount) external override returns (bool) {
        address spender = msg.sender;
        uint96 spenderAllowance = allowances[src][spender];
        uint96 amount = safe96(rawAmount, "HAT::approve: amount exceeds 96 bits");

        if (spender != src && spenderAllowance != type(uint96).max) {
            uint96 newAllowance = sub96(spenderAllowance, amount,
            "HAT::transferFrom: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "HAT::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "HAT::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "HAT::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber) external view returns (uint96) {
        require(blockNumber < block.number, "HAT::getPriorVotes: not yet determined");

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

    function _mint(address dst, uint rawAmount) internal {
        require(dst != address(0), "HAT::mint: cannot transfer to the zero address");
        require(SafeMath.add(totalSupply, rawAmount) <= CAP, "ERC20Capped: CAP exceeded");

        uint96 amount = safe96(rawAmount, "HAT::mint: amount exceeds 96 bits");
        totalSupply = safe96(SafeMath.add(totalSupply, amount), "HAT::mint: totalSupply exceeds 96 bits");

        balances[dst] = add96(balances[dst], amount, "HAT::mint: transfer amount overflows");
        emit Transfer(address(0), dst, amount);

        _moveDelegates(address(0), delegates[dst], amount);
    }

    function _burn(address src, uint rawAmount) internal {
        require(src != address(0), "HAT::burn: cannot burn to the zero address");

        uint96 amount = safe96(rawAmount, "HAT::burn: amount exceeds 96 bits");
        totalSupply = safe96(SafeMath.sub(totalSupply, amount), "HAT::mint: totalSupply exceeds 96 bits");

        balances[src] = sub96(balances[src], amount, "HAT::burn: burn amount exceeds balance");
        emit Transfer(src, address(0), amount);

        _moveDelegates(delegates[src], address(0), amount);
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _transferTokens(address src, address dst, uint96 amount) internal {
        require(src != address(0), "HAT::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "HAT::_transferTokens: cannot transfer to the zero address");

        balances[src] = sub96(balances[src], amount, "HAT::_transferTokens: transfer amount exceeds balance");
        balances[dst] = add96(balances[dst], amount, "HAT::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);

        _moveDelegates(delegates[src], delegates[dst], amount);
    }

    function _moveDelegates(address srcRep, address dstRep, uint96 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, "HAT::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "HAT::_moveVotes: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {
        uint32 blockNumber = safe32(block.number, "HAT::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity 0.8.6;




contract HATMaster is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // The user share of the pool based on the amount of lpToken the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolUpdate {
        uint256 blockNumber;// update blocknumber
        uint256 totalAllocPoint; //totalAllocPoint
    }

    struct RewardsSplit {
        uint256 hackerVestedReward;
        uint256 hackerReward;
        uint256 committeeReward;
        uint256 swapAndBurn;
        uint256 governanceHatReward;
        uint256 hackerHatReward;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 rewardPerShare;
        uint256 totalUsersAmount;
        uint256 lastProcessedTotalAllocPoint;
        uint256 balance;
    }

    struct PoolReward {
        RewardsSplit rewardsSplit;
        uint256[]  rewardsLevels;
        bool committeeCheckIn;
        uint256 vestingDuration;
        uint256 vestingPeriods;
    }

    HATToken public immutable HAT;
    uint256 public immutable REWARD_PER_BLOCK;
    uint256 public immutable START_BLOCK;
    uint256 public immutable MULTIPLIER_PERIOD;

    PoolInfo[] public poolInfo;
    PoolUpdate[] public globalPoolUpdates;
    mapping(address => uint256) public poolId1; // poolId1 count from 1, subtraction 1 before using with poolInfo
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    mapping (uint256=>PoolReward) internal poolsRewards;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SendReward(address indexed user, uint256 indexed pid, uint256 amount, uint256 requestedAmount);
    event MassUpdatePools(uint256 _fromPid, uint256 _toPid);

    constructor(
        HATToken _hat,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _multiplierPeriod
    ) {
        HAT = _hat;
        REWARD_PER_BLOCK = _rewardPerBlock;
        START_BLOCK = _startBlock;
        MULTIPLIER_PERIOD = _multiplierPeriod;
    }

    function massUpdatePools(uint256 _fromPid, uint256 _toPid) external {
        require(_toPid <= poolInfo.length, "pool range is too big");
        require(_fromPid <= _toPid, "invalid pool range");
        for (uint256 pid = _fromPid; pid < _toPid; ++pid) {
            updatePool(pid);
        }
        emit MassUpdatePools(_fromPid, _toPid);
    }

    function claimReward(uint256 _pid) external {
        _deposit(_pid, 0);
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 lastRewardBlock = pool.lastRewardBlock;
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint256 totalUsersAmount = pool.totalUsersAmount;
        uint256 lastPoolUpdate = globalPoolUpdates.length-1;
        if (totalUsersAmount == 0) {
            pool.lastRewardBlock = block.number;
            pool.lastProcessedTotalAllocPoint = lastPoolUpdate;
            return;
        }
        uint256 reward = calcPoolReward(_pid, lastRewardBlock, lastPoolUpdate);
        uint256 amountCanMint = HAT.minters(address(this));
        reward = amountCanMint < reward ? amountCanMint : reward;
        if (reward > 0) {
            HAT.mint(address(this), reward);
        }
        pool.rewardPerShare = pool.rewardPerShare.add(reward.mul(1e12).div(totalUsersAmount));
        pool.lastRewardBlock = block.number;
        pool.lastProcessedTotalAllocPoint = lastPoolUpdate;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256 result) {
        uint256[25] memory rewardMultipliers = [uint256(4413), 4413, 8825, 7788, 6873, 6065,
                                            5353, 4724, 4169, 3679, 3247, 2865,
                                            2528, 2231, 1969, 1738, 1534, 1353,
                                            1194, 1054, 930, 821, 724, 639, 0];
        uint256 max = rewardMultipliers.length;
        uint256 i = (_from - START_BLOCK) / MULTIPLIER_PERIOD + 1;
        for (; i < max; i++) {
            uint256 endBlock = MULTIPLIER_PERIOD * i + START_BLOCK;
            if (_to <= endBlock) {
                break;
            }
            result += (endBlock - _from) * rewardMultipliers[i-1];
            _from = endBlock;
        }
        result += (_to - _from) * rewardMultipliers[i > max ? (max-1) : (i-1)];
    }

    function getRewardForBlocksRange(uint256 _from, uint256 _to, uint256 _allocPoint, uint256 _totalAllocPoint)
    public
    view
    returns (uint256 reward) {
        if (_totalAllocPoint > 0) {
            reward = getMultiplier(_from, _to).mul(REWARD_PER_BLOCK).mul(_allocPoint).div(_totalAllocPoint).div(100);
        }
    }

    function calcPoolReward(uint256 _pid, uint256 _from, uint256 _lastPoolUpdate) public view returns(uint256 reward) {
        uint256 poolAllocPoint = poolInfo[_pid].allocPoint;
        uint256 i = poolInfo[_pid].lastProcessedTotalAllocPoint;
        for (; i < _lastPoolUpdate; i++) {
            uint256 nextUpdateBlock = globalPoolUpdates[i+1].blockNumber;
            reward =
            reward.add(getRewardForBlocksRange(_from,
                                            nextUpdateBlock,
                                            poolAllocPoint,
                                            globalPoolUpdates[i].totalAllocPoint));
            _from = nextUpdateBlock;
        }
        return reward.add(getRewardForBlocksRange(_from,
                                                block.number,
                                                poolAllocPoint,
                                                globalPoolUpdates[i].totalAllocPoint));
    }

    function _deposit(uint256 _pid, uint256 _amount) internal nonReentrant {
        require(poolsRewards[_pid].committeeCheckIn, "committee not checked in yet");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.rewardPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeTransferReward(msg.sender, pending, _pid);
            }
        }
        if (_amount > 0) {
            uint256 lpSupply = pool.balance;
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            pool.balance = pool.balance.add(_amount);
            uint256 factoredAmount = _amount;
            if (pool.totalUsersAmount > 0) {
                factoredAmount = pool.totalUsersAmount.mul(_amount).div(lpSupply);
            }
            user.amount = user.amount.add(factoredAmount);
            pool.totalUsersAmount = pool.totalUsersAmount.add(factoredAmount);
        }
        user.rewardDebt = user.amount.mul(pool.rewardPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function _withdraw(uint256 _pid, uint256 _amount) internal nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not enough user balance");

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.rewardPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeTransferReward(msg.sender, pending, _pid);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            uint256 amountToWithdraw = _amount.mul(pool.balance).div(pool.totalUsersAmount);
            pool.balance = pool.balance.sub(amountToWithdraw);
            pool.lpToken.safeTransfer(msg.sender, amountToWithdraw);
            pool.totalUsersAmount = pool.totalUsersAmount.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.rewardPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function _emergencyWithdraw(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "user.amount = 0");
        uint256 factoredBalance = user.amount.mul(pool.balance).div(pool.totalUsersAmount);
        pool.totalUsersAmount = pool.totalUsersAmount.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        pool.balance = pool.balance.sub(factoredBalance);
        pool.lpToken.safeTransfer(msg.sender, factoredBalance);
        emit EmergencyWithdraw(msg.sender, _pid, factoredBalance);
    }

    function add(uint256 _allocPoint, IERC20 _lpToken) internal {
        require(poolId1[address(_lpToken)] == 0, "HATMaster::add: lpToken is already in pool");
        poolId1[address(_lpToken)] = poolInfo.length + 1;
        uint256 lastRewardBlock = block.number > START_BLOCK ? block.number : START_BLOCK;
        uint256 totalAllocPoint = (globalPoolUpdates.length == 0) ? _allocPoint :
        globalPoolUpdates[globalPoolUpdates.length-1].totalAllocPoint.add(_allocPoint);

        if (globalPoolUpdates.length > 0 &&
            globalPoolUpdates[globalPoolUpdates.length-1].blockNumber == block.number) {
            globalPoolUpdates[globalPoolUpdates.length-1].totalAllocPoint = totalAllocPoint;
        } else {
            globalPoolUpdates.push(PoolUpdate({
                blockNumber: block.number,
                totalAllocPoint: totalAllocPoint
            }));
        }

        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            rewardPerShare: 0,
            totalUsersAmount: 0,
            lastProcessedTotalAllocPoint: globalPoolUpdates.length-1,
            balance: 0
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint) internal {
        updatePool(_pid);
        uint256 totalAllocPoint =
        globalPoolUpdates[globalPoolUpdates.length-1].totalAllocPoint
        .sub(poolInfo[_pid].allocPoint).add(_allocPoint);

        if (globalPoolUpdates[globalPoolUpdates.length-1].blockNumber == block.number) {
            globalPoolUpdates[globalPoolUpdates.length-1].totalAllocPoint = totalAllocPoint;
        } else {
            globalPoolUpdates.push(PoolUpdate({
                blockNumber: block.number,
                totalAllocPoint: totalAllocPoint
            }));
        }
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function safeTransferReward(address _to, uint256 _amount, uint256 _pid) internal {
        uint256 hatBalance = HAT.balanceOf(address(this));
        if (_amount > hatBalance) {
            HAT.transfer(_to, hatBalance);
            emit SendReward(_to, _pid, hatBalance, _amount);
        } else {
            HAT.transfer(_to, _amount);
            emit SendReward(_to, _pid, _amount, _amount);
        }
    }
}// MIT

pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;


interface ITokenLock {
    enum Revocability { NotSet, Enabled, Disabled }


    function currentBalance() external view returns (uint256);


    function currentTime() external view returns (uint256);

    function duration() external view returns (uint256);

    function sinceStartTime() external view returns (uint256);

    function amountPerPeriod() external view returns (uint256);

    function periodDuration() external view returns (uint256);

    function currentPeriod() external view returns (uint256);

    function passedPeriods() external view returns (uint256);


    function availableAmount() external view returns (uint256);

    function vestedAmount() external view returns (uint256);

    function releasableAmount() external view returns (uint256);

    function totalOutstandingAmount() external view returns (uint256);

    function surplusAmount() external view returns (uint256);


    function release() external;

    function withdrawSurplus(uint256 _amount) external;

    function revoke() external;
}// MIT
pragma solidity 0.8.6;


interface ITokenLockFactory {
    function setMasterCopy(address _masterCopy) external;

    function createTokenLock(
        address _token,
        address _owner,
        address _beneficiary,
        uint256 _managedAmount,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _periods,
        uint256 _releaseStartTime,
        uint256 _vestingCliffTime,
        ITokenLock.Revocability _revocable,
        bool _canDelegate
    ) external returns(address contractAddress);
}// MIT

pragma solidity 0.8.6;


contract Governable {
    address private _governance;
    address public governancePending;
    uint256 public setGovernancePendingAt;
    uint256 public constant TIME_LOCK_DELAY = 2 days;


    event GovernorshipTransferred(address indexed _previousGovernance, address indexed _newGovernance);
    event GovernancePending(address indexed _previousGovernance, address indexed _newGovernance, uint256 _at);

    modifier onlyGovernance() {
        require(msg.sender == _governance, "only governance");
        _;
    }

    function setPendingGovernance(address _newGovernance) external  onlyGovernance {
        require(_newGovernance != address(0), "Governable:new governance is the zero address");
        governancePending = _newGovernance;
        setGovernancePendingAt = block.timestamp;
        emit GovernancePending(_governance, _newGovernance, setGovernancePendingAt);
    }

    function transferGovernorship() external onlyGovernance {
        require(setGovernancePendingAt > 0, "Governable: no pending governance");
        require(block.timestamp - setGovernancePendingAt > TIME_LOCK_DELAY,
        "Governable: cannot confirm governance at this time");
        emit GovernorshipTransferred(_governance, governancePending);
        _governance = governancePending;
        setGovernancePendingAt = 0;
    }

    function governance() public view returns (address) {
        return _governance;
    }

    function initialize(address _initialGovernance) internal {
        _governance = _initialGovernance;
        emit GovernorshipTransferred(address(0), _initialGovernance);
    }
}// MIT

pragma solidity 0.8.6;


contract  HATVaults is Governable, HATMaster {
    using SafeMath  for uint256;
    using SafeERC20 for IERC20;

    struct PendingApproval {
        address beneficiary;
        uint256 severity;
        address approver;
    }

    struct ClaimReward {
        uint256 hackerVestedReward;
        uint256 hackerReward;
        uint256 committeeReward;
        uint256 swapAndBurn;
        uint256 governanceHatReward;
        uint256 hackerHatReward;
    }

    struct PendingRewardsLevels {
        uint256 timestamp;
        uint256[] rewardsLevels;
    }

    struct GeneralParameters {
        uint256 hatVestingDuration;
        uint256 hatVestingPeriods;
        uint256 withdrawPeriod;
        uint256 safetyPeriod; //withdraw disable period in seconds
        uint256 setRewardsLevelsDelay;
        uint256 withdrawRequestEnablePeriod;
        uint256 withdrawRequestPendingPeriod;
        uint256 claimFee;  //claim fee in ETH
    }

    mapping(uint256=>address) public committees;
    mapping(address => uint256) public swapAndBurns;
    mapping(address => mapping(address => uint256)) public hackersHatRewards;
    mapping(address => uint256) public governanceHatRewards;
    mapping(uint256 => PendingApproval) public pendingApprovals;
    mapping(uint256 => mapping(address => uint256)) public withdrawRequests;
    mapping(uint256 => PendingRewardsLevels) public pendingRewardsLevels;

    mapping(uint256 => bool) public poolDepositPause;

    GeneralParameters public generalParameters;

    uint256 internal constant REWARDS_LEVEL_DENOMINATOR = 10000;
    ITokenLockFactory public immutable tokenLockFactory;
    ISwapRouter public immutable uniSwapRouter;
    uint256 public constant MINIMUM_DEPOSIT = 1e6;

    modifier onlyCommittee(uint256 _pid) {
        require(committees[_pid] == msg.sender, "only committee");
        _;
    }

    modifier noPendingApproval(uint256 _pid) {
        require(pendingApprovals[_pid].beneficiary == address(0), "pending approval exist");
        _;
    }

    modifier noSafetyPeriod() {
        require(block.timestamp % (generalParameters.withdrawPeriod + generalParameters.safetyPeriod) <
        generalParameters.withdrawPeriod,
        "safety period");
        _;
    }

    event SetCommittee(uint256 indexed _pid, address indexed _committee);

    event AddPool(uint256 indexed _pid,
                uint256 indexed _allocPoint,
                address indexed _lpToken,
                address _committee,
                string _descriptionHash,
                uint256[] _rewardsLevels,
                RewardsSplit _rewardsSplit,
                uint256 _rewardVestingDuration,
                uint256 _rewardVestingPeriods);

    event SetPool(uint256 indexed _pid, uint256 indexed _allocPoint, bool indexed _registered, string _descriptionHash);
    event Claim(address indexed _claimer, string _descriptionHash);
    event SetRewardsSplit(uint256 indexed _pid, RewardsSplit _rewardsSplit);
    event SetRewardsLevels(uint256 indexed _pid, uint256[] _rewardsLevels);
    event PendingRewardsLevelsLog(uint256 indexed _pid, uint256[] _rewardsLevels, uint256 _timeStamp);

    event SwapAndSend(uint256 indexed _pid,
                    address indexed _beneficiary,
                    uint256 indexed _amountSwaped,
                    uint256 _amountReceived,
                    address _tokenLock);

    event SwapAndBurn(uint256 indexed _pid, uint256 indexed _amountSwaped, uint256 indexed _amountBurned);
    event SetVestingParams(uint256 indexed _pid, uint256 indexed _duration, uint256 indexed _periods);
    event SetHatVestingParams(uint256 indexed _duration, uint256 indexed _periods);

    event ClaimApprove(address indexed _approver,
                    uint256 indexed _pid,
                    address indexed _beneficiary,
                    uint256 _severity,
                    address _tokenLock,
                    ClaimReward _claimReward);

    event PendingApprovalLog(uint256 indexed _pid,
                            address indexed _beneficiary,
                            uint256 indexed _severity,
                            address _approver);

    event WithdrawRequest(uint256 indexed _pid,
                        address indexed _beneficiary,
                        uint256 indexed _withdrawEnableTime);

    event SetWithdrawSafetyPeriod(uint256 indexed _withdrawPeriod, uint256 indexed _safetyPeriod);

    event RewardDepositors(uint256 indexed _pid, uint256 indexed _amount);

    constructor(
        address _rewardsToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _multiplierPeriod,
        address _hatGovernance,
        ISwapRouter _uniSwapRouter,
        ITokenLockFactory _tokenLockFactory
    ) HATMaster(HATToken(_rewardsToken), _rewardPerBlock, _startBlock, _multiplierPeriod) {
        Governable.initialize(_hatGovernance);
        uniSwapRouter = _uniSwapRouter;
        tokenLockFactory = _tokenLockFactory;
        generalParameters = GeneralParameters({
            hatVestingDuration: 90 days,
            hatVestingPeriods:90,
            withdrawPeriod: 11 hours,
            safetyPeriod: 1 hours,
            setRewardsLevelsDelay: 2 days,
            withdrawRequestEnablePeriod: 7 days,
            withdrawRequestPendingPeriod: 7 days,
            claimFee: 0
        });
    }

    function pendingApprovalClaim(uint256 _pid, address _beneficiary, uint256 _severity)
    external
    onlyCommittee(_pid)
    noPendingApproval(_pid) {
        require(_beneficiary != address(0), "beneficiary is zero");
        require(block.timestamp % (generalParameters.withdrawPeriod + generalParameters.safetyPeriod) >=
        generalParameters.withdrawPeriod,
        "none safety period");
        require(_severity < poolsRewards[_pid].rewardsLevels.length, "_severity is not in the range");

        pendingApprovals[_pid] = PendingApproval({
            beneficiary: _beneficiary,
            severity: _severity,
            approver: msg.sender
        });
        emit PendingApprovalLog(_pid, _beneficiary, _severity, msg.sender);
    }

    function setWithdrawRequestParams(uint256 _withdrawRequestPendingPeriod, uint256  _withdrawRequestEnablePeriod)
    external
    onlyGovernance {
        generalParameters.withdrawRequestPendingPeriod = _withdrawRequestPendingPeriod;
        generalParameters.withdrawRequestEnablePeriod = _withdrawRequestEnablePeriod;
    }

    function dismissPendingApprovalClaim(uint256 _pid) external onlyGovernance {
        delete pendingApprovals[_pid];
    }

    function approveClaim(uint256 _pid) external onlyGovernance nonReentrant {
        require(pendingApprovals[_pid].beneficiary != address(0), "no pending approval");
        PoolReward storage poolReward = poolsRewards[_pid];
        PendingApproval memory pendingApproval = pendingApprovals[_pid];
        delete pendingApprovals[_pid];

        IERC20 lpToken = poolInfo[_pid].lpToken;
        ClaimReward memory claimRewards = calcClaimRewards(_pid, pendingApproval.severity);
        poolInfo[_pid].balance = poolInfo[_pid].balance.sub(
                            claimRewards.hackerReward
                            .add(claimRewards.hackerVestedReward)
                            .add(claimRewards.committeeReward)
                            .add(claimRewards.swapAndBurn)
                            .add(claimRewards.hackerHatReward)
                            .add(claimRewards.governanceHatReward));
        address tokenLock;
        if (claimRewards.hackerVestedReward > 0) {
            tokenLock = tokenLockFactory.createTokenLock(
            address(lpToken),
            0x000000000000000000000000000000000000dEaD, //this address as owner, so it can do nothing.
            pendingApproval.beneficiary,
            claimRewards.hackerVestedReward,
            block.timestamp, //start
            block.timestamp + poolReward.vestingDuration, //end
            poolReward.vestingPeriods,
            0, //no release start
            0, //no cliff
            ITokenLock.Revocability.Disabled,
            false
        );
            lpToken.safeTransfer(tokenLock, claimRewards.hackerVestedReward);
        }
        lpToken.safeTransfer(pendingApproval.beneficiary, claimRewards.hackerReward);
        lpToken.safeTransfer(pendingApproval.approver, claimRewards.committeeReward);
        swapAndBurns[address(lpToken)] = swapAndBurns[address(lpToken)].add(claimRewards.swapAndBurn);
        governanceHatRewards[address(lpToken)] =
        governanceHatRewards[address(lpToken)].add(claimRewards.governanceHatReward);
        hackersHatRewards[pendingApproval.beneficiary][address(lpToken)] =
        hackersHatRewards[pendingApproval.beneficiary][address(lpToken)].add(claimRewards.hackerHatReward);

        emit ClaimApprove(msg.sender,
                        _pid,
                        pendingApproval.beneficiary,
                        pendingApproval.severity,
                        tokenLock,
                        claimRewards);
        assert(poolInfo[_pid].balance > 0);
    }

    function rewardDepositors(uint256 _pid, uint256 _amount) external {
        require(poolInfo[_pid].balance.add(_amount).div(MINIMUM_DEPOSIT) < poolInfo[_pid].totalUsersAmount,
        "amount to reward is too big");
        poolInfo[_pid].lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        poolInfo[_pid].balance = poolInfo[_pid].balance.add(_amount);
        emit RewardDepositors(_pid, _amount);
    }

    function setClaimFee(uint256 _fee) external onlyGovernance {
        generalParameters.claimFee = _fee;
    }

    function setWithdrawSafetyPeriod(uint256 _withdrawPeriod, uint256 _safetyPeriod) external onlyGovernance {
        generalParameters.withdrawPeriod = _withdrawPeriod;
        generalParameters.safetyPeriod = _safetyPeriod;
        emit SetWithdrawSafetyPeriod(generalParameters.withdrawPeriod, generalParameters.safetyPeriod);
    }

    function claim(string memory _descriptionHash) external payable {
        if (generalParameters.claimFee > 0) {
            require(msg.value >= generalParameters.claimFee, "not enough fee payed");
            payable(governance()).transfer(msg.value);
        }
        emit Claim(msg.sender, _descriptionHash);
    }

    function setVestingParams(uint256 _pid, uint256 _duration, uint256 _periods) external onlyGovernance {
        require(_duration < 120 days, "vesting duration is too long");
        require(_periods > 0, "vesting periods cannot be zero");
        require(_duration >= _periods, "vesting duration smaller than periods");
        poolsRewards[_pid].vestingDuration = _duration;
        poolsRewards[_pid].vestingPeriods = _periods;
        emit SetVestingParams(_pid, _duration, _periods);
    }

    function setHatVestingParams(uint256 _duration, uint256 _periods) external onlyGovernance {
        require(_duration < 180 days, "vesting duration is too long");
        require(_periods > 0, "vesting periods cannot be zero");
        require(_duration >= _periods, "vesting duration smaller than periods");
        generalParameters.hatVestingDuration = _duration;
        generalParameters.hatVestingPeriods = _periods;
        emit SetHatVestingParams(_duration, _periods);
    }

    function setRewardsSplit(uint256 _pid, RewardsSplit memory _rewardsSplit)
    external
    onlyGovernance noPendingApproval(_pid) noSafetyPeriod {
        validateSplit(_rewardsSplit);
        poolsRewards[_pid].rewardsSplit = _rewardsSplit;
        emit SetRewardsSplit(_pid, _rewardsSplit);
    }

    function setRewardsLevelsDelay(uint256 _delay)
    external
    onlyGovernance {
        require(_delay >= 2 days, "delay is too short");
        generalParameters.setRewardsLevelsDelay = _delay;
    }

    function setPendingRewardsLevels(uint256 _pid, uint256[] memory _rewardsLevels)
    external
    onlyCommittee(_pid) noPendingApproval(_pid) {
        pendingRewardsLevels[_pid].rewardsLevels = checkRewardsLevels(_rewardsLevels);
        pendingRewardsLevels[_pid].timestamp = block.timestamp;
        emit PendingRewardsLevelsLog(_pid, _rewardsLevels, pendingRewardsLevels[_pid].timestamp);
    }

    function setRewardsLevels(uint256 _pid)
    external
    onlyCommittee(_pid) noPendingApproval(_pid) {
        require(pendingRewardsLevels[_pid].timestamp > 0, "no pending set rewards levels");
        require(block.timestamp - pendingRewardsLevels[_pid].timestamp > generalParameters.setRewardsLevelsDelay,
        "cannot confirm setRewardsLevels at this time");
        poolsRewards[_pid].rewardsLevels = pendingRewardsLevels[_pid].rewardsLevels;
        delete pendingRewardsLevels[_pid];
        emit SetRewardsLevels(_pid, poolsRewards[_pid].rewardsLevels);
    }

    function committeeCheckIn(uint256 _pid) external onlyCommittee(_pid) {
        poolsRewards[_pid].committeeCheckIn = true;
    }


    function setCommittee(uint256 _pid, address _committee)
    external {
        require(_committee != address(0), "committee is zero");
        if (msg.sender == governance() && committees[_pid] != msg.sender) {
            require(!poolsRewards[_pid].committeeCheckIn, "Committee already checked in");
        } else {
            require(committees[_pid] == msg.sender, "Only committee");
        }

        committees[_pid] = _committee;

        emit SetCommittee(_pid, _committee);
    }

    function addPool(uint256 _allocPoint,
                    address _lpToken,
                    address _committee,
                    uint256[] memory _rewardsLevels,
                    RewardsSplit memory _rewardsSplit,
                    string memory _descriptionHash,
                    uint256[2] memory _rewardVestingParams)
    external
    onlyGovernance {
        require(_rewardVestingParams[0] < 120 days, "vesting duration is too long");
        require(_rewardVestingParams[1] > 0, "vesting periods cannot be zero");
        require(_rewardVestingParams[0] >= _rewardVestingParams[1], "vesting duration smaller than periods");
        require(_committee != address(0), "committee is zero");
        add(_allocPoint, IERC20(_lpToken));
        uint256 poolId = poolInfo.length-1;
        committees[poolId] = _committee;
        uint256[] memory rewardsLevels = checkRewardsLevels(_rewardsLevels);

        RewardsSplit memory rewardsSplit = (_rewardsSplit.hackerVestedReward == 0 && _rewardsSplit.hackerReward == 0) ?
        getDefaultRewardsSplit() : _rewardsSplit;

        validateSplit(rewardsSplit);
        poolsRewards[poolId] = PoolReward({
            rewardsLevels: rewardsLevels,
            rewardsSplit: rewardsSplit,
            committeeCheckIn: false,
            vestingDuration: _rewardVestingParams[0],
            vestingPeriods: _rewardVestingParams[1]
        });

        emit AddPool(poolId,
                    _allocPoint,
                    address(_lpToken),
                    _committee,
                    _descriptionHash,
                    rewardsLevels,
                    rewardsSplit,
                    _rewardVestingParams[0],
                    _rewardVestingParams[1]);
    }

    function setPool(uint256 _pid,
                    uint256 _allocPoint,
                    bool _registered,
                    bool _depositPause,
                    string memory _descriptionHash)
    external onlyGovernance {
        require(poolInfo[_pid].lpToken != IERC20(address(0)), "pool does not exist");
        set(_pid, _allocPoint);
        poolDepositPause[_pid] = _depositPause;
        emit SetPool(_pid, _allocPoint, _registered, _descriptionHash);
    }

    function swapBurnSend(uint256 _pid,
                        address _beneficiary,
                        uint256 _amountOutMinimum,
                        uint24[2] memory _fees)
    external
    onlyGovernance {
        IERC20 token = poolInfo[_pid].lpToken;
        uint256 amountToSwapAndBurn = swapAndBurns[address(token)];
        uint256 amountForHackersHatRewards = hackersHatRewards[_beneficiary][address(token)];
        uint256 amount = amountToSwapAndBurn.add(amountForHackersHatRewards).add(governanceHatRewards[address(token)]);
        require(amount > 0, "amount is zero");
        swapAndBurns[address(token)] = 0;
        governanceHatRewards[address(token)] = 0;
        hackersHatRewards[_beneficiary][address(token)] = 0;
        uint256 hatsReceived = swapTokenForHAT(amount, token, _fees, _amountOutMinimum);
        uint256 burntHats = hatsReceived.mul(amountToSwapAndBurn).div(amount);
        if (burntHats > 0) {
            HAT.burn(burntHats);
        }
        emit SwapAndBurn(_pid, amount, burntHats);
        address tokenLock;
        uint256 hackerReward = hatsReceived.mul(amountForHackersHatRewards).div(amount);
        if (hackerReward > 0) {
            tokenLock = tokenLockFactory.createTokenLock(
                address(HAT),
                0x000000000000000000000000000000000000dEaD, //this address as owner, so it can do nothing.
                _beneficiary,
                hackerReward,
                block.timestamp, //start
                block.timestamp + generalParameters.hatVestingDuration, //end
                generalParameters.hatVestingPeriods,
                0, //no release start
                0, //no cliff
                ITokenLock.Revocability.Disabled,
                true
            );
            HAT.transfer(tokenLock, hackerReward);
        }
        emit SwapAndSend(_pid, _beneficiary, amount, hackerReward, tokenLock);
        HAT.transfer(governance(), hatsReceived.sub(hackerReward).sub(burntHats));
    }

    function withdrawRequest(uint256 _pid) external {
        require(block.timestamp > withdrawRequests[_pid][msg.sender] + generalParameters.withdrawRequestEnablePeriod,
        "pending withdraw request exist");
        withdrawRequests[_pid][msg.sender] = block.timestamp + generalParameters.withdrawRequestPendingPeriod;
        emit WithdrawRequest(_pid, msg.sender, withdrawRequests[_pid][msg.sender]);
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        require(!poolDepositPause[_pid], "deposit paused");
        require(_amount >= MINIMUM_DEPOSIT, "amount less than 1e6");
        withdrawRequests[_pid][msg.sender] = 0;
        _deposit(_pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _shares) external {
        checkWithdrawRequest(_pid);
        _withdraw(_pid, _shares);
    }

    function emergencyWithdraw(uint256 _pid) external {
        checkWithdrawRequest(_pid);
        _emergencyWithdraw(_pid);
    }

    function getPoolRewardsLevels(uint256 _pid) external view returns(uint256[] memory) {
        return poolsRewards[_pid].rewardsLevels;
    }

    function getPoolRewards(uint256 _pid) external view returns(PoolReward memory) {
        return poolsRewards[_pid];
    }

    function getRewardPerBlock(uint256 _pid1) external view returns (uint256) {
        if (_pid1 == 0) {
            return getRewardForBlocksRange(block.number-1, block.number, 1, 1);
        } else {
            return getRewardForBlocksRange(block.number-1,
                                        block.number,
                                        poolInfo[_pid1 - 1].allocPoint,
                                        globalPoolUpdates[globalPoolUpdates.length-1].totalAllocPoint);
        }
    }

    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 rewardPerShare = pool.rewardPerShare;

        if (block.number > pool.lastRewardBlock && pool.totalUsersAmount > 0) {
            uint256 reward = calcPoolReward(_pid, pool.lastRewardBlock, globalPoolUpdates.length-1);
            rewardPerShare = rewardPerShare.add(reward.mul(1e12).div(pool.totalUsersAmount));
        }
        return user.amount.mul(rewardPerShare).div(1e12).sub(user.rewardDebt);
    }

    function getGlobalPoolUpdatesLength() external view returns (uint256) {
        return globalPoolUpdates.length;
    }

    function getStakedAmount(uint _pid, address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user];
        return  user.amount;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function calcClaimRewards(uint256 _pid, uint256 _severity)
    public
    view
    returns(ClaimReward memory claimRewards) {
        uint256 totalSupply = poolInfo[_pid].balance;
        require(totalSupply > 0, "totalSupply is zero");
        require(_severity < poolsRewards[_pid].rewardsLevels.length, "_severity is not in the range");
        uint256 claimRewardAmount =
        totalSupply.mul(poolsRewards[_pid].rewardsLevels[_severity]);
        claimRewards.hackerVestedReward =
        claimRewardAmount.mul(poolsRewards[_pid].rewardsSplit.hackerVestedReward)
        .div(REWARDS_LEVEL_DENOMINATOR*REWARDS_LEVEL_DENOMINATOR);
        claimRewards.hackerReward =
        claimRewardAmount.mul(poolsRewards[_pid].rewardsSplit.hackerReward)
        .div(REWARDS_LEVEL_DENOMINATOR*REWARDS_LEVEL_DENOMINATOR);
        claimRewards.committeeReward =
        claimRewardAmount.mul(poolsRewards[_pid].rewardsSplit.committeeReward)
        .div(REWARDS_LEVEL_DENOMINATOR*REWARDS_LEVEL_DENOMINATOR);
        claimRewards.swapAndBurn =
        claimRewardAmount.mul(poolsRewards[_pid].rewardsSplit.swapAndBurn)
        .div(REWARDS_LEVEL_DENOMINATOR*REWARDS_LEVEL_DENOMINATOR);
        claimRewards.governanceHatReward =
        claimRewardAmount.mul(poolsRewards[_pid].rewardsSplit.governanceHatReward)
        .div(REWARDS_LEVEL_DENOMINATOR*REWARDS_LEVEL_DENOMINATOR);
        claimRewards.hackerHatReward =
        claimRewardAmount.mul(poolsRewards[_pid].rewardsSplit.hackerHatReward)
        .div(REWARDS_LEVEL_DENOMINATOR*REWARDS_LEVEL_DENOMINATOR);
    }

    function getDefaultRewardsSplit() public pure returns (RewardsSplit memory) {
        return RewardsSplit({
            hackerVestedReward: 6000,
            hackerReward: 2000,
            committeeReward: 500,
            swapAndBurn: 0,
            governanceHatReward: 1000,
            hackerHatReward: 500
        });
    }

    function validateSplit(RewardsSplit memory _rewardsSplit) internal pure {
        require(_rewardsSplit.hackerVestedReward
            .add(_rewardsSplit.hackerReward)
            .add(_rewardsSplit.committeeReward)
            .add(_rewardsSplit.swapAndBurn)
            .add(_rewardsSplit.governanceHatReward)
            .add(_rewardsSplit.hackerHatReward) == REWARDS_LEVEL_DENOMINATOR,
        "total split % should be 10000");
    }

    function checkWithdrawRequest(uint256 _pid) internal noPendingApproval(_pid) noSafetyPeriod {
        require(block.timestamp > withdrawRequests[_pid][msg.sender] &&
                block.timestamp < withdrawRequests[_pid][msg.sender] + generalParameters.withdrawRequestEnablePeriod,
                "withdraw request not valid");
        withdrawRequests[_pid][msg.sender] = 0;
    }

    function swapTokenForHAT(uint256 _amount,
                            IERC20 _token,
                            uint24[2] memory _fees,
                            uint256 _amountOutMinimum)
    internal
    returns (uint256 hatsReceived)
    {
        if (address(_token) == address(HAT)) {
            return _amount;
        }
        require(_token.approve(address(uniSwapRouter), _amount), "token approve failed");
        uint256 hatBalanceBefore = HAT.balanceOf(address(this));
        address weth = uniSwapRouter.WETH9();
        bytes memory path;
        if (address(_token) == weth) {
            path = abi.encodePacked(address(_token), _fees[0], address(HAT));
        } else {
            path = abi.encodePacked(address(_token), _fees[0], weth, _fees[1], address(HAT));
        }
        hatsReceived = uniSwapRouter.exactInput(ISwapRouter.ExactInputParams({
            path: path,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: _amount,
            amountOutMinimum: _amountOutMinimum
        }));
        require(HAT.balanceOf(address(this)) - hatBalanceBefore >= _amountOutMinimum, "wrong amount received");
    }

    function checkRewardsLevels(uint256[] memory _rewardsLevels)
    private
    pure
    returns (uint256[] memory rewardsLevels) {

        uint256 i;
        if (_rewardsLevels.length == 0) {
            rewardsLevels = new uint256[](4);
            for (i; i < 4; i++) {
                rewardsLevels[i] = 2000*(i+1);
            }
        } else {
            for (i; i < _rewardsLevels.length; i++) {
                require(_rewardsLevels[i] < REWARDS_LEVEL_DENOMINATOR, "reward level can not be more than 10000");
            }
            rewardsLevels = _rewardsLevels;
        }
    }
}