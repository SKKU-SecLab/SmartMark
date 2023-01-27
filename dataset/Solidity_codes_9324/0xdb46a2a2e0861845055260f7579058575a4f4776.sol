



pragma solidity ^0.8.0;

interface IERC1363Spender {

    function onApprovalReceived(
        address sender,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity ^0.8.0;

interface IERC1363Receiver {

    function onTransferReceived(
        address operator,
        address sender,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




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
}




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
}




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
}




pragma solidity ^0.8.0;



interface IERC1363 is IERC20, IERC165 {

    function transferAndCall(address recipient, uint256 amount) external returns (bool);


    function transferAndCall(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);


    function transferFromAndCall(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function transferFromAndCall(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);


    function approveAndCall(address spender, uint256 amount) external returns (bool);


    function approveAndCall(
        address spender,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

}




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
}




pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;







contract ERC1363Payable is IERC1363Receiver, IERC1363Spender, ERC165, Context {

    using ERC165Checker for address;

    event TokensReceived(address indexed operator, address indexed sender, uint256 amount, bytes data);

    event TokensApproved(address indexed sender, uint256 amount, bytes data);

    IERC1363 private _acceptedToken;

    constructor(IERC1363 acceptedToken_) {
        require(address(acceptedToken_) != address(0), "ERC1363Payable: acceptedToken is zero address");
        require(acceptedToken_.supportsInterface(type(IERC1363).interfaceId));

        _acceptedToken = acceptedToken_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {

        return
            interfaceId == type(IERC1363Receiver).interfaceId ||
            interfaceId == type(IERC1363Spender).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function onTransferReceived(
        address operator,
        address sender,
        uint256 amount,
        bytes memory data
    ) public override returns (bytes4) {

        require(_msgSender() == address(_acceptedToken), "ERC1363Payable: acceptedToken is not message sender");

        emit TokensReceived(operator, sender, amount, data);

        _transferReceived(operator, sender, amount, data);

        return IERC1363Receiver(this).onTransferReceived.selector;
    }

    function onApprovalReceived(
        address sender,
        uint256 amount,
        bytes memory data
    ) public override returns (bytes4) {

        require(_msgSender() == address(_acceptedToken), "ERC1363Payable: acceptedToken is not message sender");

        emit TokensApproved(sender, amount, data);

        _approvalReceived(sender, amount, data);

        return IERC1363Spender(this).onApprovalReceived.selector;
    }

    function acceptedToken() public view returns (IERC1363) {

        return _acceptedToken;
    }

    function _transferReceived(
        address operator,
        address sender,
        uint256 amount,
        bytes memory data
    ) internal virtual {

    }

    function _approvalReceived(
        address sender,
        uint256 amount,
        bytes memory data
    ) internal virtual {

    }
}




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
}




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
}



pragma solidity 0.8.4;








contract ExenoTokenStaking is
    Ownable,
    Pausable,
    ReentrancyGuard,
    ERC1363Payable
{

    using SafeERC20 for IERC1363;

    IERC1363 public immutable token;

    address public immutable wallet;

    uint256 public annualizedInterestRate;

    uint256 public immutable rebasePeriodInHours;

    StakeStartMode public stakeStartMode;

    uint256 public endDate;

    uint256 public totalTokensStaked;

    enum StakeStartMode {
        IMMEDIATE,
        NEAREST_FULL_HOUR,
        NEAREST_MIDNIGHT,
        NEAREST_1AM,
        NEAREST_NOON,
        NEAREST_1PM
    }
    
    struct Stake {
        address user;
        uint256 timestamp;
        uint256 amount;
    }

    struct Stakeholder {
        address user;
        uint256 totalAmount;
        Stake[] stakes;
    }

    struct Record {
        uint256 timestamp;
        uint256 amount;
        uint256 interest;
        uint256 claimable;
        uint256 nextRebaseClaimable;
        uint256 nextRebaseTimestamp;
    }

    struct StakingStatus {
        uint256 timestamp;
        uint256 totalAmount;
        Record[] records;
    }

    Stakeholder[] internal _stakeholders;

    mapping(address => uint256) internal _stakeMap;

    event Staked(
        address indexed user,
        uint256 amount
    );

    event Unstaked(
        address indexed user,
        uint256 amount,
        uint256 payout
    );

    event UpdateAnnualizedInterestRate(
        uint256 previousRate,
        uint256 currentRate
    );

    event UpdateStakeStartMode(
        StakeStartMode previousMode,
        StakeStartMode currentMode
    );

    event ExtendEndDate(
        uint256 previousEndDate,
        uint256 currentEndDate
    );

    modifier validAddress(address a) {

        require(a != address(0),
            "ExenoTokenStaking: address cannot be zero");
        require(a != address(this),
            "ExenoTokenStaking: invalid address");
        _;
    }

    constructor(
        IERC1363 _token,
        uint256 _annualizedInterestRate,
        uint256 _rebasePeriodInHours,
        uint8 _stakeStartMode,
        address _wallet,
        uint256 _endDate
    )
        ERC1363Payable(_token)
        validAddress(_wallet)
    {
        require(_annualizedInterestRate > 0,
            "ExenoTokenStaking: invalid annualized interest rate");

        require(_rebasePeriodInHours > 0,
            "ExenoTokenStaking: invalid rebase period");

        require(_stakeStartMode <= uint256(StakeStartMode.NEAREST_1PM),
            "ExenoTokenStaking: invalid stake start mode");

        require(_endDate > block.timestamp,
            "ExenoTokenStaking: end-date cannot be in the past");

        token = _token;
        annualizedInterestRate = _annualizedInterestRate;
        rebasePeriodInHours = _rebasePeriodInHours;
        stakeStartMode = StakeStartMode(_stakeStartMode);
        wallet = _wallet;
        endDate = _endDate;
        
        _stakeholders.push();
    }

    function _transferReceived(address, address sender, uint256 amount, bytes memory)
        internal override validAddress(sender)
    {

        _stake(sender, amount);
    }

    function _addStakeholder(address stakeholder)
        internal validAddress(stakeholder) returns(uint256)
    {

        _stakeholders.push();
        uint256 userIndex = _stakeholders.length - 1;
        _stakeholders[userIndex].user = stakeholder;
        _stakeMap[stakeholder] = userIndex;
        return userIndex;
    }

    function _stake(address stakeholder, uint256 amount)
        internal validAddress(stakeholder) whenNotPaused
    {

        require(amount > 0,
            "ExenoTokenStaking: amount cannot be zero");

        require(endDate > block.timestamp,
            "ExenoTokenStaking: end-date is expired");

        assert(_checkBalanceIntegrity(totalTokensStaked + amount));

        uint256 userIndex = _stakeMap[stakeholder];
        
        if (userIndex == 0) {
            userIndex = _addStakeholder(stakeholder);
        }

        _stakeholders[userIndex].stakes.push(
            Stake(stakeholder, _calculateStartTimestamp(), amount)
        );

        _stakeholders[userIndex].totalAmount += amount;

        totalTokensStaked += amount;

        emit Staked(stakeholder, amount);
    }

    function _unstake(uint256 userIndex, uint256 stakeIndex, uint256 amount)
        internal returns(uint256)
    {

        (,uint256 recentRebaseDuration,,) = _calculateDuration(
            _stakeholders[userIndex].stakes[stakeIndex].timestamp);
        
        uint256 payout = _calculatePayout(recentRebaseDuration, amount);
        
        _stakeholders[userIndex].stakes[stakeIndex].amount -= amount;

        _stakeholders[userIndex].totalAmount -= amount;

        totalTokensStaked -= amount;
        
        return payout;
    }

    function _purge(uint256 userIndex)
        internal
    {

        Stake[] storage stakes = _stakeholders[userIndex].stakes;

        uint256 i; //index of the current stake in the loop
        uint256 j; //index of the nearest non-zero stake

        while (i < stakes.length && j < stakes.length) {
            if (stakes[i].amount == 0) {
                if (j == 0) j = i + 1;
                while (j < stakes.length && stakes[j].amount == 0) {
                    j++;
                }
                if (j < stakes.length) {
                    stakes[i] = stakes[j];
                    delete stakes[j];
                }
                j++;
            }
            i++;
        }

        if (j > i) {
            for (uint256 k = 0; k < j - i; k++) {
                assert(stakes[stakes.length - 1].amount == 0);
                stakes.pop();
            }
        }
    }

    function _checkBalanceIntegrity(uint256 expectedBalance)
        internal view returns(bool)
    {

        return token.balanceOf(address(this)) >= expectedBalance;
    }

    function _calculateStartTimestamp()
        internal view virtual returns(uint256)
    {

        if (stakeStartMode == StakeStartMode.IMMEDIATE) {
            return block.timestamp;
        }
        uint256 startTimestamp = block.timestamp;
        if (stakeStartMode == StakeStartMode.NEAREST_FULL_HOUR) {
            startTimestamp = startTimestamp / 1 hours * 1 hours + 1 hours;
        } else if (stakeStartMode == StakeStartMode.NEAREST_MIDNIGHT) {
            startTimestamp = startTimestamp / 1 days * 1 days + 1 days;
        } else if (stakeStartMode == StakeStartMode.NEAREST_1AM) {
            startTimestamp = startTimestamp / 1 days * 1 days + 1 hours;
        } else if (stakeStartMode == StakeStartMode.NEAREST_NOON) {
            startTimestamp = startTimestamp / 1 days * 1 days + 12 hours;
        } else if (stakeStartMode == StakeStartMode.NEAREST_1PM) {
            startTimestamp = startTimestamp / 1 days * 1 days + 13 hours;
        }
        if (startTimestamp < block.timestamp) {
            startTimestamp += 1 days;
            assert(startTimestamp >= block.timestamp);
        }
        return startTimestamp;
    }

    function _calculateDuration(uint256 startTimestamp)
        internal view virtual returns(
            uint256 actualDuration,
            uint256 recentRebaseDuration,
            uint256 nextRebaseDuration,
            uint256 nextRebaseTimestamp
        )
    {

        uint256 endTimestamp = block.timestamp;
        
        if (endDate < endTimestamp) {
            endTimestamp = Math.min(endTimestamp, endDate + rebasePeriodInHours * 1 hours);
        }

        actualDuration = 0;
        
        if (startTimestamp < endTimestamp) {
            actualDuration = (endTimestamp - startTimestamp) / 1 hours;
        }

        recentRebaseDuration = (actualDuration / rebasePeriodInHours) * rebasePeriodInHours;

        if (endTimestamp < block.timestamp) {
            actualDuration = recentRebaseDuration;
        }

        nextRebaseDuration = 0;
        nextRebaseTimestamp = 0;
        
        if (startTimestamp + recentRebaseDuration * 1 hours < endDate) {
            nextRebaseDuration = recentRebaseDuration + rebasePeriodInHours;
            nextRebaseTimestamp = startTimestamp + nextRebaseDuration * 1 hours;
        }
    }

    function _calculatePayout(uint256 duration, uint256 amount)
        internal view virtual returns(uint256)
    {

        return duration * amount * annualizedInterestRate / 365 / 24 / 10**4;
    }

    function pause()
        external onlyOwner
    {

        _pause();
    }

    function unpause()
        external onlyOwner
    {

        _unpause();
    }

    function updateAnnualizedInterestRate(uint256 newAnnualizedInterestRate)
        external onlyOwner
    {

        require(newAnnualizedInterestRate > 0,
            "ExenoTokenStaking: invalid annualized interest rate");
        
        emit UpdateAnnualizedInterestRate(annualizedInterestRate, newAnnualizedInterestRate);
        annualizedInterestRate = newAnnualizedInterestRate;
    }

    function updateStakeStartMode(uint8 newStakeStartValue)
        external onlyOwner
    {

        require(newStakeStartValue <= uint256(StakeStartMode.NEAREST_1PM),
            "ExenoTokenStaking: invalid stake start mode");
        
        StakeStartMode newStakeStartMode = StakeStartMode(newStakeStartValue);
        emit UpdateStakeStartMode(stakeStartMode, newStakeStartMode);
        stakeStartMode = newStakeStartMode;
    }

    function extendEndDate(uint256 newEndDate)
        external onlyOwner
    {

        require(newEndDate > block.timestamp,
            "ExenoTokenStaking: new end-date cannot be in the past");

        require(newEndDate > endDate,
            "ExenoTokenStaking: new end-date cannot be prior to existing end-date");
        
        require(endDate > block.timestamp,
            "ExenoTokenStaking: cannot set a new end-date as existing end-date is expired");
        
        emit ExtendEndDate(endDate, newEndDate);
        endDate = newEndDate;
    }

    function getStakingStatus(address stakeholder)
        external view validAddress(stakeholder) returns(StakingStatus memory)
    {

        Stake[] memory stakes = _stakeholders[_stakeMap[stakeholder]].stakes;
        Record[] memory records = new Record[](stakes.length);
        for (uint256 i = 0; i < stakes.length; i++) {
            uint256 timestamp = stakes[i].timestamp;
            records[i].timestamp = timestamp;
            (
                uint256 actualDuration,
                uint256 recentRebaseDuration,
                uint256 nextRebaseDuration,
                uint256 nextRebaseTimestamp
            ) = _calculateDuration(timestamp);
            uint256 amount = stakes[i].amount;
            records[i].amount = amount;
            records[i].interest = _calculatePayout(actualDuration, amount);
            records[i].claimable = _calculatePayout(recentRebaseDuration, amount);
            records[i].nextRebaseClaimable = _calculatePayout(nextRebaseDuration, amount);
            records[i].nextRebaseTimestamp = nextRebaseTimestamp;
        }
        StakingStatus memory status = StakingStatus(block.timestamp,
            _stakeholders[_stakeMap[stakeholder]].totalAmount, records);
        return status;
    }

    function getNumberOfStakeholders()
        external view returns(uint256)
    {

        return _stakeholders.length - 1;
    }

    function checkAvailableFunds()
        external view returns(uint256, uint256)
    {

        return (token.balanceOf(wallet), token.allowance(wallet, address(this)));
    }

    function unstake(uint256 amount, uint256 stakeIndex, bool skipPayout)
        external nonReentrant
    {

        address stakeholder = msg.sender;
        uint256 userIndex = _stakeMap[stakeholder];

        Stake[] memory stakes = _stakeholders[userIndex].stakes;

        require(stakes.length > 0,
            "ExenoTokenStaking: this account has never made any staking");

        require(stakeIndex < stakes.length,
            "ExenoTokenStaking: provided index is out of range");

        Stake memory currentStake = stakes[stakeIndex];

        if (amount > 0) {
            require(currentStake.amount >= amount,
                "ExenoTokenStaking: there is not enough stake on the provided index for the requested amount");
        } else {
            require(currentStake.amount > 0,
                "ExenoTokenStaking: there is not enough stake on the provided index for the requested amount");
            amount = currentStake.amount;
        }

        uint256 payout = _unstake(userIndex, stakeIndex, amount);
        
        if (skipPayout) payout = 0;
        
        require(token.balanceOf(wallet) >= payout,
            "ExenoTokenStaking: not enough balance for payout");

        require(token.allowance(wallet, address(this)) >= payout,
            "ExenoTokenStaking: not enough allowance for payout");

        assert(_checkBalanceIntegrity(totalTokensStaked));

        _purge(userIndex);

        token.safeTransfer(stakeholder, amount);

        if (payout > 0) {
            token.safeTransferFrom(wallet, stakeholder, payout);
        }
        
        assert(_checkBalanceIntegrity(totalTokensStaked));

        emit Unstaked(stakeholder, amount, payout);
    }
    
    function unstakeFifo(uint256 amount)
        external nonReentrant
    {

        address stakeholder = msg.sender;
        uint256 userIndex = _stakeMap[stakeholder];

        Stake[] memory stakes = _stakeholders[userIndex].stakes;

        require(stakes.length > 0,
            "ExenoTokenStaking: this account has never made any staking");

        if (amount == 0) {
            amount = _stakeholders[userIndex].totalAmount;
            require(amount > 0,
                "ExenoTokenStaking: not enough stake on all indexes for the requested amount");
        }
        
        uint256 amountLeft = amount;
        uint256 payout = 0;
        uint256 index = 0;
        while (amountLeft > 0 && index < stakes.length) {
            uint256 bite = Math.min(stakes[index].amount, amountLeft);
            payout += _unstake(userIndex, index, bite);
            amountLeft -= bite;
            index++;
        }

        require(amountLeft == 0,
            "ExenoTokenStaking: not enough stake on all indexes for the requested amount");

        require(token.balanceOf(wallet) >= payout,
            "ExenoTokenStaking: not enough balance for payout");

        require(token.allowance(wallet, address(this)) >= payout,
            "ExenoTokenStaking: not enough allowance for payout");

        assert(_checkBalanceIntegrity(totalTokensStaked));

        _purge(userIndex);

        token.safeTransfer(stakeholder, amount);

        token.safeTransferFrom(wallet, stakeholder, payout);

        assert(_checkBalanceIntegrity(totalTokensStaked));

        emit Unstaked(stakeholder, amount, payout);
    }
}