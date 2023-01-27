
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

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

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}pragma solidity 0.6.12;


contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    modifier whenNotPaused() {
        require(!paused, "Has to be unpaused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Has to be paused");
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}pragma solidity 0.6.12;


contract Whitelist is Ownable {

    mapping(address => bool) public whitelist;
    bool public hasWhitelisting = false;

    event AddedToWhitelist(address account);
    event RemovedFromWhitelist(address account);

    modifier onlyWhitelisted() {
        if(hasWhitelisting){
            require(isWhitelisted(msg.sender));
        }
        _;
    }
    
    constructor (bool _hasWhitelisting) public{
        hasWhitelisting = _hasWhitelisting;
    }

    function add(address[] memory _addresses) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
            emit AddedToWhitelist(_addresses[i]);
        }
    }

    function remove(address[] memory _addresses) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            address uAddress = _addresses[i];
            if(whitelist[uAddress]){
                whitelist[uAddress] = false;
                emit RemovedFromWhitelist(uAddress);
            }
        }
    }


    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
}pragma solidity 0.6.12;
interface IidoMaster {
    
    function feeToken() external pure returns (ERC20Burnable);
    function feeWallet() external pure returns (address payable);

    function feeAmount() external pure returns (uint256);
    function burnPercent() external pure returns (uint256);
    function divider() external pure returns (uint256);
    function feeFundsPercent() external pure returns (uint256);

    function registrateIDO(
        address _poolAddress,
        uint256 _tokenPrice,
        address _payableToken,
        address _rewardToken,
        uint256 _startTimestamp,
        uint256 _finishTimestamp,
        uint256 _startClaimTimestamp,
        uint256 _minEthPayment,
        uint256 _maxEthPayment,
        uint256 _maxDistributedTokenAmount
    ) external;


}pragma solidity 0.6.12;
interface ITierSystem {
    


    function getMaxEthPayment(address user, uint256 maxEthPayment)
        external
        view
        returns (uint256);
}pragma solidity 0.6.12;


 contract IDOPool is Ownable, Pausable, Whitelist, ReentrancyGuard  {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    uint256 public tokenPrice;
    ERC20 public rewardToken;
    uint256 public decimals;
    uint256 public startTimestamp;
    uint256 public finishTimestamp;
    uint256 public startClaimTimestamp;
    uint256 public minEthPayment;
    uint256 public maxEthPayment;
    uint256 public maxDistributedTokenAmount;
    uint256 public tokensForDistribution;
    uint256 public distributedTokens;


    ITierSystem  public  tierSystem;
    IidoMaster  public  idoMaster;
    uint256 public feeFundsPercent;
    bool public enableTierSystem;

    struct UserInfo {
        uint debt;
        uint total;
        uint totalInvestedETH;
    }

    mapping(address => UserInfo) public userInfo;

    event TokensDebt(
        address indexed holder,
        uint256 ethAmount,
        uint256 tokenAmount
    );
    
    event TokensWithdrawn(address indexed holder, uint256 amount);
    event HasWhitelistingUpdated(bool newValue);
    event EnableTierSystemUpdated(bool newValue);
    event FundsWithdrawn(uint256 amount);
    event FundsFeeWithdrawn(uint256 amount);
    event NotSoldWithdrawn(uint256 amount);

    uint256 public vestingPercent;
    uint256 public vestingStart;
    uint256 public vestingInterval;
    uint256 public vestingDuration;

    event VestingUpdated(uint256 _vestingPercent,
                    uint256 _vestingStart,
                    uint256 _vestingInterval,
                    uint256 _vestingDuration);
    event VestingCreated(address indexed holder, uint256 amount);
    event VestingReleased(uint256 amount);

    struct Vesting {
        uint256 balance;
        uint256 released;
    }

    mapping (address => Vesting) private _vestings;

    constructor(
        IidoMaster _idoMaster,
        uint256 _feeFundsPercent, 
        uint256 _tokenPrice,
        ERC20 _rewardToken,
        uint256 _startTimestamp,
        uint256 _finishTimestamp,
        uint256 _startClaimTimestamp,
        uint256 _minEthPayment,
        uint256 _maxEthPayment,
        uint256 _maxDistributedTokenAmount,
        bool _hasWhitelisting,
        bool _enableTierSystem,
        ITierSystem _tierSystem
        
    ) public Whitelist(_hasWhitelisting) {
        idoMaster = _idoMaster;
        feeFundsPercent = _feeFundsPercent;
        tokenPrice = _tokenPrice;
        rewardToken = _rewardToken;
        decimals = rewardToken.decimals();

        require( _startTimestamp < _finishTimestamp,  "Start must be less than finish");
        require( _finishTimestamp > now, "Finish must be more than now");
        
        startTimestamp = _startTimestamp;
        finishTimestamp = _finishTimestamp;
        startClaimTimestamp = _startClaimTimestamp;
        minEthPayment = _minEthPayment;
        maxEthPayment = _maxEthPayment;
        maxDistributedTokenAmount = _maxDistributedTokenAmount;
        enableTierSystem = _enableTierSystem;
        tierSystem = _tierSystem;
    }


  function setVesting(uint256 _vestingPercent,
                    uint256 _vestingStart,
                    uint256 _vestingInterval,
                    uint256 _vestingDuration) external onlyOwner {

        require(now < startTimestamp, "Already started");

        require(_vestingPercent <= 100, "Vesting percent must be <= 100");
        if(_vestingPercent > 0)
        {
            require(_vestingInterval > 0 , "interval must be greater than 0");
            require(_vestingDuration >= _vestingInterval, "interval cannot be bigger than duration");
        }

        vestingPercent = _vestingPercent;
        vestingStart = _vestingStart;
        vestingInterval = _vestingInterval;
        vestingDuration = _vestingDuration;

        emit VestingUpdated(vestingPercent,
                            vestingStart,
                            vestingInterval,
                            vestingDuration);
    }


    function pay() payable external nonReentrant onlyWhitelisted whenNotPaused{
        require(msg.value >= minEthPayment, "Less then min amount");
        require(now >= startTimestamp, "Not started");
        require(now < finishTimestamp, "Ended");
        
        uint256 tokenAmount = getTokenAmount(msg.value);
        require(tokensForDistribution.add(tokenAmount) <= maxDistributedTokenAmount, "Overfilled");

        UserInfo storage user = userInfo[msg.sender];

        if(enableTierSystem){
            require(user.totalInvestedETH.add(msg.value) <= tierSystem.getMaxEthPayment(msg.sender, maxEthPayment), "More then max amount");
        }
        else{
            require(user.totalInvestedETH.add(msg.value) <= maxEthPayment, "More then max amount");
        }

        tokensForDistribution = tokensForDistribution.add(tokenAmount);
        user.totalInvestedETH = user.totalInvestedETH.add(msg.value);
        user.total = user.total.add(tokenAmount);
        user.debt = user.debt.add(tokenAmount);
        
        emit TokensDebt(msg.sender, msg.value, tokenAmount);
    }

    function getTokenAmount(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        return ethAmount.mul(10**decimals).div(tokenPrice);
    }


    function claimFor(address[] memory _addresses) external whenNotPaused{
         for (uint i = 0; i < _addresses.length; i++) {
            proccessClaim(_addresses[i]);
        }
    }

    function claim() external whenNotPaused{
        proccessClaim(msg.sender);
    }

    function proccessClaim(
        address _receiver
    ) internal nonReentrant{
        require(now > startClaimTimestamp, "Distribution not started");
        UserInfo storage user = userInfo[_receiver];
        uint256 _amount = user.debt;
        if (_amount > 0) {
            user.debt = 0;            
            distributedTokens = distributedTokens.add(_amount);

            if(vestingPercent > 0)
            {   
                uint256 vestingAmount = _amount.mul(vestingPercent).div(100);
                createVesting(_receiver, vestingAmount);
                _amount = _amount.sub(vestingAmount);
            }

            rewardToken.safeTransfer(_receiver, _amount);
            emit TokensWithdrawn(_receiver,_amount);
        }
    }

    function setHasWhitelisting(bool value) external onlyOwner{
        hasWhitelisting = value;
        emit HasWhitelistingUpdated(hasWhitelisting);
    } 

    function setEnableTierSystem(bool value) external onlyOwner{
        enableTierSystem = value;
        emit EnableTierSystemUpdated(enableTierSystem);
    } 

    function setTierSystem(ITierSystem _tierSystem) external onlyOwner {    
        tierSystem = _tierSystem;
    }

    function withdrawFunds() external onlyOwner nonReentrant{
        if(feeFundsPercent>0){
            uint256 feeAmount = address(this).balance.mul(feeFundsPercent).div(100);
            idoMaster.feeWallet().transfer(feeAmount); /* Fee Address */
            emit FundsFeeWithdrawn(feeAmount);
        }
        uint256 amount = address(this).balance;
        msg.sender.transfer(amount);
        emit FundsWithdrawn(amount);
    } 
     

    function withdrawNotSoldTokens() external onlyOwner nonReentrant{
        require(now > finishTimestamp, "Allow after finish time");
        uint256 amount = rewardToken.balanceOf(address(this)).add(distributedTokens).sub(tokensForDistribution);
        rewardToken.safeTransfer(msg.sender, amount);
        emit NotSoldWithdrawn(amount);
    }

    function getVesting(address beneficiary) public view returns (uint256, uint256) {
        Vesting memory v = _vestings[beneficiary];
        return (v.balance, v.released);
    }

    function createVesting(
        address beneficiary,
        uint256 amount
    ) private {
        Vesting storage vest = _vestings[beneficiary];
        require(vest.balance == 0, "Vesting already created");

        vest.balance = amount;

        emit VestingCreated(beneficiary, amount);
    }

     function release(address beneficiary) external nonReentrant {
        uint256 unreleased = releasableAmount(beneficiary);
        require(unreleased > 0, "Nothing to release");

        Vesting storage vest = _vestings[beneficiary];

        vest.released = vest.released.add(unreleased);
        vest.balance = vest.balance.sub(unreleased);

        rewardToken.safeTransfer(beneficiary, unreleased);
        emit VestingReleased(unreleased);
    }

    function releasableAmount(address beneficiary) public view returns (uint256) {
        return vestedAmount(beneficiary).sub(_vestings[beneficiary].released);
    }

    function vestedAmount(address beneficiary) public view returns (uint256) {
        if (block.timestamp < vestingStart) {
            return 0;
        }

        Vesting memory vest = _vestings[beneficiary];
        uint256 currentBalance = vest.balance;
        uint256 totalBalance = currentBalance.add(vest.released);

        if (block.timestamp >= vestingStart.add(vestingDuration)) {
            return totalBalance;
        } else {
            uint256 numberOfInvervals = block.timestamp.sub(vestingStart).div(vestingInterval);
            uint256 totalIntervals = vestingDuration.div(vestingInterval);
            return totalBalance.mul(numberOfInvervals).div(totalIntervals);
        }
    }

    function version() external pure returns (uint256) {
        return 101; // 1.0.1
    }
}pragma solidity 0.6.12;


contract IDOCreator is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Burnable;
    using SafeERC20 for ERC20;

    IidoMaster  public  idoMaster;
    ITierSystem  public  tierSystem;
    
    constructor(
        IidoMaster _idoMaster,
        ITierSystem _tierSystem
    ) public {
        idoMaster = _idoMaster;
        tierSystem = _tierSystem;
    }

    function createIDO(
        uint256 _tokenPrice,
        ERC20 _rewardToken,
        uint256 _startTimestamp,
        uint256 _finishTimestamp,
        uint256 _startClaimTimestamp,
        uint256 _minEthPayment,
        uint256 _maxEthPayment,
        uint256 _maxDistributedTokenAmount,
        bool _hasWhitelisting,
        bool _enableTierSystem
    ) external returns (address){
        
        if(idoMaster.feeAmount() > 0){
            uint256 burnAmount = idoMaster.feeAmount().mul(idoMaster.burnPercent()).div(idoMaster.divider());
            idoMaster.feeToken().safeTransferFrom(
                msg.sender,
                idoMaster.feeWallet(),
                idoMaster.feeAmount().sub(burnAmount)
            );
           
            if(burnAmount > 0) {
                idoMaster.feeToken().safeTransferFrom(msg.sender, address(this), burnAmount);
                idoMaster.feeToken().burn(burnAmount);
            }
        }

        IDOPool idoPool =
            new IDOPool(
                idoMaster,
                idoMaster.feeFundsPercent(),
                _tokenPrice,
                _rewardToken,
                _startTimestamp,
                _finishTimestamp,
                _startClaimTimestamp,
                _minEthPayment,
                _maxEthPayment,
                _maxDistributedTokenAmount,
                _hasWhitelisting,
                _enableTierSystem,
                tierSystem
            );

        idoPool.transferOwnership(msg.sender);

        _rewardToken.safeTransferFrom(
            msg.sender,
            address(idoPool),
            _maxDistributedTokenAmount
        );

        require(_rewardToken.balanceOf(address(idoPool)) == _maxDistributedTokenAmount,  "Unsupported token");

        idoMaster.registrateIDO(address(idoPool),   
                                _tokenPrice,
                                address(0),
                                address(_rewardToken),
                                _startTimestamp,
                                _finishTimestamp,
                                _startClaimTimestamp,
                                _minEthPayment,
                                _maxEthPayment,
                                _maxDistributedTokenAmount);

         return address(idoPool);
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function setTierSystem(ITierSystem _tierSystem) external onlyOwner {
        tierSystem = _tierSystem;
    }

    function version() external pure returns (uint256) {
        return 101; // 1.0.1
    }
}