
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

pragma solidity =0.8.4;


contract Claimer is Ownable {

    using SafeERC20 for IERC20;

    uint256 private constant UNLOCK_TIME_THRESHOLD = 1618877169;
    string public id;

    struct Claim {
        uint256 unlockTime; // unix time
        uint256 percent; // three decimals: 1.783% = 1783
    }

    Claim[] public claims;

    bool public isPaused = false;
    uint256 public totalTokens;
    mapping(address => uint256) public allocation;
    mapping(address => uint256) private claimedTotal;
    mapping(address => mapping(uint256 => uint256)) public userClaimedPerClaim;
    uint256[] public alreadyDistributedClaims;
    uint256 private manuallyClaimedTotal;

    IERC20 public token;

    event Claimed(
        address indexed account,
        uint256 amount,
        uint256 percent,
        uint256 claimIdx
    );
    event ClaimedMultiple(address indexed account, uint256 amount);
    event DuplicateAllocationSkipped(
        address indexed account,
        uint256 failedAllocation,
        uint256 existingAllocation
    );
    event ClaimReleased(uint256 percent, uint256 newTime, uint256 claimIdx);
    event ClaimTimeChanged(uint256 percent, uint256 newTime, uint256 claimIdx);
    event ClaimingPaused(bool status);

    constructor(
        string memory _id,
        address _token,
        uint256[] memory times,
        uint256[] memory percents
    ) {
        token = IERC20(_token);
        id = _id;

        uint256 totalPercent;
        for (uint256 i = 0; i < times.length; i++) {
            require(percents[i] > 0, "Claimer: 0% is not allowed");
            claims.push(Claim(times[i], percents[i]));
            totalPercent += percents[i];
        }
        require(
            totalPercent == 100000,
            "Claimer: Sum of all claimed must be 100%"
        );
    }

    function setToken(address _token) external onlyOwner {

        token = IERC20(_token);
    }

    function setAlreadyDistributedClaims(uint256[] calldata claimedIdx)
        external
        onlyOwner
    {

        for (uint256 i = 0; i < claimedIdx.length; i++) {
            require(
                claimedIdx[i] < claims.length,
                "Claimer: Index out of bounds"
            );
        }
        alreadyDistributedClaims = claimedIdx;
    }

    function getTotalRemainingAmount() external view returns (uint256) {

        return totalTokens - getTotalClaimed();
    }

    function getTotalClaimed() public view returns (uint256) {

        return manuallyClaimedTotal + getAlreadyDistributedAmount(totalTokens);
    }

    function getClaims(address account)
        external
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            bool[] memory,
            uint256[] memory
        )
    {

        uint256 len = claims.length;
        uint256[] memory times = new uint256[](len);
        uint256[] memory percents = new uint256[](len);
        uint256[] memory amount = new uint256[](len);
        bool[] memory _isClaimable = new bool[](len);
        uint256[] memory claimedAmount = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            times[i] = claims[i].unlockTime;
            percents[i] = claims[i].percent;
            amount[i] = getClaimAmount(allocation[account], i);
            _isClaimable[i] = isClaimable(account, i);
            claimedAmount[i] = getAccountClaimed(account, i);
        }

        return (times, percents, amount, _isClaimable, claimedAmount);
    }

    function getTotalAccountClaimable(address account)
        external
        view
        returns (uint256)
    {

        uint256 totalClaimable;
        for (uint256 i = 0; i < claims.length; i++) {
            if (isClaimable(account, i)) {
                totalClaimable += getClaimAmount(allocation[account], i);
            }
        }

        return totalClaimable;
    }

    function getTotalAccountClaimed(address account)
        external
        view
        returns (uint256)
    {

        return
            claimedTotal[account] +
            getAlreadyDistributedAmount(allocation[account]);
    }

    function getAccountClaimed(address account, uint256 claimIdx)
        public
        view
        returns (uint256)
    {

        for (uint256 i = 0; i < alreadyDistributedClaims.length; i++) {
            if (alreadyDistributedClaims[i] == claimIdx) {
                return
                    getClaimAmount(
                        allocation[account],
                        alreadyDistributedClaims[i]
                    );
            }
        }

        return userClaimedPerClaim[account][claimIdx];
    }

    function getAlreadyDistributedAmount(uint256 total)
        public
        view
        returns (uint256)
    {

        uint256 amount;

        for (uint256 i = 0; i < alreadyDistributedClaims.length; i++) {
            amount += getClaimAmount(total, alreadyDistributedClaims[i]);
        }

        return amount;
    }

    function claim(address account, uint256 idx) external {

        require(idx < claims.length, "Claimer: Index out of bounds");
        require(
            allocation[account] > 0,
            "Claimer: Account doesn't have allocation"
        );
        require(!isPaused, "Claimer: Claiming paused");

        uint256 claimAmount = claimInternal(account, idx);
        token.safeTransfer(account, claimAmount);
        emit Claimed(account, claimAmount, claims[idx].percent, idx);
    }

    function claimAll(address account) external {

        require(
            allocation[account] > 0,
            "Claimer: Account doesn't have allocation"
        );
        require(!isPaused, "Claimer: Claiming paused");

        uint256 claimAmount = 0;
        for (uint256 idx = 0; idx < claims.length; idx++) {
            if (isClaimable(account, idx)) {
                claimAmount += claimInternal(account, idx);
            }
        }

        token.safeTransfer(account, claimAmount);
        emit ClaimedMultiple(account, claimAmount);
    }

    function claimInternal(address account, uint256 idx)
        internal
        returns (uint256)
    {

        require(
            isClaimable(account, idx),
            "Claimer: Not claimable or already claimed"
        );

        uint256 claimAmount = getClaimAmount(allocation[account], idx);
        require(claimAmount > 0, "Claimer: Amount is zero");

        manuallyClaimedTotal += claimAmount;
        claimedTotal[account] += claimAmount;
        userClaimedPerClaim[account][idx] = claimAmount;

        return claimAmount;
    }

    function setClaimTime(uint256 claimIdx, uint256 newUnlockTime)
        external
        onlyOwner
    {

        require(claimIdx < claims.length, "Claimer: Index out of bounds");
        Claim storage _claim = claims[claimIdx];

        _claim.unlockTime = newUnlockTime;
        emit ClaimTimeChanged(_claim.percent, _claim.unlockTime, claimIdx);
    }

    function releaseClaim(uint256 claimIdx) external onlyOwner {

        require(claimIdx < claims.length, "Claimer: Index out of bounds");
        Claim storage _claim = claims[claimIdx];

        require(
            _claim.unlockTime > block.timestamp,
            "Claimer: Claim already released"
        );
        _claim.unlockTime = block.timestamp;
        emit ClaimReleased(_claim.percent, _claim.unlockTime, claimIdx);
    }

    function isClaimable(address account, uint256 claimIdx)
        public
        view
        returns (bool)
    {

        if (isClaimed(account, claimIdx)) {
            return false;
        }

        uint256 unlockTime = claims[claimIdx].unlockTime;
        if (unlockTime == 0 || unlockTime < UNLOCK_TIME_THRESHOLD) {
            return false;
        }

        return unlockTime < block.timestamp;
    }

    function isClaimed(address account, uint256 claimIdx)
        public
        view
        returns (bool)
    {

        return
            userClaimedPerClaim[account][claimIdx] > 0 ||
            isAlreadyDistributed(claimIdx);
    }

    function isAlreadyDistributed(uint256 claimIdx) public view returns (bool) {

        for (uint256 i = 0; i < alreadyDistributedClaims.length; i++) {
            if (alreadyDistributedClaims[i] == claimIdx) {
                return true;
            }
        }

        return false;
    }

    function getClaimAmount(uint256 total, uint256 claimIdx)
        internal
        view
        returns (uint256)
    {

        return (total * claims[claimIdx].percent) / 100000;
    }

    function pauseClaiming(bool status) external onlyOwner {

        isPaused = status;
        emit ClaimingPaused(status);
    }

    function setAllocation(address account, uint256 newTotal)
        external
        onlyOwner
    {

        if (newTotal > allocation[account]) {
            totalTokens += newTotal - allocation[account];
        } else {
            totalTokens -= allocation[account] - newTotal;
        }
        allocation[account] = newTotal;
    }

    function batchAddAllocation(
        address[] calldata addresses,
        uint256[] calldata allocations
    ) external onlyOwner {

        require(
            addresses.length == allocations.length,
            "Claimer: Arguments length mismatch"
        );

        for (uint256 i = 0; i < addresses.length; i++) {
            address account = addresses[i];
            uint256 alloc = allocations[i];

            if (allocation[account] > 0) {
                emit DuplicateAllocationSkipped(
                    account,
                    alloc,
                    allocation[account]
                );
                continue;
            }

            allocation[account] = alloc;
            totalTokens += alloc;
        }
    }

    function withdrawAll() external onlyOwner {

        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(owner()).transfer(balance);
        }

        token.transfer(owner(), token.balanceOf(address(this)));
    }

    function withdrawToken(address _token, uint256 amount) external onlyOwner {

        IERC20(_token).transfer(owner(), amount);
    }
}