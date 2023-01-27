
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
}//MIT
pragma solidity ^0.8.0;

interface IVoters {

  function snapshot() external returns (uint);

  function totalSupplyAt(uint snapshotId) external view returns (uint);

  function votesAt(address account, uint snapshotId) external view returns (uint);

  function balanceOf(address account) external view returns (uint);

  function balanceOfAt(address account, uint snapshotId) external view returns (uint);

  function donate(uint amount) external;

}// MIT
pragma solidity ^0.8.0;

interface IERC677Receiver {

  function onTokenTransfer(address _sender, uint _value, bytes calldata _data) external;

}//MIT
pragma solidity ^0.8.0;


interface IStaking {

    function deposit(uint amount, address to) external;

}

interface ITiers {

    function userInfos(address user) external view returns (uint256, uint256, uint256);

    function userInfoTotal(address user) external view returns (uint256, uint256);

}

contract SaleFcfs is IERC677Receiver, Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    struct UserInfo {
        uint amount;
        bool claimed;
    }

    uint public constant PRECISION = 1e8;
    uint public constant ALLOCATION_DURATION = 7200; // 2 hours
    IERC20 public immutable paymentToken;
    IERC20 public immutable offeringToken;
    IERC20 public immutable vxrune;
    uint public immutable startTime;
    uint public immutable endTime;
    uint public offeringAmount;
    uint public raisingAmount;
    uint public raisingAmountTiers;
    uint public immutable perUserCap;
    bool public paused;
    bool public finalized;
    uint public totalAmount;
    mapping(address => UserInfo) public userInfo;
    address[] public addressList;
    IStaking public immutable staking;
    ITiers public tiers;
    uint public tiersAllocation;
    uint[] public tiersLevels;
    uint[] public tiersMultipliers;

    event PausedToggled(bool paused);
    event TiersConfigured(address tiersContract, uint allocation, uint[] levels, uint[] multipliers);
    event RaisingAmountSet(uint amount);
    event AmountsSet(uint offering, uint raising, uint raisingTiers);
    event Deposit(address indexed user, uint amount);
    event Harvest(address indexed user, uint amount);

    constructor(
        address _paymentToken,
        address _offeringToken,
        address _vxrune,
        uint _startTime,
        uint _endTime,
        uint _offeringAmount,
        uint _raisingAmount,
        uint _raisingAmountTiers,
        uint _perUserCap,
        address _staking
    ) Ownable() {
        paymentToken = IERC20(_paymentToken);
        offeringToken = IERC20(_offeringToken);
        vxrune = IERC20(_vxrune);
        startTime = _startTime;
        endTime = _endTime;
        offeringAmount = _offeringAmount;
        raisingAmount = _raisingAmount;
        raisingAmountTiers = _raisingAmountTiers;
        perUserCap = _perUserCap;
        staking = IStaking(_staking);
        require(_paymentToken != address(0) && _offeringToken != address(0), "!zero");
        require(_paymentToken != _offeringToken, "payment != offering");
        require(_offeringAmount > 0, "offering > 0");
        require(_raisingAmount > 0, "raising > 0");
        require(_startTime > block.timestamp, "start > now");
        require(_startTime + ALLOCATION_DURATION < _endTime, "start < end");
        require(_startTime < 1e10, "start time not unix");
        require(_endTime < 1e10, "start time not unix");
    }

    function configureTiers(
        address tiersContract,
        uint allocation,
        uint[] calldata levels,
        uint[] calldata multipliers
    ) external onlyOwner {

        tiers = ITiers(tiersContract);
        tiersAllocation = allocation;
        tiersLevels = levels;
        tiersMultipliers = multipliers;
        emit TiersConfigured(tiersContract, allocation, levels, multipliers);
    }

    function setRaisingAmount(uint amount) external onlyOwner {

      require(block.timestamp < startTime && totalAmount == 0, "sale started");
      raisingAmount = amount;
      emit RaisingAmountSet(amount);
    }

    function setAmounts(uint offering, uint raising, uint raisingTiers) external onlyOwner {

      require(block.timestamp < startTime && totalAmount == 0, "sale started");
      offeringAmount = offering;
      raisingAmount = raising;
      raisingAmountTiers = raisingTiers;
      emit AmountsSet(offering, raising, raisingTiers);
    }

    function togglePaused() external onlyOwner {

        paused = !paused;
        emit PausedToggled(paused);
    }

    function finalize() external {

        require(msg.sender == owner() || block.timestamp > endTime + 30 days, "not allowed");
        finalized = true;
    }

    function getAddressListLength() external view returns (uint) {

        return addressList.length;
    }

    function getParams() external view returns (uint, uint, uint, uint, uint, uint, uint, bool, bool) {

        return (startTime, endTime, raisingAmount, offeringAmount, raisingAmountTiers, perUserCap, totalAmount, paused, finalized);
    }

    function getTiersParams() external view returns (uint, uint[] memory, uint[] memory) {

        return (tiersAllocation, tiersLevels, tiersMultipliers);
    }

    function getOfferingAmount(address _user) public view returns (uint) {

        return (userInfo[_user].amount * offeringAmount) / raisingAmount;
    }

    function getUserAllocation(address user) public view returns (uint, uint) {

        (, uint lastDeposit,) = tiers.userInfos(user);
        if (lastDeposit >= startTime || lastDeposit == 0) {
          return (0, 0);
        }

        uint allocation = 0;
        (, uint tiersTotal) = tiers.userInfoTotal(user);
        for (uint i = 0; i < tiersLevels.length; i++) {
            if (tiersTotal >= tiersLevels[i]) {
                allocation = (tiersAllocation * tiersMultipliers[i]) / PRECISION;
            }
        }
        return (allocation, tiersTotal);
    }

    function _deposit(address user, uint amount) private nonReentrant {

        require(!paused, "paused");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "sale not active");
        require(amount > 0, "need amount > 0");
        require(totalAmount < raisingAmount, "sold out");

        if (userInfo[user].amount == 0) {
            addressList.push(address(user));
        }

        (uint allocation, uint tiersTotal) = getUserAllocation(user);
        if (block.timestamp < startTime + ALLOCATION_DURATION) {
            require(userInfo[user].amount + amount <= allocation, "over allocation size");
            require(totalAmount + amount <= raisingAmountTiers, "reached phase 1 total cap");
        } else {
            require(perUserCap == 0 || userInfo[user].amount + amount <= allocation + perUserCap, "over per user cap");
            require(vxrune.balanceOf(user) >= 100 || tiersTotal >= 100, "minimum 100 vXRUNE or staked to participate");
        }

        if (totalAmount + amount > raisingAmount) {
            paymentToken.safeTransfer(user, (totalAmount + amount) - raisingAmount);
            amount = raisingAmount - totalAmount;
        }

        userInfo[user].amount = userInfo[user].amount + amount;
        totalAmount = totalAmount + amount;
        emit Deposit(user, amount);
    }

    function deposit(uint amount) external {

        _transferFrom(msg.sender, amount);
        _deposit(msg.sender, amount);
    }

    function onTokenTransfer(address user, uint amount, bytes calldata _data) external override {

        require(msg.sender == address(paymentToken), "onTokenTransfer: not paymentToken");
        _deposit(user, amount);
    }

    function harvest(bool stake) external nonReentrant {

        require(!paused, "paused");
        require(block.timestamp > endTime, "sale not ended");
        require(finalized, "not finalized");
        require(userInfo[msg.sender].amount > 0, "have you participated?");
        require(!userInfo[msg.sender].claimed, "nothing to harvest");
        userInfo[msg.sender].claimed = true;
        uint amount = getOfferingAmount(msg.sender);

        if (stake) {
            require(address(staking) != address(0), "no staking available");
            offeringToken.approve(address(staking), amount);
            staking.deposit(amount, msg.sender);
        } else {
            offeringToken.safeTransfer(address(msg.sender), amount);
        }

        emit Harvest(msg.sender, amount);
    }

    function withdrawToken(address token, uint amount) external onlyOwner {

        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function _transferFrom(address from, uint amount) private {

        uint balanceBefore = paymentToken.balanceOf(address(this));
        paymentToken.safeTransferFrom(from, address(this), amount);
        uint balanceAfter = paymentToken.balanceOf(address(this));
        require(balanceAfter - balanceBefore == amount, "_transferFrom: balance change does not match amount");
    }
}