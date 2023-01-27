

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

interface IWETH {   

    function deposit() payable external;

    function withdraw(uint256 wad) external;

}

contract FarmTreasuryV1_ETH is ReentrancyGuard, FarmTreasuryV1 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    constructor(string memory _nameUnderlying, uint8 _decimalsUnderlying, address _underlying) public FarmTreasuryV1(_nameUnderlying, _decimalsUnderlying, _underlying){
    }

    receive() payable external {
        if(msg.sender != underlyingContract){
            depositETH(address(0));
        }
    }

    function depositETH(address _referral) public payable nonReentrant {

        require(msg.value > 0, "FARMTREASURYV1: msg.value == 0");
        require(!paused && !pausedDeposits, "FARMTREASURYV1: paused");

        _deposit(msg.value, _referral);

        IWETH(underlyingContract).deposit{value: msg.value}();
    }

    function withdrawETH(uint256 _amountUnderlying) external nonReentrant {

        require(_amountUnderlying > 0, "FARMTREASURYV1: amount == 0");
        require(!paused, "FARMTREASURYV1: paused");

        _withdraw(_amountUnderlying);

        IWETH(underlyingContract).withdraw(_amountUnderlying);
        msg.sender.transfer(_amountUnderlying);
    }
}