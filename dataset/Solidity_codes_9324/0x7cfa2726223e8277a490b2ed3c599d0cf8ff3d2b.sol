


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



contract TokenSwap is Ownable {


    event AdminWalletUpdated(address addr);
    event LockIntervalUpdated(uint256 interval);
    event LockPercentageUpdated(uint256 percentage);
    event MinDepositUpdated(uint256 amount);

    event TokenWithdrawed(uint256 amount);

    event PhaseCreated(uint256 startTime, uint256 endTime, uint256 swapRate);
    event PhaseTimeUpdated(uint256 phaseId, uint256 startTime, uint256 endTime);
    event SwapRateUpdated(uint256 phaseId, uint256 swapRate);

    event Swapped(uint256 phaseId, address account, uint256 ethDeposit, uint256 ethRefund, uint256 tokenSwap, uint256 tokenLock, string referralCode);

    event TokenClaimed(uint256 phaseId, address account, uint256 amount);
    event TotalTokenClaimed(address account, uint256 amount);

    IERC20 private _token;

    address private _adminWallet;

    uint256 private _lockInterval;

    uint256 private _lockPercentage;

    uint256 private _minDeposit;

    struct ReferralCodeInfo {
        uint128 amount; // ETH
        uint128 numSwap;
    }

    mapping(string => ReferralCodeInfo) private _referralCodes;

    struct PhaseInfo {
        uint128 startTime;
        uint128 endTime;
        uint256 swapRate;
    }

    uint256 private _totalPhases;

    mapping(uint256 => PhaseInfo) private _phases;

    struct LockedBalanceInfo {
        uint128 amount; // Token
        uint128 releaseTime;
    }

    uint256 private _totalLockedBalance;

    mapping(uint256 => mapping(address => LockedBalanceInfo)) private _lockedBalances;

    mapping(address => uint256[]) private _boughtPhases;

    modifier phaseExist(uint256 phaseId) {

        require(_phases[phaseId].swapRate > 0, "TokenSwap: phase doesn't exist");
        _;
    }

    constructor(address token, address adminWallet)
    {
        _token = IERC20(token);

        _adminWallet = adminWallet;

        _lockInterval = 6 * 30 days; // 6 months

        _lockPercentage = 75; // 75%

        _minDeposit = 0.5 ether;
    }

    function getContractInfo()
        public
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256, address, address)
    {

        return (
            _lockInterval, _lockPercentage, _totalLockedBalance, _totalPhases, _token.balanceOf(address(this)), _minDeposit,
            _adminWallet, address(_token)
        );
    }

    function updateAdminWallet(address adminWallet)
        public
        onlyOwner
    {

        require(adminWallet != address(0), "TokenSwap: address is invalid");

        _adminWallet = adminWallet;

        emit AdminWalletUpdated(adminWallet);
    }

    function updateLockInterval(uint256 lockInterval)
        public
        onlyOwner
    {

        _lockInterval = lockInterval;

        emit LockIntervalUpdated(lockInterval);
    }

    function updateLockPercentage(uint256 lockPercentage)
        public
        onlyOwner
    {

        require(lockPercentage <= 100, "TokenSwap: percentage is invalid");

        _lockPercentage = lockPercentage;

        emit LockPercentageUpdated(lockPercentage);
    }

    function updateMinDeposit(uint256 minDeposit)
        public
        onlyOwner
    {

        require(minDeposit > 0, "TokenSwap: amount is invalid");

        _minDeposit = minDeposit;

        emit MinDepositUpdated(minDeposit);
    }

    function withdrawToken(uint256 amount)
        public
        onlyOwner
    {

        require(amount > 0, "TokenSwap: amount is invalid");

        _token.transfer(_adminWallet, amount);

        emit TokenWithdrawed(amount);
    }

    function createPhase(uint256 startTime, uint256 endTime, uint256 swapRate)
        public
        onlyOwner
    {

        require(startTime >= block.timestamp && startTime > _phases[_totalPhases].endTime && startTime < endTime, "TokenSwap: time is invalid");

        require(swapRate > 0, "TokenSwap: rate is invalid");

        _totalPhases++;

        _phases[_totalPhases] = PhaseInfo(uint128(startTime), uint128(endTime), swapRate);

        emit PhaseCreated(startTime, endTime, swapRate);
    }

    function updatePhaseTime(uint256 phaseId, uint256 startTime, uint256 endTime)
        public
        onlyOwner
        phaseExist(phaseId)
    {

        PhaseInfo storage phase = _phases[phaseId];

        if (startTime != 0) {
            phase.startTime = uint128(startTime);
        }

        if (endTime != 0) {
            phase.endTime = uint128(endTime);
        }

        require((startTime == 0 || startTime >= block.timestamp) && phase.startTime < phase.endTime, "TokenSwap: time is invalid");

        emit PhaseTimeUpdated(phaseId, startTime, endTime);
    }

    function updateSwapRate(uint256 phaseId, uint256 swapRate)
        public
        onlyOwner
        phaseExist(phaseId)
    {

        require(swapRate > 0, "TokenSwap: rate is invalid");

        _phases[phaseId].swapRate = swapRate;

        emit SwapRateUpdated(phaseId, swapRate);
    }

    function getPhaseInfo(uint256 phaseId)
        public
        view
        returns (PhaseInfo memory)
    {

        return _phases[phaseId];
    }

    function getActivePhaseInfo()
        public
        view
        returns (uint256, PhaseInfo memory)
    {

        uint256 currentTime = block.timestamp;

        for (uint256 i = 1; i <= _totalPhases; i++) {
            PhaseInfo memory phase = _phases[i];

            if (currentTime < phase.endTime) {
                return (i, phase);
            }
        }

        return (0, _phases[0]);
    }

    function getReferralCodeInfo(string memory referralCode)
        public
        view
        returns (ReferralCodeInfo memory)
    {

        return _referralCodes[referralCode];
    }

    function swap(uint256 phaseId, string memory referralCode)
        public
        payable
    {

        require(msg.value >= _minDeposit, "TokenSwap: msg.value is invalid");

        PhaseInfo memory phase = _phases[phaseId];

        require(block.timestamp >= phase.startTime && block.timestamp < phase.endTime, "TokenSwap: not in swapping time");

        uint256 remain = _token.balanceOf(address(this)) - _totalLockedBalance;

        require(remain > 0, "TokenSwap: not enough token");

        uint256 amount = msg.value * phase.swapRate / 1 ether;

        uint refund;

        if (amount > remain) {
            refund = (amount - remain) * 1 ether / phase.swapRate;
            amount = remain;
        }

        if (refund > 0) {
            payable(_msgSender()).transfer(refund);
        }

        payable(_adminWallet).transfer(msg.value - refund);

        uint256 locked = amount * _lockPercentage / 100;

        _token.transfer(_msgSender(), amount - locked);

        _totalLockedBalance += locked;

        LockedBalanceInfo storage balance = _lockedBalances[phaseId][_msgSender()];
        balance.amount += uint128(locked);
        balance.releaseTime = uint128(phase.startTime + _lockInterval);

        ReferralCodeInfo storage referral = _referralCodes[referralCode];
        referral.amount += uint128(msg.value - refund);
        referral.numSwap++;

        uint256[] storage phases = _boughtPhases[_msgSender()];

        if (phases.length == 0 || phases[phases.length - 1] != phaseId) {
            phases.push(phaseId);
        }

        emit Swapped(phaseId, _msgSender(), msg.value, refund, amount, locked, referralCode);
    }

    function getTokenBalance(address account)
        public
        view
        returns (uint256, uint256)
    {

        uint256 currentTime = block.timestamp;

        uint256 balance;

        uint256 lockedBalance;

        uint256[] memory phases = _boughtPhases[account];

        for (uint256 i = 0; i < phases.length; i++) {
            LockedBalanceInfo memory info = _lockedBalances[phases[i]][account];

            if (info.amount == 0) {
                continue;
            }

            if (info.releaseTime <= currentTime) {
                balance += info.amount;

            } else {
                lockedBalance += info.amount;
            }
        }

        return (balance, lockedBalance);
    }

    function claimToken()
        public
    {

        address msgSender = _msgSender();

        uint256 currentTime = block.timestamp;

        uint256 balance;

        uint256[] memory phases = _boughtPhases[msgSender];

        uint256 length = phases.length;

        for (uint256 i = 0; i < length; i++) {
            LockedBalanceInfo memory info = _lockedBalances[phases[i]][msgSender];

            uint256 amount = info.amount;

            if (amount == 0) {
                continue;
            }

            if (info.releaseTime <= currentTime) {
                balance += amount;

                emit TokenClaimed(phases[i], msgSender, amount);

                delete _lockedBalances[phases[i]][msgSender];
            }
        }

        require(balance > 0, "TokenSwap: balance isn't enough");

        _totalLockedBalance -= balance;

        _token.transfer(msgSender, balance);

        emit TotalTokenClaimed(msgSender, balance);
    }

    function getLockedBalanceInfo(uint256 phaseId, address account)
        public
        view
        returns (LockedBalanceInfo memory)
    {

        return _lockedBalances[phaseId][account];
    }

    function getBoughtPhases(address account)
        public
        view
        returns (uint256[] memory)
    {

        return _boughtPhases[account];
    }

}