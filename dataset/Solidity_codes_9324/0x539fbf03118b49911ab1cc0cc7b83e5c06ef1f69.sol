

pragma solidity >=0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

contract LasmVesting is ReentrancyGuard, Ownable {

    uint256 private constant E18                         = 10 ** 18;

    uint256 private constant LOCKED_ALLOCATION           = 160_000_000 * E18;
    uint256 private constant PUBLIC_SALE_ALLOCATION      =  80_000_000 * E18;
    uint256 private constant TEAM_ALLOCATION_1           = 110_000_000 * E18;
    uint256 private constant TEAM_ALLOCATION_2           =  10_000_000 * E18;
    uint256 private constant PARTNERS_ALLOCATION         =  40_000_000 * E18;
    uint256 private constant MARKETING_ALLOCATION        =  40_000_000 * E18;
    uint256 private constant DEVELOPMENT_ALLOCATION      =  80_000_000 * E18;
    uint256 private constant STAKING_ALLOCATION          = 240_000_000 * E18;
    uint256 private constant AIRDROP_ALLOCATION          =  40_000_000 * E18;

    address private constant lockedWallet            = address(0x35eb4C5e5b240C6Ec155516385Db59327B3415B1);
    address private constant managerWallet           = address(0xA22Bf614Fa7Fe2486d2bdf9B1Ace730716caFa70);
    address private constant teamWallet              = address(0xb37F5a0Da2630a9474791f606048538AEc5F1ca9);
    address private constant partnersWallet          = address(0x6C53d1F3323Ca6F8a0d10Ed12B1248254DCd0453);
    address private constant marketingWallet         = address(0x51f68ddA6470C0aE5B7383F2af3614C582D80A0F);
    address private constant developmentWallet       = address(0xEf3fE1A4B8393ac016Ef57020c28E0487e0EdbDa);
    address private constant stakingRewardsWallet    = address(0x4168CAc6FB9c95d19d8cAA39BfC0418ab41564C9);
    address private constant airdropWallet           = address(0xe7bB7d8be65A11b4BA7141EE6E1CD85D13ad650C);

    uint256 private constant VESTING_END_AT = 4 * 365 days;  // 48 months

    address public vestingToken;   // ERC20 token that get vested.

    event TokenSet(address vestingToken);
    event Claimed(address indexed beneficiary, uint256 amount);

    struct Schedule {
        string templateName;

        uint256 claimedTokens;

        uint256 startTime;

        uint256 allocation;

        uint256 duration;

        uint256 cliff;

        uint256 linear;

        uint256 lastClaimTime;
    }

    struct ClaimedEvent {
        uint8 scheduleIndex;

        uint256 claimedTokens;

        uint256 unlockedTokens;

        uint256 lockedTokens;

        uint256 eventTime;
    }

    Schedule[] public schedules;
    ClaimedEvent[] public scheduleEvents;

    mapping (address => uint8[]) public schedulesByOwner;
    mapping (string => uint8) public schedulesByName;
    mapping (string => address) public beneficiary;

    mapping (address => uint8[]) public eventsByScheduleBeneficiary;
    mapping (string => uint8[]) public eventsByScheduleName;

    constructor() {
    }

    function setToken(address tokenAddress) external onlyOwner {

        require(tokenAddress != address(0), "Vesting: ZERO_ADDRESS_NOT_ALLOWED");
        require(vestingToken == address(0), "Vesting: ALREADY_SET");

        vestingToken = tokenAddress;

        emit TokenSet(tokenAddress);
    }

    function initVestingSchedule() public onlyOwner {

        _createSchedule(lockedWallet, Schedule({
            templateName         :  "Locked",
            claimedTokens        :  uint256(0),
            startTime            :  block.timestamp,
            allocation           :  LOCKED_ALLOCATION,
            duration             :  93312000,     // 36 Months (36 * 30 * 24 * 60 * 60)
            cliff                :  62208000,     // 24 Months (24 * 30 * 24 * 60 * 60)
            linear               :  31104000,     // 12 Months (12 * 30 * 24 * 60 * 60)
            lastClaimTime        :  0
        }));

        _createSchedule(managerWallet, Schedule({
            templateName         :  "PublicSale",
            claimedTokens        :  uint256(0),
            startTime            :  block.timestamp,
            allocation           :  PUBLIC_SALE_ALLOCATION,
            duration             :  18144000,     // 7 Months (7 * 30 * 24 * 60 * 60)
            cliff                :   7776000,     // 3 Months (4 * 30 * 24 * 60 * 60)
            linear               :  10368000,     // 4 Months (4 * 30 * 24 * 60 * 60)
            lastClaimTime        :  0
        }));

        _createSchedule(teamWallet, Schedule({
            templateName         :  "Team_1",
            claimedTokens        :  uint256(0),
            startTime            :  block.timestamp,
            allocation           :  TEAM_ALLOCATION_1,
            duration             :  93312000,    // 36 Months (36 * 30 * 24 * 60 * 60)
            cliff                :   7776000,    //  3 Months ( 3 * 30 * 24 * 60 * 60)
            linear               :  85536000,    // 33 Months (33 * 30 * 24 * 60 * 60)
            lastClaimTime        :  0
        }));

        _createSchedule(teamWallet, Schedule({
            templateName         :  "Team_2",
            claimedTokens        :  uint256(0),
            startTime            :  block.timestamp + 93312000,     // After 36 Months of closing the Team Allocation_1
            allocation           :  TEAM_ALLOCATION_2,
            duration             :  31104000,    // 12 Months (12 * 30 * 24 * 60 * 60)
            cliff                :  0,
            linear               :  31104000,    // 12 Months (12 * 30 * 24 * 60 * 60)
            lastClaimTime        :  0
        }));

        _createSchedule(partnersWallet, Schedule({
            templateName         :  "Partners",
            claimedTokens        :  uint256(0),
            startTime            :  block.timestamp,
            allocation           :  PARTNERS_ALLOCATION,
            duration             :  62208000,     // 24 Months (24 * 30 * 24 * 60 * 60)
            cliff                :  31104000,     // 12 Months (12 * 30 * 24 * 60 * 60)
            linear               :  31104000,     // 12 Months (12 * 30 * 24 * 60 * 60)
            lastClaimTime        :  0
        }));

        _createSchedule(marketingWallet, Schedule({
            templateName         :  "Marketing",
            claimedTokens        :  uint256(0),
            startTime            :  block.timestamp,
            allocation           :  MARKETING_ALLOCATION,
            duration             :  0,            // 0 Months
            cliff                :  0,            // 0 Months
            linear               :  0,            // 0 Months
            lastClaimTime        :  0
        }));

        _createSchedule(developmentWallet, Schedule({
            templateName         :  "Development",
            claimedTokens        :  uint256(0),
            startTime            :  block.timestamp,
            allocation           :  DEVELOPMENT_ALLOCATION,
            duration             :  0,            // 0 Month
            cliff                :  0,            // 0 Month
            linear               :  0,            // 0 Month
            lastClaimTime        :  0
        }));

        _createSchedule(stakingRewardsWallet, Schedule({
            templateName         :  "Staking",
            claimedTokens        :  uint256(0),
            startTime            :  block.timestamp,
            allocation           :  STAKING_ALLOCATION,
            duration             :  85536000,     // 33 Months (33 * 30 * 24 * 60 * 60)
            cliff                :   7776000,     //  3 Months ( 3 * 30 * 24 * 60 * 60)
            linear               :  77760000,     // 30 Months (30 * 30 * 24 * 60 * 60)
            lastClaimTime        :  0
        }));

        _createSchedule(airdropWallet, Schedule({
            templateName         :  "Airdrop",
            claimedTokens        :  uint256(0),
            startTime            :  block.timestamp,
            allocation           :  AIRDROP_ALLOCATION,
            duration             :  0,            // 0 Month
            cliff                :  0,            // 0 Month
            linear               :  0,            // 0 Month
            lastClaimTime        :  0
        }));
    }

    function _createSchedule(address _beneficiary, Schedule memory _schedule) internal {

        schedules.push(_schedule);

        uint8 index = uint8(schedules.length) - 1;

        schedulesByOwner[_beneficiary].push(index);
        schedulesByName[_schedule.templateName] = index;
        beneficiary[_schedule.templateName] = _beneficiary;
    }

    function pendingTokensByScheduleBeneficiary(address _account) public view returns (uint256) {

        uint8[] memory _indexs = schedulesByOwner[_account];
        require(_indexs.length != uint256(0), "Vesting: NOT_AUTORIZE");

        uint256 amount = 0;
        for (uint8 i = 0; i < _indexs.length; i++) {
            string memory _templateName = schedules[_indexs[i]].templateName;
            amount += pendingTokensByScheduleName(_templateName);
        }

        return amount;
    }

    function pendingTokensByScheduleName(string memory _templateName) public view returns (uint256) {

        uint8 index = schedulesByName[_templateName];
        require(index >= 0 && index < schedules.length, "Vesting: NOT_SCHEDULE");

        Schedule memory schedule = schedules[index];
        uint256 vestedAmount = 0;
        if (
            schedule.startTime + schedule.cliff >= block.timestamp 
            || schedule.claimedTokens == schedule.allocation) {
            return 0;
        }

        if (schedule.duration == 0 && schedule.startTime <= block.timestamp) {
            vestedAmount = schedule.allocation;
        }
        else if (schedule.startTime + schedule.duration <= block.timestamp) {
            vestedAmount = schedule.allocation;
        } 
        else {
            if (block.timestamp > schedule.startTime + schedule.cliff && schedule.linear > 0) {
                uint256 timePeriod            = block.timestamp - schedule.startTime - schedule.cliff;
                uint256 unitPeriodAllocation  = schedule.allocation / schedule.linear;

                vestedAmount = timePeriod * unitPeriodAllocation;
            }
            else 
                return 0;
        }

        return vestedAmount - schedule.claimedTokens;
    }

    function claimByScheduleBeneficiary() external nonReentrant {

        require(vestingToken != address(0), "Vesting: VESTINGTOKEN_NO__SET");

        uint8[] memory _indexs = schedulesByOwner[msg.sender];
        require(_indexs.length != uint256(0), "Vesting: NOT_AUTORIZE");

        uint256 amount = 0;
        uint8 index;
        for (uint8 i = 0; i < _indexs.length; i++) {
            index = _indexs[i];

            string memory _templateName = schedules[index].templateName;
            uint256 claimAmount = pendingTokensByScheduleName(_templateName);

            if (claimAmount == 0)
                continue;

            schedules[index].claimedTokens += claimAmount;
            schedules[index].lastClaimTime = block.timestamp;
            amount += claimAmount;

            registerEvent(msg.sender, index, claimAmount);
        }

        require(amount > uint256(0), "Vesting: NO_VESTED_TOKENS");

        SafeERC20.safeTransfer(IERC20(vestingToken), msg.sender, amount);

        emit Claimed(msg.sender, amount);
    }

    function claimByScheduleName(string memory _templateName) external nonReentrant {

        require(vestingToken != address(0), "Vesting: VESTINGTOKEN_NO__SET");

        uint8 index = schedulesByName[_templateName];
        require(index >= 0 && index < schedules.length, "Vesting: NOT_SCHEDULE");
        require(beneficiary[_templateName] == msg.sender, "Vesting: NOT_AUTORIZE");

        uint256 claimAmount = pendingTokensByScheduleName(_templateName);

        require(claimAmount > uint256(0), "Vesting: NO_VESTED_TOKENS");

        schedules[index].claimedTokens += claimAmount;
        schedules[index].lastClaimTime = block.timestamp;

        SafeERC20.safeTransfer(IERC20(vestingToken), msg.sender, claimAmount);

        registerEvent(msg.sender, index, claimAmount);

        emit Claimed(beneficiary[_templateName], claimAmount);
    }

    function registerEvent(address _account, uint8 _scheduleIndex, uint256 _claimedTokens) internal {

        Schedule memory schedule = schedules[_scheduleIndex];

        scheduleEvents.push(ClaimedEvent({
            scheduleIndex: _scheduleIndex,
            claimedTokens: _claimedTokens,
            unlockedTokens: schedule.claimedTokens,
            lockedTokens: schedule.allocation - schedule.claimedTokens,
            eventTime: schedule.lastClaimTime
        }));

        eventsByScheduleBeneficiary[_account].push(uint8(scheduleEvents.length) - 1);
        eventsByScheduleName[schedule.templateName].push(uint8(scheduleEvents.length) - 1);
    }

    function withdraw(address tokenAddress, uint256 amount, address destination) external onlyOwner {

        require(vestingToken != address(0), "Vesting: VESTINGTOKEN_NO__SET");
        require(block.timestamp > VESTING_END_AT, "Vesting: NOT_ALLOWED");
        require(destination != address(0),        "Vesting: ZERO_ADDRESS_NOT_ALLOWED");
        require(amount <= IERC20(tokenAddress).balanceOf(address(this)), "Insufficient balance");

        SafeERC20.safeTransfer(IERC20(tokenAddress), destination, amount);
    }
}