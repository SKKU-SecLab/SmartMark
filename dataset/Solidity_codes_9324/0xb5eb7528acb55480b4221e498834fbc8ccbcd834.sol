

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


pragma solidity ^0.6.0;

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

}


pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function governance() public view returns (address) {

        return _owner;
    }

    modifier onlyGovernance() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferGovernance(address newOwner) internal virtual onlyGovernance {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

contract ReentrancyGuard {


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


interface StabilizeStrategy {

    function rewardTokensCount() external view returns (uint256);

    function rewardTokenAddress(uint256) external view returns (address);

    function withdrawTokenReserves() external view returns (address, uint256);

    function balance() external view returns (uint256);

    function pricePerToken() external view returns (uint256);

    function enter() external;

    function exit() external;

    function deposit(bool) external;

    function withdraw(address, uint256, uint256, bool) external returns (uint256); // Will withdraw to the address specified a percent of total shares

}

pragma solidity =0.6.6;

contract zsToken is ERC20("Stabilize Strategy Emerging USD Tokens v2", "zs-XUSD2"), Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    uint256 constant DIVISION_FACTOR = 100000;
    
    
    struct UserInfo {
        uint256 depositTime; // The time the user made the last deposit
        uint256 shareEstimate;
    }
    
    mapping(address => UserInfo) private userInfo;
    
    struct TokenInfo {
        IERC20 token; // Reference of token
        uint256 decimals; // Decimals of token
    }
    
    TokenInfo[] private tokenList; // An array of tokens accepted as deposits
    address private _underlyingPriceAsset; // Token from which the price is derived for STBZ staking
    bool public depositsOpen = true; // Governance can open or close deposits without timelock, cannot block withdrawals
    
    StabilizeStrategy private currentStrategy; // This will be the contract for the strategy
    address private _pendingStrategy;
    
    event Wrapped(address indexed user, uint256 amount);
    event Unwrapped(address indexed user, uint256 amount);

    constructor (address _priceAsset) public {
        _underlyingPriceAsset = _priceAsset;
        setupWithdrawTokens();
    }
    
    function setupWithdrawTokens() internal {

        IERC20 _token = IERC20(address(0x674C6Ad92Fd080e4004b2312b45f796a192D27a0));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        );   
        
        _token = IERC20(address(0xe2f2a5C287993345a840Db3B0845fbC70f5935a5));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        );
        
        _token = IERC20(address(0x5BC25f649fc4e26069dDF4cF4010F9f706c23831));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        );
        
        _token = IERC20(address(0x1456688345527bE1f37E9e627DA0837D6f08C925));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        );
        
        _token = IERC20(address(0xBC6DA0FE9aD5f3b0d58160288917AA56653660E9));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        );
    }
    
    function getCurrentStrategy() external view returns (address) {

        return address(currentStrategy);
    }
    
    function getPendingStrategy() external view returns (address) {

        return _pendingStrategy;
    }

    function underlyingAsset() public view returns (address) {

        return address(_underlyingPriceAsset);
    }
    
    function underlyingDepositAssets() public view returns (address[] memory) {

        address[] memory addresses = new address[](tokenList.length);
        uint256 length = tokenList.length;
        for(uint256 i = 0; i < length; i++){
            addresses[i] = address(tokenList[i].token);
        }
        return addresses;
    }
    
    function pricePerToken() public view returns (uint256) {

        if(totalSupply() == 0){
            return 1e18; // Shown in Wei units
        }else{
            return uint256(1e18).mul(valueOfVaultAndStrategy()).div(totalSupply());      
        }
    }
    
    function getNormalizedTotalBalance(address _address) public view returns (uint256) {

        uint256 _balance = 0;
        for(uint256 i = 0; i < tokenList.length; i++){
            uint256 _bal = tokenList[i].token.balanceOf(_address);
            _bal = _bal.mul(1e18).div(10**tokenList[i].decimals);
            _balance = _balance.add(_bal); // This has been normalized to 1e18 decimals
        }
        return _balance;
    }
    
    function valueOfVaultAndStrategy() public view returns (uint256) { // The total value of the tokens

        uint256 balance = getNormalizedTotalBalance(address(this)); // Get tokens stored in this contract
        if(currentStrategy != StabilizeStrategy(address(0))){
            balance += currentStrategy.balance(); // And tokens stored at the strategy
        }
        return balance;
    }
    
    function withdrawTokenReserves() public view returns (address, uint256) {

        if(currentStrategy != StabilizeStrategy(address(0))){
            return currentStrategy.withdrawTokenReserves();
        }else{
            uint256 length = tokenList.length;
            uint256 targetID = 0;
            uint256 targetNormBalance = 0;
            for(uint256 i = 0; i < length; i++){
                uint256 _normBal = tokenList[i].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[i].decimals);
                if(_normBal > 0){
                    if(targetNormBalance == 0 || _normBal >= targetNormBalance){
                        targetNormBalance = _normBal;
                        targetID = i;
                    }
                }
            }
            if(targetNormBalance > 0){
                return (address(tokenList[targetID].token), tokenList[targetID].token.balanceOf(address(this)));
            }else{
                return (address(0), 0); // No balance
            }
        }
    }
    
    
    function deposit(uint256 amount, uint256 _tokenID) public nonReentrant {

        uint256 total = valueOfVaultAndStrategy(); // Get token equivalent at strategy and here if applicable
        
        require(depositsOpen == true, "Deposits have been suspended, but you can still withdraw");
        require(currentStrategy != StabilizeStrategy(address(0)),"No strategy contract has been selected yet");
        require(_tokenID < tokenList.length, "Token ID is outside range of tokens in contract");
        
        IERC20 _token = tokenList[_tokenID].token; // Trusted tokens
        uint256 _before = _token.balanceOf(address(this));
        _token.safeTransferFrom(_msgSender(), address(this), amount); // Transfer token to this address
        amount = _token.balanceOf(address(this)).sub(_before); // Some tokens lose amount (transfer fee) upon transfer
        require(amount > 0, "Cannot deposit 0");
        bool nonContract = false;
        if(tx.origin == _msgSender()){
            nonContract = true; // The sender is not a contract
        }
        uint256 _strategyBalance = currentStrategy.balance(); // Will get the balance of the value of the main tokens at the strategy
        pushTokensToStrategy(); // Push any strategy tokens here into the strategy
        currentStrategy.deposit(nonContract); // Activate strategy deposit
        require(currentStrategy.balance() > _strategyBalance, "No change in strategy balance"); // Balance should increase
        uint256 normalizedAmount = amount.mul(1e18).div(10**tokenList[_tokenID].decimals); // Make sure everything is same units
        uint256 mintAmount = normalizedAmount;
        if(totalSupply() > 0){
            mintAmount = normalizedAmount.mul(totalSupply()).div(total); // Our share of the total
        }
        _mint(_msgSender(),mintAmount); // Now mint new zs-token to the depositor
        
        userInfo[_msgSender()].depositTime = now;
        userInfo[_msgSender()].shareEstimate = userInfo[_msgSender()].shareEstimate.add(mintAmount);

        emit Wrapped(_msgSender(), amount);
    }
    
    function redeem(uint256 share) public nonReentrant {

        require(share > 0, "Cannot withdraw 0");
        require(totalSupply() > 0, "No value redeemable");
        uint256 tokenTotal = totalSupply();
        _burn(_msgSender(),share); // Burn the amount, will fail if user doesn't have enough
        
        bool nonContract = false;
        if(tx.origin == _msgSender()){
            nonContract = true; // The sender is not a contract, we will allow market sells and buys
        }else{
            require(userInfo[_msgSender()].depositTime < now && userInfo[_msgSender()].depositTime > 0, "Contract depositor cannot redeem in same transaction");
        }
        
        if(share <= userInfo[_msgSender()].shareEstimate){
            userInfo[_msgSender()].shareEstimate = userInfo[_msgSender()].shareEstimate.sub(share);
        }else{
            userInfo[_msgSender()].shareEstimate = 0;
            require(nonContract == true, "Contract depositors cannot take out more than what they put in");
        }

        uint256 withdrawAmount = 0;
        if(currentStrategy != StabilizeStrategy(address(0))){
            withdrawAmount = currentStrategy.withdraw(_msgSender(), share, tokenTotal, nonContract); // Returns the amount of underlying removed
            require(withdrawAmount > 0, "Failed to withdraw from the strategy");
        }else{
            if(share < tokenTotal){
                uint256 _balance = getNormalizedTotalBalance(address(this));
                uint256 _myBalance = _balance.mul(share).div(tokenTotal);
                withdrawPerBalance(_msgSender(), _myBalance, false); // This will withdraw based on token balanace
                withdrawAmount = _myBalance;
            }else{
                uint256 _balance = getNormalizedTotalBalance(address(this));
                withdrawPerBalance(_msgSender(), _balance, true);
                withdrawAmount = _balance;
            }
        }
        
        emit Unwrapped(_msgSender(), withdrawAmount);
    }
    
    function withdrawPerBalance(address _receiver, uint256 _withdrawAmount, bool _takeAll) internal {

        uint256 length = tokenList.length;
        if(_takeAll == true){
            for(uint256 i = 0; i < length; i++){
                uint256 _bal = tokenList[i].token.balanceOf(address(this));
                if(_bal > 0){
                    tokenList[i].token.safeTransfer(_receiver, _bal);
                }
            }
            return;
        }
        bool[] memory done = new bool[](length);
        uint256 targetID = 0;
        uint256 targetNormBalance = 0;
        for(uint256 i = 0; i < length; i++){
            
            targetNormBalance = 0; // Reset the target balance
            for(uint256 i2 = 0; i2 < length; i2++){
                if(done[i2] == false){
                    uint256 _normBal = tokenList[i2].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[i2].decimals);
                    if(targetNormBalance == 0 || _normBal >= targetNormBalance){
                        targetNormBalance = _normBal;
                        targetID = i2;
                    }
                }
            }
            done[targetID] = true;
            
            uint256 _normalizedBalance = tokenList[targetID].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[targetID].decimals);
            if(_normalizedBalance <= _withdrawAmount){
                if(_normalizedBalance > 0){
                    _withdrawAmount = _withdrawAmount.sub(_normalizedBalance);
                    tokenList[targetID].token.safeTransfer(_receiver, tokenList[targetID].token.balanceOf(address(this)));                    
                }
            }else{
                if(_withdrawAmount > 0){
                    uint256 _balance = _withdrawAmount.mul(10**tokenList[targetID].decimals).div(1e18);
                    _withdrawAmount = 0;
                    tokenList[targetID].token.safeTransfer(_receiver, _balance);
                }
                break; // Nothing more to withdraw
            }
        }
    }
    
    
    function stopDeposits() external onlyGovernance {

        depositsOpen = false;
    }

    function startDeposits() external onlyGovernance {

        depositsOpen = true;
    }

    function emergencyStopStrategy() external onlyGovernance {

        depositsOpen = false;
        if(currentStrategy != StabilizeStrategy(address(0)) && totalSupply() > 0){
            currentStrategy.exit(); // Pulls all the tokens and accessory tokens from the strategy 
        }
        currentStrategy = StabilizeStrategy(address(0));
        _timelockType = 0; // Prevent governance from changing to new strategy without timelock
    }

    
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant TIMELOCK_DURATION = 86400; // Timelock is 24 hours
    
    address private _timelock_address;
    
    modifier timelockConditionsMet(uint256 _type) {

        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        if(totalSupply() > 0){
            require(now >= _timelockStart + TIMELOCK_DURATION, "Timelock time not met");
        }
        _;
    }
    
    function startGovernanceChange(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {

        transferGovernance(_timelock_address);
    }
    
    
    function startChangeStrategy(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 2;
        _timelock_address = _address;
        _pendingStrategy = _address;
        if(totalSupply() == 0){
            finishChangeStrategy();
        }
    }
    
    function finishChangeStrategy() public onlyGovernance timelockConditionsMet(2) {

        if(currentStrategy != StabilizeStrategy(address(0)) && totalSupply() > 0){
            currentStrategy.exit(); // Pulls all the tokens and accessory tokens from the strategy 
        }
        currentStrategy = StabilizeStrategy(_timelock_address);
        if(currentStrategy != StabilizeStrategy(address(0)) && totalSupply() > 0){
            pushTokensToStrategy(); // It will push any strategy reward tokens here to the new strategy
            currentStrategy.enter(); // Puts all the tokens and accessory tokens into the new strategy 
        }
        _pendingStrategy = address(0);
    }
    
    function pushTokensToStrategy() internal {

        uint256 tokenCount = currentStrategy.rewardTokensCount();
        for(uint256 i = 0; i < tokenCount; i++){
            IERC20 _token = IERC20(address(currentStrategy.rewardTokenAddress(i)));
            uint256 _balance = _token.balanceOf(address(this));
            if(_balance > 0){
                _token.safeTransfer(address(currentStrategy), _balance);
            }
        }
    }
    
    function startAddNewStableToken(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 3;
        _timelock_address = _address;
    }
    
    function finishAddNewStableToken() public onlyGovernance timelockConditionsMet(3) {

        IERC20 _token = IERC20(address(_timelock_address));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        );        
    }
}