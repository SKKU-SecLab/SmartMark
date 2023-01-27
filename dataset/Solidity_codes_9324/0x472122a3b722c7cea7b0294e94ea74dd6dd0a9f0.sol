



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
}





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
}





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
}





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}





pragma solidity =0.8.4;
contract Vesting is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    uint256 public constant MAX_LOCK_LENGTH = 100;

    IERC20 public immutable token;
    uint256 public immutable startAt;

    struct LockBatchInput {
        address account;
        uint256[] unlockAt;
        uint256[] amounts;
    }

    struct Lock {
        uint256[] amounts;
        uint256[] unlockAt;
        uint256 released;
    }

    struct Balance {
        Lock[] locks;
    }

    mapping (address => Balance) private _balances;

    event TokensVested(address indexed _to, uint256 _amount);
    event TokensClaimed(address indexed _beneficiary, uint256 _amount);

    constructor(IERC20 _baseToken, uint256 _startAt) {
        token = _baseToken;
        startAt = _startAt;
    }

    function getLocks(address _participant, uint _index)
        external
        view
        returns (
            uint256[] memory amounts,
            uint256[] memory unlocks
        )
    {

        Lock memory _lock = _balances[_participant].locks[_index];
        amounts = _lock.amounts;
        unlocks = _lock.unlockAt;
    }

    function getLocksLength(address _participant) external view returns (uint256) {

        return _balances[_participant].locks.length;
    }

    function getItemsLengthByLockIndex(address _participant, uint256 _lockIndex)
        external
        view
        returns (uint256)
    {

        require(_balances[_participant].locks.length > _lockIndex, "Index not exist");

        return _balances[_participant].locks[_lockIndex].amounts.length;
    }

    function lock(address _account, uint256[] memory _unlockAt, uint256[] memory _amounts)
        external
        onlyOwner
        returns (uint256 totalAmount)
    {

        require(_account != address(0), "Zero address");
        require(
            _unlockAt.length == _amounts.length &&
            _unlockAt.length <= MAX_LOCK_LENGTH,
            "Wrong array length"
        );
        require(_unlockAt.length != 0, "Zero array length");

        for (uint i = 0; i < _unlockAt.length; i++) {
            if (i == 0) {
                require(_unlockAt[0] >= startAt, "Early unlock");
            }

            if (i > 0) {
                if (_unlockAt[i-1] >= _unlockAt[i]) {
                    require(false, "Timeline violation");
                }
            }

            totalAmount += _amounts[i];
        }

        token.safeTransferFrom(msg.sender, address(this), totalAmount);

        _balances[_account].locks.push(Lock({
            amounts: _amounts,
            unlockAt: _unlockAt,
            released: 0
        }));

        emit TokensVested(_account, totalAmount);
    }


    function lockBatch(LockBatchInput[] memory _input)
        external
        onlyOwner
        returns (uint256 totalAmount)
    {

        uint256 inputsLen = _input.length;

        require(inputsLen != 0, "Empty input data");

        uint256 lockLen;
        uint i;
        uint ii;
        for (i; i < inputsLen; i++) {
            if (_input[i].account == address(0)) {
                require(false, "Zero address");
            }

            if (
                _input[i].amounts.length == 0 ||
                _input[i].unlockAt.length == 0
            ) {
                require(false, "Zero array length");
            }

            if (
                _input[i].unlockAt.length != _input[i].amounts.length ||
                _input[i].unlockAt.length > MAX_LOCK_LENGTH
            ) {
                require(false, "Wrong array length");
            }

            lockLen = _input[i].unlockAt.length;
            for (ii; ii < lockLen; ii++) {
                if (ii == 0) {
                    require(_input[i].unlockAt[0] >= startAt, "Early unlock");
                }

                if (ii > 0) {
                    if (_input[i].unlockAt[ii-1] >= _input[i].unlockAt[ii]) {
                        require(false, "Timeline violation");
                    }
                }

                totalAmount += _input[i].amounts[ii];
            }

            ii = 0;
        }

        token.safeTransferFrom(msg.sender, address(this), totalAmount);

        uint amount;
        uint l;

        i = 0;
        for (i; i < inputsLen; i++) {
            _balances[_input[i].account].locks.push(Lock({
                amounts: _input[i].amounts,
                unlockAt: _input[i].unlockAt,
                released: 0
            }));

            l = _input[i].amounts.length;
            ii = 0;
            if (l > 1) {
                for (ii; ii < l; ii++) {
                    amount += _input[i].amounts[ii];
                    if (ii == l - 1) {
                        emit TokensVested(_input[i].account, amount);
                        amount = 0;
                    }
                }
            } else {
                emit TokensVested(_input[i].account, _input[i].amounts[0]);
            }
        }
    }

    function getNextUnlock(address _participant) external view returns (uint256 timestamp) {

        uint256 locksLen = _balances[_participant].locks.length;
        uint currentUnlock;
        uint i;
        for (i; i < locksLen; i++) {
            currentUnlock = _getNextUnlock(_participant, i);
            if (currentUnlock != 0) {
                if (timestamp == 0) {
                    timestamp = currentUnlock;
                } else {
                    if (currentUnlock < timestamp) {
                        timestamp = currentUnlock;
                    }
                }
            }
        }
    }

    function getNextUnlockByIndex(address _participant, uint256 _lockIndex)
        external
        view
        returns (uint256 timestamp)
    {

        uint256 locksLen = _balances[_participant].locks.length;

        require(locksLen > _lockIndex, "Index not exist");

        timestamp = _getNextUnlock(_participant, _lockIndex);
    }

    function pendingReward(address _participant) external view returns (uint256 reward) {

        reward = _pendingReward(_participant, 0, _balances[_participant].locks.length);
    }

    function pendingRewardInRange(address _participant, uint256 _from, uint256 _to)
        external
        view
        returns (uint256 reward)
    {

        reward = _pendingReward(_participant, _from, _to);
    }

    function claim(address _participant) external nonReentrant returns (uint256 claimed) {

        claimed = _claim(_participant, 0, _balances[_participant].locks.length);
    }

    function claimInRange(address _participant, uint256 _from, uint256 _to)
        external
        nonReentrant
        returns (uint256 claimed)
    {

        claimed = _claim(_participant, _from, _to);
    }

    function _pendingReward(address _participant, uint256 _from, uint256 _to)
        internal
        view
        returns (uint256 reward)
    {

        uint amount;
        uint released;
        uint i = _from;
        uint ii;
        for (i; i < _to; i++) {
            uint len = _balances[_participant].locks[i].amounts.length;
            for (ii; ii < len; ii++) {
                if (block.timestamp >= _balances[_participant].locks[i].unlockAt[ii]) {
                    amount += _balances[_participant].locks[i].amounts[ii];
                }
            }

            released += _balances[_participant].locks[i].released;
            ii = 0;
        }

        if (amount >= released) {
            reward = amount - released;
        }
    }

    function _claim(address _participant, uint256 _from, uint256 _to)
        internal
        returns (uint256 claimed)
    {

        uint amount;
        uint released;
        uint i = _from;
        uint ii;
        for (i; i < _to; i++) {
            uint toRelease;
            uint len = _balances[_participant].locks[i].amounts.length;
            for (ii; ii < len; ii++) {
                if (block.timestamp >= _balances[_participant].locks[i].unlockAt[ii]) {
                    amount += _balances[_participant].locks[i].amounts[ii];
                    toRelease += _balances[_participant].locks[i].amounts[ii];
                }
            }

            released += _balances[_participant].locks[i].released;
            if (toRelease > 0 && _balances[_participant].locks[i].released < toRelease) {
                _balances[_participant].locks[i].released = toRelease;
            }

            ii = 0;
        }

        require(amount >= released, "Nothing to claim");

        claimed = amount - released;

        require(claimed > 0, "Zero claim");

        token.safeTransfer(_participant, claimed);
        emit TokensClaimed(_participant, claimed);
    }

    function _getNextUnlock(address _participant, uint256 _lockIndex)
        internal
        view
        returns (uint256 timestamp)
    {

        Lock memory _lock = _balances[_participant].locks[_lockIndex];
        uint256 lockLen = _lock.unlockAt.length;
        uint i;
        for (i; i < lockLen; i++) {
            if (block.timestamp < _lock.unlockAt[i]) {
                timestamp = _lock.unlockAt[i];
                return timestamp;
            }
        }
    }
}