


pragma experimental ABIEncoderV2;
pragma solidity ^0.6.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}

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

library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract FarmTokenV1 is IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private shares;
    mapping(address => mapping (address => uint256)) private allowances;

    uint256 public totalShares;

    string public name;
    string public symbol;
    string public underlying;
    address public underlyingContract;

    uint8 public decimals;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, uint8 _decimals, address _underlyingContract) public {
        name = string(abi.encodePacked(abi.encodePacked("Stacker Ventures ", _name), " v1"));
        symbol = string(abi.encodePacked("stack", _name));
        underlying = _name;

        decimals = _decimals;

        underlyingContract = _underlyingContract;
    }

    function totalSupply() external override view returns (uint256){
        return _getTotalUnderlying();
    }

    function totalUnderlying() external view returns (uint256){
        return _getTotalUnderlying();
    }

    function balanceOf(address _account) public override view returns (uint256){
        return getUnderlyingForShares(_sharesOf(_account));
    }

    function transfer(address _recipient, uint256 _amount) external override returns (bool){
        _verify(msg.sender, _amount);
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) external override returns (bool){
        _verify(_sender, _amount);
        uint256 _currentAllowance = allowances[_sender][msg.sender];
        require(_currentAllowance >= _amount, "FARMTOKENV1: not enough allowance");

        _transfer(_sender, _recipient, _amount);
        _approve(_sender, msg.sender, _currentAllowance.sub(_amount));
        return true;
    }

    function _verify(address _account, uint256 _amountUnderlyingToSend) internal virtual;

    function allowance(address _owner, address _spender) external override view returns (uint256){
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) external override returns (bool){
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function sharesOf(address _account) external view returns (uint256) {
        return _sharesOf(_account);
    }

    function getSharesForUnderlying(uint256 _amountUnderlying) public view returns (uint256){
        uint256 _totalUnderlying = _getTotalUnderlying();
        if (_totalUnderlying == 0){
            return _amountUnderlying; // this will init at 1:1 _underlying:_shares
        }
        uint256 _totalShares = totalShares;
        if (_totalShares == 0){
            return _amountUnderlying; // this will init the first shares, expected contract underlying balance == 0, or there will be a bonus (doesn't belong to anyone so ok)
        }

        return _amountUnderlying.mul(_totalShares).div(_totalUnderlying);
    }

    function getUnderlyingForShares(uint256 _amountShares) public view returns (uint256){
        uint256 _totalShares = totalShares;
        if (_totalShares == 0){
            return _amountShares; // this will init at 1:1 _shares:_underlying
        }
        uint256 _totalUnderlying = _getTotalUnderlying();
        if (_totalUnderlying == 0){
            return _amountShares; // this will init at 1:1 
        }

        return _amountShares.mul(_totalUnderlying).div(_totalShares);

    }

    function _sharesOf(address _account) internal view returns (uint256){
        return shares[_account];
    }

    function _getTotalUnderlying() internal virtual view returns (uint256);

    function _transfer(address _sender, address _recipient, uint256 _amount) internal {
        uint256 _sharesToTransfer = getSharesForUnderlying(_amount);
        _transferShares(_sender, _recipient, _sharesToTransfer);
        emit Transfer(_sender, _recipient, _amount);
    }

    function _approve(address _owner, address _spender, uint256 _amount) internal {
        require(_owner != address(0), "FARMTOKENV1: from == 0x0");
        require(_spender != address(0), "FARMTOKENV1: to == 0x00");

        allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function _transferShares(address _sender, address _recipient,  uint256 _amountShares) internal {
        require(_sender != address(0), "FARMTOKENV1: from == 0x00");
        require(_recipient != address(0), "FARMTOKENV1: to == 0x00");

        uint256 _currentSenderShares = shares[_sender];
        require(_amountShares <= _currentSenderShares, "FARMTOKENV1: transfer amount exceeds balance");

        shares[_sender] = _currentSenderShares.sub(_amountShares);
        shares[_recipient] = shares[_recipient].add(_amountShares);
    }

    function _mintShares(address _recipient, uint256 _amountShares) internal {
        require(_recipient != address(0), "FARMTOKENV1: to == 0x00");

        totalShares = totalShares.add(_amountShares);
        shares[_recipient] = shares[_recipient].add(_amountShares);



    }

    function _burnShares(address _account, uint256 _amountShares) internal {
        require(_account != address(0), "FARMTOKENV1: burn from == 0x00");

        uint256 _accountShares = shares[_account];
        require(_amountShares <= _accountShares, "FARMTOKENV1: burn amount exceeds balance");
        totalShares = totalShares.sub(_amountShares);

        shares[_account] = _accountShares.sub(_amountShares);



    }
}

contract FarmTreasuryV1 is ReentrancyGuard, FarmTokenV1 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    mapping(address => DepositInfo) public userDeposits;
    mapping(address => bool) public noLockWhitelist;

    struct DepositInfo {
        uint256 amountUnderlyingLocked;
        uint256 timestampDeposit;
        uint256 timestampUnlocked;
    }

    uint256 internal constant LOOP_LIMIT = 200;

    address payable public governance;
    address payable public farmBoss;

    bool public paused = false;
    bool public pausedDeposits = false;

    uint256 public constant max = 10000;
    uint256 public performanceToTreasury = 1000;
    uint256 public performanceToFarmer = 1000;
    uint256 public baseToTreasury = 100;
    uint256 public baseToFarmer = 100;

    uint256 public rebalanceUpLimit = 100; // maximum of a 1% gain per rebalance
    uint256 public rebalanceUpWaitTime = 23 hours;
    uint256 public lastRebalanceUpTime;

    uint256 public waitPeriod = 1 weeks;

    uint256 public hotWalletHoldings = 1000; // 10% initially

    uint256 public ACTIVELY_FARMED;

    event RebalanceHot(uint256 amountIn, uint256 amountToFarmer, uint256 timestamp);
    event ProfitDeclared(bool profit, uint256 amount, uint256 timestamp, uint256 totalAmountInPool, uint256 totalSharesInPool, uint256 performanceFeeTotal, uint256 baseFeeTotal);
    event Deposit(address depositor, uint256 amount, address referral);
    event Withdraw(address withdrawer, uint256 amount);

    constructor(string memory _nameUnderlying, uint8 _decimalsUnderlying, address _underlying) public FarmTokenV1(_nameUnderlying, _decimalsUnderlying, _underlying) {
        governance = msg.sender;
        lastRebalanceUpTime = block.timestamp;
    }

    function setGovernance(address payable _new) external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        governance = _new;
    }

    function setFarmBoss(address payable _new) external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        farmBoss = _new;
    }

    function setNoLockWhitelist(address[] calldata _accounts, bool[] calldata _noLock) external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_accounts.length == _noLock.length && _accounts.length <= LOOP_LIMIT, "FARMTREASURYV1: check array lengths");

        for (uint256 i = 0; i < _accounts.length; i++){
            noLockWhitelist[_accounts[i]] = _noLock[i];
        }
    }

    function pause() external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        paused = true;
    }

    function unpause() external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        paused = false;
    }

    function pauseDeposits() external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        pausedDeposits = true;
    }

    function unpauseDeposits() external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        pausedDeposits = false;
    }

    function setFeeDistribution(uint256 _performanceToTreasury, uint256 _performanceToFarmer, uint256 _baseToTreasury, uint256 _baseToFarmer) external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_performanceToTreasury.add(_performanceToFarmer) < max, "FARMTREASURYV1: too high performance");
        require(_baseToTreasury.add(_baseToFarmer) <= 500, "FARMTREASURYV1: too high base");
        
        performanceToTreasury = _performanceToTreasury;
        performanceToFarmer = _performanceToFarmer;
        baseToTreasury = _baseToTreasury;
        baseToFarmer = _baseToFarmer;
    }

    function setWaitPeriod(uint256 _new) external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_new <= 10 weeks, "FARMTREASURYV1: too long wait");

        waitPeriod = _new;
    }

    function setHotWalletHoldings(uint256 _new) external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_new <= max && _new >= 100, "FARMTREASURYV1: hot wallet values bad");

        hotWalletHoldings = _new;
    }

    function setRebalanceUpLimit(uint256 _new) external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_new < max, "FARMTREASURYV1: >= max");

        rebalanceUpLimit = _new;
    }

    function setRebalanceUpWaitTime(uint256 _new) external {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_new <= 1 weeks, "FARMTREASURYV1: > 1 week");

        rebalanceUpWaitTime = _new;
    }

    function deposit(uint256 _amountUnderlying, address _referral) external nonReentrant {

        require(_amountUnderlying > 0, "FARMTREASURYV1: amount == 0");
        require(!paused && !pausedDeposits, "FARMTREASURYV1: paused");

        _deposit(_amountUnderlying, _referral);

        IERC20 _underlying = IERC20(underlyingContract);
        uint256 _before = _underlying.balanceOf(address(this));
        _underlying.safeTransferFrom(msg.sender, address(this), _amountUnderlying);
        uint256 _after = _underlying.balanceOf(address(this));
        uint256 _total = _after.sub(_before);
        require(_total >= _amountUnderlying, "FARMTREASURYV1: bad transfer");
    }

    function _deposit(uint256 _amountUnderlying, address _referral) internal {

        uint256 _sharesToMint = getSharesForUnderlying(_amountUnderlying);

        _mintShares(msg.sender, _sharesToMint);
        _storeDepositInfo(msg.sender, _amountUnderlying);

        if (_referral != msg.sender){
            emit Deposit(msg.sender, _amountUnderlying, _referral);
        }
        else {
            emit Deposit(msg.sender, _amountUnderlying, address(0));
        }

        emit Transfer(address(0), msg.sender, _amountUnderlying);
    }

    function _storeDepositInfo(address _account, uint256 _amountUnderlying) internal {


        DepositInfo memory _existingInfo = userDeposits[_account];

        if (_existingInfo.timestampDeposit == 0){
            DepositInfo memory _info = DepositInfo(
                {
                    amountUnderlyingLocked: _amountUnderlying, 
                    timestampDeposit: block.timestamp, 
                    timestampUnlocked: block.timestamp.add(waitPeriod)
                }
            );
            userDeposits[_account] = _info;
        }
        else {
            uint256 _lockedAmt = _getLockedAmount(_account, _existingInfo.amountUnderlyingLocked, _existingInfo.timestampDeposit, _existingInfo.timestampUnlocked);

            if (_lockedAmt == 0){
                DepositInfo memory _info = DepositInfo(
                    {
                        amountUnderlyingLocked: _amountUnderlying, 
                        timestampDeposit: block.timestamp, 
                        timestampUnlocked: block.timestamp.add(waitPeriod)
                    }
                );
                userDeposits[_account] = _info;
            }
            else {
                uint256 _lockedAmtTime = _lockedAmt.mul(_existingInfo.timestampUnlocked.sub(block.timestamp));
                uint256 _newAmtTime = _amountUnderlying.mul(waitPeriod);
                uint256 _total = _amountUnderlying.add(_lockedAmt);

                uint256 _newLockedTime = (_lockedAmtTime.add(_newAmtTime)).div(_total);

                DepositInfo memory _info = DepositInfo(
                    {
                        amountUnderlyingLocked: _total, 
                        timestampDeposit: block.timestamp, 
                        timestampUnlocked: block.timestamp.add(_newLockedTime)
                    }
                );
                userDeposits[_account] = _info;
            }
        }
    }

    function getLockedAmount(address _account) public view returns (uint256) {

        DepositInfo memory _existingInfo = userDeposits[_account];
        return _getLockedAmount(_account, _existingInfo.amountUnderlyingLocked, _existingInfo.timestampDeposit, _existingInfo.timestampUnlocked);
    }

    function _getLockedAmount(address _account, uint256 _amountLocked, uint256 _timestampDeposit, uint256 _timestampUnlocked) internal view returns (uint256) {

        if (_timestampUnlocked <= block.timestamp || noLockWhitelist[_account]){
            return 0;
        }
        else {
            uint256 _remainingTime = _timestampUnlocked.sub(block.timestamp);
            uint256 _totalTime = _timestampUnlocked.sub(_timestampDeposit);

            return _amountLocked.mul(_remainingTime).div(_totalTime);
        }
    }

    function withdraw(uint256 _amountUnderlying) external nonReentrant {

        require(_amountUnderlying > 0, "FARMTREASURYV1: amount == 0");
        require(!paused, "FARMTREASURYV1: paused");

        _withdraw(_amountUnderlying);

        IERC20(underlyingContract).safeTransfer(msg.sender, _amountUnderlying);
    }

    function _withdraw(uint256 _amountUnderlying) internal {

        _verify(msg.sender, _amountUnderlying);
        if (IERC20(underlyingContract).balanceOf(address(this)) < _amountUnderlying){
            revert("FARMTREASURYV1: Hot wallet balance depleted. Please try smaller withdraw or wait for rebalancing.");
        }

        uint256 _sharesToBurn = getSharesForUnderlying(_amountUnderlying);
        _burnShares(msg.sender, _sharesToBurn); // they must have >= _sharesToBurn, checked here

        emit Transfer(msg.sender, address(0), _amountUnderlying);
        emit Withdraw(msg.sender, _amountUnderlying);
    }

    function _verify(address _account, uint256 _amountUnderlyingToSend) internal override {

        DepositInfo memory _existingInfo = userDeposits[_account];

        uint256 _lockedAmt = _getLockedAmount(_account, _existingInfo.amountUnderlyingLocked, _existingInfo.timestampDeposit, _existingInfo.timestampUnlocked);
        uint256 _balance = balanceOf(_account);

        require(_balance.sub(_amountUnderlyingToSend) >= _lockedAmt, "FARMTREASURYV1: requested funds are temporarily locked");
    }

    function rebalanceUp(uint256 _amount, address _farmerRewards) external nonReentrant returns (bool, uint256) {

        require(msg.sender == farmBoss, "FARMTREASURYV1: !farmBoss");
        require(!paused, "FARMTREASURYV1: paused");

        if (_amount > 0){
            require(block.timestamp.sub(lastRebalanceUpTime) >= rebalanceUpWaitTime, "FARMTREASURYV1: <rebalanceUpWaitTime");
            require(ACTIVELY_FARMED.mul(rebalanceUpLimit).div(max) >= _amount, "FARMTREASURYV1 _amount > rebalanceUpLimit");
            ACTIVELY_FARMED = ACTIVELY_FARMED.add(_amount);
            uint256 _totalPerformance = _performanceFee(_amount, _farmerRewards);
            uint256 _totalAnnual = _annualFee(_farmerRewards);

            lastRebalanceUpTime = block.timestamp; 

            emit ProfitDeclared(true, _amount, block.timestamp, _getTotalUnderlying(), totalShares, _totalPerformance, _totalAnnual);
        }
        else {
            emit ProfitDeclared(true, _amount, block.timestamp, _getTotalUnderlying(), totalShares, 0, 0);
        }

        (bool _fundsNeeded, uint256 _amountChange) = _calcHotWallet();
        _rebalanceHot(_fundsNeeded, _amountChange); // if the hot wallet rebalance fails, revert() the entire function

        return (_fundsNeeded, _amountChange); // in case we need them, FE simulations and such
    }

    function rebalanceDown(uint256 _amount, bool _rebalanceHotWallet) external nonReentrant returns (bool, uint256) {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");

        ACTIVELY_FARMED = ACTIVELY_FARMED.sub(_amount);

        if (_rebalanceHotWallet){
            (bool _fundsNeeded, uint256 _amountChange) = _calcHotWallet();
            _rebalanceHot(_fundsNeeded, _amountChange); // if the hot wallet rebalance fails, revert() the entire function

            return (_fundsNeeded, _amountChange); // in case we need them, FE simulations and such
        }

        emit ProfitDeclared(false, _amount, block.timestamp, _getTotalUnderlying(), totalShares, 0, 0);

        return (false, 0);
    }

    function _performanceFee(uint256 _amount, address _farmerRewards) internal returns (uint256){


        uint256 _existingShares = totalShares;
        uint256 _balance = _getTotalUnderlying();

        uint256 _performanceToFarmerUnderlying = _amount.mul(performanceToFarmer).div(max);
        uint256 _performanceToTreasuryUnderlying = _amount.mul(performanceToTreasury).div(max);
        uint256 _performanceTotalUnderlying = _performanceToFarmerUnderlying.add(_performanceToTreasuryUnderlying);

        if (_performanceTotalUnderlying == 0){
            return 0;
        }

        uint256 _sharesToMint = _underlyingFeeToShares(_performanceTotalUnderlying, _balance, _existingShares);

        uint256 _sharesToFarmer = _sharesToMint.mul(_performanceToFarmerUnderlying).div(_performanceTotalUnderlying); // by the same ratio
        uint256 _sharesToTreasury = _sharesToMint.sub(_sharesToFarmer);

        _mintShares(_farmerRewards, _sharesToFarmer);
        _mintShares(governance, _sharesToTreasury);

        uint256 _underlyingFarmer = getUnderlyingForShares(_sharesToFarmer);
        uint256 _underlyingTreasury = getUnderlyingForShares(_sharesToTreasury);

        emit Transfer(address(0), _farmerRewards, _underlyingFarmer);
        emit Transfer(address(0), governance, _underlyingTreasury);

        return _underlyingFarmer.add(_underlyingTreasury);
    }

    function _annualFee(address _farmerRewards) internal returns (uint256) {

        uint256 _lastAnnualFeeTime = lastRebalanceUpTime;
        if (_lastAnnualFeeTime >= block.timestamp){
            return 0;
        }

        uint256 _elapsedTime = block.timestamp.sub(_lastAnnualFeeTime);
        uint256 _existingShares = totalShares;
        uint256 _balance = _getTotalUnderlying();

        uint256 _annualPossibleUnderlying = _balance.mul(_elapsedTime).div(365 days);
        uint256 _annualToFarmerUnderlying = _annualPossibleUnderlying.mul(baseToFarmer).div(max);
        uint256 _annualToTreasuryUnderlying = _annualPossibleUnderlying.mul(baseToFarmer).div(max);
        uint256 _annualTotalUnderlying = _annualToFarmerUnderlying.add(_annualToTreasuryUnderlying);

        if (_annualTotalUnderlying == 0){
            return 0;
        }

        uint256 _sharesToMint = _underlyingFeeToShares(_annualTotalUnderlying, _balance, _existingShares);

        uint256 _sharesToFarmer = _sharesToMint.mul(_annualToFarmerUnderlying).div(_annualTotalUnderlying); // by the same ratio
        uint256 _sharesToTreasury = _sharesToMint.sub(_sharesToFarmer);

        _mintShares(_farmerRewards, _sharesToFarmer);
        _mintShares(governance, _sharesToTreasury);

        uint256 _underlyingFarmer = getUnderlyingForShares(_sharesToFarmer);
        uint256 _underlyingTreasury = getUnderlyingForShares(_sharesToTreasury);

        emit Transfer(address(0), _farmerRewards, _underlyingFarmer);
        emit Transfer(address(0), governance, _underlyingTreasury);

        return _underlyingFarmer.add(_underlyingTreasury);
    }

    function _underlyingFeeToShares(uint256 _totalFeeUnderlying, uint256 _balance, uint256 _existingShares) pure internal returns (uint256 _sharesToMint){

        return _existingShares
                .mul(_balance)
                .div(_balance.sub(_totalFeeUnderlying))
                .sub(_existingShares);
    }

    function _calcHotWallet() internal view returns (bool _fundsNeeded, uint256 _amountChange) {

        uint256 _balanceHere = IERC20(underlyingContract).balanceOf(address(this));
        uint256 _balanceFarmed = ACTIVELY_FARMED;

        uint256 _totalAmount = _balanceHere.add(_balanceFarmed);
        uint256 _hotAmount = _totalAmount.mul(hotWalletHoldings).div(max);

        if (_balanceHere >= _hotAmount){
            return (false, _balanceHere.sub(_hotAmount));
        }
        if (_balanceHere < _hotAmount){
            return (true, _hotAmount.sub(_balanceHere));
        }
    }

    function _rebalanceHot(bool _fundsNeeded, uint256 _amountChange) internal {

        if (_fundsNeeded){
            uint256 _before = IERC20(underlyingContract).balanceOf(address(this));
            IERC20(underlyingContract).safeTransferFrom(farmBoss, address(this), _amountChange);
            uint256 _after = IERC20(underlyingContract).balanceOf(address(this));
            uint256 _total = _after.sub(_before);

            require(_total >= _amountChange, "FARMTREASURYV1: bad rebalance, hot wallet needs funds!");

            ACTIVELY_FARMED = ACTIVELY_FARMED.sub(_amountChange);

            emit RebalanceHot(_amountChange, 0, block.timestamp);
        }
        else {
            require(farmBoss != address(0), "FARMTREASURYV1: !FarmBoss"); // don't burn funds

            IERC20(underlyingContract).safeTransfer(farmBoss, _amountChange); // _calcHotWallet() guarantees we have funds here to send

            ACTIVELY_FARMED = ACTIVELY_FARMED.add(_amountChange);

            emit RebalanceHot(0, _amountChange, block.timestamp);
        }
    }

    function _getTotalUnderlying() internal override view returns (uint256) {

        uint256 _balanceHere = IERC20(underlyingContract).balanceOf(address(this));
        uint256 _balanceFarmed = ACTIVELY_FARMED;

        return _balanceHere.add(_balanceFarmed);
    }

    function rescue(address _token, uint256 _amount) external nonReentrant {

        require(msg.sender == governance, "FARMTREASURYV1: !governance");

        if (_token != address(0)){
            IERC20(_token).safeTransfer(governance, _amount);
        }
        else { // if _tokenContract is 0x0, then escape ETH
            governance.transfer(_amount);
        }
    }
}

interface IUniswapRouterV2 {

    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint[] memory amounts);

}

abstract contract FarmBossV1 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    mapping(address => mapping(bytes4 => uint256)) public whitelist; // contracts -> mapping (functionSig -> allowed, msg.value allowed)
    mapping(address => bool) public farmers;

    bytes4 constant internal FALLBACK_FN_SIG = 0xffffffff;
    uint256 constant internal NOT_ALLOWED = 0;
    uint256 constant internal ALLOWED_NO_MSG_VALUE = 1;
    uint256 constant internal ALLOWED_W_MSG_VALUE = 2; 

    uint256 internal constant LOOP_LIMIT = 200;
    uint256 public constant max = 10000;
    uint256 public CRVTokenTake = 1500; // pct of max

    struct WhitelistData {
        address account;
        bytes4 fnSig;
        bool valueAllowed;
    }

    struct Approves {
        address token;
        address allow;
    }

    address payable public governance;
    address public daoCouncilMultisig;
    address public treasury;
    address public underlying;

    address public constant UniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; 
    address public constant SushiswapRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant CRVToken = 0xD533a949740bb3306d119CC777fa900bA034cd52;

    event NewFarmer(address _farmer);
    event RmFarmer(address _farmer);

    event NewWhitelist(address _contract, bytes4 _fnSig, uint256 _allowedType);
    event RmWhitelist(address _contract, bytes4 _fnSig);

    event NewApproval(address _token, address _contract);
    event RmApproval(address _token, address _contract);

    event ExecuteSuccess(bytes _returnData);
    event ExecuteERROR(bytes _returnData);

    constructor(address payable _governance, address _daoMultisig, address _treasury, address _underlying) public {
        governance = _governance;
        daoCouncilMultisig = _daoMultisig;
        treasury = _treasury;
        underlying = _underlying;

        farmers[msg.sender] = true;
        emit NewFarmer(msg.sender);
        
        IERC20(_underlying).safeApprove(_treasury, type(uint256).max); // treasury has full control over underlying in this contract

        _initFirstFarms();
    }

    receive() payable external {}

    function _initFirstFarms() internal virtual;

    function setGovernance(address payable _new) external {
        require(msg.sender == governance, "FARMBOSSV1: !governance");

        governance = _new;
    }

    function setDaoCouncilMultisig(address _new) external {
        require(msg.sender == governance || msg.sender == daoCouncilMultisig, "FARMBOSSV1: !(governance || multisig)");

        daoCouncilMultisig = _new;
    }

    function setCRVTokenTake(uint256 _new) external {
        require(msg.sender == governance || msg.sender == daoCouncilMultisig, "FARMBOSSV1: !(governance || multisig)");
        require(_new <= max.div(2), "FARMBOSSV1: >half CRV to take");

        CRVTokenTake = _new;
    }

    function getWhitelist(address _contract, bytes4 _fnSig) external view returns (uint256){
        return whitelist[_contract][_fnSig];
    }

    function changeFarmers(address[] calldata _newFarmers, address[] calldata _rmFarmers) external {
        require(msg.sender == governance, "FARMBOSSV1: !governance");
        require(_newFarmers.length.add(_rmFarmers.length) <= LOOP_LIMIT, "FARMBOSSV1: >LOOP_LIMIT"); // dont allow unbounded loops

        for (uint256 i = 0; i < _newFarmers.length; i++){
            farmers[_newFarmers[i]] = true;

            emit NewFarmer(_newFarmers[i]);
        }
        for (uint256 j = 0; j < _rmFarmers.length; j++){
            farmers[_rmFarmers[j]] = false;

            emit RmFarmer(_rmFarmers[j]);
        }
    }

    function emergencyRemoveFarmers(address[] calldata _rmFarmers) external {
        require(msg.sender == daoCouncilMultisig, "FARMBOSSV1: !multisig");
        require(_rmFarmers.length <= LOOP_LIMIT, "FARMBOSSV1: >LOOP_LIMIT"); // dont allow unbounded loops

        for (uint256 j = 0; j < _rmFarmers.length; j++){
            farmers[_rmFarmers[j]] = false;

            emit RmFarmer(_rmFarmers[j]);
        }
    }

    function changeWhitelist(WhitelistData[] calldata _newActions, WhitelistData[] calldata _rmActions, Approves[] calldata _newApprovals, Approves[] calldata _newDepprovals) external {
        require(msg.sender == governance, "FARMBOSSV1: !governance");
        require(_newActions.length.add(_rmActions.length).add(_newApprovals.length).add(_newDepprovals.length) <= LOOP_LIMIT, "FARMBOSSV1: >LOOP_LIMIT"); // dont allow unbounded loops

        for (uint256 i = 0; i < _newActions.length; i++){
            _addWhitelist(_newActions[i].account, _newActions[i].fnSig, _newActions[i].valueAllowed);
        }
        for (uint256 j = 0; j < _rmActions.length; j++){
            whitelist[_rmActions[j].account][_rmActions[j].fnSig] = NOT_ALLOWED;

            emit RmWhitelist(_rmActions[j].account, _rmActions[j].fnSig);
        }
        for (uint256 k = 0; k < _newApprovals.length; k++){
            _approveMax(_newApprovals[k].token, _newApprovals[k].allow);
        }
        for (uint256 l = 0; l < _newDepprovals.length; l++){
            IERC20(_newDepprovals[l].token).safeApprove(_newDepprovals[l].allow, 0);

            emit RmApproval(_newDepprovals[l].token, _newDepprovals[l].allow);
        }
    }

    function _addWhitelist(address _contract, bytes4 _fnSig, bool _msgValueAllowed) internal {
        if (_msgValueAllowed){
            whitelist[_contract][_fnSig] = ALLOWED_W_MSG_VALUE;
            emit NewWhitelist(_contract, _fnSig, ALLOWED_W_MSG_VALUE);
        }
        else {
            whitelist[_contract][_fnSig] = ALLOWED_NO_MSG_VALUE;
            emit NewWhitelist(_contract, _fnSig, ALLOWED_NO_MSG_VALUE);
        }
    }

    function _approveMax(address _token, address _account) internal {
        IERC20(_token).safeApprove(_account, 0);
        IERC20(_token).safeApprove(_account, type(uint256).max);

        emit NewApproval(_token, _account);
    }

    function emergencyRemoveWhitelist(WhitelistData[] calldata _rmActions, Approves[] calldata _newDepprovals) external {
        require(msg.sender == daoCouncilMultisig, "FARMBOSSV1: !multisig");
        require(_rmActions.length.add(_newDepprovals.length) <= LOOP_LIMIT, "FARMBOSSV1: >LOOP_LIMIT"); // dont allow unbounded loops

        for (uint256 j = 0; j < _rmActions.length; j++){
            whitelist[_rmActions[j].account][_rmActions[j].fnSig] = NOT_ALLOWED;

            emit RmWhitelist(_rmActions[j].account, _rmActions[j].fnSig);
        }
        for (uint256 l = 0; l < _newDepprovals.length; l++){
            IERC20(_newDepprovals[l].token).safeApprove(_newDepprovals[l].allow, 0);

            emit RmApproval(_newDepprovals[l].token, _newDepprovals[l].allow);
        }
    }

    function govExecute(address payable _target, uint256 _value, bytes calldata _data) external returns (bool, bytes memory){
        require(msg.sender == governance, "FARMBOSSV1: !governance");

        return _execute(_target, _value, _data);
    }

    function farmerExecute(address payable _target, uint256 _value, bytes calldata _data) external returns (bool, bytes memory){
        require(farmers[msg.sender] || msg.sender == daoCouncilMultisig, "FARMBOSSV1: !(farmer || multisig)");
        
        require(_checkContractAndFn(_target, _value, _data), "FARMBOSSV1: target.fn() not allowed. ask DAO for approval.");
        return _execute(_target, _value, _data);
    }


    function _checkContractAndFn(address _target, uint256 _value, bytes calldata _data) internal view returns (bool) {

        bytes4 _fnSig;
        if (_data.length < 4){ // we are calling a payable function, or the data is otherwise invalid (need 4 bytes for any fn call)
            _fnSig = FALLBACK_FN_SIG;
        }
        else { // we are calling a normal function, get the function signature from the calldata (first 4 bytes of calldata)


            bytes memory _fnSigBytes = bytes(_data[0:4]);
            assembly {
                _fnSig := mload(add(add(_fnSigBytes, 0x20), 0))
            }
        }

        bytes4 _transferSig = 0xa9059cbb;
        bytes4 _approveSig = 0x095ea7b3;
        if (_fnSig == _transferSig || _fnSig == _approveSig || whitelist[_target][_fnSig] == NOT_ALLOWED){
            return false;
        }
        else if (whitelist[_target][_fnSig] == ALLOWED_NO_MSG_VALUE && _value > 0){
            return false;
        }
        return true;
    }

    function _execute(address payable _target, uint256 _value, bytes memory _data) internal returns (bool, bytes memory){
        bool _success;
        bytes memory _returnData;

        if (_data.length == 4 && _data[0] == 0xff && _data[1] == 0xff && _data[2] == 0xff && _data[3] == 0xff){ // check if fallback function is invoked, send w/ no data
            (_success, _returnData) = _target.call{value: _value}("");
        }
        else {
            (_success, _returnData) = _target.call{value: _value}(_data);
        }

        if (_success){
            emit ExecuteSuccess(_returnData);
        }
        else {
            emit ExecuteERROR(_returnData);
        }

        return (_success, _returnData);
    }

    function rebalanceUp(uint256 _amount, address _farmerRewards) external {
        require(msg.sender == governance || farmers[msg.sender] || msg.sender == daoCouncilMultisig, "FARMBOSSV1: !(governance || farmer || multisig)");

        FarmTreasuryV1(treasury).rebalanceUp(_amount, _farmerRewards);
    }

    function sellExactTokensForUnderlyingToken(bytes calldata _data, bool _isSushi) external returns (uint[] memory amounts){
        require(msg.sender == governance || farmers[msg.sender] || msg.sender == daoCouncilMultisig, "FARMBOSSV1: !(governance || farmer || multisig)");

        (uint256 amountIn, uint256 amountOutMin, address[] memory path, address to, uint256 deadline) = abi.decode(_data[4:], (uint256, uint256, address[], address, uint256));

        require(to == address(this), "FARMBOSSV1: invalid sell, to != address(this)");

        if (underlying == WETH){
            require(path.length == 2, "FARMBOSSV1: path.length != 2");
            require(path[1] == WETH, "FARMBOSSV1: WETH invalid sell, output != underlying");
        }
        else {
            require(path.length == 3, "FARMBOSSV1: path.length != 3");
            require(path[1] == WETH, "FARMBOSSV1: path[1] != WETH");
            require(path[2] == underlying, "FARMBOSSV1: invalid sell, output != underlying");
        }

        if (path[0] == CRVToken && CRVTokenTake > 0){
            uint256 _amtTake = amountIn.mul(CRVTokenTake).div(max); // take some portion, and send to governance

            amountIn = amountIn.sub(_amtTake);
            amountOutMin = amountOutMin.mul(max.sub(CRVTokenTake)).div(max); // reduce the amountOutMin by the same ratio, therefore target slippage pct is the same

            IERC20(CRVToken).safeTransfer(governance, _amtTake);
        }

        if (_isSushi){ // sell on Sushiswap
            return IUniswapRouterV2(SushiswapRouter).swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
        }
        else { // sell on Uniswap
            return IUniswapRouterV2(UniswapRouter).swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
        }
    }

    function rescue(address _token, uint256 _amount) external {
        require(msg.sender == governance, "FARMBOSSV1: !governance");

        if (_token != address(0)){
            IERC20(_token).safeTransfer(governance, _amount);
        }
        else { // if _tokenContract is 0x0, then escape ETH
            governance.transfer(_amount);
        }
    }
}

contract FarmBossV1_USDC is FarmBossV1 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;


    bytes4 constant private add_liquidity_2 = 0x0b4c7e4d;
    bytes4 constant private add_liquidity_3 = 0x4515cef3;
    bytes4 constant private add_liquidity_4 = 0x029b2f34;

    bytes4 constant private add_liquidity_u_2 = 0xee22be23;
    bytes4 constant private add_liquidity_u_3 = 0x2b6e993a;

    bytes4 constant private remove_liquidity_one_burn = 0x517a55a3;
    bytes4 constant private remove_liquidity_one = 0x1a4d01d2;

    bytes4 constant private remove_liquidity_4 = 0x18a7bd76;

    bytes4 constant private deposit_gauge = 0xb6b55f25; // deposit(uint256 _value)
    bytes4 constant private withdraw_gauge = 0x2e1a7d4d; // withdraw(uint256 _value)

    bytes4 constant private mint = 0x6a627842; // mint(address gauge_addr)
    bytes4 constant private mint_many = 0xa51e1904; // mint_many(address[8])
    bytes4 constant private claim_rewards = 0x84e9bd7e; // claim_rewards(address addr)

    bytes4 constant private deposit = 0xb6b55f25; // deposit(uint256 _amount)
    bytes4 constant private withdraw = 0x2e1a7d4d; // withdraw(uint256 _shares)

    bytes4 constant private claim = 0x2f52ebb7;

    bytes4 constant private mint_ctoken = 0xa0712d68; // mint(uint256 mintAmount)
    bytes4 constant private redeem_ctoken = 0xdb006a75; // redeem(uint256 redeemTokens)
    bytes4 constant private claim_COMP = 0x1c3db2e0; // claimComp(address holder, address[] cTokens)

    bytes4 constant private mint_idle = 0x2befabbf; // mintIdleToken(uint256 _amount, bool _skipRebalance, address _referral)
    bytes4 constant private redeem_idle = 0x8b30b516; // redeemIdleToken(uint256 _amount)

    constructor(address payable _governance, address _daoMultisig, address _treasury, address _underlying) public FarmBossV1(_governance, _daoMultisig, _treasury, _underlying){
    }

    function _initFirstFarms() internal override {




        address _crv3Pool = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
        address _crv3PoolToken = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
        _approveMax(underlying, _crv3Pool);
        _addWhitelist(_crv3Pool, add_liquidity_3, false);
        _addWhitelist(_crv3Pool, remove_liquidity_one, false);

        address _crv3Gauge = 0xbFcF63294aD7105dEa65aA58F8AE5BE2D9d0952A;
        _approveMax(_crv3PoolToken, _crv3Gauge);
        _addWhitelist(_crv3Pool, deposit_gauge, false);
        _addWhitelist(_crv3Pool, withdraw_gauge, false);

        address _crvSUSDPool = 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;
        address _crvSUSDToken = 0xC25a3A3b969415c80451098fa907EC722572917F;
        _approveMax(underlying, _crvSUSDPool);
        _addWhitelist(_crvSUSDPool, add_liquidity_4, false);
        _addWhitelist(_crvSUSDPool, remove_liquidity_4, false);

        address _crvSUSDWithdraw = 0xFCBa3E75865d2d561BE8D220616520c171F12851; // because crv frontend is misconfigured to think this is a lending pool
        _approveMax(underlying, _crvSUSDWithdraw);
        _approveMax(_crvSUSDToken, _crvSUSDWithdraw);
        _addWhitelist(_crvSUSDWithdraw, add_liquidity_4, false);
        _addWhitelist(_crvSUSDWithdraw, remove_liquidity_one_burn, false);

        address _crvSUSDGauge = 0xA90996896660DEcC6E997655E065b23788857849;
        _approveMax(_crvSUSDToken, _crvSUSDGauge);
        _addWhitelist(_crvSUSDGauge, deposit_gauge, false);
        _addWhitelist(_crvSUSDGauge, withdraw_gauge, false);
        _addWhitelist(_crvSUSDGauge, claim_rewards, false);

        address _SNXToken = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
        _approveMax(_SNXToken, SushiswapRouter);
        _approveMax(_SNXToken, UniswapRouter);

        address _crvCOMPDeposit = 0xeB21209ae4C2c9FF2a86ACA31E123764A3B6Bc06;
        address _crvCOMPToken = 0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2;
        _approveMax(underlying, _crvCOMPDeposit);
        _approveMax(_crvCOMPToken, _crvCOMPDeposit); // allow withdraws, lending pool
        _addWhitelist(_crvCOMPDeposit, add_liquidity_2, false);
        _addWhitelist(_crvCOMPDeposit, remove_liquidity_one_burn, false);

        address _crvCOMPGauge = 0x7ca5b0a2910B33e9759DC7dDB0413949071D7575;
        _approveMax(_crvCOMPToken, _crvCOMPGauge);
        _addWhitelist(_crvCOMPGauge, deposit_gauge, false);
        _addWhitelist(_crvCOMPGauge, withdraw_gauge, false);

        address _crvBUSDDeposit = 0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB;
        address _crvBUSDToken = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B;
        _approveMax(underlying, _crvBUSDDeposit);
        _approveMax(_crvBUSDToken, _crvBUSDDeposit);
        _addWhitelist(_crvBUSDDeposit, add_liquidity_4, false);
        _addWhitelist(_crvBUSDDeposit, remove_liquidity_one_burn, false);

        address _crvBUSDGauge = 0x69Fb7c45726cfE2baDeE8317005d3F94bE838840;
        _approveMax(_crvBUSDToken, _crvBUSDGauge);
        _addWhitelist(_crvBUSDGauge, deposit_gauge, false);
        _addWhitelist(_crvBUSDGauge, withdraw_gauge, false);

        address _crvAavePool = 0xDeBF20617708857ebe4F679508E7b7863a8A8EeE; // new style lending pool w/o second approve needed... direct burn from msg.sender
        address _crvAaveToken = 0xFd2a8fA60Abd58Efe3EeE34dd494cD491dC14900;
        _approveMax(underlying, _crvAavePool);
        _addWhitelist(_crvAavePool, add_liquidity_u_3, false);
        _addWhitelist(_crvAavePool, remove_liquidity_one_burn, false);

        address _crvAaveGauge = 0xd662908ADA2Ea1916B3318327A97eB18aD588b5d;
        _approveMax(_crvAaveToken, _crvAaveGauge);
        _addWhitelist(_crvAaveGauge, deposit_gauge, false);
        _addWhitelist(_crvAaveGauge, withdraw_gauge, false);

        address _crvYDeposit = 0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3;
        address _crvYToken = 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8;
        _approveMax(underlying, _crvYDeposit);
        _approveMax(_crvYToken, _crvYDeposit); // allow withdraws, lending pool
        _addWhitelist(_crvYDeposit, add_liquidity_4, false);
        _addWhitelist(_crvYDeposit, remove_liquidity_one_burn, false);

        address _crvYGauge = 0xFA712EE4788C042e2B7BB55E6cb8ec569C4530c1;
        _approveMax(_crvYToken, _crvYGauge);
        _addWhitelist(_crvYGauge, deposit_gauge, false);
        _addWhitelist(_crvYGauge, withdraw_gauge, false);

        address _crvUSDTCompDeposit = 0xac795D2c97e60DF6a99ff1c814727302fD747a80;
        address _crvUSDTCompToken = 0x9fC689CCaDa600B6DF723D9E47D84d76664a1F23;
        _approveMax(underlying, _crvUSDTCompDeposit);
        _approveMax(_crvUSDTCompToken, _crvUSDTCompDeposit);  // allow withdraws, lending pool
        _addWhitelist(_crvUSDTCompDeposit, add_liquidity_3, false);
        _addWhitelist(_crvUSDTCompDeposit, remove_liquidity_one_burn, false);

        address _crvUSDTCompGauge = 0xBC89cd85491d81C6AD2954E6d0362Ee29fCa8F53;
        _approveMax(_crvUSDTCompToken, _crvUSDTCompGauge);
        _addWhitelist(_crvUSDTCompGauge, deposit_gauge, false);
        _addWhitelist(_crvUSDTCompGauge, withdraw_gauge, false);

        address _crvIBPool = 0x2dded6Da1BF5DBdF597C45fcFaa3194e53EcfeAF;
        _approveMax(underlying, _crvIBPool);
        _addWhitelist(_crvIBPool, add_liquidity_u_3, false);
        _addWhitelist(_crvIBPool, remove_liquidity_one_burn, false);

        address _crvIBGauge = 0xF5194c3325202F456c95c1Cf0cA36f8475C1949F;
        address _crvIBToken = 0x5282a4eF67D9C33135340fB3289cc1711c13638C;
        _approveMax(_crvIBToken, _crvIBGauge);
        _addWhitelist(_crvIBGauge, deposit_gauge, false);
        _addWhitelist(_crvIBGauge, withdraw_gauge, false);

        address _crvMintr = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;
        _addWhitelist(_crvMintr, mint, false);
        _addWhitelist(_crvMintr, mint_many, false);

        _approveMax(CRVToken, SushiswapRouter);
        _approveMax(CRVToken, UniswapRouter);


        address _ahUSDC = 0x08bd64BFC832F1C2B3e07e634934453bA7Fa2db2;
        IERC20(underlying).safeApprove(_ahUSDC, type(uint256).max);
        whitelist[_ahUSDC][deposit] = ALLOWED_NO_MSG_VALUE;
        whitelist[_ahUSDC][withdraw] = ALLOWED_NO_MSG_VALUE;
        whitelist[_ahUSDC][claim] = ALLOWED_NO_MSG_VALUE; // claim ALPHA token reward

        _approveMax(underlying, _ahUSDC);
        _addWhitelist(_ahUSDC, deposit, false);
        _addWhitelist(_ahUSDC, withdraw, false);
        _addWhitelist(_ahUSDC, claim, false);

        address ALPHA_TOKEN = 0xa1faa113cbE53436Df28FF0aEe54275c13B40975;
        _approveMax(ALPHA_TOKEN, SushiswapRouter);
        _approveMax(ALPHA_TOKEN, UniswapRouter);

        address _yearnUSDC = 0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9;
        IERC20(underlying).safeApprove(_yearnUSDC, type(uint256).max);
        whitelist[_yearnUSDC][deposit] = ALLOWED_NO_MSG_VALUE;
        whitelist[_yearnUSDC][withdraw] = ALLOWED_NO_MSG_VALUE;

        _approveMax(underlying, _yearnUSDC);
        _addWhitelist(_yearnUSDC, deposit, false);
        _addWhitelist(_yearnUSDC, withdraw, false);

        address _compUSDC = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
        _approveMax(underlying, _compUSDC);
        _addWhitelist(_compUSDC, mint_ctoken, false);
        _addWhitelist(_compUSDC, redeem_ctoken, false);

        address _comptroller = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B; // claimComp
        _addWhitelist(_comptroller, claim_COMP, false);

        address _COMP = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
        _approveMax(_COMP, SushiswapRouter);
        _approveMax(_COMP, UniswapRouter);

        address _idleBestUSDCv4 = 0x5274891bEC421B39D23760c04A6755eCB444797C;
        _approveMax(underlying, _idleBestUSDCv4);
        _addWhitelist(_idleBestUSDCv4, mint_idle, false);
        _addWhitelist(_idleBestUSDCv4, redeem_idle, false);

        address IDLEToken = 0x875773784Af8135eA0ef43b5a374AaD105c5D39e;
        _approveMax(IDLEToken, SushiswapRouter);
        _approveMax(IDLEToken, UniswapRouter);

    }
}