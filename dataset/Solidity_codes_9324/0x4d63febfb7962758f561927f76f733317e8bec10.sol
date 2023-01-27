
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.9;


abstract contract OwnPauseAuth is Ownable, Pausable {
    mapping(address => bool) internal _authorizedAddressList;

    event RevokeAuthorized(address auth_);
    event GrantAuthorized(address auth_);

    modifier isAuthorized() {
        require(
            msg.sender == owner() || _authorizedAddressList[msg.sender] == true,
            "OwnPauseAuth: unauthorized"
        );
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner(), "OwnPauseAuth: not owner");
        _;
    }

    function grantAuthorized(address auth_) external isOwner {
        require(auth_ != address(0), "OwnPauseAuth: invalid auth_ address ");

        _authorizedAddressList[auth_] = true;

        emit GrantAuthorized(auth_);
    }

    function revokeAuthorized(address auth_) external isOwner {
        require(auth_ != address(0), "OwnPauseAuth: invalid auth_ address ");

        _authorizedAddressList[auth_] = false;

        emit RevokeAuthorized(auth_);
    }

    function checkAuthorized(address auth_) public view returns (bool) {
        require(auth_ != address(0), "OwnPauseAuth: invalid auth_ address ");

        return auth_ == owner() || _authorizedAddressList[auth_] == true;
    }

    function pause() external isOwner {
        _pause();
    }

    function unpause() external isOwner {
        _unpause();
    }
}// MIT

pragma solidity ^0.8.9;


contract TimeLockStaking is OwnPauseAuth, ReentrancyGuard {

    using SafeERC20 for IERC20;

    IERC20 public token;

    string public name;

    uint256 public timelock;

    uint256 public apr;

    uint256 public maxCap;

    uint256 public expiryTime;

    uint256 public minTokensPerDeposit;

    uint256 public maxTokensPerDeposit;

    uint256 public totalPayout;

    uint256 public totalRewardTokens;

    uint256 public totalDepositedTokens;

    bool public isMaxCapReached = false;

    struct DepositInfo {
        uint256 seq;
        uint256 amount;
        uint256 reward;
        bool isPaidOut;
        uint256 unlockTime;
    }

    mapping(address => DepositInfo[]) public stakingList;

    event Deposited(
        address indexed sender,
        uint256 seq,
        uint256 amount,
        uint256 timestamp
    );

    event Claimed(
        address indexed sender,
        uint256 seq,
        uint256 amount,
        uint256 reward,
        uint256 timestamp
    );

    event OwnerClaimed(address indexed sender, uint256 _remainingReward, address _to);
    event OwnerWithdrawn(address indexed sender, uint256 _amount, address _to);
    event OwnerWithdrawnAll(address indexed sender, uint256 _amount, address _to);

    event EvtSetName(string _name);
    event EvtSetTimelock(uint256 _timelock);
    event EvtSetAPR(uint256 _apr);
    event EvtSetMaxCap(uint256 _maxCap);
    event EvtSetExpiryTime(uint256 _expiryTime);
    event EvtSetMinTokensPerDeposit(uint256 _minTokensPerDeposit);
    event EvtSetMaxTokensPerDeposit(uint256 _maxTokensPerDeposit);

    constructor(
        IERC20 _token,
        string memory _campaignName,
        uint256 _expiryTime, // set to zero to disable expiry
        uint256 _maxCap,
        uint256 _maxTokensPerDeposit,
        uint256 _minTokensPerDeposit,
        uint256 _timelock,
        uint256 _apr
    ) {
        token = _token;
        name = _campaignName;

        if (_expiryTime > 0) {
            expiryTime = block.timestamp + _expiryTime;
        }

        maxCap = _maxCap;
        maxTokensPerDeposit = _maxTokensPerDeposit;
        minTokensPerDeposit = _minTokensPerDeposit;
        timelock = _timelock;
        apr = _apr;
    }

    function deposit(uint256 _amountIn) external whenNotPaused nonReentrant {

        require(isMaxCapReached == false, "TimeLockStaking: Max cap reached");

        uint256 _amount;
        if (totalDepositedTokens + _amountIn <= maxCap) {
            _amount = _amountIn;
        } else {
            isMaxCapReached = true;
            _amount = maxCap - totalDepositedTokens;
        }

        require(
            _amount >= minTokensPerDeposit,
            "TimeLockStaking: Depositing amount smaller than minTokensPerDeposit"
        );
        require(
            _amount <= maxTokensPerDeposit,
            "TimeLockStaking: Depositing amount larger than maxTokensPerDeposit"
        );
        require(
            expiryTime == 0 || block.timestamp < expiryTime,
            "TimeLockStaking: Campaign over"
        );

        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 unlockTime = block.timestamp + timelock;
        uint256 seq = stakingList[msg.sender].length + 1;
        uint256 reward = (_amount * apr * timelock) /
            (365 * 24 * 60 * 60 * 100);

        DepositInfo memory staking = DepositInfo(
            seq,
            _amount,
            reward,
            false,
            unlockTime
        );
        stakingList[msg.sender].push(staking);

        totalDepositedTokens += _amount;
        totalRewardTokens += reward;

        emit Deposited(msg.sender, seq, _amount, block.timestamp);
    }

    function claim(uint256 _seq) external whenNotPaused nonReentrant {

        DepositInfo[] memory userStakings = stakingList[msg.sender];
        require(
            _seq > 0 && userStakings.length >= _seq,
            "TimeLockStaking: Invalid seq"
        );

        uint256 idx = _seq - 1;

        DepositInfo memory staking = userStakings[idx];

        require(!staking.isPaidOut, "TimeLockStaking: Already paid out");
        require(
            staking.unlockTime <= block.timestamp,
            "TimeLockStaking: Staking still locked"
        );

        uint256 payout = staking.amount + staking.reward;

        token.safeTransfer(msg.sender, payout);
        totalPayout += payout;

        stakingList[msg.sender][idx].isPaidOut = true;

        emit Claimed(
            msg.sender,
            _seq,
            staking.amount,
            staking.reward,
            block.timestamp
        );
    }

    function getRemainingPayout() public view returns (uint256) {

        uint256 remainingPayoutAmount = totalDepositedTokens +
            totalRewardTokens -
            totalPayout;
        return remainingPayoutAmount;
    }

    function getTokenBalance() public view returns (uint256) {

        return token.balanceOf(address(this));
    }

    function getRemainingReward() public view returns (uint256) {

        uint256 remainingPayoutAmount = getRemainingPayout();
        uint256 balance = getTokenBalance();
        return balance - remainingPayoutAmount;
    }

    function ownerClaimRemainingReward(address _to)
        external
        isOwner
        nonReentrant
    {

        require(
            block.timestamp > expiryTime,
            "TimeLockStaking: Campaign not yet expired"
        );

        uint256 remainingReward = getRemainingReward();
        token.safeTransfer(_to, remainingReward);

        emit OwnerClaimed(msg.sender, remainingReward, _to);
    }

    function ownerWithdraw(address _to, uint256 _amount)
        external
        isOwner
        nonReentrant
    {

        token.safeTransfer(_to, _amount);

        emit OwnerWithdrawn(msg.sender, _amount, _to);
    }

    function ownerWithdrawAll(address _to) external isOwner nonReentrant {

        uint256 tokenBal = getTokenBalance();
        token.safeTransfer(_to, tokenBal);

        emit OwnerWithdrawnAll(msg.sender, tokenBal, _to);
    }

    function setName(string memory _name) external isAuthorized {

        name = _name;
        emit EvtSetName(_name);
    }

    function setTimelock(uint256 _timelock) external isAuthorized {

        timelock = _timelock;
        emit EvtSetTimelock(_timelock);
    }

    function setAPR(uint256 _apr) external isAuthorized {

        apr = _apr;
        emit EvtSetAPR(_apr);
    }

    function setMaxCap(uint256 _maxCap) external isAuthorized {

        maxCap = _maxCap;
        isMaxCapReached = false;
        emit EvtSetMaxCap(_maxCap);
    }

    function setExpiryTime(uint256 _expiryTime) external isAuthorized {

        expiryTime = _expiryTime;
        emit EvtSetExpiryTime(_expiryTime);
    }

    function setMinTokensPerDeposit(uint256 _minTokensPerDeposit)
        external
        isAuthorized
    {

        minTokensPerDeposit = _minTokensPerDeposit;
        emit EvtSetMinTokensPerDeposit(_minTokensPerDeposit);
    }

    function setMaxTokensPerDeposit(uint256 _maxTokensPerDeposit)
        external
        isAuthorized
    {

        maxTokensPerDeposit = _maxTokensPerDeposit;
        emit EvtSetMaxTokensPerDeposit(_maxTokensPerDeposit);
    }

    function getCampaignInfo()
        external
        view
        returns (
            IERC20 _token,
            string memory _campaignName,
            uint256 _expiryTime,
            uint256 _maxCap,
            uint256 _maxTokensPerDeposit,
            uint256 _minTokensPerDeposit,
            uint256 _timelock,
            uint256 _apr,
            uint256 _totalDepositedTokens,
            uint256 _totalPayout
        )
    {

        return (
            token,
            name,
            expiryTime,
            maxCap,
            maxTokensPerDeposit,
            minTokensPerDeposit,
            timelock,
            apr,
            totalDepositedTokens,
            totalPayout
        );
    }

    function getStakings(address _staker)
        external
        view
        returns (
            uint256[] memory _seqs,
            uint256[] memory _amounts,
            uint256[] memory _rewards,
            bool[] memory _isPaidOuts,
            uint256[] memory _timestamps
        )
    {

        DepositInfo[] memory userStakings = stakingList[_staker];

        uint256 length = userStakings.length;

        uint256[] memory seqList = new uint256[](length);
        uint256[] memory amountList = new uint256[](length);
        uint256[] memory rewardList = new uint256[](length);
        bool[] memory isPaidOutList = new bool[](length);
        uint256[] memory timeList = new uint256[](length);

        for (uint256 idx = 0; idx < length; idx++) {
            DepositInfo memory stakingInfo = userStakings[idx];

            seqList[idx] = stakingInfo.seq;
            amountList[idx] = stakingInfo.amount;
            rewardList[idx] = stakingInfo.reward;
            isPaidOutList[idx] = stakingInfo.isPaidOut;
            timeList[idx] = stakingInfo.unlockTime;
        }

        return (seqList, amountList, rewardList, isPaidOutList, timeList);
    }
}