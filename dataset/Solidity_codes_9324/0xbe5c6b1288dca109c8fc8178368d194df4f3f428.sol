
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
}//MIT
pragma solidity =0.8.4;


contract SHO is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    uint32 constant HUNDRED_PERCENT = 1e6;

    struct User1 {
        uint16 claimedUnlocksCount;
        uint16 eliminatedAfterUnlock;
        uint120 allocation;
    }

    struct User2 {
        uint120 allocation;
        uint120 debt;

        uint16 claimedUnlocksCount;
        uint120 currentUnlocked;
        uint120 currentClaimed;

        uint120 totalUnlocked;
        uint120 totalClaimed;
    }

    mapping(address => User1) public users1;
    mapping(address => User2) public users2;

    IERC20 public immutable shoToken;
    uint64 public immutable startTime;
    address public immutable feeCollector;
    uint32 public immutable baseFeePercentage1;
    uint32 public immutable baseFeePercentage2;
    uint32 public immutable freeClaimablePercentage;
    address public immutable burnValley;
    uint32 public immutable burnPercentage;

    uint32[] public unlockPercentages;
    uint32[] public unlockPeriods;
    uint120[] public extraFees2;
    bool public whitelistingAllowed = true;

    uint16 passedUnlocksCount;
    uint120 public globalTotalAllocation1;
    uint120 public globalTotalAllocation2;

    uint16 public collectedFeesUnlocksCount;
    uint120 public extraFees1Allocation;
    uint120 public extraFees1AllocationUncollectable;

    event Whitelist (
        address user,
        uint120 allocation,
        uint8 option
    );

    event Claim1 (
        address indexed user,
        uint16 currentUnlock,
        uint120 claimedTokens
    );

    event Claim2 (
        address indexed user,
        uint16 currentUnlock,
        uint120 claimedTokens,
        uint120 baseClaimed,
        uint120 chargedfee
    );

    event FeeCollection (
        uint16 currentUnlock,
        uint120 totalFee,
        uint120 extraFee,
        uint120 burned
    );

    event UserElimination (
        address user,
        uint16 currentUnlock
    );

    event Update (
        uint16 passedUnlocksCount
    );

    modifier onlyWhitelistedUser1() {

        require(users1[msg.sender].allocation > 0, "SHO: caller is not whitelisted or does not have the correct option");
        _;
    }

    modifier onlyWhitelistedUser2() {

        require(users2[msg.sender].allocation > 0, "SHO: caller is not whitelisted or does not have the correct option");
        _;
    }

    constructor(
        IERC20 _shoToken,
        uint32[] memory _unlockPercentagesDiff,
        uint32[] memory _unlockPeriodsDiff,
        uint32 _baseFeePercentage1,
        uint32 _baseFeePercentage2,
        address _feeCollector,
        uint64 _startTime,
        address _burnValley,
        uint32 _burnPercentage,
        uint32 _freeClaimablePercentage
    ) {
        require(address(_shoToken) != address(0), "SHO: sho token zero address");
        require(_unlockPercentagesDiff.length > 0, "SHO: 0 unlock percentages");
        require(_unlockPercentagesDiff.length <= 800, "SHO: too many unlock percentages");
        require(_unlockPeriodsDiff.length == _unlockPercentagesDiff.length, "SHO: different array lengths");
        require(_baseFeePercentage1 <= HUNDRED_PERCENT, "SHO: base fee percentage 1 higher than 100%");
        require(_baseFeePercentage2 <= HUNDRED_PERCENT, "SHO: base fee percentage 2 higher than 100%");
        require(_feeCollector != address(0), "SHO: fee collector zero address");
        require(_startTime > block.timestamp, "SHO: start time must be in future");
        require(_burnValley != address(0), "SHO: burn valley zero address");
        require(_burnPercentage <= HUNDRED_PERCENT, "SHO: burn percentage higher than 100%");
        require(_freeClaimablePercentage <= HUNDRED_PERCENT, "SHO: free claimable percentage higher than 100%");

        uint32[] memory _unlockPercentages = _buildArraySum(_unlockPercentagesDiff);
        uint32[] memory _unlockPeriods = _buildArraySum(_unlockPeriodsDiff);
        require(_unlockPercentages[_unlockPercentages.length - 1] == HUNDRED_PERCENT, "SHO: invalid unlock percentages");

        shoToken = _shoToken;
        unlockPercentages = _unlockPercentages;
        unlockPeriods = _unlockPeriods;
        baseFeePercentage1 = _baseFeePercentage1;
        baseFeePercentage2 = _baseFeePercentage2;
        feeCollector = _feeCollector;
        startTime = _startTime;
        burnValley = _burnValley;
        burnPercentage = _burnPercentage;
        freeClaimablePercentage = _freeClaimablePercentage;
        extraFees2 = new uint120[](_unlockPercentagesDiff.length);
    }

    function whitelistUsers(
        address[] calldata userAddresses,
        uint120[] calldata allocations,
        uint8[] calldata options,
        bool last
    ) external onlyOwner {

        require(whitelistingAllowed, "SHO: whitelisting not allowed anymore");
        require(userAddresses.length != 0, "SHO: zero length array");
        require(userAddresses.length == allocations.length, "SHO: different array lengths");
        require(userAddresses.length == options.length, "SHO: different array lengths");

        uint120 _globalTotalAllocation1;
        uint120 _globalTotalAllocation2;
        for (uint256 i = 0; i < userAddresses.length; i++) {
            address userAddress = userAddresses[i];
            if (userAddress == feeCollector) {
                require(burnPercentage == 0);
                globalTotalAllocation1 += allocations[i];
                extraFees1Allocation += _applyBaseFee(allocations[i], 1);
                continue;
            }

            require(options[i] == 1 || options[i] == 2, "SHO: invalid user option");
            require(users1[userAddress].allocation == 0, "SHO: some users are already whitelisted");
            require(users2[userAddress].allocation == 0, "SHO: some users are already whitelisted");

            if (options[i] == 1) {
                users1[userAddress].allocation = allocations[i];
                _globalTotalAllocation1 += allocations[i];
            } else if (options[i] == 2) {
                users2[userAddress].allocation = allocations[i];
                _globalTotalAllocation2 += allocations[i];
            }

            emit Whitelist(
                userAddresses[i],
                allocations[i],
                options[i]
            );
        }
            
        globalTotalAllocation1 += _globalTotalAllocation1;
        globalTotalAllocation2 += _globalTotalAllocation2;
        
        if (last) {
            whitelistingAllowed = false;
        }
    }

    function claimUser1() onlyWhitelistedUser1 external nonReentrant returns (uint120 amountToClaim) {

        update();
        User1 memory user = users1[msg.sender];
        require(passedUnlocksCount > 0, "SHO: no unlocks passed");
        require(user.claimedUnlocksCount < passedUnlocksCount, "SHO: nothing to claim");

        uint16 currentUnlock = passedUnlocksCount - 1;
        if (user.eliminatedAfterUnlock > 0) {
            require(user.claimedUnlocksCount < user.eliminatedAfterUnlock, "SHO: nothing to claim");
            currentUnlock = user.eliminatedAfterUnlock - 1;
        }

        uint32 lastUnlockPercentage = user.claimedUnlocksCount > 0 ? unlockPercentages[user.claimedUnlocksCount - 1] : 0;
        amountToClaim = _applyPercentage(user.allocation, unlockPercentages[currentUnlock] - lastUnlockPercentage);
        amountToClaim = _applyBaseFee(amountToClaim, 1);

        user.claimedUnlocksCount = currentUnlock + 1;
        users1[msg.sender] = user;
        shoToken.safeTransfer(msg.sender, amountToClaim);
        emit Claim1(
            msg.sender, 
            currentUnlock,
            amountToClaim
        );
    }

    function eliminateUsers1(address[] calldata userAddresses) external onlyOwner {

        update();
        require(passedUnlocksCount > 0, "SHO: no unlocks passed");
        uint16 currentUnlock = passedUnlocksCount - 1;
        require(currentUnlock < unlockPeriods.length - 1, "SHO: eliminating in the last unlock");

        for (uint256 i = 0; i < userAddresses.length; i++) {
            address userAddress = userAddresses[i];
            User1 memory user = users1[userAddress];
            require(user.allocation > 0, "SHO: some user not option 1");
            require(user.eliminatedAfterUnlock == 0, "SHO: some user already eliminated");

            uint120 userAllocation = _applyBaseFee(user.allocation, 1);
            uint120 uncollectable = _applyPercentage(userAllocation, unlockPercentages[currentUnlock]);

            extraFees1Allocation += userAllocation;
            extraFees1AllocationUncollectable += uncollectable;

            users1[userAddress].eliminatedAfterUnlock = currentUnlock + 1;
            emit UserElimination(
                userAddress,
                currentUnlock
            );
        }
    }
    
    function claimUser2(
        uint120 extraAmountToClaim
    ) external nonReentrant onlyWhitelistedUser2 returns (
        uint120 amountToClaim, 
        uint120 baseClaimAmount, 
        uint120 currentUnlocked
    ) {

        update();
        User2 memory user = users2[msg.sender];
        require(passedUnlocksCount > 0, "SHO: no unlocks passed");
        uint16 currentUnlock = passedUnlocksCount - 1;

        if (user.claimedUnlocksCount < passedUnlocksCount) {
            amountToClaim = _updateUserCurrent(user, currentUnlock);
            baseClaimAmount = _getCurrentBaseClaimAmount(user, currentUnlock);
            amountToClaim += baseClaimAmount;
            user.currentClaimed += baseClaimAmount;
        } else {
            require(extraAmountToClaim > 0, "SHO: nothing to claim");
        }

        currentUnlocked = user.currentUnlocked;

        if (extraAmountToClaim > 0) {
            require(extraAmountToClaim <= user.currentUnlocked - user.currentClaimed, "SHO: passed extra amount too high");
            amountToClaim += extraAmountToClaim;
            user.currentClaimed += extraAmountToClaim;
            _chargeFee(user, extraAmountToClaim, currentUnlock);
        }

        require(amountToClaim > 0, "SHO: nothing to claim");

        user.totalClaimed += amountToClaim;
        users2[msg.sender] = user;
        shoToken.safeTransfer(msg.sender, amountToClaim);
        emit Claim2(
            msg.sender, 
            currentUnlock,
            amountToClaim,
            baseClaimAmount,
            extraAmountToClaim
        );
    }

    function collectFees() external nonReentrant returns (uint120 baseFee, uint120 extraFee, uint120 burned) {

        update();
        require(collectedFeesUnlocksCount < passedUnlocksCount, "SHO: no fees to collect");
        uint16 currentUnlock = passedUnlocksCount - 1;

        uint32 lastUnlockPercentage = collectedFeesUnlocksCount > 0 ? unlockPercentages[collectedFeesUnlocksCount - 1] : 0;
        uint120 globalAllocation1 = _applyPercentage(globalTotalAllocation1, unlockPercentages[currentUnlock] - lastUnlockPercentage);
        uint120 globalAllocation2 = _applyPercentage(globalTotalAllocation2, unlockPercentages[currentUnlock] - lastUnlockPercentage);
        baseFee = _applyPercentage(globalAllocation1, baseFeePercentage1);
        baseFee += _applyPercentage(globalAllocation2, baseFeePercentage2);

        uint120 extraFee2;
        for (uint16 i = collectedFeesUnlocksCount; i <= currentUnlock; i++) {
            extraFee2 += extraFees2[i];
        }

        uint120 extraFees1AllocationTillNow = _applyPercentage(extraFees1Allocation, unlockPercentages[currentUnlock]);
        uint120 extraFee1 = extraFees1AllocationTillNow - extraFees1AllocationUncollectable;
        extraFees1AllocationUncollectable = extraFees1AllocationTillNow;

        extraFee = extraFee1 + extraFee2;
        uint120 totalFee = baseFee + extraFee;
        burned = _burn(extraFee);
        collectedFeesUnlocksCount = currentUnlock + 1;
        shoToken.safeTransfer(feeCollector, totalFee - burned);
        emit FeeCollection(
            currentUnlock,
            totalFee,
            extraFee,
            burned
        );
    }

    function update() public {

        uint16 _passedUnlocksCount = getPassedUnlocksCount();
        if (_passedUnlocksCount > passedUnlocksCount) {
            passedUnlocksCount = _passedUnlocksCount;
            emit Update(_passedUnlocksCount);
        }
    }


    function getPassedUnlocksCount() public view returns (uint16 _passedUnlocksCount) {

        require(block.timestamp >= startTime, "SHO: before startTime");
        uint256 timeSinceStart = block.timestamp - startTime;
        uint256 maxReleases = unlockPeriods.length;
        _passedUnlocksCount = passedUnlocksCount;

        while (_passedUnlocksCount < maxReleases && timeSinceStart >= unlockPeriods[_passedUnlocksCount]) {
            _passedUnlocksCount++;
        }
    }

    function getTotalUnlocksCount() public view returns (uint16 totalUnlocksCount) {

        return uint16(unlockPercentages.length);
    }


    function _burn(uint120 amount) private returns (uint120 burned) {

        burned = _applyPercentage(amount, burnPercentage);
        if (burned == 0) return 0;

        uint256 balanceBefore = shoToken.balanceOf(address(this));
        address(shoToken).call(abi.encodeWithSignature("burn(uint256)", burned));
        uint256 balanceAfter = shoToken.balanceOf(address(this));

        if (balanceBefore == balanceAfter) {
            shoToken.safeTransfer(burnValley, burned);
        }
    }

    function _updateUserCurrent(User2 memory user, uint16 currentUnlock) private view returns (uint120 claimableFromPreviousUnlocks) {

        claimableFromPreviousUnlocks = _getClaimableFromPreviousUnlocks(user, currentUnlock);

        uint120 newUnlocked = claimableFromPreviousUnlocks - (user.currentUnlocked - user.currentClaimed);

        uint32 unlockPercentageDiffCurrent = currentUnlock > 0 ?
            unlockPercentages[currentUnlock] - unlockPercentages[currentUnlock - 1] : unlockPercentages[currentUnlock];

        uint120 currentUnlocked = _applyPercentage(user.allocation, unlockPercentageDiffCurrent);
        currentUnlocked = _applyBaseFee(currentUnlocked, 2);

        newUnlocked += currentUnlocked;
        if (newUnlocked >= user.debt) {
            newUnlocked -= user.debt;
        } else {
            newUnlocked = 0;
        }

        if (claimableFromPreviousUnlocks >= user.debt) {
            claimableFromPreviousUnlocks -= user.debt;
            user.debt = 0;
        } else {
            user.debt -= claimableFromPreviousUnlocks;
            claimableFromPreviousUnlocks = 0;
        }

        if (currentUnlocked >= user.debt) {
            currentUnlocked -= user.debt;
            user.debt = 0;
        } else {
            user.debt -= currentUnlocked;
            currentUnlocked = 0;
        }
        
        user.totalUnlocked += newUnlocked;
        user.currentUnlocked = currentUnlocked;
        user.currentClaimed = 0;
        user.claimedUnlocksCount = passedUnlocksCount;
    }

    function _getClaimableFromPreviousUnlocks(User2 memory user, uint16 currentUnlock) private view returns (uint120 claimableFromPreviousUnlocks) {

        uint32 lastUnlockPercentage = user.claimedUnlocksCount > 0 ? unlockPercentages[user.claimedUnlocksCount - 1] : 0;
        uint32 previousUnlockPercentage = currentUnlock > 0 ? unlockPercentages[currentUnlock - 1] : 0;
        uint120 claimableFromMissedUnlocks = _applyPercentage(user.allocation, previousUnlockPercentage - lastUnlockPercentage);
        claimableFromMissedUnlocks = _applyBaseFee(claimableFromMissedUnlocks, 2);
        
        claimableFromPreviousUnlocks = user.currentUnlocked - user.currentClaimed;
        claimableFromPreviousUnlocks += claimableFromMissedUnlocks;
    }

    function _getCurrentBaseClaimAmount(User2 memory user, uint16 currentUnlock) private view returns (uint120 baseClaimAmount) {

        if (currentUnlock < unlockPeriods.length - 1) {
            baseClaimAmount =_applyPercentage(user.currentUnlocked, freeClaimablePercentage);
        } else {
            baseClaimAmount = user.currentUnlocked;
        }
    }

    function _chargeFee(User2 memory user, uint120 fee, uint16 currentUnlock) private {

        user.debt += fee;

        while (fee > 0 && currentUnlock < unlockPeriods.length - 1) {
            uint16 nextUnlock = currentUnlock + 1;
            uint120 nextUserAvailable = _applyPercentage(user.allocation, unlockPercentages[nextUnlock] - unlockPercentages[currentUnlock]);
            nextUserAvailable = _applyBaseFee(nextUserAvailable, 2);

            uint120 currentUnlockFee = fee <= nextUserAvailable ? fee : nextUserAvailable;
            extraFees2[nextUnlock] += currentUnlockFee;
            fee -= currentUnlockFee;
            currentUnlock++;
        }
    }

    function _applyPercentage(uint120 value, uint32 percentage) private pure returns (uint120) {

        return uint120(uint256(value) * percentage / HUNDRED_PERCENT);
    }

    function _applyBaseFee(uint120 value, uint8 option) private view returns (uint120) {

        return value - _applyPercentage(value, option == 1 ? baseFeePercentage1 : baseFeePercentage2);
    }

    function _buildArraySum(uint32[] memory diffArray) internal pure returns (uint32[] memory) {

        uint256 len = diffArray.length;
        uint32[] memory sumArray = new uint32[](len);
        uint32 lastSum = 0;
        for (uint256 i = 0; i < len; i++) {
            if (i > 0) {
                lastSum = sumArray[i - 1];
            }
            sumArray[i] = lastSum + diffArray[i];
        }
        return sumArray;
    }
}