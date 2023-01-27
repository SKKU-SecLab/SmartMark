

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}




interface IERC20Upgradeable {

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




interface IPureFiFarming{

    function depositTo(uint16 _pid, uint256 _amount, address _beneficiary) external;

    function deposit(uint16 _pid, uint256 _amount) external;

    function withdraw(uint16 _pid, uint256 _amount) external;

    function claimReward(uint16 _pid) external;

    function exit(uint16 _pid) external;

    function emergencyWithdraw(uint16 _pid) external;

    function getContractData() external view returns (uint256, uint256, uint64);

    function getPoolLength() external view returns (uint256);

    function getPool(uint16 _index) external view returns (address, uint256, uint64, uint64, uint64, uint256, uint256);

    function getUserInfo(uint16 _pid, address _user) external view returns (uint256, uint256, uint256);

}













library AddressUpgradeable {

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}










abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}



abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}









abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}




 abstract contract PureFiPaymentPlan is Initializable, OwnableUpgradeable, PausableUpgradeable {

  using SafeERC20Upgradeable for IERC20Upgradeable;

  struct Vesting{
    uint8 paymentPlan; //payment plan ID
    uint64 startDate; //payment plan initiation date. Can be 0 if PaymentPlan refers to exact unlock timestamps.
    uint256 totalAmount; //total amount of tokens vested for a person
    uint256 withdrawnAmount; //amount withdrawn by user
  }

  mapping (address => Vesting) internal vestedTokens;

  IERC20Upgradeable public token;
  uint256 public totalVestedAmount; // total amount of vested tokens under this contract control.
  address public farmingContract;
  uint8 public farmingContractPool;

  event Withdrawal(address indexed who, uint256 amount);
  event PaymentPlanAdded(uint256 index);
  event TokensVested(address indexed beneficiary, uint8 paymentPlan, uint64 startDate, uint256 amount);
  
  function initialize(
        address _token
    ) public initializer {
        __Ownable_init();
        __Pausable_init_unchained();

       require(_token != address(0),"incorrect token address");
       token = IERC20Upgradeable(_token);
    }

  function pause() onlyOwner public {
      super._pause();
  }
   
  function unpause() onlyOwner public {
      super._unpause();
  }

  function setFarmingContract(address _farmingContract, uint8 _farmingContractPool) onlyOwner public {
    farmingContract = _farmingContract;
    farmingContractPool = _farmingContractPool;
  }

  function vestTokens(uint8 _paymentPlan, uint64 _startDate, uint256 _amount, address _beneficiary) public onlyOwner whenNotPaused{
    require(vestedTokens[_beneficiary].totalAmount == 0, "This address already has vested tokens");
    require(_isPaymentPlanExists(_paymentPlan), "Incorrect payment plan index");
    require(_amount > 0, "Can't vest 0 tokens");
    require(token.balanceOf(address(this)) >= totalVestedAmount + _amount, "Not enough tokens for this vesting plan");
    vestedTokens[_beneficiary] = Vesting(_paymentPlan, _startDate, _amount, 0);
    totalVestedAmount += _amount;
    emit TokensVested(_beneficiary, _paymentPlan, _startDate, _amount);
  }

  function withdrawAvailableTokens() public whenNotPaused {
    (, uint256 available) = withdrawableAmount(msg.sender);
    _prepareWithdraw(available);
    token.safeTransfer(msg.sender, available);
  }

  function withdrawAndStakeAvailableTokens() public whenNotPaused {
    require(farmingContract != address(0),"Farming contract is not defined");
    (, uint256 available) = withdrawableAmount(msg.sender);
    _prepareWithdraw(available);
    token.safeApprove(farmingContract, available);
    IPureFiFarming(farmingContract).depositTo(farmingContractPool, available, msg.sender);
  }

  function withdraw(uint256 _amount) public whenNotPaused {
    _prepareWithdraw(_amount);
    token.safeTransfer(msg.sender, _amount);
  }

  function withdrawAndStake(uint256 _amount) public whenNotPaused{
    require(farmingContract != address(0),"Farming contract is not defined");
    _prepareWithdraw(_amount);
    token.safeApprove(farmingContract, _amount);
    IPureFiFarming(farmingContract).depositTo(farmingContractPool, _amount, msg.sender);
  }

  function _prepareWithdraw(uint256 _amount) private {
    require(vestedTokens[msg.sender].totalAmount > 0,"No tokens vested for this address");
    (, uint256 available) = withdrawableAmount(msg.sender);
    require(_amount <= available, "Amount exeeded current withdrawable amount");
    require(available > 0, "Nothing to withdraw");
    vestedTokens[msg.sender].withdrawnAmount += _amount;
    totalVestedAmount -= _amount;
    emit Withdrawal(msg.sender, _amount);
  } 
  
  function withdrawableAmount(address _beneficiary) public virtual view returns (uint64, uint256);

  function vestingData(address _beneficiary) public view returns (uint8, uint64, uint64, uint256, uint256, uint256) {
    (uint64 nextUnlockDate, uint256 available) = withdrawableAmount(_beneficiary);
    return (vestedTokens[_beneficiary].paymentPlan, vestedTokens[_beneficiary].startDate, nextUnlockDate, vestedTokens[_beneficiary].totalAmount, vestedTokens[_beneficiary].withdrawnAmount, available);
  }

  function _isPaymentPlanExists(uint8 _id) internal virtual view returns (bool);

}
contract PureFiFixedDatePaymentPlan is PureFiPaymentPlan {


  struct PaymentPlan{
    uint64[] unlockDateShift; //timestamp shift of the unlock date; I.e. unlock date = unlockDateShift + startDate
    uint16[] unlockPercent; //unlock percents multiplied by 100;
  }

  PaymentPlan[] internal paymentPlans;

  uint256 public constant PERCENT_100 = 100_00; // 100% with extra denominator

  function addPaymentPlan(uint64[] memory _ts, uint16[] memory _percents) public onlyOwner whenNotPaused{

    require(_ts.length == _percents.length,"array length doesn't match");
    uint16 totalPercent = 0;
    uint16 prevPercent = 0;
    uint64 prevDate = 0;
    for(uint i = 0; i < _ts.length; i++){
      require (prevPercent <= _percents[i], "Incorrect percent value");
      require (prevDate <= _ts[i], "Incorrect unlock date value");
      prevPercent = _percents[i];
      prevDate = _ts[i];
      totalPercent += _percents[i];
    }
    require(totalPercent == PERCENT_100, "Total percent is not 100%");
    
    paymentPlans.push(PaymentPlan(_ts, _percents));
    emit PaymentPlanAdded(paymentPlans.length - 1);
  }

  function withdrawableAmount(address _beneficiary) public override view returns (uint64, uint256) {

    require(vestedTokens[_beneficiary].totalAmount > 0,"No tokens vested for this address");
    uint16 percentLocked = 0;
    uint64 paymentPlanStartDate = vestedTokens[_beneficiary].startDate;
    uint256 index = paymentPlans[vestedTokens[_beneficiary].paymentPlan].unlockPercent.length;
    uint64 nextUnlockDate = 0;
    while (index > 0 && uint64(block.timestamp) < paymentPlanStartDate + paymentPlans[vestedTokens[_beneficiary].paymentPlan].unlockDateShift[index-1]) {
      index--;
      nextUnlockDate = paymentPlanStartDate + paymentPlans[vestedTokens[_beneficiary].paymentPlan].unlockDateShift[index];
      percentLocked += paymentPlans[vestedTokens[_beneficiary].paymentPlan].unlockPercent[index];
      
    }
    uint256 amountLocked = vestedTokens[_beneficiary].totalAmount*percentLocked / PERCENT_100;
    uint256 remaining = vestedTokens[_beneficiary].totalAmount - vestedTokens[_beneficiary].withdrawnAmount;
    uint256 available = 0;
    if (remaining > amountLocked){
      available = remaining - amountLocked;
    } else {
      available = 0;
    }

    return (nextUnlockDate, available);
  }

  function paymentPlanLength(uint256 _paymentPlan) public view returns(uint256){

    return paymentPlans[_paymentPlan].unlockPercent.length;
  }

  function paymentPlanData(uint256 _paymentPlan, uint256 _index) public view returns (uint64, uint16){

    return (paymentPlans[_paymentPlan].unlockDateShift[_index], paymentPlans[_paymentPlan].unlockPercent[_index]);
  }

  function _isPaymentPlanExists(uint8 _id) internal override view returns (bool){

    return (_id < paymentPlans.length);
  }
}