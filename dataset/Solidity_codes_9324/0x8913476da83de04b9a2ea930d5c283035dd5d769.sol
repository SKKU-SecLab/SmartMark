
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

contract Ownable {
  address payable public owner;

  constructor() {  owner = payable(msg.sender);  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address payable newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}// MIT
pragma solidity ^0.8.0;


struct Stake {
    uint256 _amount;
    uint256 _since;
    IERC20 _stakingToken;
    uint256 _stakaAmount;
    uint256 _estimatedReward;
    APY _estimatedAPY;
    uint256 _rewardStartDate; //This date will change as the amount staked increases
    bool _exists;
}

struct StakingContractParameters {
    uint256 _minimumStake;
    uint256 _maxSupply;
    uint256 _totalReward;
    IERC20 _stakingToken;
    uint256 _stakingDuration;
    uint256 _maximumStake;
    uint256 _minimumNumberStakeHoldersBeforeStart;
    uint256 _minimumTotalStakeBeforeStart;
    uint256 _startDate;
    uint256 _endDate;
    Percentage _immediateRewardPercentage;
    uint256 _cliffDuration;
    Percentage _cliffRewardPercentage;
    uint256 _linearDuration;
}

struct Percentage {
    uint256 _percentage;
    uint256 _percentageBase;
}

struct StakingContractParametersUpdate {
    uint256 _minimumStake;
    uint256 _maxSupply;
    uint256 _totalReward;
    IERC20 _stakingToken;
    uint256 _stakingDuration;
    uint256 _maximumStake;
    uint256 _minimumNumberStakeHoldersBeforeStart;
    uint256 _minimumTotalStakeBeforeStart;
    Percentage _immediateRewardPercentage;
    uint256 _cliffDuration;
    Percentage _cliffRewardPercentage;
    uint256 _linearDuration;
}

struct APY {
    uint256 _apy;
    uint256 _base;
}

contract KatanaInuStakingContract is
    ERC20("STAKA Token", "STAKA"),
    Ownable,
    Pausable
{
    using SafeMath for uint256;

    event Staked(
        address indexed stakeholder,
        uint256 amountStaked,
        IERC20 stakingToken,
        uint256 xKataAmount
    );

    event Withdrawn(
        address indexed stakeholder,
        uint256 amountStaked,
        uint256 amountReceived,
        IERC20 stakingToken
    );

    event EmergencyWithdraw(
        address indexed stakeholder,
        uint256 amountSKataBurned,
        uint256 amountReceived
    );


    mapping(address => Stake) public _stakeholdersMapping;
    uint256 _currentNumberOfStakeholders;

    StakingContractParameters private _stakingParameters;

    uint256 private _totalKataStaked;

    uint256 private _totalKataRewardsClaimed;

    bool private _stakingStarted;


    constructor(address stakingTokenAddress) {
        _stakingParameters._stakingToken = IERC20(stakingTokenAddress);
        _stakingParameters._minimumNumberStakeHoldersBeforeStart = 1;
    }

    function updateStakingParameters(
        StakingContractParametersUpdate calldata stakingParameters
    ) external onlyOwner {
        _stakingParameters._minimumStake = stakingParameters._minimumStake;
        _stakingParameters._maxSupply = stakingParameters._maxSupply;
        _stakingParameters._totalReward = stakingParameters._totalReward;
        _stakingParameters._stakingToken = IERC20(
            stakingParameters._stakingToken
        );
        _stakingParameters._stakingDuration = stakingParameters
            ._stakingDuration;
        if (_stakingStarted) {
            _stakingParameters._endDate =
                _stakingParameters._startDate +
                _stakingParameters._stakingDuration;
        }
        if (!_stakingStarted) {
            _stakingParameters
                ._minimumNumberStakeHoldersBeforeStart = stakingParameters
                ._minimumNumberStakeHoldersBeforeStart;
            _stakingParameters._minimumTotalStakeBeforeStart = stakingParameters
                ._minimumTotalStakeBeforeStart;
            if (
                (_stakingParameters._minimumTotalStakeBeforeStart == 0 ||
                    _totalKataStaked >=
                    _stakingParameters._minimumTotalStakeBeforeStart) &&
                (_stakingParameters._minimumNumberStakeHoldersBeforeStart ==
                    0 ||
                    _currentNumberOfStakeholders >=
                    _stakingParameters._minimumNumberStakeHoldersBeforeStart)
            ) {
                _stakingStarted = true;
                _stakingParameters._startDate = block.timestamp;
                _stakingParameters._endDate =
                    _stakingParameters._startDate +
                    _stakingParameters._stakingDuration;
            }
        }
        _stakingParameters._maximumStake = stakingParameters._maximumStake;

        _stakingParameters._immediateRewardPercentage = stakingParameters
            ._immediateRewardPercentage;
        _stakingParameters._cliffDuration = stakingParameters._cliffDuration;
        _stakingParameters._cliffRewardPercentage = stakingParameters
            ._cliffRewardPercentage;
        _stakingParameters._linearDuration = stakingParameters._linearDuration;
    }

    function stake(uint256 amount) external onlyUser whenNotPaused {
        require(
            amount >= _stakingParameters._minimumStake,
            "Amount below the minimum stake"
        );
        require(
            _stakingParameters._maximumStake == 0 ||
                amount <= _stakingParameters._maximumStake,
            "amount exceeds maximum stake"
        );
        require(
            (_totalKataStaked + amount) <= _stakingParameters._maxSupply,
            "You can not exceeed maximum supply for staking"
        );

        require(
            !_stakingStarted || block.timestamp < _stakingParameters._endDate,
            "The staking period has ended"
        );
        require(
            _totalKataRewardsClaimed < _stakingParameters._totalReward,
            "All rewards have been distributed"
        );

        Stake memory newStake = createStake(amount);
        _totalKataStaked += amount;
        if (!_stakeholdersMapping[msg.sender]._exists) {
            _currentNumberOfStakeholders += 1;
        }
        if (
            !_stakingStarted &&
            (_stakingParameters._minimumTotalStakeBeforeStart == 0 ||
                _totalKataStaked >=
                _stakingParameters._minimumTotalStakeBeforeStart) &&
            (_stakingParameters._minimumNumberStakeHoldersBeforeStart == 0 ||
                _currentNumberOfStakeholders >=
                _stakingParameters._minimumNumberStakeHoldersBeforeStart)
        ) {
            _stakingStarted = true;
            _stakingParameters._startDate = block.timestamp;
            _stakingParameters._endDate =
                _stakingParameters._startDate +
                _stakingParameters._stakingDuration;
        }
        if (
            !_stakingParameters._stakingToken.transferFrom(
                msg.sender,
                address(this),
                amount
            )
        ) {
            revert("couldn 't transfer tokens from sender to contract");
        }

        _mint(msg.sender, newStake._stakaAmount);


        if (!_stakeholdersMapping[msg.sender]._exists) {
            _stakeholdersMapping[msg.sender] = newStake;
            _stakeholdersMapping[msg.sender]._exists = true;
        } else {
            _stakeholdersMapping[msg.sender]
                ._rewardStartDate = calculateNewRewardStartDate(
                _stakeholdersMapping[msg.sender],
                newStake
            );
            _stakeholdersMapping[msg.sender]._amount += newStake._amount;
            _stakeholdersMapping[msg.sender]._stakaAmount += newStake
                ._stakaAmount;
        }
        emit Staked(
            msg.sender,
            amount,
            _stakingParameters._stakingToken,
            newStake._stakaAmount
        );
    }

    function calculateNewRewardStartDate(
        Stake memory existingStake,
        Stake memory newStake
    ) private pure returns (uint256) {
        uint256 multiplier = (
            existingStake._rewardStartDate.mul(existingStake._stakaAmount)
        ).add(newStake._rewardStartDate.mul(newStake._stakaAmount));
        uint256 divider = existingStake._stakaAmount.add(newStake._stakaAmount);
        return multiplier.div(divider);
    }

    function withdrawStake(uint256 amount) external onlyUser whenNotPaused {
        require(
            _stakeholdersMapping[msg.sender]._exists,
            "Can not find stake for sender"
        );
        require(
            _stakeholdersMapping[msg.sender]._amount >= amount,
            "Can not withdraw more than actual stake"
        );
        Stake memory stakeToWithdraw = _stakeholdersMapping[msg.sender];
        require(stakeToWithdraw._amount > 0, "Stake alreday withdrawn");
        uint256 reward = (
            computeRewardForStake(block.timestamp, stakeToWithdraw, true).mul(
                amount
            )
        ).div(stakeToWithdraw._amount);
        uint256 currentRewardBalance = getRewardBalance();
        require(
            reward <= currentRewardBalance,
            "The contract does not have enough reward tokens"
        );
        uint256 totalAmoutToWithdraw = reward + amount;
        uint256 nbStakaToBurn = (stakeToWithdraw._stakaAmount.mul(amount)).div(
            stakeToWithdraw._amount
        );

        _stakeholdersMapping[msg.sender]._amount -= amount;
        _stakeholdersMapping[msg.sender]._stakaAmount -= nbStakaToBurn;

        _totalKataStaked = _totalKataStaked - amount;
        _totalKataRewardsClaimed += reward;
        if (
            !stakeToWithdraw._stakingToken.transfer(
                msg.sender,
                totalAmoutToWithdraw
            )
        ) {
            revert("couldn 't transfer tokens from sender to contract");
        }
        _burn(msg.sender, nbStakaToBurn);
        emit Withdrawn(
            msg.sender,
            stakeToWithdraw._amount,
            totalAmoutToWithdraw,
            stakeToWithdraw._stakingToken
        );
    }

    function emergencyWithdraw(address stakeHolderAddress) external onlyOwner {
        require(
            _stakeholdersMapping[stakeHolderAddress]._exists,
            "Can not find stake for sender"
        );
        require(
            _stakeholdersMapping[stakeHolderAddress]._amount > 0,
            "Can not any stake for supplied address"
        );

        uint256 totalAmoutTowithdraw;
        uint256 totalSKataToBurn;
        totalAmoutTowithdraw = _stakeholdersMapping[stakeHolderAddress]._amount;
        totalSKataToBurn = _stakeholdersMapping[stakeHolderAddress]
            ._stakaAmount;
        if (
            !_stakeholdersMapping[stakeHolderAddress]._stakingToken.transfer(
                stakeHolderAddress,
                _stakeholdersMapping[stakeHolderAddress]._amount
            )
        ) {
            revert("couldn 't transfer tokens from sender to contract");
        }
        _stakeholdersMapping[stakeHolderAddress]._amount = 0;
        _stakeholdersMapping[stakeHolderAddress]._exists = false;
        _stakeholdersMapping[stakeHolderAddress]._stakaAmount = 0;

        _totalKataStaked = _totalKataStaked - totalAmoutTowithdraw;
        _burn(stakeHolderAddress, totalSKataToBurn);
        emit EmergencyWithdraw(
            stakeHolderAddress,
            totalSKataToBurn,
            totalAmoutTowithdraw
        );
    }

    function getStakeReward(uint256 targetTime)
        external
        view
        onlyUser
        returns (uint256)
    {
        require(
            _stakeholdersMapping[msg.sender]._exists,
            "Can not find stake for sender"
        );
        Stake memory targetStake = _stakeholdersMapping[msg.sender];
        return computeRewardForStake(targetTime, targetStake, true);
    }

    function getEstimationOfReward(uint256 targetTime, uint256 amountToStake)
        external
        view
        returns (uint256)
    {
        Stake memory targetStake = createStake(amountToStake);
        return computeRewardForStake(targetTime, targetStake, false);
    }

    function getAPY() external view returns (APY memory) {
        if (
            !_stakingStarted ||
            _stakingParameters._endDate == _stakingParameters._startDate ||
            _totalKataStaked == 0
        ) return APY(0, 1);

        uint256 targetTime = 365 days;
        if (
            _stakingParameters._immediateRewardPercentage._percentage == 0 &&
            _stakingParameters._cliffRewardPercentage._percentage == 0 &&
            _stakingParameters._cliffDuration == 0 &&
            _stakingParameters._linearDuration == 0
        ) {
            uint256 reward = _stakingParameters
                ._totalReward
                .mul(targetTime)
                .div(
                    _stakingParameters._endDate.sub(
                        _stakingParameters._startDate
                    )
                );
            return APY(reward.mul(100000).div(_totalKataStaked), 100000);
        }
        return getAPYWithVesting();
    }

    function getAPYWithVesting() private view returns (APY memory) {
        uint256 targetTime = 365 days;
        Stake memory syntheticStake = Stake(
            _totalKataStaked,
            block.timestamp,
            _stakingParameters._stakingToken,
            totalSupply(),
            0,
            APY(0, 1),
            block.timestamp,
            true
        );
        uint256 reward = computeRewardForStakeWithVesting(
            block.timestamp + targetTime,
            syntheticStake,
            true
        );
        return APY(reward.mul(100000).div(_totalKataStaked), 100000);
    }

    function createStake(uint256 amount) private view returns (Stake memory) {
        uint256 xKataAmountToMint;
        uint256 currentTimeStanp = block.timestamp;
        if (_totalKataStaked == 0 || totalSupply() == 0) {
            xKataAmountToMint = amount;
        } else {
            uint256 multiplier = amount
                .mul(
                    _stakingParameters._endDate.sub(
                        _stakingParameters._startDate
                    )
                )
                .div(
                    _stakingParameters._endDate.add(currentTimeStanp).sub(
                        2 * _stakingParameters._startDate
                    )
                );
            xKataAmountToMint = multiplier.mul(totalSupply()).div(
                _totalKataStaked
            );
        }
        return
            Stake(
                amount,
                currentTimeStanp,
                _stakingParameters._stakingToken,
                xKataAmountToMint,
                0,
                APY(0, 1),
                currentTimeStanp,
                true
            );
    }


    function getRewardBalance() public view returns (uint256) {
        uint256 stakingTokenBalance = _stakingParameters
            ._stakingToken
            .balanceOf(address(this));
        uint256 rewardBalance = stakingTokenBalance.sub(_totalKataStaked);
        return rewardBalance;
    }

    function getTotalRewardsClaimed() public view returns (uint256) {
        return _totalKataRewardsClaimed;
    }

    function getRequiredRewardAmountForPerdiod(uint256 endPeriod)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return caluclateRequiredRewardAmountForPerdiod(endPeriod);
    }

    function getRequiredRewardAmount() external view returns (uint256) {
        return caluclateRequiredRewardAmountForPerdiod(block.timestamp);
    }


    function caluclateRequiredRewardAmountForPerdiod(uint256 endPeriod)
        private
        view
        returns (uint256)
    {
        if (
            !_stakingStarted ||
            _stakingParameters._endDate == _stakingParameters._startDate ||
            _totalKataStaked == 0
        ) return 0;
        uint256 requiredReward = _stakingParameters
            ._totalReward
            .mul(endPeriod.sub(_stakingParameters._startDate))
            .div(_stakingParameters._endDate.sub(_stakingParameters._startDate))
            .sub(_totalKataRewardsClaimed);
        return requiredReward;
    }

    function computeRewardForStake(
        uint256 targetTime,
        Stake memory targetStake,
        bool existingStake
    ) private view returns (uint256) {
        if (
            _stakingParameters._immediateRewardPercentage._percentage == 0 &&
            _stakingParameters._cliffRewardPercentage._percentage == 0 &&
            _stakingParameters._cliffDuration == 0 &&
            _stakingParameters._linearDuration == 0
        ) {
            return
                computeReward(
                    _stakingParameters._totalReward,
                    targetTime,
                    targetStake._stakaAmount,
                    targetStake._rewardStartDate,
                    existingStake
                );
        }
        return
            computeRewardForStakeWithVesting(
                targetTime,
                targetStake,
                existingStake
            );
    }

    function computeRewardForStakeWithVesting(
        uint256 targetTime,
        Stake memory targetStake,
        bool existingStake
    ) private view returns (uint256) {
        uint256 accumulatedReward;
        uint256 currentStartTime = targetStake._rewardStartDate;
        uint256 currentTotalRewardAmount = (
            _stakingParameters._totalReward.mul(
                _stakingParameters._immediateRewardPercentage._percentage
            )
        ).div(_stakingParameters._immediateRewardPercentage._percentageBase);

        if (
            (currentStartTime + _stakingParameters._cliffDuration) >= targetTime
        ) {
            return
                computeReward(
                    currentTotalRewardAmount,
                    targetTime,
                    targetStake._stakaAmount,
                    currentStartTime,
                    existingStake
                );
        }

        accumulatedReward += computeReward(
            currentTotalRewardAmount,
            currentStartTime + _stakingParameters._cliffDuration,
            targetStake._stakaAmount,
            currentStartTime,
            existingStake
        );

        currentStartTime = currentStartTime + _stakingParameters._cliffDuration;
        currentTotalRewardAmount += (
            _stakingParameters._totalReward.mul(
                _stakingParameters._cliffRewardPercentage._percentage
            )
        ).div(_stakingParameters._cliffRewardPercentage._percentageBase);

        if (
            _stakingParameters._linearDuration == 0 ||
            (currentStartTime + _stakingParameters._linearDuration) <=
            targetTime
        ) {
            currentTotalRewardAmount = _stakingParameters._totalReward;

            return (
                accumulatedReward.add(
                    computeReward(
                        currentTotalRewardAmount,
                        targetTime,
                        targetStake._stakaAmount,
                        currentStartTime,
                        existingStake
                    )
                )
            );
        }
        currentTotalRewardAmount += (
            _stakingParameters._totalReward.sub(currentTotalRewardAmount)
        ).mul(targetTime - currentStartTime).div(
                _stakingParameters._linearDuration
            );
        accumulatedReward += computeReward(
            currentTotalRewardAmount,
            targetTime,
            targetStake._stakaAmount,
            currentStartTime,
            existingStake
        );
        return accumulatedReward;
    }

    function computeReward(
        uint256 applicableReward,
        uint256 targetTime,
        uint256 stakaAmount,
        uint256 rewardStartDate,
        bool existingStake
    ) private view returns (uint256) {
        uint256 mulltiplier = stakaAmount
            .mul(applicableReward)
            .mul(targetTime.sub(rewardStartDate))
            .div(
                _stakingParameters._endDate.sub(_stakingParameters._startDate)
            );

        uint256 divider = existingStake
            ? totalSupply()
            : totalSupply().add(stakaAmount);
        return mulltiplier.div(divider);
    }

    function setStakingToken(address stakingTokenAddress) external onlyOwner {
        _stakingParameters._stakingToken = IERC20(stakingTokenAddress);
    }

    function withdrawFromReward(uint256 amount) external onlyOwner {
        require(
            amount <= getRewardBalance(),
            "The contract does not have enough reward tokens"
        );
        if (!_stakingParameters._stakingToken.transfer(msg.sender, amount)) {
            revert("couldn 't transfer tokens from sender to contract");
        }
    }

    function getTotalStaked() external view returns (uint256) {
        return _totalKataStaked;
    }

    function getContractParameters()
        external
        view
        returns (StakingContractParameters memory)
    {
        return _stakingParameters;
    }

    function getStake() external view returns (Stake memory) {
        Stake memory currentStake = _stakeholdersMapping[msg.sender];
        if (!currentStake._exists) {
            return
                Stake(
                    0,
                    0,
                    _stakingParameters._stakingToken,
                    0,
                    0,
                    APY(0, 1),
                    0,
                    false
                );
        }
        if (_stakingStarted) {
            currentStake._estimatedReward = computeRewardForStake(
                block.timestamp,
                currentStake,
                true
            );
            currentStake._estimatedAPY = APY(
                computeRewardForStake(
                    currentStake._rewardStartDate + 365 days,
                    currentStake,
                    true
                ).mul(100000).div(currentStake._amount),
                100000
            );
        }
        return currentStake;
    }

    function shouldStartContract(
        uint256 newTotalKataStaked,
        uint256 newCurrentNumberOfStakeHolders
    ) private view returns (bool) {
        if (
            _stakingParameters._minimumTotalStakeBeforeStart > 0 &&
            newTotalKataStaked <
            _stakingParameters._minimumTotalStakeBeforeStart
        ) {
            return false;
        }
        if (
            _stakingParameters._minimumNumberStakeHoldersBeforeStart > 0 &&
            newCurrentNumberOfStakeHolders <
            _stakingParameters._minimumNumberStakeHoldersBeforeStart
        ) {
            return false;
        }
        return true;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from == address(0))
            return;
        if (to == address(0))
            return;

        Stake memory fromStake = _stakeholdersMapping[from];
        uint256 amountOfKataToTransfer = (
            _stakeholdersMapping[from]._amount.mul(amount)
        ).div(_stakeholdersMapping[from]._stakaAmount);

        fromStake._exists = true;
        fromStake._stakaAmount = amount;
        fromStake._amount = amountOfKataToTransfer;
        if (!_stakeholdersMapping[to]._exists) {
            _stakeholdersMapping[to] = fromStake;
            _stakeholdersMapping[from]._stakaAmount -= amount;
            _stakeholdersMapping[from]._amount -= amountOfKataToTransfer;
        } else {
            _stakeholdersMapping[to]
                ._rewardStartDate = calculateNewRewardStartDate(
                _stakeholdersMapping[to],
                fromStake
            );
            _stakeholdersMapping[to]._stakaAmount += amount;
            _stakeholdersMapping[to]._amount += amountOfKataToTransfer;
            _stakeholdersMapping[from]._stakaAmount -= amount;
            _stakeholdersMapping[from]._amount -= amountOfKataToTransfer;
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    modifier onlyUser() {
        require(msg.sender == tx.origin);
        _;
    }
}